/obj/item/device/fuse_bomb
	name = "fuse bomb"
	desc = "fshhhhhhhh BOOM!"
	icon = 'icons/obj/device.dmi'
	icon_state = "fuse_bomb_5"
	flags = FPRINT | TABLEPASS
	var/fuse_lit = 0
	var/seconds_left = 5

/obj/item/device/fuse_bomb/admin//spawned by the adminbus, doesn't send an admin message, but the logs are still kept.

/obj/item/device/fuse_bomb/attack_self(mob/user as mob)
	if(!fuse_lit)
		lit(user)
	else
		fuse_lit = 0
		update_icon()
		user << "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>"
	return

/obj/item/device/fuse_bomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(!fuse_lit)
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				lit(user,W)
		else if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.lit)
				lit(user,W)
		else if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.lit)
				lit(user,W)
		else if(istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			if(C.lit)
				lit(user,W)
	else
		if(istype(W, /obj/item/weapon/wirecutters))
			fuse_lit = 0
			update_icon()
			user << "<span class='warning'>You extinguish the fuse with [seconds_left] seconds left!</span>"


/obj/item/device/fuse_bomb/proc/lit(mob/user as mob, var/obj/O=null)
	fuse_lit = 1
	user << "<span class='warning'>You lit the fuse[O ? " with [O]":""]! [seconds_left] seconds till detonation!</span>"
	admin_warn(user)
	add_fingerprint(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	update_icon()
	fuse_burn()

/obj/item/device/fuse_bomb/proc/fuse_burn()
	set waitfor = 0
	if(src && src.fuse_lit)
		if(src.seconds_left)
			sleep(10)
			src.seconds_left--
			src.update_icon()
			.()
		else
			src.detonation()
	return

/obj/item/device/fuse_bomb/extinguish()
	..()
	fuse_lit = 0
	update_icon()

/obj/item/device/fuse_bomb/proc/detonation()
	explosion(get_turf(src), -1, 1, 3)
	qdel(src)

/obj/item/device/fuse_bomb/update_icon()
	icon_state = "fuse_bomb_[seconds_left][fuse_lit ? "-lit":""]"

/obj/item/device/fuse_bomb/proc/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	message_admins(log_str, 0, 1)
	log_game(log_str)

/obj/item/device/fuse_bomb/admin/admin_warn(mob/user as mob)
	var/turf/bombturf = get_turf(src)
	var/area/A = get_area(bombturf)

	var/demoman_name = ""
	if(!user)
		demoman_name = "Unknown"
	else
		demoman_name = "[user.name]([user.ckey])"

	var/log_str = "Bomb fuse lit in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name]</a> by [demoman_name]"

	if(user)
		log_str += "(<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)"

	bombers += log_str
	log_game(log_str)

/obj/item/device/fuse_bomb/cultify()
	return
