#define IV_TAKING 0
#define IV_INJECTING 1
///Universal IV that can drain blood or feed reagents over a period of time from or to a replaceable container
/obj/machinery/iv_drip
	name = "\improper IV drip"
	desc = "An IV drip with an advanced infusion pump that can both drain blood into and inject liquids from attached containers. Blood packs are processed at an accelerated rate. Right-Click to change the transfer rate."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	base_icon_state = "iv_drip"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	///Who are we sticking our needle in?
	var/mob/living/carbon/attached
	///Are we donating or injecting?
	var/mode = IV_INJECTING
	///whether we feed slower
	var/dripfeed = FALSE
	///Internal beaker
	var/obj/item/reagent_container
	///Set false to block beaker use and instead use an internal reagent holder
	var/use_internal_storage = FALSE
	///Typecache of containers we accept
	var/static/list/drip_containers = typecacheof(list(/obj/item/reagent_containers/blood,
									/obj/item/reagent_containers/food,
									/obj/item/reagent_containers/glass,
									/obj/item/reagent_containers/chem_pack))

/obj/machinery/iv_drip/Initialize(mapload)
	. = ..()
	update_appearance()
	if(use_internal_storage)
		create_reagents(100, TRANSPARENT)

/obj/machinery/iv_drip/Destroy()
	attached = null
	QDEL_NULL(reagent_container)
	return ..()

/obj/machinery/iv_drip/update_icon_state()
	if(attached)
		icon_state = "[base_icon_state]_[mode ? "injecting" : "donating"]"
	else
		icon_state = "[base_icon_state]_[mode ? "injectidle" : "donateidle"]"
	return ..()

/obj/machinery/iv_drip/update_overlays()
	. = ..()

	if(!reagent_container)
		return

	. += attached ? "beakeractive" : "beakeridle"
	var/datum/reagents/target_reagents = get_reagent_holder()
	if(!target_reagents)
		return

	var/mutable_appearance/filling_overlay = mutable_appearance('icons/obj/iv_drip.dmi', "reagent")
	var/percent = round((target_reagents.total_volume / target_reagents.maximum_volume) * 100)
	switch(percent)
		if(0 to 9)
			filling_overlay.icon_state = "reagent0"
		if(10 to 24)
			filling_overlay.icon_state = "reagent10"
		if(25 to 49)
			filling_overlay.icon_state = "reagent25"
		if(50 to 74)
			filling_overlay.icon_state = "reagent50"
		if(75 to 79)
			filling_overlay.icon_state = "reagent75"
		if(80 to 90)
			filling_overlay.icon_state = "reagent80"
		if(91 to INFINITY)
			filling_overlay.icon_state = "reagent100"

	filling_overlay.color = mix_color_from_reagents(target_reagents.reagent_list)
	. += filling_overlay

/obj/machinery/iv_drip/MouseDrop(mob/living/target)
	. = ..()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE) || !isliving(target))
		return

	if(attached)
		visible_message(span_warning("[attached] is detached from [src]."))
		attached = null
		update_appearance()
		return

	if(!target.has_dna())
		to_chat(usr, span_danger("The drip beeps: Warning, incompatible creature!"))
		return

	if(Adjacent(target) && usr.Adjacent(target))
		if(get_reagent_holder())
			attach_iv(target, usr)
		else
			to_chat(usr, span_warning("There's nothing attached to the IV drip!"))


/obj/machinery/iv_drip/attackby(obj/item/W, mob/user, params)
	if(use_internal_storage)
		return ..()

	if(is_type_in_typecache(W, drip_containers) || IS_EDIBLE(W))
		if(reagent_container)
			to_chat(user, span_warning("[reagent_container] is already loaded on [src]!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		reagent_container = W
		to_chat(user, span_notice("You attach [W] to [src]."))
		user.log_message("attached a [W] to [src] at [AREACOORD(src)] containing ([reagent_container.reagents.log_list()])", LOG_ATTACK)
		add_fingerprint(user)
		update_appearance()
		return
	else
		return ..()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc)
	qdel(src)

/obj/machinery/iv_drip/process(delta_time)
	if(!attached)
		return PROCESS_KILL

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		to_chat(attached, span_userdanger("The IV drip needle is ripped out of you!"))
		attached.apply_damage(3, BRUTE, pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		detach_iv()
		return PROCESS_KILL

	var/datum/reagents/target_reagents = get_reagent_holder()
	if(target_reagents)
		// Give blood
		if(mode)
			if(target_reagents.total_volume)
				var/transfer_amount = 5
				if (dripfeed)
					transfer_amount = 1
				if(istype(reagent_container, /obj/item/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount *= 2
				target_reagents.trans_to(attached, transfer_amount * delta_time * 0.5, methods = INJECT, show_message = FALSE) //make reagents reacts, but don't spam messages
				update_appearance()

		// Take blood
		else
			var/amount = target_reagents.maximum_volume - target_reagents.total_volume
			amount = min(amount, 4) * delta_time * 0.5
			// If the beaker is full, ping
			if(!amount)
				if(prob(5))
					visible_message(span_hear("[src] pings."))
				return

			// If the human is losing too much blood, beep.
			if(attached.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
				visible_message(span_hear("[src] beeps loudly."))
				playsound(loc, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			var/atom/movable/target = use_internal_storage ? src : reagent_container
			attached.transfer_blood_to(target, amount)
			update_appearance()

/obj/machinery/iv_drip/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(attached)
		visible_message(span_notice("[attached] is detached from [src]."))
		detach_iv()
		return
	else if(reagent_container)
		eject_beaker(user)
	else
		toggle_mode()

/obj/machinery/iv_drip/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(dripfeed)
		dripfeed = FALSE
		to_chat(usr, span_notice("You loosen the valve to speed up the [src]."))
	else
		dripfeed = TRUE
		to_chat(usr, span_notice("You tighten the valve to slowly drip-feed the contents of [src]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///called when an IV is attached
/obj/machinery/iv_drip/proc/attach_iv(mob/living/target, mob/user)
	usr.visible_message(span_warning("[usr] attaches [src] to [target]."), span_notice("You attach [src] to [target]."))
	var/datum/reagents/container = get_reagent_holder()
	log_combat(usr, target, "attached", src, "containing: ([container.log_list()])")
	add_fingerprint(usr)
	attached = target
	START_PROCESSING(SSmachines, src)
	update_appearance()

	SEND_SIGNAL(src, COMSIG_IV_ATTACH, target)

///Called when an iv is detached. doesnt include chat stuff because there's multiple options and its better handled by the caller
/obj/machinery/iv_drip/proc/detach_iv()
	SEND_SIGNAL(src, COMSIG_IV_DETACH, attached)

	attached = null
	update_appearance()

/obj/machinery/iv_drip/proc/get_reagent_holder()
	return use_internal_storage ? reagents : reagent_container?.reagents

/obj/machinery/iv_drip/verb/eject_beaker()
	set category = "Object"
	set name = "Remove IV Container"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if (!usr.canUseTopic())
		return
	if(usr.incapacitated())
		return
	if(reagent_container)
		reagent_container.forceMove(drop_location())
		reagent_container = null
		update_appearance()

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if (!usr.canUseTopic())
		return
	if(usr.incapacitated())
		return
	mode = !mode
	to_chat(usr, span_notice("The IV drip is now [mode ? "injecting" : "taking blood"]."))
	update_appearance()

/obj/machinery/iv_drip/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 2)
		return

	. += "[src] is [mode ? "injecting" : "taking blood"]."

	if(reagent_container)
		if(reagent_container.reagents && reagent_container.reagents.reagent_list.len)
			. += span_notice("Attached is \a [reagent_container] with [reagent_container.reagents.total_volume] units of liquid.")
		else
			. += span_notice("Attached is an empty [reagent_container.name].")
	else if(use_internal_storage)
		. += span_notice("It has an internal chemical storage.")
	else
		. += span_notice("No chemicals are attached.")

	. += span_notice("[attached ? attached : "No one"] is attached.")


/obj/machinery/iv_drip/saline
	name = "saline drip"
	desc = "An all-you-can-drip saline canister designed to supply a hospital without running out, with a scary looking pump rigged to inject saline into containers, but filling people directly might be a bad idea."
	icon_state = "saline"
	base_icon_state = "saline"
	density = TRUE

/obj/machinery/iv_drip/saline/Initialize(mapload)
	. = ..()
	reagent_container = new /obj/item/reagent_containers/glass/saline(src)

/obj/machinery/iv_drip/saline/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/machinery/iv_drip/saline/eject_beaker()
	return

/obj/machinery/iv_drip/saline/toggle_mode()
	return

///modified IV that can be anchored and takes plumbing in- and output
/obj/machinery/iv_drip/plumbing
	name = "automated IV drip"
	desc = "A modified IV drip with plumbing connects. Reagents received from the connect are injected directly into their bloodstream, blood that is drawn goes to the internal storage and then into the ducting."
	icon_state = "plumb"
	base_icon_state = "plumb"

	density = TRUE
	use_internal_storage = TRUE

/obj/machinery/iv_drip/plumbing/Initialize()
	. = ..()

	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))
	AddComponent(/datum/component/plumbing/iv_drip, anchored)

///Check if we can be rotated for the rotation component
/obj/machinery/iv_drip/plumbing/proc/can_be_rotated(mob/user,rotation_type)
	return !anchored

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

#undef IV_TAKING
#undef IV_INJECTING
