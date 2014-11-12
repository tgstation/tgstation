/* Clown Items
 * Contains:
 *		Soap
 *		Bike Horns
 */

/*
 * Soap
 */

/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/cleanspeed = 50 //slower than mop

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of high-class luxury."
	icon_state = "soapdeluxe"
	cleanspeed = 40 //same speed as mop because deluxe -- captain gets one of these

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes

/obj/item/weapon/soap/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(4, 2, src)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("<span class='warning'>[user] begins to scrub \the [target.name] out with [src].</span>")
		if(do_after(user, src.cleanspeed))
			user << "<span class='notice'>You scrub \the [target.name] out.</span>"
			qdel(target)
	else
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		if(do_after(user, src.cleanspeed))
			user << "<span class='notice'>You clean \the [target.name].</span>"
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='danger'>\the [user] washes \the [target]'s mouth out with [src.name]!</span>") //washes mouth out with soap sounds better than 'the soap' here
		return
	..()

/*
 * Bike Horns
 */


/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	attack_verb = list("HONKED")
	var/spam_flag = 0

/obj/item/weapon/bikehorn/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return
//Krotchy doll, hail Postal. by WalterJe

/obj/item/weapon/krotchy
	name = "krotchy doll"
	desc = "The Bad Touch - Krotchy Doll."
	icon = 'icons/obj/krotchy.dmi'
	icon_state = "doll"
	item_state = "doll"
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	attack_verb = list("Played krotchy")
	var/spam_flag = 0

/obj/item/weapon/krotchy/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, "krotchy", 50) //plays instead of tap.ogg!
	return ..()

/obj/item/weapon/krotchy/attack_self(mob/user as mob)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, "krotchy", 50)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return
