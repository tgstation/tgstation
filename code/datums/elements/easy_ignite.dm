/// Creates a hotspot and deletes the owner atom upon being exposed to high temperatures, by Melbert
/datum/element/easy_ignite
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE // because turfs
	argument_hash_start_idx = 2
	/// Temp required for ignition
	var/required_temp = 480

/datum/element/easy_ignite/Attach(datum/target, required_temp = 480)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	src.required_temp = required_temp
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(attackby_react))
	RegisterSignal(target, COMSIG_ATOM_FIRE_ACT, PROC_REF(flame_react))
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(projectile_react))
	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(welder_react))
	if(isturf(target))
		RegisterSignal(target, COMSIG_TURF_EXPOSE, PROC_REF(hotspots_react))

/datum/element/easy_ignite/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ITEM_INTERACTION)
	UnregisterSignal(source, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(source, COMSIG_ATOM_BULLET_ACT)
	UnregisterSignal(source, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER))
	if(isturf(source))
		UnregisterSignal(source, COMSIG_TURF_EXPOSE)

/datum/element/easy_ignite/proc/ignite(atom/igniting, mob/user)
	var/delete_after = TRUE

	igniting.visible_message(span_warning("[igniting] catch[igniting.p_es()] fire!"), span_warning("You ignite into flames!"))
	new /obj/effect/hotspot(isturf(igniting) ? igniting : igniting.loc)

	if(isturf(igniting))
		var/turf/parent_turf = igniting
		parent_turf.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
		delete_after = FALSE

	// Logging-related
	var/log_message = "ignited [igniting]"
	if(user)
		user.log_message(log_message, LOG_ATTACK, log_globally = FALSE)//only individual log

	else
		log_message = "[key_name(user)] " + log_message + " by fire"
		log_attack(log_message)

	if(delete_after && !QDELETED(igniting))
		qdel(igniting)

/datum/element/easy_ignite/proc/flame_react(obj/item/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(exposed_temperature > required_temp)
		ignite(source)

/datum/element/easy_ignite/proc/hotspots_react(obj/item/source, air, exposed_temperature)
	SIGNAL_HANDLER

	if(exposed_temperature > required_temp)
		ignite(source)

/datum/element/easy_ignite/proc/attackby_react(obj/item/source, mob/user, obj/item/tool, modifiers)
	SIGNAL_HANDLER

	if(!tool.get_temperature())
		return NONE

	if (!item_ignition(source, tool, user))
		return ITEM_INTERACT_BLOCKING

	ignite(source, user)
	return ITEM_INTERACT_SUCCESS

/datum/element/easy_ignite/proc/projectile_react(obj/item/source, obj/projectile/shot)
	SIGNAL_HANDLER

	if(shot.damage_type == BURN && shot.damage > 0)
		ignite(source, shot.firer)

/datum/element/easy_ignite/proc/welder_react(obj/item/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(!tool.get_temperature())
		return NONE

	if (!item_ignition(source, tool, user))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/datum/element/easy_ignite/proc/item_ignition(obj/item/source, obj/item/tool, mob/user)
	if(tool.get_temperature() >= required_temp)
		source.visible_message(
			span_warning("[user] ignites [source] with [tool]!"),
			span_warning("You ignite [source] with [tool]!"),
		)
		ignite(source, user)
		return TRUE

	source.visible_message(
		span_warning("[user] tries to ignite [source] with [tool]!"),
		span_warning("You try to ignite [source] with [tool], but it's not hot enough!"),
	)
	return FALSE
