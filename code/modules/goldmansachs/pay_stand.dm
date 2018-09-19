/obj/machinery/paystand
	name = "Pay Stand ($0)"
	desc = "Owned by . Pays directly into his account when swiped with an ID card."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	density = FALSE
	anchored = TRUE
	var/price = 0
	var/obj/item/card/id/my_card

/obj/machinery/paystand/proc/relocate(area/new_area)
	say("We're moving to a new location at [new_area]! See you capitalist consumers there!")
	qdel(src)

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(!my_card)
		say("ERROR: NO OWNER FOUND, SELF DESTRUCTION IMMINENT!!!")
		qdel(src)
	if(istype(W, /obj/item/stack/spacecash))
		say("What is this, the 2000s? We only take card here.")
		return
	if(istype(W, /obj/item/coin))
		say("What is this, the 1800s? We only take card here.")
		return
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/vbucks = W
		if(vbucks.registered_account)
			if(vbucks.registered_account.adjust_money(-1 * price))
				my_card.registered_account.adjust_money(price)
				my_card.say("Purchase made at your vendor by [vbucks.registered_account.account_holder] for $[price].")
				say("Thanks for purchasing! The vendor has been informed.")
				return
			else
				say("You trying to punk me, kid? Come back when you have the cash.")
				return
		else
			say("You're going to need an actual bank account for that one, buddy.")
			return
