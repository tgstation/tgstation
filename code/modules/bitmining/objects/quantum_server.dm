#define ONLY_TURF 1 // There should only ever be one turf at the bottom left of the map.
#define REDACTED "???"

/**
 * ### Quantum Server
 * Houses artificial realities. Interfaced by the console.
 * Destroying this causes brain damage to the occupants and deletes the level.
 */
/obj/machinery/quantum_server
	name = "quantum server"

	circuit = /obj/item/circuitboard/machine/quantum_server
	density = TRUE
	desc = "A hulking computational machine designed to fabricate virtual domains."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	/// The area type used as a reference to load templates
	var/area/preset_mapload_area = /area/station/virtual_domain/bottom_left
	/// The area type used as a reference to load the safehouse
	var/area/preset_safehouse_area = /area/station/virtual_domain/safehouse/bottom_left
	/// The area type used in vdom to send loot and mark completion
	var/area/preset_send_area = /area/station/virtual_domain/safehouse/send
	/// The area type used to delete objects in the vdom
	var/area/preset_delete_area = /area/station/virtual_domain/to_delete
	/// The area type to receive loot after a domain is completed
	var/area/receive_area = /area/station/bitminer_den/receive
	/// The loaded map template, map_template/virtual_domain
	var/datum/map_template/virtual_domain/generated_domain
	/// The loaded safehouse, map_template/safehouse
	var/datum/map_template/safehouse/generated_safehouse
	/// The generated z level to spawn other presets onto, datum/space_level
	var/datum/weakref/vdom_ref
	/// The connected console
	var/datum/weakref/console_ref
	/// If the current domain was a random selection
	var/domain_randomized = FALSE
	/// The amount to scale (and descale) mob health on connect/disconnect
	var/difficulty_coeff = 1.5
	/// Current plugged in users
	var/list/datum/weakref/occupant_mind_refs = list()
	/// Currently (un)loading a domain. Prevents multiple user actions.
	var/loading = FALSE
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Scanner tier
	var/scanner_tier = 1
	/// Server cooldown efficiency
	var/server_cooldown_efficiency = 1
	/// Length of time it takes for the server to cool down after despawning a map. Here to give miners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 2 MINUTES
	/// If the server is cooling down from a recent despawn
	COOLDOWN_DECLARE(cooling_off)
	/// This marks the starting point (bottom left) of the virtual dom map. We use this to spawn templates. Expected: 1
	var/turf/map_load_turf = list()
	/// This marks the starting point (bottom left) of the safehouse. We use this to spawn the safehouse. Expected: 1
	var/turf/safehouse_load_turf = list()
	/// The turfs on station where we generate loot.
	var/turf/receive_turfs = list()

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
		COMSIG_QDELETING
		),
		PROC_REF(on_broken)
	)
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_BITMINING_CLIENT_CONNECTED, PROC_REF(on_client_connected))
	RegisterSignal(src, COMSIG_BITMINING_CLIENT_DISCONNECTED, PROC_REF(on_client_disconnected))
	RefreshParts()

/obj/machinery/quantum_server/Destroy(force)
	. = ..()
	occupant_mind_refs.Cut()
	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)

/obj/machinery/quantum_server/attackby(obj/item/tool, mob/user, params)
	var/icon_closed = initial(icon_state)
	var/icon_open = "[initial(icon_state)]_o"
	if(!(machine_stat & (BROKEN|NOPOWER)))
		icon_closed = "[initial(icon_state)]_off"
		icon_open = "[initial(icon_state)]_o_off"

	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, tool))
		return
	// Using a multitool lets you access the receiver's interface
	else if(tool.tool_behaviour == TOOL_MULTITOOL)
		attack_hand(user)

	else if(default_deconstruction_crowbar(tool))
		return
	else
		return ..()

/obj/machinery/quantum_server/RefreshParts()
	. = ..()
	var/total_rating = 1.2

	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		total_rating -= capacitor.tier * 0.1

	server_cooldown_efficiency = max(total_rating, 0)

	var/datum/stock_part/scanning_module/scanner = locate(/datum/stock_part/scanning_module) in component_parts
	if(scanner)
		scanner_tier = scanner.tier

/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(occupant_mind_refs))
		stop_domain(user)
		return

	balloon_alert(user, "notifying clients...")
	SEND_SIGNAL(src, COMSIG_BITMINING_SHUTDOWN_ALERT, src)

	if(!do_after(user, 15 SECONDS, src))
		return

	stop_domain(user)

/// Checks if there is a loot crate in the designated send areas (2x2)
/obj/machinery/quantum_server/proc/check_completion(mob/user)
	if(isnull(generated_domain))
		return FALSE

	var/datum/space_level/vdom = vdom_ref?.resolve()
	if(isnull(vdom))
		return FALSE

	var/turf/send_turfs = get_area_turfs(preset_send_area, vdom.z_value)
	if(!length(send_turfs))
		CRASH("Failed to find send turfs in the virtual domain.")

	for(var/turf/tile in send_turfs)
		if(locate(/obj/structure/closet/crate/secure/bitminer_loot/encrypted) in tile)
			return TRUE

	user.playsound_local(src, 'sound/machines/buzz-two.ogg', 30, 2)
	balloon_alert(user, "no loot crate found.")

	return FALSE

/**
 * ### Quantum Server Cold Boot
 * Procedurally links the 3 booting processes together.
 *
 * This is the starting point if you have an id. Does validation and feedback on steps
 */
/obj/machinery/quantum_server/proc/cold_boot_map(mob/user, map_id)
	if(!get_ready_status())
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

	var/datum/map_template/virtual_domain/to_generate = set_domain(map_id)
	if(isnull(to_generate))
		balloon_alert(user, "invalid domain specified.")
		loading = FALSE
		return FALSE

	points -= to_generate.cost
	if(points < 0)
		balloon_alert(user, "not enough points.")
		loading = FALSE
		return FALSE

	var/datum/space_level/loaded_zlevel = vdom_ref?.resolve()
	if(isnull(loaded_zlevel) && !initialize_virtual_domain())
		loading = FALSE
		return FALSE

	if(!load_domain(to_generate))
		loading = FALSE
		return FALSE

	loading = FALSE
	balloon_alert(user, "virtual domain generated.")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)

	return TRUE

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

	return

/// Generates a reward based on the given domain
/obj/machinery/quantum_server/proc/generate_loot(mob/user)
	if(isnull(generated_domain))
		return FALSE

	if(length(occupant_mind_refs))
		balloon_alert(user, "all clients must disconnect!")
		return FALSE

	if(!length(receive_turfs))
		receive_turfs = get_area_turfs(receive_area)
	if(!length(receive_turfs))
		CRASH("Failed to find receive turfs on the station.")

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, 2)

	var/turf/to_spawn = pick(receive_turfs)
	if(isnull(to_spawn))
		CRASH("Failed to find a turf to spawn loot crate on.")

	new /obj/structure/closet/crate/secure/bitminer_loot/decrypted(to_spawn, generated_domain)
	return TRUE

/// If there are hosted minds, attempts to get a list of their current virtual bodies w/ vitals
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/mind_ref in occupant_mind_refs)
		var/datum/mind/this_mind = mind_ref.resolve()
		if(isnull(this_mind))
			occupant_mind_refs -= this_mind

		var/mob/living/creature = this_mind.current
		var/mob/living/pilot = this_mind.pilot_ref?.resolve()

		hosted_avatars += list(list(
			"health" = creature.health,
			"name" = creature.name,
			"pilot" = pilot,
		))

	return hosted_avatars

/// Compiles a list of available domains.
/obj/machinery/quantum_server/proc/get_available_domains()
	var/list/levels = list()

	for(var/datum/map_template/virtual_domain/domain as anything in subtypesof(/datum/map_template/virtual_domain))
		if(initial(domain.test_only))
			continue
		var/can_view = initial(domain.difficulty) <= scanner_tier
		var/can_view_reward = initial(domain.difficulty) <= (scanner_tier + 1)

		levels += list(list(
			"cost" = initial(domain.cost),
			"desc" = can_view ? initial(domain.desc) : "Limited scanning capabilities. Cannot infer domain details.",
			"difficulty" = initial(domain.difficulty),
			"id" = initial(domain.id),
			"name" = can_view ? initial(domain.name) : REDACTED,
			"reward" = can_view_reward ? initial(domain.reward_points) : REDACTED,
		))

	return levels

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
		if(!initial(available.test_only) && init_cost > 0 && init_cost <= points)
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

	return

/// Returns if the server is busy via loading or cooldown states
/obj/machinery/quantum_server/proc/get_ready_status()
	return !loading && COOLDOWN_FINISHED(src, cooling_off)

/// Gets all mobs originally generated by the loaded domain and returns a list that are capable of being antagged
/obj/machinery/quantum_server/proc/get_valid_domain_targets()
	if(!length(occupant_mind_refs))
		return

	if(isnull(generated_domain))
		return

	var/list/mutation_candidates = list()
	for(var/mob/living/creature as anything in generated_domain.created_atoms)
		if(QDELETED(creature) || !isliving(creature) || creature.key)
			continue

		mutation_candidates += creature

	return mutation_candidates

/// Generates a new virtual domain
/obj/machinery/quantum_server/proc/initialize_virtual_domain()
	var/datum/map_template/virtual_domain/base_map = new()
	var/datum/space_level/loaded_zlevel = base_map.load_new_z()

	if(isnull(loaded_zlevel))
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	vdom_ref = WEAKREF(loaded_zlevel)

	map_load_turf = get_area_turfs(preset_mapload_area, loaded_zlevel.z_value)
	safehouse_load_turf = get_area_turfs(preset_safehouse_area, loaded_zlevel.z_value)

	return TRUE

/// Validates target mob as valid to buff/nerf
/obj/machinery/quantum_server/proc/is_valid_mob(mob/living/creature)
	return isliving(creature) && isnull(creature.key) && creature.stat != DEAD && creature.health > 10

/// Loads the safehouse and given domain into the virtual domain
/obj/machinery/quantum_server/proc/load_domain(datum/map_template/virtual_domain/to_generate)
	var/datum/map_template/safehouse/safehouse = new to_generate.safehouse_path
	// We need to reload the safehouse so things don't carry over
	safehouse.load(safehouse_load_turf[ONLY_TURF])
	to_generate.load(map_load_turf[ONLY_TURF])

	generated_domain = to_generate
	generated_safehouse = safehouse

	return TRUE

/// If broken via signal, disconnects all users
/obj/machinery/quantum_server/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(stop_domain))


/// Each time someone connects, mob health jumps 1.5x
/obj/machinery/quantum_server/proc/on_client_connected(datum/source, datum/weakref/new_mind)
	SIGNAL_HANDLER

	occupant_mind_refs += new_mind
	if(length(occupant_mind_refs) == 1)
		return

	for(var/mob/living/creature as anything in generated_domain.created_atoms)
		if(is_valid_mob(creature))
			creature.health *= difficulty_coeff
			creature.maxHealth *= difficulty_coeff

/// If a client disconnects, remove them from the list & nerf mobs
/obj/machinery/quantum_server/proc/on_client_disconnected(datum/source, datum/weakref/old_mind)
	SIGNAL_HANDLER

	occupant_mind_refs -= old_mind
	if(length(occupant_mind_refs) == 0)
		return

	for(var/mob/living/creature as anything in generated_domain.created_atoms)
		if(is_valid_mob(creature))
			creature.health /= difficulty_coeff
			creature.maxHealth /= difficulty_coeff


/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(get_ready_status())
		return

	examine_text += span_notice("It is currently cooling down. Give it a few moments.")
	if(server_cooldown_efficiency < 1)
		examine_text += span_notice("Its coolant capacity reduces cooldown time by [(1 - server_cooldown_efficiency) * 100]%.")

/// Sets the current virtual domain to the given map template
/obj/machinery/quantum_server/proc/set_domain(map_id)
	var/datum/map_template/virtual_domain/to_generate
	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		if(map_id == initial(available.id) && initial(available.cost) <= points)
			to_generate = new available
			if(domain_randomized)
				to_generate.reward_points += 1
			break

	return to_generate

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/stop_domain(mob/user)
	if(user) // Sometimes called by on_broken()
		balloon_alert(user, "powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, 2)

	loading = TRUE
	domain_randomized = FALSE
	SEND_SIGNAL(src, COMSIG_BITMINING_SERVER_CRASH)
	COOLDOWN_START(src, cooling_off, min(server_cooldown_time * server_cooldown_efficiency))

	var/datum/space_level/vdom = vdom_ref?.resolve()
	if(isnull(vdom))
		loading = FALSE
		return

	var/datum/map_template/virtual_domain/fresh_map = new()
	fresh_map.load(map_load_turf[ONLY_TURF])

	for(var/turf/tile in get_area_turfs(preset_delete_area, vdom.z_value))
		for(var/thing in tile.contents)
			if(!isobserver(thing))
				qdel(thing)

	for(var/turf/tile in safehouse_load_turf)
		for(var/thing in tile.contents)
			if(!isobserver(thing))
				qdel(thing)

	generated_domain = null
	generated_safehouse = null
	loading = FALSE

#undef ONLY_TURF
#undef REDACTED
