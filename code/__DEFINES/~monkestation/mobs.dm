#define SPECIES_ARACHNIDS "arachnid"
#define SPECIES_DRACONIC_SKELETON "draconic_skeleton"

GLOBAL_REAL_VAR(list/voice_type2sound = list(
	"1" = list(
		"1" = sound('goon/sounds/speak_1.ogg'),
		"!" = sound('goon/sounds/speak_1_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_1_ask.ogg')
	),
	"2" = list(
		"2" = sound('goon/sounds/speak_2.ogg'),
		"!" = sound('goon/sounds/speak_2_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_2_ask.ogg')
	),
	"3" = list(
		"3" = sound('goon/sounds/speak_3.ogg'),
		"!" = sound('goon/sounds/speak_3_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_3_ask.ogg')
	),
	"4" = list(
		"4" = sound('goon/sounds/speak_4.ogg'),
		"!" = sound('goon/sounds/speak_4_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_4_ask.ogg')
	),
))

///Managed global that is a reference to the real global
GLOBAL_LIST_INIT(voice_type2sound_ref, voice_type2sound)
