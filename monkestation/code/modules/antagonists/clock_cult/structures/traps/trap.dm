//might be able to refactor these into mech comp stuff
//Thing that you stick on the floor
/obj/item/clockwork/trap_placer
	name = "trap"
	desc = "don't trust it"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	w_class = WEIGHT_CLASS_HUGE
	/// The path of the trap to make when this is set down
	var/result_path = /obj/structure/destructible/clockwork/trap


/obj/item/clockwork/trap_placer/attack_self(mob/user)
	. = ..()
	if(!IS_CLOCK(user))
		return

	if(user.loc != get_turf(src))
		return

	place_trap(get_turf(src), user)

/obj/item/clockwork/trap_placer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!IS_CLOCK(user) || !isturf(target) || !proximity_flag)
		return

	place_trap(target, user)


/obj/item/clockwork/trap_placer/proc/place_trap(atom/target, mob/user)
	for(var/obj/structure/destructible/clockwork/trap/trap in target) // No 50-spear instakills please

		if(!istype(trap, result_path))
			continue

		user.balloon_alert(user, "space occupied!")
		return

	to_chat(user, span_brass("You place [src], use a <b>clockwork slab</b> to link it to other traps."))
	var/obj/new_obj = new result_path(target)
	new_obj.setDir(user.dir)

	qdel(src)

//Thing you stick on the wall
/obj/item/wallframe/clocktrap
	name = "clockwork trap item"
	desc = "It's a... Wait what?"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	pixel_shift = 24
	w_class = WEIGHT_CLASS_HUGE
	result_path = /obj/structure/destructible/clockwork/trap
	/// What to show the user if they are a clock cultist
	var/clockwork_desc = "It seems to be able to be placed on walls."


/obj/item/wallframe/clocktrap/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_description, clockwork_desc)


//Wall item (either spawned by a wallframe or directly)
/obj/structure/destructible/clockwork/trap
	name = "clockwork trap item"
	desc = "Probably doesn't do much."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	density = FALSE
	layer = LOW_OBJ_LAYER
	break_message = span_warning("The intricate looking device falls apart.")
	/// What item's produced when this structure is unwrenched
	var/unwrench_path = /obj/item/wallframe/clocktrap
	/// The component used for the trap's back-end
	var/component_datum = /datum/component/clockwork_trap


/obj/structure/destructible/clockwork/trap/Initialize(mapload)
	. = ..()
	AddComponent(component_datum)


/obj/structure/destructible/clockwork/trap/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	balloon_alert(user, "unwrenching...")

	if(!do_after(user, 5 SECONDS, target = src))
		return

	balloon_alert(user, "detached [src]")
	new unwrench_path(get_turf(src))

	qdel(src)


//Component
/datum/component/clockwork_trap
	/// A list of traps this sends a signal to when this is triggered
	var/list/outputs = list()
	/// If this sends input (e.g. pressure plate)
	var/sends_input = FALSE
	/// If this takes input (e.g. skewer)
	var/takes_input = FALSE


/datum/component/clockwork_trap/Initialize()
	. = ..()

	if(!istype(parent, /obj/structure/destructible/clockwork))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_CLOCKWORK_SIGNAL_RECEIVED, PROC_REF(trigger))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))


/// Adds an input device to our own `outputs` list, to be sent when it triggers
/datum/component/clockwork_trap/proc/add_input(datum/component/clockwork_trap/input)
	outputs |= input.parent


/// Adds this as an output to the targeted component's `outputs` list
/datum/component/clockwork_trap/proc/add_output(datum/component/clockwork_trap/output)
	output.outputs |= parent


/// Signal proc for when the trap calls CLOCKWORK_SIGNAL_RECEIVED
/datum/component/clockwork_trap/proc/trigger()
	SIGNAL_HANDLER

	return TRUE


/// Signal proc for when the trap has ATOM_ATTACK_HAND called on it
/datum/component/clockwork_trap/proc/attack_hand(mob/user)
	SIGNAL_HANDLER

	return

/// Signal proc when the trap has PARENT_ATTACKBY called on it
/datum/component/clockwork_trap/proc/on_attackby(datum/source, obj/item/attack_item, mob/user)
	SIGNAL_HANDLER

	if(!IS_CLOCK(user) || !istype(attack_item, /obj/item/clockwork/clockwork_slab))
		return

	var/obj/item/clockwork/clockwork_slab/slab = attack_item

	if(slab.buffer)

		if(takes_input)
			to_chat(user, span_brass("You connect [slab.buffer.parent] to [parent]."))
			add_output(slab.buffer)
			slab.buffer = null

		else
			to_chat(user, span_brass("That device does not accept input."))

	else

		if(sends_input)
			to_chat(user, span_brass("You prepare to connect [parent] with other devices."))
			slab.buffer = src

		else

			to_chat(user, span_brass("That device does not output anything."))

/// Sends a signal to activate to every outputting component in `outputs`
/datum/component/clockwork_trap/proc/trigger_connected()
	for(var/datum/output as anything in outputs) //must be typecasted because of how SEND_SIGNAL works

		SEND_SIGNAL(output, COMSIG_CLOCKWORK_SIGNAL_RECEIVED)
