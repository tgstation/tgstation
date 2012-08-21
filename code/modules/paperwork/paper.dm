/obj/item/weapon/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	layer = 4
	pressure_resistance = 1
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	attack_verb = list("")

	var/info	//What's actually written on the paper.
	var/info_links //A different version of the paper which includes html links at fields and EOF
	var/stamps	//The (text for the) stamps on the paper.
	var/fields  //Amount of user created fields
	var/list/stamped
	var/rigged = 0
	var/spam_flag = 0

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"

/obj/item/weapon/paper/New()
	..()
	src.pixel_y = rand(-8, 8)
	src.pixel_x = rand(-9, 9)
	spawn(2)
		if(src.info)
			src.overlays += "paper_words"
		updateinfolinks()
		return

/obj/item/weapon/paper/update_icon()
	if(src.info)
		src.overlays += "paper_words"
	return

/obj/item/weapon/paper/examine()
	set src in oview(1)

//	..()	//We don't want them to see the dumb "this is a paper" thing every time.
	// I didn't like the idea that people can read tiny pieces of paper from across the room.
	// Now you need to be next to the paper in order to read it.
	if(in_range(usr, src))
		if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
			onclose(usr, "[name]")
		else
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
			onclose(usr, "[name]")
	else
		usr << "<span class='notice'>It is too far away.</span>"
	return

/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if ((CLUMSY in usr.mutations) && prob(50))
		usr << "<span class='warning'>You cut yourself on the paper.</span>"
		return
	var/n_name = input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((loc == usr && usr.stat == 0))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	examine()
	if(rigged && (Holiday == "April Fool's Day"))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
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

/obj/item/weapon/paper/proc/addtofield(var/id, var/text, var/links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(1) // I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

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

/obj/item/weapon/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		addtofield(i, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font>"

/obj/item/weapon/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays = null
	updateinfolinks()

/obj/item/weapon/paper/proc/parsepencode(var/t, var/obj/item/weapon/pen/P, mob/user as mob, var/iscrayon = 0)
//	t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)

	t = dd_replacetext(t, "\[center\]", "<center>")
	t = dd_replacetext(t, "\[/center\]", "</center>")
	t = dd_replacetext(t, "\[br\]", "<BR>")
	t = dd_replacetext(t, "\[b\]", "<B>")
	t = dd_replacetext(t, "\[/b\]", "</B>")
	t = dd_replacetext(t, "\[i\]", "<I>")
	t = dd_replacetext(t, "\[/i\]", "</I>")
	t = dd_replacetext(t, "\[u\]", "<U>")
	t = dd_replacetext(t, "\[/u\]", "</U>")
	t = dd_replacetext(t, "\[large\]", "<font size=\"4\">")
	t = dd_replacetext(t, "\[/large\]", "</font>")
	t = dd_replacetext(t, "\[sign\]", "<font face=\"[signfont]\"><i>[user.real_name]</i></font>")
	t = dd_replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")

	if(!iscrayon)
		t = dd_replacetext(t, "\[*\]", "<li>")
		t = dd_replacetext(t, "\[hr\]", "<HR>")
		t = dd_replacetext(t, "\[small\]", "<font size = \"1\">")
		t = dd_replacetext(t, "\[/small\]", "</font>")
		t = dd_replacetext(t, "\[list\]", "<ul>")
		t = dd_replacetext(t, "\[/list\]", "</ul>")

		t = "<font face=\"[deffont]\" color=[P.colour]>[t]</font>"
	else // If it is a crayon, and he still tries to use these, make them empty!
		t = dd_replacetext(t, "\[*\]", "")
		t = dd_replacetext(t, "\[hr\]", "")
		t = dd_replacetext(t, "\[small\]", "")
		t = dd_replacetext(t, "\[/small\]", "")
		t = dd_replacetext(t, "\[list\]", "")
		t = dd_replacetext(t, "\[/list\]", "")

		t = "<font face=\"[crayonfont]\" color=[P.colour]><b>[t]</b></font>"

//	t = dd_replacetext(t, "#", "") // Junk converted to nothing!

	//Count the fields
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields++

	return t


/obj/item/weapon/paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")

/obj/item/weapon/paper/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return

	if(href_list["write"])
		var/id = href_list["write"]
		//var/t = strip_html_simple(input(usr, "What text do you wish to add to " + (id=="end" ? "the end of the paper" : "field "+id) + "?", "[name]", null),8192) as message
		var/t =  strip_html_simple(input("Enter what you want to write:", "Write", null, null)  as message, MAX_MESSAGE_LEN)
		var/obj/item/i = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/weapon/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1


		if ((!in_range(src, usr) && src.loc != usr && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != usr && usr.get_active_hand() != i)) // Some check to see if he's allowed to write
			return

		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			updateinfolinks()

		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]") // Update the window

		if(!overlays.Find("paper_words"))
			overlays += "paper_words"

/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if (istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]")
		//openhelp(user)
		return
	else if(istype(P, /obj/item/weapon/stamp))
		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.get_active_hand() != P))
			return

		stamps += (stamps=="" ? "<HR>" : "<BR>") + "<i>This paper has been stamped with the [P.name].</i>"

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
					usr << "<span class='notice'>You are totally unable to use the stamp. HONK!</span>"
					return
				else
					overlays += "paper_stamped_clown"
			else
				overlays += "paper_stamped"
		if(!stamped)
			stamped = new
		stamped += P.type

		user << "<span class='notice'>You stamp the paper with your rubber stamp.</span>"

	add_fingerprint(user)
	return