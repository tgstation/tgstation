/// Teleports interactors onto a safe turf randomly picked from a list of z-levels.
/datum/component/houlihan_teleport
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// Text that will appear in the alert prompt.
	var/question = "Travel back?"
	/// List of z-levels that the user can teleport to. By default, this is station z-levels.
	var/list/zlevels

/datum/component/houlihan_teleport/Initialize(question, zlevels)
	. = ..()
	if(!isstructure(parent))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(question) && (!istext(question) || !length(question)))
		stack_trace("received bad question argument, falling back to default")
		question = null
	src.question = question || initial(src.question)

	if(!isnull(zlevels) && (!islist(zlevels) || !length(zlevels)))
		stack_trace("received bad zlevels argument, falling back to default")
		zlevels = null
	src.zlevels = zlevels || SSmapping.levels_by_trait(ZTRAIT_STATION)

/datum/component/houlihan_teleport/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_ATTACK_ROBOT, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_ATOM_ATTACK_LARVA), PROC_REF(handle_generic_attack))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(handle_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))

/datum/component/houlihan_teleport/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_ROBOT, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_ATOM_ATTACK_LARVA, //handle_generic_attack
		COMSIG_ATOM_ATTACK_HAND, //handle_attack_hand
		COMSIG_ATOM_ATTACKBY, //handle_attackby
	))

/datum/component/houlihan_teleport/proc/get_me_outta_here(obj/structure/source, mob/living/user)
	var/said_yes = (tgui_alert(user, question, source.name, list("Yes", "No")) == "Yes")
	if(!said_yes || !source.Adjacent(user))
		return

	var/turf/destination_turf = zlevels ? find_safe_turf(zlevels) : get_safe_random_station_turf_equal_weight()
	if(!destination_turf)
		source.balloon_alert(user, "uh oh...")
		to_chat(user, span_warning("Nothing happens. You feel like this is a bad sign."))
		return

	var/turf/user_turf = get_turf(user)
	var/atom/movable/dragged = user.pulling
	user.forceMove(destination_turf)
	user_turf.balloon_alert_to_viewers("(pop)")
	if(dragged)
		var/turf/dragged_turf = get_turf(dragged)
		dragged.forceMove(destination_turf)
		user.start_pulling(dragged, force = TRUE)
		dragged_turf.balloon_alert_to_viewers("(pop)")

	to_chat(list(user, dragged), span_notice("You blink and find yourself in <b>[get_area_name(destination_turf)]</b>."))
	user.emote("blink")
	astype(dragged, /mob)?.emote("blink") // shhhhh just let it happen

/datum/component/houlihan_teleport/proc/handle_generic_attack(obj/structure/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER

	if(user.combat_mode)
		return NONE

	if(iscyborg(user) && !source.Adjacent(user))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(get_me_outta_here), source, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/houlihan_teleport/proc/handle_attack_hand(obj/structure/source, mob/user, list/modifiers)
	SIGNAL_HANDLER

	if(!isliving(user))
		return NONE

	var/mob/living/living_user = user
	if(living_user.combat_mode)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(get_me_outta_here), source, living_user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/houlihan_teleport/proc/handle_attackby(obj/structure/source, obj/item/item, mob/living/user, list/modifiers)
	SIGNAL_HANDLER

	if(user.combat_mode)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(get_me_outta_here), source, user)
	return COMPONENT_NO_AFTERATTACK
