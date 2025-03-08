/obj/structure/reagent_anvil
	name = "smithing anvil"
	desc = "Essentially a big block of metal that you can hammer other metals on top of, crucial for anyone working metal by hand."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "anvil_empty"

	anchored = TRUE
	density = TRUE

/obj/structure/reagent_anvil/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/falling_hazard, damage = 40, wound_bonus = 10, hardhat_safety = FALSE, crushes = TRUE)

/obj/structure/reagent_anvil/update_appearance()
	. = ..()
	cut_overlays()
	if(!length(contents))
		return

	var/image/overlayed_item = image(icon = contents[1].icon, icon_state = contents[1].icon_state)
	overlayed_item.transform = matrix(, 0, 0, 0, 0.8, 0)
	add_overlay(overlayed_item)

/obj/structure/reagent_anvil/examine(mob/user)
	. = ..()
	. += span_notice("You can place <b>hot metal objects</b> on this using some <b>tongs</b>.")
	. += span_notice("It can be (un)secured with <b>Right Click</b>")

	if(length(contents))
		. += span_notice("It has [contents[1]] sitting on it.")

/obj/structure/reagent_anvil/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src))
		return

	set_anchored(!anchored)
	balloon_alert_to_viewers(anchored ? "secured" : "unsecured")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/reagent_anvil/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert_to_viewers("deconstructing...")

	if(!do_after(user, 2 SECONDS, src))
		balloon_alert_to_viewers("stopped deconstructing")
		return TRUE

	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return TRUE

/obj/structure/reagent_anvil/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron/ten(get_turf(src))
	return ..()

/obj/structure/reagent_anvil/tong_act(mob/living/user, obj/item/tool)
	var/obj/item/forging/forge_item = tool
	var/obj/obj_anvil_search = locate() in contents

	if(forge_item.in_use)
		balloon_alert(user, "already in use")
		return ITEM_INTERACT_SUCCESS

	var/obj/obj_tong_search = locate() in forge_item.contents
	if(obj_anvil_search && !obj_tong_search)
		obj_anvil_search.forceMove(forge_item)
		update_appearance()
		forge_item.icon_state = "tong_full"
		return ITEM_INTERACT_SUCCESS

	if(!obj_anvil_search && obj_tong_search)
		obj_tong_search.forceMove(src)
		update_appearance()
		forge_item.icon_state = "tong_empty"
		return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_anvil/hammer_act(mob/living/user, obj/item/tool)
	//do we have an incomplete item to hammer out? if so, here is our block of code
	var/obj/item/forging/incomplete/locate_incomplete = locate() in contents
	if(locate_incomplete)
		if (locate_incomplete.in_use)
			balloon_alert(user, "being worked on")
			return ITEM_INTERACT_SUCCESS
		locate_incomplete.in_use = TRUE
		do_hammer(user, tool, locate_incomplete)
		locate_incomplete.in_use = FALSE
		return ITEM_INTERACT_SUCCESS

	//okay, so we didn't find an incomplete item to hammer, do we have a hammerable item?
	var/obj/locate_obj = locate() in contents
	if(locate_obj && (locate_obj.obj_flags_doppler & ANVIL_REPAIR))
		if(locate_obj.get_integrity() >= locate_obj.max_integrity)
			balloon_alert(user, "already repaired")
			return ITEM_INTERACT_SUCCESS

		while(locate_obj.get_integrity() < locate_obj.max_integrity)
			if(!do_after(user, 1 SECONDS, src))
				balloon_alert(user, "stopped repairing")
				return ITEM_INTERACT_SUCCESS

			locate_obj.repair_damage(locate_obj.get_integrity() + 10)
			user.mind.adjust_experience(/datum/skill/smithing, 5) //repairing does give some experience
			playsound(src, 'modular_doppler/reagent_forging/sound/forge.ogg', 50, TRUE, ignore_walls = FALSE)

	return ITEM_INTERACT_SUCCESS

/obj/structure/reagent_anvil/proc/do_hammer(mob/living/user, obj/item/tool, obj/item/forging/incomplete/locate_incomplete)
	while(locate_incomplete.times_hit < locate_incomplete.average_hits)
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER) * locate_incomplete.average_wait

		if(!do_after(user, skill_modifier * tool.toolspeed, src))
			balloon_alert(user, "stopped hammering")
			locate_incomplete.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		if(locate_incomplete.loc != src)
			balloon_alert(user, "workpiece moved!")
			locate_incomplete.in_use = FALSE
			return ITEM_INTERACT_SUCCESS

		playsound(src, 'modular_doppler/reagent_forging/sound/forge.ogg', 50, TRUE, ignore_walls = FALSE)
		if(COOLDOWN_FINISHED(locate_incomplete, heating_remainder))
			balloon_alert(user, "metal too cool!")
			locate_incomplete.times_hit -= 3
			if(locate_incomplete.times_hit <= -locate_incomplete.average_hits)
				balloon_alert_to_viewers("workpiece breaks!")
				qdel(locate_incomplete)
				update_appearance()
			return ITEM_INTERACT_SUCCESS

		locate_incomplete.times_hit++
		user.mind.adjust_experience(/datum/skill/smithing, 1) //A good hit gives minimal experience

	balloon_alert(user, "workpiece sounds ready")

/obj/structure/reagent_anvil/hammer_act_secondary(mob/living/user, obj/item/tool)
	hammer_act(user, tool)

/obj/structure/reagent_anvil/onZImpact(turf/impacted_turf, levels, message = TRUE)
	var/mob/living/poor_target = locate(/mob/living) in impacted_turf
	if(!poor_target)
		return ..()

	poor_target.apply_damage(60 * levels, forced = TRUE)

	if(istype(poor_target, /mob/living/carbon)) //If this mob is a carbon, break a few of their limbs
		poor_target.take_bodypart_damage(40 * levels, wound_bonus = 5 * levels)
		poor_target.take_bodypart_damage(40 * levels, wound_bonus = 5 * levels)

	poor_target.AddElement(/datum/element/squish, 30 SECONDS)
	poor_target.visible_message(
		span_bolddanger("[src] falls on [poor_target], crushing them!"),
		span_userdanger("You are crushed by [src]!")
	)
	poor_target.Paralyze(5 SECONDS)
	poor_target.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
	playsound(poor_target, 'sound/effects/magic/clockwork/fellowship_armory.ogg', 50, TRUE)
	add_memory_in_range(poor_target, 7, /datum/memory/witness_vendor_crush, protagonist = poor_target, antognist = src)
	return TRUE
