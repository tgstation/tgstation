/obj/item/radio/radio_mic
	name = "Radio Microphone"
	desc = "Used to talk over the radio"

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "unce_machine"

	radio_host = TRUE
	command = TRUE

	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/item/radio/radio_mic/Initialize(mapload)
	. = ..()
	frequency = FREQ_RADIO
	broadcasting = TRUE
	use_command = TRUE

	perform_update_icon = FALSE
	should_update_icon = FALSE

	set_broadcasting(TRUE)

/obj/item/radio/radio_mic/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	return

/obj/item/radio/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
