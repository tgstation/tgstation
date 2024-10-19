// dopplerboop helper procs

/proc/random_voice_type()
	return pick(GLOB.dopplerboop_voice_types)

GLOBAL_LIST_INIT(dopplerboop_voice_types, sort_list(list(
	"caring",
	"peppy",
	"snobby",
	"sweet",
	"grumpy",
	"jock",
	"lazy",
	"smug",
	"mute",
)))
