/obj/machinery/atm
	name = "automated transfer machine"
	desc = "A Nanotrasen Bank of Credit ATM, used for trasnferring funds to and from ID cards."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	layer = 3
	anchored = 1
	var/obj/item/weapon/card/id/id = null //ID currently in the ATM
	var/authed = 0 //If the ATM is authenticated

/obj/machinery/atm/examine(mob/user)
	..()
	if(emagged)
		user << "It appears to be in maintenance mode."

/obj/machinery/atm/Destroy()
	EjectId()
	..()

/obj/machinery/atm/emag_act(mob/user)
	emagged = !emagged
	audible_message("<span class='warning'>BZZZZZZzzzzzzz</span>")
	user << "<span class='warning'>You [emagged ? "disable" : "enable"] [src]'s PIN authorization protocols.</span>"

/obj/machinery/atm/power_change()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			icon_state = "dorm_off"
			stat |= NOPOWER
			EjectId() //If we run out of power, eject an ID if we have one

/obj/machinery/atm/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & (NOPOWER|BROKEN))
		return
	if(istype(W, /obj/item/weapon/card/id) && !id && !authed)
		user.drop_item()
		user.visible_message("<span class='notice'>[user] inserts [W] into [src].</span>", \
							 "<span class='notice'>You slide the ID into [src].</span>")
		W.loc = src
		id = W
		AttemptToInterface(user)
	return

/obj/machinery/atm/attack_hand(mob/user)
	AttemptToInterface(user)

/obj/machinery/atm/proc/AttemptToInterface(mob/user)
	/*if(user.key == "Miauw")
		user.gib()
		return
	*/
	if(!ishuman(user))
		user << "<span class='warning'>[src] rejects your attempts to interface with it.</span>"
		return
	if(stat & (BROKEN|NOPOWER))
		user << "<span class='warning'>[src] seems unpowered.</span>"
		return
	if(!id)
		user << "<span class='warning'>[src] has no ID inserted.</span>"
		return
	if(!user.canUseTopic(src))
		return
	icon_state = "dorm_taken"
	if(!authed)
		if(emagged)
			say("Maintenance override detected. Welcome, [id.registered_name].")
			authed = 1
			Interface(user)
			return
		var/code
		code = (input(user, "Enter the PIN number of your ID card.", "Authentication", "[code]") as num)
		say("Validating code...")
		sleep(20)
		if(code != id.pin)
			say("Authentication denied.")
			return EjectId(user)
		else
			say("Authentication accepted. Welcome, [id.registered_name].")
			authed = 1
	Interface(user)

/obj/machinery/atm/proc/Interface(mob/user)
	if(!user.canUseTopic(src)) return
	var/list/options = list("Check Balance", "Change PIN #", "Exit")
	switch(input(user, "Please choose an action.", "ATM Interface", null) in options)
		if("Check Balance")
			if(!user.canUseTopic(src)) return
			user << "<span class='notice'>[id] currently has $[id.credits] stored.</span>"
			return Interface(user)
		if("Change PIN #")
			if(!user.canUseTopic(src)) return
			var/newPin
			newPin = (input(user, "Enter a new PIN number for your ID card.", "PIN Change", "[newPin]") as num)
			newPin = Clamp(newPin, 0001, 9999)
			say("Processing...")
			sleep(20)
			say("PIN change complete.")
			id.pin = newPin
			return Interface(user)
		if("Exit")
			if(!user.canUseTopic(src)) return
			EjectId(user)
			say("Ejecting ID. Thank you for letting us keep your money safe.")
			return

/obj/machinery/atm/proc/EjectId(var/mob/living/carbon/human/user)
	if(!id)
		return
	id.loc = get_turf(src)
	if(in_range(user, src) && istype(user) && user)
		user.put_in_hands(id)
	visible_message("<span class='notice'>[id] slides out of [src].</span>")
	id = null
	if(!emagged)
		icon_state = "dorm_available"
	else
		icon_state = "dorm_inside"
	authed = 0
