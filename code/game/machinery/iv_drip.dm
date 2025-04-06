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
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	use_power = NO_POWER_USE
	interaction_flags_mouse_drop = NEED_HANDS

	/// Information and effects about where the IV drip is attached to
	var/datum/iv_drip_attachment/attachment
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
	// If the blood draining tab should be greyed out
	var/inject_only = FALSE

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
	QDEL_NULL(attachment)
	QDEL_NULL(reagent_container)
	return ..()

/obj/machinery/iv_drip/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IVDrip", name)
		ui.open()

/obj/machinery/iv_drip/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(attachment)
		context[SCREENTIP_CONTEXT_RMB] = "Take needle out"
	else if(reagent_container && !use_internal_storage)
		context[SCREENTIP_CONTEXT_RMB] = "Eject container"
	else if(!inject_only)
		context[SCREENTIP_CONTEXT_RMB] = "Change direction"

	if(transfer_rate > MIN_IV_TRANSFER_RATE)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Set flow to min"
	else
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Set flow to max"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/iv_drip/ui_static_data(mob/user)
	. = list()
	.["transferStep"] = IV_TRANSFER_RATE_STEP
	.["maxTransferRate"] = MAX_IV_TRANSFER_RATE
	.["minTransferRate"] = MIN_IV_TRANSFER_RATE

/obj/machinery/iv_drip/ui_data(mob/user)
	. = list()

	.["hasInternalStorage"] = use_internal_storage
	.["hasContainer"] = reagent_container ? TRUE : FALSE
	.["canRemoveContainer"] = !use_internal_storage

	.["mode"] = mode == IV_INJECTING ? TRUE : FALSE
	.["canDraw"] = inject_only || (attachment && !isliving(attachment.attached_to)) ? FALSE : TRUE
	.["transferRate"] = transfer_rate

	.["hasObjectAttached"] = !!attachment
	if(attachment)
		.["objectName"] = attachment.attached_to.name

	var/datum/reagents/drip_reagents = get_reagents()
	if(drip_reagents)
		.["containerCurrentVolume"] = round(drip_reagents.total_volume, IV_TRANSFER_RATE_STEP)
		.["containerMaxVolume"] = drip_reagents.maximum_volume
		.["containerReagentColor"] = mix_color_from_reagents(drip_reagents.reagent_list)

/obj/machinery/iv_drip/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

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
	transfer_rate = round(clamp(new_rate, MIN_IV_TRANSFER_RATE, MAX_IV_TRANSFER_RATE), IV_TRANSFER_RATE_STEP)
	update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/update_icon_state()
	if(transfer_rate > 0 && attachment)
		icon_state = "[base_icon_state]_[mode ? "injecting" : "donating"]"
	else
		icon_state = "[base_icon_state]_[mode ? "injectidle" : "donateidle"]"
	return ..()

/obj/machinery/iv_drip/update_overlays()
	. = ..()

	if(!reagent_container)
		return

	. += attachment ? "beakeractive" : "beakeridle"
	var/datum/reagents/container_reagents = get_reagents()
	if(!container_reagents)
		return

	//The thresholds used to determine the reagent fill icon
	var/static/list/fill_icon_thresholds = list(0, 10, 25, 50, 75, 80, 90)

	var/threshold = null
	for(var/i in 1 to fill_icon_thresholds.len)
		if(ROUND_UP(100 * container_reagents.total_volume / container_reagents.maximum_volume) >= fill_icon_thresholds[i])
			threshold = i

	if(threshold)
		var/fill_name = "reagent[fill_icon_thresholds[threshold]]"
		var/mutable_appearance/filling = mutable_appearance(icon, fill_name)
		filling.color = mix_color_from_reagents(container_reagents.reagent_list)
		. += filling

/obj/machinery/iv_drip/mouse_drop_dragged(atom/target, mob/user)
	if(!isliving(user))
		to_chat(user, span_warning("You can't do that!"))
		return
	if(!get_reagents())
		to_chat(user, span_warning("There's nothing attached to the IV drip!"))
		return
	if(!target.is_injectable(user))
		to_chat(user, span_warning("Can't inject into this!"))
		return
	if(attachment)
		visible_message(span_warning("[attachment.attached_to] is detached from [src]."))
		QDEL_NULL(attachment)
		update_appearance(UPDATE_ICON)
	user.visible_message(span_warning("[user] attaches [src] to [target]."), span_notice("You attach [src] to [target]."))
	attach_iv(target, user)

/obj/machinery/iv_drip/attackby(obj/item/W, mob/user, params)
	if(use_internal_storage)
		return ..()

	//Typecache of containers we accept
	var/static/list/drip_containers = typecacheof(list(
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/chem_pack,
	))

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


/obj/machinery/iv_drip/click_alt(mob/user)
	set_transfer_rate(transfer_rate > MIN_IV_TRANSFER_RATE ? MIN_IV_TRANSFER_RATE : MAX_IV_TRANSFER_RATE)
	return CLICK_ACTION_SUCCESS

/obj/machinery/iv_drip/on_deconstruction(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc)

/obj/machinery/iv_drip/process(seconds_per_tick)
	if(!attachment)
		return PROCESS_KILL

	var/atom/attached_to = attachment.attached_to

	if(!(get_dist(src, attached_to) <= 1 && isturf(attached_to.loc)))
		if(isliving(attached_to))
			var/mob/living/carbon/attached_mob = attached_to
			to_chat(attached_to, span_userdanger("The IV drip needle is ripped out of you, leaving an open bleeding wound!"))
			var/list/arm_zones = shuffle(list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
			var/obj/item/bodypart/chosen_limb = attached_mob.get_bodypart(arm_zones[1]) || attached_mob.get_bodypart(arm_zones[2]) || attached_mob.get_bodypart(BODY_ZONE_CHEST)
			attached_mob.apply_damage(3, BRUTE, chosen_limb, wound_bonus = CANT_WOUND)
			attached_mob.cause_wound_of_type_and_severity(WOUND_PIERCE, chosen_limb, WOUND_SEVERITY_MODERATE, wound_source = "IV needle")
		else
			visible_message(span_warning("[attached_to] is detached from [src]."))
		detach_iv()
		return PROCESS_KILL

	var/datum/reagents/drip_reagents = get_reagents()
	if(!drip_reagents)
		return PROCESS_KILL

	if(!transfer_rate)
		return

	// Give reagents
	if(mode)
		if(drip_reagents.total_volume)
			drip_reagents.trans_to(attached_to, transfer_rate * seconds_per_tick, methods = INJECT, show_message = FALSE) //make reagents reacts, but don't spam messages
			update_appearance(UPDATE_ICON)

	// Take blood
	else if (isliving(attached_to))
		var/mob/living/attached_mob = attached_to
		var/amount = min(transfer_rate * seconds_per_tick, drip_reagents.maximum_volume - drip_reagents.total_volume)
		// If the beaker is full, ping
		if(!amount)
			set_transfer_rate(MIN_IV_TRANSFER_RATE)
			audible_message(span_hear("[src] pings."))
			return

		// If the human is losing too much blood, beep.
		if(attached_mob.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
			audible_message(span_hear("[src] beeps loudly."))
			playsound(loc, 'sound/machines/beep/twobeep_high.ogg', 50, TRUE)
		var/atom/movable/target = use_internal_storage ? src : reagent_container
		attached_mob.transfer_blood_to(target, amount)
		update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!ishuman(user))
		return
	if(attachment)
		visible_message(span_notice("[attachment.attached_to] is detached from [src]."))
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

	qdel(attachment)
	attachment = new(src, target)

	START_PROCESSING(SSmachines, src)
	update_appearance(UPDATE_ICON)

	SEND_SIGNAL(src, COMSIG_IV_ATTACH, target)

///Called when an iv is detached. doesnt include chat stuff because there's multiple options and its better handled by the caller
/obj/machinery/iv_drip/proc/detach_iv()
	if(attachment)
		visible_message(span_notice("[attachment.attached_to] is detached from [src]."))
		if(isliving(attachment.attached_to))
			var/mob/living/attached_mob = attachment.attached_to
			attached_mob.clear_alert(ALERT_IV_CONNECTED, /atom/movable/screen/alert/iv_connected)
	SEND_SIGNAL(src, COMSIG_IV_DETACH, attachment?.attached_to)
	QDEL_NULL(attachment)
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
	if(usr.incapacitated)
		return
	if(reagent_container)
		if(attachment)
			visible_message(span_warning("[attachment?.attached_to] is detached from [src]."))
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
	if(!usr.can_perform_action(src) || usr.incapacitated)
		return
	if(inject_only)
		mode = IV_INJECTING
		return
	// Prevent blood draining from non-living
	if(attachment && !isliving(attachment.attached_to))
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
	. += span_notice("[attachment ? attachment.attached_to : "Nothing"] is connected.")

/// Information and effects about where an IV drip is attached to
// Lifetime is managed by the iv_drip, which will delete the iv_drip_attachment after
// a process if the attached object is invalid.
// iv_drip_attachment should never outlive iv_drip.
/datum/iv_drip_attachment
	var/obj/machinery/iv_drip/iv_drip
	var/atom/attached_to

	VAR_PRIVATE
		datum/beam/beam
		datum/component/tug_towards/tug_to_me

/datum/iv_drip_attachment/New(
	obj/machinery/iv_drip/iv_drip,
	atom/attached_to
)
	src.iv_drip = iv_drip
	src.attached_to = attached_to

	tug_to_me = attached_to.AddComponent(/datum/component/tug_towards, iv_drip)

	beam = iv_drip.Beam(
		attached_to,
		icon_state = "1-full",
		beam_color = COLOR_SILVER,
		layer = BELOW_MOB_LAYER,

		// Come out from the spout
		override_origin_pixel_x = 9,
		override_origin_pixel_y = 2,
	)

/datum/iv_drip_attachment/Destroy(force)
	tug_to_me.remove_tug_target(iv_drip)
	tug_to_me = null

	iv_drip = null
	attached_to = null

	QDEL_NULL(beam)

	return ..()

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

#undef DEFAULT_IV_TRANSFER_RATE
