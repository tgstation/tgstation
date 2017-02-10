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

/datum/umbrage/proc/give_ability(ability_name, silent, consume_lucidity)
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
	if(consume_lucidity)
		lucidity = max(0, lucidity - initial(ability.lucidity_cost))
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
		AL["desc"] = initial(ability.desc)
		AL["psi_cost"] = initial(ability.psi_cost)
		AL["lucidity_cost"] = initial(ability.lucidity_cost)
		AL["owned"] = has_ability(initial(ability.name))
		AL["can_purchase"] = (!has_ability(initial(ability.name)) && lucidity >= initial(ability.lucidity_cost))

		abilities += list(AL)

	data["abilities"] = abilities

	return data

/datum/umbrage/ui_act(action, params)
	if(..())
		return
	if(action == "unlock")
		give_ability(params["name"], 0, 1)
