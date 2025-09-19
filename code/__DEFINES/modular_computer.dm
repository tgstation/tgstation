/**
 * can_run_on_flags bitflags
 * Used by programs to tell what type of ModPC it can run on.
 * Everything a program can run on needs valid icons for each individual one.
 */
///Runs on everything.
#define PROGRAM_ALL ALL
///Can run on Modular PC Consoles
#define PROGRAM_CONSOLE (1<<0)
///Can run on Laptops.
#define PROGRAM_LAPTOP (1<<1)
///Can run on PDAs.
#define PROGRAM_PDA (1<<2)

/**
 * program_flags
 * Used by programs to tell the ModPC any special functions it has.
 */
///If the program requires NTNet to be online for it to work.
#define PROGRAM_REQUIRES_NTNET (1<<0)
///The program can be downloaded from the default NTNet downloader store.
#define PROGRAM_ON_NTNET_STORE (1<<1)
///The program can only be downloaded from the Syndinet store, usually nukie/emagged pda.
#define PROGRAM_ON_SYNDINET_STORE (1<<2)
///The program is unique and will delete itself upon being transferred to ensure only one copy exists.
#define PROGRAM_UNIQUE_COPY (1<<3)
///The program is a header and will show up at the top of the ModPC's UI.
#define PROGRAM_HEADER (1<<4)
///The program will run despite the ModPC not having any power in it.
#define PROGRAM_RUNS_WITHOUT_POWER (1<<5)
///The circuit ports of this program can be triggered even if the program is not open
#define PROGRAM_CIRCUITS_RUN_WHEN_CLOSED (1<<6)

//Program categories
#define PROGRAM_CATEGORY_DEVICE "Device Tools"
#define PROGRAM_CATEGORY_EQUIPMENT "Equipment"
#define PROGRAM_CATEGORY_GAMES "Games"
#define PROGRAM_CATEGORY_SECURITY "Security & Records"
#define PROGRAM_CATEGORY_ENGINEERING "Engineering"
#define PROGRAM_CATEGORY_SUPPLY "Supply"
#define PROGRAM_CATEGORY_SCIENCE "Science"

///The default amount a program should take in cell use.
#define PROGRAM_BASIC_CELL_USE 2 WATTS

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
#define PDA_THEME_HACKERMAN "hackerman"
#define PDA_THEME_ROULETTE "cardtable"
#define PDA_THEME_ABDUCTOR "abductor"
#define PDA_THEME_BIRD "neutral"


//Defines for the names of all the themes
#define PDA_THEME_NTOS_NAME "NtOS"
#define PDA_THEME_DARK_MODE_NAME "NtOS Dark Mode"
#define PDA_THEME_RETRO_NAME "Retro"
#define PDA_THEME_SYNTH_NAME "Synth"
#define PDA_THEME_TERMINAL_NAME "Terminal"
#define PDA_THEME_SYNDICATE_NAME "Syndicate"
#define PDA_THEME_CAT_NAME "Cat"
#define PDA_THEME_LIGHT_MODE_NAME "NtOS Light Mode"
#define PDA_THEME_SPOOKY_NAME "Eldritch"
#define PDA_THEME_HACKERMAN_NAME "Hackerman"
#define PDA_THEME_ROULETTE_NAME "Roulette Table"
#define PDA_THEME_ABDUCTOR_NAME "Alien"
#define PDA_THEME_BIRD_NAME "Bird"

///List of PDA themes that are accessible to everyone by default.
GLOBAL_LIST_INIT(default_pda_themes, list(
	PDA_THEME_NTOS_NAME = PDA_THEME_NTOS,
	PDA_THEME_DARK_MODE_NAME = PDA_THEME_DARK_MODE,
	PDA_THEME_RETRO_NAME = PDA_THEME_RETRO,
	PDA_THEME_SYNTH_NAME = PDA_THEME_SYNTH,
	PDA_THEME_TERMINAL_NAME = PDA_THEME_TERMINAL,
	PDA_THEME_BIRD_NAME = PDA_THEME_BIRD,
))

///List of PDA themes that are accessible to everyone by default.
GLOBAL_LIST_INIT(pda_name_to_theme, list(
	PDA_THEME_NTOS_NAME = PDA_THEME_NTOS,
	PDA_THEME_DARK_MODE_NAME = PDA_THEME_DARK_MODE,
	PDA_THEME_RETRO_NAME = PDA_THEME_RETRO,
	PDA_THEME_SYNTH_NAME = PDA_THEME_SYNTH,
	PDA_THEME_TERMINAL_NAME = PDA_THEME_TERMINAL,
	PDA_THEME_SYNDICATE_NAME = PDA_THEME_SYNDICATE,
	PDA_THEME_CAT_NAME = PDA_THEME_CAT,
	PDA_THEME_LIGHT_MODE_NAME = PDA_THEME_LIGHT_MODE,
	PDA_THEME_SPOOKY_NAME = PDA_THEME_SPOOKY,
	PDA_THEME_HACKERMAN_NAME = PDA_THEME_HACKERMAN,
	PDA_THEME_ROULETTE_NAME = PDA_THEME_ROULETTE,
	PDA_THEME_ABDUCTOR_NAME = PDA_THEME_ABDUCTOR,
	PDA_THEME_BIRD_NAME = PDA_THEME_BIRD,
))
