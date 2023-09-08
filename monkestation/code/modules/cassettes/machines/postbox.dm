/obj/machinery/cassette/mailbox
	name = "Space Board of Music Postbox"
	desc = "Has a slit specifically to fit cassettes into it."

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "postbox"

	max_integrity = 100000 //lol
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE


/obj/machinery/cassette/mailbox/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/device/cassette_tape) || !user.client)
		return

	var/obj/item/device/cassette_tape/attacked_tape = weapon
	if(attacked_tape.approved_tape)
		to_chat(user, span_notice("This tape has already been approved by the Board, it would be a waste of money to send it in again."))
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
