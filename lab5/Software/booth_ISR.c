#include "address_map_arm.h"

// Global flag to indicate an interrupt from the multiplier
external volatile int multiplier_interrupt_flag;

/***************************************************************************************
 * Booth - Interrupt Service Routine
 *
 * This routine clears the interrupt (ack) and sets the global interrupt flag  
****************************************************************************************/

void booth_ISR()
{
    volatile int * slv_reg3_ptr = (int *)SLV_REG3_ADDR; // pointer to slv_reg3 address

    // Clear the interrupt by writing 1, then 0 to bit 2 of slv_reg3 (ack input)
    *slv_reg3_ptr |= (1 << 2); // set bit 2 to 1
    *slv_reg3_ptr &= ~(1 << 2); // clear bit 2 to 0

    // Set global flag to indicate interrupt received
    multiplier_interrupt_flag = 1;
}

