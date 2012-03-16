/obj/item/weapon/paper
	name = "paper"
	gender = PLURAL
	icon = 'bureaucracy.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	layer = 4
	var/info	//What's actually written on the paper.
	var/stamps	//The (text for the) stamps on the paper.
	var/list/stamped
	var/see_face = 1
	var/body_parts_covered = HEAD
	var/protective_temperature = 0

/obj/item/weapon/paper/New()

	..()
	src.pixel_y = rand(-8, 8)
	src.pixel_x = rand(-9, 9)
	spawn(2)
		if(src.info)
			src.overlays += "paper_words"
		return

/obj/item/weapon/paper/update_icon()
	if(src.info)
		src.overlays += "paper_words"
	return

/obj/item/weapon/paper/examine()
	set src in oview(1)

//	..()	//We don't want them to see the dumb "this is a paper" thing every time.
	if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	return

/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red You cut yourself on the paper."
		return
	var/n_name = input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((loc == usr && usr.stat == 0))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	examine()
	return

/obj/item/weapon/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if (istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if (dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	return

/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if (istype(P, /obj/item/weapon/pen))
		var/t = strip_html_simple(input(user, "What text do you wish to add?", "[name]", null),8192)  as message

		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return

		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		t = dd_replacetext(t, "\[center\]", "<center>")
		t = dd_replacetext(t, "\[/center\]", "</center>")
		t = dd_replacetext(t, "\[list\]", "<ul>")
		t = dd_replacetext(t, "\[/list\]", "</ul>")
		t = dd_replacetext(t, "\[*\]", "<li>")
		t = dd_replacetext(t, "\[*\]", "<li>")
		t = dd_replacetext(t, "\[br\]", "<BR>")
		t = dd_replacetext(t, "\[hr\]", "<HR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = dd_replacetext(t, "\[small\]", "<font size = \"1\">")
		t = dd_replacetext(t, "\[/small\]", "</font>")
		t = dd_replacetext(t, "\[large\]", "<font size = \"4\">")
		t = dd_replacetext(t, "\[/large\]", "</font>")
		t = dd_replacetext(t, "\[sign\]", "<font face=vivaldi>[user.real_name]</font>")

		var/obj/item/weapon/pen/i = P
		t = "<font face=calligrapher color=[i.colour]>[t]</font>"

		if(!overlays.Find("paper_words"))
			overlays += "paper_words"
		info += t
		return

	if(istype(P, /obj/item/toy/crayon))
		var/t = strip_html_simple(input(user, "What text do you wish to add?", "[name]", null),8192)  as message

		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return

		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		t = dd_replacetext(t, "\[center\]", "<center>")
		t = dd_replacetext(t, "\[/center\]", "</center>")
		t = dd_replacetext(t, "\[br\]", "<BR>")
		t = dd_replacetext(t, "\[b\]", "")
		t = dd_replacetext(t, "\[/b\]", "")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = dd_replacetext(t, "\[large\]", "<font size = \"4\">")
		t = dd_replacetext(t, "\[/large\]", "</font>")
		t = dd_replacetext(t, "\[sign\]", "<I>[user.real_name]</I>")

		var/obj/item/toy/crayon/i = P
		t = "<font face=\"Comic Sans MS\" color=[i.colour]><B>[t]</B></font>"

		if(!overlays.Find("paper_words"))
			overlays += "paper_words"
		info += t
		return

	else
		if(istype(P, /obj/item/weapon/stamp))
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return
			if(stamps)
				stamps += "<BR><i>This paper has been stamped with the [P.name].</i>"
			else
				stamps += "<HR><i>This paper has been stamped with the [P.name].</i>"
			switch(P.type)
				if(/obj/item/weapon/stamp/captain)
					overlays += "paper_stamped_cap"
				if(/obj/item/weapon/stamp/hop)
					overlays += "paper_stamped_hop"
				if(/obj/item/weapon/stamp/hos)
					overlays += "paper_stamped_hos"
				if(/obj/item/weapon/stamp/ce)
					overlays += "paper_stamped_ce"
				if(/obj/item/weapon/stamp/rd)
					overlays += "paper_stamped_rd"
				if(/obj/item/weapon/stamp/cmo)
					overlays += "paper_stamped_cmo"
				if(/obj/item/weapon/stamp/denied)
					overlays += "paper_stamped_denied"
				if(/obj/item/weapon/stamp/clown)
					if (!clown)
						usr << "\red You are totally unable to use the stamp. HONK!"
						return
					else
						overlays += "paper_stamped_clown"
				else
					overlays += "paper_stamped"
			if(!stamped)
				stamped = new
			stamped += P.type

			user << "\blue You stamp the paper with your rubber stamp."
	add_fingerprint(user)
	return