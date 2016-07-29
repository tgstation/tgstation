/obj/item/verbs/borer/attached_arm/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.borer_speak(message)

/obj/item/verbs/borer/attached_arm/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.evolve()

/obj/item/verbs/borer/attached_arm/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_arm/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.abandon_host()

//////////OFFENSE TREE/////////////////////
/obj/item/verbs/borer/attached_arm/bone_sword/verb/bone_sword()
	set category = "Alien"
	set name = "Bone Sword"
	set desc = "Expend chemicals constantly to form a large blade of bone for your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bone_sword()

/mob/living/simple_animal/borer/proc/bone_sword()
	set category = "Alien"
	set name = "Bone Sword"
	set desc = "Expend chemicals constantly to form a large blade of bone for your host."

	if(!check_can_do(0))
		return

	if(channeling && !channeling_bone_sword)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a blade of bone for your host.")
		channeling = 0
		channeling_bone_sword = 0
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/item/weapon/melee/bone_sword/S = new(get_turf(host), src)
		if(hostlimb == LIMB_RIGHT_ARM)
			if(host.get_held_item_by_index(GRASP_RIGHT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/melee/bone_sword))
					to_chat(src, "<span class='warning'>Your host already has a bone sword on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_RIGHT_HAND), force_drop = 1)
			host.put_in_r_hand(S)
		else
			if(host.get_held_item_by_index(GRASP_LEFT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_LEFT_HAND), /obj/item/weapon/melee/bone_sword))
					to_chat(src, "<span class='warning'>Your host already has a bone sword on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_LEFT_HAND), force_drop = 1)
			host.put_in_l_hand(S)
		to_chat(src, "You begin to focus your efforts on sustaining a blade of bone for your host.")
		channeling = 1
		channeling_bone_sword = 1
		host.visible_message("<span class='warning'>A blade of bone erupts from \the [host.name]'s [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>","<span class='warning'>A blade of bone erupts from your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>")
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_sword)
				time_spent_channeling++
				sleep(10)
			channeling = 0
			channeling_bone_sword = 0
			host.visible_message("<span class='notice'>\The [host]'s bone sword crumbles into nothing.</span>","<span class='notice'>Your bone sword crumbles into nothing.</span>")
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

/obj/item/verbs/borer/attached_arm/bone_hammer/verb/bone_hammer()
	set category = "Alien"
	set name = "Bone Hammer"
	set desc = "Expend chemicals constantly to form a large, heavy mass of bone on your host's arm."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bone_hammer()

/mob/living/simple_animal/borer/proc/bone_hammer()
	set category = "Alien"
	set name = "Bone Hammer"
	set desc = "Expend chemicals constantly to form a large, heavy mass of bone on your host's arm."

	if(!check_can_do(0))
		return

	if(channeling && !channeling_bone_hammer)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a mass of bone for your host.")
		channeling = 0
		channeling_bone_hammer = 0
	else if(chemicals < 10)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/item/weapon/melee/bone_hammer/S = new(get_turf(host), src)
		if(hostlimb == LIMB_RIGHT_ARM)
			if(host.get_held_item_by_index(GRASP_RIGHT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/melee/bone_hammer))
					to_chat(src, "<span class='warning'>Your host already has a bone hammer on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_RIGHT_HAND), force_drop = 1)
			host.put_in_r_hand(S)
		else
			if(host.get_held_item_by_index(GRASP_LEFT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_LEFT_HAND), /obj/item/weapon/melee/bone_hammer))
					to_chat(src, "<span class='warning'>Your host already has a bone hammer on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_LEFT_HAND), force_drop = 1)
			host.put_in_l_hand(S)
		to_chat(src, "You begin to focus your efforts on sustaining a mass of bone for your host.")
		channeling = 1
		channeling_bone_hammer = 1
		host.visible_message("<span class='warning'>A mass of bone erupts from \the [host.name]'s [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>","<span class='warning'>A mass of bone erupts from your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>")
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_hammer)
				time_spent_channeling++
				sleep(10)
			channeling = 0
			channeling_bone_hammer = 0
			host.visible_message("<span class='notice'>\The [host]'s bone hammer crumbles into nothing.</span>","<span class='notice'>Your bone hammer crumbles into nothing.</span>")
			var/showmessage = 0
			if(chemicals < 10)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

//////////DEFENSE TREE/////////////////////
/obj/item/verbs/borer/attached_arm/bone_shield/verb/bone_shield()
	set category = "Alien"
	set name = "Bone Shield"
	set desc = "Expend chemicals constantly to form a large shield of bone for your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bone_shield()

/mob/living/simple_animal/borer/proc/bone_shield()
	set category = "Alien"
	set name = "Bone Shield"
	set desc = "Expend chemicals constantly to form a large shield of bone for your host."

	if(!check_can_do(0))
		return

	if(channeling && !channeling_bone_shield)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a shield of bone for your host.")
		channeling = 0
		channeling_bone_shield = 0
	else if(chemicals < 3)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/item/weapon/shield/riot/bone/S = new(get_turf(host), src)
		if(hostlimb == LIMB_RIGHT_ARM)
			if(host.get_held_item_by_index(GRASP_RIGHT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/shield/riot/bone))
					to_chat(src, "<span class='warning'>Your host already has a bone shield on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_RIGHT_HAND), force_drop = 1)
			host.put_in_r_hand(S)
		else
			if(host.get_held_item_by_index(GRASP_LEFT_HAND))
				if(istype(host.get_held_item_by_index(GRASP_LEFT_HAND), /obj/item/weapon/shield/riot/bone))
					to_chat(src, "<span class='warning'>Your host already has a bone shield on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_held_item_by_index(GRASP_LEFT_HAND), force_drop = 1)
			host.put_in_l_hand(S)
		to_chat(src, "You begin to focus your efforts on sustaining a shield of bone for your host.")
		channeling = 1
		channeling_bone_shield = 1
		host.visible_message("<span class='warning'>A shield of bone erupts from \the [host.name]'s [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>","<span class='warning'>A shield of bone erupts from your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm!</span>")
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_shield)
				time_spent_channeling++
				sleep(10)
			channeling = 0
			channeling_bone_shield = 0
			host.visible_message("<span class='notice'>\The [host]'s bone shield crumbles into nothing.</span>","<span class='notice'>Your bone shield crumbles into nothing.</span>")
			var/showmessage = 0
			if(chemicals < 3)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

/obj/item/verbs/borer/attached_arm/bone_cocoon/verb/bone_cocoon()
	set category = "Alien"
	set name = "Bone Cocoon"
	set desc = "Expend chemicals constantly to form a large protective cocoon of bone around your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bone_cocoon()

/mob/living/simple_animal/borer/proc/bone_cocoon()
	set category = "Alien"
	set name = "Bone Cocoon"
	set desc = "Expend chemicals constantly to form a large protective cocoon of bone around your host."

	if(!check_can_do(0))
		return

	if(channeling && !channeling_bone_cocoon)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a shield of bone for your host.")
		channeling = 0
		channeling_bone_cocoon = 0
	else if(chemicals < 10)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/structure/bone_cocoon/S = new(get_turf(host), src)
		to_chat(src, "You begin to focus your efforts on sustaining a cocoon of bone for your host.")
		channeling = 1
		channeling_bone_cocoon = 1
		host.visible_message("<span class='warning'>A cocoon of bone sprouts from \the [host.name]'s [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm and envelops \him!</span>","<span class='warning'>A cocoon of bone erupts from your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm and envelops you!</span>")
		host.forceMove(S)
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_cocoon)
				time_spent_channeling++
				sleep(10)
			channeling = 0
			channeling_bone_cocoon = 0
			var/showmessage = 0
			if(chemicals < 10)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

/obj/item/verbs/borer/attached_arm/em_pulse/verb/em_pulse()
	set category = "Alien"
	set name = "Electromagnetic Pulse"
	set desc = "Expend a great deal of chemicals to produce a small electromagnetic pulse."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.em_pulse()

/mob/living/simple_animal/borer/proc/em_pulse()
	set category = "Alien"
	set name = "Electromagnetic Pulse"
	set desc = "Expend a great deal of chemicals to produce a small electromagnetic pulse."

	if(!check_can_do())
		return

	if(chemicals < 100)
		to_chat(src, "<span class='warning'>You need at least 100 chemicals to do this.</span>")
		return
	else
		chemicals -= 100
		empulse(get_turf(src), 1, 2, 0)

//////////UTILITY TREE/////////////////////
/obj/item/verbs/borer/attached_arm/repair_bone/verb/repair_bone()
	set category = "Alien"
	set name = "Repair Bone"
	set desc = "Expend chemicals to repair bones in your host's arm."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.repair_bone()

/mob/living/simple_animal/borer/proc/repair_bone()
	set category = "Alien"
	set name = "Repair Bone"
	set desc = "Expend chemicals to repair bones in your host's arm."

	if(!check_can_do())
		return

	if (!host)
		return
	if(!istype(host, /mob/living/carbon/human))
		to_chat(src, "<span class='warning'>You can't seem to repair your host's strange biology.</span>")
		return
	if(chemicals < 30)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	var/has_healed_hand = 0
	var/mob/living/carbon/human/H = host
	var/datum/organ/external/current_limb = null
	current_limb = H.get_organ(hostlimb)

	for(var/datum/organ/external/O in current_limb.children)
		if(O.is_broken())
			O.status &= ~ORGAN_BROKEN
			O.perma_injury = 0
			var/minimum_broken_damage_hand = O.min_broken_damage
			O.brute_dam = ((minimum_broken_damage_hand * config.organ_health_multiplier)-1)
			to_chat(src, "<span class='notice'>You've repaired the bones in your host's [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] hand.</span>")
			to_chat(host, "<span class='notice'>You feel the bones in your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] hand mend together.</span>")
			chemicals -= 30
			has_healed_hand = 1
	if(current_limb.is_broken())
		if(chemicals < 50)
			if(has_healed_hand)
				to_chat(src, "<span class='warning'>You don't have enough chemicals left to heal your host's [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm.</span>")
				return
			else
				to_chat(src, "<span class='warning'>You must have at least 50 chemicals stored to heal a broken arm.</span>")
				return
		current_limb.status &= ~ORGAN_BROKEN
		current_limb.perma_injury = 0
		var/minimum_broken_damage_arm = current_limb.min_broken_damage
		current_limb.brute_dam = ((minimum_broken_damage_arm * config.organ_health_multiplier)-1)
		to_chat(src, "<span class='notice'>You've repaired the bones in your host's [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm.</span>")
		to_chat(host, "<span class='notice'>You feel the bones in your [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm mend together.</span>")
		chemicals -= 50
	else
		if(!has_healed_hand)
			to_chat(src, "<span class='notice'>None of the bones in your host's [hostlimb == LIMB_RIGHT_ARM ? "right" : "left"] arm or hand are broken.</span>")