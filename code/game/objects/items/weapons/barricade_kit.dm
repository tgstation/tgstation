//Code graciously stolen from police_tape. Made with wooden planks
//For reasons building a full barricade uses the entire kit. Cading a door uses a third
/obj/item/weapon/barricade_kit
	name = "wooden barricade kit"
	desc = "Used to seal off areas ever since carpentry was perfected."
	icon = 'icons/obj/items.dmi'
	icon_state = "barricadekit"
	flags = FPRINT
	w_class = 3.0
	force = 3.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 3
	var/kit_uses = 3 //5 wood spent for 3 uses of the door cade function or 1 full cade

/obj/item/weapon/barricade_kit/attack_self(mob/user as mob)
	if(kit_uses < 3)
		user << "<span class='warning'>Most of [src] was used, now it's only good for doors.</span>"
		return
	if(istype(user.loc,/turf/space))
		user << "<span class='warning'>You can't use [src] in space.</span>"
		return
	user << "<span class='notice'>You start building a barricade using [src].</span>"
	user.visible_message("<span class='warning'>[user] starts building a barricade.</span>")
	if(do_after(user,50))
		user << "<span class='notice'>You finish the barricade.</span>"
		new /obj/structure/barricade/wooden(usr.loc)
		del(src) //Used up everything


/obj/item/weapon/barricade_kit/afterattack(var/atom/A, mob/user as mob)
	if(istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/window/full)) //Airlocks
		if(get_dist(user,A)>1) //There, it's unfucked
			return
		var/turf/T = get_turf(A)
		for(var/obj/structure/S in T)
			if(istype(S,/obj/structure/barricade/wooden/door))
				return
		var/obj/structure/barricade/wooden/door/B = new /obj/structure/barricade/wooden/door
		user << "<span class='warning'>You start installing [src].</span>"
		if(do_after(user,30))
			B.loc = locate(T.x,T.y,T.z)
			B.layer = 4 //Higher than doors and windows
			user << "<span class='notice'>You finish installing [src].</span>"
			user.visible_message("<span class='warning'>[user] barricades [A].</span>")
			kit_uses -= 1
			if(!(kit_uses))
				del(src) //Failsafe

	if(istype(A, /obj/structure/window) && !istype(A, /obj/structure/window/full)) //Windows
		if(get_dist(user,A)>1)
			return
		var/turf/T = get_turf(A)
		for(var/obj/structure/S in T)
			if(istype(S,/obj/structure/barricade/wooden/door))
				return
			if(istype(S,/obj/structure/grille))
				var/obj/structure/barricade/wooden/door/B = new /obj/structure/barricade/wooden/door
				user << "<span class='warning'>You start installing [src].</span>"
				if(do_after(user,30))
					B.loc = locate(S.x,S.y,S.z)
					B.layer = 4
					user << "<span class='notice'>You finish installing [src].</span>"
					user.visible_message("<span class='warning'>[user] barricades [A].</span>")
					kit_uses -= 1
					if(!(kit_uses))
						del(src) //Failsafe


