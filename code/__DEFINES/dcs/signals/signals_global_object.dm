/// signals from globally accessible objects

///from SSJob when DivideOccupations is called
#define COMSIG_OCCUPATIONS_DIVIDED "occupations_divided"

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

///from SSsecurity_level when the security level changes : (new_level)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

///from SSshuttle when the supply shuttle starts spawning orders : ()
#define COMSIG_SUPPLY_SHUTTLE_BUY "supply_shuttle_buy"

///from GLOB.data_core when someone is injected into the manifest: (datum/datacore/source, mob/living/carbon/human/injected_human, list/new_records)
#define COMSIG_MANIFEST_INJECTED(ref) "manifest_injected_[ref]"
