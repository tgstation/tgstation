/proc/make_link_visual_generic(datum/mod_link/mod_link, proc_path)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	var/obj/effect/overlay/link_visual = new()
	link_visual.name = "holocall ([mod_link.id])"
	link_visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	LAZYADD(mod_link.holder.update_on_z, link_visual)
	link_visual.appearance_flags |= KEEP_TOGETHER
	link_visual.makeHologram(0.75)
	mod_link.visual_overlays = user.overlays - user.active_thinking_indicator
	link_visual.add_overlay(mod_link.visual_overlays)
	mod_link.visual = link_visual
	mod_link.holder.become_hearing_sensitive(REF(mod_link))
	mod_link.holder.RegisterSignals(user, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY), proc_path)
	return link_visual

/proc/get_link_visual_generic(datum/mod_link/mod_link, atom/movable/visuals, proc_path)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	playsound(mod_link.holder, 'sound/machines/terminal_processing.ogg', 50, vary = TRUE)
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "static_base", TURF_LAYER))
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "modlink", ABOVE_ALL_MOB_LAYER))
	visuals.add_filter("crop_square", 1, alpha_mask_filter(icon = icon('icons/effects/effects.dmi', "modlink_filter")))
	visuals.maptext_height = 6
	visuals.alpha = 0
	user.vis_contents += visuals
	visuals.forceMove(user)
	animate(visuals, 0.5 SECONDS, alpha = 255)
	var/datum/callback/setdir_callback = CALLBACK(mod_link.holder, proc_path)
	setdir_callback.Invoke(user, user.dir, user.dir)
	mod_link.holder.RegisterSignal(mod_link.holder.loc, COMSIG_ATOM_DIR_CHANGE, proc_path)

/proc/delete_link_visual_generic(datum/mod_link/mod_link)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	playsound(mod_link.get_other().holder, 'sound/machines/terminal_processing.ogg', 50, vary = TRUE, frequency = -1)
	LAZYREMOVE(mod_link.holder.update_on_z, mod_link.visual)
	mod_link.holder.lose_hearing_sensitivity(REF(mod_link))
	mod_link.holder.UnregisterSignal(user, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(mod_link.visual)

/proc/on_user_set_dir_generic(datum/mod_link/mod_link, newdir)
	var/atom/other_visual = mod_link.get_other().visual
	if(!newdir) //can sometimes be null or 0
		return
	other_visual.setDir(SOUTH)
	other_visual.pixel_x = 0
	other_visual.pixel_y = 0
	var/matrix/new_transform = matrix()
	if(newdir & NORTH)
		other_visual.pixel_y = 13
		other_visual.layer = BELOW_MOB_LAYER
	if(newdir & SOUTH)
		other_visual.pixel_y = -24
		other_visual.layer = ABOVE_ALL_MOB_LAYER
		new_transform.Scale(-1, 1)
		new_transform.Translate(-1, 0)
	if(newdir & EAST)
		other_visual.pixel_x = 14
		other_visual.layer = BELOW_MOB_LAYER
		new_transform.Shear(0.5, 0)
		new_transform.Scale(0.65, 1)
	if(newdir & WEST)
		other_visual.pixel_x = -14
		other_visual.layer = BELOW_MOB_LAYER
		new_transform.Shear(-0.5, 0)
		new_transform.Scale(0.65, 1)
	other_visual.transform = new_transform

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	mod_link = new(
		src,
		starting_frequency,
		CALLBACK(src, PROC_REF(get_wearer)),
		CALLBACK(src, PROC_REF(can_call)),
		CALLBACK(src, PROC_REF(make_link_visual)),
		CALLBACK(src, PROC_REF(get_link_visual)),
		CALLBACK(src, PROC_REF(delete_link_visual))
	)

/obj/item/mod/control/multitool_act_secondary(mob/living/user, obj/item/multitool/tool)
	if(!multitool_check_buffer(user, tool))
		return
	var/tool_frequency = null
	if(istype(tool.buffer, /datum/mod_link))
		var/datum/mod_link/buffer_link = tool.buffer
		tool_frequency = buffer_link.frequency
		balloon_alert(user, "frequency set")
	if(!tool_frequency && mod_link.frequency)
		tool.set_buffer(mod_link)
		balloon_alert(user, "frequency copied")
	else if(tool_frequency && !mod_link.frequency)
		mod_link.frequency = tool_frequency
	else if(tool_frequency && mod_link.frequency)
		var/response = tgui_alert(user, "Would you like to copy or imprint the frequency?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(tool))
			return
		switch(response)
			if("Copy")
				tool.set_buffer(mod_link)
				balloon_alert(user, "frequency copied")
			if("Imprint")
				mod_link.frequency = tool_frequency
				balloon_alert(user, "frequency set")

/obj/item/mod/control/proc/can_call()
	return get_charge() && wearer && wearer.stat < DEAD

/obj/item/mod/control/proc/make_link_visual()
	return make_link_visual_generic(mod_link, PROC_REF(on_overlay_change))

/obj/item/mod/control/proc/get_link_visual(atom/movable/visuals)
	return get_link_visual_generic(mod_link, visuals, PROC_REF(on_wearer_set_dir))

/obj/item/mod/control/proc/delete_link_visual()
	return delete_link_visual_generic(mod_link)

/obj/item/mod/control/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	if(speaker != wearer && speaker != ai_assistant)
		return
	mod_link.visual.say(raw_message, sanitize = FALSE, message_range = 2)

/obj/item/mod/control/proc/on_overlay_change(atom/source, cache_index, overlay)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(update_link_visual)), 1 TICKS, TIMER_UNIQUE)

/obj/item/mod/control/proc/update_link_visual()
	if(QDELETED(mod_link.link_call))
		return
	mod_link.visual.cut_overlay(mod_link.visual_overlays)
	mod_link.visual_overlays = wearer.overlays - wearer.active_thinking_indicator
	mod_link.visual.add_overlay(mod_link.visual_overlays)

/obj/item/mod/control/proc/on_wearer_set_dir(atom/source, dir, newdir)
	SIGNAL_HANDLER
	on_user_set_dir_generic(mod_link, newdir || SOUTH)

/obj/item/clothing/neck/link_scryer
	name = "\improper MODlink scryer"
	desc = "An intricate piece of machinery that creates a holographic video call with another MODlink-compatible device. Essentially a video necklace."
	icon_state = "modlink"
	actions_types = list(/datum/action/item_action/call_link)
	/// The installed power cell.
	var/obj/item/stock_parts/power_store/cell
	/// The MODlink datum we operate.
	var/datum/mod_link/mod_link
	/// Initial frequency of the MODlink.
	var/starting_frequency
	/// An additional name tag for the scryer, seen as "MODlink scryer - [label]"
	var/label

/obj/item/clothing/neck/link_scryer/Initialize(mapload)
	. = ..()
	mod_link = new(
		src,
		starting_frequency,
		CALLBACK(src, PROC_REF(get_user)),
		CALLBACK(src, PROC_REF(can_call)),
		CALLBACK(src, PROC_REF(make_link_visual)),
		CALLBACK(src, PROC_REF(get_link_visual)),
		CALLBACK(src, PROC_REF(delete_link_visual))
	)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/neck/link_scryer/Destroy()
	QDEL_NULL(cell)
	QDEL_NULL(mod_link)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/neck/link_scryer/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("The battery charge reads [cell.percent()]%. <b>Right-click</b> with an empty hand to remove it.")
	else
		. += span_notice("It is missing a battery, one can be installed by clicking with a power cell on it.")
	. += span_notice("The MODlink ID is [mod_link.id], frequency is [mod_link.frequency || "unset"]. <b>Right-click</b> with multitool to copy/imprint frequency.")
	. += span_notice("Use in hand to set name.")

/obj/item/clothing/neck/link_scryer/equipped(mob/living/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_NECK)
		mod_link?.end_call()

/obj/item/clothing/neck/link_scryer/dropped(mob/living/user)
	. = ..()
	mod_link?.end_call()

/obj/item/clothing/neck/link_scryer/attack_self(mob/user, modifiers)
	var/new_label = reject_bad_text(tgui_input_text(user, "Change the visible name", "Set Name", label, MAX_NAME_LEN))
	if(!user.is_holding(src))
		return
	if(!new_label)
		balloon_alert(user, "invalid name!")
		return
	label = new_label
	balloon_alert(user, "name set")
	update_name()

/obj/item/clothing/neck/link_scryer/process(seconds_per_tick)
	if(!mod_link.link_call)
		return
	cell.use(0.02 * STANDARD_CELL_RATE * seconds_per_tick, force = TRUE)

/obj/item/clothing/neck/link_scryer/attackby(obj/item/attacked_by, mob/user, params)
	. = ..()
	if(cell || !istype(attacked_by, /obj/item/stock_parts/power_store/cell))
		return
	if(!user.transferItemToLoc(attacked_by, src))
		return
	cell = attacked_by
	balloon_alert(user, "installed [cell.name]")

/obj/item/clothing/neck/link_scryer/update_name(updates)
	. = ..()
	name = "[initial(name)][label ? " - [label]" : ""]"

/obj/item/clothing/neck/link_scryer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

/obj/item/clothing/neck/link_scryer/attack_hand_secondary(mob/user, list/modifiers)
	if(!cell)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	balloon_alert(user, "removed [cell.name]")
	user.put_in_hands(cell)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/neck/link_scryer/multitool_act_secondary(mob/living/user, obj/item/multitool/tool)
	if(!multitool_check_buffer(user, tool))
		return
	var/tool_frequency = null
	if(istype(tool.buffer, /datum/mod_link))
		var/datum/mod_link/buffer_link = tool.buffer
		tool_frequency = buffer_link.frequency
		balloon_alert(user, "frequency set")
	if(!tool_frequency && mod_link.frequency)
		tool.set_buffer(mod_link)
		balloon_alert(user, "frequency copied")
	else if(tool_frequency && !mod_link.frequency)
		mod_link.frequency = tool_frequency
	else if(tool_frequency && mod_link.frequency)
		var/response = tgui_alert(user, "Would you like to copy or imprint the frequency?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(tool))
			return
		switch(response)
			if("Copy")
				tool.set_buffer(mod_link)
				balloon_alert(user, "frequency copied")
			if("Imprint")
				mod_link.frequency = tool_frequency
				balloon_alert(user, "frequency set")

/obj/item/clothing/neck/link_scryer/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!QDELETED(mod_link.link_call))
		. += mutable_appearance('icons/mob/clothing/neck.dmi', "modlink_active")

/obj/item/clothing/neck/link_scryer/ui_action_click(mob/user)
	if(mod_link.link_call)
		mod_link.end_call()
	else
		call_link(user, mod_link)

/obj/item/clothing/neck/link_scryer/proc/get_user()
	var/mob/living/carbon/user = loc
	return istype(user) && user.wear_neck == src ? user : null

/obj/item/clothing/neck/link_scryer/proc/can_call()
	var/mob/living/user = loc
	return istype(user) && cell?.charge && user.stat < DEAD

/obj/item/clothing/neck/link_scryer/proc/make_link_visual()
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	user.update_worn_neck()
	return make_link_visual_generic(mod_link, PROC_REF(on_overlay_change))

/obj/item/clothing/neck/link_scryer/proc/get_link_visual(atom/movable/visuals)
	return get_link_visual_generic(mod_link, visuals, PROC_REF(on_user_set_dir))

/obj/item/clothing/neck/link_scryer/proc/delete_link_visual()
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	if(!QDELETED(user))
		user.update_worn_neck()
	return delete_link_visual_generic(mod_link)

/obj/item/clothing/neck/link_scryer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	if(speaker != loc)
		return
	mod_link.visual.say(raw_message, sanitize = FALSE, message_range = 3)

/obj/item/clothing/neck/link_scryer/proc/on_overlay_change(atom/source, cache_index, overlay)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(update_link_visual)), 1 TICKS, TIMER_UNIQUE)

/obj/item/clothing/neck/link_scryer/proc/update_link_visual()
	if(QDELETED(mod_link.link_call))
		return
	var/mob/living/user = loc
	mod_link.visual.cut_overlay(mod_link.visual_overlays)
	mod_link.visual_overlays = user.overlays - user.active_thinking_indicator
	mod_link.visual.add_overlay(mod_link.visual_overlays)

/obj/item/clothing/neck/link_scryer/proc/on_user_set_dir(atom/source, dir, newdir)
	SIGNAL_HANDLER
	on_user_set_dir_generic(mod_link, newdir || SOUTH)

/obj/item/clothing/neck/link_scryer/loaded
	starting_frequency = "NT"

/obj/item/clothing/neck/link_scryer/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/high(src)

/obj/item/clothing/neck/link_scryer/loaded/charlie
	starting_frequency = MODLINK_FREQ_CHARLIE

/// A MODlink datum, used to handle unique functions that will be used in the MODlink call.
/datum/mod_link
	/// Generic name for multitool buffers.
	var/name = "MODlink"
	/// The frequency of the MODlink. You can only call other MODlinks on the same frequency.
	var/frequency
	/// The unique ID of the MODlink.
	var/id = ""
	/// The atom that holds the MODlink.
	var/atom/movable/holder
	/// A reference to the visuals generated by the MODlink.
	var/atom/movable/visual
	/// A list of all overlays of the user, copied everytime they have an overlay change.
	var/list/visual_overlays = list()
	/// A reference to the call between two MODlinks.
	var/datum/mod_link_call/link_call
	/// A callback that returns the user of the MODlink.
	var/datum/callback/get_user_callback
	/// A callback that returns whether the MODlink can currently call.
	var/datum/callback/can_call_callback
	/// A callback that returns the visuals of the MODlink.
	var/datum/callback/make_visual_callback
	/// A callback that receives the visuals of the other MODlink.
	var/datum/callback/get_visual_callback
	/// A callback that deletes the visuals of the MODlink.
	var/datum/callback/delete_visual_callback

/datum/mod_link/New(
	atom/holder,
	frequency,
	datum/callback/get_user_callback,
	datum/callback/can_call_callback,
	datum/callback/make_visual_callback,
	datum/callback/get_visual_callback,
	datum/callback/delete_visual_callback
)
	var/attempts = 0
	var/digits_to_make = 3
	do
		if(attempts == 10)
			attempts = 0
			digits_to_make++
		id = ""
		for(var/i in 1 to digits_to_make)
			id += num2text(rand(0,9))
		attempts++
	while(GLOB.mod_link_ids[id])
	GLOB.mod_link_ids[id] = src
	src.frequency = frequency
	src.holder = holder
	src.get_user_callback = get_user_callback
	src.can_call_callback = can_call_callback
	src.make_visual_callback = make_visual_callback
	src.get_visual_callback = get_visual_callback
	src.delete_visual_callback = delete_visual_callback
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(on_holder_delete))

/datum/mod_link/Destroy()
	GLOB.mod_link_ids -= id
	if(link_call)
		end_call()
	get_user_callback = null
	make_visual_callback = null
	get_visual_callback = null
	delete_visual_callback = null
	return ..()

/datum/mod_link/proc/get_other()
	RETURN_TYPE(/datum/mod_link)
	if(!link_call)
		return
	return link_call.caller == src ? link_call.receiver : link_call.caller

/datum/mod_link/proc/call_link(datum/mod_link/called, mob/user)
	if(!frequency)
		return
	if(!istype(called))
		holder.balloon_alert(user, "invalid target!")
		return
	var/mob/living/link_user = get_user_callback.Invoke()
	if(!link_user)
		return
	if(HAS_TRAIT(link_user, TRAIT_IN_CALL))
		holder.balloon_alert(user, "user already in call!")
		return
	var/mob/living/link_target = called.get_user_callback.Invoke()
	if(!link_target)
		holder.balloon_alert(user, "invalid target!")
		return
	if(HAS_TRAIT(link_target, TRAIT_IN_CALL))
		holder.balloon_alert(user, "target already in call!")
		return
	if(!can_call_callback.Invoke() || !called.can_call_callback.Invoke())
		holder.balloon_alert(user, "can't call!")
		return
	link_target.playsound_local(get_turf(called.holder), 'sound/weapons/ring.ogg', 15, vary = TRUE)
	var/atom/movable/screen/alert/modlink_call/alert = link_target.throw_alert("[REF(src)]_modlink", /atom/movable/screen/alert/modlink_call)
	alert.desc = "[holder] ([id]) is calling you! Left-click this to accept the call. Right-click to deny it."
	alert.caller_ref = WEAKREF(src)
	alert.receiver_ref = WEAKREF(called)
	alert.user_ref = WEAKREF(user)

/datum/mod_link/proc/end_call()
	QDEL_NULL(link_call)

/datum/mod_link/proc/on_holder_delete(atom/source)
	SIGNAL_HANDLER
	qdel(src)

/// A MODlink call datum, used to handle the call between two MODlinks.
/datum/mod_link_call
	/// The MODlink that is calling.
	var/datum/mod_link/caller
	/// The MODlink that is being called.
	var/datum/mod_link/receiver

/datum/mod_link_call/New(datum/mod_link/caller, datum/mod_link/receiver)
	caller.link_call = src
	receiver.link_call = src
	src.caller = caller
	src.receiver = receiver
	var/mob/living/caller_mob = caller.get_user_callback.Invoke()
	ADD_TRAIT(caller_mob, TRAIT_IN_CALL, REF(src))
	var/mob/living/receiver_mob = receiver.get_user_callback.Invoke()
	ADD_TRAIT(receiver_mob, TRAIT_IN_CALL, REF(src))
	make_visuals()
	START_PROCESSING(SSprocessing, src)

/datum/mod_link_call/Destroy()
	var/mob/living/caller_mob = caller.get_user_callback.Invoke()
	if(!QDELETED(caller_mob))
		REMOVE_TRAIT(caller_mob, TRAIT_IN_CALL, REF(src))
	var/mob/living/receiver_mob = receiver.get_user_callback.Invoke()
	if(!QDELETED(receiver_mob))
		REMOVE_TRAIT(receiver_mob, TRAIT_IN_CALL, REF(src))
	STOP_PROCESSING(SSprocessing, src)
	clear_visuals()
	caller.link_call = null
	receiver.link_call = null
	return ..()

/datum/mod_link_call/process(seconds_per_tick)
	if(can_continue_call())
		return
	qdel(src)

/datum/mod_link_call/proc/can_continue_call()
	return caller.frequency == receiver.frequency && caller.can_call_callback.Invoke() && receiver.can_call_callback.Invoke()

/datum/mod_link_call/proc/make_visuals()
	var/caller_visual = caller.make_visual_callback.Invoke()
	var/receiver_visual = receiver.make_visual_callback.Invoke()
	caller.get_visual_callback.Invoke(receiver_visual)
	receiver.get_visual_callback.Invoke(caller_visual)

/datum/mod_link_call/proc/clear_visuals()
	caller.delete_visual_callback.Invoke()
	receiver.delete_visual_callback.Invoke()

/proc/call_link(mob/user, datum/mod_link/calling_link)
	if(!calling_link.frequency)
		return
	var/list/callers = list()
	for(var/id in GLOB.mod_link_ids)
		var/datum/mod_link/link = GLOB.mod_link_ids[id]
		if(link.frequency != calling_link.frequency)
			continue
		if(link == calling_link)
			continue
		if(!link.can_call_callback.Invoke())
			continue
		callers["[link.holder] ([id])"] = id
	if(!length(callers))
		calling_link.holder.balloon_alert(user, "no targets on freq [calling_link.frequency]!")
		return
	var/chosen_link = tgui_input_list(user, "Choose ID to call from [calling_link.frequency] frequency", "MODlink", callers)
	if(!chosen_link)
		return
	calling_link.call_link(GLOB.mod_link_ids[callers[chosen_link]], user)

/atom/movable/screen/alert/modlink_call
	name = "MODlink Call Incoming"
	desc = "Someone is calling you! Left-click this to accept the call. Right-click to deny it."
	icon_state = "called"
	timeout = 10 SECONDS
	var/end_message = "call timed out!"
	/// A weak reference to the MODlink that is calling.
	var/datum/weakref/caller_ref
	/// A weak reference to the MODlink that is being called.
	var/datum/weakref/receiver_ref
	/// A weak reference to the mob that is calling.
	var/datum/weakref/user_ref

/atom/movable/screen/alert/modlink_call/Click(location, control, params)
	. = ..()
	if(usr != owner)
		return
	var/datum/mod_link/caller = caller_ref.resolve()
	var/datum/mod_link/receiver = receiver_ref.resolve()
	if(!caller || !receiver)
		return
	if(caller.link_call || receiver.link_call)
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		end_message = "call denied!"
		owner.clear_alert("[REF(caller)]_modlink")
		return
	end_message = "call accepted"
	new /datum/mod_link_call(caller, receiver)
	owner.clear_alert("[REF(caller)]_modlink")

/atom/movable/screen/alert/modlink_call/Destroy()
	var/mob/living/user = user_ref?.resolve()
	var/datum/mod_link/caller = caller_ref?.resolve()
	if(!user || !caller)
		return ..()
	caller.holder.balloon_alert(user, end_message)
	return ..()
