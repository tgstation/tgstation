/obj/machinery/door/password
	name = "door"
	desc = "This door only opens when provided a password."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor_type = /datum/armor/door_password
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	/// Password that must be provided to open the door.
	var/password = "Swordfish"
	/// Setting to true allows the user to input the password through a text box after clicking on the door.
	var/interaction_activated = TRUE
	/// Say the password nearby to open the door.
	var/voice_activated = FALSE
	/// Sound used upon opening.
	var/door_open = 'sound/machines/blastdoor.ogg'
	/// Sound used upon closing.
	var/door_close = 'sound/machines/blastdoor.ogg'
	/// Sound used upon denying.
	var/door_deny = 'sound/machines/buzz-sigh.ogg'

/obj/machinery/door/password/voice
	voice_activated = TRUE


/datum/armor/door_password
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/machinery/door/password/Initialize(mapload)
	. = ..()
	if(voice_activated)
		become_hearing_sensitive()

/obj/machinery/door/password/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(!density || !voice_activated || radio_freq)
		return
	if(findtext(raw_message, password))
		open()

/obj/machinery/door/password/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/password/try_to_activate_door(mob/user, access_bypass = FALSE)
	add_fingerprint(user)
	if(operating)
		return
	if(density)
		if(access_bypass || ask_for_pass(user))
			open()
		else
			do_animate("deny")

/obj/machinery/door/password/update_icon_state()
	. = ..()
	icon_state = density ? "closed" : "open"

/obj/machinery/door/password/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, door_open, 50, TRUE)
		if("closing")
			flick("closing", src)
			playsound(src, door_close, 50, TRUE)
		if("deny")
			//Deny animation would be nice to have.
			playsound(src, door_deny, 30, TRUE)

/obj/machinery/door/password/proc/ask_for_pass(mob/user)
	var/guess = tgui_input_text(user, "Enter the password", "Password")
	if(guess == password)
		return TRUE
	return FALSE

/obj/machinery/door/password/emp_act(severity)
	return

/obj/machinery/door/password/ex_act(severity, target)
	return FALSE
