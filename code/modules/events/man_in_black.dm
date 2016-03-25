/datum/round_event_control/man_in_black
	name = "NCO Agent" //Nanotrasen Covert Operations
	typepath = /datum/round_event/man_in_black
	max_occurrences = 1
	earliest_start = 6000 //10 minutes

/datum/round_event_control/man_in_black/New()
	..()
	if(check_holiday(APRIL_FOOLS))
		weight = INFINITY //So it's guaranteed to happen
		message_admins("April Fools' Day detected, NCO Agent event enabled")
	else
		weight = 0

/datum/round_event/man_in_black

/datum/round_event/man_in_black/start()
	processing = 0
	message_admins("NCO agent being spawned as part of a random event")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered to be sent in as a covert Nanotrasen agent?", "nco", null, ROLE_TRAITOR)
	if(candidates.len <= 1)
		var/mob/dead/observer/candidate = pick(candidates)
		var/mob/living/carbon/human/man_in_black = makeBody(candidate)
		var/obj/effect/landmark/spawn_point = pick(latejoin)
		man_in_black.loc = get_turf(spawn_point)
		man_in_black.equip_nco_agent()
		return 1
	else
		message_admins("NCO agent failed to spawn; no candidates accepted the query")
		return 0

/mob/living/carbon/human/proc/equip_nco_agent()
	var/list/possible_names = list("KAPITAN", "ENORMOZ", "BABYLON", "CARTHAGE", "TYRE", "LIBERAL", "ANTENNA", "ANTON", "FROST", "PERSEUS", "GOOSE", "REST", "NEIGHBOR") //Code names of Soviet spies from the Cold War era
	real_name = pick(possible_names)
	name = real_name
	equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cent, slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses, slot_glasses)
	var/suit_type = /obj/item/clothing/under/suit_jacket/really_black/armored
	if(gender == FEMALE)
		suit_type = /obj/item/clothing/under/suit_jacket/female/armored
	equip_to_slot_or_del(new suit_type(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/nagant, slot_belt)
	equip_to_slot_or_del(new /obj/item/weapon/suppressor, slot_l_store)
	equip_to_slot_or_del(new /obj/item/ammo_box/a357, slot_r_store)
	var/obj/item/weapon/storage/backpack/satchel/satchel = new
	satchel.contents = list()
	new /obj/item/bodybag(satchel)
	new /obj/item/weapon/soap/nanotrasen(satchel)
	new /obj/item/weapon/card/emag(satchel)
	new /obj/item/weapon/c4/nco(satchel)
	new /obj/item/device/nco_extractor(satchel)
	equip_to_slot_or_del(satchel, slot_back)
	var/obj/item/weapon/card/id/centcom/id = new
	id.registered_name = real_name
	id.assignment = "NCO Agent"
	id.access = get_all_accesses() //All-access
	equip_to_slot_or_del(id, slot_wear_id)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup, slot_shoes)
	if(mind)
		job = "NCO Agent"
		mind.assigned_role = "NCO Agent"
		mind.special_role = "NCO Agent"
		ticker.mode.traitors += mind
		src << "<span class='userdanger'>You are a Nanotrasen Covert Operations agent</span> <b>sent to assassinate a target of high value to Central Command. Why you are doing this is not \
		important and is above your pay grade. You are only to carry out your orders. You are dressed to kill and have been sent to [station_name()] aboard the arrival shuttle with several \
		objects helpful in assassination, such as a silencer-compatible revolver (silencer and speed loader included), cryptographic sequencer, body bag, bar of soap, and all-access ID card. \
		You are to operate with as much stealth and efficiency as possible. Avoid collateral damage, but if anyone attempts to disrupt your mission, take what measures you must.\n\n\
		\
		Upon your target's death, use the modified block of C4 in your satchel to dispose of their corpse, if possible, then use the extraction device - also in your satchel - to return to \
		headquarters. This will take several seconds and you will be vulnerable during this time."
		var/list/possible_targets = list()
		for(var/mob/living/carbon/human/H in living_mob_list)
			if(H.z == z && H.mind)
				possible_targets.Add(H)
		if(!possible_targets.len)
			src << "<b><i>Something went wrong, and you were sent without a target. You should proceed to extract using the extractor in your satchel.</i></b>"
		else
			var/datum/objective/assassinate/A = new
			A.owner = mind
			var/mob/living/carbon/human/chosen_target = pick(possible_targets)
			A.target = chosen_target.mind
			A.explanation_text = "Assassinate [chosen_target.real_name], the [chosen_target.mind.assigned_role]."
			mind.objectives += A
			src << "<b>Objective #1:</b> [A.explanation_text]"

/obj/item/device/nco_extractor
	name = "mysterious tube"
	desc = null //Examines are different depending on who's examining it
	icon_state = "memorizerburnt"
	w_class = 2
	var/extracting = FALSE

/obj/item/device/nco_extractor/examine(mob/user)
	if(user.stat == DEAD || user.job == "NCO Agent")
		desc = "A specialized beacon that will send the all-clear signal to headquarters, permitting your extraction via bluespace teleportation."
	else
		desc = "A strange, cylindrical object about six inches tall and one inch in diameter."
	..()
	desc = null

/obj/item/device/nco_extractor/attack_self(mob/living/user)
	if(!user.job == "NCO Agent")
		user << "<span class='warning'>You don't what [src] does!</span>"
		return 0
	if(extracting)
		user << "<span class='warning'>There is already an extraction in progress!</span>"
		return 0
	extracting = TRUE
	user.visible_message("<span class='warning'>[user] twists the top of [src], and it begins to flash!</span>", \
						"<b><i>Your tracking implant crackles with an operator's voice:</b></i> \"Recall signal received. Standby for retrieval.\"")
	icon_state = "memorizer2"
	playsound(get_turf(user), 'sound/weapons/flash.ogg', 50, 0)
	if(!do_after(user, 100, target = user))
		user << "<span class='warning'>Your beacon's signal has been cut!</span>"
		icon_state = initial(icon_state)
		extracting = FALSE
		return 0
	user.visible_message("<span class='warning'>[user]'s form suddenly breaks apart and vanishes in a flash of light!</span>", \
						"<span class='notice'><b>You have been extracted from [station_name()]!</b></span>")
	playsound(get_turf(user), 'sound/weapons/marauder.ogg', 100, 0)
	for(var/mob/living/L in viewers(7, src))
		L.flash_eyes(1, 1)
	qdel(user) //Extracted!
	return 1
