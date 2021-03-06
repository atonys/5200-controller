# Makefile for programming the ATtiny85
# modified the one generated by CrossPack

DEVICE      = attiny85
CLOCK      = 8000000
PROGRAMMER = -c usbtiny 
# for ATTiny85
# see http://www.engbedded.com/fusecalc/
FUSES       = -U lfuse:w:0xE2:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m 

# Tune the lines below only if you know what you are doing:
AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

# symbolic targets:
all:	5200controller.hex digipot-cycle.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(COMPILE) -S $< -o $@

flash:	all
	$(AVRDUDE) -B 3 -c usbasp -U flash:w:5200controller.hex:i

fuse:
	$(AVRDUDE) -B 3 -c usbasp $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID 5200controller.hex

clean:
	rm -f 5200controller.hex 5200controller.elf digipot-cycle.hex digipot-cycle.elf

# file targets:
5200controller.elf: 5200controller.c
	$(COMPILE) -o 5200controller.elf 5200controller.c

5200controller.hex: 5200controller.elf
	rm -f 5200controller.hex
	avr-objcopy -j .text -j .data -O ihex 5200controller.elf 5200controller.hex
#	avr-size --format=avr --mcu=$(DEVICE) 5200controller.elf
	avr-size 5200controller.elf

digipot-cycle.elf: digipot-cycle.c
	$(COMPILE) -o digipot-cycle.elf digipot-cycle.c

digipot-cycle.hex: digipot-cycle.elf
	rm -f digipot-cycle.hex
	avr-objcopy -j .text -j .data -O ihex digipot-cycle.elf digipot-cycle.hex
#       avr-size --format=avr --mcu=$(DEVICE) digipot-cycle.elf
	avr-size digipot-cycle.elf

# Targets for code debugging and analysis:
disasm:	5200controller.elf
	avr-objdump -d 5200controller.elf

cpp:
	$(COMPILE) -E 5200controller.c
