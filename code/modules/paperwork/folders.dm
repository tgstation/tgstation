/obj/item/weapon/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = 2
	pressure_resistance = 2

	autoignition_temperature = 522 // Kelvin

/obj/item/weapon/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/weapon/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/weapon/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/weapon/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/weapon/folder/update_icon()
	overlays.Cut()
	if(contents.len)
		overlays += "folder_paper"
	return

/obj/item/weapon/folder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/photo))
		user.drop_item()
		W.loc = src
		user << "<span class='notice'>You put the [W] into \the [src].</span>"
		update_icon()
	else if(istype(W, /obj/item/weapon/pen))
		var/n_name = copytext(sanitize(input(usr, "What would you like to label the folder?", "Folder Labelling", null)  as text), 1, MAX_NAME_LEN)
		if((loc == usr && usr.stat == 0))
			name = "folder[(n_name ? text("- '[n_name]'") : null)]"
	return

/obj/item/weapon/folder/attack_self(mob/user as mob)
	var/dat = "<title>[name]</title>"

	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)
	return

/obj/item/weapon/folder/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(usr.contents.Find(src))

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(!(istype(P, /obj/item/weapon/paper)) && !(istype(P, /obj/item/weapon/photo)))
				var/message = "<span class='warning'>[usr]([usr.key]) has tried to remove something other than a paper/photo from a folder.<span>"
				message_admins(message)
				message += "[P]"
				log_game(message)
				admin_log.Add(message)
				return
			if(!(P in src.contents))
				var/message = "<span class='warning'>[usr]([usr.key]) has tried to remove a paper/photo from a folder that didn't contain it.<span>"
				message_admins(message)
				message += "[P]"
				log_game(message)
				admin_log.Add(message)
				return
			if(P)
				P.loc = usr.loc
				usr.put_in_hands(P)

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(P)
				if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
		if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"])
			if(P)
				P.show(usr)

		//Update everything
		attack_self(usr)
		update_icon()
	return