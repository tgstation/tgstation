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
	var/door_deny = 'sound/machines/buzz/buzz-sigh.ogg'

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
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/machinery/door/password/get_save_vars()
	return ..() + NAMEOF(src, password)

/obj/machinery/door/password/Hear(atom/movable/speaker, message_language, raw_message, radio_freq, radio_freq_name, radio_freq_color, list/spans, list/message_mods = list(), message_range)
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
			run_animation(DOOR_DENY_ANIMATION)

/obj/machinery/door/password/update_icon_state()
	. = ..()
	//Deny animation would be nice to have.
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			icon_state = "opening"
		if(DOOR_CLOSING_ANIMATION)
			icon_state = "closing"
		else
			icon_state = density ? "closed" : "open"

/obj/machinery/door/password/animation_length(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			return 1.1 SECONDS
		if(DOOR_CLOSING_ANIMATION)
			return 1.1 SECONDS

/obj/machinery/door/password/animation_segment_delay(animation)
	switch(animation)
		if(DOOR_OPENING_PASSABLE)
			return 0.5 SECONDS
		if(DOOR_OPENING_FINISHED)
			return 1.1 SECONDS
		if(DOOR_CLOSING_UNPASSABLE)
			return 0.2 SECONDS
		if(DOOR_CLOSING_FINISHED)
			return 1.1 SECONDS

/obj/machinery/door/password/animation_effects(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			playsound(src, door_open, 50, TRUE)
		if(DOOR_CLOSING_ANIMATION)
			playsound(src, door_close, 50, TRUE)
		if(DOOR_DENY_ANIMATION)
			playsound(src, door_deny, 30, TRUE)

/obj/machinery/door/password/proc/ask_for_pass(mob/user)
	var/guess = tgui_input_text(user, "Enter the password", "Password", max_length = MAX_MESSAGE_LEN)
	if(guess == password)
		return TRUE
	return FALSE

/obj/machinery/door/password/ex_act(severity, target)
	return FALSE
