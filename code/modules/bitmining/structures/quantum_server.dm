#define BOTTOM_LEFT 1

/**
 * ### Quantum Server
 * Houses artificial realities. Interfaced by the console.
 * Destroying this causes brain damage to the occupants and deletes the level.
 */
/obj/machinery/quantum_server
	name = "quantum server"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	desc = "A hulking computational machine designed to fabricate virtual domains."
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 3
	/// The area type for safehouse surroundting tiles
	var/area/domain_biome_area = /area/station/virtual_domain/outside
	/// The area type to spawn a presets into
	var/area/domain_generation_area = /area/station/virtual_domain/generated
	/// The loaded domain preset
	var/datum/map_template/virtual_domain/generated_domain
	/// The generated base level to spawn other presets into
	var/datum/space_level/vdom
	/// Current plugged in users
	var/list/datum/weakref/occupant_refs = list()
	/// The connected console
	var/obj/machinery/computer/quantum_console/console
	/// Turfs to replace with the generated domain
	var/turf/available_turfs = list()
	/// "Safe" turfs surrounding the safehouse
	var/turf/biome_turfs = list()

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()
	if(!console)
		panic_find_console()

	RegisterSignals(src, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(stop_domain))


/obj/machinery/quantum_server/Destroy(force)
	. = ..()
	stop_domain()

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

/// Generates a new virtual domain
/obj/machinery/quantum_server/proc/generate_virtual_domain(mob/user)
	balloon_alert(user, "initializing virtual domain...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	var/datum/map_template/virtual_domain/base_zone = new()
	var/datum/space_level/loaded_map = base_zone.load_new_z()
	if(!loaded_map)
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	vdom = loaded_map
	if(!length(available_turfs))
		available_turfs = get_area_turfs(domain_generation_area, vdom.z_value)
	if(!length(biome_turfs))
		biome_turfs = get_area_turfs(domain_biome_area, vdom.z_value)

	return TRUE

/// Returns a list of occupant data if the refs are still valid
/obj/machinery/quantum_server/proc/get_occupant_data()
	var/list/occupants = list()

	for(var/datum/weakref/user_ref in occupants)
		var/mob/living/carbon/human/avatar/avatar = user_ref.resolve()
		if(!avatar)
			occupant_refs -= user_ref
			continue

		occupants += list(list(
			"health" = avatar.health,
			"name" = avatar.name,
		))

	return occupants

/// Generates the virtual template around the safehouse
/obj/machinery/quantum_server/proc/load_domain(mob/user, datum/map_template/virtual_domain/to_generate)
	if(!to_generate)
		return FALSE

	if(!vdom)
		generate_virtual_domain(user)

	for(var/turf/open/to_replace in available_turfs)
		to_replace.ChangeTurf(to_generate.biome_turf)

	to_generate.load(available_turfs[BOTTOM_LEFT])

	for(var/turf/open/to_replace in biome_turfs)
		to_replace.ChangeTurf(to_generate.biome_turf)

	generated_domain = to_generate
	balloon_alert(user, "virtual domain generated.")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)

	return TRUE

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

	var/datum/map_template/virtual_domain/to_generate
	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		if(id == initial(available.id))
			to_generate = new available
			break

	if(!load_domain(user, to_generate))
		balloon_alert(user, "failed to generate domain.")
		return FALSE

	return TRUE

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/stop_domain()
	if(!generated_domain)
		return

	SEND_SIGNAL(COMSIG_QSERVER_DISCONNECT)

	qdel(generated_domain)

#undef BOTTOM_LEFT
