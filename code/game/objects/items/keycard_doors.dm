/obj/machinery/door/keycard
	name = "locked door"
	desc = "This door only opens when a keycard is swiped. It looks virtually indestructable."
	icon = 'icons/obj/doors/puzzledoor/default.dmi'
	icon_state = "door_closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	/// Make sure that the key has the same puzzle_id as the keycard door!
	var/puzzle_id = null
	/// Message that occurs when the door is opened
	var/open_message = "The door beeps, and slides opens."

//Standard Expressions to make keycard doors basically un-cheeseable
/obj/machinery/door/keycard/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/keycard/emp_act(severity)
	return

/obj/machinery/door/keycard/ex_act(severity, target)
	return FALSE

/obj/machinery/door/keycard/try_to_activate_door(mob/user, access_bypass = FALSE)
	add_fingerprint(user)
	if(operating)
		return

/obj/machinery/door/keycard/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I,/obj/item/keycard))
		var/obj/item/keycard/key = I
		if((!puzzle_id || puzzle_id == key.puzzle_id)  && density)
			if(open_message)
				to_chat(user, span_notice("[open_message]"))
			open()
			return
		else if(puzzle_id != key.puzzle_id)
			to_chat(user, span_notice("[src] buzzes. This must not be the right key."))
			return
		else
			to_chat(user, span_notice("This door doesn't appear to close."))
			return

//Test doors. Gives admins a few doors to use quickly should they so choose for events.
/obj/machinery/door/keycard/yellow_required
	name = "blue airlock"
	desc = "It looks like it requires a yellow keycard."
	puzzle_id = "yellow"

/obj/machinery/door/keycard/blue_required
	name = "blue airlock"
	desc = "It looks like it requires a blue keycard."
	puzzle_id = "blue"

//Doors Below
/obj/machinery/door/keycard/syndicate_bomb
	name = "Syndicate Ordinance Laboratory"
	desc = "Locked. Looks like you'll need a special access key to get in."
	puzzle_id = "syndicate_bomb"

/obj/machinery/door/keycard/syndicate_bio
	name = "Syndicate Bio-Weapon Laboratory"
	desc = "Locked. Looks like you'll need a special access key to get in."
	puzzle_id = "syndicate_bio"

/obj/machinery/door/keycard/syndicate_chem
	name = "Syndicate Chemical Manufacturing Plant"
	desc = "Locked. Looks like you'll need a special access key to get in"
	puzzle_id = "syndicate_chem"

/obj/machinery/door/keycard/syndicate_fridge
	name = "The Walk-In Fridge"
	desc = "Locked. Lopez sure runs a tight galley."
	puzzle_id = "syndicate_fridge"
