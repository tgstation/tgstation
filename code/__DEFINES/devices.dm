// PDA defines //
#define CART_SECURITY (1<<0)
#define CART_ENGINE (1<<1)
#define CART_ATMOS (1<<2)
#define CART_MEDICAL (1<<3)
#define CART_MANIFEST (1<<4)
#define CART_CLOWN (1<<5)
#define CART_MIME (1<<6)
#define CART_JANITOR (1<<7)
#define CART_REAGENT_SCANNER (1<<8)
#define CART_NEWSCASTER (1<<9)
#define CART_REMOTE_DOOR (1<<10)
#define CART_STATUS_DISPLAY (1<<11)
#define CART_QUARTERMASTER (1<<12)
#define CART_HYDROPONICS (1<<13)
#define CART_DRONEPHONE (1<<14)
#define CART_DRONEACCESS (1<<15)

/// PDA ui menu defines
#define PDA_UI_HUB 0
#define PDA_UI_NOTEKEEPER 1
#define PDA_UI_MESSENGER 2
#define PDA_UI_READ_MESSAGES 21
#define PDA_UI_ATMOS_SCAN 3
#define PDA_UI_SKILL_TRACKER 4
/// mode is divided by on return
#define PDA_UI_RETURN_DIVIDER 10
/// if the new mode from return is between these, go straight to the hub.
#define PDA_UI_REDIRECT_HUB_MIN 4
#define PDA_UI_REDIRECT_HUB_MAX 9
#define PDA_UI_CREW_MANIFEST 41
#define PDA_UI_STATUS_DISPLAY 42
#define PDA_UI_POWER_MONITOR 43
#define PDA_UI_POWER_MONITOR_SELECTED 433
#define PDA_UI_MED_RECORDS 44
#define PDA_UI_MED_RECORD_SELECTED 441
#define PDA_UI_SEC_RECORDS 45
#define PDA_UI_SEC_RECORD_SELECTED 451
#define PDA_UI_SUPPLY_RECORDS 46
#define PDA_UI_SILO_LOGS 47
#define PDA_UI_BOTS_ACCESS 48
#define PDA_UI_JANNIE_LOCATOR 49
#define PDA_UI_EMOJI_GUIDE 50
#define PDA_UI_SIGNALER 51
#define PDA_UI_NEWSCASTER 52
#define PDA_UI_NEWSCASTER_ERROR 53


// Used by PDA and cartridge code to reduce repetitiveness of spritesheets
#define PDAIMG(what) {"<span class="pda16x16 [#what]"></span>"}

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
