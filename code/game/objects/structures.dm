obj/structure
	icon = 'structures.dmi'

	girder
		icon_state = "girder"
		anchored = 1
		density = 1
		var/state = 0

		displaced
			icon_state = "displaced"
			anchored = 0

		reinforced
			icon_state = "reinforced"
			state = 2

/obj/structure/girder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && state == 0 && anchored && !istype(src,/obj/structure/girder/displaced))
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now disassembling the girder"
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You dissasembled the girder!"
			new /obj/item/weapon/sheet/metal(get_turf(src))
			del(src)

	else if(istype(W, /obj/item/weapon/sheet/metal) && istype(src,/obj/structure/girder/displaced))
		W:amount -= 1
		if(W:amount <= 0)
			del(W)
		user << "\blue You create a false wall! Push on it to open or close the passage."
		new /obj/falsewall (src.loc)
		del(src)

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now unsecuring support struts"
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You unsecured the support struts!"
			state = 1

	else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now removing support struts"
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You removed the support struts!"
			new/obj/structure/girder( src.loc )
			del(src)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now dislodging the girder"
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You dislodged the girder!"
			new/obj/structure/girder/displaced( src.loc )
			del(src)

	else if(istype(W, /obj/item/weapon/wrench) && state == 0 && !anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Now securing the girder"
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You secured the girder!"
			new/obj/structure/girder( src.loc )
			del(src)

	else if((istype(W, /obj/item/weapon/sheet/metal)) && (W:amount >= 2))
		var/turf/T = get_turf(user)
		user << "\blue Now adding plating..."
		sleep(40)
		if (get_turf(user) == T)
			user << "\blue You added the plating!"
			var/turf/Tsrc = get_turf(src)
			Tsrc.ReplaceWithWall()
			W:amount -= 2
			if(W:amount <= 0)
				del(W)
			del(src)
		return

	else if (istype(W, /obj/item/weapon/sheet/r_metal))
		var/turf/T = get_turf(user)
		if (src.icon_state == "reinforced") //Time to finalize!
			user << "\blue Now finalising reinforced wall."
			sleep(50)
			if(get_turf(user) == T)
				user << "\blue Wall fully reinforced!"
				var/turf/Tsrc = get_turf(src)
				Tsrc.ReplaceWithRWall()
				W:amount--
				if (W:amount <= 0)
					del(W)
				del(src)
				return
		else
			user << "\blue Now reinforcing girders"
			sleep(60)
			user << "\blue Girders reinforced!"
			new/obj/structure/girder/reinforced( src.loc )
			del(src)
			return
	else
		..()

/obj/structure/girder/blob_act()
	if(prob(10))
		del(src)