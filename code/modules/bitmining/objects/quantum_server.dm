#define ONLY_TURF 1 // There should only ever be one turf at the bottom left of the map.

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
	var/area/preset_mapload_area = /area/station/virtual_domain/generate_point
	/// The area type used as a reference to load the safehouse
	var/area/preset_safehouse_area = /area/station/virtual_domain/safehouse/generate_point
	/// The area type used in vdom to send loot and mark completion
	var/area/preset_send_area = /area/station/virtual_domain/safehouse/send
	/// The area type to receive loot after a domain is completed
	var/area/receive_area = /area/station/bitminer_den/receive
	/// The loaded template
	var/datum/map_template/virtual_domain/generated_domain
	/// The loaded safehouse
	var/datum/map_template/safehouse/generated_safehouse
	/// The generated base level to spawn other presets into
	var/datum/space_level/vdom
	/// Currently (un)loading a domain. Prevents multiple user actions.
	var/loading = FALSE
	/// Currently plugged in avatars
	var/list/datum/weakref/avatar_refs = list()
	/// Current plugged in users
	var/list/datum/weakref/occupant_refs = list()
	/// The connected console
	var/obj/machinery/computer/quantum_console/console
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Scanner tier
	var/scanner_tier = 1
	/// Length of time it takes for the server to cool down after despawning a map. Here to give miners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 2 MINUTES
	/// Server cooldown efficiency
	var/server_cooldown_efficiency = 1
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
	RegisterSignals(src, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(stop_domain), usr, TRUE)
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(mapload)
		RefreshParts()

/obj/machinery/quantum_server/Destroy(force)
	. = ..()
	SEND_SIGNAL(src, COMSIG_QSERVER_DISCONNECT)
	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)
	QDEL_NULL(vdom)
	occupant_refs.Cut()
	avatar_refs.Cut()

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

/// Checks if there is a loot crate in the designated send areas (2x2)
/obj/machinery/quantum_server/proc/check_completion(mob/user)
	if(!generated_domain)
		return FALSE

	var/turf/send_turfs = get_area_turfs(preset_send_area, vdom.z_value)
	if(!length(send_turfs))
		CRASH("Failed to find send turfs in the virtual domain.")

	for(var/turf/tile in send_turfs)
		if(locate(/obj/structure/closet/crate/secure/bitminer_loot/encrypted) in tile)
			return TRUE

	return FALSE

/// Generates a reward based on the given domain
/obj/machinery/quantum_server/proc/generate_loot(mob/user)
	if(!generated_domain)
		return FALSE

	if(length(occupant_refs))
		balloon_alert(user, "all clients must disconnect!")
		return FALSE

	if(!length(receive_turfs))
		receive_turfs = get_area_turfs(receive_area)
	if(!length(receive_turfs))
		CRASH("Failed to find receive turfs on the station.")

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, 2)

	var/turf/to_spawn = pick(receive_turfs)
	if(!to_spawn)
		CRASH("Failed to find a turf to spawn loot crate on.")

	new /obj/structure/closet/crate/secure/bitminer_loot/decrypted(to_spawn, generated_domain)
	return TRUE

/// Generates a new virtual domain
/obj/machinery/quantum_server/proc/generate_virtual_domain(mob/user)
	if(!console && !panic_find_console())
		balloon_alert(user, "error: no console found.")
		return FALSE

	if(loading)
		balloon_alert(user, "error: please wait...")
		return FALSE

	balloon_alert(user, "initializing virtual domain...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)
	loading = TRUE

	var/datum/map_template/virtual_domain/base_zone = new()
	var/datum/space_level/loaded_map = base_zone.load_new_z()
	if(!loaded_map)
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	vdom = loaded_map

	if(!length(map_load_turf))
		map_load_turf = get_area_turfs(preset_mapload_area, vdom.z_value)

	if(!length(safehouse_load_turf))
		safehouse_load_turf = get_area_turfs(preset_safehouse_area, vdom.z_value)

	loading = FALSE

	return TRUE

/// Returns a list of occupant data if the refs are still valid
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/avatar_ref in avatar_refs)
		var/mob/living/carbon/human/avatar/avatar = avatar_ref.resolve()
		if(!avatar)
			avatar_refs -= avatar_ref
			continue

		hosted_avatars += list(list(
			"health" = avatar.health,
			"name" = avatar.name,
			"pilot" = avatar.pilot,
		))

	return hosted_avatars

/// Returns if the server is busy via loading or cooldown states
/obj/machinery/quantum_server/proc/get_ready_status()
	return !loading && COOLDOWN_FINISHED(src, cooling_off)

/// Generates the virtual template around the safehouse
/obj/machinery/quantum_server/proc/load_domain(mob/user, datum/map_template/virtual_domain/to_generate)
	if(!to_generate || !get_ready_status())
		return FALSE

	if(!vdom)
		generate_virtual_domain(user)

	loading = TRUE

	var/datum/map_template/safehouse/safehouse = new to_generate.safehouse_path
	// We need to reload the safehouse so things don't carry over
	safehouse.load(safehouse_load_turf[ONLY_TURF])
	to_generate.load(map_load_turf[ONLY_TURF])

	generated_domain = to_generate
	generated_safehouse = safehouse
	balloon_alert(user, "virtual domain generated.")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)
	loading = FALSE

	return TRUE

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(get_ready_status())
		return

	examine_text += span_notice("It is currently cooling down. Give it a few moments.")
	if(server_cooldown_efficiency < 1)
		examine_text += span_notice("Its coolant capacity reduces cooldown time by [(1 - server_cooldown_efficiency) * 100]%.")

/// Attempts to connect to a quantum console
/obj/machinery/quantum_server/proc/panic_find_console()
	for(var/obj/machinery/computer/quantum_console/console as anything in oview(7))
		if(!istype(console, /obj/machinery/computer/quantum_console))
			continue
		src.console = console
		console.server = src
		return TRUE

	return FALSE

/// Sets the current virtual domain to the given map template
/obj/machinery/quantum_server/proc/set_domain(mob/user, id)
	if(!id)
		balloon_alert(user, "no domain specified.")
		return FALSE

	if(length(occupant_refs))
		balloon_alert(user, "error: connected clients!")
		return FALSE

	loading = TRUE

	var/datum/map_template/virtual_domain/to_generate
	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		if(id == initial(available.id) && initial(available.cost) <= points)
			to_generate = new available
			break

	loading = FALSE

	if(!to_generate)
		balloon_alert(user, "invalid domain specified.")
		return FALSE

	stop_domain(user)

	points -= to_generate.cost

	if(points < 0 || !load_domain(user, to_generate))
		balloon_alert(user, "failed to generate domain.")
		return FALSE

	return TRUE

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/stop_domain(mob/user, force = FALSE)
	set waitfor = FALSE
	if(!generated_domain)
		return

	if(!force)
		balloon_alert(user, "powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 30, 2)

	loading = TRUE
	SEND_SIGNAL(src, COMSIG_QSERVER_DISCONNECT)
	COOLDOWN_START(src, cooling_off, min(server_cooldown_time * server_cooldown_efficiency))

	generated_domain.clear_atoms()
	generated_domain = null

	generated_safehouse.clear_atoms()
	generated_safehouse = null

	for(var/datum/weakref/avatar_ref in avatar_refs)
		var/mob/living/carbon/human/avatar/avatar = avatar_ref.resolve()
		avatar_refs -= avatar_ref
		if(!avatar)
			continue
		qdel(avatar)

	loading = FALSE

#undef ONLY_TURF
