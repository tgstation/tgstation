/obj/item/stack/sheet
	name = "sheet"
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon_state = "sheet-metal_3"
	abstract_type = /obj/item/stack/sheet
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
	table_type = /obj/structure/table/greyscale
	pickup_sound = 'sound/items/handling/materials/metal_pick_up.ogg'
	drop_sound = 'sound/items/handling/materials/metal_drop.ogg'
	sound_vary = TRUE
	/// this is used for girders in the creation of walls/false walls
	var/sheettype = null
	///If true, this is worth points in the gulag labour stacker
	var/gulag_valid = FALSE
	///Set to true if this is vended from a material storage
	var/manufactured = FALSE
	///What type of wall does this sheet spawn
	var/walltype
	/// whether this sheet can be sniffed by the material sniffer
	var/sniffable = FALSE

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
 * The initial use case is glass sheets breaking in to shards when the floor is hit.
 * Args:
 * * target: The floor that was hit
 * * user: The user that did the action
 * * modifiers: The modifiers passed in from attackby
 */
/obj/item/stack/sheet/proc/on_attack_floor(turf/open/floor/target, mob/user, list/modifiers)
	var/list/shards = list()
	for(var/datum/material/mat in custom_materials)
		if(mat.shard_type)
			shards += mat.shard_type
	if(!shards.len)
		return FALSE
	if(!use(1))
		to_chat(user, is_cyborg ? span_warning("There is not enough material in the synthesizer to produce a shard!") : span_warning("Somehow, there is not enough of [src] to shatter!"))
		if(!is_cyborg)
			stack_trace("A stack of sheet material was attempted to be shattered into shards while having less than 1 sheets remaining.")
		return FALSE
	user.do_attack_animation(target, ATTACK_EFFECT_BOOP)
	playsound(target, SFX_SHATTER, 70, TRUE)
	var/list/shards_created = list()
	for(var/shard_to_create in shards)
		var/obj/item/new_shard = new shard_to_create(target)
		new_shard.add_fingerprint(user)
		shards_created += "[new_shard.name]"
	user.visible_message(span_notice("[user] shatters the sheet of [name] on [target], leaving [english_list(shards_created)]."), \
		span_notice("You shatter the sheet of [name] on [target], leaving [english_list(shards_created)]."))
	return TRUE

