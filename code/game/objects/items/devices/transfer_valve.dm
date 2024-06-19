/obj/item/transfer_valve
	icon = 'icons/obj/devices/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	base_icon_state = "valve"
	inhand_icon_state = "ttv"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back/backpack.dmi'
	worn_icon_state = "ttv"
	desc = "Regulates the transfer of air between two tanks."
	w_class = WEIGHT_CLASS_BULKY

	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/assembly/attached_device
	var/mob/attacher = null
	var/valve_open = FALSE
	var/toggle = TRUE
	///do we have cables attached to be able to be put on the back?
	var/wired = FALSE
	///our overlay when wired = true
	var/mutable_appearance/cable_overlay

/obj/item/transfer_valve/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FRIED, PROC_REF(on_fried))

/obj/item/transfer_valve/Destroy()
	attached_device = null
	return ..()

/obj/item/transfer_valve/IsAssemblyHolder()
	return TRUE

/obj/item/transfer_valve/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == tank_one)
		tank_one = null
		update_appearance()
	else if(gone == tank_two)
		tank_two = null
		update_appearance()

/obj/item/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, span_warning("There are already two tanks attached, remove one first!"))
			return

		if(!tank_one)
			if(!user.transferItemToLoc(item, src))
				return
			tank_one = item
			to_chat(user, span_notice("You attach the tank to the transfer valve."))
		else if(!tank_two)
			if(!user.transferItemToLoc(item, src))
				return
			tank_two = item
			to_chat(user, span_notice("You attach the tank to the transfer valve."))

		update_appearance()
//TODO: Have this take an assemblyholder
	else if(isassembly(item))
		var/obj/item/assembly/A = item
		if(A.secured)
			to_chat(user, span_notice("The device is secured."))
			return
		if(attached_device)
			to_chat(user, span_warning("There is already a device attached to the valve, remove it first!"))
			return
		if(!user.transferItemToLoc(item, src))
			return
		attached_device = A
		to_chat(user, span_notice("You attach the [item] to the valve controls and secure it."))
		A.holder = src
		A.on_attach()
		A.toggle_secure() //this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).
		log_bomber(user, "attached a [item.name] to a ttv -", src, null, FALSE)
		attacher = user

	else if(istype(item, /obj/item/stack/cable_coil) && !wired)
		var/obj/item/stack/cable_coil/coil = item
		if (coil.get_amount() < 15)
			to_chat(user, span_warning("You need fifteen lengths of coil for this!"))
			return
		coil.use(15)
		to_chat(user, span_notice("You add some cables, not being really sure why. Looks like <i>backpack</i> straps."))
		wired = TRUE
		slot_flags |= ITEM_SLOT_BACK
		update_appearance()

	else if(item.tool_behaviour == TOOL_WIRECUTTER && wired)
		item.play_tool_sound(src)
		to_chat(user, span_notice("You remove the cables."))
		wired = FALSE
		slot_flags &= ~ITEM_SLOT_BACK
		Move(drop_location())
		new /obj/item/stack/cable_coil(drop_location(), 15)
		update_appearance()

	return

//These keep attached devices synced up, for example a TTV with a mouse trap being found in a bag so it's triggered, or moving the TTV with an infrared beam sensor to update the beam's direction.
/obj/item/transfer_valve/Move()
	. = ..()
	if(attached_device)
		attached_device.holder_movement()

/obj/item/transfer_valve/dropped()
	. = ..()
	if(attached_device)
		attached_device.dropped()

/obj/item/transfer_valve/on_found(mob/finder)
	if(attached_device)
		attached_device.on_found(finder)

//Triggers mousetraps
/obj/item/transfer_valve/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(attached_device)
		attached_device.attack_hand()

/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	if(toggle)
		toggle = FALSE
		toggle_valve()
		addtimer(CALLBACK(src, PROC_REF(toggle_off)), 5) //To stop a signal being spammed from a proxy sensor constantly going off or whatever

/obj/item/transfer_valve/proc/toggle_off()
	toggle = TRUE

/obj/item/transfer_valve/update_icon_state()
	icon_state = "[base_icon_state][(!tank_one && !tank_two && !attached_device) ? "_1" : null]"
	return ..()

/obj/item/transfer_valve/update_overlays()
	. = ..()
	if(tank_one)
		. += "[tank_one.icon_state]"

	if(!tank_two)
		underlays = null
	else
		var/mutable_appearance/J = mutable_appearance(icon, icon_state = "[tank_two.icon_state]")
		var/matrix/T = matrix()
		T.Translate(-13, 0)
		J.transform = T
		underlays = list(J)

	if(wired)
		cable_overlay = mutable_appearance(icon, icon_state = "valve_cables", layer = layer + 0.05, appearance_flags = KEEP_TOGETHER)
		add_overlay(cable_overlay)

	else if(cable_overlay)
		cut_overlay(cable_overlay, TRUE)
		cable_overlay = null

	worn_icon_state = "[initial(worn_icon_state)][tank_two ? "l" : ""][tank_one ? "r" : ""]"
	if(ishuman(loc)) //worn
		var/mob/living/carbon/human/human = loc
		human.update_worn_back()

	if(!attached_device)
		return

	. += "device"
	if(!istype(attached_device, /obj/item/assembly/infra))
		return
	var/obj/item/assembly/infra/sensor = attached_device
	if(sensor.on && sensor.visible)
		. += "proxy_beam"


/// Merge both gases into a single tank. Combine the volume by default. If target tank isn't specified default to tank_two
/obj/item/transfer_valve/proc/merge_gases(obj/item/tank/target, change_volume = TRUE)
	if(!target)
		target = tank_two

	if(!istype(target) || (target != tank_one && target != tank_two))
		return FALSE

	// Throw both tanks into processing queue
	var/datum/gas_mixture/target_mix = target.return_air()
	var/datum/gas_mixture/other_mix
	other_mix = (target == tank_one ? tank_two : tank_one).return_air()

	if(change_volume)
		target_mix.volume += other_mix.volume

	target_mix.merge(other_mix.remove_ratio(1))
	return TRUE

/obj/item/transfer_valve/proc/split_gases()
	if (!valve_open || !tank_one || !tank_two)
		return
	var/datum/gas_mixture/mix_one = tank_one.return_air()
	var/datum/gas_mixture/mix_two = tank_two.return_air()

	var/volume_ratio = mix_one.volume/mix_two.volume
	var/datum/gas_mixture/temp
	temp = mix_two.remove_ratio(volume_ratio)
	mix_one.merge(temp)
	mix_two.volume -= mix_one.volume

/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
*/
/obj/item/transfer_valve/proc/toggle_valve(obj/item/tank/target, change_volume = TRUE)
	playsound(src, 'sound/effects/valve_opening.ogg', 50)
	if(!valve_open && tank_one && tank_two)
		var/turf/bombturf = get_turf(src)

		var/attachment
		var/attachment_signal_log
		if(attached_device)
			if(issignaler(attached_device))
				var/obj/item/assembly/signaler/attached_signaller = attached_device
				attachment = "<A HREF='?_src_=holder;[HrefToken()];secrets=list_signalers'>[attached_signaller]</A>"
				attachment_signal_log = attached_signaller.last_receive_signal_log ? "The following log entry is the last one associated with the attached signaller<br>[attached_signaller.last_receive_signal_log]" : "There is no signal log entry."
			else
				attachment = attached_device

		var/admin_attachment_message
		var/attachment_message
		if(attachment)
			admin_attachment_message = "The bomb had [attachment], which was attached by [attacher ? ADMIN_LOOKUPFLW(attacher) : "Unknown"]"
			attachment_message = " with [attachment] attached by [attacher ? key_name_admin(attacher) : "Unknown"]"

		var/mob/bomber = get_mob_by_key(fingerprintslast)
		var/admin_bomber_message
		var/bomber_message
		if(bomber)
			admin_bomber_message = "The bomb's most recent set of fingerprints indicate it was last touched by [ADMIN_LOOKUPFLW(bomber)]"
			bomber_message = " - Last touched by: [key_name_admin(bomber)]"
			bomber.log_message("opened bomb valve", LOG_GAME, log_globally = FALSE)

		if(istype(attachment, /obj/item/assembly/voice))
			var/obj/item/assembly/voice/spoken_trigger = attachment
			attachment_message += " with the following activation message: \"[spoken_trigger.recorded]\""
			admin_attachment_message += " with the following activation message: \"[spoken_trigger.recorded]\""

		var/admin_bomb_message = "Bomb valve opened in [ADMIN_VERBOSEJMP(bombturf)]<br>[admin_attachment_message]<br>[admin_bomber_message]<br>[attachment_signal_log]"
		GLOB.bombers += admin_bomb_message
		message_admins(admin_bomb_message)
		log_game("Bomb valve opened in [AREACOORD(bombturf)][attachment_message][bomber_message]")

		valve_open = merge_gases(target, change_volume)

		if(!valve_open)
			stack_trace("TTV gas merging failed.")

		for(var/i in 1 to 6)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance)), 20 + (i - 1) * 10)

	else if(valve_open && tank_one && tank_two)
		split_gases()
		valve_open = FALSE
		update_appearance()
/*
	This doesn't do anything but the timer etc. expects it to be here
	eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
*/
/obj/item/transfer_valve/proc/c_state()
	return

///Signal when deep fried, so it can have an explosive reaction!
/obj/item/transfer_valve/proc/on_fried(datum/source, fry_time)
	SIGNAL_HANDLER
	log_bomber(null, "TTV valve opened via deepfrying", src, "last fingerprints = [fingerprintslast]")
	toggle_valve()

/obj/item/transfer_valve/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/transfer_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransferValve", name)
		ui.open()

/obj/item/transfer_valve/ui_data(mob/user)
	var/list/data = list()
	data["tank_one"] = tank_one ? tank_one.name : null
	data["tank_two"] = tank_two ? tank_two.name : null
	data["attached_device"] = attached_device ? attached_device.name : null
	data["valve"] = valve_open
	return data

/obj/item/transfer_valve/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("tankone")
			if(tank_one)
				split_gases()
				valve_open = FALSE
				tank_one.forceMove(drop_location())
				. = TRUE
		if("tanktwo")
			if(tank_two)
				split_gases()
				valve_open = FALSE
				tank_two.forceMove(drop_location())
				. = TRUE
		if("toggle")
			toggle_valve()
			. = TRUE
		if("device")
			if(attached_device)
				attached_device.attack_self(usr)
				. = TRUE
		if("remove_device")
			if(attached_device)
				attached_device.on_detach()
				attached_device = null
				. = TRUE

	update_appearance()

/**
 * Returns if this is ready to be detonated. Checks if both tanks are in place.
 */
/obj/item/transfer_valve/proc/ready()
	return tank_one && tank_two

/obj/item/transfer_valve/fake/Initialize(mapload)
	. = ..()

	tank_one = new /obj/item/tank/internals/plasma (src)
	tank_two = new /obj/item/tank/internals/oxygen (src)

	update_appearance()
