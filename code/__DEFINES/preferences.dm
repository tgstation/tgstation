
//Preference toggles
#define SOUND_ADMINHELP	1
#define SOUND_MIDI		2
#define SOUND_AMBIENCE	4
#define SOUND_LOBBY		8
#define MEMBER_PUBLIC	16
#define INTENT_STYLE	32
#define MIDROUND_ANTAG	64
#define SOUND_INSTRUMENTS	128
#define SOUND_SHIP_AMBIENCE 256
#define SOUND_PRAYERS 512
#define ANNOUNCE_LOGIN 1024
#define SOUND_ANNOUNCEMENTS 2048
#define DISABLE_DEATHRATTLE 4096
#define DISABLE_ARRIVALRATTLE 8192

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|MEMBER_PUBLIC|INTENT_STYLE|MIDROUND_ANTAG|SOUND_INSTRUMENTS|SOUND_SHIP_AMBIENCE|SOUND_PRAYERS|SOUND_ANNOUNCEMENTS)

//Chat toggles
#define CHAT_OOC		1
#define CHAT_DEAD		2
#define CHAT_GHOSTEARS	4
#define CHAT_GHOSTSIGHT	8
#define CHAT_PRAYER		16
#define CHAT_RADIO		32
#define CHAT_PULLR		64
#define CHAT_GHOSTWHISPER 128
#define CHAT_GHOSTPDA	256
#define CHAT_GHOSTRADIO 512

#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO)

#define PARALLAX_INSANE -1 //for show offs
#define PARALLAX_HIGH    0 //default.
#define PARALLAX_MED     1
#define PARALLAX_LOW     2
#define PARALLAX_DISABLE 3 //this option must be the highest number

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

#define SEC_DEPT_NONE "None"
#define SEC_DEPT_RANDOM "Random"
#define SEC_DEPT_ENGINEERING "Engineering"
#define SEC_DEPT_MEDICAL "Medical"
#define SEC_DEPT_SCIENCE "Science"
#define SEC_DEPT_SUPPLY "Supply"

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_CREW			"Crew"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"
#define EXP_TYPE_ANTAG			"Antag"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT 1