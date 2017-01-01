/obj/item/weapon/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	obj_integrity = 50
	max_integrity = 50

	var/obj/item/weapon/paper/internalPaper
	var/list/stamped = list()

/obj/item/weapon/paperplane/New(loc, obj/item/weapon/paper/newPaper)
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	if(newPaper)
		internalPaper = newPaper
		src.flags = newPaper.flags
		stamped = internalPaper.stamped
		newPaper.forceMove(src)
	else
		internalPaper = new /obj/item/weapon/paper(src)
	update_icon()

/obj/item/weapon/paperplane/suicide_act(mob/user)
	user.Stun(10)
	user.visible_message("<span class='suicide'>[user] jams the [src] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.adjust_blurriness(6)
	user.adjust_eye_damage(rand(6,8))
	sleep(10)
	return (BRUTELOSS)

/obj/item/weapon/paperplane/update_icon()
	cut_overlays()
	if(!stamped)
		stamped = new
	else if(stamped)
		for(var/S in stamped)
			var/obj/item/weapon/stamp/stamp = S
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi', "paperplane_[initial(stamp.icon_state)]")
			add_overlay(stampoverlay)

/obj/item/weapon/paperplane/attack_self(mob/user)
	user << "<span class='notice'>You unfold [src].</span>"
	user.unEquip(src)
	user.put_in_hands(internalPaper)
	qdel(src)

/obj/item/weapon/paperplane/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		user << "<span class='notice'>You should unfold [src] before changing it.</span>"
		return

	else if(istype(P, /obj/item/weapon/stamp)) 	//we don't randomize stamps on a paperplane

		if (!stamped)
			stamped = new

		stamped += P.type
		internalPaper.stamps += "<img src=large_[P.icon_state].png>" //stamps the paper inside!
		internalPaper.stamped = stamped
		internalPaper.attackby(P) //spoofed attack to update internal paper.
		user << "<span class='notice'>You stamp [src] with your rubber stamp.</span>"
		update_icon()

	else if(P.is_hot())
		if(user.disabilities & CLUMSY && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites themselves!</span>", \
				"<span class='userdanger'>You miss the [src] and accidentally light yourself on fire!</span>")
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


/obj/item/weapon/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE)
	. = ..(target, range, speed, thrower, FALSE, diagonals_first)

/obj/item/weapon/paperplane/throw_impact(atom/hit_atom)
	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	var/mob/living/carbon/human/H = hit_atom
	if(prob(2))
		if((H.head && H.head.flags_cover & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || (H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES))
			return
		visible_message("<span class='danger'>\The [src] hits [H] in the eye!</span>")
		H.adjust_blurriness(6)
		H.adjust_eye_damage(rand(6,8))
		H.Weaken(2)
		H.emote("scream")

/obj/item/weapon/paper/AltClick(mob/living/carbon/user, obj/item/I)
	if ( istype(user) )
		if( (!in_range(src, user)) || user.stat || user.restrained() )
			return
		user << "<span class='notice'>You fold [src] into the shape of a plane!</span>"
		user.unEquip(src)
		I = new /obj/item/weapon/paperplane(loc, src)
		user.put_in_hands(I)
	else
		user << "<span class='notice'> You lack the dexterity to fold \the [src]. </span>"
