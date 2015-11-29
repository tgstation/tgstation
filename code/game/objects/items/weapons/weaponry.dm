/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	flags = FPRINT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")


	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</span>")
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(get_turf(src), 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	user.adjustBruteLoss(0.5)
	return ..()

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	hitsound = "sound/weapons/bloodyslice.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


	IsShield()
		return 1

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)

/obj/item/weapon/claymore/cultify()
	new /obj/item/weapon/melee/cultblade(loc)
	..()

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bloodyslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	hitsound = "sound/weapons/bloodyslice.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
		return(BRUTELOSS)

/obj/item/weapon/katana/IsShield()
		return 1

/obj/item/weapon/katana/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bloodyslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/harpoon
	name = "harpoon"
	sharpness = 1.2
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	hitsound = "sound/weapons/bladeslice.ogg"
	force = 20
	throwforce = 15
	w_class = 3
	attack_verb = list("jabbed","stabbed","ripped")

obj/item/weapon/wirerod
	name = "Wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = FPRINT
	siemens_coefficient = 1
	force = 9
	throwforce = 10
	w_class = 3
	starting_materials = list(MAT_IRON = 1875)
	w_type = RECYK_METAL
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")


obj/item/weapon/wirerod/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/weapon/shard))
		var/obj/item/weapon/spear/S = new /obj/item/weapon/spear

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")
		del(I)
		del(src)

	else if(istype(I, /obj/item/weapon/wirecutters))
		var/obj/item/weapon/melee/baton/cattleprod/P = new /obj/item/weapon/melee/baton/cattleprod

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>")
		del(I)
		del(src)


obj/item/weapon/banhammer/admin
	desc = "A banhammer specifically reserved for admins. Legends tell of a weapon that destroys the target to the utmost capacity"
	throwforce = 999
	force = 999
