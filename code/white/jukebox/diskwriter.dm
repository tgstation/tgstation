/obj/item/weapon/disk/music
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0

	var/datum/turntable_soundtrack/data
	var/uploader_ckey

/obj/machinery/party/musicwriter
	name = "Memories writer"
	icon = 'icons/writer.dmi'
	icon_state = "writer_off"
	var/coin = 0
	//var/obj/item/weapon/disk/music/disk
	var/mob/retard //current user
	var/retard_name
	var/writing = 0

/obj/machinery/party/musicwriter/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/coin))
		user.dropItemToGround()
		del(O)
		coin++

/obj/machinery/party/musicwriter/attack_hand(mob/user)
	var/dat = ""
	if(writing)
		dat += "Memory scan completed. <br>Writing from scan of [retard_name] mind... Please Stand By."
	else if(!coin)
		dat += "Please insert a coin."
	else
		dat += "<A href='?src=\ref[src];write=1'>Write</A>"

	user << browse(dat, "window=musicwriter;size=200x100")
	onclose(user, "onclose")
	return

/obj/machinery/party/musicwriter/Topic(href, href_list)
	if(href_list["write"])
		if(!writing && !retard && coin)
			icon_state = "writer_on"
			writing = 1
			retard = usr
			retard_name = retard.name
			var/N = sanitize(input("Name of music") as text|null)
			//retard << "Please stand still while your data is uploading"
			if(N)
				var/sound/S = input("Your music file") as sound|null
				if(S)
					var/datum/turntable_soundtrack/T = new()
					var/obj/item/weapon/disk/music/disk = new()
					T.path = S
					T.f_name = copytext(N, 1, 2)
					T.name = copytext(N, 2)
					disk.data = T
					disk.name = "disk ([N])"
					disk.loc = src.loc
					disk.uploader_ckey = retard.ckey
					var/mob/M = usr
					message_admins("[M.real_name]([M.ckey]) uploaded <A HREF='?_src_=holder;listensound=\ref[S]'>sound</A> named as [N]. <A HREF='?_src_=holder;wipedata=\ref[disk]'>Wipe</A> data.")
			icon_state = "writer_off"
			writing = 0
			coin -= 1
			retard = null
			retard_name = null
