#define ONLY_TURF 1 // There should only ever be one turf at the bottom left of the map.
#define REDACTED "???"

/obj/machinery/quantum_server
	name = "quantum server"

	circuit = /obj/item/circuitboard/machine/quantum_server
	density = TRUE
	desc = "A hulking computational machine designed to fabricate virtual domains."
	icon = 'icons/obj/machines/bitmining.dmi'
	base_icon_state = "qserver"
	icon_state = "qserver"
	/// The area type used to delete objects in the vdom
	var/area/preset_delete_area = /area/virtual_domain/to_delete
	/// The area type used to spawn hololadders
	var/area/preset_exit_area = /area/virtual_domain/safehouse/exit
	/// The area type used as a reference to load templates
	var/area/preset_mapload_area = /area/virtual_domain/bottom_left
	/// The area type to receive loot after a domain is completed
	var/area/preset_receive_area = /area/station/bitmining/receiving
	/// The area type used as a reference to load the safehouse
	var/area/preset_safehouse_area = /area/virtual_domain/safehouse/bottom_left
	/// The area type used in vdom to send loot and mark completion
	var/area/preset_send_area = /area/virtual_domain/safehouse/send
	/// The loaded map template, map_template/virtual_domain
	var/datum/map_template/virtual_domain/generated_domain
	/// The loaded safehouse, map_template/safehouse
	var/datum/map_template/safehouse/generated_safehouse
	/// The generated z level to spawn other presets onto, datum/space_level
	var/datum/weakref/vdom_ref
	/// The connected console
	var/datum/weakref/console_ref
	/// If the server is cooling down from a recent despawn
	var/cooling_off = FALSE
	/// If the current domain was a random selection
	var/domain_randomized = FALSE
	/// List of available domains
	var/list/available_domains = list()
	/// Current plugged in users
	var/list/datum/weakref/occupant_mind_refs = list()
	/// Currently (un)loading a domain. Prevents multiple user actions.
	var/loading = FALSE
	/// Scales loot with extra players
	var/multiplayer_bonus = 1.1
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Keeps track of the number of times someone has built a hololadder
	var/retries_spent = 0
	/// Scanner tier
	var/scanner_tier = 1
	/// Server cooldown efficiency
	var/server_cooldown_efficiency = 1
	/// Length of time it takes for the server to cool down after despawning a map. Here to give miners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 2 SECONDS
	/// Turfs to delete whenever the server is shut down.
	var/turf/delete_turfs = list()
	/// The turfs we can place a hololadder on.
	var/turf/exit_turfs = list()
	/// This marks the starting point (bottom left) of the virtual dom map. We use this to spawn templates. Expected: 1
	var/turf/map_load_turf = list()
	/// The turfs on station where we generate loot.
	var/turf/receive_turfs = list()
	/// This marks the starting point (bottom left) of the safehouse. We use this to spawn the safehouse. Expected: 1
	var/turf/safehouse_load_turf = list()
	/// Turfs to look for loot boxes.
	var/turf/send_turfs = list()

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/quantum_server/LateInitialize()
	. = ..()
	if(isnull(console_ref))
		find_console()

	RegisterSignals(src, list(
		COMSIG_MACHINERY_BROKEN,
		COMSIG_MACHINERY_POWER_LOST,
		),
		PROC_REF(on_broken)
	)
	RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete))
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_BITMINING_CLIENT_CONNECTED, PROC_REF(on_client_connected))
	RegisterSignal(src, COMSIG_BITMINING_CLIENT_DISCONNECTED, PROC_REF(on_client_disconnected))
	RefreshParts()

	// This further gets sorted in the client by cost so it's random and grouped
	available_domains = shuffle(subtypesof(/datum/map_template/virtual_domain))

/obj/machinery/quantum_server/Destroy(force)
	. = ..()
	occupant_mind_refs.Cut()
	available_domains.Cut()
	QDEL_NULL(delete_turfs)
	QDEL_NULL(exit_turfs)
	QDEL_NULL(map_load_turf)
	QDEL_NULL(receive_turfs)
	QDEL_NULL(safehouse_load_turf)
	QDEL_NULL(send_turfs)
	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)

/obj/machinery/quantum_server/update_appearance(updates)
	if(isnull(vdom_ref))
		set_light(0)
		return ..()

	set_light_color(isnull(generated_domain) ? LIGHT_COLOR_FIRE : LIGHT_COLOR_BABY_BLUE)
	set_light(2, 1.5)

	return ..()

/obj/machinery/quantum_server/update_icon_state()
	if(generated_domain)
		icon_state = "[base_icon_state]_on"
		return ..()
	if(cooling_off)
		icon_state = "[base_icon_state]_off"
		return ..()

	icon_state = base_icon_state
	return ..()

/obj/machinery/quantum_server/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!get_is_ready())
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(length(occupant_mind_refs))
		balloon_alert(user, "all clients must disconnect!")
		return TRUE
	if(default_deconstruction_crowbar(crowbar))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()
	if(!get_is_ready())
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", icon_state, screwdriver))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/RefreshParts()
	. = ..()

	var/capacitor_rating = 1.2
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		capacitor_rating -= capacitor.tier * 0.1

	server_cooldown_efficiency = max(capacitor_rating, 0)

	var/datum/stock_part/scanning_module/scanner = locate(/datum/stock_part/scanning_module) in component_parts
	if(scanner)
		scanner_tier = scanner.tier

/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(occupant_mind_refs))
		balloon_alert(user, "powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, 2)
		stop_domain()
		return

	balloon_alert(user, "notifying clients...")
	SEND_SIGNAL(src, COMSIG_BITMINING_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, src))
		return

	stop_domain()

/// Handles calculating rewards based on number of players, parts, etc
/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	for(var/datum/stock_part/servo/servo in component_parts)
		rewards_base += servo.tier * 0.1

	for(var/index in 2 to length(occupant_mind_refs))
		rewards_base += multiplayer_bonus

	return rewards_base

/**
 * ### Quantum Server Cold Boot
 * Procedurally links the 3 booting processes together.
 *
 * This is the starting point if you have an id. Does validation and feedback on steps
 */
/obj/machinery/quantum_server/proc/cold_boot_map(mob/user, map_id)
	if(!get_is_ready())
		return FALSE

	if(isnull(map_id))
		balloon_alert(user, "no domain specified.")
		return FALSE

	if(generated_domain)
		balloon_alert(user, "stop the current domain first.")
		return FALSE

	if(length(occupant_mind_refs))
		balloon_alert(user, "all clients must disconnect!")
		return FALSE

	loading = TRUE
	balloon_alert(user, "initializing virtual domain...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	var/datum/space_level/loaded_zlevel = vdom_ref?.resolve()
	if(isnull(loaded_zlevel) && !initialize_virtual_domain())
		loading = FALSE
		return FALSE

	var/datum/map_template/virtual_domain/to_generate = initialize_domain(map_id)
	if(isnull(to_generate))
		balloon_alert(user, "invalid domain specified.")
		loading = FALSE
		return FALSE

	points -= to_generate.cost
	if(points < 0)
		balloon_alert(user, "not enough points.")
		loading = FALSE
		return FALSE

	if(!load_domain(to_generate))
		loading = FALSE
		return FALSE

	loading = FALSE
	balloon_alert(user, "virtual domain generated.")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)

	return TRUE

/// Resets the cooldown state and updates icons
/obj/machinery/quantum_server/proc/cool_off()
	cooling_off = FALSE
	update_icon_state()

/// Attempts to connect to a quantum console
/obj/machinery/quantum_server/proc/find_console()
	var/obj/machinery/computer/quantum_console/console = console_ref?.resolve()
	if(console)
		return console

	for(var/direction in GLOB.cardinals)
		var/obj/machinery/computer/quantum_console/nearby_console = locate(/obj/machinery/computer/quantum_console, get_step(src, direction))
		if(nearby_console)
			console_ref = WEAKREF(nearby_console)
			nearby_console.server_ref = WEAKREF(src)
			return nearby_console

/// Generates a new avatar for the bitminer.
/obj/machinery/quantum_server/proc/generate_avatar(obj/structure/hololadder/wayout, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/datum/outfit/to_wear = generated_domain.forced_outfit || netsuit
	avatar.equipOutfit(to_wear, visualsOnly = TRUE)

	var/obj/item/card/id/outfit_id = avatar.wear_id
	if(outfit_id)
		outfit_id.assignment = "Bit Avatar"
		outfit_id.registered_name = avatar.real_name
		SSid_access.apply_trim_to_card(outfit_id, /datum/id_trim/bit_avatar)

	return avatar

/// Generates a new hololadder for the bitminer. Effectively a respawn attempt.
/obj/machinery/quantum_server/proc/generate_hololadder()
	if(!length(exit_turfs))
		return

	if(retries_spent >= length(exit_turfs))
		return

	var/turf/destination
	for(var/turf/dest_turf as anything in exit_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			destination = dest_turf
			break

	if(isnull(destination))
		return

	var/obj/structure/hololadder/wayout = new(destination)
	if(isnull(wayout))
		return

	retries_spent += 1

	return wayout

/// Generates a reward based on the given domain
/obj/machinery/quantum_server/proc/generate_loot()
	if(!length(receive_turfs))
		receive_turfs = get_area_turfs(preset_receive_area)
	if(!length(receive_turfs))
		return FALSE

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, 2)

	var/turf/dest_turf = pick(receive_turfs)
	if(isnull(dest_turf))
		stack_trace("Failed to find a turf to spawn loot crate on.")
		return FALSE

	var/obj/structure/closet/crate/secure/bitminer_loot/decrypted/reward_crate = new(dest_turf, generated_domain, calculate_rewards())
	spark_at_location(reward_crate)
	return TRUE

/// Compiles a list of available domains.
/obj/machinery/quantum_server/proc/get_available_domains()
	var/list/levels = list()

	for(var/datum/map_template/virtual_domain/domain as anything in available_domains)
		if(initial(domain.test_only))
			continue
		var/can_view = initial(domain.difficulty) < scanner_tier && initial(domain.cost) <= points + 5
		var/can_view_reward = initial(domain.difficulty) < (scanner_tier + 1) && initial(domain.cost) <= points + 3

		levels += list(list(
			"cost" = initial(domain.cost),
			"desc" = can_view ? initial(domain.desc) : "Limited scanning capabilities. Cannot infer domain details.",
			"difficulty" = initial(domain.difficulty),
			"id" = initial(domain.id),
			"name" = can_view ? initial(domain.name) : REDACTED,
			"reward" = can_view_reward ? initial(domain.reward_points) : REDACTED,
		))

	return levels

/// If there are hosted minds, attempts to get a list of their current virtual bodies w/ vitals
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/mind_ref in occupant_mind_refs)
		var/datum/mind/this_mind = mind_ref.resolve()
		if(isnull(this_mind))
			occupant_mind_refs -= this_mind
			continue

		var/mob/living/creature = this_mind.current
		var/mob/living/pilot = this_mind.pilot_ref?.resolve()

		hosted_avatars += list(list(
			"health" = creature.health,
			"name" = creature.name,
			"pilot" = pilot,
			"brute" = creature.get_damage_amount(BRUTE),
			"burn" = creature.get_damage_amount(BURN),
			"tox" = creature.get_damage_amount(TOX),
			"oxy" = creature.get_damage_amount(OXY),
		))

	return hosted_avatars


/// Returns the current domain name if the server has the proper tier scanner and it isn't randomized
/obj/machinery/quantum_server/proc/get_current_domain_name()
	if(isnull(generated_domain))
		return null

	if(scanner_tier < generated_domain.difficulty || domain_randomized)
		return REDACTED

	return generated_domain.name

/// Gets a random available domain given the current points. Weighted towards higher cost domains.
/obj/machinery/quantum_server/proc/get_random_domain_id()
	if(points < 1)
		return

	var/list/available_domains = list()
	var/total_cost = 0

	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		var/init_cost = initial(available.cost)
		if(!initial(available.test_only) && init_cost > 0 && init_cost < 4 && init_cost <= points)
			available_domains += list(list(
				cost = init_cost,
				id = initial(available.id),
			))

	var/random_value = rand(0, total_cost)
	var/accumulated_cost = 0

	for(var/available as anything in available_domains)
		accumulated_cost += available["cost"]
		if(accumulated_cost >= random_value)
			domain_randomized = TRUE
			return available["id"]

/// Returns boolean if the server is ready to be used
/obj/machinery/quantum_server/proc/get_is_ready()
	return !loading && !cooling_off

/// Gets all mobs originally generated by the loaded domain and returns a list that are capable of being antagged
/obj/machinery/quantum_server/proc/get_valid_domain_targets()
	if(!length(occupant_mind_refs))
		return

	if(isnull(generated_domain))
		return

	var/list/mutation_candidates = list()
	for(var/mob/living/creature as anything in generated_domain.created_atoms)
		if(QDELETED(creature) || !isliving(creature) || creature.mind || !creature.can_be_cybercop)
			continue

		mutation_candidates += creature

	return mutation_candidates

/// Returns a new domain if the given id is valid and the user has enough points
/obj/machinery/quantum_server/proc/initialize_domain(map_id)
	var/datum/map_template/virtual_domain/to_generate
	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		if(map_id == initial(available.id) && points >= initial(available.cost))
			to_generate = new available
			return to_generate

/// Generates a new virtual domain
/obj/machinery/quantum_server/proc/initialize_virtual_domain()
	var/datum/map_template/virtual_domain/base_map = new()
	var/datum/space_level/loaded_zlevel = base_map.load_new_z()

	if(isnull(loaded_zlevel))
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	vdom_ref = WEAKREF(loaded_zlevel)

	delete_turfs = get_area_turfs(preset_delete_area, loaded_zlevel.z_value)
	map_load_turf = get_area_turfs(preset_mapload_area, loaded_zlevel.z_value)
	safehouse_load_turf = get_area_turfs(preset_safehouse_area, loaded_zlevel.z_value)

	return TRUE

/// Validates target mob as valid to buff/nerf
/obj/machinery/quantum_server/proc/is_valid_mob(mob/living/creature)
	return isliving(creature) && isnull(creature.key) && creature.stat != DEAD && creature.health > 10

/// Loads the safehouse and given domain into the virtual domain
/obj/machinery/quantum_server/proc/load_domain(datum/map_template/virtual_domain/to_generate)
	var/datum/map_template/safehouse/safehouse = new to_generate.safehouse_path

	to_generate.load(map_load_turf[ONLY_TURF])
	safehouse.load(safehouse_load_turf[ONLY_TURF])

	generated_domain = to_generate
	generated_safehouse = safehouse

	var/datum/space_level/vdom = vdom_ref?.resolve()
	exit_turfs = get_area_turfs(preset_exit_area, vdom.z_value)
	send_turfs = get_area_turfs(preset_send_area, vdom.z_value)

	for(var/turf/tile in send_turfs)
		RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_send_turf_entered))

	update_appearance()

	return TRUE

/// If broken via signal, disconnects all users
/obj/machinery/quantum_server/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	if(isnull(generated_domain))
		return

	stop_domain()

/// Each time someone connects, mob health jumps 1.5x
/obj/machinery/quantum_server/proc/on_client_connected(datum/source, datum/weakref/new_mind)
	SIGNAL_HANDLER

	occupant_mind_refs += new_mind

/// If a client disconnects, remove them from the list & nerf mobs
/obj/machinery/quantum_server/proc/on_client_disconnected(datum/source, datum/weakref/old_mind)
	SIGNAL_HANDLER

	occupant_mind_refs -= old_mind

/// Being qdeleted - make sure the circuit and connected mobs go with it
/obj/machinery/quantum_server/proc/on_delete(datum/source)
	SIGNAL_HANDLER

	if(generated_domain)
		SEND_SIGNAL(src, COMSIG_BITMINING_SEVER_AVATAR)
		scrub_vdom()

	if(get_is_ready())
		return

	var/obj/item/circuitboard/machine/quantum_server/circuit = locate(/obj/item/circuitboard/machine/quantum_server) in contents
	if(circuit)
		qdel(circuit)

/// Whenever something enters the send tiles, check if it's a loot crate. If so, alert players.
/obj/machinery/quantum_server/proc/on_send_turf_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!istype(arrived, /obj/structure/closet/crate/secure/bitminer_loot/encrypted))
		return

	var/obj/structure/closet/crate/secure/bitminer_loot/encrypted/loot_crate = arrived
	if(!istype(loot_crate))
		return

	spark_at_location(loot_crate)
	qdel(loot_crate)
	SEND_SIGNAL(src, COMSIG_BITMINING_DOMAIN_COMPLETE, arrived)
	generate_loot()

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(server_cooldown_efficiency < 1)
		examine_text += span_infoplain("Its coolant capacity reduces cooldown time by [(1 - server_cooldown_efficiency) * 100]%.")

	var/rewards_bonus = 0.8
	for(var/datum/stock_part/servo/servo in component_parts)
		rewards_bonus += servo.tier * 0.1

	if(rewards_bonus > 1)
		examine_text += span_infoplain("Its manipulation potential is increasing rewards by [(rewards_bonus)]x.")

	if(!get_is_ready())
		examine_text += span_notice("It is currently cooling down. Give it a few moments.")
		return

/// Deletes all the tile contents
/obj/machinery/quantum_server/proc/scrub_vdom()
	for(var/turf/tile in send_turfs)
		UnregisterSignal(tile, COMSIG_ATOM_ENTERED)
		UnregisterSignal(tile, COMSIG_ATOM_EXAMINE)

	for(var/turf/tile in exit_turfs)
		UnregisterSignal(tile, COMSIG_ATOM_ENTERED)

	for(var/turf/tile in delete_turfs)
		for(var/thing in tile.contents)
			if(!isobserver(thing))
				qdel(thing)

		for(var/thing in tile.contents) // some things drop their contents
			if(!isobserver(thing))
				qdel(thing)

		tile.baseturfs.Cut(3)

	for(var/turf/tile in safehouse_load_turf) // cleanup that one tile
		for(var/thing in tile.contents)
			if(!isobserver(thing))
				qdel(thing)

		tile.baseturfs.Cut(3)

/// Do some magic teleport sparks
/obj/machinery/quantum_server/proc/spark_at_location(obj/crate)
	playsound(crate, 'sound/magic/blink.ogg', 50, TRUE)
	var/datum/effect_system/spark_spread/quantum/sparks = new()
	sparks.set_up(5, 1, get_turf(crate))
	sparks.start()

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/stop_domain()
	loading = TRUE

	SEND_SIGNAL(src, COMSIG_BITMINING_SEVER_AVATAR)

	scrub_vdom()

	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)

	cooling_off = TRUE
	addtimer(CALLBACK(src, PROC_REF(cool_off)), min(server_cooldown_time * server_cooldown_efficiency), TIMER_UNIQUE|TIMER_STOPPABLE)
	update_appearance()

	domain_randomized = FALSE
	retries_spent = 0
	loading = FALSE

#undef ONLY_TURF
#undef REDACTED
