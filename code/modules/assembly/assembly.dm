
/obj/item/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/devices/new_assemblies.dmi'
	icon_state = ""
	obj_flags = CONDUCTS_ELECTRICITY
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT)
	throwforce = 2
	throw_speed = 3
	throw_range = 7
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	/**
	 * Set to true if the device has different icons for each position.
	 * This will prevent things such as visible lasers from facing the incorrect direction when transformed by assembly_holder's update_appearance()
	 */
	var/is_position_sensitive = FALSE
	/// Flags related to this assembly. See [assemblies.dm]
	var/assembly_flags = NONE
	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/assembly_holder/holder = null
	var/assembly_behavior = ASSEMBLY_FUNCTIONAL_OUTPUT // how does the assembly behave with respect to what it's connected to
	var/datum/wires/connected = null
	var/next_activate = 0 //When we're next allowed to activate - for spam control

/obj/item/assembly/Destroy()
	holder = null
	return ..()

/obj/item/assembly/get_part_rating()
	return 1

/**
 * on_attach: Called when attached to a holder, wiring datum, or other special assembly
 *
 * Will also be called if the assembly holder is attached to a plasma (internals) tank or welding fuel (dispenser) tank.
 */
/obj/item/assembly/proc/on_attach()
	SHOULD_CALL_PARENT(TRUE)
	if(!holder && connected)
		holder = connected.holder
	SEND_SIGNAL(src, COMSIG_ASSEMBLY_ATTACHED, holder)

/**
 * on_detach: Called when removed from an assembly holder or wiring datum
 */
/obj/item/assembly/proc/on_detach()
	SHOULD_CALL_PARENT(TRUE)
	if(connected)
		connected = null
	if(!holder)
		return FALSE
	var/atom/was_holder = holder
	holder = null
	forceMove(was_holder.drop_location())
	SEND_SIGNAL(src, COMSIG_ASSEMBLY_DETACHED, was_holder)
	return TRUE

/**
 * holder_movement: Called when the assembly's holder detects movement
 */
/obj/item/assembly/proc/holder_movement()
	if(!holder)
		return FALSE
	setDir(holder.dir)
	return TRUE

/obj/item/assembly/proc/is_secured(mob/user)
	if(!secured)
		to_chat(user, span_warning("\The [src] is unsecured!"))
		return FALSE
	return TRUE

/**
 * Pulsed: This device was pulsed by another device
 *
 * * pulser: Who triggered the pulse
 */
/obj/item/assembly/proc/pulsed(mob/pulser)
	INVOKE_ASYNC(src, PROC_REF(activate), pulser)
	SEND_SIGNAL(src, COMSIG_ASSEMBLY_PULSED)
	return TRUE

/**
 * Pulse: This device is emitting a pulse to act on another device
 */
/obj/item/assembly/proc/pulse()
	// if we have connected wires and are a pulsing assembly, pulse it
	if(connected)
		connected.pulse_assembly(src)
	// otherwise if we're attached to a holder, process the activation of it with our flags
	else if(holder)
		holder.process_activation(src)
	return TRUE

/// What the device does when turned on
/obj/item/assembly/proc/activate(mob/activator)
	if(QDELETED(src) || !secured || (next_activate > world.time))
		return FALSE
	next_activate = world.time + 30
	return TRUE

/obj/item/assembly/proc/toggle_secure()
	secured = !secured
	update_appearance()
	return secured

// This is overwritten so that clumsy people can set off mousetraps even when in a holder.
// We are not going deeper than that however (won't set off if in a tank bomb or anything with wires)
// That would need to be added to all parent objects, or a signal created, whatever.
// Anyway this return check prevents you from picking up every assembly inside the holder at once.
/obj/item/assembly/attack_hand(mob/living/user, list/modifiers)
	if(holder || connected)
		return
	. = ..()

/obj/item/assembly/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(isassembly(attacking_item))
		var/obj/item/assembly/new_assembly = attacking_item
		// Check both our's and their's assembly flags to see if either should not duplicate
		// If so, and we match types, don't create a holder - block it
		if(((new_assembly.assembly_flags|assembly_flags) & ASSEMBLY_NO_DUPLICATES) && istype(new_assembly, type))
			balloon_alert(user, "can't attach another [new_assembly.name]!")
			return
		if(new_assembly.secured)
			balloon_alert(user, "[new_assembly.name] is not attachable!")
			return
		if(secured)
			balloon_alert(user, "[name] is not attachable!")
			return

		holder = new /obj/item/assembly_holder(drop_location())
		holder.assemble(src, new_assembly, user)
		holder.balloon_alert(user, "parts combined")
		return

	if(istype(attacking_item, /obj/item/assembly_holder))
		var/obj/item/assembly_holder/added_to_holder = attacking_item
		added_to_holder.try_add_assembly(src, user)
		return

	return ..()

/obj/item/assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(toggle_secure())
		to_chat(user, span_notice("\The [src] is ready!"))
	else
		to_chat(user, span_notice("\The [src] can now be attached!"))
	add_fingerprint(user)
	return TRUE

/obj/item/assembly/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] [secured? "is secured and ready to be used!" : "can be attached to other things."]")

/obj/item/assembly/ui_host(mob/user)
	// In order, return:
	// - The conencted wiring datum's owner, or
	// - The thing your assembly holder is attached to, or
	// - the assembly holder itself, or
	// - us
	return connected?.holder || holder?.master || holder || src

/obj/item/assembly/ui_state(mob/user)
	return GLOB.hands_state
