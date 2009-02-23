#ifndef __LPC24xx_H__
#define __LPC24xx_H__

#define T0IR         *((unsigned long *)0xE0004000)

#warning "Some registers addresses must be checked!!!!!"
#define VICVectCntl4 *((unsigned long *)0xE)
#define T0PR         *((unsigned long *)0xE)
#define T0TCR        *((unsigned long *)0xE)
#define T0CTCR       *((unsigned long *)0xE)
#define T0MR1        *((unsigned long *)0xE)
#define T0MCR        *((unsigned long *)0xE)
/* End of unchecked adresses list */
#define PCLKSEL0     *((unsigned long *)0xE01FC1A8)
#define VICIntEnable *((unsigned long *)0xFFFFF010)
#define VICVectAddr4 *((unsigned long *)0xFFFFF110)

#define VICVectAddr  *((unsigned long *)0xFFFFFF00)
#endif /* __LPC24xx_H__ */

