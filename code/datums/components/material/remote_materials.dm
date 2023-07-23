/*
This component allows machines to connect remotely to a material container
(namely an /obj/machinery/ore_silo) elsewhere. It offers optional graceful
fallback to a local material storage in case remote storage is unavailable, and
handles linking back and forth.
*/

/datum/component/remote_materials
	// Three possible states:
	// 1. silo exists, materials is parented to silo
	// 2. silo is null, materials is parented to parent
	// 3. silo is null, materials is null

	/// The silo machine this container is connected to
	var/obj/machinery/ore_silo/silo
	//material container. the value is either the silo or local
	var/datum/component/material_container/mat_container
	//should we create a local storage if we can't connect to silo
	var/allow_standalone
	//are we trying to connect to the silo
	var/connecting
	//local size of container when silo = null
	var/local_size = INFINITY
	///Flags used when converting inserted materials into their component materials.
	var/mat_container_flags = NONE

/datum/component/remote_materials/Initialize(mapload, allow_standalone = TRUE, force_connect = FALSE, mat_container_flags = NONE)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.allow_standalone = allow_standalone
	src.mat_container_flags = mat_container_flags

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(OnAttackBy))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(OnMultitool))

	var/turf/T = get_turf(parent)
	if(force_connect || (mapload && is_station_level(T.z)))
		connecting = TRUE

/datum/component/remote_materials/RegisterWithParent()
	if (connecting)
		silo = GLOB.ore_silo_default
		if (silo)
			silo.ore_connected_machines += src
			mat_container = silo.GetComponent(/datum/component/material_container)
		connecting = FALSE
	if (!mat_container && allow_standalone)
		_MakeLocal()

/datum/component/remote_materials/Destroy()
	if (silo)
		silo.ore_connected_machines -= src
		silo.holds -= src
		silo.updateUsrDialog()
		silo = null
	mat_container = null
	return ..()

/datum/component/remote_materials/proc/_MakeLocal()
	silo = null

	var/static/list/allowed_mats = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
	)

	mat_container = parent.AddComponent( \
		/datum/component/material_container, \
		allowed_mats, \
		local_size, \
		mat_container_flags, \
		allowed_items = /obj/item/stack \
	)

/datum/component/remote_materials/proc/toggle_holding(force_hold = FALSE)
	if(isnull(silo))
		return

	if(force_hold)
		silo.holds[src] = TRUE
	else if(!silo.holds[src])
		silo.holds[src] = TRUE
	else
		silo.holds -= src

/datum/component/remote_materials/proc/set_local_size(size)
	local_size = size
	if (!silo && mat_container)
		mat_container.max_amount = size

// called if disconnected by ore silo UI or destruction
/datum/component/remote_materials/proc/disconnect_from(obj/machinery/ore_silo/old_silo)
	if (!old_silo || silo != old_silo)
		return
	silo.ore_connected_machines -= src
	silo = null
	mat_container = null
	if (allow_standalone)
		_MakeLocal()

/datum/component/remote_materials/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER

	if (silo && isstack(I))
		if (silo.remote_attackby(parent, user, I, mat_container_flags))
			return COMPONENT_NO_AFTERATTACK

/datum/component/remote_materials/proc/OnMultitool(datum/source, mob/user, obj/item/I)
	SIGNAL_HANDLER

	if(!I.multitool_check_buffer(user, I))
		return COMPONENT_BLOCK_TOOL_ATTACK
	var/obj/item/multitool/M = I
	if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
		if (silo == M.buffer)
			to_chat(user, span_warning("[parent] is already connected to [silo]!"))
			return COMPONENT_BLOCK_TOOL_ATTACK
		if(!check_z_level(M.buffer))
			to_chat(user, span_warning("[parent] is too far away to get a connection signal!"))
			return COMPONENT_BLOCK_TOOL_ATTACK
		if (silo)
			silo.ore_connected_machines -= src
			silo.holds -= src
			silo.updateUsrDialog()
		else if (mat_container)
			qdel(mat_container)
		silo = M.buffer
		silo.ore_connected_machines += src
		silo.updateUsrDialog()
		mat_container = silo.GetComponent(/datum/component/material_container)
		to_chat(user, span_notice("You connect [parent] to [silo] from the multitool's buffer."))
		return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/remote_materials/proc/check_z_level(obj/silo_to_check)
	SIGNAL_HANDLER
	if(!silo_to_check)
		if(isnull(silo))
			return FALSE
		silo_to_check = silo

	var/turf/current_turf = get_turf(parent)
	var/turf/silo_turf = get_turf(silo_to_check)
	if(!is_valid_z_level(silo_turf, current_turf))
		return FALSE
	return TRUE

/datum/component/remote_materials/proc/on_hold()
	if(!check_z_level())
		return FALSE
	return silo.holds[src]

/datum/component/remote_materials/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (silo)
		silo.silo_log(M || parent, action, amount, noun, mats)

/datum/component/remote_materials/proc/format_amount()
	if (mat_container)
		return "[mat_container.total_amount()] / [mat_container.max_amount == INFINITY ? "Unlimited" : mat_container.max_amount] ([silo ? "remote" : "local"])"
	else
		return "0 / 0"

/// Ejects the given material ref and logs it, or says out loud the problem.
/datum/component/remote_materials/proc/eject_sheets(datum/material/material_ref, eject_amount)
	var/atom/movable/movable_parent = parent
	if (!istype(movable_parent))
		return 0

	if (!mat_container)
		movable_parent.say("No access to material storage, please contact the quartermaster.")
		return 0
	if (on_hold())
		movable_parent.say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(eject_amount, material_ref, movable_parent.drop_location())
	var/list/matlist = list()
	matlist[material_ref] = eject_amount
	silo_log(parent, "ejected", -count, "sheets", matlist)
	return count
