/*
 * TODO:
 * Decide if we need fingerprints on this obj
 * Decide which other mob can use this
 * Sprite bar sign that is destroyed
 * Sprite bar sign that is unpowered
 * Add this obj to power consumers
 * Decide how much power this uses
 * Make this constructable with a decided step how to construct it
 * Make this deconstructable with a decided step how to deconstruct it
 * Decide what materials are used for this obj
 * Logic for area because it's a two tile consuming obj
 * Is this obj can be emagged? if yes what can be the trace that this obj is emagged?
 *									(I suggest broken ID authentication wiring)
 * Need more frames for existing bar signs (icons/obj/barsigns.dmi)
 * An ID scanner that will makes sound and
 *		output something that's the access has been granted
 */

/obj/structure/sign/double/barsign	// The sign is 64x32, so it needs two tiles. ;3
	name = "--------"
	desc = "a bar sign"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"

	req_access = list(access_bar)

	var/list/sign_list = list("Armok's Bar N Grill",
							  "The Broken Drum",
							  "The Limbo",
							  "The Magma Sea",
							  "The Pink Flamingo",
							  "The Rusty Axe",
							  "Meadbay",
							  "Cindi Kate's",
							  "The Cavern",
							  "The Clown's Head",
							  "The Orchard",
							  "The Saucy Clown",
							  "The Damn Wall",
							  "Whiskey Implant",
							  "Carpe Carp",
							  "Robust Roadhouse",
							  "The Grey Tide",
							  "The Redshirt",
							  "Maltese Falcon",
							  "--------")

	var/sign_name = ""

/obj/structure/sign/double/barsign/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/sign/double/barsign/attack_hand(mob/user as mob)
	if (!src.allowed(user))
		user << "\red Access denied."
		return

	if (!(get_dir(src, usr) in list(SOUTHWEST, SOUTH, SOUTHEAST)))
		return

	pick_sign(sign_list)

/obj/structure/sign/double/barsign/proc/pick_sign(var/list/L)
	var/previous_sign = sign_name
	var/previous_sign_index = L.Find(sign_name)

	L.Remove(sign_name)
	L.Add("Cancel")

	switch (input("Available Signage", "Bar Sign") in L)

		/*
		 * Template for adding new bar signs
		 *
		 *        if ("element on var/list/sign_list")
		 *               sign_name = "name of bar Sign"
		 *               sign_icon = "state of icon on icons/obj/barsigns.dmi"
		 */

		if ("Armok's Bar N Grill")
			sign_name = "Armok's Bar N Grill"
			icon_state = "armokbar"

		if ("The Broken Drum")
			sign_name = "The Broken Drum"
			icon_state = "brokendrum"

		if ("The Limbo")
			sign_name = "The Limbo"
			icon_state = "limbo"

		if ("The Magma Sea")
			sign_name = "The Magma Sea"
			icon_state = "magmasea"

		if ("The Pink Flamingo")
			sign_name = "The Pink Flamingo"
			icon_state = "pinkflamingo"

		if ("The Rusty Axe")
			sign_name = "The Rusty Axe"
			icon_state = "rustyaxe"

		if ("Meadbay")
			sign_name = "Meadbay"
			icon_state = "meadbay"

		if ("Cindi Kate's")
			sign_name = "Cindi Kate's"
			icon_state = "cindikate"

		if ("The Cavern")
			sign_name = "The Cavern"
			icon_state = "thecavern"

		if ("The Clown's Head")
			sign_name = "The Clown's Head"
			icon_state = "theclownshead"

		if ("The Orchard")
			sign_name = "The Orchard"
			icon_state = "theorchard"

		if ("The Saucy Clown")
			sign_name = "The Saucy Clown"
			icon_state = "thesaucyclown"

		if ("The Damn Wall")
			sign_name = "The Damn Wall"
			icon_state = "thedamnwall"

		if ("Whiskey Implant")
			sign_name = "Whiskey Implant"
			icon_state = "whiskeyimplant"

		if ("Carpe Carp")
			sign_name = "Carpe Carp"
			icon_state = "carpecarp"

		if ("Robust Roadhouse")
			sign_name = "Robust Roadhouse"
			icon_state = "robustroadhouse"

		if ("The Grey Tide")
			sign_name = "The Grey Tide"
			icon_state = "greytide"

		if ("The Redshirt")
			sign_name = "Redshirt"
			icon_state = "theredshirt"

		if ("Maltese Falcon")
			sign_name = "Maltese Falcon"
			icon_state = "maltesefalcon"

		if ("--------")
			sign_name = "--------"
			icon_state = "empty"

		if ("Cancel")
			L.Remove("Cancel")
			L.Insert(previous_sign_index, previous_sign)
			return

	L.Remove("Cancel")
	L.Insert(previous_sign_index, previous_sign)

	desc = "It displays ``[sign_name]''."
