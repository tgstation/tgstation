/// Save objects types
#define SAVE_OBJECTS (1 << 1)
/// Save objects variables from obj.get_save_vars() and obj.get_custom_save_vars()
#define SAVE_OBJECTS_VARIABLES (1 << 2)
/// Save objects custom properties from obj.on_object_saved()
#define SAVE_OBJECTS_PROPERTIES (1 << 3)
/// Save mobs types (excludes mob/living/carbon)
#define SAVE_MOBS (1 << 4)
/// Save turfs types, if disabled, this will save turfs as /turf/template_noop
#define SAVE_TURFS (1 << 5)
/// Save turfs atmospheric properties (gases, temperature, etc.)
#define SAVE_TURFS_ATMOS (1 << 6)
/// Save space turfs, if disabled, this will replace objects, mobs, and areas that are on space turfs with /template_noop
#define SAVE_TURFS_SPACE (1 << 7)
/// Save areas types, if disabled, this will save areas as /area/template_noop
#define SAVE_AREAS (1 << 8)
/// Save areas types for default shuttles like arrivals, cargo, mining, whiteship, etc. (does not include custom shuttles), if disabled, uses /template_noop
#define SAVE_AREAS_DEFAULT_SHUTTLES (1 << 9)
/// Save areas types for custom shuttles that players make, if disabled, uses /template_noop
#define SAVE_AREAS_CUSTOM_SHUTTLES (1 << 10)

//Ignore turf if it contains
#define SAVE_SHUTTLEAREA_DONTCARE 0
#define SAVE_SHUTTLES_ONLY 1

#define DMM2TGM_MESSAGE "MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"

/// Prevent symbols from being because otherwise you can name something
/// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun
#define HASHTAG_NEWLINES_AND_TABS(text, replacements)\
	replacements = replacements || list("\n"="#","\t"="#");\
	for(var/char in replacements){\
		var/index = findtext(text, char);\
		while(index){\
			text = copytext(text, 1, index) + replacements[char] + copytext(text, index + length(char));\
			index = findtext(text, char, index + length(char));\
		};\
	};

/** Takes a constant, encodes it into a TGM valid string.
 * not handled:
 * - pops: /obj{name="foo"}
 * - new(), newlist(), icon(), matrix(), sound()
**/
#define TGM_ENCODE(value)\
	if(istext(value)) {\
		var/list/replacement_characters = list("{"="", "}"="", "\""="", ","="");\
		HASHTAG_NEWLINES_AND_TABS(value, replacement_characters);\
		value = "\"[value]\"";\
	} else if(isnum(value) || ispath(value)) {\
		value = "[value]";\
	} else if(islist(value)) {\
		value = to_list_string(value);\
	} else if(isnull(value)) {\
		value = "null";\
	} else if(isicon(value) || isfile(value)) {\
		value = "'[value]'";\
	} else {\
		value = "[value]";\
		var/list/replacement_characters = list("{"="", "}"="", "\""="", ","="");\
		HASHTAG_NEWLINES_AND_TABS(value, replacement_characters);\
		value = "\"[value]\"";\
	};

#define TGM_OBJ_INCREMENT (GLOB.TGM_objs += 1)
#define TGM_MOB_INCREMENT (GLOB.TGM_mobs += 1)
#define TGM_OBJ_CHECK (GLOB.TGM_objs > CONFIG_GET(number/persistent_max_object_limit_per_turf))
#define TGM_MOB_CHECK (GLOB.TGM_mobs > CONFIG_GET(number/persistent_max_mob_limit_per_turf))
