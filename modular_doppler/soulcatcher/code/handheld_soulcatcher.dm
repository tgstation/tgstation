#define RSD_ATTEMPT_COOLDOWN 2 MINUTES

/obj/item/handheld_soulcatcher
	name = "\improper Evoker-type RSD"
	desc = "The Evoker-Type Resonance Simulation Device is a sort of 'Soulcatcher' instrument that's been designated for handheld usage. These RSDs were designed with the Medical field in mind, a tool meant to offer comfort to the temporarily-departed while their bodies are being repaired, healed, or produced. The Evoker is essentially a very specialized handheld NIF, still using the same nanomachinery for the software and hardware. This careful instrument is able to host a virtual space for a great number of Engrams for an essentially indefinite amount of time in an unlimited variety of simulations, even able to transfer them to and from a NIF. However, it's best Medical practice to not lollygag."
	icon = 'modular_doppler/soulcatcher/icons/devices.dmi'
	icon_state = "soulcatcher-device"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	obj_flags = UNIQUE_RENAME
	/// What soulcatcher datum is associated with this item?
	var/datum/component/soulcatcher/linked_soulcatcher
	/// The cooldown for the RSD on scanning a body if the ghost refuses. This is here to prevent spamming.
	COOLDOWN_DECLARE(rsd_scan_cooldown)

/obj/item/handheld_soulcatcher/Initialize(mapload)
	. = ..()
	name += " #[rand(0, 999)]" // If it works for monkeys, it surely works for soulcatchers.
	SSpoints_of_interest.make_point_of_interest(src)

/obj/item/handheld_soulcatcher/attack_self(mob/user, modifiers)
	linked_soulcatcher.ui_interact(user)

/obj/item/handheld_soulcatcher/New(loc, ...)
	. = ..()
	linked_soulcatcher = AddComponent(/datum/component/soulcatcher)
	linked_soulcatcher.name = name

/obj/item/handheld_soulcatcher/Destroy(force)
	if(linked_soulcatcher)
		qdel(linked_soulcatcher)

	return ..()

/obj/item/handheld_soulcatcher/attack(mob/living/target_mob, mob/living/user, params)
	if(!target_mob)
		return ..()

	if(target_mob.GetComponent(/datum/component/previous_body))
		linked_soulcatcher.scan_body(target_mob, user)
		return TRUE

	if(!target_mob.mind)
		to_chat(user, span_warning("You are unable to remove a mind from an empty body."))
		return FALSE

	if(!COOLDOWN_FINISHED(src, rsd_scan_cooldown))
		var/time_left = round((COOLDOWN_TIMELEFT(src, rsd_scan_cooldown)) / (1 MINUTES), 0.01)
		to_chat(user, span_warning("You are currently unable to grab the soul of [target_mob], please wait [time_left] minutes before trying again."))
		return FALSE

	if(target_mob.stat == DEAD) //We can temporarily store souls of dead mobs.
		target_mob.ghostize(TRUE) //Incase they are staying in the body.
		var/mob/dead/observer/target_ghost = target_mob.get_ghost(TRUE, TRUE)
		if(!target_ghost)
			to_chat(user, span_warning("You are unable to get the soul of [target_mob]!"))
			return FALSE

		var/datum/soulcatcher_room/target_room = tgui_input_list(user, "Choose a room to send [target_mob]'s soul to.", name, linked_soulcatcher.soulcatcher_rooms, timeout = 30 SECONDS)
		if(!target_room)
			return FALSE

		SEND_SOUND(target_ghost, 'sound/announcer/notice/notice2.ogg')
		window_flash(target_ghost.client)

		if(tgui_alert(target_ghost, "[user] wants to transfer you to [target_room] inside of a soulcatcher, do you accept?", name, list("Yes", "No"), 30 SECONDS, autofocus = FALSE) != "Yes")
			to_chat(user, span_warning("[target_mob] doesn't seem to want to enter."))
			COOLDOWN_START(src, rsd_scan_cooldown, RSD_ATTEMPT_COOLDOWN)
			return FALSE

		if(!target_room.add_soul_from_ghost(target_ghost))
			return FALSE

		if(!target_mob.GetComponent(/datum/component/previous_body))
			return FALSE

		var/turf/source_turf = get_turf(user)
		log_admin("[key_name(user)] used [src] to put [key_name(target_mob)]'s mind into a soulcatcher at [AREACOORD(source_turf)]")
		linked_soulcatcher.scan_body(target_mob, user)
		return TRUE

	var/datum/soulcatcher_room/target_room = tgui_input_list(user, "Choose a room to send [target_mob]'s soul to.", name, linked_soulcatcher.soulcatcher_rooms, timeout = 30 SECONDS)
	if(!target_room)
		return FALSE

	SEND_SOUND(target_mob, 'sound/announcer/notice/notice2.ogg')
	window_flash(target_mob.client)

	if((tgui_alert(target_mob, "Do you wish to enter [target_room]? This will remove you from your body until you leave.", name, list("Yes", "No"), 30 SECONDS, FALSE) != "Yes") || (tgui_alert(target_mob, "Are you sure about this?", name, list("Yes", "No"), 30 SECONDS, FALSE) != "Yes"))
		COOLDOWN_START(src, rsd_scan_cooldown, RSD_ATTEMPT_COOLDOWN)
		to_chat(user, span_warning("[target_mob] doesn't seem to want to enter."))
		return FALSE

	if(!target_mob.mind)
		return FALSE

	target_room.add_soul(target_mob.mind, TRUE)
	//playsound(src, 'modular_nova/modules/modular_implants/sounds/default_good.ogg', 50, FALSE, ignore_walls = FALSE)
	visible_message(span_notice("[src] beeps: [target_mob]'s mind transfer is now complete."))

	if(!target_mob.GetComponent(/datum/component/previous_body))
		return FALSE

	linked_soulcatcher.scan_body(target_mob, user)

	var/turf/source_turf = get_turf(user)
	log_admin("[key_name(user)] used [src] to put [key_name(target_mob)]'s mind into a soulcatcher while they were still alive at [AREACOORD(source_turf)]")

	return TRUE

/obj/item/handheld_soulcatcher/attack_secondary(mob/living/carbon/human/target_mob, mob/living/user, params)
	if(!istype(target_mob))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/obj/item/organ/brain/target_brain = target_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!istype(target_brain))
		to_chat(user, span_warning("[target_mob] lacks a brain!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!HAS_TRAIT(target_brain, TRAIT_RSD_COMPATIBLE))
		to_chat(user, span_warning("[target_mob]'s brain isn't compatible."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(target_mob.mind || target_mob.ckey || target_mob.GetComponent(/datum/component/previous_body))
		to_chat(user, span_warning("[target_mob] is not able to receive a soul"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/list/soul_list = list()
	for(var/datum/soulcatcher_room/room as anything in linked_soulcatcher.soulcatcher_rooms)
		for(var/mob/living/soulcatcher_soul/soul as anything in room.current_souls)
			if(!soul.round_participant || soul.body_scan_needed)
				continue

			soul_list += soul

	if(!length(soul_list))
		to_chat(user, span_warning("There are no souls that can be transferred to [target_mob]."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/mob/living/soulcatcher_soul/chosen_soul = tgui_input_list(user, "Choose a soul to transfer into the body", name, soul_list)
	if(!chosen_soul)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(chosen_soul.previous_body)
		var/mob/living/old_body = chosen_soul.previous_body.resolve()
		if(!old_body)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		SEND_SIGNAL(old_body, COMSIG_SOULCATCHER_CHECK_SOUL, FALSE)

	chosen_soul.mind.transfer_to(target_mob, TRUE)
	//playsound(src, 'modular_nova/modules/modular_implants/sounds/default_good.ogg', 50, FALSE, ignore_walls = FALSE)
	visible_message(span_notice("[src] beeps: Body transfer complete."))
	log_admin("[src] was used by [user] to transfer [chosen_soul]'s soulcatcher soul to [target_mob].")

	qdel(chosen_soul)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

#undef RSD_ATTEMPT_COOLDOWN
