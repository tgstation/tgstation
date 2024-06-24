//Credit to Beestation for the original anesthetic machine code: https://github.com/BeeStation/BeeStation-Hornet/pull/3753

/obj/machinery/anesthetic_machine
	name = "portable anesthetic tank stand"
	desc = "A stand on wheels, similar to an IV drip, that can hold a canister of anesthetic along with a gas mask."
	icon = 'monkestation/code/modules/blueshift/icons/obj/machinery.dmi'
	icon_state = "breath_machine"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	use_power = NO_POWER_USE
	/// The mask attached to the anesthetic machine
	var/obj/item/clothing/mask/breath/anesthetic/attached_mask
	/// the tank attached to the anesthetic machine, by default it does not come with one.
	var/obj/item/tank/attached_tank = null
	/// Is the attached mask currently out?
	var/mask_out = FALSE

/obj/machinery/anesthetic_machine/examine(mob/user)
	. = ..()

	. += "<b>Right-clicking</b> with a wrench will deconstruct the stand, if there is no tank attached."
	if(mask_out)
		. += "<b>Click</b> on the stand to retract the mask, if the mask is currently out"
	if(attached_tank)
		. += "<b>Alt + Click</b> to remove [attached_tank]."

/obj/machinery/anesthetic_machine/Initialize(mapload)
	. = ..()
	attached_mask = new /obj/item/clothing/mask/breath/anesthetic(src)
	update_icon()

/obj/machinery/anesthetic_machine/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(user.istate & ISTATE_HARM)
		return ..()

	if(mask_out)
		to_chat(user, span_warning("There is someone currently attached to the [src]!"))
		return TRUE

	if(attached_tank)
		to_chat(user, span_warning("[attached_tank] must be removed from [src] first!"))
		return TRUE

	new /obj/item/anesthetic_machine_kit(get_turf(src))
	tool.play_tool_sound(user)
	to_chat(user, span_notice("You deconstruct the [src]."))
	qdel(src)
	return TRUE

/obj/machinery/anesthetic_machine/update_icon()
	. = ..()

	cut_overlays()

	if(attached_tank)
		add_overlay("tank_on")

	if(mask_out)
		add_overlay("mask_off")
		return
	add_overlay("mask_on")

/obj/machinery/anesthetic_machine/attack_hand(mob/living/user)
	. = ..()
	if(!retract_mask())
		return FALSE
	visible_message(span_notice("[user] retracts [attached_mask] back into [src]."))

/obj/machinery/anesthetic_machine/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/tank))
		return ..()

	if(attached_tank) // If there is an attached tank, remove it and drop it on the floor
		attached_tank.forceMove(loc)

	attacking_item.forceMove(src) // Put new tank in, set it as attached tank
	visible_message(span_notice("[user] inserts [attacking_item] into [src]."))
	attached_tank = attacking_item
	update_icon()

/obj/machinery/anesthetic_machine/AltClick(mob/user)
	if(!attached_tank)
		return

	attached_tank.forceMove(loc)
	to_chat(user, span_notice("You remove the [attached_tank]."))
	attached_tank = null
	update_icon()
	if(mask_out)
		retract_mask()
	return TRUE

///Retracts the attached_mask back into the machine
/obj/machinery/anesthetic_machine/proc/retract_mask()
	if(!mask_out)
		return FALSE

	if(iscarbon(attached_mask.loc)) // If mask is on a mob
		var/mob/living/carbon/attached_mob = attached_mask.loc
		// Close external air tank
		if (attached_mob.external)
			attached_mob.close_externals()
		attached_mob.transferItemToLoc(attached_mask, src, TRUE)
	else
		attached_mask.forceMove(src)

	mask_out = FALSE
	update_icon()
	return TRUE

/obj/machinery/anesthetic_machine/MouseDrop_T(mob/living/carbon/over, mob/living/user)
	. = ..()
	if(!istype(over))
		return

	if((!Adjacent(over)) || !(user.Adjacent(over)))
		return FALSE

	if(!attached_tank || mask_out)
		to_chat(user, span_warning("[mask_out ? "The machine is already in use!" : "The machine has no attached tank!"]"))
		return FALSE

	// if we somehow lost the mask, let's just make a brand new one. the wonders of technology!
	if(QDELETED(attached_mask))
		attached_mask = new /obj/item/clothing/mask/breath/anesthetic(src)
		update_icon()

	user.visible_message(span_warning("[user] attemps to attach the [attached_mask] to [over]."), span_notice("You attempt to attach the [attached_mask] to [over]"))
	if(!do_after(user, 5 SECONDS, over))
		return
	if(!over.equip_to_appropriate_slot(attached_mask))
		to_chat(user, span_warning("You are unable to attach the [attached_mask] to [over]!"))
		return

	user.visible_message(span_warning("[user] attaches the [attached_mask] to [over]."), span_notice("You attach the [attached_mask] to [over]"))

	// Open the tank externally
	over.open_internals(attached_tank, is_external = TRUE)
	mask_out = TRUE
	START_PROCESSING(SSmachines, src)
	update_icon()

/obj/machinery/anesthetic_machine/process()
	if(!mask_out) // If not on someone, stop processing
		return PROCESS_KILL

	var/mob/living/carbon/carbon_target = attached_mask.loc
	if(get_dist(src, get_turf(attached_mask)) > 1) // If too far away, detach
		to_chat(carbon_target, span_warning("[attached_mask] is ripped off of your face!"))
		retract_mask()
		return PROCESS_KILL

	// Attempt to restart airflow if it was temporarily interrupted after mask adjustment.
	if(attached_tank && istype(carbon_target) && !carbon_target.external && !attached_mask.up)
		carbon_target.open_internals(attached_tank, is_external = TRUE)

/obj/machinery/anesthetic_machine/Destroy()
	if(mask_out)
		retract_mask()

	if(attached_tank)
		attached_tank.forceMove(loc)
		attached_tank = null

	QDEL_NULL(attached_mask)
	return ..()

/// This a special version of the breath mask used for the anesthetic machine.
/obj/item/clothing/mask/breath/anesthetic
	/// What machine is the mask currently attached to?
	var/datum/weakref/attached_machine

/obj/item/clothing/mask/breath/anesthetic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

	// Make sure we are not spawning outside of a machine
	if(istype(loc, /obj/machinery/anesthetic_machine))
		attached_machine = WEAKREF(loc)

	var/obj/machinery/anesthetic_machine/our_machine
	if(attached_machine)
		our_machine = attached_machine.resolve()

	if(!our_machine)
		attached_machine = null
		if(mapload)
			stack_trace("Abstract, undroppable item [name] spawned at ([loc]) at [AREACOORD(src)] in \the [get_area(src)]. \
				Please remove it. This item should only ever be created by the anesthetic machine.")
		return INITIALIZE_HINT_QDEL

/obj/item/clothing/mask/breath/anesthetic/Destroy()
	attached_machine = null
	return ..()

/obj/item/clothing/mask/breath/anesthetic/dropped(mob/user)
	. = ..()

	if(isnull(attached_machine))
		return

	var/obj/machinery/anesthetic_machine/our_machine = attached_machine.resolve()
	// no machine, then delete it
	if(!our_machine)
		attached_machine = null
		qdel(src)
		return

	if(loc != our_machine) //If it isn't in the machine, then it retracts when dropped
		to_chat(user, span_notice("[src] retracts back into the [our_machine]."))
		our_machine.retract_mask()

/obj/item/clothing/mask/breath/anesthetic/adjustmask(mob/living/carbon/user)
	. = ..()
	// Air only goes through the mask, so temporarily pause airflow if mask is getting adjusted.
	// Since the mask is NODROP, the only possible user is the wearer
	var/mob/living/carbon/carbon_target = loc
	if(up && carbon_target.external)
		carbon_target.close_externals()

/// A boxed version of the Anesthetic Machine. This is what is printed from the medical prolathe.
/obj/item/anesthetic_machine_kit
	name = "anesthetic stand parts kit"
	desc = "Contains all of the parts needed to assemble a portable anesthetic stand. Use in hand to construct."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "plasticbox"

/obj/item/anesthetic_machine_kit/attack_self(mob/user)
	new /obj/machinery/anesthetic_machine(user.loc)

	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	qdel(src)
