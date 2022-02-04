/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	inhand_icon_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=400, /datum/material/glass=120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/datum/radio_frequency/radio_connection
	///Holds the mind that commited suicide.
	var/datum/mind/suicider
	///Holds a reference string to the mob, decides how much of a gamer you are.
	var/suicide_mob
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
	user.death(0)
	user.suicide_log()
	playsound(user, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
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

/obj/item/assembly/signaler/ui_status(mob/user)
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
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("signal")
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_SIGNALLER_SEND))
				to_chat(usr, span_warning("[src] is still recharging..."))
				return
			TIMER_COOLDOWN_START(src, COOLDOWN_SIGNALLER_SEND, 1 SECONDS)
			INVOKE_ASYNC(src, .proc/signal)
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

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)

	var/logging_data
	if(usr)
		logging_data = "[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]"
		GLOB.lastsignalers.Add(logging_data)

	var/datum/signal/signal = new(list("code" = code), logging_data = logging_data)
	radio_connection.post_signal(src, signal)

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return
	if(suicider)
		manual_suicide(suicider)
		return

	// If the holder is a TTV, we want to store the last received signal to incorporate it into TTV logging, else wipe it.
	last_receive_signal_log = istype(holder, /obj/item/transfer_valve) ? signal.logging_data : null

	pulse(TRUE)
	audible_message("<span class='infoplain'>[icon2html(src, hearers(src))] *beep* *beep* *beep*</span>", null, hearing_range)
	for(var/mob/hearing_mob in get_hearers_in_view(hearing_range, src))
		hearing_mob.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/assembly/signaler/receiver
	var/on = FALSE

/obj/item/assembly/signaler/receiver/proc/toggle_safety()
	on = !on

/obj/item/assembly/signaler/receiver/activate()
	toggle_safety()
	return TRUE

/obj/item/assembly/signaler/receiver/examine(mob/user)
	. = ..()
	. += span_notice("The radio receiver is [on?"on":"off"].")

/obj/item/assembly/signaler/receiver/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..(signal)

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/obj/item/assembly/signaler/crystal_anomaly/attack_self()
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
	if(istype(user, /mob/living/silicon/pai))
		return TRUE
	. = ..()

