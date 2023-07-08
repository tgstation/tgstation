/obj/machinery/telecomms/relay/preset/reebe
	id = "Hierophant Relay"
	hide = TRUE
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "relay"
	broadcasting = FALSE //It only receives
	resistance_flags = INDESTRUCTIBLE
	soundloop = null //for now im just making this be null, might give it something at some point

/obj/machinery/telecomms/relay/preset/reebe/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/encryptionkey) || attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		if(GLOB.current_eminence)
			var/obj/item/encryptionkey/key = attacking_item
			for(var/i in key.channels)
				key.channels[i] = 1
			GLOB.current_eminence.internal_radio.attackby(key, user, params)
	. = ..()

/obj/item/radio/intercom/reebe
	name = "Listening Device"
	freerange = TRUE
