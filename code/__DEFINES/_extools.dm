 /// Easy macro for always properly calling the correct version of extools
 #define EXTOOLS (world.system_type == MS_WINDOWS ? "byond-extools.dll" : "libbyond-extools.so")
