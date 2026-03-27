// BUT CIRR IT'S NOT A CARBON WHAT ARE YOU DOING
// sshhhh sshshhhh this isn't for flock agent surgery, this is for fun butcher prizes
// (and some other functionality that didn't fit anywhere else)
/obj/item/implant/radio/flock
	name = "flock radio antenna"
	desc = "It crackles and buzzes like an untuned radio."
	icon = 'icons/obj/devices/voice.dmi' // todo: custom sprite?
	icon_state = "walkietalkie"
	radio_key = /obj/item/encryptionkey/flock
	subspace_transmission = TRUE

/obj/item/implant/radio/flock/Initialize(mapload)
	. = ..()
	radio.name = "flock antenna"

/obj/item/encryptionkey/flock
	name = "eerie encryption key simulacrum"
	desc = "How the hell does alien radio bird technology look exactly like an NT-supplied radio encryption key??"
	icon = 'icons/map_icons/items/encryptionkey.dmi'
	icon_state = "/obj/item/encryptionkey/heads/captain"
	post_init_icon_state = "cypherkey_cube"
	channels = list(
		RADIO_CHANNEL_COMMAND = 1,
		RADIO_CHANNEL_SECURITY = 1,
		RADIO_CHANNEL_ENGINEERING = 1,
		RADIO_CHANNEL_SCIENCE = 1,
		RADIO_CHANNEL_MEDICAL = 1,
		RADIO_CHANNEL_SUPPLY = 1,
		RADIO_CHANNEL_SERVICE = 1,
		RADIO_CHANNEL_AI_PRIVATE = 1,
		RADIO_CHANNEL_ENTERTAINMENT = 1,
		RADIO_CHANNEL_SYNDICATE = 1,
		)
	greyscale_config = /datum/greyscale_config/encryptionkey_cube
	greyscale_colors = "#4dc08b#20d1fd"
