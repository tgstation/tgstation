/* Clown Items
 * Contains:
 *		Soap
 *		Bike Horns
 *		Air Horns
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
	if(!proximity)
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='warning'>You need to take that [target.name] off before cleaning it!</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("<span class='warning'>[user] begins to scrub \the [target.name] out with [src].</span>")
		if(do_after(user, src.cleanspeed))
			user << "<span class='notice'>You scrub \the [target.name] out.</span>"
			qdel(target)
	else if(ishuman(target) && user.zone_sel && user.zone_sel.selecting == "mouth")
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with [src.name]!</span>") //washes mouth out with soap sounds better than 'the soap' here
		return
	else
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src]...</span>")
		if(do_after(user, src.cleanspeed))
			user << "<span class='notice'>You clean \the [target.name].</span>"
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()
	return


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
	var/honksound = 'sound/items/bikehorn.ogg'
	var/cooldowntime = 20

/obj/item/weapon/bikehorn/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!spam_flag)
		playsound(loc, honksound, 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, honksound, 50, 1)
		src.add_fingerprint(user)
		spawn(cooldowntime)
			spam_flag = 0
	return

/obj/item/weapon/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	honksound = 'sound/items/AirHorn2.ogg'
	cooldowntime = 50