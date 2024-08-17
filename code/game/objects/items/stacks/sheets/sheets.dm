/obj/item/stack/sheet
	name = "sheet"
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon_state = "sheet-metal_3"
	full_w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "smashes")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "smash")
	novariants = FALSE
	material_flags = MATERIAL_EFFECTS
	pickup_sound = 'sound/items/metal_pick_up.ogg'
	drop_sound = 'sound/items/metal_drop.ogg'
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	///If true, this is worth points in the gulag labour stacker
	var/gulag_valid = FALSE
	///Set to true if this is vended from a material storage
	var/manufactured = FALSE
	///What type of wall does this sheet spawn
	var/walltype
	/// whether this sheet can be sniffed by the material sniffer
	var/sniffable = FALSE
	/// this makes pickup and drop sounds vary
	sound_vary = TRUE

/obj/item/stack/sheet/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	if(sniffable && amount >= 10 && is_station_level(z))
		GLOB.sniffable_sheets |= src

/obj/item/stack/sheet/Destroy(force)
	if(sniffable)
		GLOB.sniffable_sheets -= src
	return ..()

/obj/item/stack/sheet/examine(mob/user)
	. = ..()
	if (manufactured && gulag_valid)
		. += "It has been embossed with a manufacturer's mark of guaranteed quality."

/obj/item/stack/sheet/add(_amount)
	. = ..()
	if(sniffable && amount >= 10 && is_station_level(z))
		GLOB.sniffable_sheets |= src

/obj/item/stack/sheet/merge(obj/item/stack/sheet/target_stack, limit)
	. = ..()
	manufactured = manufactured && target_stack.manufactured

/obj/item/stack/sheet/copy_evidences(obj/item/stack/sheet/from)
	. = ..()
	manufactured = from.manufactured

/// removing from sniffable handled by the sniffer itself when it checks for targets

/**
 * Facilitates sheets being smacked on the floor
 *
 * This is used for crafting by hitting the floor with items.
 * The inital use case is glass sheets breaking in to shards when the floor is hit.
 * Args:
 * * user: The user that did the action
 * * params: paramas passed in from attackby
 */
/obj/item/stack/sheet/proc/on_attack_floor(mob/user, params)
	var/list/shards = list()
	for(var/datum/material/mat in custom_materials)
		if(mat.shard_type)
			var/obj/item/new_shard = new mat.shard_type(user.loc)
			new_shard.add_fingerprint(user)
			shards += "\a [new_shard.name]"
	if(!shards.len)
		return FALSE
	user.do_attack_animation(src, ATTACK_EFFECT_BOOP)
	playsound(src, SFX_SHATTER, 70, TRUE)
	use(1)
	user.visible_message(span_notice("[user] shatters the sheet of [name] on the floor, leaving [english_list(shards)]."), \
		span_notice("You shatter the sheet of [name] on the floor, leaving [english_list(shards)]."))
	return TRUE
