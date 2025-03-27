/// File path used for the "enable tracy next round" functionality
#define TRACY_ENABLE_PATH	"data/enable_tracy"

/// The DLL path for byond-tracy.
#define TRACY_DLL_PATH		(world.system_type == MS_WINDOWS ? "prof.dll" : "./libprof.so")
