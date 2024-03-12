/// signals from globally accessible objects

///Whenever SetupOccupations() is called, called all occupations are set
#define COMSIG_OCCUPATIONS_SETUP "occupations_setup"

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

///from SSsecurity_level when the security level changes : (new_level)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

///from SSshuttle when the supply shuttle starts spawning orders : ()
#define COMSIG_SUPPLY_SHUTTLE_BUY "supply_shuttle_buy"
