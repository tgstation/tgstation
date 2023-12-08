/**
 * Program bitflags
 * Used by programs to tell what type of ModPC it can run on.
 * Everything a program can run on needs valid icons for each individual one.
 */

#define PROGRAM_ALL ALL
#define PROGRAM_CONSOLE (1<<0)
#define PROGRAM_LAPTOP (1<<1)
#define PROGRAM_PDA (1<<2)

//Program categories
#define PROGRAM_CATEGORY_DEVICE "Device Tools"
#define PROGRAM_CATEGORY_EQUIPMENT "Equipment"
#define PROGRAM_CATEGORY_GAMES "Games"
#define PROGRAM_CATEGORY_SECURITY "Security & Records"
#define PROGRAM_CATEGORY_ENGINEERING "Engineering"
#define PROGRAM_CATEGORY_SUPPLY "Supply"
#define PROGRAM_CATEGORY_SCIENCE "Science"

///This app grants a minor protection against being PDA bombed if installed.
///(can sometimes prevent it from being sent, while wasting a PDA bomb from the sender).
#define DETOMATIX_RESIST_MINOR 1
///This app grants a larger protection against being PDA bombed if installed.
///(can sometimes prevent it from being sent, while wasting a PDA bomb from the sender).
#define DETOMATIX_RESIST_MAJOR 2
///This app gives a diminished protection against being PDA bombed if installed.
#define DETOMATIX_RESIST_MALUS -4

/**
 * NTNet transfer speeds, used when downloading/uploading a file/program.
 * The define is how fast it will download an app every program's process_tick.
 */
///Used for wireless devices with low signal.
#define NTNETSPEED_LOWSIGNAL 0.5
///Used for wireless devices with high signal.
#define NTNETSPEED_HIGHSIGNAL 1
///Used for laptops with a high signal, or computers, which is connected regardless of z level.
#define NTNETSPEED_ETHERNET 2

/**
 * NTNet connection signals
 * Used to calculate the defines above from NTNet Downloader, this is how
 * good a ModPC's signal is.
 */
///When you're away from the station/mining base and not on a console, you can't access the internet.
#define NTNET_NO_SIGNAL 0
///Low signal, so away from the station, but still connected
#define NTNET_LOW_SIGNAL 1
///On station with good signal.
#define NTNET_GOOD_SIGNAL 2
///Using a Computer or Laptop with good signal, ethernet-connected.
#define NTNET_ETHERNET_SIGNAL 3

/// The default ringtone of the Messenger app.
#define MESSENGER_RINGTONE_DEFAULT "beep"

/// The maximum length of the ringtone of the Messenger app.
#define MESSENGER_RINGTONE_MAX_LENGTH 20

/**
 * PDA Themes
 * For these to work, the defines must be defined in tgui/styles/themes/[define].scss
 */

///Default NtOS PDA theme
#define PDA_THEME_NTOS "ntos"
#define PDA_THEME_DARK_MODE "ntos_darkmode"
#define PDA_THEME_RETRO "ntOS95"
#define PDA_THEME_SYNTH "ntos_synth"
#define PDA_THEME_TERMINAL "ntos_terminal"

///Emagged/Syndicate NtOS (SyndiOS) PDA theme
#define PDA_THEME_SYNDICATE "syndicate"

//Maintenance-loot themes
#define PDA_THEME_CAT "ntos_cat"
#define PDA_THEME_LIGHT_MODE "ntos_lightmode"
#define PDA_THEME_SPOOKY "ntos_spooky"

//Defines for the names of all the themes
#define PDA_THEME_NTOS_NAME "NtOS"
#define PDA_THEME_DARK_MODE_NAME "NtOS Dark Mode"
#define PDA_THEME_RETRO_NAME "Retro"
#define PDA_THEME_SYNTH_NAME "Synth"
#define PDA_THEME_TERMINAL_NAME "Terminal"
#define SYNDICATE_THEME_NAME "Syndicate"
#define CAT_THEME_NAME "Cat"
#define LIGHT_THEME_NAME "NtOS Light Mode"
#define ELDRITCH_THEME_NAME "Eldritch"

///List of PDA themes that are accessible to everyone by default.
GLOBAL_LIST_INIT(default_pda_themes, list(
	PDA_THEME_NTOS_NAME = PDA_THEME_NTOS,
	PDA_THEME_DARK_MODE_NAME = PDA_THEME_DARK_MODE,
	PDA_THEME_RETRO_NAME = PDA_THEME_RETRO,
	PDA_THEME_SYNTH_NAME = PDA_THEME_SYNTH,
	PDA_THEME_TERMINAL_NAME = PDA_THEME_TERMINAL,
))

///List of PDA themes that are accessible to everyone by default.
GLOBAL_LIST_INIT(pda_name_to_theme, list(
	PDA_THEME_NTOS_NAME = PDA_THEME_NTOS,
	PDA_THEME_DARK_MODE_NAME = PDA_THEME_DARK_MODE,
	PDA_THEME_RETRO_NAME = PDA_THEME_RETRO,
	PDA_THEME_SYNTH_NAME = PDA_THEME_SYNTH,
	PDA_THEME_TERMINAL_NAME = PDA_THEME_TERMINAL,
	SYNDICATE_THEME_NAME = PDA_THEME_SYNDICATE,
	CAT_THEME_NAME = PDA_THEME_CAT,
	LIGHT_THEME_NAME = PDA_THEME_LIGHT_MODE,
	ELDRITCH_THEME_NAME = PDA_THEME_SPOOKY,
))
