/obj/item/weapon/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = 1
	burn_state = FLAMMABLE
	burntime = 5

	var/obj/item/weapon/paper/internalPaper

/obj/item/weapon/paperplane/New(loc, obj/item/weapon/paper/newPaper)
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	if(newPaper)
		internalPaper = newPaper
		src.flags = newPaper.flags
		newPaper.forceMove(src)
	else
		internalPaper = new /obj/item/weapon/paper(src)


/obj/item/weapon/paperplane/suicide_act(mob/user)
	user.Stun(10)
	user.visible_message("<span class='suicide'>[user] pokes their eyes with the paper plane! It looks like \he's trying to commit sudoku.</span>")
	user.adjust_blurriness(6)
	user.adjust_eye_damage(rand(6,8))
	sleep(10)
	return (BRUTELOSS)

/obj/item/weapon/paperplane/attack_self(mob/user)
	user << "<span class='notice'>You unfold [src].</span>"
	user.unEquip(src)
	user.put_in_hands(internalPaper)
	qdel(src)

/obj/item/weapon/paperplane/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon) || istype(P, /obj/item/weapon/stamp))
		user << "<span class='notice'>You should unfold [src] before changing it.</span>"
		return
	if(P.is_hot())
		if(user.disabilities & CLUMSY && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites themselves!</span>", \
				"<span class='userdanger'>You miss the paper plane and accidentally light yourself on fire!</span>")
			user.unEquip(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.unEquip(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)


/obj/item/weapon/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=0) //prevent the paper plane from spinning
	if(!..())
		return

/obj/item/weapon/paperplane/throw_impact(atom/hit_atom)
	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	var/mob/living/carbon/human/H = hit_atom
	if(prob(15))
		if((H.head && H.head.flags_cover & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || (H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES))
			return
		visible_message("<span class='danger'>\The [src] hits [H] in the eye!</span>")
		H.adjust_blurriness(6)
		H.adjust_eye_damage(rand(6,8))
		H.Weaken(2)
		H.emote("scream")

/obj/item/weapon/paper/AltClick(mob/living/carbon/user, obj/item/I,)
	if((!in_range(src, user)) || usr.stat || usr.restrained())
		return
	user << "<span class='notice'>You fold [src] into the shape of a plane!</span>"
	user.unEquip(src)
	I = new /obj/item/weapon/paperplane(loc, src)
	user.put_in_hands(I)

