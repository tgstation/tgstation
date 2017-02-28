//Handles everything related to psi and lucidity.
/datum/umbrage
	var/datum/mind/linked_mind
	var/mob/living/linked_body
	var/psi = 100 //Our psi, used for abilities.
	var/max_psi = 100
	var/psi_regeneration = 20 //The limit for psi regenerated during the cycle.
	var/psi_used_since_last_cycle //How much psi we've used in the last five seconds.
	var/cycle_progress = 0 //When this reaches 5, it will reset to 0 and regenerate up to 20 spent psi.
	var/lucidity = 3 //Lucidiy is used to buy abilities. We gain one each time we drain someone.
	var/lucidity_drained = 3 //How much lucidity we've taken overall.
	var/list/ability_types //Types of abilities that the umbrage CAN OWN
	var/list/linked_abilities //Abilities that we have
	var/list/linked_ability_types //Types of abilities that the umbrage OWNS
	var/list/drained_minds //People drained with Devour Will

/datum/umbrage/New()
	..()
	ability_types = list()
	linked_abilities = list()
	START_PROCESSING(SSprocessing, src)
	for(var/V in subtypesof(/datum/action/innate/umbrage))
		var/datum/action/innate/umbrage/U = V
		ability_types[initial(U.id)] = V //"V" is the path

/datum/umbrage/process()
	cycle_progress++
	if(cycle_progress >= 5)
		regenerate_psi()
		cycle_progress = 0
	if(linked_mind && linked_body != linked_body && linked_body.stat != DEAD)
		link_to_new_body(linked_body)

/datum/umbrage/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/umbrage/proc/link_to_new_body(mob/living/new_host) //Give all our old abilities to a new body, in case we're cloned or such
	linked_body = new_host
	for(var/taip in linked_ability_types)
		var/datum/action/innate/umbrage/U = taip
		give_ability(initial(U.id), 1)
	return TRUE

/datum/umbrage/proc/has_psi(psi_amount)
	return psi >= psi_amount

/datum/umbrage/proc/use_psi(used_psi)
	cycle_progress = 0 //Reset regenerating psi when we use more
	psi = max(0, min(psi - used_psi, max_psi))
	psi_used_since_last_cycle += used_psi
	return TRUE

/datum/umbrage/proc/regenerate_psi()
	var/psi_to_regen
	if(psi >= max_psi) //No need to regenerate anything, so let's get out
		return TRUE
	psi_to_regen = min(psi_used_since_last_cycle, psi_regeneration) //Never go above our regen rate
	psi = min(psi + psi_to_regen, max_psi)
	psi_used_since_last_cycle = 0
	return TRUE

/datum/umbrage/proc/has_ability(id)
	return linked_abilities[id]

/datum/umbrage/proc/give_ability(id, silent, consume_lucidity) //Gives an ability of a certain name to the umbrage and consumes lucidity if applicable.
	if(!ability_types[id] || has_ability(id))
		return
	var/datum/action/innate/umbrage/ability
	var/ability_type = ability_types[id]
	ability = new ability_type
	ability.linked_umbrage = src
	ability.Grant(linked_body)
	linked_abilities[ability.id] = ability
	LAZYADD(linked_ability_types, ability.type)
	if(!silent)
		linked_body << "<span class='velvet italic'>You have learned the \"[ability.name]\" ability.</span>"
	if(consume_lucidity)
		lucidity = max(0, lucidity - initial(ability.lucidity_cost))
	return TRUE

/datum/umbrage/proc/take_ability(id, silent) //Takes an ability of a certain name from the umbrage.
	if(!has_ability(id))
		return
	var/datum/action/innate/umbrage/ability
	ability = linked_abilities[id]
	ability.Remove(linked_body)
	linked_abilities[id] = null
	LAZYREMOVE(linked_ability_types, ability.type)
	if(!silent)
		linked_body << "<span class='warning'>You have lost the \"[ability.name]\" ability.</span>"
	qdel(ability)
	return TRUE


//Psi Web code goes below here
/datum/umbrage/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = not_incapacitated_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "psi_web", "Psi Web", 900, 480, master_ui, state)
		ui.open()

/datum/umbrage/ui_data(mob/user)
	var/list/data = list()

	data["lucidity"] = lucidity

	var/list/abilities = list()

	for(var/path in subtypesof(/datum/action/innate/umbrage))
		var/datum/action/innate/umbrage/ability = path

		if(initial(ability.blacklisted))
			continue

		var/list/AL = list() //This is mostly copy-pasted from the cellular emporium, but it should be fine regardless
		AL["name"] = initial(ability.name)
		AL["id"] = initial(ability.id)
		AL["desc"] = initial(ability.desc)
		AL["psi_cost"] = initial(ability.psi_cost)
		AL["lucidity_cost"] = initial(ability.lucidity_cost)
		AL["owned"] = has_ability(initial(ability.id))
		AL["can_purchase"] = (!has_ability(initial(ability.id)) && lucidity >= initial(ability.lucidity_cost))

		abilities += list(AL)

	data["abilities"] = abilities

	return data

/datum/umbrage/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("unlock")
			give_ability(params["id"], 0, 1)
