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

	///The silo machine this container is connected to
	var/obj/machinery/ore_silo/silo
	///Material container. the value is either the silo or local
	var/datum/component/material_container/mat_container
	///Should we create a local storage if we can't connect to silo
	var/allow_standalone
	///Local size of container when silo = null
	var/local_size = INFINITY
	///Flags used for the local material container(exceptions for item insert & intent flags)
	var/mat_container_flags = NONE
	///List of signals to hook onto the local container
	var/list/mat_container_signals
	///Typecache for items that the silo will accept through this remote no matter what
	var/list/whitelist_typecache

/datum/component/remote_materials/Initialize(
	mapload,
	allow_standalone = TRUE,
	force_connect = FALSE,
	mat_container_flags = NONE,
	list/mat_container_signals = null,
	list/whitelist_typecache = null
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.allow_standalone = allow_standalone
	src.mat_container_flags = mat_container_flags
	src.mat_container_signals = mat_container_signals
	src.whitelist_typecache = whitelist_typecache

	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(OnMultitool))

	var/turf/T = get_turf(parent)
	var/connect_to_silo = FALSE
	if(force_connect || (mapload && is_station_level(T.z)))
		connect_to_silo = TRUE
		if(!(mat_container_flags & MATCONTAINER_NO_INSERT))
			RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, TYPE_PROC_REF(/datum/component/remote_materials, SiloAttackBy))

	if(mapload) // wait for silo to initialize during mapload
		addtimer(CALLBACK(src, PROC_REF(_PrepareStorage), connect_to_silo))
	else //directly register in round
		_PrepareStorage(connect_to_silo)

/**
 * Internal proc. prepares local storage if onnect_to_silo = FALSE
 *
 * Arguments
 * connect_to_silo- if true connect to global silo. If not successfull then go to local storage
 * only if allow_standalone = TRUE, else you a null mat_container
 */
/datum/component/remote_materials/proc/_PrepareStorage(connect_to_silo)
	PRIVATE_PROC(TRUE)

	if (connect_to_silo)
		silo = GLOB.ore_silo_default
		if (silo)
			silo.ore_connected_machines += src
			mat_container = silo.GetComponent(/datum/component/material_container)
	if (!mat_container && allow_standalone)
		_MakeLocal()

/datum/component/remote_materials/Destroy()
	if (silo)
		silo.ore_connected_machines -= src
		silo.holds -= src
		silo = null
		UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	mat_container = null
	return ..()

/datum/component/remote_materials/proc/_MakeLocal()
	PRIVATE_PROC(TRUE)

	silo = null

	mat_container = parent.AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		local_size, \
		mat_container_flags, \
		container_signals = mat_container_signals, \
		allowed_items = /obj/item/stack \
	)

	if (whitelist_typecache)
		mat_container.allowed_item_typecache |= whitelist_typecache

/datum/component/remote_materials/proc/toggle_holding(force_hold = FALSE)
	if(isnull(silo))
		return

	if(force_hold)
		silo.holds[src] = TRUE
	else if(!silo.holds[src])
		silo.holds[src] = TRUE
	else
		silo.holds -= src

/**
 * Sets the storage size for local materials when not linked with silo
 * Arguments
 *
 * * size - the new size for local storage. measured in SHEET_MATERIAL_SIZE units
 */
/datum/component/remote_materials/proc/set_local_size(size)
	local_size = size
	if (!silo && mat_container)
		mat_container.max_amount = size

/**
 * Disconnect this component from the remote silo
 *
 * Arguments
 * old_silo- The silo we are trying to disconnect from
 */
/datum/component/remote_materials/proc/disconnect_from(obj/machinery/ore_silo/old_silo)
	if (!old_silo || silo != old_silo)
		return
	silo.ore_connected_machines -= src
	silo = null
	mat_container = null
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	if (allow_standalone)
		_MakeLocal()

///Insert mats into silo
/datum/component/remote_materials/proc/SiloAttackBy(datum/source, obj/item/target, mob/living/user)
	SIGNAL_HANDLER

	//Allows you to attack the machine with iron sheets for e.g.
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return

	if(silo)
		mat_container.user_insert(target, user, parent, (whitelist_typecache && is_type_in_typecache(target, whitelist_typecache)))

	return COMPONENT_NO_AFTERATTACK

/datum/component/remote_materials/proc/OnMultitool(datum/source, mob/user, obj/item/multitool/M)
	SIGNAL_HANDLER

	. = NONE
	if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
		if (silo == M.buffer)
			to_chat(user, span_warning("[parent] is already connected to [silo]!"))
			return ITEM_INTERACT_BLOCKING
		if(!check_z_level(M.buffer))
			to_chat(user, span_warning("[parent] is too far away to get a connection signal!"))
			return ITEM_INTERACT_BLOCKING

		var/obj/machinery/ore_silo/new_silo = M.buffer
		var/datum/component/material_container/new_container = new_silo.GetComponent(/datum/component/material_container)
		if (silo)
			silo.ore_connected_machines -= src
			silo.holds -= src
		else if (mat_container)
			//transfer all mats to silo. whatever cannot be transfered is dumped out as sheets
			if(mat_container.total_amount())
				for(var/datum/material/mat as anything in mat_container.materials)
					var/mat_amount = mat_container.materials[mat]
					if(!mat_amount || !new_container.has_space(mat_amount) || !new_container.can_hold_material(mat))
						continue
					new_container.materials[mat] += mat_amount
					mat_container.materials[mat] = 0
			qdel(mat_container)
		silo = new_silo
		silo.ore_connected_machines += src
		mat_container = new_container
		if(!(mat_container_flags & MATCONTAINER_NO_INSERT))
			RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, TYPE_PROC_REF(/datum/component/remote_materials, SiloAttackBy))
		to_chat(user, span_notice("You connect [parent] to [silo] from the multitool's buffer."))
		return ITEM_INTERACT_SUCCESS

/**
 * Checks if the param silo is in the same level as this components parent i.e. connected machine, rcd, etc
 *
 * Arguments
 * silo_to_check- Is this components parent in the same Z level as this param silo. If null
 * then check this components connected silo
 *
 * Returns true if both are on the station or same z level
 */
/datum/component/remote_materials/proc/check_z_level(obj/silo_to_check = silo)
	if(isnull(silo_to_check))
		return FALSE

	return is_valid_z_level(get_turf(silo_to_check), get_turf(parent))

/// returns TRUE if this connection put on hold by the silo
/datum/component/remote_materials/proc/on_hold()
	return check_z_level() ? silo.holds[src] : FALSE

/**
 * Check if this connection can use any materials from the silo
 * Returns true only if
 * - The parent is of type movable atom
 * - A mat container is actually present
 * - The silo in not on hold
 * Arguments
 * * check_hold - should we check if the silo is on hold
 */
/datum/component/remote_materials/proc/can_use_resource(check_hold = TRUE)
	var/atom/movable/movable_parent = parent
	if (!istype(movable_parent))
		return FALSE
	if (!mat_container) //no silolink & local storage not supported
		movable_parent.say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if(check_hold && on_hold()) //silo on hold
		movable_parent.say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	return TRUE

/**
 * Use materials from either the silo(if connected) or from the local storage. If silo then this action
 * is logged else not e.g. action="build" & name="matter bin" means you are trying to build an matter bin
 *
 * Arguments
 * [mats][list]- list of materials to use
 * coefficient- each mat unit is scaled by this value then rounded. This value if usually your machine efficiency e.g. upgraded protolathe has reduced costs
 * multiplier- each mat unit is scaled by this value then rounded after it is scaled by coefficient. This value is your print quatity e.g. printing multiple items
 * action- For logging only. e.g. build, create, i.e. the action you are trying to perform
 * name- For logging only. the design you are trying to build e.g. matter bin, etc.
 */
/datum/component/remote_materials/proc/use_materials(list/mats, coefficient = 1, multiplier = 1, action = "build", name = "design")
	if(!can_use_resource())
		return 0

	var/amount_consumed = mat_container.use_materials(mats, coefficient, multiplier)

	if (silo)//log only if silo is linked
		var/list/scaled_mats = list()
		for(var/i in mats)
			scaled_mats[i] = OPTIMAL_COST(OPTIMAL_COST(mats[i] * coefficient) * multiplier)
		silo.silo_log(parent, action, -multiplier, name, scaled_mats)

	return amount_consumed

/**
 * Ejects the given material ref and logs it
 *
 * Arguments
 * [material_ref][datum/material]- The material type you are trying to eject
 * eject_amount- how many sheets to eject
 * [drop_target][atom]- optional where to drop the sheets. null means it is dropped at this components parent location
 */
/datum/component/remote_materials/proc/eject_sheets(datum/material/material_ref, eject_amount, atom/drop_target = null)
	if(!can_use_resource())
		return 0

	var/atom/movable/movable_parent = parent
	if(isnull(drop_target))
		drop_target = movable_parent.drop_location()

	return mat_container.retrieve_sheets(eject_amount, material_ref, target = drop_target, context = parent)

/**
 * Insert an item into the mat container, helper proc to insert items with the correct context
 *
 * Arguments
 * * obj/item/weapon - the item you are trying to insert
 * * multiplier - the multiplier applied on the materials consumed
 */
/datum/component/remote_materials/proc/insert_item(obj/item/weapon, multiplier = 1)
	if(!can_use_resource(FALSE))
		return MATERIAL_INSERT_ITEM_FAILURE

	return mat_container.insert_item(weapon, multiplier, parent)
