/**
 * ### Quantum CPU
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
	/// Current plugged in users
	var/list/datum/weakref/occupant_refs = list()
	/// The connected console
	var/obj/machinery/computer/quantum_console/console
	/// The currently generated level
	var/datum/space_level/generated_domain

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()
	if(!console)
		panic_find_console()

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
/obj/machinery/quantum_server/proc/generate_domain(datum/map_template/virtual_domain/to_generate)
	var/datum/space_level/loaded_map = to_generate.load_new_z()
	if(!loaded_map)
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	generated_domain = loaded_map
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
/obj/machinery/quantum_server/proc/set_domain(id)
	if(!id)
		balloon_alert(usr, "No domain specified.")
		return FALSE

	if(length(occupant_refs))
		balloon_alert(src, "Cannot change domain while server is occupied.")
		return FALSE

	var/datum/map_template/virtual_domain/to_generate
	for(var/datum/map_template/virtual_domain/available as anything in subtypesof(/datum/map_template/virtual_domain))
		if(id == initial(available.id))
			to_generate = new available
			break

	if(!to_generate || !generate_domain(to_generate))
		balloon_alert(usr, "Failed to generate domain.")
		return FALSE

	return TRUE

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/stop_domain()
	if(!generated_domain)
		return

	for(var/datum/weakref/user_ref in occupant_refs)
		var/mob/living/carbon/human/avatar/avatar = user_ref.resolve()

		if(avatar)
			avatar.disconnect()

	qdel(generated_domain)
