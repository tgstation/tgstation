/datum/round_event_control/shuttle_catastrophe
	name = "Shuttle Catastrophe"
	typepath = /datum/round_event/shuttle_catastrophe
	weight = 10
	max_occurrences = 1

/datum/round_event_control/shuttle_catastrophe/canSpawnEvent(players, gamemode)
	if(SSshuttle.emergency.name == "Build your own shuttle kit")
		return FALSE //don't undo manual player engineering, it also would unload people and ghost them, there's just a lot of problems
	if(EMERGENCY_AT_LEAST_DOCKED)
		return FALSE //don't remove all players when its already on station or going to centcom
	return ..()


/datum/round_event/shuttle_catastrophe
	var/datum/map_template/shuttle/new_shuttle

/datum/round_event/shuttle_catastrophe/announce(fake)
	var/cause = pick("was attacked by [syndicate_name()] Operatives", "mysteriously teleported away", "had its refuelling crew mutiny",
		"was found with its engines stolen", "\[REDACTED\]", "flew into the sunset, and melted", "learned something from a very wise cow, and left on its own",
		"had cloning devices on it", "had its shuttle inspector put the shuttle in reverse instead of park, causing the shuttle to crash into the hangar")

	priority_announce("Your emergency shuttle [cause]. Your replacement shuttle will be the [new_shuttle.name] until further notice.", "CentCom Spacecraft Engineering")

/datum/round_event/shuttle_catastrophe/setup()
	var/list/valid_shuttle_templates = list()
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.can_be_bought && template.credit_cost < INFINITY) //if we could get it from the communications console, it's cool for us to get it here
			valid_shuttle_templates += template
	new_shuttle = pick(valid_shuttle_templates)

/datum/round_event/shuttle_catastrophe/start()
	SSshuttle.shuttle_purchased = SHUTTLEPURCHASE_FORCED
	SSshuttle.unload_preview()
	SSshuttle.load_template(new_shuttle)
	SSshuttle.existing_shuttle = SSshuttle.emergency
	SSshuttle.action_load(new_shuttle)
	log_shuttle("Shuttle Catastrophe set a new shuttle, [new_shuttle.name].")
