/* This linker script generated from xt-genldscripts.tpp for LSP /home/rajivr/MultiCoreWare/MP/emul/sys-x86-linux/subsys.xtsys/package/cores/P6_0/xtensa-elf/lib/xtkc705-rt */
/* Linker Script for default link */
MEMORY
{
  dram0_0_seg :                       	org = 0x3FF00000, len = 0x80000
  dram1_0_seg :                       	org = 0x3FF80000, len = 0x80000
  sysrom_B0_seg :                     	org = 0x50000000, len = 0x300
  sysrom_D0_seg :                     	org = 0x50001000, len = 0x3FED00
  sysrom_D1_seg :                     	org = 0x503FFD00, len = 0x300
  sysrom_E0_seg :                     	org = 0x50600000, len = 0x4
  sysram_B0_seg :                     	org = 0x60000000, len = 0x178
  sysram_B1_seg :                     	org = 0x60000178, len = 0x8
  sysram_B2_seg :                     	org = 0x60000180, len = 0x38
  sysram_B3_seg :                     	org = 0x600001B8, len = 0x8
  sysram_B4_seg :                     	org = 0x600001C0, len = 0x38
  sysram_B5_seg :                     	org = 0x600001F8, len = 0x8
  sysram_B6_seg :                     	org = 0x60000200, len = 0x38
  sysram_B7_seg :                     	org = 0x60000238, len = 0x8
  sysram_B8_seg :                     	org = 0x60000240, len = 0x38
  sysram_B9_seg :                     	org = 0x60000278, len = 0x8
  sysram_B10_seg :                    	org = 0x60000280, len = 0x38
  sysram_B11_seg :                    	org = 0x600002B8, len = 0x48
  sysram_B12_seg :                    	org = 0x60000300, len = 0x40
  sysram_B13_seg :                    	org = 0x60000340, len = 0xFFFCC0
}

PHDRS
{
  sysram_l0_phdr PT_LOAD;
  dram0_0_phdr PT_LOAD;
  dram0_0_bss_phdr PT_LOAD;
  dram1_0_phdr PT_LOAD;
  dram1_0_bss_phdr PT_LOAD;
  sysrom_B0_phdr PT_LOAD;
  sysrom_C0_phdr PT_LOAD;
  sysrom_D0_phdr PT_LOAD;
  sysrom_D1_phdr PT_LOAD;
  sysrom_E0_phdr PT_LOAD;
  sysrom0_phdr PT_LOAD;
  sysram_B0_phdr PT_LOAD;
  sysram_B1_phdr PT_LOAD;
  sysram_B2_phdr PT_LOAD;
  sysram_B3_phdr PT_LOAD;
  sysram_B4_phdr PT_LOAD;
  sysram_B5_phdr PT_LOAD;
  sysram_B6_phdr PT_LOAD;
  sysram_B7_phdr PT_LOAD;
  sysram_B8_phdr PT_LOAD;
  sysram_B9_phdr PT_LOAD;
  sysram_B10_phdr PT_LOAD;
  sysram_B11_phdr PT_LOAD;
  sysram_B12_phdr PT_LOAD;
  sysram_B13_phdr PT_LOAD;
  sysram_B13_bss_phdr PT_LOAD;
  sysram0_phdr PT_LOAD;
  sharedram_l0_phdr PT_LOAD;
  mmio0_phdr PT_LOAD;
}


/*  Default entry point:  */
ENTRY(_ResetVector)

/*  Memory boundary addresses:  */
_memmap_mem_sysram_l_start = 0x4;
_memmap_mem_sysram_l_end   = 0x10000000;
_memmap_mem_dram0_start = 0x3ff00000;
_memmap_mem_dram0_end   = 0x3ff80000;
_memmap_mem_dram1_start = 0x3ff80000;
_memmap_mem_dram1_end   = 0x40000000;
_memmap_mem_sysrom_B_start = 0x50000000;
_memmap_mem_sysrom_B_end   = 0x50000300;
_memmap_mem_sysrom_C_start = 0x50000300;
_memmap_mem_sysrom_C_end   = 0x50001000;
_memmap_mem_sysrom_D_start = 0x50001000;
_memmap_mem_sysrom_D_end   = 0x50400000;
_memmap_mem_sysrom_E_start = 0x50600000;
_memmap_mem_sysrom_E_end   = 0x50600004;
_memmap_mem_sysrom_start = 0x50600008;
_memmap_mem_sysrom_end   = 0x51000000;
_memmap_mem_sysram_B_start = 0x60000000;
_memmap_mem_sysram_B_end   = 0x61000000;
_memmap_mem_sysram_start = 0x61800000;
_memmap_mem_sysram_end   = 0x64000000;
_memmap_mem_sharedram_l_start = 0xf0000000;
_memmap_mem_sharedram_l_end   = 0xf8000000;
_memmap_mem_mmio_start = 0xfd000000;
_memmap_mem_mmio_end   = 0xfe000000;

/*  Memory segment boundary addresses:  */
_memmap_seg_dram0_0_start = 0x3ff00000;
_memmap_seg_dram0_0_max   = 0x3ff80000;
_memmap_seg_dram1_0_start = 0x3ff80000;
_memmap_seg_dram1_0_max   = 0x40000000;
_memmap_seg_sysrom_B0_start = 0x50000000;
_memmap_seg_sysrom_B0_max   = 0x50000300;
_memmap_seg_sysrom_D0_start = 0x50001000;
_memmap_seg_sysrom_D0_max   = 0x503ffd00;
_memmap_seg_sysrom_D1_start = 0x503ffd00;
_memmap_seg_sysrom_D1_max   = 0x50400000;
_memmap_seg_sysrom_E0_start = 0x50600000;
_memmap_seg_sysrom_E0_max   = 0x50600004;
_memmap_seg_sysram_B0_start = 0x60000000;
_memmap_seg_sysram_B0_max   = 0x60000178;
_memmap_seg_sysram_B1_start = 0x60000178;
_memmap_seg_sysram_B1_max   = 0x60000180;
_memmap_seg_sysram_B2_start = 0x60000180;
_memmap_seg_sysram_B2_max   = 0x600001b8;
_memmap_seg_sysram_B3_start = 0x600001b8;
_memmap_seg_sysram_B3_max   = 0x600001c0;
_memmap_seg_sysram_B4_start = 0x600001c0;
_memmap_seg_sysram_B4_max   = 0x600001f8;
_memmap_seg_sysram_B5_start = 0x600001f8;
_memmap_seg_sysram_B5_max   = 0x60000200;
_memmap_seg_sysram_B6_start = 0x60000200;
_memmap_seg_sysram_B6_max   = 0x60000238;
_memmap_seg_sysram_B7_start = 0x60000238;
_memmap_seg_sysram_B7_max   = 0x60000240;
_memmap_seg_sysram_B8_start = 0x60000240;
_memmap_seg_sysram_B8_max   = 0x60000278;
_memmap_seg_sysram_B9_start = 0x60000278;
_memmap_seg_sysram_B9_max   = 0x60000280;
_memmap_seg_sysram_B10_start = 0x60000280;
_memmap_seg_sysram_B10_max   = 0x600002b8;
_memmap_seg_sysram_B11_start = 0x600002b8;
_memmap_seg_sysram_B11_max   = 0x60000300;
_memmap_seg_sysram_B12_start = 0x60000300;
_memmap_seg_sysram_B12_max   = 0x60000340;
_memmap_seg_sysram_B13_start = 0x60000340;
_memmap_seg_sysram_B13_max   = 0x61000000;

_rom_store_table = 0;
_ResetTable_base = 0x50600000;
PROVIDE(_memmap_vecbase_reset = 0x60000000);
PROVIDE(_memmap_reset_vector = 0x50000000);
/* Various memory-map dependent cache attribute settings: */
_memmap_cacheattr_wb_base = 0x10041141;
_memmap_cacheattr_wt_base = 0x30043343;
_memmap_cacheattr_bp_base = 0x40044444;
_memmap_cacheattr_unused_mask = 0x0FF00000;
_memmap_cacheattr_wb_trapnull = 0x14441141;
_memmap_cacheattr_wba_trapnull = 0x14441141;
_memmap_cacheattr_wbna_trapnull = 0x24442242;
_memmap_cacheattr_wt_trapnull = 0x34443343;
_memmap_cacheattr_bp_trapnull = 0x44444444;
_memmap_cacheattr_wb_strict = 0x10041141;
_memmap_cacheattr_wt_strict = 0x30043343;
_memmap_cacheattr_bp_strict = 0x40044444;
_memmap_cacheattr_wb_allvalid = 0x14441141;
_memmap_cacheattr_wt_allvalid = 0x34443343;
_memmap_cacheattr_bp_allvalid = 0x44444444;
PROVIDE(_memmap_cacheattr_reset = _memmap_cacheattr_wb_trapnull);

SECTIONS
{

  .dram0.rodata : ALIGN(4)
  {
    _dram0_rodata_start = ABSOLUTE(.);
    *(.dram0.rodata)
    _dram0_rodata_end = ABSOLUTE(.);
  } >dram0_0_seg :dram0_0_phdr

  .dram0.literal : ALIGN(4)
  {
    _dram0_literal_start = ABSOLUTE(.);
    *(.dram0.literal)
    _dram0_literal_end = ABSOLUTE(.);
  } >dram0_0_seg :dram0_0_phdr

  .dram0.data : ALIGN(4)
  {
    _dram0_data_start = ABSOLUTE(.);
    *(.dram0.data)
    _dram0_data_end = ABSOLUTE(.);
  } >dram0_0_seg :dram0_0_phdr

  .dram0.bss (NOLOAD) : ALIGN(8)
  {
    . = ALIGN (8);
    _dram0_bss_start = ABSOLUTE(.);
    *(.dram0.bss)
    . = ALIGN (8);
    _dram0_bss_end = ABSOLUTE(.);
    _memmap_seg_dram0_0_end = ALIGN(0x8);
  } >dram0_0_seg :dram0_0_bss_phdr

  .dram1.rodata : ALIGN(4)
  {
    _dram1_rodata_start = ABSOLUTE(.);
    *(.dram1.rodata)
    _dram1_rodata_end = ABSOLUTE(.);
  } >dram1_0_seg :dram1_0_phdr

  .dram1.literal : ALIGN(4)
  {
    _dram1_literal_start = ABSOLUTE(.);
    *(.dram1.literal)
    _dram1_literal_end = ABSOLUTE(.);
  } >dram1_0_seg :dram1_0_phdr

  .dram1.data : ALIGN(4)
  {
    _dram1_data_start = ABSOLUTE(.);
    *(.dram1.data)
    _dram1_data_end = ABSOLUTE(.);
  } >dram1_0_seg :dram1_0_phdr

  .dram1.bss (NOLOAD) : ALIGN(8)
  {
    . = ALIGN (8);
    _dram1_bss_start = ABSOLUTE(.);
    *(.dram1.bss)
    . = ALIGN (8);
    _dram1_bss_end = ABSOLUTE(.);
    _memmap_seg_dram1_0_end = ALIGN(0x8);
  } >dram1_0_seg :dram1_0_bss_phdr

  .SharedResetVector.text : ALIGN(4)
  {
    _SharedResetVector_text_start = ABSOLUTE(.);
    KEEP (*(.SharedResetVector.text))
    _SharedResetVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysrom_B0_end = ALIGN(0x8);
  } >sysrom_B0_seg :sysrom_B0_phdr

  .sysrom.rodata : ALIGN(4)
  {
    _sysrom_rodata_start = ABSOLUTE(.);
    *(.sysrom.rodata)
    _sysrom_rodata_end = ABSOLUTE(.);
  } >sysrom_D0_seg :sysrom_D0_phdr

  .sysrom.text : ALIGN(4)
  {
    _sysrom_text_start = ABSOLUTE(.);
    *(.sysrom.literal .sysrom.text)
    _sysrom_text_end = ABSOLUTE(.);
    _memmap_seg_sysrom_D0_end = ALIGN(0x8);
  } >sysrom_D0_seg :sysrom_D0_phdr

  .ResetVector.text : ALIGN(4)
  {
    _ResetVector_text_start = ABSOLUTE(.);
    *(.ResetVector.literal .ResetVector.text)
    _ResetVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysrom_D1_end = ALIGN(0x8);
  } >sysrom_D1_seg :sysrom_D1_phdr

  .ResetTable.rodata : ALIGN(4)
  {
    _ResetTable_rodata_start = ABSOLUTE(.);
    *(.ResetTable.rodata)
    _ResetTable_rodata_end = ABSOLUTE(.);
    _memmap_seg_sysrom_E0_end = ALIGN(0x8);
  } >sysrom_E0_seg :sysrom_E0_phdr

  .WindowVectors.text : ALIGN(4)
  {
    _WindowVectors_text_start = ABSOLUTE(.);
    KEEP (*(.WindowVectors.text))
    _WindowVectors_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B0_end = ALIGN(0x8);
  } >sysram_B0_seg :sysram_B0_phdr

  .Level2InterruptVector.literal : ALIGN(4)
  {
    _Level2InterruptVector_literal_start = ABSOLUTE(.);
    *(.Level2InterruptVector.literal)
    _Level2InterruptVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B1_end = ALIGN(0x8);
  } >sysram_B1_seg :sysram_B1_phdr

  .Level2InterruptVector.text : ALIGN(4)
  {
    _Level2InterruptVector_text_start = ABSOLUTE(.);
    KEEP (*(.Level2InterruptVector.text))
    _Level2InterruptVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B2_end = ALIGN(0x8);
  } >sysram_B2_seg :sysram_B2_phdr

  .DebugExceptionVector.literal : ALIGN(4)
  {
    _DebugExceptionVector_literal_start = ABSOLUTE(.);
    *(.DebugExceptionVector.literal)
    _DebugExceptionVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B3_end = ALIGN(0x8);
  } >sysram_B3_seg :sysram_B3_phdr

  .DebugExceptionVector.text : ALIGN(4)
  {
    _DebugExceptionVector_text_start = ABSOLUTE(.);
    KEEP (*(.DebugExceptionVector.text))
    _DebugExceptionVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B4_end = ALIGN(0x8);
  } >sysram_B4_seg :sysram_B4_phdr

  .NMIExceptionVector.literal : ALIGN(4)
  {
    _NMIExceptionVector_literal_start = ABSOLUTE(.);
    *(.NMIExceptionVector.literal)
    _NMIExceptionVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B5_end = ALIGN(0x8);
  } >sysram_B5_seg :sysram_B5_phdr

  .NMIExceptionVector.text : ALIGN(4)
  {
    _NMIExceptionVector_text_start = ABSOLUTE(.);
    KEEP (*(.NMIExceptionVector.text))
    _NMIExceptionVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B6_end = ALIGN(0x8);
  } >sysram_B6_seg :sysram_B6_phdr

  .KernelExceptionVector.literal : ALIGN(4)
  {
    _KernelExceptionVector_literal_start = ABSOLUTE(.);
    *(.KernelExceptionVector.literal)
    _KernelExceptionVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B7_end = ALIGN(0x8);
  } >sysram_B7_seg :sysram_B7_phdr

  .KernelExceptionVector.text : ALIGN(4)
  {
    _KernelExceptionVector_text_start = ABSOLUTE(.);
    KEEP (*(.KernelExceptionVector.text))
    _KernelExceptionVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B8_end = ALIGN(0x8);
  } >sysram_B8_seg :sysram_B8_phdr

  .UserExceptionVector.literal : ALIGN(4)
  {
    _UserExceptionVector_literal_start = ABSOLUTE(.);
    *(.UserExceptionVector.literal)
    _UserExceptionVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B9_end = ALIGN(0x8);
  } >sysram_B9_seg :sysram_B9_phdr

  .UserExceptionVector.text : ALIGN(4)
  {
    _UserExceptionVector_text_start = ABSOLUTE(.);
    KEEP (*(.UserExceptionVector.text))
    _UserExceptionVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B10_end = ALIGN(0x8);
  } >sysram_B10_seg :sysram_B10_phdr

  .DoubleExceptionVector.literal : ALIGN(4)
  {
    _DoubleExceptionVector_literal_start = ABSOLUTE(.);
    *(.DoubleExceptionVector.literal)
    _DoubleExceptionVector_literal_end = ABSOLUTE(.);
    _memmap_seg_sysram_B11_end = ALIGN(0x8);
  } >sysram_B11_seg :sysram_B11_phdr

  .DoubleExceptionVector.text : ALIGN(4)
  {
    _DoubleExceptionVector_text_start = ABSOLUTE(.);
    KEEP (*(.DoubleExceptionVector.text))
    _DoubleExceptionVector_text_end = ABSOLUTE(.);
    _memmap_seg_sysram_B12_end = ALIGN(0x8);
  } >sysram_B12_seg :sysram_B12_phdr

  .sysram.rodata : ALIGN(4)
  {
    _sysram_rodata_start = ABSOLUTE(.);
    *(.sysram.rodata)
    _sysram_rodata_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .rodata : ALIGN(4)
  {
    _rodata_start = ABSOLUTE(.);
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    *(.rodata1)
    __XT_EXCEPTION_TABLE__ = ABSOLUTE(.);
    KEEP (*(.xt_except_table))
    KEEP (*(.gcc_except_table))
    *(.gnu.linkonce.e.*)
    *(.gnu.version_r)
    KEEP (*(.eh_frame))
    /*  C++ constructor and destructor tables, properly ordered:  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
    /*  C++ exception handlers table:  */
    __XT_EXCEPTION_DESCS__ = ABSOLUTE(.);
    *(.xt_except_desc)
    *(.gnu.linkonce.h.*)
    __XT_EXCEPTION_DESCS_END__ = ABSOLUTE(.);
    *(.xt_except_desc_end)
    *(.dynamic)
    *(.gnu.version_d)
    . = ALIGN(4);		/* this table MUST be 4-byte aligned */
    _bss_table_start = ABSOLUTE(.);
    LONG(_dram0_bss_start)
    LONG(_dram0_bss_end)
    LONG(_dram1_bss_start)
    LONG(_dram1_bss_end)
    LONG(_bss_start)
    LONG(_bss_end)
    _bss_table_end = ABSOLUTE(.);
    _rodata_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .SharedResetVector.literal : ALIGN(4)
  {
    _SharedResetVector_literal_start = ABSOLUTE(.);
    *(.SharedResetVector.literal)
    _SharedResetVector_literal_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .sysram.text : ALIGN(4)
  {
    _sysram_text_start = ABSOLUTE(.);
    *(.sysram.literal .sysram.text)
    _sysram_text_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .text : ALIGN(4)
  {
    _stext = .;
    _text_start = ABSOLUTE(.);
    *(.entry.text)
    *(.init.literal)
    KEEP(*(.init))
    *(.literal .text .literal.* .text.* .stub .gnu.warning .gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
    *(.fini.literal)
    KEEP(*(.fini))
    *(.gnu.version)
    _text_end = ABSOLUTE(.);
    _etext = .;
  } >sysram_B13_seg :sysram_B13_phdr

  .sysram.data : ALIGN(4)
  {
    _sysram_data_start = ABSOLUTE(.);
    *(.sysram.data)
    _sysram_data_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .data : ALIGN(4)
  {
    _data_start = ABSOLUTE(.);
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
    KEEP(*(.gnu.linkonce.d.*personality*))
    *(.data1)
    *(.sdata)
    *(.sdata.*)
    *(.gnu.linkonce.s.*)
    *(.sdata2)
    *(.sdata2.*)
    *(.gnu.linkonce.s2.*)
    KEEP(*(.jcr))
    _data_end = ABSOLUTE(.);
  } >sysram_B13_seg :sysram_B13_phdr

  .bss (NOLOAD) : ALIGN(8)
  {
    . = ALIGN (8);
    _bss_start = ABSOLUTE(.);
    *(.dynsbss)
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    *(.scommon)
    *(.sbss2)
    *(.sbss2.*)
    *(.gnu.linkonce.sb2.*)
    *(.dynbss)
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    *(.sysram.bss)
    . = ALIGN (8);
    _bss_end = ABSOLUTE(.);
    _end = ALIGN(0x8);
    PROVIDE(end = ALIGN(0x8));
    _stack_sentry = ALIGN(0x8);
    _memmap_seg_sysram_B13_end = ALIGN(0x8);
  } >sysram_B13_seg :sysram_B13_bss_phdr
  PROVIDE(__stack = 0x61000000);
  _heap_sentry = 0x61000000;
  .debug  0 :  { *(.debug) }
  .line  0 :  { *(.line) }
  .debug_srcinfo  0 :  { *(.debug_srcinfo) }
  .debug_sfnames  0 :  { *(.debug_sfnames) }
  .debug_aranges  0 :  { *(.debug_aranges) }
  .debug_pubnames  0 :  { *(.debug_pubnames) }
  .debug_info  0 :  { *(.debug_info) }
  .debug_abbrev  0 :  { *(.debug_abbrev) }
  .debug_line  0 :  { *(.debug_line) }
  .debug_frame  0 :  { *(.debug_frame) }
  .debug_str  0 :  { *(.debug_str) }
  .debug_loc  0 :  { *(.debug_loc) }
  .debug_macinfo  0 :  { *(.debug_macinfo) }
  .debug_weaknames  0 :  { *(.debug_weaknames) }
  .debug_funcnames  0 :  { *(.debug_funcnames) }
  .debug_typenames  0 :  { *(.debug_typenames) }
  .debug_varnames  0 :  { *(.debug_varnames) }
  .xt.insn 0 :
  {
    KEEP (*(.xt.insn))
    KEEP (*(.gnu.linkonce.x.*))
  }
  .xt.prop 0 :
  {
    KEEP (*(.xt.prop))
    KEEP (*(.xt.prop.*))
    KEEP (*(.gnu.linkonce.prop.*))
  }
  .xt.lit 0 :
  {
    KEEP (*(.xt.lit))
    KEEP (*(.xt.lit.*))
    KEEP (*(.gnu.linkonce.p.*))
  }
  .debug.xt.callgraph 0 :
  {
    KEEP (*(.debug.xt.callgraph .debug.xt.callgraph.* .gnu.linkonce.xt.callgraph.*))
  }
}

