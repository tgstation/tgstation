
//Preference toggles
#define SOUND_ADMINHELP			(1<<0)
#define SOUND_MIDI				(1<<1)
#define SOUND_AMBIENCE			(1<<2)
#define SOUND_LOBBY				(1<<3)
#define MEMBER_PUBLIC			(1<<4)
#define INTENT_STYLE			(1<<5)
#define MIDROUND_ANTAG			(1<<6)
#define SOUND_INSTRUMENTS		(1<<7)
#define SOUND_SHIP_AMBIENCE		(1<<8)
#define SOUND_PRAYERS			(1<<9)
#define ANNOUNCE_LOGIN			(1<<10)
#define SOUND_ANNOUNCEMENTS		(1<<11)
#define DISABLE_DEATHRATTLE		(1<<12)
#define DISABLE_ARRIVALRATTLE	(1<<13)
#define COMBOHUD_LIGHTING		(1<<14)

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|MEMBER_PUBLIC|INTENT_STYLE|MIDROUND_ANTAG|SOUND_INSTRUMENTS|SOUND_SHIP_AMBIENCE|SOUND_PRAYERS|SOUND_ANNOUNCEMENTS)

//Chat toggles
#define CHAT_OOC			(1<<0)
#define CHAT_DEAD			(1<<1)
#define CHAT_GHOSTEARS		(1<<2)
#define CHAT_GHOSTSIGHT		(1<<3)
#define CHAT_PRAYER			(1<<4)
#define CHAT_RADIO			(1<<5)
#define CHAT_PULLR			(1<<6)
#define CHAT_GHOSTWHISPER	(1<<7)
#define CHAT_GHOSTPDA		(1<<8)
#define CHAT_GHOSTRADIO 	(1<<9)

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
#define EXP_TYPE_ADMIN			"Admin"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT 1

#define DEFAULT_CYBORG_NAME "Default Cyborg Name"