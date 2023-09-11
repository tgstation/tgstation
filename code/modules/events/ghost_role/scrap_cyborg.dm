/// Spawns a busted up cyborg randomly in maintenance via pod.
/// They're given a random lawset, and a random number of ion laws.
/datum/round_event_control/scrap_cyborg
	name = "Scrap Cyborg"
	typepath = /datum/round_event/ghost_role/scrap_cyborg
	weight = 8
	max_occurrences = 1
	min_players = 20
	category = EVENT_CATEGORY_AI
	description = "A old, abandoned cyborg with a random lawset and module has found its way abord the station."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 7

/datum/round_event_control/scrap_cyborg/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return

	// We'll only spawn if there's some other silicons on board we can interact with
	return length(get_friend_silicons()) > 0

/// Returns a list of silicon mobs that are alive and on the station, excluding PAIs (and drones?)
/datum/round_event_control/scrap_cyborg/proc/get_friend_silicons()
	var/list/all_friends = list()
	for(var/mob/living/silicon/friend as anything in GLOB.silicon_mobs)
		if(!iscyborg(to_warn) && !isAI(to_warn))
			continue
		if(friend.stat == DEAD)
			continue
		var/turf/friend_turf = get_turf(friend)
		if(!is_station_level(friend_turf?.z))
			continue
		all_friends += friend
	return all_friends

// The actual round event.
/datum/round_event/ghost_role/scrap_cyborg
	minimum_required = 1
	role_name = "abandoned cyborg"
	fakeable = FALSE

/// Returns a list of silicon mobs that are alive and on the station, excluding PAIs (and drones?)
/datum/round_event/ghost_role/scrap_cyborg/proc/get_friend_silicons() // melbert todo : kill this copy pasta
	var/list/all_friends = list()
	for(var/mob/living/silicon/friend as anything in GLOB.silicon_mobs)
		if(!iscyborg(to_warn) && !isAI(to_warn))
			continue
		if(friend.stat == DEAD)
			continue
		var/turf/friend_turf = get_turf(friend)
		if(!is_station_level(friend_turf?.z))
			continue
		all_friends += friend
	return all_friends

/datum/round_event/ghost_role/scrap_cyborg/spawn_role()
	var/list/candidates = get_candidates(JOB_CYBORG)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/turf/spawn_loc = find_maintenance_spawn(atmos_sensitive = FALSE, require_darkness = FALSE)
	if(isnull(spawn_loc))
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)

	var/obj/structure/closet/supplypod/pod = podspawn(list(
		"target" = spawn_loc,
		"path" = /obj/structure/closet/supplypod,
	))

	// Used for logging
	var/lawset_chosen = ""
	// Determine how many, if any, ion laws to give the cyborg
	var/ion_laws = pick_weight(list(
		"0" = 10,
		"1" = 5,
		"2" = 3,
		"3" = 1,
		"All" = 1,
	))

	// Actually makes the thing and shoves them into the pod
	var/mob/living/silicon/robot/spawned_cyborg = new(pod) // melbert todo : should be a unique subtype.

	if(ion_laws == "All")
		// Spawned with a purged lawset (no laws) then fill in a buncha ion ones
		spawned_cyborg.laws = new()
		ion_laws = pick("3", "4")
		lawset_chosen = "Purged / Fully ion ([ion_laws] laws)"

	else
		// This is based on that which the station AI can get, which excludes extremely harmful ones.
		// (Perhaps an antag variant of this event could spawn with a more dangerous lawset?)
		// (Or maybe just change this to be a random lawset period - given the cyborg spawns damaged, it likely can't accomplish much.)
		var/random_lawset = pick_weighted_lawset()
		spawned_cyborg.laws = new random_lawset()
		lawset_chosen = "[spawned_cyborg.laws.name] ([ion_laws] ion laws)"

	for(var/i in 1 to text2num(ion_laws))
		spawned_cyborg.laws.add_ion_law(generate_ion_law())

	// Randomly fuck up the cyborg.
	// Maybe they're unlocked, fully opened, and have exposed wires? Maybe they're missing a cell?
	// Maybe they're heavily burned or battered to bits?
	if(prob(50))
		spawned_cyborg.locked = FALSE
		if(prob(50))
			spawned_cyborg.opened = TRUE
			if(prob(50))
				spawned_cyborg.wiresexposed = TRUE
		if(prob(50)) // Only have a chance to spawn cell-less if unlocked, for fairness
			QDEL_NULL(spawned_cyborg.cell)

		spawned_cyborg.update_icons()

	if(prob(50))
		spawned_cyborg.lamp_functional = FALSE

	var/damage_to_deal = rand(spawned_cyborg.maxHealth * 0.2, spawned_cyborg.maxHealth * 0.8)
	var/and_how_much_brute = damage_to_deal * rand(0, 10) * 0.1
	var/and_how_much_burn = damage_to_deal - and_how_much_brute

	if(and_how_much_brute > 0)
		spawned_cyborg.apply_damage(and_how_much_brute, BRUTE)
	if(and_how_much_burn > 0)
		spawned_cyborg.apply_damage(and_how_much_burn, BURN)

	spawned_cyborg.apply_status_effect(/datum/status_effect/scrapped_borg)
	spawned_cyborg.scrambledcodes = TRUE // Prevent robo console / cyborg upload from revealing us
	spawned_cyborg.lawupdate = FALSE // Prevent law sync
	spawned_cyborg.lamp_color = COLOR_LIME // Just for flavor

	// Finally move the player in, after all setup is done.
	spawned_cyborg.key = selected.key
	spawned_cyborg.log_message("was spawned as a/an \"[role_name]\" by an event. Lawset chosen: [lawset_chosen]", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(spawned_cyborg)] has been made into a/an \"[role_name]\" by an event. Lawset chosen: [lawset_chosen]")

	spawned_mobs += spawned_cyborg

	addtimer(CALLBACK(src, PROC_REF(warn_ai), get_area(spawn_loc)), rand(20 SECONDS, 60 SECONDS))

	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/scrap_cyborg/proc/warn_ai(area/spawn_area)
	var/warning_message = span_green("Unidentified signal detected in: [get_area_name(spawn_area, TRUE)].")
	for(var/mob/living/silicon/to_warn as anything in get_friend_silicons())
		to_chat(to_warn, warning_message)
	// melbert todo : should the pod be announced? maybe as a fake stray cargo pod event?

// Status effect applied to broken borgs, simply applies a movespeed modifier
// (which in turns makes them very distinct from normal borgs.)
/datum/status_effect/scrapped_borg
	id = "scrapped_borg"
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/borgo
	remove_on_fullheal = TRUE
	heal_flag_necessary = ALL // anything goes

/datum/status_effect/scrapped_borg/on_apply()
	if(!iscyborg(owner))
		return FALSE

	owner.add_movespeed_modifier(/datum/movespeed_modifier/scrapped_borg)
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(health_updated))
	return TRUE

/datum/status_effect/scrapped_borg/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/scrapped_borg)
	UnregisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE)

/datum/status_effect/scrapped_borg/tick(seconds_between_ticks)
	var/mob/living/silicon/robot/robowner = owner
	if(SPT_PROB(5, seconds_between_ticks))
		robowner.spark_system.start()

	if(SPT_PROB(4, seconds_between_ticks))
		robowner.emp_knockout(2 SECONDS)

/datum/status_effect/scrapped_borg/proc/health_updated()
	SIGNAL_HANDLER
	if(QDELING(src))
		return
	if(owner.health == owner.maxHealth)
		qdel(src)

/datum/status_effect/scrapped_borg/get_examine_text()
	return span_notice("[owner.p_They()] appear to be in a state of disrepair.")

// Alert for above
/atom/movable/screen/alert/status_effect/borgo
	name = "Scrapped"
	desc = "Fatal error. Servo motors damaged. Critical systems offline. Seek repairs immediately."
	icon_state = ALERT_CHARGE

// Movespeed modifier for above
/datum/movespeed_modifier/scrapped_borg
	multiplicative_slowdown = 0.5
