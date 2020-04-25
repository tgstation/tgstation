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
	item_state = "card-id"
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
	item_state = "card-id"
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
	if (target.type in type_blacklist)
		to_chat(user, "<span class='warning'>The [target] cannot be affected by the [src]! A more specialized hacking device is required.</span>")
		return FALSE
	return TRUE

/*
 * DOORMAG
 */
/obj/item/card/emag/doormag
	desc = "It's a specialized cryptographic sequencer specifically designed to override station airlock access codes. Seems to crack airlock encryption algorithms by using raw telecrystals."
	name = "airlock authentication override card"
	icon_state = "doormag"
	var/type_whitelist //List of types 
	var/charges = 3
	var/max_charges = 3
	var/charge_tick = 0


/obj/item/card/emag/doormag/Initialize(mapload)
	. = ..()
	type_whitelist = list(subtypesof(/obj/machinery/door/airlock), subtypesof(/obj/machinery/door/window/)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/doormag/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/card/emag/doormag/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/card/emag/doormag/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	charges = min(charges+1, max_charges)
	return TRUE

/obj/item/card/emag/doormag/proc/use_charge(mob/user)
	charges --
	to_chat(user, "<span class='notice'>You use [src]. It now has [charges] charges remaining.</span>")

/obj/item/card/emag/doormag/examine(mob/user)
	. = ..()
	. += "The [src] has the ability to hack [charges] airlocks."







/obj/item/card/emag/doormag/can_emag(atom/target, mob/user)
	if (charges <= 0)
		to_chat(user, "<span class='warning'>[src] is recharging!</span>")
		return FALSE
	if (!(target.type in type_whitelist))
		to_chat(user, "<span class='warning'>[src] is unable to interface with this. It only seems to fit into airlock electronics.</span>")
		return FALSE
	return TRUE

