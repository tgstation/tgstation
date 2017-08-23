/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod_nocell"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"
	slot_flags = null

/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(status && user.disabilities & CLUMSY && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits themself with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		if(do_teleport(user, get_turf(user), 50))//honk honk
			user.Knockdown(stunforce*3)
			deductcharge(hitcost)
		else
			user.Knockdown(stunforce*3)
			deductcharge(hitcost/4)
		return
	else
		if(status)
			if(!istype(M) && M.anchored)
				return .
			else
				do_teleport(M, get_turf(M), 15)

/obj/item/melee/baton/cattleprod/attackby(obj/item/I, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(istype(I, /obj/item/ore/bluespace_crystal))
		if(!cell)
			var/obj/item/melee/baton/cattleprod/teleprod/S = new /obj/item/melee/baton/cattleprod/teleprod
			remove_item_from_storage(user)
			qdel(src)
			qdel(I)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>You place the bluespace crystal firmly into the igniter.</span>")
		else
			user.visible_message("<span class='warning'>You can't put the crystal onto the stunprod while it has a power cell installed!</span>")
	else
		return ..()
