#include <fcntl.h>
#include <libfdt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define barrier() asm volatile ("" ::: "memory")
#define mb() barrier()
#define schedule() barrier()

typedef uint8_t __u8;
typedef uint32_t __u32;
typedef uint64_t __u64;

#include "xrp_api.h"
#include "../xrp-kernel/xrp_kernel_dsp_interface.h"
#include "xrp_alloc.h"

extern char dt_blob_start[];

struct xrp_shmem {
	phys_addr_t start;
	phys_addr_t size;
	const char *name;
	int fd;
	void *ptr;
};

static struct xrp_shmem *xrp_shmem;
static int xrp_shmem_count;

struct xrp_device_description {
	phys_addr_t io_base;
	phys_addr_t comm_base;
	phys_addr_t shared_base;
	phys_addr_t shared_size;
	void *comm_ptr;
	void *shared_ptr;
};

static struct xrp_device_description xrp_device_description[4];
static int xrp_device_count;

struct xrp_refcounted {
	unsigned long count;
};

struct xrp_device {
	struct xrp_refcounted ref;
	struct xrp_device_description *description;
	struct xrp_allocation_pool shared_pool;
};

struct xrp_buffer {
	struct xrp_refcounted ref;
	struct xrp_device *device;
	enum {
		XRP_BUFFER_TYPE_HOST,
		XRP_BUFFER_TYPE_DEVICE,
	} type;
	struct xrp_allocation *xrp_allocation;
	void *ptr;
	size_t size;
	unsigned long map_count;
	enum xrp_access_flags map_flags;
};

struct xrp_buffer_group_record {
	struct xrp_buffer *buffer;
	enum xrp_access_flags access_flags;
};

struct xrp_buffer_group {
	struct xrp_refcounted ref;
	size_t n_buffers;
	size_t capacity;
	struct xrp_buffer_group_record *buffer;
};

struct xrp_queue {
	struct xrp_refcounted ref;
	struct xrp_device *device;
};

struct xrp_event {
	struct xrp_refcounted ref;
	struct xrp_device *device;
	unsigned long cookie;
};

/* Helpers */

static inline void set_status(enum xrp_status *status, enum xrp_status v)
{
	if (status)
		*status = v;
}

static void *alloc_refcounted(size_t sz)
{
	void *buf = calloc(1, sz);
	struct xrp_refcounted *ref = buf;

	if (ref)
		ref->count = 1;

	return buf;
}

static enum xrp_status retain_refcounted(void *buf)
{
	struct xrp_refcounted *ref = buf;

	if (ref) {
		++ref->count;
		return XRP_STATUS_SUCCESS;
	}
	return XRP_STATUS_FAILURE;
}

static enum xrp_status release_refcounted(void *buf)
{
	struct xrp_refcounted *ref = buf;

	if (ref) {
		if (--ref->count == 0)
			free(buf);
		return XRP_STATUS_SUCCESS;
	}
	return XRP_STATUS_FAILURE;
}

static inline int last_refcount(const void *buf)
{
	const struct xrp_refcounted *ref = buf;

	return ref->count == 1;
}

static inline void xrp_comm_write32(volatile void *addr, __u32 v)
{
	*(volatile __u32 *)addr = v;
}

static inline __u32 xrp_comm_read32(volatile void *addr)
{
	return *(volatile __u32 *)addr;
}

static uint32_t getprop_u32(const void *value, int offset)
{
	fdt32_t v;

	memcpy(&v, value + offset, sizeof(v));
	return fdt32_to_cpu(v);
}

static struct xrp_shmem *find_shmem(phys_addr_t addr)
{
	int i;

	for (i = 0; i < xrp_shmem_count; ++i) {
		if (addr >= xrp_shmem[i].start &&
		    addr - xrp_shmem[i].start < xrp_shmem[i].size)
			return xrp_shmem + i;
	}
	return NULL;
}

static void *p2v(phys_addr_t addr)
{
	struct xrp_shmem *shmem = find_shmem(addr);

	if (shmem) {
		return shmem->ptr + addr - shmem->start;
	} else {
		return NULL;
	}
}

static void initialize_shmem(void)
{
	void *fdt = &dt_blob_start;
	const void *reg;
	const void *names;
	int reg_len, names_len;
	int offset, reg_offset = 0, name_offset = 0;
	int i;

	offset = fdt_node_offset_by_compatible(fdt,
					       -1, "cdns,sim-shmem");
	if (offset < 0) {
		printf("%s: cdns,sim-shmem device not found\n", __func__);
		return;
	}
	reg = fdt_getprop(fdt, offset, "reg", &reg_len);
	if (!reg) {
		printf("%s: %s\n", __func__, fdt_strerror(reg_len));
		return;
	}
	names = fdt_getprop(fdt, offset, "reg-names", &names_len);
	if (!names) {
		printf("%s: %s\n", __func__, fdt_strerror(names_len));
		return;
	}
	xrp_shmem_count = reg_len / 8;
	xrp_shmem = malloc(xrp_shmem_count * sizeof(struct xrp_shmem));

	for (i = 0; i < xrp_shmem_count; ++i) {
		int rc;
		const char *name = names + name_offset;

		xrp_shmem[i] = (struct xrp_shmem){
			.start = getprop_u32(reg, reg_offset),
			.size = getprop_u32(reg, reg_offset + 4),
			.name = name,
		};
		reg_offset += 8;
		name_offset += strlen(names + name_offset) + 1;

		xrp_shmem[i].fd = shm_open(xrp_shmem[i].name,
					   O_RDWR | O_CREAT, 0666);
		if (xrp_shmem[i].fd < 0) {
			perror("shm_open");
			break;
		}
		rc = ftruncate(xrp_shmem[i].fd, xrp_shmem[i].size);
		if (rc < 0) {
			perror("ftruncate");
			break;
		}
		xrp_shmem[i].ptr = mmap(NULL, xrp_shmem[i].size,
					PROT_READ | PROT_WRITE,
					MAP_SHARED, xrp_shmem[i].fd, 0);
		if (xrp_shmem[i].ptr == MAP_FAILED) {
			perror("mmap");
			break;
		}
	}
}

static void synchronize(int i)
{
	static const int irq_mode[] = {
		[0] = XRP_DSP_SYNC_IRQ_MODE_NONE,
		[1] = XRP_DSP_SYNC_IRQ_MODE_LEVEL,
		[2] = XRP_DSP_SYNC_IRQ_MODE_EDGE,
	};

	struct xrp_dsp_sync *shared_sync = xrp_device_description[i].comm_ptr;

	xrp_comm_write32(&shared_sync->sync, XRP_DSP_SYNC_START);
	mb();
	do {
		__u32 v = xrp_comm_read32(&shared_sync->sync);
		if (v == XRP_DSP_SYNC_DSP_READY)
			break;
		schedule();
	} while (1);

	xrp_comm_write32(&shared_sync->device_mmio_base,
			 xrp_device_description[i].io_base);
	xrp_comm_write32(&shared_sync->host_irq_mode,
			 irq_mode[0]);
	xrp_comm_write32(&shared_sync->host_irq_offset,
			 0);
	xrp_comm_write32(&shared_sync->host_irq_bit,
			 0);
	xrp_comm_write32(&shared_sync->device_irq_mode,
			 irq_mode[0]);
	xrp_comm_write32(&shared_sync->device_irq_offset,
			 0);
	xrp_comm_write32(&shared_sync->device_irq_bit,
			 0);
	xrp_comm_write32(&shared_sync->device_irq,
			 0);
	mb();
	xrp_comm_write32(&shared_sync->sync, XRP_DSP_SYNC_HOST_TO_DSP);
	mb();

	do {
		__u32 v = xrp_comm_read32(&shared_sync->sync);
		if (v == XRP_DSP_SYNC_DSP_TO_HOST)
			break;
		schedule();
	} while (1);

#if 0
	xrp_send_device_irq(xvp);

	if (xvp->host_irq_mode != XRP_IRQ_NONE) {
		int res = wait_for_completion_timeout(&xvp->completion,
						      XVP_TIMEOUT_JIFFIES);
		if (res == 0) {
			dev_err(xvp->dev,
				"host IRQ mode is requested, but DSP couldn't deliver IRQ during synchronization\n");
			goto err;
		}
	}
#endif
	xrp_comm_write32(&shared_sync->sync, XRP_DSP_SYNC_IDLE);

}

static void initialize(void)
{
	int i;
	int offset = -1;
	void *fdt = &dt_blob_start;

	initialize_shmem();

	for (i = 0; ; ++i) {
		const void *reg;
		int len;

		offset = fdt_node_offset_by_compatible(fdt,
						       offset, "cdns,xrp");
		if (offset < 0)
			break;

		reg = fdt_getprop(fdt, offset, "reg", &len);
		if (!reg) {
			printf("%s: %s\n", __func__, fdt_strerror(len));
			break;
		}
		if (len < 24) {
			printf("%s: reg property size is too small (%d)\n",
			       __func__, len);
			break;
		}

		xrp_device_description[i] = (struct xrp_device_description){
			.io_base = getprop_u32(reg, 0),
			.comm_base = getprop_u32(reg, 8),
			.shared_base = getprop_u32(reg, 16),
			.shared_size = getprop_u32(reg, 20),
		};

		xrp_device_description[i].comm_ptr =
			p2v(xrp_device_description[i].comm_base);
		if (!xrp_device_description[i].comm_ptr) {
			printf("%s: shmem not found for comm area @0x%08x\n",
			       __func__, xrp_device_description[i].comm_base);
			break;
		}

		xrp_device_description[i].shared_ptr =
			p2v(xrp_device_description[i].shared_base);
		if (!xrp_device_description[i].shared_ptr) {
			printf("%s: shmem not found for shared area @0x%08x\n",
			       __func__, xrp_device_description[i].shared_base);
			break;
		}

		synchronize(i);
		++xrp_device_count;
	}

}

/* Device API. */

struct xrp_device *xrp_open_device(int idx, enum xrp_status *status)
{
	struct xrp_device *device;

	if (!xrp_device_count) {
		initialize();
	}

	if (idx < 0 || idx > xrp_device_count) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}

	device = alloc_refcounted(sizeof(*device));
	if (!device) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}
	device->description = xrp_device_description + idx;
	xrp_init_pool(&device->shared_pool,
		      device->description->shared_base,
		      device->description->shared_size);

	set_status(status, XRP_STATUS_SUCCESS);
	return device;
}

void xrp_retain_device(struct xrp_device *device, enum xrp_status *status)
{
	set_status(status, retain_refcounted(device));
}

void xrp_release_device(struct xrp_device *device, enum xrp_status *status)
{
	if (last_refcount(device)) {
	}
	set_status(status, release_refcounted(device));
}


/* Buffer API. */

struct xrp_buffer *xrp_create_buffer(struct xrp_device *device,
				     size_t size, void *host_ptr,
				     enum xrp_status *status)
{
	struct xrp_buffer *buf;

	if (!host_ptr && !device) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}

	buf = alloc_refcounted(sizeof(*buf));

	if (!buf) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}

	if (!host_ptr) {
		long rc = xrp_allocate(&device->shared_pool, size, 0x10,
				       &buf->xrp_allocation);
		if (rc < 0) {
			release_refcounted(buf);
			set_status(status, XRP_STATUS_FAILURE);
			return NULL;
		}
		buf->type = XRP_BUFFER_TYPE_DEVICE;
		buf->ptr = p2v(buf->xrp_allocation->start);
		buf->size = size;
	} else {
		buf->type = XRP_BUFFER_TYPE_HOST;
		buf->ptr = host_ptr;
		buf->size = size;
	}
	return buf;
}

void xrp_retain_buffer(struct xrp_buffer *buffer, enum xrp_status *status)
{
	set_status(status, retain_refcounted(buffer));
}

void xrp_release_buffer(struct xrp_buffer *buffer, enum xrp_status *status)
{
	if (last_refcount(buffer)) {
		if (buffer->type == XRP_BUFFER_TYPE_DEVICE) {
			xrp_free(buffer->xrp_allocation);
		}
	}
	set_status(status, release_refcounted(buffer));
}

void *xrp_map_buffer(struct xrp_buffer *buffer, size_t offset, size_t size,
		     enum xrp_access_flags map_flags, enum xrp_status *status)
{
	if (offset <= buffer->size &&
	    size <= buffer->size - offset) {
		retain_refcounted(buffer);
		++buffer->map_count;
		buffer->map_flags |= map_flags;
		set_status(status, XRP_STATUS_SUCCESS);
		return buffer->ptr + offset;
	}
	set_status(status, XRP_STATUS_FAILURE);
	return NULL;
}

void xrp_unmap_buffer(struct xrp_buffer *buffer, void *p,
		      enum xrp_status *status)
{
	if (p >= buffer->ptr && (size_t)(p - buffer->ptr) <= buffer->size) {
		--buffer->map_count;
		release_refcounted(buffer);
		set_status(status, XRP_STATUS_SUCCESS);
	} else {
		set_status(status, XRP_STATUS_FAILURE);
	}
}


/* Buffer group API. */

struct xrp_buffer_group *xrp_create_buffer_group(enum xrp_status *status)
{
	struct xrp_buffer_group *group = alloc_refcounted(sizeof(*group));

	if (group)
		set_status(status, XRP_STATUS_SUCCESS);
	else
		set_status(status, XRP_STATUS_FAILURE);

	return group;
}

void xrp_retain_buffer_group(struct xrp_buffer_group *group,
			     enum xrp_status *status)
{
	set_status(status, retain_refcounted(group));
}

void xrp_release_buffer_group(struct xrp_buffer_group *group,
			      enum xrp_status *status)
{
	if (last_refcount(group)) {
		size_t i;

		for (i = 0; i < group->n_buffers; ++i)
			xrp_release_buffer(group->buffer[i].buffer, NULL);
		free(group->buffer);
	}
	set_status(status, release_refcounted(group));
}

size_t xrp_add_buffer_to_group(struct xrp_buffer_group *group,
			       struct xrp_buffer *buffer,
			       enum xrp_access_flags access_flags,
			       enum xrp_status *status)
{
	enum xrp_status s;

	if (group->n_buffers == group->capacity) {
		struct xrp_buffer_group_record *r =
			realloc(group->buffer,
				sizeof(struct xrp_buffer_group_record) *
				((group->capacity + 2) * 2));

		if (r == NULL) {
			set_status(status, XRP_STATUS_FAILURE);
			return -1;
		}
		group->buffer = r;
		group->capacity = (group->capacity + 2) * 2;
	}

	xrp_retain_buffer(buffer, &s);
	if (s != XRP_STATUS_SUCCESS) {
		set_status(status, s);
		return -1;
	}
	group->buffer[group->n_buffers].buffer = buffer;
	group->buffer[group->n_buffers].access_flags = access_flags;
	return group->n_buffers++;
}

struct xrp_buffer *xrp_get_buffer_from_group(struct xrp_buffer_group *group,
					     size_t idx,
					     enum xrp_status *status)
{
	if (idx < group->n_buffers) {
		set_status(status, XRP_STATUS_SUCCESS);

		return group->buffer[idx].buffer;
	}
	set_status(status, XRP_STATUS_FAILURE);
	return NULL;
}


/* Queue API. */

struct xrp_queue *xrp_create_queue(struct xrp_device *device,
				   enum xrp_status *status)
{
	struct xrp_queue *queue;
	enum xrp_status s;

	if (!device) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}

	queue = alloc_refcounted(sizeof(*queue));

	if (!queue) {
		set_status(status, XRP_STATUS_FAILURE);
		return NULL;
	}

	xrp_retain_device(device, &s);
	if (s != XRP_STATUS_SUCCESS) {
		set_status(status, s);
		release_refcounted(queue);
		return NULL;
	}
	queue->device = device;

	return queue;
}

void xrp_retain_queue(struct xrp_queue *queue, enum xrp_status *status)
{
	set_status(status, retain_refcounted(queue));
}

void xrp_release_queue(struct xrp_queue *queue, enum xrp_status *status)
{
	if (last_refcount(queue)) {
		enum xrp_status s;

		xrp_release_device(queue->device, &s);
		if (s != XRP_STATUS_SUCCESS) {
			set_status(status, s);
			return;
		}
	}
	set_status(status, release_refcounted(queue));
}


/* Event API. */

void xrp_retain_event(struct xrp_event *event, enum xrp_status *status)
{
	set_status(status, retain_refcounted(event));
}

void xrp_release_event(struct xrp_event *event, enum xrp_status *status)
{
	if (last_refcount(event)) {
		enum xrp_status s;

		xrp_release_device(event->device, &s);
		if (s != XRP_STATUS_SUCCESS) {
			set_status(status, s);
			return;
		}
	}
	set_status(status, release_refcounted(event));
}


/* Communication API */

void xrp_run_command_sync(struct xrp_queue *queue,
			  const void *in_data, size_t in_data_size,
			  void *out_data, size_t out_data_size,
			  struct xrp_buffer_group *buffer_group,
			  enum xrp_status *status)
{
	xrp_enqueue_command(queue, in_data, in_data_size,
			    out_data, out_data_size,
			    buffer_group, NULL, status);
}

void xrp_enqueue_command(struct xrp_queue *queue,
			 const void *in_data, size_t in_data_size,
			 void *out_data, size_t out_data_size,
			 struct xrp_buffer_group *buffer_group,
			 struct xrp_event **evt,
			 enum xrp_status *status)
{
	struct xrp_device *device = queue->device;
	struct xrp_event *event = NULL;
	size_t n_buffers = buffer_group ? buffer_group->n_buffers : 0;
	size_t i;
	struct xrp_dsp_cmd *dsp_cmd = device->description->comm_ptr;
	struct xrp_allocation *in_data_allocation;
	struct xrp_allocation *out_data_allocation;
	struct xrp_allocation *buffer_allocation;
	struct xrp_allocation *user_buffer_allocation[n_buffers];
	void *in_data_ptr;
	void *out_data_ptr;
	struct xrp_dsp_buffer *buffer_ptr;

	if (in_data_size > XRP_DSP_CMD_INLINE_DATA_SIZE) {
		long rc = xrp_allocate(&device->shared_pool, in_data_size,
				       0x10, &in_data_allocation);
		if (rc < 0) {
			set_status(status, XRP_STATUS_FAILURE);
			return;
		}
		dsp_cmd->in_data_addr = in_data_allocation->start;
		in_data_ptr = p2v(in_data_allocation->start);
	} else {
		in_data_ptr = &dsp_cmd->in_data;
	}
	dsp_cmd->in_data_size = in_data_size;
	memcpy(in_data_ptr, in_data, in_data_size);

	if (out_data_size > XRP_DSP_CMD_INLINE_DATA_SIZE) {
		long rc = xrp_allocate(&device->shared_pool, out_data_size,
				       0x10, &out_data_allocation);
		if (rc < 0) {
			set_status(status, XRP_STATUS_FAILURE);
			return;
		}
		dsp_cmd->out_data_addr = out_data_allocation->start;
		out_data_ptr = p2v(out_data_allocation->start);
	} else {
		out_data_ptr = &dsp_cmd->out_data;
	}
	dsp_cmd->out_data_size = out_data_size;

	if (n_buffers > XRP_DSP_CMD_INLINE_BUFFER_COUNT) {
		long rc = xrp_allocate(&device->shared_pool,
				       n_buffers * sizeof(struct xrp_dsp_buffer),
				       0x10, &buffer_allocation);
		if (rc < 0) {
			set_status(status, XRP_STATUS_FAILURE);
			return;
		}
		dsp_cmd->buffer_addr = buffer_allocation->start;
		buffer_ptr = p2v(buffer_allocation->start);
	} else {
		buffer_ptr = dsp_cmd->buffer_data;
	}
	dsp_cmd->buffer_size = n_buffers * sizeof(struct xrp_dsp_buffer);

	for (i = 0; i < n_buffers; ++i) {
		phys_addr_t addr;

		if (buffer_group->buffer[i].buffer->map_count > 0) {
			set_status(status, XRP_STATUS_FAILURE);
			return;

		}
		if (buffer_group->buffer[i].buffer->type == XRP_BUFFER_TYPE_DEVICE) {
			addr = buffer_group->buffer[i].buffer->xrp_allocation->start;
		} else {
			long rc = xrp_allocate(&device->shared_pool,
					       buffer_group->buffer[i].buffer->size,
					       0x10, user_buffer_allocation + i);

			if (rc < 0) {
				set_status(status, XRP_STATUS_FAILURE);
				return;
			}
			addr = user_buffer_allocation[i]->start;
			memcpy(p2v(addr), buffer_group->buffer[i].buffer->ptr,
			       buffer_group->buffer[i].buffer->size);
		}
		buffer_ptr[i] = (struct xrp_dsp_buffer){
			.flags = buffer_group->buffer[i].access_flags,
			.size = buffer_group->buffer[i].buffer->size,
			.addr = addr,
		};
	}

	if (evt) {
		enum xrp_status s;

		event = alloc_refcounted(sizeof(*event));
		if (!event) {
			set_status(status, XRP_STATUS_FAILURE);
			return;
		}
		xrp_retain_device(queue->device, &s);
		if (s != XRP_STATUS_SUCCESS) {
			set_status(status, s);
			release_refcounted(event);
			return;
		}
		event->device = queue->device;
	}

	barrier();
	xrp_comm_write32(&dsp_cmd->flags, XRP_DSP_CMD_FLAG_REQUEST_VALID);
	do {
		barrier();
	} while (xrp_comm_read32(&dsp_cmd->flags) !=
		 (XRP_DSP_CMD_FLAG_REQUEST_VALID |
		  XRP_DSP_CMD_FLAG_RESPONSE_VALID));

	memcpy(out_data, out_data_ptr, out_data_size);

	if (in_data_size > XRP_DSP_CMD_INLINE_DATA_SIZE) {
		xrp_free(in_data_allocation);
	}
	if (out_data_size > XRP_DSP_CMD_INLINE_DATA_SIZE) {
		xrp_free(out_data_allocation);
	}
	for (i = 0; i < n_buffers; ++i) {
		phys_addr_t addr;

		if (buffer_group->buffer[i].buffer->type != XRP_BUFFER_TYPE_DEVICE) {
			if (buffer_ptr[i].flags & XRP_DSP_BUFFER_FLAG_WRITE) {
				addr = user_buffer_allocation[i]->start;
				memcpy(buffer_group->buffer[i].buffer->ptr, p2v(addr),
				       buffer_group->buffer[i].buffer->size);
			}
			xrp_free(user_buffer_allocation[i]);
		}
	}
	if (n_buffers > XRP_DSP_CMD_INLINE_BUFFER_COUNT) {
		xrp_free(buffer_allocation);
	}

	if (evt) {
//		event->cookie = ioctl_queue.flags;
		*evt = event;
	}
	set_status(status, XRP_STATUS_SUCCESS);
}

void xrp_wait(struct xrp_event *event, enum xrp_status *status)
{
#if 0
	struct xrp_ioctl_wait ioctl_wait = {
		.cookie = event->cookie,
	};
	int ret = ioctl(event->device->fd,
			XRP_IOCTL_WAIT, &ioctl_wait);

	if (ret < 0) {
		set_status(status, XRP_STATUS_FAILURE);
		return;
	}
	set_status(status, XRP_STATUS_SUCCESS);
#endif
}