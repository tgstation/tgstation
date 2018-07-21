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
	var/obj/machinery/ore_silo/silo
	var/datum/component/material_container/mat_container
	var/category

/datum/component/remote_materials/Initialize(category, mapload, allow_standalone = TRUE, force_connect = FALSE)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.category = category

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)

	var/turf/T = get_turf(parent)
	if (force_connect || (mapload && is_station_level(T.z)))
		addtimer(CALLBACK(src, .proc/LateInitialize))
	// TODO: create local storage otherwise

/datum/component/remote_materials/proc/LateInitialize()
	silo = GLOB.ore_silo_default
	if (silo)
		silo.connected += src
		mat_container = silo.GetComponent(/datum/component/material_container)
	// TODO: create local storage otherwise

/datum/component/remote_materials/Destroy()
	if (silo)
		silo.connected -= src
		silo.updateUsrDialog()
		silo = null
		mat_container = null
	else if (mat_container)
		mat_container.retrieve_all()
	return ..()

// called if disconnected by ore silo UI or destruction
/datum/component/remote_materials/proc/disconnect_from(obj/machinery/ore_silo/old_silo)
	if (!old_silo || silo != old_silo)
		return
	silo = null
	mat_container = null
	// TODO: revert to local storage if set

/datum/component/remote_materials/proc/OnAttackBy(obj/item/I, mob/user)
	if (istype(I, /obj/item/multitool))
		var/obj/item/multitool/M = I
		if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
			if (silo)
				silo.connected -= src
			silo = M.buffer
			silo.connected += src
			silo.updateUsrDialog()
			mat_container = silo.GetComponent(/datum/component/material_container)
			to_chat(user, "<span class='notice'>You connect [parent] to [silo] from the multitool's buffer.</span>")
			return COMPONENT_NO_AFTERATTACK

	else if (silo && istype(I, /obj/item/stack))
		if (silo.remote_attackby(parent, user, I))
			return COMPONENT_NO_AFTERATTACK

/datum/component/remote_materials/proc/on_hold()
	return silo && silo.holds["[get_area(parent)]/[category]"]

/datum/component/remote_materials/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (silo)
		silo.silo_log(M || parent, action, amount, noun, mats)

/datum/component/remote_materials/proc/format_amount()
	if (mat_container)
		return "[mat_container.total_amount] / [mat_container.max_amount == INFINITY ? "Unlimited" : mat_container.max_amount]"

/datum/component/remote_materials/proc/eject_sheets(eject_amt, eject_sheet)
	if (!mat_container)
		return 0

	var/atom/P = parent
	var/count = mat_container.retrieve_sheets(eject_amt, eject_sheet, P.drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
	silo_log(src, "ejected", -count, "sheets", matlist)
	return count
