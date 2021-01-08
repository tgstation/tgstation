/obj/item/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	name = "Payload Device"
	icon_state = "valve"
	inhand_icon_state = "ttv"
	desc = "Injects a bomb payload with superheated Hyper-Noblium, containing enough energy to kickstart a tritium reaction."
	w_class = WEIGHT_CLASS_BULKY

	var/obj/item/tank/payload
	var/obj/item/assembly/attached_device
	var/datum/gas_mixture/gasmix
	var/mob/attacher = null
	var/range = FALSE
	var/failed = 0
	var/deltaW = 0

/obj/item/transfer_valve/Initialize()
	. = ..()

	gasmix = new(100) //liters
	gasmix.temperature = T20C
	
	add_overlay("valve_hotmix")

/obj/item/transfer_valve/IsAssemblyHolder()
	return TRUE

/obj/item/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		if(payload)
			to_chat(user, "<span class='warning'>There is a payload on the device!</span>")
			return
		else
			if(!user.transferItemToLoc(item, src))
				return
			payload = item
			to_chat(user, "<span class='notice'>You attach the tank to the bomb.</span>")

		update_icon()
		
	else if(isassembly(item))
		var/obj/item/assembly/A = item
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first!</span>")
			return
		if(!user.transferItemToLoc(item, src))
			return
		attached_device = A
		to_chat(user, "<span class='notice'>You attach the [item] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).
		log_bomber(user, "attached a [item.name] to a ttv -", src, null, FALSE)
		attacher = user
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

/obj/item/transfer_valve/Crossed(atom/movable/AM as mob|obj)
	. = ..()
	if(attached_device)
		attached_device.Crossed(AM)

//Triggers mousetraps
/obj/item/transfer_valve/attack_hand()
	. = ..()
	if(.)
		return
	if(attached_device)
		attached_device.attack_hand()

/obj/item/transfer_valve/update_icon()
	cut_overlays()

	add_overlay("valve_hotmix")

	if(payload)
		var/mutable_appearance/J = mutable_appearance(icon, icon_state = "[payload.icon_state]")
		var/matrix/T = matrix()
		T.Translate(-13, 0)
		J.transform = T
		underlays = list(J)
	else
		underlays = null

	if(attached_device)
		add_overlay("device")
		if(istype(attached_device, /obj/item/assembly/infra))
			var/obj/item/assembly/infra/sensor = attached_device
			if(sensor.on && sensor.visible)
				add_overlay("proxy_beam")
/*

	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
*/
/obj/item/transfer_valve/proc/log_activation()
	var/turf/bombturf = get_turf(src)
	var/attachment
	var/attachment_signal_log
	var/admin_attachment_message
	var/attachment_message
	var/mob/bomber = get_mob_by_key(fingerprintslast)
	var/admin_bomber_message
	var/bomber_message
	
	if(attached_device)
		if(istype(attached_device, /obj/item/assembly/signaler))
			var/obj/item/assembly/signaler/attached_signaller = attached_device
			attachment = "<A HREF='?_src_=holder;[HrefToken()];secrets=list_signalers'>[attached_signaller]</A>"
			attachment_signal_log = attached_signaller.last_receive_signal_log ? "The following log entry is the last one associated with the attached signaller<br>[attached_signaller.last_receive_signal_log]" : "There is no signal log entry."
		else
			attachment = attached_device

	if(attachment)
		admin_attachment_message = "The bomb had [attachment], which was attached by [attacher ? ADMIN_LOOKUPFLW(attacher) : "Unknown"]"
		attachment_message = " with [attachment] attached by [attacher ? key_name_admin(attacher) : "Unknown"]"

	if(bomber)
		admin_bomber_message = "The bomb's most recent set of fingerprints indicate it was last touched by [ADMIN_LOOKUPFLW(bomber)]"
		bomber_message = " - Last touched by: [key_name_admin(bomber)]"

	var/admin_bomb_message = "Bomb valve opened in [ADMIN_VERBOSEJMP(bombturf)]<br>[admin_attachment_message]<br>[admin_bomber_message]<br>[attachment_signal_log]"
	GLOB.bombers += admin_bomb_message
	message_admins(admin_bomb_message)
	log_game("Bomb valve opened in [AREACOORD(bombturf)][attachment_message][bomber_message]")


/obj/item/transfer_valve/proc/merge_gases()
	if (!payload.air_contents)
		return
	var/datum/gas_mixture/payload_content = payload.air_contents
	var/old_energy = payload_content.temperature * payload_content.heat_capacity()
	var/injected_energy = 6e7 //0.03 moles of Hyper-Noblium at 1 million kelvins
	var/energy_after_reacting = 0

	gasmix.merge(payload_content)
	payload_content = null

	ASSERT_GAS(/datum/gas/hypernoblium, gasmix)
	gasmix.gases[/datum/gas/hypernoblium][MOLES] += 0.03
	gasmix.temperature = (injected_energy + old_energy) / gasmix.heat_capacity()
	gasmix.react()
	energy_after_reacting = gasmix.temperature * gasmix.heat_capacity()
	deltaW = energy_after_reacting - (injected_energy + old_energy)

/obj/item/transfer_valve/proc/calculate_power() //Other dependencies now only have to call this proc and merge_gases to get the explosion range.
	if (deltaW > 1e5) //Only allows for explosions for differences in delta W. This is to prevent Hypernob abuse.
		var/range_update = deltaW / 1.5e5
		return range_update
	else
		return 0

/obj/item/transfer_valve/proc/handle_explosion()
	var/turf/epicenter = get_turf(loc)
	explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
	qdel(src)

/obj/item/transfer_valve/proc/activate()
	if(!failed && ready())
		log_activation()
		merge_gases()
		range = calculate_power()
	
		if (range)
			handle_explosion()
		else
			failed = TRUE

/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	activate()

/obj/item/transfer_valve/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/transfer_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransferValve", name)
		ui.open()

/obj/item/transfer_valve/ui_data(mob/user)
	var/list/data = list()
	data["payload"] = payload ? payload.name : null
	data["attached_device"] = attached_device ? attached_device.name : null
	data["failed"] = failed ? TRUE : null
	return data

/obj/item/transfer_valve/proc/ready()
	return (payload ? TRUE: FALSE)
	
/obj/item/transfer_valve/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("payload")
			if(payload)
				payload.forceMove(drop_location())
				payload = null
				. = TRUE
		if("toggle")
			activate()
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

	update_icon()
