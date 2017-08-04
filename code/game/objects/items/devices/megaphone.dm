/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/spamcheck = 0
	var/emagged = FALSE
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/device/megaphone/get_held_item_speechspans(mob/living/carbon/user)
	if(spamcheck > world.time)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
	else
		playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
		spamcheck = world.time + 50
		return voicespan

/obj/item/device/megaphone/emag_act(mob/user)
	if(emagged)
		return
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	emagged = TRUE
	voicespan = list(SPAN_REALLYBIG, "userdanger")

/obj/item/device/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"

/obj/item/device/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"

/obj/item/device/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"

/obj/item/device/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)