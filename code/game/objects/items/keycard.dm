/obj/item/keycard
	name = "security keycard"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "keycard"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/puzzle_id = null

//Two test keys for use alongside the two test doors.
/obj/item/keycard/yellow
	name = "yellow keycard"
	desc = "A yellow keycard. How fantastic. Looks like it belongs to a high security door."
	color = "#f0da12"
	puzzle_id = "yellow"

/obj/item/keycard/blue
	name = "blue keycard"
	desc = "A blue keycard. How terrific. Looks like it belongs to a high security door."
	color = "#3bbbdb"
	puzzle_id = "blue"

//Keycards Below
/obj/item/keycard/syndicate_bomb
	name = "Syndicate Ordnance Laboratory Access Card"
	desc = "A red keycard with an image of a bomb. Using this will allow you to gain access to the Ordnance Lab in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_bomb"

/obj/item/keycard/syndicate_bio
	name = "Syndicate Bio-Weapon Laboratory Access Card"
	desc = "A red keycard with a biohazard symbol. Using this will allow you to gain access to the Bio-Weapon Lab in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_bio"

/obj/item/keycard/syndicate_chem
	name = "Syndicate Chemical Plant Access Card"
	desc = "A red keycard with an image of a beaker. Using this will allow you to gain access to the Chemical Manufacturing Plant in Firebase Balthazord."
	color = "#9c0e26"
	puzzle_id = "syndicate_chem"

/obj/item/keycard/syndicate_fridge
	name = "Lopez's Access Card"
	desc = "A grey keycard with Lopez's Information on it. This is your ticket into the Fridge in Firebase Balthazord."
	color = "#636363"
	puzzle_id = "syndicate_fridge"
