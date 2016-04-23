/obj/item/weapon/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = 1
	layer = 3
	pressure_resistance = 0
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	burn_state = FLAMMABLE
	burntime = 5

	var/info
	var/info_links
	var/stamps
	var/fields
	var/list/stamped
	var/rigged
	var/spam_flag


/obj/item/weapon/paperplane/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	src.CheckParts(src.loc)
	updateinfolinks()
	update_icon()


/obj/item/weapon/paperplane/update_icon()
	if(burn_state == ON_FIRE)
		overlays += "paperplane_onfire"
		return
	if(info)
		return
	icon_state = "paperplane"

/obj/item/weapon/paperplane/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.Cut()
	updateinfolinks()
	update_icon()

/obj/item/weapon/paperplane/suicide_act(mob/user)
	user.Stun(10)
	user.visible_message("<span class='suicide'>[user] pokes their eyes with the paper plane! It looks like \he's trying to commit sudoku..</span>")
	user.adjust_blurriness(6)
	user.adjust_eye_damage(rand(6,8))
	sleep(10)
	return (BRUTELOSS)

/obj/item/weapon/paperplane/proc/addtofield(id, text, links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(1)	//I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart == 0)
			return	//No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/weapon/paperplane/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		addtofield(i, "<font face=\"[PEN_FONT]\"><A href='?src=\ref[src];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[PEN_FONT]\"><A href='?src=\ref[src];write=end'>write</A></font>"


/obj/item/weapon/paperplane/attackby(obj/item/weapon/P, mob/living/carbon/human/user, params)
	..()
	if(burn_state == ON_FIRE)
		return
	if(is_blind(user))
		return
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		user << "<span class='notice'>You should unfold the paper before writing a note.</span>"
		return
	if(istype(P, /obj/item/weapon/stamp))
		if(!in_range(src, usr) && loc != user && !istype(loc, /obj/item/weapon/clipboard) && loc.loc != user && user.get_active_hand() != P)
			return

		stamps += "<img src=large_[P.icon_state].png>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		stampoverlay.icon_state = "paper_[P.icon_state]"

		if(!stamped)
			stamped = new
		stamped += P.type
		overlays += stampoverlay

		user << "<span class='notice'>You stamp the paper plane with your rubber stamp.</span>"

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


/obj/item/weapon/paperplane/fire_act()
	..(0)
	icon_state = null //so the sprites don't stack
	info = "[stars(info)]"
	update_icon()

/obj/item/weapon/paperplane/extinguish()
	..()
	update_icon()


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

// Dear PKPenguin321
// We need to make sure this AltClick doesn't override the child objects (aka talismans)
// We need to define the AltClick on Child, Force Do Not Load, then return.
// How to define on all child? Force do not load? Your advice is appreciated

/obj/item/weapon/paper/AltClick(mob/user, obj/item/I,)
	if(istype(src, /obj/item/weapon/paper/talisman)) //doesn't fuck with cult
		user << "<span class='notice'>You can't fold this type of paper... yet.</span>>"
		return
	if(!in_range(src, user))
		return
	if(!istype(src, /obj/item/weapon/paper/talisman)) //doesn't fuck with cult
		user << "<span class='notice'>You fold the paper in the shape of a plane!</span>"
		if(do_after(user, 20, target = src))
			user.drop_item(src)
			I = new /obj/item/weapon/paperplane(src.loc)
			user.put_in_hands(I)
			src.forceMove(I)
			I.CheckParts()
		return

/obj/item/weapon/paperplane/AltClick(mob/user, obj/item/I,)
	if(!in_range(src, user))
		return
	if(istype(src, /obj/item/weapon/paperplane))
		user << "<span class='notice'>You unfold the paper plane!</span>"
		if(do_after(user, 10, target = src))
			user.drop_item(src)
			I = new /obj/item/weapon/paper(src.loc)
			user.put_in_hands(I)
			src.forceMove(I)
			I.CheckParts()
		return

/obj/item/weapon/paper/CheckParts()
	var/obj/item/weapon/paperplane/P = locate(/obj/item/weapon/paperplane) in src
	if(P)
		src.info = P.info
		src.stamps = P.stamps
		if(P.stamped)
			src.stamped = P.stamped.Copy()
		src.rigged = P.rigged
		src.overlays = P.overlays
		qdel(P)
		P.updateinfolinks()
	update_icon()

/obj/item/weapon/paperplane/CheckParts()
	var/obj/item/weapon/paper/P = locate(/obj/item/weapon/paper) in src
	if(P)
		src.info = P.info
		src.stamps = P.stamps
		if(P.stamped)
			src.stamped = P.stamped.Copy()
		src.rigged = P.rigged
		src.overlays = P.overlays
		qdel(P)
		P.updateinfolinks()
	update_icon()
