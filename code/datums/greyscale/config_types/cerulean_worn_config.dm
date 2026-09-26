/*
 * The greyscale config which contains all the modsuit parts we can choose to use to render.
 * this config expects 3 color sources
 */
/datum/greyscale_config/modular_mod_parts_cerulean
	name = "Cerulean Tail Modsuit Parts (Worn)"
	icon_file = CERULEAN_MODSUIT_GEN_FILE
	json_config = 'code/datums/greyscale/json_configs/cerulean_mod.json'

/*
 *	The greyscale config which contains only the fem flipper modsuit parts, and a pre-made design for
 *	modsuits which were not given an entry in var/list/cerulean_tail_palette.
 *	this config expects 1 color source
 */
/datum/greyscale_config/modular_mod_parts_cerulean/basic
	name = "Cerulean Tail Modsuit Parts (Basic)(Worn)"
	json_config = 'code/datums/greyscale/json_configs/cerulean_mod_basic.json'

/*
 *
 *
/datum/greyscale_config/uniform_worn_cerulean
	name = "Cerulean Tail Uniforms (Worn)"
	icon_file = CERULEAN_UNIFORM_FILE
	json_config = 'code/datums/greyscale/json_configs/cerulean_uniform.json'
 */

/*
 *
 */
/datum/greyscale_config/suit_worn_cerulean
	name = "Cerulean Tail Suits (Worn)"
	icon_file = CERULEAN_SUIT_FILE
	json_config = 'code/datums/greyscale/json_configs/cerulean_suit.json'
