/datum/round_event_control/chronop
	name = "Timeline Eradication Agent"
	typepath = /datum/round_event/chronop
	max_occurrences = 3
	earliest_start = 30000

/datum/round_event/chronop
	var/customkey = null
	var/list/customtargets = list()
	var/mob/living/carbon/human/TEA = null

/datum/round_event/chronop/start()
	spawn(0)
		var/key
		var/spawn_loc

		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("carpspawn")
						spawn_locs += L.loc
		if(!spawn_locs.len)
			return kill(1)
		spawn_loc = pick(spawn_locs)

		if(!customkey)
			var/list/mob/dead/observer/candidates = list()
			var/mob/dead/observer/picked = null
			var/time_passed = world.time

			for(var/mob/dead/observer/G in player_list)
				spawn(0)
					switch(alert(G,"Do you wish to be considered for the position of Timeline Eradication Agent?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)
								return
							candidates += G
						if("No")
							return
						else
							return
			sleep(300)

			for(var/mob/dead/observer/G in candidates)
				if(!G.key)
					candidates.Remove(G)

			if(candidates.len)
				picked = pick(candidates)
				key = picked.key
			else
				return kill(1)
		else
			key = customkey

		var/datum/mind/TEAmind = new(key)
		TEAmind.assigned_role = "Timeline Eradication Agent"
		TEAmind.special_role = "agent"
		ticker.mode.traitors |= TEAmind
		TEAmind.active = 1

		if(customtargets.len)
			for(var/datum/mind/M in customtargets)
				var/datum/objective/TED_erase/erasO = new()
				erasO.owner = TEAmind
				erasO.target = M
				TEAmind.objectives += erasO
		else
			var/erase_count = Clamp(Ceiling(joined_player_list.len / 6), 1, 4)
			for(var/i=0, i < erase_count, i++)
				var/datum/objective/TED_erase/erasO = new()
				erasO.owner = TEAmind
				erasO.find_target()
				TEAmind.objectives += erasO

		var/datum/objective/survive/S = new()
		S.owner = TEAmind
		TEAmind.objectives += S

		TEA = new(spawn_loc)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/under/color/aqua(TEA), slot_w_uniform)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(TEA), slot_wear_mask)
		var/obj/item/clothing/suit/space/chronos/chronosuit = new(TEA)
		var/radio_freq = SYND_FREQ
		var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
		R.set_frequency(radio_freq)
		TEA.equip_to_slot_or_del(R, slot_ears)
		TEA.equip_to_slot_or_del(chronosuit, slot_wear_suit)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/chronos(TEA), slot_head)
		TEA.equip_to_slot_or_del(new /obj/item/weapon/tank/internals/emergency_oxygen(TEA), slot_s_store)
		TEA.equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_r_store)
		TEA.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(src), slot_l_store)
		TEA.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(agent), slot_shoes)
		TEA.equip_to_slot_or_del(new /obj/item/weapon/chrono_eraser(TEA), slot_back)

		TEAmind.transfer_to(TEA)

		TEA.internal = TEA.s_store
		chronosuit.activate()
		TEA.loc = locate(1,1,2)
		chronosuit.chronowalk(TEA)

/datum/round_event/chronop/kill(fail)
	if(fail && control)
		control.occurrences--
	return ..()

/datum/round_event/chronop/end() //This is to make sure it doesn't get killed until it's done
	if(!TEA)
		endWhen++

/datum/objective/TED_erase
	explanation_text = "Using your TED device, erase the target from the timestream."

/datum/objective/TED_erase/target_check(var/datum/mind/target)
	var/mob/living/carbon/human/Htarget = target.current
	return (Htarget && Htarget.z == 1)

/datum/objective/TED_erase/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Using your TED device, erase [target.name], the [target.assigned_role], from the timestream."
	else
		explanation_text = "Free Objective"

/datum/objective/TED_erase/check_completion()
	if(target && owner)
		if(owner.current)
			var/mob/user = owner.current
			for(var/obj/item/weapon/chrono_eraser/TED in user.contents)
				if(target in TED.erased_minds)
					return 1
		return 0
	return 1