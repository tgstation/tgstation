/client/proc/only_one()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/silicon/S in player_list) //All silicons get made into humans so they can be highlanders, too.
		if(S.isDead() || !S.client) continue
		if(is_special_character(S)) continue

		var/mob/living/carbon/human/new_human = new /mob/living/carbon/human(S.loc, delay_ready_dna=1)
		new_human.setGender(pick(MALE, FEMALE)) //The new human's gender will be random
		var/datum/preferences/A = new()	//Randomize appearance for the human
		A.randomize_appearance_for(new_human)
		new_human.generate_name()
		new_human.languages |= S.languages
		if(S.default_language) new_human.default_language = S.default_language
		if(S.mind)
			S.mind.transfer_to(new_human)
		else
			new_human.key = S.key
		qdel(S)

	for(var/mob/living/carbon/human/H in player_list)
		if(H.isDead() || !H.client) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = HIGHLANDER

		H.mutations.Add(M_HULK) //all highlanders are permahulks
		H.update_mutations()
		H.update_body()

		/* This never worked.
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = H.mind
		steal_objective.set_target("nuclear authentication disk")
		H.mind.objectives += steal_objective
		*/

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		to_chat(H, "<B>You are a highlander!</B>")
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			if(isplasmaman(H)) //Plasmamen don't lose their plasma gear since they need it to live.
				if(!(istype(I, /obj/item/clothing/suit/space/plasmaman) || istype(I, /obj/item/clothing/head/helmet/space/plasmaman) || istype(I, /obj/item/weapon/tank/plasma/plasmaman) || istype(I, /obj/item/clothing/mask/breath)))
					qdel(I)
			else if(isvox(H)) //Vox don't lose their N2 gear since they need it to live.
				if(!(istype(I, /obj/item/weapon/tank/nitrogen) || istype(I, /obj/item/clothing/mask/breath/vox)))
					qdel(I)
			else
				qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_ears)
		if(!isplasmaman(H)) //Plasmamen don't get a beret since they need their helmet to not burn to death.
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), slot_l_store)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)

	message_admins("<span class='notice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>", 1)
	log_admin("[key_name(usr)] used there can be only one.")