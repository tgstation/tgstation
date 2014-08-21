/*
 * nano paper
 *
 *
 * this basicaly a modified copy/paste of paper.dm
 */

/obj/item/weapon/paper/nano
	name = "nano paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "nano_paper"

	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1

/obj/item/weapon/paper/nano/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	spawn(2)
		update_icon()
		updateinfolinks()
		return

/obj/item/weapon/paper/nano/update_icon()
	if(info)
		icon_state = "nano_paper_words"
		return
	icon_state = "nano_paper"

/obj/item/weapon/paper/nano/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	// Didn't feel like this was appropriate for a paper that is made of plastic
	//if((M_CLUMSY in usr.mutations) && prob(50))
	//	usr << "<span class='warning'>You cut yourself on the paper.</span>"
	//	return

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the [src]?", "[src] Labelling", null)  as text), 1, MAX_NAME_LEN)
	if((loc == usr && usr.stat == 0))
		name = "[src][(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/obj/item/weapon/paper/nano/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		addtofield(i, "<A href='?src=\ref[src];write=[i]'>write</A> ", 1)
		addtofield(i, "<A href='?src=\ref[src];help=[i]'>help</A> ", 1)
	info_links +="<A href='?src=\ref[src];write=end'>write</A> "
	info_links +="<A href='?src=\ref[src];help=end'>help</A> "


/obj/item/weapon/paper/nano/parsepencode(var/t, var/obj/item/weapon/pen/P, mob/user as mob)
	return P.Format(user,t,1)


/obj/item/weapon/paper/nano/openhelp(mob/user as mob)
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

/obj/item/weapon/paper/nano/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["write"])
		var/id = href_list["write"]
		var/t = sanitize(input("Enter what you want to write:", "Write", null, null))  as message

		// if paper is not in usr, then it must be in a clipboard or folder, which must be in or near usr
		if(src.loc != usr && !((istype(src.loc, /obj/item/weapon/clipboard) || istype(src.loc, /obj/item/weapon/folder)) && (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )
			return

		log += "<br />\[[time_stamp()]] [key_name(usr)] added: [t]"

		t = replacetext(t, "\n", "<BR>")
		if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			updateinfolinks()
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]</BODY></HTML>", "window=[name]") // Update the window

	if(href_list["help"])
		openhelp(usr)

	update_icon()
