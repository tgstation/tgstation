//NTNet stuff, for modular computers
// NTNet module-configuration values. Do not change these. If you need to add another use larger number (5..6..7 etc)
#define NTNET_SOFTWAREDOWNLOAD 1 // Downloads of software from NTNet
#define NTNET_COMMUNICATION 2 // Communication (messaging)

//NTNet transfer speeds, used when downloading/uploading a file/program.
#define NTNETSPEED_LOWSIGNAL 0.5 // GQ/s transfer speed when the device is wirelessly connected and on Low signal
#define NTNETSPEED_HIGHSIGNAL 1 // GQ/s transfer speed when the device is wirelessly connected and on High signal
#define NTNETSPEED_ETHERNET 2 // GQ/s transfer speed when the device is using wired connection

//Caps for NTNet logging. Less than 10 would make logging useless anyway, more than 500 may make the log browser too laggy. Defaults to 100 unless user changes it.
#define MAX_NTNET_LOGS 300
#define MIN_NTNET_LOGS 10

//Program bitflags
#define PROGRAM_ALL (~0)
#define PROGRAM_CONSOLE (1<<0)
#define PROGRAM_LAPTOP (1<<1)
#define PROGRAM_TABLET (1<<2)
//Program states
#define PROGRAM_STATE_KILLED 0
#define PROGRAM_STATE_BACKGROUND 1
#define PROGRAM_STATE_ACTIVE 2
//Program categories
#define PROGRAM_CATEGORY_CREW "Crew"
#define PROGRAM_CATEGORY_ENGI "Engineering"
#define PROGRAM_CATEGORY_SUPL "Supply"
#define PROGRAM_CATEGORY_SCI "Science"
#define PROGRAM_CATEGORY_MISC "Other"

#define DETOMATIX_RESIST_MINOR 1
#define DETOMATIX_RESIST_MAJOR 2

// NTNet connection signals
///When you're away from the station/mining base and not on a console, you can't access the internet
#define NTNET_NO_SIGNAL 0
///Low signal, so away from the station, but still connected
#define NTNET_LOW_SIGNAL 1
///On station, good signal
#define NTNET_GOOD_SIGNAL 2
///Using a Computer, ethernet-connected.
#define NTNET_ETHERNET_SIGNAL 3

/// The default ringtone of the Messenger app.
#define MESSENGER_RINGTONE_DEFAULT "beep"

/// The maximum length of the ringtone of the Messenger app.
#define MESSENGER_RINGTONE_MAX_LENGTH 20
