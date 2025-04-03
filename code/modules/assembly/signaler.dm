/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	inhand_icon_state = "signaler"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 4, /datum/material/glass=SMALL_MATERIAL_AMOUNT*1.2)
	assembly_behavior = ASSEMBLY_ALL
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	/// The code sent by this signaler.
	var/code = DEFAULT_SIGNALER_CODE
	/// The frequency this signaler is set to.
	var/frequency = FREQ_SIGNALER
	/// How long of a cooldown exists on this signaller.
	var/cooldown_length = 1 SECONDS
	/// The radio frequency connection this signaler is using.
	var/datum/radio_frequency/radio_connection
	/// Holds the mind that commited suicide.
	var/datum/mind/suicider
	/// Holds a reference string to the mob, decides how much of a gamer you are.
	var/suicide_mob
	/// How many tiles away can you hear when this signaler is used or gets activated.
	var/hearing_range = 1
	/// String containing the last piece of logging data relating to when this signaller has received a signal.
	var/last_receive_signal_log

/obj/item/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] eats \the [src]! If it is signaled, [user.p_they()] will die!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	moveToNullspace()
	suicider = user.mind
	suicide_mob = REF(user)
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/assembly/signaler/proc/manual_suicide(datum/mind/suicidee)
	var/mob/living/user = suicidee.current
	if(!istype(user))
		return
	if(suicide_mob == REF(user))
		user.visible_message(span_suicide("[user]'s [src] receives a signal, killing [user.p_them()] instantly!"))
	else
		user.visible_message(span_suicide("[user]'s [src] receives a signal and [user.p_they()] die[user.p_s()] like a gamer!"))
	user.set_suicide(TRUE)
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(FALSE)
	playsound(user, 'sound/machines/beep/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	qdel(src)

/obj/item/assembly/signaler/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	suicider = null
	. = ..()

/obj/item/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_appearance()
	. = ..()
	holder?.update_appearance()

/obj/item/assembly/signaler/ui_status(mob/user, datum/ui_state/state)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", name)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = frequency
	data["cooldown"] = cooldown_length
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("signal")
			if(cooldown_length > 0)
				if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_SIGNALLER_SEND))
					balloon_alert(ui.user, "recharging!")
					return
				TIMER_COOLDOWN_START(src, COOLDOWN_SIGNALLER_SEND, cooldown_length)
			INVOKE_ASYNC(src, PROC_REF(signal))
			balloon_alert(ui.user, "signaled")
			. = TRUE
		if("freq")
			var/new_frequency = sanitize_frequency(unformat_frequency(params["freq"]), TRUE)
			set_frequency(new_frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = round(code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else
				code = initial(code)
			. = TRUE

	update_appearance()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	..()

/obj/item/assembly/signaler/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!ishuman(user))
		return
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_SIGNALLER_SEND))
		balloon_alert(user, "still recharging...")
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_SIGNALLER_SEND, 1 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(signal))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/time = time2text(world.realtime, "hh:mm:ss", TIMEZONE_UTC)
	var/turf/T = get_turf(src)

	var/logging_data = "[time] <B>:</B> [key_name(usr)] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]"
	add_to_signaler_investigate_log(logging_data)

	var/datum/signal/signal = new(list("code" = code), logging_data = logging_data)
	radio_connection.post_signal(src, signal)

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(suicider)
		manual_suicide(suicider)
		return

	// If the holder is a TTV, we want to store the last received signal to incorporate it into TTV logging, else wipe it.
	last_receive_signal_log = istype(holder, /obj/item/transfer_valve) ? signal.logging_data : null

	pulse()
	audible_message(span_infoplain("[icon2html(src, hearers(src))] *beep* *beep* *beep*"), null, hearing_range)
	for(var/mob/hearing_mob in get_hearers_in_view(hearing_range, src))
		hearing_mob.playsound_local(get_turf(src), 'sound/machines/beep/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

/obj/item/assembly/signaler/cyborg

/obj/item/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/signaler/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/signaler/internal
	name = "internal remote signaling device"

/obj/item/assembly/signaler/internal/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/assembly/signaler/internal/attackby(obj/item/W, mob/user, params)
	return

/obj/item/assembly/signaler/internal/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/signaler/internal/can_interact(mob/user)
	if(ispAI(user))
		return TRUE
	. = ..()
