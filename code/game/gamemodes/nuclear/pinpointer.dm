/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'device.dmi'
	icon_state = "pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/obj/item/weapon/disk/nuclear/the_disk = null
	var/active = 0

	attack_self()
		if(!active)
			active = 1
			work()
			usr << "\blue You activate the pinpointer"
		else
			active = 0
			icon_state = "pinoff"
			usr << "\blue You deactivate the pinpointer"

	proc/work()
		if(!active) return
		if(!the_disk)
			the_disk = locate()
			if(!the_disk)
				active = 0
				icon_state = "pinonnull"
				return
		src.dir = get_dir(src,the_disk)
		switch(get_dist(src,the_disk))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
		spawn(5) .()


/*/obj/item/weapon/pinpointer/New()
	. = ..()
	processing_items.Add(src)

/obj/item/weapon/pinpointer/Del()
	processing_items.Remove(src)
	. = ..()

/obj/item/weapon/pinpointer/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = "<B>Nuclear Disk Pinpointer</B><HR>"
		dat += "<A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")

/obj/item/weapon/pinpointer/process()
	/*
	//TODO: REWRITE
	set background = 1
	var/turf/sr = get_turf(src)

	if (sr)
		for(var/obj/item/weapon/disk/nuclear/W in world)
			var/turf/tr = get_turf(W)
			if (tr && tr.z == sr.z)
				src.dir = get_dir(sr, tr)
				break
	*/
/obj/item/weapon/pinpointer/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["refresh"])
			src.temp = "<B>Nuclear Disk Pinpointer</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Disks:</B><BR>"

				for(var/obj/item/weapon/disk/nuclear/W in world)
					var/turf/tr = get_turf(W)
					if (tr && tr.z == sr.z)
						var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						var/strength = "unknown"
						var/directional = dir2text(get_dir(sr, tr));

						if (distance < 5)
							strength = "very strong"
						else if (distance < 10)
							strength = "strong"
						else if (distance < 15)
							strength = "weak"
						else if (distance < 20)
							strength = "very weak"
							directional = "unknown"
						else
							continue

						if (!directional)
							directional = "right on top of it"

						src.temp += "[directional]-[strength]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else if (href_list["temp"])
			src.temp = null

		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for (var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
*/