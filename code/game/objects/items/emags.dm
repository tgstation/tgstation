/* Emags
 * Contains:
 *		EMAGS AND DOORMAGS
 */


/*
 * EMAG AND SUBTYPES
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	var/prox_check = TRUE //If the emag requires you to be in range
	var/type_blacklist //List of types that require a specialized emag

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	prox_check = FALSE

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "It's a pumpkin with a cryptographic sequencer sticking out."
	icon_state = "hack_o_lantern"

/obj/item/card/emagfake
	desc = "It's a card with a magnetic strip attached to some circuitry. Closer inspection shows that this card is a poorly made replica, with a \"DonkCo\" logo stamped on the back."
	name = "cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/emagfake/afterattack()
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)

/obj/item/card/emag/Initialize(mapload)
	. = ..()
	type_blacklist = list(subtypesof(/obj/machinery/door/airlock), subtypesof(/obj/machinery/door/window/)) //list of all typepaths that require a specialized emag to hack.

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return
	if(!can_emag(target, user))
		return
	log_combat(user, A, "attempted to emag")
	A.emag_act(user, src)

/obj/item/card/emag/proc/can_emag(atom/target, mob/user)
	for (var/subtypelist in type_blacklist)
		if (target.type in subtypelist)
			to_chat(user, "<span class='warning'>The [target] cannot be affected by the [src]! A more specialized hacking device is required.</span>")
			return FALSE
	return TRUE

/*
 * DOORMAG
 */
/obj/item/card/emag/doorjack
	desc = "Commonly known as a \"doorjack\", this device is a specialized cryptographic sequencer specifically designed to override station airlock access codes. Uses self-refilling charges to hack airlocks."
	name = "airlock authentication override card"
	icon_state = "doorjack"
	var/type_whitelist //List of types
	var/charges = 3
	var/max_charges = 3
	var/list/charge_timers = list()
	var/charge_time = 1800 //three minutes

/obj/item/card/emag/doorjack/Initialize(mapload)
	. = ..()
	type_whitelist = list(subtypesof(/obj/machinery/door/airlock), subtypesof(/obj/machinery/door/window/)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/doorjack/proc/use_charge(mob/user)
	charges --
	to_chat(user, "<span class='notice'>You use [src]. It now has [charges] charges remaining.</span>")
	charge_timers.Add(addtimer(CALLBACK(src, .proc/recharge), charge_time, TIMER_STOPPABLE))

/obj/item/card/emag/doorjack/proc/recharge(mob/user)
	charges = min(charges+1, max_charges)
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE)
	charge_timers.Remove(charge_timers[1])

/obj/item/card/emag/doorjack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has [charges] charges remaining.</span>"
	if (length(charge_timers))
		. += "<span class='notice'><b>A small display on the back reads:</span></b>"
	for (var/i in 1 to length(charge_timers))
		var/timeleft = timeleft(charge_timers[i])
		var/loadingbar = num2loadingbar(timeleft/charge_time)
		. += "<span class='notice'><b>CHARGE #[i]: [loadingbar] ([timeleft*0.1]s)</b></span>"

/obj/item/card/emag/doorjack/can_emag(atom/target, mob/user)
	if (charges <= 0)
		to_chat(user, "<span class='warning'>[src] is recharging!</span>")
		return FALSE
	for (var/list/subtypelist in type_whitelist)
		if (target.type in subtypelist)
			return TRUE
	to_chat(user, "<span class='warning'>[src] is unable to interface with this. It only seems to fit into airlock electronics.</span>")
	return FALSE

