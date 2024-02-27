/obj/item/machine_remote
	name = "machine wand"
	desc = "A remote for controlling machines and bots around the station."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "weakpoint_locator"
	inhand_icon_state = "weakpoint_locator"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
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
	if(!controlling_machine_or_bot)
		return
	if(controlling_machine_or_bot.ui_interact(user, ui))
		return
	controlling_machine_or_bot.interact(user) //no ui, interact instead (to open windoors and such)

/obj/item/machine_remote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(controlling_machine_or_bot)
		return controlling_machine_or_bot.ui_act(action, params, ui, state)

/obj/item/machine_remote/AltClick(mob/user)
	. = ..()
	if(moving_bug) //we have a bug in transit, so let's kill it.
		QDEL_NULL(moving_bug)
	if(!controlling_machine_or_bot)
		return
	say("Remote control over [controlling_machine_or_bot] stopped.")
	remove_old_machine()

/obj/item/machine_remote/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ismachinery(target) && !isbot(target))
		return
	if(moving_bug) //we have a bug in transit already, so let's kill it.
		QDEL_NULL(moving_bug)
	var/turf/spawning_turf = (controlling_machine_or_bot ? get_turf(controlling_machine_or_bot) : get_turf(src))
	moving_bug = new(spawning_turf, src, target)
	remove_old_machine()

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
	RegisterSignal(controlling_machine_or_bot, COMSIG_QDELETING, PROC_REF(on_control_destroy))
	controlling_machine_or_bot = new_machine
	controlling_machine_or_bot.add_overlay(bug_appearance)

///Removes the machine being controlled as the current machine, taking its signals and overlays with it.
/obj/item/machine_remote/proc/remove_old_machine()
	if(!controlling_machine_or_bot)
		return
	UnregisterSignal(controlling_machine_or_bot, COMSIG_QDELETING)
	controlling_machine_or_bot.cut_overlay(bug_appearance)
	controlling_machine_or_bot = null


///The effect of the bug moving towards the selected machinery to mess with.
/obj/effect/bug_moving
	name = "bug"
	desc = "Where da bug goin?"
	icon_state = "fly"
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
	var/datum/move_loop/loop = SSmove_manager.home_onto(src, thing_moving_towards, delay = 5, flags = MOVEMENT_LOOP_NO_DIR_UPDATE)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(reached_destination_check))
	RegisterSignal(thing_moving_towards, COMSIG_QDELETING, PROC_REF(on_machine_del))

/obj/effect/bug_moving/Destroy(force)
	if(controller)
		controller.moving_bug = null
		controller = null
	thing_moving_towards = null
	return ..()

/obj/effect/bug_moving/proc/reached_destination_check(datum/move_loop/source, result)
	SIGNAL_HANDLER
	if(!Adjacent(thing_moving_towards))
		return
	controller.set_controlled_machine(thing_moving_towards)
	qdel(src)

/obj/effect/bug_moving/proc/on_machine_del(datum/move_loop/source)
	SIGNAL_HANDLER
	qdel(src)
