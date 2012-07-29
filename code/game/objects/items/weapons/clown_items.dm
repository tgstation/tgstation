/*
CONTAINS:
NO MORE BANANA, NOW YOU CAN EAT IT. GO SEE OTHER FOOD STUFFS.
BANANA PEEL
SOAP
BIKE HORN

*/

/obj/item/weapon/bananapeel/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.Stun(4)
		M.Weaken(2)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.Stun(8)
		M.Weaken(5)

/obj/item/weapon/soap/HasEntered(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.Stun(3)
		M.Weaken(2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob)
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user << "<span class='notice'>You scrub \the [target.name] out.</span>"
		del(target)
	else
		user << "<span class='notice'>You clean \the [target.name].</span>"
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("\red \the [user] washes \the [target]'s mouth out with soap!")
		return
	..()

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return