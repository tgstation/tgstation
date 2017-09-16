/datum/antagonist/vampire
	var/usable_blood = 0
	var/total_blood = 0
	var/list/objectives_given = list()

/datum/antagonist/vampire/on_gain()
	give_objectives()
	SSticker.mode.vampires += owner
	..()

/datum/antagonist/traitor/on_removal()
	SSticker.mode.vampires -= owner
	for(var/O in objectives_given)
		owner.objectives -= O
	objectives_given = list()
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>Your powers have been quenched! You are no longer a vampire</span>")
	owner.special_role = null
	..()

/datum/antagonist/vampire/greet()
	to_chat(owner, "<span class='danger'>You are a Vampire!</span>")
	if(LAZYLEN(objectives_given))
		owner.announce_objectives()

/datum/antagonist/vampire/proc/give_objectives()
	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = owner
	blood_objective.gen_amount_goal()
	add_objective(blood_objective)

	for(var/i = 1, i < config.traitor_objectives_amount, i++)
		forge_single_objective()

	if(!(locate(/datum/objective/escape) in owner.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	objectives_given += O

/datum/antagonist/vampire/proc/forge_single_objective() //Returns how many objectives are added
	.=1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		add_objective(steal_objective)

/datum/antagonist/vampire/proc/vamp_burn(var/severe_burn = FALSE)
	var/mob/living/L = owner.current
	if(!L)
		return
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && L.health >= 50)
		switch(L.health)
			if(75 to 100)
				to_chat(L, "<span class='warning'>Your skin flakes away...</span>")
			if(50 to 75)
				to_chat(L, "<span class='warning'>Your skin sizzles!</span>")
		L.adjustFireLoss(3)
	else if(L.health < 50)
		if(!L.on_fire)
			to_chat(L, "<span class='danger'>Your skin catches fire!</span>")
			L.emote("scream")
		else
			to_chat(L, "<span class='danger'>You continue to burn!</span>")
		L.adjust_fire_stacks(5)
		L.IgniteMob()
	return

/datum/antagonist/vampire/proc/check_sun()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	var/ax = C.x
	var/ay = C.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), C.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return
	vamp_burn(TRUE)

/datum/antagonist/vampire/proc/vampire_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(istype(C.loc, /obj/structure/closet/coffin))
		C.adjustBruteLoss(-4)
		C.adjustFireLoss(-4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		return
	if(istype(get_area(C.loc), /area/chapel))
		vamp_burn()
	if(isspaceturf(C.loc))
		check_sun()