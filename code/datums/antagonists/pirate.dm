/datum/antagonist/pirate
	name = "Space Pirate"
	job_rank = ROLE_TRAITOR
	var/datum/objective_team/pirate/crew

/datum/antagonist/pirate/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Space Pirate!</span>")
	to_chat(owner, "<B>The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot.</B>")
	owner.announce_objectives()

/datum/antagonist/pirate/get_team()
	return crew

/datum/antagonist/pirate/create_team(datum/objective_team/pirate/new_team)
	if(!new_team)
		for(var/datum/antagonist/pirate/P in GLOB.antagonists)
			if(P.crew)
				new_team = P.crew
		if(!new_team)
			crew = new /datum/objective_team/pirate
			crew.forge_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	crew = new_team

/datum/antagonist/pirate/on_gain()
	if(crew)
		owner.objectives |= crew.objectives
	. = ..()

/datum/antagonist/pirate/on_removal()
	if(crew)
		owner.objectives -= crew.objectives
	. = ..()

/datum/objective_team/pirate
	name = "Pirate crew"
	var/list/objectives = list()

/datum/objective_team/pirate/proc/forge_objectives()
	var/datum/objective/loot/getbooty = new()
	getbooty.team = src
	getbooty.storage_area = locate(/area/shuttle/pirate/vault) in GLOB.sortedAreas
	getbooty.update_initial_value()
	getbooty.update_explanation_text()
	objectives += getbooty
	for(var/datum/mind/M in members)
		M.objectives |= objectives


GLOBAL_LIST_INIT(pirate_loot_cache, typecacheof(list(
	/obj/structure/reagent_dispensers/beerkeg,
	/mob/living/simple_animal/parrot,
	/obj/item/stack/sheet/mineral/gold,
	/obj/item/stack/sheet/mineral/diamond,
	/obj/item/stack/spacecash,
	/obj/item/melee/sabre,)))

/datum/objective/loot
	var/area/storage_area //Place where we we will look for the loot.
	explanation_text = "Acquire valuable loot and store it in designated area."
	var/target_value = 50000
	var/initial_value = 0 //Things in the vault at spawn time do not count

/datum/objective/loot/update_explanation_text()
	if(storage_area)
		explanation_text = "Acquire loot and store [target_value] of credits worth in [storage_area.name]."

/datum/objective/loot/proc/loot_listing()
	//Lists notable loot.
	if(!storage_area)
		return "Nothing"
	var/list/loot_table = list()
	for(var/atom/movable/AM in storage_area.GetAllContents())
		if(is_type_in_typecache(AM,GLOB.pirate_loot_cache))
			var/lootname = AM.name
			var/count = 1
			if(istype(AM,/obj/item/stack)) //Ugh.
				var/obj/item/stack/S = AM
				lootname = S.singular_name
				count = S.amount
			if(!loot_table[lootname])
				loot_table[lootname] = count
			else
				loot_table[lootname] += count
	var/text = ""
	for(var/key in loot_table)
		var/amount = loot_table[key]
		text += "[amount] [key][amount > 1 ? "s":""], "
	return text

/datum/objective/loot/proc/get_loot_value()
	if(!storage_area)
		return 0
	var/value = 0
	for(var/turf/T in storage_area.contents)
		value += export_item_and_contents(T,TRUE, TRUE, dry_run = TRUE)
	return value - initial_value

/datum/objective/loot/proc/update_initial_value()
	initial_value = get_loot_value()

/datum/objective/loot/check_completion()
	return ..() || get_loot_value() >= target_value


//These need removal ASAP as everything is converted to datum antags.
/datum/game_mode/proc/auto_declare_completion_pirates()
	var/list/datum/mind/pirates = get_antagonists(/datum/antagonist/pirate)
	var/datum/objective_team/pirate/crew
	var/text = ""
	if(pirates.len)
		text += "<br><b>Space Pirates were:</b>"
		for(var/datum/mind/M in pirates)
			text += printplayer(M)
			if(!crew)
				var/datum/antagonist/pirate/P = M.has_antag_datum(/datum/antagonist/pirate)
				crew = P.crew
		if(crew)
			text += "<br>Loot stolen: "
			var/datum/objective/loot/L = locate() in crew.objectives
			text += L.loot_listing()
			text += "<br>Total loot value : [L.get_loot_value()]/[L.target_value] credits"

			var/all_dead = TRUE
			for(var/datum/mind/M in crew.members)
				if(considered_alive(M))
					all_dead = FALSE
					break
			if(L.check_completion() && !all_dead)
				text += "<br><font color='green'><b>The pirate crew was successful!</b></font>"
			else
				text += "<br><span class='boldannounce'>The pirate crew has failed.</span>"
	to_chat(world, text)