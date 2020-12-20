I N C O M P L E T E
===================
____________________

# Ada-on-RPi0

A GNAT Ada runtime library for the Raspberry Pi Zero - RPi0

Here are bare board runtime libraries (bb-runtimes) for the RPi0 for the standard 3 profiles: Zero FootPrint, Ravenscar Small and Full.

The source of other runtimes is here: https://github.com/AdaCore/bb-runtimes

Only the Zero FootPrint library has been tested. It is in rpio-runtimes/zfp-rpi0.

These runtimes were created by cloning the rpi2 information, altering this and then building as described in the link above.  The following files are new and are in the libraries:

   /src/s-bbbosu__rpi0.adb 
   
   /src/s-textio__rpi0-mini.adb
   
   /src/s-bbpara__rpi0.ads
   
   /arm/rpi0/ram.ld 
   
   /arm/rpi0/start-ram.S 
   
The following files are modified and are in the libraries:

   /src/i-raspberry_pi.ads
   
   /src/i-cache__armv7.adb

   The following files are modified and form part of the build process:
   
      /install.py 
      
      /build_rts.py
      
      /arm/cortexar.py 
      
   
