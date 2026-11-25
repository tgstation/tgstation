/**
 * ## Anomaly Locked Gun
 *
 * Prevents guns from being fired without having an anomaly core installed
 */
/datum/component/anomaly_locked_gun
	/// Reference to currently installed core
	VAR_PRIVATE/obj/item/assembly/signaler/anomaly/core
	/// List of anomaly core types that are accepted by this gun
	var/list/accepted_anomalies

/datum/component/anomaly_locked_gun/Initialize(list/accepted_anomalies, init_core = FALSE)
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	if(!length(accepted_anomalies))
		return COMPONENT_INCOMPATIBLE

	src.accepted_anomalies = accepted_anomalies

	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interact))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_destruction))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_GUN_CAN_SHOOT, PROC_REF(on_can_shoot))
	RegisterSignals(parent, list(COMSIG_GUN_TRY_FIRE, COMSIG_GUN_TRY_AUTO_FIRE), PROC_REF(on_try_fire))

	if(init_core)
		var/obj/item/the_gun = parent
		var/first_option = accepted_anomalies[1]
		core = new first_option(the_gun)
		the_gun.update_appearance()

/datum/component/anomaly_locked_gun/Destroy(force)
	QDEL_NULL(core)
	return ..()

/datum/component/anomaly_locked_gun/proc/on_item_interact(obj/item/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(!is_type_in_list(tool, accepted_anomalies))
		return NONE
	if(!isnull(core))
		source.balloon_alert(user, "already has core!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, source))
		return ITEM_INTERACT_BLOCKING

	playsound(source, 'sound/machines/click.ogg', 30, TRUE)
	core = tool
	source.balloon_alert(user, "core inserted")
	source.update_appearance()
	return ITEM_INTERACT_SUCCESS

/datum/component/anomaly_locked_gun/proc/on_screwdriver_act(obj/item/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER
	if(isnull(core))
		return NONE // allows for removing firing pins or whatever else
	if(DOING_INTERACTION_WITH_TARGET(user, source))
		return NONE // other interactions ongoing

	INVOKE_ASYNC(src, PROC_REF(try_remove_core), source, user, tool)
	return ITEM_INTERACT_SUCCESS

/datum/component/anomaly_locked_gun/proc/try_remove_core(obj/item/source, mob/living/user, obj/item/tool)
	source.balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, source))
		return
	source.balloon_alert(user, "core removed")
	user.put_in_hands(core)

/datum/component/anomaly_locked_gun/proc/on_exited(obj/item/source, atom/gone, ...)
	SIGNAL_HANDLER
	if(gone != core)
		return
	core = null
	if(QDELING(source))
		return
	source.update_appearance()

/datum/component/anomaly_locked_gun/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	if(!isnull(core))
		examine_list += span_notice("There is \a [core] installed in it. You could remove it with a <b>screwdriver</b>...")
		return

	var/list/core_list = list()
	for(var/atom/core_path as anything in accepted_anomalies)
		core_list += initial(core_path.name)
	examine_list += span_notice("You need to insert \a [english_list(core_list, and_text = " or ")] for this weapon to fire.")

/datum/component/anomaly_locked_gun/proc/on_destruction(obj/item/source)
	SIGNAL_HANDLER
	core?.forceMove(source.drop_location())

/// Hooks can_shoot to ensure we cover ALL cases where the gun may attempt to fire
/datum/component/anomaly_locked_gun/proc/on_can_shoot(obj/item/gun/source, ...)
	SIGNAL_HANDLER
	if(!isnull(core))
		return NONE
	return COMPONENT_CANCEL_GUN_FIRE

/// Hooks try_shoot to give a feedback when they try to fire (it runs before can_shoot, letting us be more specific)
/datum/component/anomaly_locked_gun/proc/on_try_fire(obj/item/gun/source, mob/living/shooter, ...)
	SIGNAL_HANDLER
	if(!isnull(core))
		return NONE
	source.balloon_alert(shooter, "cannot fire without a core!")
	source.shoot_with_empty_chamber(shooter)
	return COMPONENT_CANCEL_GUN_FIRE
