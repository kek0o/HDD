/* This files provides address values that exist in the system */

#define BOARD                 "DE10-Standard"

/* Memory */
#define DDR_BASE              0x00000000
#define DDR_END               0x3FFFFFFF
#define A9_ONCHIP_BASE        0xFFFF0000
#define A9_ONCHIP_END         0xFFFFFFFF
#define SDRAM_BASE            0xC0000000
#define SDRAM_END             0xC3FFFFFF
#define FPGA_PIXEL_BUF_BASE   0xC8000000
#define FPGA_PIXEL_BUF_END    0xC803FFFF
#define FPGA_CHAR_BASE        0xC9000000
#define FPGA_CHAR_END         0xC9001FFF

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200020
#define SW_BASE               0xFF200010
#define KEY_BASE              0xFF200000
#define JTAG_UART_BASE        0xFF200030

/* Cyclone V HPS devices */
#define HPS_GPIO0_BASE        0xFF708000
#define HPS_GPIO1_BASE        0xFF709000
#define HPS_GPIO2_BASE        0xFF70A000
#define I2C0_BASE             0xFFC04000
#define I2C1_BASE             0xFFC05000
#define I2C2_BASE             0xFFC06000
#define I2C3_BASE             0xFFC07000
#define HPS_TIMER0_BASE       0xFFC08000
#define HPS_TIMER1_BASE       0xFFC09000
#define HPS_TIMER2_BASE       0xFFD00000
#define HPS_TIMER3_BASE       0xFFD01000
#define HPS_RSTMGR	      0xFFD05000
#define HPS_RSTMGR_PREMODRST  0xFFD05014
#define FPGA_BRIDGE           0xFFD0501C

#define PIN_MUX		      0xFFD08400
#define CLK_MGR		      0xFFD04000

#define SPIM0_BASE	      0xFFF00000
#define SPIM0_SR	      0xFFF00028
#define SPIM0_DR	      0xFFF00060
/* ARM A9 MPCORE devices */
#define   PERIPH_BASE         0xFFFEC000    // base address of peripheral devices
#define   MPCORE_PRIV_TIMER   0xFFFEC600    // PERIPH_BASE + 0x0600

/* Interrupt controller (GIC) CPU interface(s) */
#define MPCORE_GIC_CPUIF      0xFFFEC100    // PERIPH_BASE + 0x100
#define ICCICR                0x00          // offset to CPU interface control reg
#define ICCPMR                0x04          // offset to interrupt priority mask reg
#define ICCIAR                0x0C          // offset to interrupt acknowledge reg
#define ICCEOIR               0x10          // offset to end of interrupt reg
/* Interrupt controller (GIC) distributor interface(s) */
#define MPCORE_GIC_DIST       0xFFFED000    // PERIPH_BASE + 0x1000
#define ICDDCR                0x00          // offset to distributor control reg
#define ICDISER               0x100         // offset to interrupt set-enable regs
#define ICDICER               0x180         // offset to interrupt clear-enable regs
#define ICDIPTR               0x800         // offset to interrupt processor targets regs
#define ICDICFR               0xC00         // offset to interrupt configuration regs

/* AXI4 interface registers */
#define SLV_REG0_ADDR         0xFF200000    // slv_reg0 address
#define SLV_REG1_ADDR         0xFF200004    // slv_reg0 address
#define SLV_REG2_ADDR         0xFF200008    // slv_reg0 address
#define SLV_REG3_ADDR         0xFF20000C    // slv_reg0 address


