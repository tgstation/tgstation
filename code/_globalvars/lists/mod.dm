/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
/// Global list of all ids associated to a /datum/mod_link instance
GLOBAL_LIST_EMPTY(mod_link_ids)

/**
 *	A global associated list with entries named after modsuit themes.
 *	When an entry exists here, and there isn't a drawn modsuit sprite to use,
 *	handle_cerulean_modsuit(...) will generate a modsuit sprite with the supplied parts.
 *	Check CERULEAN_MODSUIT_GEN_FILE for existing parts to pick from.
 *	Sprites at the top of the list load first
 */
GLOBAL_ALIST_INIT(mer_mod_theme, list(
	/datum/mod_theme/debug = list(
		"security" = list("#00289f", "#343442", "#0050d5"),
	),
	/datum/mod_theme/cosmohonk = list(
		"medical" = list("#7e1c29", "#adad95", "#d9d7c7"),
	),
	/datum/mod_theme/corporate = list(
		"security" = list("#29722e", "#ffce5b", "#488c40"),
	),
	/datum/mod_theme/chrono = list(
		"medical" = list("#39393f", "#eeeeee", "#eeeeee"),
	),
	/datum/mod_theme/enchanted = list(
		"security" = list("#8637af", "#490869", "#994dc5"),
	),
	/datum/mod_theme/elite = list(
		"security" = list("#1d1d1f", "#34333a", "#545350"),
	),
	/datum/mod_theme/infiltrator = list(
		"medical" = list("#1e1e32", "#820a16", "#b22c20"),
	),
	/datum/mod_theme/interdyne = list(
		"medical" = list("#222222", "#c2c1c9", "#b22c20"),
	),
	/datum/mod_theme/loader = list(/* sorry nothing */),
	/datum/mod_theme/mining = list(
		"security" = list("#363740", "#31313d", "#4f4f52"),
	),
	/datum/mod_theme/ninja = list(
		"security" = list("#212022", "#2f2e31", "#2f2e31"),
	),
	/datum/mod_theme/prototype = list(
		"security" = list("#72452a", "#55322e", "#9f6f3d"),
	),
	/datum/mod_theme/research = list(
		"medical" = list("#1e1e32", "#343442", "#7a0bb7"),
	),
	/datum/mod_theme = list(
		"security" = list("#292929", "#414146", "#585858"),
	),
))

/**
 *	Like above but slightly less alisty. The color given is for the flippers
 *	Ceruleans with a female physique have, when the modsuit is sealed
 */
GLOBAL_ALIST_INIT(mod_theme_to_flipper_color, list(
	/datum/mod_theme/debug = "#001775",
	/datum/mod_theme/corporate = "#2b2c38",
	/datum/mod_theme/chrono = "#7ed2ff",
	/datum/mod_theme/enchanted = "#47bfff",
	/datum/mod_theme/elite = "#34333a",
	/datum/mod_theme/infiltrator = "#1e1e32",
	/datum/mod_theme/interdyne = "#3d667a",
	/datum/mod_theme/loader = NO_FLIPPERS,
	/datum/mod_theme/mining = "#40404e",
	/datum/mod_theme/ninja = "#21a52e",
	/datum/mod_theme/prototype = "#573431",
	/datum/mod_theme/research = "#7a0bb7",
	/datum/mod_theme = "#414146",
))
