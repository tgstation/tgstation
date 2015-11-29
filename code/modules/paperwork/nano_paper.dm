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

/obj/item/weapon/paper/nano/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	// Didn't feel like this was appropriate for a paper that is made of plastic
	//if((M_CLUMSY in usr.mutations) && prob(50))
//		to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
	//	return

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the [src]?", "[src] Labelling", null)  as text), 1, MAX_NAME_LEN)
	if((loc == usr && !usr.stat && !(usr.status_flags & FAKEDEATH)))
		name = "[src][(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

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
		\[large\] - \[/large\] : Increases the <span style=\"font-size:25px\">size</span> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		\[small\] - \[/small\] : Decreases the <span style=\"font-size:15px\">size</span> of the text.<br>
		\[tiny\] - \[/tiny\] : Sharply decreases the <span style=\"font-size:10px\">size</span> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule. <br>
		\[img\]http://url\[/img\] : add an image <br>
		\[video\]http://url.wmv\[/video\] : add a video with simple controls, MUST BE IN WMV FORMAT!!<br>
		<br>
		<center>Fonts</center><br>
		\[agency\] - \[/agency\] : <span style=\"font-family:Agency FB\">Agency FB</span><br>
		\[algerian\] - \[/algerian\] : <span style=\"font-family:Algerian\">Algerian</span><br>
		\[arial\] - \[/arial\] : <span style=\"font-family:Arial\">Arial</span><br>
		\[arialb\] - \[/arialb\] : <span style=\"font-family:Arial Black\">Arial Black</span><br>
		\[calibri\] - \[/calibri\] :<span style=\"font-family:Calibri\">Calibri</span><br>
		\[courier\] - \[/courier\] : <span style=\"font-family:Courier\">Courier</span><br>
		\[helvetica\] - \[/helvetica\] : <span style=\"font-family:Helvetica\">Helvetica</span><br>
		\[impact\] - \[/impact\] : <span style=\"font-family:Impact\">Impact</span><br>
		\[palatino\] - \[/palatino\] : <span style=\"font-family:Palatino Linotype\">Palatino Linotype</span><br>
		\[tnr\] - \[/tnr\] : <span style=\"font-family:Times New Roman\">Times New Roman</span><br>
	</BODY></HTML>"}, "window=paper_help")