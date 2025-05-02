/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape"
	var/prefix = "sticky"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/cellulose = 5)
	splint_factor = 0.65
	merge_type = /obj/item/stack/sticky_tape
	var/conferred_embed = /datum/embedding/sticky_tape
	///The tape type you get when ripping off a piece of tape.
	var/obj/tape_gag = /obj/item/clothing/mask/muzzle/tape
	greyscale_config = /datum/greyscale_config/tape
	greyscale_colors = "#B2B2B2#BD6A62"

/datum/embedding/sticky_tape
	pain_mult = 0
	jostle_pain_mult = 0
	ignore_throwspeed_threshold = TRUE
	immune_traits = null

/obj/item/stack/sticky_tape/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)
		if(!do_after(user, 1 SECONDS))
			return
		var/new_tape_gag = new tape_gag(src)
		user.put_in_hands(new_tape_gag)
		use(1)
		to_chat(user, span_notice("You rip off a piece of tape."))
		playsound(user, 'sound/items/duct_tape/duct_tape_snap.ogg', 50, TRUE)
		return TRUE
	return ..()

/obj/item/stack/sticky_tape/examine(mob/user)
	. = ..()
	. += "[span_notice("You could rip a piece off by using an empty hand.")]"

/obj/item/stack/sticky_tape/interact_with_atom(obj/item/target, mob/living/user, list/modifiers)
	if(!isitem(target))
		return NONE

	if(target.get_embed()?.type == conferred_embed)
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] begins wrapping [target] with [src]."), span_notice("You begin wrapping [target] with [src]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if(!do_after(user, 3 SECONDS, target=target))
		return ITEM_INTERACT_BLOCKING

	playsound(user, 'sound/items/duct_tape/duct_tape_snap.ogg', 50, TRUE)
	use(1)
	if(istype(target, /obj/item/clothing/gloves/fingerless))
		var/obj/item/clothing/gloves/tackler/offbrand/O = new /obj/item/clothing/gloves/tackler/offbrand
		to_chat(user, span_notice("You turn [target] into [O] with [src]."))
		QDEL_NULL(target)
		user.put_in_hands(O)
		return ITEM_INTERACT_SUCCESS

	if(target.get_embed()?.type == conferred_embed)
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return ITEM_INTERACT_BLOCKING

	target.set_embed(conferred_embed)
	to_chat(user, span_notice("You finish wrapping [target] with [src]."))
	target.name = "[prefix] [target.name]"

	if(isgrenade(target))
		var/obj/item/grenade/sticky_bomb = target
		sticky_bomb.sticky = TRUE

	return ITEM_INTERACT_SUCCESS

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischievous substance in the galaxy. Use with extreme lack of caution."
	prefix = "super sticky"
	conferred_embed = /datum/embedding/sticky_tape/super
	splint_factor = 0.4
	merge_type = /obj/item/stack/sticky_tape/super
	greyscale_colors = "#4D4D4D#75433F"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/super

/datum/embedding/sticky_tape/super
	embed_chance = 100
	fall_chance = 0.1

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_spikes"
	prefix = "pointy"
	conferred_embed = /datum/embedding/pointy_tape
	merge_type = /obj/item/stack/sticky_tape/pointy
	greyscale_config = /datum/greyscale_config/tape/spikes
	greyscale_colors = "#E64539#808080#AD2F45"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/pointy

/datum/embedding/pointy_tape
	ignore_throwspeed_threshold = TRUE

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	prefix = "super pointy"
	conferred_embed = /datum/embedding/pointy_tape/super
	merge_type = /obj/item/stack/sticky_tape/pointy/super
	greyscale_colors = "#8C0A00#4F4F4F#300008"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/pointy/super

/datum/embedding/pointy_tape/super
	embed_chance = 100

/obj/item/stack/sticky_tape/surgical
	name = "surgical tape"
	singular_name = "surgical tape"
	desc = "Made for patching broken bones back together alongside bone gel, not for playing pranks."
	prefix = "surgical"
	conferred_embed = /datum/embedding/sticky_tape/surgical
	splint_factor = 0.5
	custom_price = PAYCHECK_CREW
	merge_type = /obj/item/stack/sticky_tape/surgical
	greyscale_colors = "#70BAE7#BD6A62"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/surgical

/datum/embedding/sticky_tape/surgical
	embed_chance = 30

/obj/item/stack/sticky_tape/surgical/get_surgery_tool_overlay(tray_extended)
	return "tape" + (tray_extended ? "" : "_out")

/obj/item/stack/sticky_tape/duct
	name = "duct tape"
	singular_name = "duct tape"
	desc = "Tape designed for sealing punctures, holes and breakages in objects. Engineers swear by this stuff for practically all kinds of repairs. Maybe a little TOO much..."
	prefix = "duct taped"
	conferred_embed = /datum/embedding/sticky_tape/duct
	merge_type = /obj/item/stack/sticky_tape/duct
	var/object_repair_value = 30
	amount = 10
	max_amount = 10

/datum/embedding/sticky_tape/duct
	embed_chance = 0 //Wrapping something in duct tape is basically ensuring it never embeds.

/obj/item/stack/sticky_tape/duct/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!object_repair_value)
		return NONE

	if(issilicon(interacting_with))
		var/mob/living/silicon/robotic_pal = interacting_with
		var/robot_is_damaged = robotic_pal.getBruteLoss()

		if(!robot_is_damaged)
			user.balloon_alert(user, "[robotic_pal] is not damaged!")
			return ITEM_INTERACT_BLOCKING

		user.visible_message(span_notice("[user] begins repairing [robotic_pal] with [src]."), span_notice("You begin repairing [robotic_pal] with [src]."))
		playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

		if(!do_after(user, 3 SECONDS, target = robotic_pal))
			return ITEM_INTERACT_BLOCKING

		robotic_pal.adjustBruteLoss(-object_repair_value)
		use(1)
		to_chat(user, span_notice("You finish repairing [interacting_with] with [src]."))
		return ITEM_INTERACT_SUCCESS

	if(!isobj(interacting_with) || iseffect(interacting_with))
		return NONE

	var/obj/item/object_to_repair = interacting_with
	var/object_is_damaged = object_to_repair.get_integrity() < object_to_repair.max_integrity

	if(!object_is_damaged)
		user.balloon_alert(user, "[object_to_repair] is not damaged!")
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] begins repairing [object_to_repair] with [src]."), span_notice("You begin repairing [object_to_repair] with [src]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if(!do_after(user, 3 SECONDS, target = object_to_repair))
		return ITEM_INTERACT_BLOCKING

	if(isclothing(object_to_repair))
		var/obj/item/clothing/clothing_to_repair = object_to_repair
		clothing_to_repair.repair()
	else
		object_to_repair.repair_damage(object_repair_value)

	use(1)
	to_chat(user, span_notice("You finish repairing [interacting_with] with [src]."))
	return ITEM_INTERACT_SUCCESS
