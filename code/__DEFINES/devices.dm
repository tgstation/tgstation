// Role disk defines

#define DISK_POWER (1<<0)
#define DISK_ATMOS (1<<1)
#define DISK_MED (1<<2)
#define DISK_CHEM (1<<3)
#define DISK_MANIFEST (1<<4)
#define DISK_NEWS (1<<5)
#define DISK_SIGNAL	(1<<6)
#define DISK_STATUS (1<<7)
#define DISK_CARGO (1<<8)
#define DISK_ROBOS (1<<9)
#define DISK_JANI (1<<10)
#define DISK_SEC (1<<11)
#define DISK_BUDGET (1<<12)
#define DISK_SCI (1<<13)

// Used to stringify message targets before sending the signal datum.
#define STRINGIFY_PDA_TARGET(name, job) "[name] ([job])"

//N-spect scanner defines
#define INSPECTOR_PRINT_SOUND_MODE_NORMAL 1
#define INSPECTOR_PRINT_SOUND_MODE_CLASSIC 2
#define INSPECTOR_PRINT_SOUND_MODE_HONK 3
#define INSPECTOR_PRINT_SOUND_MODE_FAFAFOGGY 4
#define BANANIUM_CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST 4
#define CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST 4
#define INSPECTOR_POWER_USAGE_HONK 15
#define INSPECTOR_POWER_USAGE_NORMAL 5
#define INSPECTOR_TIME_MODE_SLOW 1
#define INSPECTOR_TIME_MODE_FAST 2
#define INSPECTOR_TIME_MODE_HONK 3
