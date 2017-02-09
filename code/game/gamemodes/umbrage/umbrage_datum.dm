/datum/umbrage
	var/datum/mind/linked_mind
	var/psi = 100 //Our psi, used for abilities.
	var/max_psi = 100
	var/psi_regeneration = 20 //The limit for psi regenerated during the cycle.
	var/psi_used_since_last_cycle //How much psi we've used in the last five seconds.
	var/cycle_progress = 0 //When this reaches 5, it will reset to 0 and regenerate up to 20 spent psi.
	var/lucidity = 3 //Lucidiy is used to buy abilities. We gain one each time we drain someone.

/datum/umbrage/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/umbrage/process()
	cycle_progress++
	if(cycle_progress >= 5)
		regenerate_psi()
		cycle_progress = 0

/datum/umbrage/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/umbrage/proc/use_psi(used_psi)
	cycle_progress = 0 //Reset regenerating psi when we use more
	psi = max(0, min(psi - used_psi, max_psi))
	psi_used_since_last_cycle += used_psi
	return 1

/datum/umbrage/proc/regenerate_psi()
	var/psi_to_regen
	if(psi >= max_psi) //No need to regenerate anything, so let's get out
		return 1
	psi_to_regen = min(psi_used_since_last_cycle, psi_regeneration) //Never go above our regen rate
	psi = min(psi + psi_to_regen, max_psi)
	psi_used_since_last_cycle = 0
	return 1

/datum/umbrage/proc/has_ability(ability_name)
	for(var/datum/action/innate/umbrage/U in linked_mind.current.actions)
		if(U.name == ability_name)
			return 1
	return

/datum/umbrage/proc/give_ability(ability_name, silent)
	var/datum/action/innate/umbrage/ability
	for(var/V in subtypesof(/datum/action/innate/umbrage))
		var/datum/action/innate/umbrage/U = V
		if(initial(U.name) == ability_name)
			ability = new U
			break
	if(!ability)
		return
	ability.Grant(linked_mind.current)
	if(!silent)
		linked_mind.current << "<span class='velvet_italic'>You have learned the \"[ability_name]\" ability.</span>"
	return 1

/datum/umbrage/proc/take_ability(ability_name, silent)
	var/datum/action/innate/umbrage/ability
	for(var/datum/action/innate/umbrage/U in linked_mind.current.actions)
		if(U.name == ability_name)
			ability = U
			break
	if(!ability)
		return
	ability.Remove(linked_mind.current)
	if(!silent)
		linked_mind.current << "<span class='warning'>You have lost the \"[ability_name]\" ability.</span>"
	qdel(ability)
	return 1
