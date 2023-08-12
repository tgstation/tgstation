///IV drip operation mode when it sucks blood from the object
#define IV_TAKING 0
///IV drip operation mode when it injects reagents into the object
#define IV_INJECTING 1
///What the transfer rate value is rounded to
#define IV_TRANSFER_RATE_STEP 0.01
///Minimum possible IV drip transfer rate in units per second
#define MIN_IV_TRANSFER_RATE 0
///Maximum possible IV drip transfer rate in units per second
#define MAX_IV_TRANSFER_RATE 5
///Default IV drip transfer rate in units per second
#define DEFAULT_IV_TRANSFER_RATE 5
//Alert shown to mob the IV is still connected
#define ALERT_IV_CONNECTED "iv_connected"

///Universal IV that can drain blood or feed reagents over a period of time from or to a replaceable container
/obj/machinery/iv_drip
	name = "\improper IV drip"
	desc = "An IV drip with an advanced infusion pump that can both drain blood into and inject liquids from attached containers."
	icon = 'icons/obj/medical/iv_drip.dmi'
	icon_state = "iv_drip"
	base_icon_state = "iv_drip"
	///icon_state for the reagent fill overlay
	var/fill_icon_state = "reagent"
	///The thresholds used to determine the reagent fill icon
	var/list/fill_icon_thresholds = list(0,10,25,50,75,80,90)
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	use_power = NO_POWER_USE
	///What are we sticking our needle in?
	var/atom/attached
	///Are we donating or injecting?
	var/mode = IV_INJECTING
	///The chemicals flow speed
	var/transfer_rate = DEFAULT_IV_TRANSFER_RATE
	///Internal beaker
	var/obj/item/reagent_container
	///Set false to block beaker use and instead use an internal reagent holder
	var/use_internal_storage = FALSE
	///If we're using the internal container, fill us UP with the below : list(/datum/reagent/water = 5000)
	var/internal_list_reagents
	///How many reagents can we hold?
	var/internal_volume_maximum = 100
	///Typecache of containers we accept
	var/static/list/drip_containers = typecacheof(list(
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/chem_pack,
	))
	// If the blood draining tab should be greyed out
	var/inject_only = FALSE
	// Whether the injection maintained by the plumbing network
	var/inject_from_plumbing = FALSE

/obj/machinery/iv_drip/Initialize(mapload)
	. = ..()
	if(use_internal_storage)
		create_reagents(internal_volume_maximum, TRANSPARENT)
		if(internal_list_reagents)
			reagents.add_reagent_list(internal_list_reagents)
	interaction_flags_machine |= INTERACT_MACHINE_OFFLINE
	register_context()
	update_appearance(UPDATE_ICON)
	AddElement(/datum/element/noisy_movement)

/obj/machinery/iv_drip/Destroy()
	attached = null
	QDEL_NULL(reagent_container)
	return ..()

/obj/machinery/iv_drip/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IVDrip", name)
		ui.open()

/obj/machinery/iv_drip/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(attached)
		context[SCREENTIP_CONTEXT_RMB] = "Take needle out"
	else if(reagent_container && !use_internal_storage)
		context[SCREENTIP_CONTEXT_RMB] = "Eject container"
	else if(!inject_only)
		context[SCREENTIP_CONTEXT_RMB] = "Change direction"

	if(istype(src, /obj/machinery/iv_drip/plumbing))
		return CONTEXTUAL_SCREENTIP_SET

	if(transfer_rate > MIN_IV_TRANSFER_RATE)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Set flow to min"
	else
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Set flow to max"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/iv_drip/ui_data(mob/user)
	var/list/data = list()

	data["hasInternalStorage"] = use_internal_storage
	data["hasContainer"] = reagent_container ? TRUE : FALSE
	data["canRemoveContainer"] = !use_internal_storage

	data["mode"] = mode == IV_INJECTING ? TRUE : FALSE
	data["canDraw"] = inject_only || (attached && !isliving(attached)) ? FALSE : TRUE
	data["injectFromPlumbing"] = inject_from_plumbing

	data["canAdjustTransfer"] = inject_from_plumbing && mode == IV_INJECTING ? FALSE : TRUE
	data["transferRate"] = transfer_rate
	data["transferStep"] = IV_TRANSFER_RATE_STEP
	data["maxTransferRate"] = MAX_IV_TRANSFER_RATE
	data["minTransferRate"] = MIN_IV_TRANSFER_RATE

	data["hasObjectAttached"] = attached ? TRUE : FALSE
	if(attached)
		data["objectName"] = attached.name

	var/datum/reagents/drip_reagents = get_reagents()
	if(drip_reagents)
		data["containerCurrentVolume"] = round(drip_reagents.total_volume, IV_TRANSFER_RATE_STEP)
		data["containerMaxVolume"] = drip_reagents.maximum_volume
		data["containerReagentColor"] = mix_color_from_reagents(drip_reagents.reagent_list)

	return data

/obj/machinery/iv_drip/ui_act(action, params)
	if(..())
		return TRUE
	switch(action)
		if("changeMode")
			toggle_mode()
			return TRUE
		if("eject")
			eject_beaker()
			return TRUE
		if("detach")
			detach_iv()
			return TRUE
		if("changeRate")
			set_transfer_rate(text2num(params["rate"]))
			return TRUE

/// Sets the transfer rate to the provided value
/obj/machinery/iv_drip/proc/set_transfer_rate(new_rate)
	if(inject_from_plumbing && mode == IV_INJECTING)
		return
	transfer_rate = round(clamp(new_rate, MIN_IV_TRANSFER_RATE, MAX_IV_TRANSFER_RATE), IV_TRANSFER_RATE_STEP)
	update_appearance(UPDATE_ICON)

/// Toggles transfer rate between min and max rate
/obj/machinery/iv_drip/proc/toggle_transfer_rate()
	if(transfer_rate > MIN_IV_TRANSFER_RATE)
		set_transfer_rate(MIN_IV_TRANSFER_RATE)
	else
		set_transfer_rate(MAX_IV_TRANSFER_RATE)

/obj/machinery/iv_drip/update_icon_state()
	if(transfer_rate > 0 && attached)
		icon_state = "[base_icon_state]_[mode ? "injecting" : "donating"]"
	else
		icon_state = "[base_icon_state]_[mode ? "injectidle" : "donateidle"]"
	return ..()

/obj/machinery/iv_drip/update_overlays()
	. = ..()

	if(!reagent_container)
		return

	. += attached ? "beakeractive" : "beakeridle"
	var/datum/reagents/container_reagents = get_reagents()
	if(!container_reagents)
		return

	var/threshold = null
	for(var/i in 1 to fill_icon_thresholds.len)
		if(ROUND_UP(100 * container_reagents.total_volume / container_reagents.maximum_volume) >= fill_icon_thresholds[i])
			threshold = i
	if(threshold)
		var/fill_name = "[fill_icon_state][fill_icon_thresholds[threshold]]"
		var/mutable_appearance/filling = mutable_appearance(icon, fill_name)
		filling.color = mix_color_from_reagents(container_reagents.reagent_list)
		. += filling

/obj/machinery/iv_drip/MouseDrop(atom/target)
	. = ..()
	if(!Adjacent(target) || !usr.can_perform_action(src))
		return
	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if(!get_reagents())
		to_chat(usr, span_warning("There's nothing attached to the IV drip!"))
		return
	if(!target.is_injectable(usr))
		to_chat(usr, span_warning("Can't inject into this!"))
		return
	if(attached)
		visible_message(span_warning("[attached] is detached from [src]."))
		attached = null
		update_appearance(UPDATE_ICON)
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
		update_appearance(UPDATE_ICON)
		return
	else
		return ..()

/// Checks whether the IV drip transfer rate can be modified with AltClick
/obj/machinery/iv_drip/proc/can_use_alt_click(mob/user)
	if(!can_interact(user))
		return FALSE
	if(istype(src, /obj/machinery/iv_drip/plumbing)) // AltClick is used for rotation there
		return FALSE
	return TRUE

/obj/machinery/iv_drip/AltClick(mob/user)
	if(!can_use_alt_click(user))
		return ..()
	toggle_transfer_rate()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc)
	qdel(src)

/obj/machinery/iv_drip/process(seconds_per_tick)
	if(!attached)
		return PROCESS_KILL

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		if(isliving(attached))
			var/mob/living/attached_mob = attached
			to_chat(attached, span_userdanger("The IV drip needle is ripped out of you, leaving an open bleeding wound!"))
			var/list/arm_zones = shuffle(list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
			var/obj/item/bodypart/chosen_limb = attached_mob.get_bodypart(arm_zones[1]) || attached_mob.get_bodypart(arm_zones[2]) || attached_mob.get_bodypart(BODY_ZONE_CHEST)
			chosen_limb.receive_damage(3)
			chosen_limb.force_wound_upwards(/datum/wound/pierce/moderate, wound_source = "IV needle")
		else
			visible_message(span_warning("[attached] is detached from [src]."))
		detach_iv()
		return PROCESS_KILL

	var/datum/reagents/drip_reagents = get_reagents()
	if(!drip_reagents)
		return PROCESS_KILL

	if(transfer_rate == 0)
		return

	// Give reagents
	if(mode)
		if(drip_reagents.total_volume)
			drip_reagents.trans_to(attached, transfer_rate * seconds_per_tick, methods = INJECT, show_message = FALSE) //make reagents reacts, but don't spam messages
			update_appearance(UPDATE_ICON)

	// Take blood
	else if (isliving(attached))
		var/mob/living/attached_mob = attached
		var/amount = min(transfer_rate * seconds_per_tick, drip_reagents.maximum_volume - drip_reagents.total_volume)
		// If the beaker is full, ping
		if(!amount)
			set_transfer_rate(MIN_IV_TRANSFER_RATE)
			audible_message(span_hear("[src] pings."))
			return

		// If the human is losing too much blood, beep.
		if(attached_mob.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
			audible_message(span_hear("[src] beeps loudly."))
			playsound(loc, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		var/atom/movable/target = use_internal_storage ? src : reagent_container
		attached_mob.transfer_blood_to(target, amount)
		update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!ishuman(user))
		return
	if(attached)
		visible_message(span_notice("[attached] is detached from [src]."))
		detach_iv()
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
	var/datum/reagents/container = get_reagents()
	log_combat(usr, target, "attached", src, "containing: ([container.get_reagent_log_string()])")
	add_fingerprint(usr)
	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.throw_alert(ALERT_IV_CONNECTED, /atom/movable/screen/alert/iv_connected)
	attached = target
	START_PROCESSING(SSmachines, src)
	update_appearance(UPDATE_ICON)

	SEND_SIGNAL(src, COMSIG_IV_ATTACH, target)

///Called when an iv is detached. doesnt include chat stuff because there's multiple options and its better handled by the caller
/obj/machinery/iv_drip/proc/detach_iv()
	if(attached)
		visible_message(span_notice("[attached] is detached from [src]."))
		if(isliving(attached))
			var/mob/living/attached_mob = attached
			attached_mob.clear_alert(ALERT_IV_CONNECTED, /atom/movable/screen/alert/iv_connected)
	SEND_SIGNAL(src, COMSIG_IV_DETACH, attached)
	attached = null
	update_appearance(UPDATE_ICON)

/// Get the reagents used by IV drip
/obj/machinery/iv_drip/proc/get_reagents()
	return use_internal_storage ? reagents : reagent_container?.reagents

/obj/machinery/iv_drip/verb/eject_beaker()
	set category = "Object"
	set name = "Remove IV Container"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if(!usr.can_perform_action(src))
		return
	if(usr.incapacitated())
		return
	if(reagent_container)
		if(attached)
			visible_message(span_warning("[attached] is detached from [src]."))
			detach_iv()
		reagent_container.forceMove(drop_location())
		reagent_container = null
		update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return
	if(!usr.can_perform_action(src))
		return
	if(usr.incapacitated())
		return
	if(inject_only)
		mode = IV_INJECTING
		return
	// Prevent blood draining from non-living
	if(attached && !isliving(attached))
		mode = IV_INJECTING
		return
	mode = !mode
	update_appearance(UPDATE_ICON)
	to_chat(usr, span_notice("The IV drip is now [mode ? "injecting" : "taking blood"]."))

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
	. += span_notice("[attached ? attached : "Nothing"] is connected.")

/datum/crafting_recipe/iv_drip
	name = "IV drip"
	result = /obj/machinery/iv_drip
	time = 30
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/plastic = 1,
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

	use_internal_storage = TRUE
	internal_list_reagents = list(/datum/reagent/medicine/salglu_solution = 5000)
	internal_volume_maximum = 5000

/obj/machinery/iv_drip/saline/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	. = ..()

///modified IV that can be anchored and takes plumbing in- and output
/obj/machinery/iv_drip/plumbing
	name = "automated IV drip"
	desc = "A modified IV drip with plumbing connects. Reagents received from the connect are injected directly into their bloodstream, blood that is drawn goes to the internal storage and then into the ducting."
	icon_state = "plumb"
	base_icon_state = "plumb"
	density = TRUE
	use_internal_storage = TRUE
	inject_from_plumbing = TRUE

/obj/machinery/iv_drip/plumbing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/iv_drip, anchored)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/iv_drip/plumbing/deconstruct(disassembled = TRUE)
	qdel(src)

/atom/movable/screen/alert/iv_connected
	name = "IV Connected"
	desc = "You have an IV connected to your arm. Remember to remove it or drag the IV stand with you before moving, or else it will rip out!"
	icon_state = ALERT_IV_CONNECTED

#undef IV_TAKING
#undef IV_INJECTING

#undef MIN_IV_TRANSFER_RATE
#undef MAX_IV_TRANSFER_RATE

#undef IV_TRANSFER_RATE_STEP

#undef ALERT_IV_CONNECTED
