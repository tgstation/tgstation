/obj/structure/large_mortar
	name = "large mortar"
	desc = "A large bowl perfect for grinding or juicing a large number of things at once."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/cooking_structures.dmi'
	icon_state = "big_mortar"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	pass_flags = PASSTABLE
	resistance_flags = FLAMMABLE
	custom_materials = list(
		/datum/material/wood = SHEET_MATERIAL_AMOUNT  * 10,
	)
	/// The maximum number of items this structure can store
	var/maximum_contained_items = 10
	var/in_use = FALSE

/obj/structure/large_mortar/Initialize(mapload)
	. = ..()
	create_reagents(200, OPENCONTAINER)

	AddElement(/datum/element/falling_hazard, damage = 20, wound_bonus = 5, hardhat_safety = TRUE, crushes = FALSE)

/obj/structure/large_mortar/examine(mob/user)
	. = ..()
	. += span_notice("It currently contains <b>[length(contents)]/[maximum_contained_items]</b> items.")
	. += span_notice("It can be (un)secured with <b>Right Click</b>")
	. += span_notice("You can empty all of the items out of it with <b>Alt Click</b>")

/obj/structure/large_mortar/Destroy()
	drop_everything_contained()
	return ..()

/obj/structure/large_mortar/click_alt(mob/user)
	if(in_use) // If the big mortar is currently in use by someone then we cannot use it
		balloon_alert(user, "big mortar busy")
		return CLICK_ACTION_BLOCKING

	if(!length(contents))
		balloon_alert(user, "nothing inside")
		return CLICK_ACTION_BLOCKING

	drop_everything_contained()
	balloon_alert(user, "removed all items")
	return CLICK_ACTION_SUCCESS

/// Drops all contents at the mortar
/obj/structure/large_mortar/proc/drop_everything_contained()
	if(!length(contents))
		return

	for(var/obj/target_item as anything in contents)
		target_item.forceMove(get_turf(src))

/obj/structure/large_mortar/attack_hand_secondary(mob/user, list/modifiers)
	if(in_use) // If the big mortar is currently in use by someone then we cannot use it
		balloon_alert(user, "big mortar busy")
		return

	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src))
		return

	set_anchored(!anchored)
	balloon_alert_to_viewers(anchored ? "secured" : "unsecured")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/large_mortar/attackby(obj/item/attacking_item, mob/living/carbon/human/user)
	if(in_use) // If the big mortar is currently in use by someone then we cannot use it
		balloon_alert(user, "big mortar busy")
		return

	if(attacking_item.is_refillable())
		return

/obj/structure/large_mortar/item_interaction(mob/living/user, obj/item/tool, list/modifiers, is_right_clicking)
	if(in_use) // If the big mortar is currently in use by someone then we cannot use it
		balloon_alert(user, "big mortar busy")
		return ITEM_INTERACT_BLOCKING

	. = ..()
	if(. || user.combat_mode || tool.is_refillable())
		return .
	if(istype(tool, /obj/item/storage/bag))
		if(length(contents) >= maximum_contained_items)
			balloon_alert(user, "already full!")
			return ITEM_INTERACT_BLOCKING

		if(!length(tool.contents))
			balloon_alert(user, "nothing to transfer!")
			return ITEM_INTERACT_BLOCKING

		for(var/obj/item/target_item in tool.contents)
			if(length(contents) >= maximum_contained_items)
				break

			if(target_item.juice_typepath || target_item.grind_results)
				target_item.forceMove(src)

		if (length(contents) >= maximum_contained_items)
			balloon_alert(user, "filled")
		else
			balloon_alert(user, "transferred")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/pestle))
		if(!anchored)
			balloon_alert(user, "not secured!")
			return ITEM_INTERACT_BLOCKING

		if(!length(contents) && reagents.total_volume == 0)
			balloon_alert(user, "mortar empty!")
			return ITEM_INTERACT_BLOCKING

		var/list/choose_options = list(
			"Grind" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind"),
			"Juice" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice"),
			"Mix" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_mix"),
		)
		var/picked_option = show_radial_menu(user, src, choose_options, radius = 38, require_near = TRUE)

		if(!in_range(src, user) || !user.is_holding(tool) || !picked_option)
			return ITEM_INTERACT_BLOCKING
		var/act_verb = LOWER_TEXT(picked_option)
		var/act_verb_ing
		if(act_verb == "juice")
			act_verb_ing = "juicing"
		else
			act_verb_ing = "[act_verb]ing"

		var/has_resource
		if(picked_option == "Mix")
			has_resource = reagents.total_volume > 0
		else
			has_resource = length(contents) > 0

		if(!has_resource)
			balloon_alert(user, "nothing to [act_verb]!")
			return ITEM_INTERACT_BLOCKING

		balloon_alert_to_viewers("[act_verb_ing]...")

		in_use = TRUE

		if(!do_after(user, 5 SECONDS, target = src))
			balloon_alert_to_viewers("stopped [act_verb_ing]")
			in_use = FALSE
			return ITEM_INTERACT_BLOCKING

		switch(picked_option)
			if("Juice")
				for(var/obj/item/target_item as anything in contents)
					if (reagents.total_volume >= reagents.maximum_volume)
						balloon_alert(user, "overflowing!")
						break
					if(target_item.juice_typepath)
						juice_target_item(target_item, user)
					else
						grind_target_item(target_item, user)

			if("Grind")
				for(var/obj/item/target_item as anything in contents)
					if (reagents.total_volume >= reagents.maximum_volume)
						balloon_alert(user, "overflowing!")
						break
					if(target_item.grind_results)
						grind_target_item(target_item, user)
					else
						juice_target_item(target_item, user)
			if("Mix")
				mix()

		in_use = FALSE
		return ITEM_INTERACT_SUCCESS

	if(!tool.grind_results && !tool.juice_typepath)
		balloon_alert(user, "can't grind this!")
		return ITEM_INTERACT_BLOCKING

	if(length(contents) >= maximum_contained_items)
		balloon_alert(user, "already full!")
		return ITEM_INTERACT_BLOCKING

	tool.forceMove(src)
	return ITEM_INTERACT_SUCCESS

///Juices the passed target item, and transfers any contained chems to the mortar as well
/obj/structure/large_mortar/proc/juice_target_item(obj/item/to_be_juiced, mob/living/carbon/human/user)
	if(to_be_juiced.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to juice [to_be_juiced], but it fades away!"))
		qdel(to_be_juiced)
		return

	if(!to_be_juiced.juice(src.reagents, user))
		to_chat(user, span_danger("You fail to juice [to_be_juiced]."))

	to_chat(user, span_notice("You juice [to_be_juiced] into a liquid."))
	QDEL_NULL(to_be_juiced)

///Grinds the passed target item, and transfers any contained chems to the mortar as well
/obj/structure/large_mortar/proc/grind_target_item(obj/item/to_be_ground, mob/living/carbon/human/user)
	if(to_be_ground.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to grind [to_be_ground], but it fades away!"))
		qdel(to_be_ground)
		return

	if(!to_be_ground.grind(src.reagents, user))
		if(isstack(to_be_ground))
			to_chat(user, span_notice("[src] attempts to grind as many pieces of [to_be_ground] as possible."))
		else
			to_chat(user, span_danger("You fail to grind [to_be_ground]."))

	to_chat(user, span_notice("You break [to_be_ground] into a fine powder."))
	QDEL_NULL(to_be_ground)

///Mixes contained reagents, creating butter/mayo/whipped cream
/obj/structure/large_mortar/proc/mix()
	//Recipe to make Butter
	var/butter_amt = FLOOR(reagents.get_reagent_amount(/datum/reagent/consumable/milk) / MILK_TO_BUTTER_COEFF, 1)
	var/purity = reagents.get_reagent_purity(/datum/reagent/consumable/milk)
	reagents.remove_reagent(/datum/reagent/consumable/milk, MILK_TO_BUTTER_COEFF * butter_amt)
	for(var/i in 1 to butter_amt)
		var/obj/item/food/butter/tasty_butter = new(drop_location())
		tasty_butter.reagents.set_all_reagents_purity(purity)

	//Recipe to make Mayonnaise
	if (reagents.has_reagent(/datum/reagent/consumable/eggyolk))
		reagents.convert_reagent(/datum/reagent/consumable/eggyolk, /datum/reagent/consumable/mayonnaise)

	//Recipe to make whipped cream
	if (reagents.has_reagent(/datum/reagent/consumable/cream))
		reagents.convert_reagent(/datum/reagent/consumable/cream, /datum/reagent/consumable/whipped_cream)
