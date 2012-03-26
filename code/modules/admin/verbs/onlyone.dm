/client/proc/only_one()
	set category = "Fun"
	set name = "THERE CAN BE ONLY ONE"
	set desc = "Makes everyone into a traitor and has them fight for the nuke auth. disk."
	if(!ticker)
		alert("The game hasn't started yet!")
		return
	if(alert("BEGIN THE TOURNAMENT?",,"Yes","No")=="No")
		return

	for(var/mob/living/carbon/human/H in world)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		var/datum/objective/steal/nuke_disk/steal_objective = new
		steal_objective.owner = H.mind
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
			del(I)

		H.equip_if_possible(new /obj/item/clothing/under/kilt(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/head/beret(H), H.slot_head)
		H.equip_if_possible(new /obj/item/weapon/claymore(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/clothing/shoes/combat(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/pinpointer(H.loc), H.slot_l_store)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered = H.real_name
		H.equip_if_possible(W, H.slot_wear_id)

	message_admins("\blue [key_name_admin(usr)] used THERE CAN BE ONLY ONE!", 1)
	log_admin("[key_name(usr)] used there can be only one.")