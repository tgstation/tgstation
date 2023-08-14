/// Pulled verbatim from Daedalus Dock.

/// Keybind
/datum/keybinding/carbon/sprint
	hotkey_keys = list("Shift")
	name = "Sprint"
	full_name = "Sprint"
	description = "Run quickly, but burn stamina."
	keybind_signal = COMSIG_KB_CARBON_SPRINT_DOWN

/datum/keybinding/carbon/sprint/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.sprint_key_down = TRUE

/datum/keybinding/carbon/sprint/up(client/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(user.mob, COMSIG_KB_CARBON_SPRINT_UP)


/// Sprint dust
/obj/effect/sprint_dust
	icon = 'goon/icons/obj/effects.dmi'
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/effect/sprint_dust/proc/appear(state, dir, turf/T, duration)
	if(!T)
		return
	if(state == "sprint_cloud")
		src.dir = SOUTH
	src.dir ||= dir
	abstract_move(T)
	flick(state, src)
	addtimer(CALLBACK(src, /atom/movable/proc/moveToNullspace), duration)


/// Component
/datum/component/carbon_sprint
	var/mob/living/carbon/carbon_parent
	var/sprint_key_down = FALSE
	var/sprinting = FALSE
	var/sustained_moves = 0
	var/last_dust
	///Our very own dust
	var/obj/effect/sprint_dust/dust = new(null)

/datum/component/carbon_sprint/Destroy(force, silent)
	QDEL_NULL(dust)
	return ..()

/datum/component/carbon_sprint/RegisterWithParent()
	. = ..()
	carbon_parent = parent
	RegisterSignal(carbon_parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(onMobMove))
	RegisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_DOWN, PROC_REF(keyDown))
	RegisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_UP,  PROC_REF(keyUp))

/datum/component/carbon_sprint/UnregisterFromParent()
	. = ..()
	UnregisterSignal(carbon_parent, COMSIG_MOB_CLIENT_PRE_MOVE)
	UnregisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_DOWN)
	UnregisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_UP)

/datum/component/carbon_sprint/proc/onMobMove(datum/source, list/move_args)
	var/direct = move_args[MOVE_ARG_DIRECTION]
	if(SEND_SIGNAL(carbon_parent, COMSIG_CARBON_PRE_SPRINT) & INTERRUPT_SPRINT)
		if(sprinting)
			stopSprint()
		return
	var/turf/T = move_args[MOVE_ARG_NEW_LOC]
	if(!isturf(T))
		return
	if(!T.Enter(parent, TRUE))
		return

	if(sprint_key_down && !HAS_TRAIT(carbon_parent, TRAIT_NO_SPRINT))
		var/_step_size = (direct & (direct-1)) ? 1.4 : 1 //If we're moving diagonally, we're taking roughly 1.4x step size
		if(!sprinting)
			sprinting = TRUE
			carbon_parent.set_move_intent(MOVE_INTENT_SPRINT)
			dust.appear("sprint_cloud", direct, get_turf(carbon_parent), 0.6 SECONDS)
			last_dust = world.time
			sustained_moves += _step_size

		else if(world.time > last_dust + STAMINA_SUSTAINED_RUN_GRACE)
			if(direct & carbon_parent.last_move)
				if((sustained_moves < STAMINA_SUSTAINED_SPRINT_THRESHOLD) && ((sustained_moves + _step_size) >= STAMINA_SUSTAINED_SPRINT_THRESHOLD))
					dust.appear("sprint_cloud_small", direct, get_turf(carbon_parent), 0.4 SECONDS)
					last_dust = world.time
				sustained_moves += _step_size

			else
				if(sustained_moves >= STAMINA_SUSTAINED_SPRINT_THRESHOLD)
					dust.appear("sprint_cloud_small", direct, get_turf(carbon_parent), 0.4 SECONDS)
					last_dust = world.time
				if(direct & turn(carbon_parent.last_move, 180))
					dust.appear("sprint_cloud_tiny", direct, get_turf(carbon_parent), 0.3 SECONDS)
					last_dust = world.time
				sustained_moves = 0

		carbon_parent.stamina.adjust(-STAMINA_SPRINT_COST)

	else if(sprinting)
		stopSprint()

/datum/component/carbon_sprint/proc/keyDown()
	sprint_key_down = TRUE

/datum/component/carbon_sprint/proc/keyUp()
	sprint_key_down = FALSE

/datum/component/carbon_sprint/proc/stopSprint()
	sprinting = FALSE
	sustained_moves = FALSE
	last_dust = null
	carbon_parent.set_move_intent(MOVE_INTENT_RUN)
