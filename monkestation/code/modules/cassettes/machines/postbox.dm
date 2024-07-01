/obj/machinery/cassette/mailbox
	name = "Space Board of Music Postbox"
	desc = "Has a slit specifically to fit cassettes into it."

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "postbox"

	max_integrity = 100000 //lol
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE

/obj/machinery/cassette/mailbox/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)


/obj/machinery/cassette/mailbox/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/device/cassette_tape) || !user.client)
		return

	var/obj/item/device/cassette_tape/attacked_tape = weapon

	var/list/admin_count = get_admin_counts(R_FUN)
	if(!length(admin_count["present"]))
		to_chat(user, span_notice("The postbox refuses your cassette, it seems the Space Board is out for lunch."))
		return

	if(attacked_tape.name == "A blank cassette")
		to_chat(user, span_notice("Please name your tape before submitting it you can't change this later!"))
		return

	if(attacked_tape.cassette_desc_string == "Generic Desc")
		to_chat(user, span_notice("Please add a description to your tape before submitting it you can't change this later!"))
		return

	var/list/side1 = attacked_tape.songs["side1"]
	var/list/side2 = attacked_tape.songs["side2"]

	if(!length(side1) && !length(side2))
		to_chat(user, span_notice("Please add some songs to your tape before submitting it you can't change this later!"))
		return

	if(attacked_tape.approved_tape)
		to_chat(user, span_notice("This tape has already been approved by the Board, it would be a waste of money to send it in again."))
		return
	var/choice = tgui_alert(user, "Are you sure this Costs 5k Monkecoins", "Mailbox", list("Yes", "No"))
	if(choice != "Yes")
		return
	///these two parts here should be commented out for local testing without a db
	if(user.client.prefs.metacoins < 5000)
		to_chat(user, span_notice("Sorry you don't have enough Monkecoins to submit a cassette for review."))
		return

	if(!user.client.prefs.adjust_metacoins(user.client.ckey, -5000, donator_multipler = FALSE))
		return
	/// this is where it ends
	attacked_tape.moveToNullspace()
	submit_cassette_for_review(attacked_tape, user)
	return TRUE
