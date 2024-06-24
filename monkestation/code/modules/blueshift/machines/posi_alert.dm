/obj/machinery/posialert
	name = "automated positronic alert console"
	desc = "A console that will ping when a positronic personality is available for download."
	icon = 'monkestation/code/modules/blueshift/icons/terminals.dmi'
	icon_state = "posialert"
	// to create a cooldown so if roboticists are tired of ghosts
	COOLDOWN_DECLARE(robotics_cooldown)
	/// the reason that the console is muted (player decided)
	var/mute_reason
	// to create a cooldown so ghosts cannot spam it
	COOLDOWN_DECLARE(ghost_cooldown)
	/// The encryption key typepath that will be used by the console.
	var/radio_key = /obj/item/encryptionkey/headset_sci
	/// The radio used to send messages over the science channel.
	var/obj/item/radio/radio

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/posialert, 28)

/obj/machinery/posialert/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, robotics_cooldown))
		. += span_notice("Remaining time on mute is [COOLDOWN_TIMELEFT(src, robotics_cooldown) * 0.1] seconds.")
		. += span_notice("Mute reason: [mute_reason]")
	. += span_notice("Press the screen to mute or unmute the console.")

/obj/machinery/posialert/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/machinery/posialert/Destroy()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/posialert/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, robotics_cooldown))
		COOLDOWN_RESET(src, robotics_cooldown)
		to_chat(user, span_notice("You have removed the mute on [src]."))
		return
	mute_reason = null
	mute_reason = stripped_input(user, "What would the reason for the mute be? (max characters is 20)", "Mute Reason", "", 20)
	if(!mute_reason)
		to_chat(user, span_warning("[src] requires a reason to mute!"))
		return
	COOLDOWN_START(src, robotics_cooldown, 5 MINUTES)
	to_chat(user, span_notice("You have muted [src] for five minutes."))

/obj/machinery/posialert/attack_ghost(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, robotics_cooldown))
		to_chat(user, span_warning("[src] has been muted! Remaining time on mute is [COOLDOWN_TIMELEFT(src, robotics_cooldown) * 0.1] seconds."))
		to_chat(user, span_warning("[src]'s mute reason: [mute_reason]"))
		return
	if(!COOLDOWN_FINISHED(src, ghost_cooldown))
		to_chat(user, span_warning("[src] is currently still on cooldown! Remaining time on cooldown is [COOLDOWN_TIMELEFT(src, ghost_cooldown) * 0.1] seconds."))
		return
	COOLDOWN_START(src, ghost_cooldown, 30 SECONDS)
	flick("posialertflash",src)
	say("There are positronic personalities available.")
	radio.talk_into(src, "There are positronic personalities available.", RADIO_CHANNEL_SCIENCE)
	playsound(loc, 'sound/machines/ping.ogg', 50)
