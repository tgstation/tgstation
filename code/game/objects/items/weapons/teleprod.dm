/obj/item/weapon/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"

/obj/item/weapon/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(status && user.disabilities & CLUMSY && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits themself with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		do_teleport(user, get_turf(user), 50)//honk honk
		return
	else
		if(status)
			if(!istype(M) && M.anchored)
				return .
			else
				do_teleport(M, get_turf(M), 15)

/obj/item/weapon/melee/baton/cattleprod/attackby(obj/item/I, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	..()
	if(istype(I, /obj/item/weapon/ore/bluespace_crystal))
		if(!bcell)
			var/obj/item/weapon/melee/baton/cattleprod/teleprod/S = new /obj/item/weapon/melee/baton/cattleprod/teleprod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			user.unEquip(I)
			user.put_in_hands(S)
			user << "<span class='notice'>You clamp the bluespace crystal securely with the wirecutters.</span>"
			I.loc = S//places the crystal into the contents of the prod for later removal
			qdel(src)
		else
			user.visible_message("<span class='warning'>You can't install the crystal onto the stunprod while it has a powercell installed!</span>")

/obj/item/weapon/melee/baton/cattleprod/teleprod/attack_self(mob/user, obj/item/I)//handles removing the bluespace crystal + turning the prod on and off
	if(bcell && bcell.charge > hitcost)
		status = !status
		user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!bcell)
			var/obj/item/weapon/melee/baton/cattleprod/S = new /obj/item/weapon/melee/baton/cattleprod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			var/turf/open/floorloc = get_turf(user)
			floorloc.contents += contents//drops the contents of the prod (the only content should be the crystal) at the user's feet
			user.unEquip(I)
			user.put_in_hands(S)
			user << "<span class='notice'>You carefully remove the bluespace crystal from the teleprod.</span>"
			qdel(I)
			qdel(src)
		else
			user << "<span class='warning'>[src] is out of charge.</span>"
	update_icon()
	add_fingerprint(user)