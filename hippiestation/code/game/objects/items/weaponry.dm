/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shard))
		var/obj/item/twohanded/spear/S = new /obj/item/twohanded/spear

		remove_item_from_storage(user)
		qdel(I)
		qdel(src)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")

	else if(istype(I, /obj/item/device/assembly/igniter) && !(I.flags_1 & NODROP_1))
		var/obj/item/melee/baton/cattleprod/hippie_cattleprod/P = new /obj/item/melee/baton/cattleprod/hippie_cattleprod

		remove_item_from_storage(user)

		to_chat(user, "<span class='notice'>You fasten [I] to the top of the rod with the cable.</span>")

		qdel(I)
		qdel(src)

		user.put_in_hands(P)
	else
		return ..()

/obj/item/sord/attack(mob/living/M, mob/living/user)
	if(prob(10))
		M.adjustBruteLoss(1)
		visible_message("<span class='greenannounce'>[user] has scored a critical hit on [M]!</span>")
		playsound(src, 'sound/arcade/mana.ogg', 50, 1)
	..()

/obj/item/banhammer/syndicate
	desc = "A banhammer. Upon closer inspection, it appears to have a red tag around its handle."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "toyhammertagged"
	throwforce = 20
	force = 20
	armour_penetration = 100 //Target will be downed in 5 hits before they knew what happened."

/obj/item/banhammer/syndicate/attack(mob/M, mob/user)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(0.1) && H.can_heartattack() && !H.undergoing_cardiac_arrest())
			H.set_heartattack(TRUE)
			if(H.stat == CONSCIOUS)
				H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")
			
