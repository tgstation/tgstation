var/global/list/animal_masks = list(/obj/item/clothing/mask/horsehead, \
									/obj/item/clothing/mask/pig) // in the future: more masks

#define GREETING "Hello, mother."

/datum/game_mode/hotline
	name = "Hotline"
	config_tag = "hotline"
	required_players = 0
	var/datum/sadistic_objective/sadObj = null
	var/objectives_completed = 0
	var/list/sadistic_objectives = list()


/datum/game_mode/hotline/announce()
	world << "<B>The current game mode is - Hotline!</B>"
	world << "<B>The singularity is upon us: an AI at Centcomm has achieved superintelligence. Follow it's sadistic instructions and maybe there is some hope of survival.</B>"


/datum/game_mode/hotline/post_setup()
	..()
	//objectives!
	for(var/path in (typesof(/datum/sadistic_objective) - /datum/sadistic_objective))
		var/datum/sadistic_objective/S = new path()
		sadistic_objectives += S

	//masks!
	for(var/mob/living/carbon/human/player in player_list)
		var/mask =  pick(animal_masks)
		var/obj/item/clothing/a_mask = new mask(player)
		a_mask.flags |= NODROP
		if(player.wear_mask)
			player.wear_mask.loc = null
			player.wear_mask = null
		player.equip_to_slot_or_del(a_mask, slot_wear_mask)

		//hallucinations!
		player.hallucination += rand(30, 50)

	//blood!
	for(var/turf/simulated/floor/F in world)
		if(prob(96))
			continue

		new /obj/effect/decal/cleanable/blood(F)

	//lights!
	var/list/epicentreList = list()
	for(var/obj/machinery/power/apc/A in world)
		if(A.z == 1)
			epicentreList += A

	if(!epicentreList.len)
		return

	for(var/i = 1, i <= 16, i++)
		var/obj/machinery/power/apc/A = pick(epicentreList)
		A.overload_lighting()
		epicentreList -= A

	//cloner!
	for(var/obj/machinery/clonepod/C in world)
		C.loc.ex_act(3)
		C.loc.ex_act(3)
		qdel(C)


/datum/game_mode/hotline/declare_completion()
	..()
	world << "<FONT size = 3><B>The crew activate the nuclear device. Up to that point, they had stopped thinking of morals, stopped thinking of society, laws, punishments. Their only want was to obey the instructions given. They perished wishing for another order. The station was destroyed.</B></FONT>"
	return 1


/datum/game_mode/hotline/process()
	if(!sadObj)
		sadObj = pick(sort_objective_level(objectives_completed))
		sadObj.Announce()
	if(sadObj.CheckCompletion())
		sadObj = null
		objectives_completed++


/datum/game_mode/hotline/proc/sort_objective_level(ideallevel = 0)
	var/list/matching_objectives = list()
	for(var/datum/sadistic_objective/objective in sadistic_objectives)
		if(objective.level == ideallevel)
			matching_objectives += objective

	return matching_objectives


/datum/sadistic_objective
	var/level = 0
	var/alert = "I appear to be malfunctioning. You should never see this."
	var/mob/target = 0

/datum/sadistic_objective/proc/CheckCompletion()
	return 0

/datum/sadistic_objective/proc/Announce()
	var/Ualert = alert

	if(target)
		var/list/living_players = living_mob_list
		living_players &= player_list
		target = pick(living_players)
		Ualert = replacetextEx(Ualert, "%target%", "[target]")
		Ualert = replacetextEx(Ualert, "%He%", (target.gender == "male" ? "He" : "She"))
		Ualert = replacetextEx(Ualert, "%His%", (target.gender == "male" ? "His" : "Her"))
		Ualert = replacetextEx(Ualert, "%Him%", (target.gender == "male" ? "Him" : "Her"))
		Ualert = replacetextEx(Ualert, "%he%", (target.gender == "male" ? "he" : "she"))
		Ualert = replacetextEx(Ualert, "%his%", (target.gender == "male" ? "his" : "her"))
		Ualert = replacetextEx(Ualert, "%him%", (target.gender == "male" ? "him" : "her"))

	priority_announce("[GREETING] [Ualert]")


/datum/sadistic_objective/ian
	level = 0
	alert = "Kill Ian."

/datum/sadistic_objective/ian/CheckCompletion()
	if(!target)
		target = locate(/mob/living/simple_animal/corgi/Ian) in living_mob_list
	if(target.stat == DEAD)
		return 1
	return 0


/datum/sadistic_objective/runtime
	level = 0
	alert = "Kill Runtime."

/datum/sadistic_objective/runtime/CheckCompletion()
	if(!target)
		target = locate(/mob/living/simple_animal/cat/Runtime) in living_mob_list
	if(target.stat == DEAD)
		return 1
	return 0


/datum/sadistic_objective/monkeys
	level = 1
	alert = "Gas at least three monkeys."
	var/list/targets = null

/datum/sadistic_objective/monkeys/CheckCompletion()
	if(!targets)
		targets = list()
		for(var/mob/living/carbon/monkey/M in living_mob_list)
			targets += M
	if(targets)
		var/count = 0
		for(var/mob/living/carbon/monkey/M in targets)
			if(M.stat)
				if(M.oxyloss > 50 || M.toxloss > 50)	//magic numbers!
					if(!istype(M.loc, /turf/space))
						count++
		if(count >= 3)
			return 1

	return 0

/datum/sadistic_objective/stab
	level = 2
	alert = "Put out %target%'s eyes."
	target = 1

/datum/sadistic_objective/stab/CheckCompletion()
	if(!target)
		var/list/living_players = living_mob_list
		living_players &= player_list
		target = pick(living_players)
		priority_announce("[GREETING] Do it to [target] instead.")
	if(target)
		var/mob/living/carbon/human/H = target
		if(H.blinded)
			return 1

	return 0


/datum/sadistic_objective/jacket
	level = 2
	alert = "%target% wishes you harm. Straightjacket %him% to ensure his cooperation."
	target = 1

/datum/sadistic_objective/jacket/CheckCompletion()
	if(!target)
		var/list/living_players = living_mob_list
		living_players &= player_list
		target = pick(living_players)
		priority_announce("[GREETING] Do it to [target] instead.")
	if(target)
		var/mob/living/carbon/human/H = target
		if(istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket))
			return 1

	return 0


/datum/sadistic_objective/gib
	level = 3
	alert = "Gib %target%, and then consume %his% meat."
	target = 1
	var/meat = 0
	var/targetname = null

/datum/sadistic_objective/gib/Announce()
	..()
	var/mob/living/carbon/C = target
	var/mask = C.wear_mask
	qdel(mask)
	C.update_icons()

/datum/sadistic_objective/gib/CheckCompletion()
	if(!target)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/H = locate() in world
		if(H && H.subjectname == targetname && !meat)
			meat = 1
			priority_announce("[GREETING] Now consume the meat.")
		else if(!H)
			return 1
	if(target && !targetname)
		var/mob/living/carbon/human/H = target
		targetname = H.real_name

	return 0


/datum/sadistic_objective/suicide
	level = 4
	alert = "Three humans must die."
	var/initialhumans = 0

/datum/sadistic_objective/suicide/Announce()
	..()
	initialhumans = player_list.len

/datum/sadistic_objective/suicide/CheckCompletion()
	if(player_list.len <= initialhumans - 3)
		return 1

	return 0


/datum/sadistic_objective/nuke
	level = 5
	alert = "Detonate the station nuke. The code is 00000."

/datum/sadistic_objective/nuke/Announce()
	..()
	for(var/obj/machinery/nuclearbomb/nuke in world)
		if(nuke.z != 1)
			return
		nuke.r_code = "00000"


#undef GREETING