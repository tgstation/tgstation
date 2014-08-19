/*
 * nano paper
 *
 *
 * this basicaly a modified copy/paste of paper.dm
 */

/obj/item/weapon/nano_paper
	name = "Nano paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "nano_paper"
	throwforce = 0
	w_class = 1.0
	throw_range = 1
	throw_speed = 1
	layer = 3.9
	pressure_resistance = 1
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	attack_verb = list("slapped")
	autoignition_temperature = AUTOIGNITION_PAPER

	var/info		//What's actually written on the paper.
	var/info_links
	var/fields		//Amount of user created fields
	var/rigged = 0
	var/spam_flag = 0
	var/log=""
	var/const/deffont = "Sans-Serif" // looks more digital
	var/const/signfont = "Times New Roman"

/obj/item/weapon/nano_paper/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	spawn(2)
		update_icon()
		updateinfolinks()
		return

/obj/item/weapon/nano_paper/update_icon()
	if(info)
		icon_state = "nano_paper_words"
		return
	icon_state = "nano_paper"

/obj/item/weapon/nano_paper/examine()
	set src in oview(1)

	// if in range, show whats on the paper.
	if(in_range(usr, src))
		if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]</BODY></HTML>", "window=[name]")
			onclose(usr, "[name]")
		else
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]</BODY></HTML>", "window=[name]")
			onclose(usr, "[name]")
	else
		usr << "<span class='notice'>This is Nano paper, I should get closer to see its contents...</span>"
	return

/obj/item/weapon/nano_paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	// Didn't feel like this was appropriate for a paper that is made of plastic
	//if((M_CLUMSY in usr.mutations) && prob(50))
	//	usr << "<span class='warning'>You cut yourself on the paper.</span>"
	//	return

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the nano paper?", "nano paper Labelling", null)  as text), 1, MAX_NAME_LEN)
	if((loc == usr && usr.stat == 0))
		name = "nano paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/obj/item/weapon/nano_paper/attack_self(mob/living/user as mob)
	examine()
	if(rigged && (Holiday == "April Fool's Day"))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
	return

/obj/item/weapon/nano_paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	return

/obj/item/weapon/nano_paper/proc/addtofield(var/id, var/text, var/links = 0)
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

/obj/item/weapon/nano_paper/proc/updateinfolinks()
	info_links = info
	for(var/i=0,i < fields,i++)
		addtofield(i, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[i]'>\[write\]</A> </font>", 1)
		addtofield(i, "<font face=\"[deffont]\"><A href='?src=\ref[src];help=[i]'>\[help\]</A> </font>", 2)
	info_links += "<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>\[write\]</A> </font>"
	info_links += "<font face=\"[deffont]\"><A href='?src=\ref[src];help=end'>\[help\]</A> </font>"

/obj/item/weapon/nano_paper/proc/clearpaper()
	info = null
	overlays.Cut()
	updateinfolinks()
	update_icon()

/obj/item/weapon/nano_paper/proc/parsepencode(var/t, var/obj/item/weapon/pen/P, mob/user as mob, var/iscrayon = 0)
	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[br\]", "<BR>")
	t = replacetext(t, "\[b\]", "<B>")
	t = replacetext(t, "\[/b\]", "</B>")
	t = replacetext(t, "\[i\]", "<I>")
	t = replacetext(t, "\[/i\]", "</I>")
	t = replacetext(t, "\[u\]", "<U>")
	t = replacetext(t, "\[/u\]", "</U>")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[sign\]", "<font face=\"[signfont]\"><i>[user.real_name]</i></font>")
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext(t, "\[img\]","<img src=\"")
	t = replacetext(t, "\[/img\]", "\" />")
	t = replacetext(t, "\[*\]", "<li>")
	t = replacetext(t, "\[hr\]", "<HR>")
	t = replacetext(t, "\[small\]", "<font size = \"1\">")
	t = replacetext(t, "\[/small\]", "</font>")
	t = replacetext(t, "\[list\]", "<ul>")
	t = replacetext(t, "\[/list\]", "</ul>")
	t = replacetext(t, "\[video\]", "<embed src=\"")
	t = replacetext(t, "\[/video\]", "\" width=\"420\" height=\"344\" type=\"x-ms-wmv\" volume=\"85\" autoStart=\"0\" autoplay=\"true\" />")
	t = "<font face=\"[deffont]\" color=[P.colour]>[t]</font>"

//Count the fields
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields++
	return t


/obj/item/weapon/nano_paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Valid BBcodes</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule. <br>
		\[img\]http://url\[/img\] : add an image <br>
		\[video\]http://url.wmv\[/video\] : add a video with simple controls, MUST BE IN WMV FORMAT!! <br>
	</BODY></HTML>"}, "window=paper_help")

/obj/item/weapon/nano_paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["write"])
		var/id = href_list["write"]
		var/t = sanitize(input("Enter what you want to write:", "Write", null, null))  as message
		var/obj/item/i = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/weapon/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1

		// if paper is not in usr, then it must be in a clipboard or folder, which must be in or near usr
		if(src.loc != usr && !((istype(src.loc, /obj/item/weapon/clipboard) || istype(src.loc, /obj/item/weapon/folder)) && (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )
			return

		 log += "<br />\[[time_stamp()]] [key_name(usr)] added: [t]"

		// logs images and videos, IN CASE SOMEONE POSTS SOME CP, so admins can have some fun...
		if(findtext(t,"\[img]"))
			message_admins("[key_name_admin(usr)] added an image to [src] at [formatJumpTo(get_turf(src))]")
			log_admin("[key_name_admin(usr)] added an image to [src] at [formatJumpTo(get_turf(src))]")
		if(findtext(t,"\[video]"))
			message_admins("[key_name_admin(usr)] added an image to [src] at [formatJumpTo(get_turf(src))]")
			log_admin("[key_name_admin(usr)] added an image to [src] at [formatJumpTo(get_turf(src))]")

		t = replacetext(t, "\n", "<BR>")
		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			updateinfolinks()

		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]</BODY></HTML>", "window=[name]") // Update the window

	if(href_list["help"])
		openhelp(usr)

	update_icon()


/obj/item/weapon/nano_paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()

	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		if ( istype(P, /obj/item/weapon/pen/robopen) && P:mode == 2 )
			P:RenamePaper(user,src)
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]</BODY></HTML>", "window=[name]")
		//openhelp(user)
		return

	add_fingerprint(user)
	return