I N C O M P L E T E
===================
____________________

# Ada-on-RPi0

## A GNAT Ada runtime library for the Raspberry Pi Zero - RPi0

In **rpi0-runtimes** are bare board runtime libraries (bb-runtimes) for the RPi0 for the standard 3 profiles: Zero FootPrint, Ravenscar Small and Full.

The standard source of (other) runtimes is here: https://github.com/AdaCore/bb-runtimes

Only the Zero FootPrint library has been tested. It is in rpio-runtimes/zfp-rpi0.

These runtimes were created by cloning the rpi2 information, altering this and then building as described in the link above.  The following files are new and are in the libraries:

- /src/s-bbbosu__rpi0.adb 
   
- /src/s-textio__rpi0-mini.adb
   
- /src/s-bbpara__rpi0.ads
   
- /arm/rpi0/ram.ld 
   
- /arm/rpi0/start-ram.S 
   
The following files are modified and are in the libraries:

- /src/i-raspberry_pi.ads
   
- /src/i-cache__armv7.adb
   
The following file has been removed from the libraries  
   a-elcha.ads

The following files are modified and form part of the build process:
   
- /install.py 
      
 - /build_rts.py
      
 - /arm/cortexar.py 
      
  The new aspects of the start-up file - start-ram.s are:
  
  1. the trap vectors and addresses are explicitly copied from 0x8000 to address 0
  
  2. CPS instructions are used to change processor mode in order to create separate stacks
  
  3. BSS is zeroised using block transfers as far as possible, i.e. STMIA instructions
  
  4. a convenient *Last Chance Handler* is provided, which counts the number of occurrences and returns to the main program
  
  
  The new or modified files are in the same place in the directory hierarchy as in the standard source ( https://github.com/AdaCore/bb-runtimes)
  
  
