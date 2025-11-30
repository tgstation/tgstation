/// Save objects types
#define SAVE_OBJECTS (1 << 1)
/// Save objects variables from obj.get_save_vars() and obj.get_custom_save_vars() if disabled, saves dir, pixel_x, pixel_y as default
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

/** Encodes a value into a TGM valid string.
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

/// Generates a TGM string for an object's variables "{variables}"
#define TGM_VARS_BLOCK(variables) ("{\n\t[variables]\n\t}")

/// Generates a TGM string for a single variable assignment line "[variable] = [value]"
#define TGM_VAR_LINE(variable, value) ("[variable] = [value]")

/**
 * Adds a TGM object to the map string with optional variables.
 *
 * Arguments:
 * map_string: The current map string being assembled (will be modified in-place).
 * typepath: The typepath to save
 * variables_metadata: The variables that will be included on the typepath that must be formatted via generate_tgm_metadata()
 */
#define TGM_MAP_BLOCK(map_string, typepath, variables_metadata)\
	if(length(map_string)) {\
		map_string += ",\n";\
	};\
	map_string += "[typepath]";\
	if(length(variables_metadata)) {\
		map_string += "[variables_metadata]";\
	};

/**
 * Adds a variable/value pair to a provided list ONLY if the value is not the typepath's default value. This will also compile time check variable names on the typepath to make sure the variable is valid and exists.
 *
 * Arguments:
 * variables_to_add: An associated list of variables/values to be added during serilization
 * typepath: The type of the object
 * var: The name of the variable on the typepath
 * value: The value of the var that will be inserted during serilization
 */
#define TGM_ADD_TYPEPATH_VAR(variables_to_add, typepath, var, value)\
	if(!IS_TYPEPATH_DEFAULT_VAR(typepath, var, value)) {\
		variables_to_add[NAMEOF_TYPEPATH(typepath, var)] = value;\
	};

/// Checks if a given value matches the compile-time default value of a typepath variable
#define IS_TYPEPATH_DEFAULT_VAR(datum, variable, new_var) (##datum::variable == new_var)

// Metrics tracking macros for map serialization

/// Increment object counter (per turf)
#define INCREMENT_OBJ_COUNT(...) \
	do { \
		GLOB.TGM_objs++; \
		GLOB.TGM_total_objs++; \
	} while (FALSE); \

/// Increment mob counter (per turf)
#define INCREMENT_MOB_COUNT(...) \
	do { \
		GLOB.TGM_mobs++; \
		GLOB.TGM_total_mobs++; \
	} while (FALSE); \

/// Increment turf counter
#define INCREMENT_TURF_COUNT (GLOB.TGM_total_turfs++)

/// Increment area counter (should only be called once per unique area)
#define INCREMENT_AREA_COUNT (GLOB.TGM_total_areas++)

/// Check if object limit is exceeded
#define OBJECT_LIMIT_EXCEEDED (GLOB.TGM_objs >= CONFIG_GET(number/persistent_max_object_limit_per_turf))

/// Check if mob limit is exceeded
#define MOB_LIMIT_EXCEEDED (GLOB.TGM_mobs >= CONFIG_GET(number/persistent_max_mob_limit_per_turf))
