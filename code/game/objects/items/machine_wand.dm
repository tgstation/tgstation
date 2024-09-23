///When EMPed, how long the remote will be disabled for by default.
#define EMP_TIMEOUT_DURATION (2 MINUTES)

/obj/item/machine_remote
	name = "machine wand"
	desc = "A remote for controlling machines and bots around the station."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "weakpoint_locator"
	inhand_icon_state = "weakpoint_locator"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	///If we're unable to be used, this is how long we have left to wait.
	COOLDOWN_DECLARE(timeout_time)
	///The appearance put onto machines being actively controlled.
	var/mutable_appearance/bug_appearance
	///Direct reference to the moving bug effect that moves towards machines we direct it at.
	var/obj/effect/bug_moving/moving_bug
	///The machine that's currently being controlled.
	var/atom/movable/controlling_machine_or_bot

/obj/item/machine_remote/Initialize(mapload)
	. = ..()
	bug_appearance = mutable_appearance('icons/effects/effects.dmi', "fly-surrounding", ABOVE_WINDOW_LAYER)
	register_context()

/obj/item/machine_remote/equipped(mob/user, slot, initial)
	. = ..()
	if(user.get_active_held_item() == src)
		ADD_TRAIT(user, TRAIT_AI_ACCESS, HELD_ITEM_TRAIT)
		ADD_TRAIT(user, TRAIT_SILICON_ACCESS, HELD_ITEM_TRAIT)

/obj/item/machine_remote/dropped(mob/user, silent)
	. = ..()
	if(user.get_active_held_item() != src)
		REMOVE_TRAIT(user, TRAIT_AI_ACCESS, HELD_ITEM_TRAIT)
		REMOVE_TRAIT(user, TRAIT_SILICON_ACCESS, HELD_ITEM_TRAIT)

/obj/item/machine_remote/Destroy(force)
	. = ..()
	if(controlling_machine_or_bot)
		remove_old_machine()
	QDEL_NULL(moving_bug)
	QDEL_NULL(bug_appearance)

/obj/item/machine_remote/examine(mob/user)
	. = ..()
	if(controlling_machine_or_bot)
		. += span_notice("It is currently controlling [controlling_machine_or_bot]. Use in-hand to interact with it.")

/obj/item/machine_remote/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(controlling_machine_or_bot)
		context[SCREENTIP_CONTEXT_LMB] = "Use [controlling_machine_or_bot]"
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Flush Control"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/machine_remote/proc/on_control_destroy(obj/machinery/source)
	SIGNAL_HANDLER
	remove_old_machine()

/obj/item/machine_remote/ui_interact(mob/user, datum/tgui/ui)
	if(!COOLDOWN_FINISHED(src, timeout_time))
		playsound(src, 'sound/machines/synth/synth_no.ogg', 30 , TRUE)
		say("Remote control disabled temporarily. Please try again soon.")
		return FALSE
	if(!controlling_machine_or_bot)
		return
	if(controlling_machine_or_bot.ui_interact(user, ui))
		return
	controlling_machine_or_bot.interact(user) //no ui, interact instead (to open windoors and such)

/obj/item/machine_remote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(controlling_machine_or_bot)
		return controlling_machine_or_bot.ui_act(action, params, ui, state)

/obj/item/machine_remote/click_alt(mob/user)
	if(moving_bug) //we have a bug in transit, so let's kill it.
		QDEL_NULL(moving_bug)
		return CLICK_ACTION_BLOCKING
	if(!controlling_machine_or_bot)
		return CLICK_ACTION_BLOCKING
	say("Remote control over [controlling_machine_or_bot] stopped.")
	remove_old_machine()
	return CLICK_ACTION_SUCCESS

/obj/item/machine_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION) || (!ismachinery(interacting_with) && !isbot(interacting_with)))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/machine_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, timeout_time))
		playsound(src, 'sound/machines/synth/synth_no.ogg', 30 , TRUE)
		say("Remote control disabled temporarily. Please try again soon.")
		return ITEM_INTERACT_BLOCKING
	if(!ismachinery(interacting_with) && !isbot(interacting_with))
		return NONE
	if(moving_bug) //we have a bug in transit already, so let's kill it.
		QDEL_NULL(moving_bug)
	var/turf/spawning_turf = (controlling_machine_or_bot ? get_turf(controlling_machine_or_bot) : get_turf(src))
	moving_bug = new(spawning_turf, src, interacting_with)
	remove_old_machine()
	return ITEM_INTERACT_SUCCESS

///Sets a controlled machine to a new machine, if possible. Checks if AIs can even control it.
/obj/item/machine_remote/proc/set_controlled_machine(obj/machinery/new_machine)
	if(controlling_machine_or_bot == new_machine)
		return
	remove_old_machine()
	if(istype(new_machine, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/new_apc = new_machine
		if(new_apc.aidisabled)
			say("AI wire cut, machine uncontrollable.")
			return
	else if(istype(new_machine, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/new_airlock = new_machine
		if(!new_airlock.canAIControl())
			say("AI wire cut, machine uncontrollable.")
			return
	controlling_machine_or_bot = new_machine
	controlling_machine_or_bot.add_overlay(bug_appearance)
	RegisterSignal(controlling_machine_or_bot, COMSIG_QDELETING, PROC_REF(on_control_destroy))
	RegisterSignal(controlling_machine_or_bot, COMSIG_ATOM_EMP_ACT, PROC_REF(on_machine_emp))

///Removes the machine being controlled as the current machine, taking its signals and overlays with it.
/obj/item/machine_remote/proc/remove_old_machine()
	if(!controlling_machine_or_bot)
		return
	UnregisterSignal(controlling_machine_or_bot, list(COMSIG_ATOM_EMP_ACT, COMSIG_QDELETING))
	controlling_machine_or_bot.cut_overlay(bug_appearance)
	controlling_machine_or_bot = null

///Called when the machine we're controlling is EMP, removing our control from it.
/obj/item/machine_remote/proc/on_machine_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(severity & EMP_PROTECT_CONTENTS)
		return
	disable_remote(EMP_TIMEOUT_DURATION)

/obj/item/machine_remote/proc/disable_remote(timeout_duration)
	remove_old_machine()
	COOLDOWN_START(src, timeout_time, timeout_duration)

///The effect of the bug moving towards the selected machinery to mess with.
/obj/effect/bug_moving
	name = "bug"
	desc = "Where da bug goin?"
	icon_state = "fly"
	obj_flags = CAN_BE_HIT
	max_integrity = 20
	uses_integrity = TRUE
	plane = ABOVE_GAME_PLANE
	layer = FLY_LAYER
	movement_type = PHASING
	///The controller that's sending us out to the machine.
	var/obj/item/machine_remote/controller
	///The machine we are trying to get remote access to.
	var/atom/movable/thing_moving_towards

/obj/effect/bug_moving/Initialize(mapload, obj/item/machine_remote/controller, atom/movable/thing_moving_towards)
	. = ..()
	if(!controller)
		CRASH("a moving bug has been created by something that isn't a machine remote controller!")
	if(!thing_moving_towards)
		CRASH("a moving bug has been created but isn't moving towards anything!")
	src.controller = controller
	src.thing_moving_towards = thing_moving_towards
	var/datum/move_loop/loop = GLOB.move_manager.home_onto(src, thing_moving_towards, delay = 5, flags = MOVEMENT_LOOP_NO_DIR_UPDATE)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(reached_destination_check))
	RegisterSignal(thing_moving_towards, COMSIG_QDELETING, PROC_REF(on_machine_del))

/obj/effect/bug_moving/Destroy(force)
	if(controller)
		controller.moving_bug = null
		controller = null
	thing_moving_towards = null
	return ..()

/obj/effect/bug_moving/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	controller.disable_remote(EMP_TIMEOUT_DURATION)
	qdel(src)

/obj/effect/bug_moving/proc/reached_destination_check(datum/move_loop/source, result)
	SIGNAL_HANDLER
	if(!Adjacent(thing_moving_towards))
		return
	controller.set_controlled_machine(thing_moving_towards)
	qdel(src)

/obj/effect/bug_moving/proc/on_machine_del(datum/move_loop/source)
	SIGNAL_HANDLER
	qdel(src)

#undef EMP_TIMEOUT_DURATION
