#define IV_TAKING 0
#define IV_INJECTING 1

#define MIN_IV_TRANSFER_RATE 0
#define MAX_IV_TRANSFER_RATE 5

///Universal IV that can drain blood or feed reagents over a period of time from or to a replaceable container
/obj/machinery/iv_drip
	name = "\improper IV drip"
	desc = "An IV drip with an advanced infusion pump that can both drain blood into and inject liquids from attached containers. Blood packs are injected at twice the displayed rate. Right-Click to detach the IV or the attached container."
	icon = 'icons/obj/medical/iv_drip.dmi'
	icon_state = "iv_drip"
	base_icon_state = "iv_drip"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	use_power = NO_POWER_USE
	///Who are we sticking our needle in?
	var/atom/attached
	///Are we donating or injecting?
	var/mode = IV_INJECTING
	///whether we feed slower
	var/transfer_rate = MAX_IV_TRANSFER_RATE
	///Internal beaker
	var/obj/item/reagent_container
	///Set false to block beaker use and instead use an internal reagent holder
	var/use_internal_storage = FALSE
	///Typecache of containers we accept
	var/static/list/drip_containers = typecacheof(list(
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/chem_pack,
	))
	// If the blood draining tab should be greyed out
	var/inject_only = FALSE

/obj/machinery/iv_drip/Initialize(mapload)
	. = ..()
	update_appearance()
	if(use_internal_storage)
		create_reagents(100, TRANSPARENT)
	interaction_flags_machine |= INTERACT_MACHINE_OFFLINE

/obj/machinery/iv_drip/Destroy()
	attached = null
	QDEL_NULL(reagent_container)
	return ..()

/obj/machinery/iv_drip/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/machinery/iv_drip/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IVDrip", name)
		ui.open()

/obj/machinery/iv_drip/ui_data(mob/user)
	var/list/data = list()
	data["transferRate"] = transfer_rate
	data["injectOnly"] = inject_only ? TRUE : FALSE
	data["maxInjectRate"] = MAX_IV_TRANSFER_RATE
	data["minInjectRate"] = MIN_IV_TRANSFER_RATE
	data["mode"] = mode == IV_INJECTING ? TRUE : FALSE
	data["connected"] = attached ? TRUE : FALSE
	if(attached)
		data["objectName"] = attached.name
		data["canDrainBlood"] = isliving(attached)
	data["beakerAttached"] = reagent_container ? TRUE : FALSE
	if(reagent_container)
		data["beakerCurrentVolume"] = round(reagent_container.reagents.total_volume, 0.01)
		data["beakerMaxVolume"] = reagent_container.reagents.maximum_volume
		data["beakerReagentColor"] = mix_color_from_reagents(reagent_container.reagents.reagent_list)
	data["useInternalStorage"] = use_internal_storage
	return data

/obj/machinery/iv_drip/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("changeMode")
			toggle_mode()
			. = TRUE
		if("eject")
			eject_beaker()
			. = TRUE
		if("detach")
			if(attached)
				visible_message(span_notice("[attached] is detached from [src]."))
				detach_iv()
			. = TRUE
		if("changeRate")
			var/target_rate = params["rate"]
			if(text2num(target_rate) != null)
				target_rate = text2num(target_rate)
				transfer_rate = round(clamp(target_rate, MIN_IV_TRANSFER_RATE, MAX_IV_TRANSFER_RATE), 0.01)
				. = TRUE
	update_appearance()

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

	var/mutable_appearance/filling_overlay = mutable_appearance('icons/obj/medical/iv_drip.dmi', "reagent")
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

/obj/machinery/iv_drip/MouseDrop(atom/target)
	. = ..()
	if(!Adjacent(target) || !usr.Adjacent(target))
		return
	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if(!get_reagent_holder())
		to_chat(usr, span_warning("There's nothing attached to the IV drip!"))
		return
	if(!target.reagents)
		to_chat(usr, span_warning("Target can't hold reagents!"))
		return
	if(attached)
		visible_message(span_warning("[attached] is detached from [src]."))
		attached = null
		update_appearance()
	usr.visible_message(span_warning("[usr] attaches [src] to [target]."), span_notice("You attach [src] to [target]."))
	attach_iv(target, usr)

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
		user.log_message("attached a [W] to [src] at [AREACOORD(src)] containing ([reagent_container.reagents.get_reagent_log_string()])", LOG_ATTACK)
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
		if(isliving(attached))
			var/mob/living/attached_mob = attached
			to_chat(attached, span_userdanger("The IV drip needle is ripped out of you, leaving an open bleeding wound!"))
			var/list/arm_zones = shuffle(list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
			var/obj/item/bodypart/chosen_limb = attached_mob.get_bodypart(arm_zones[1]) || attached_mob.get_bodypart(arm_zones[2]) || attached_mob.get_bodypart(BODY_ZONE_CHEST)
			chosen_limb.receive_damage(3)
			chosen_limb.force_wound_upwards(/datum/wound/pierce/moderate)
		else
			visible_message(span_warning("[attached] is detached from [src]."))
		detach_iv()
		return PROCESS_KILL

	if(transfer_rate == 0)
		return

	var/datum/reagents/target_reagents = get_reagent_holder()
	if(target_reagents)
		// Give blood
		if(mode)
			if(target_reagents.total_volume)
				target_reagents.trans_to(attached, transfer_rate * delta_time, methods = INJECT, show_message = FALSE) //make reagents reacts, but don't spam messages
				update_appearance()

		// Take blood
		else if (isliving(attached))
			var/mob/living/attached_mob = attached
			var/amount = min(transfer_rate * delta_time, target_reagents.maximum_volume - target_reagents.total_volume)
			// If the beaker is full, ping
			if(!amount)
				transfer_rate = 0
				visible_message(span_hear("[src] pings."))
				return

			// If the human is losing too much blood, beep.
			if(attached_mob.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
				visible_message(span_hear("[src] beeps loudly."))
				playsound(loc, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			var/atom/movable/target = use_internal_storage ? src : reagent_container
			attached_mob.transfer_blood_to(target, amount)
			update_appearance()

/obj/machinery/iv_drip/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
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
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

///called when an IV is attached
/obj/machinery/iv_drip/proc/attach_iv(atom/target, mob/user)
	if(isliving(target))
		user.visible_message(span_warning("[usr] begins attaching [src] to [target]..."), span_warning("You begin attaching [src] to [target]."))
		if(!do_after(usr, 1 SECONDS, target))
			return
	else
		mode = IV_INJECTING
	usr.visible_message(span_warning("[usr] attaches [src] to [target]."), span_notice("You attach [src] to [target]."))
	var/datum/reagents/container = get_reagent_holder()
	log_combat(usr, target, "attached", src, "containing: ([container.get_reagent_log_string()])")
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
		if(attached)
			visible_message(span_warning("[attached] is detached from [src]."))
			detach_iv()
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
	// Prevent blood draining from non-living
	if(!isliving(attached))
		mode = IV_INJECTING
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

/datum/crafting_recipe/iv_drip
	name = "IV drip"
	result = /obj/machinery/iv_drip
	time = 30
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/reagent_containers/syringe = 1,
	)
	category = CAT_CHEMISTRY

/obj/machinery/iv_drip/saline
	name = "saline drip"
	desc = "An all-you-can-drip saline canister designed to supply a hospital without running out, with a scary looking pump rigged to inject saline into containers, but filling people directly might be a bad idea."
	icon_state = "saline"
	base_icon_state = "saline"
	density = TRUE
	inject_only = TRUE

/obj/machinery/iv_drip/saline/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	. = ..()
	reagent_container = new /obj/item/reagent_containers/cup/saline(src)

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

/obj/machinery/iv_drip/plumbing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/iv_drip, anchored)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

#undef IV_TAKING
#undef IV_INJECTING

#undef MIN_IV_TRANSFER_RATE
#undef MAX_IV_TRANSFER_RATE
