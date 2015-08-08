/client/proc/only_one()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = H.mind
		steal_objective.set_target(new /datum/objective_item/steal/nukedisc)
		H.mind.objectives += steal_objective

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		H << "<B>You are the traitor.</B>"
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), slot_l_store)

		var/obj/item/weapon/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used there can be only one.")


/client/proc/only_me()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "[H.real_name] Prime"

		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		H << "<B>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</B>"
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		var/obj/item/slot_item_ID = H.get_item_by_slot(slot_wear_id)
		qdel(slot_item_ID)
		var/obj/item/slot_item_hand = H.get_item_by_slot(slot_r_hand)
		H.unEquip(slot_item_hand)

		var /obj/item/weapon/multisword/multi = new(H)
		H.equip_to_slot_or_del(multi, slot_r_hand)

		var/obj/item/weapon/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Multiverse Summoner"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ME!</span>")
	log_admin("[key_name(usr)] used there can be only me.")
