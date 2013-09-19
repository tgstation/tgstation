/* CONTAINS:
 *  Mops
 *  Wet floor signs
 *  Soap
 */

/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/weapon/mop/New()
	create_reagents(5)


obj/item/weapon/mop/proc/clean(turf/simulated/A)
	if(reagents.has_reagent("water", 1))
		A.clean_blood()
		for(var/obj/effect/O in A)
			if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				del(O)
	reagents.reaction(A, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/weapon/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			user << "<span class='notice'>Your mop is dry!</span>"
			return

		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")

		if(do_after(user, 40))
			if(A)
				clean(get_turf(A))
			user << "<span class='notice'>You have finished mopping!</span>"


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap))
		return
	..()


/obj/item/weapon/caution
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/weapon/caution/cone
	name = "warning cone"
	desc = "This cone is trying to warn you of something!"
	icon_state = "cone"


/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/soap/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(3)
		M.Weaken(2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
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