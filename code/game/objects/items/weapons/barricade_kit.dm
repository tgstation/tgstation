//Code graciously stolen from police_tape. Made with wooden planks
//For reasons building a full barricade uses the entire kit. Cading a door uses 1
/obj/item/barricade_kit
	name = "wooden barricade kit"
	desc = "Used to seal off areas ever since carpentry was perfected."
	icon = 'icons/obj/items.dmi'
	icon_state = "barricadekit"
	flags = FPRINT
	w_class = 3.0
	var/kit_uses = 2 //5 wood spent for 2 uses of the door cade function or 1 full cade

/obj/item/barricade_kit/attack_self(mob/user as mob)
	if(kit_uses < 2)
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


/obj/item/barricade_kit/afterattack(var/atom/A, mob/user as mob)
	if (istype(A, /obj/machinery/door/airlock)) //Airlocks
		if(!user.Adjacent(A)) //There, it's unfucked
			return
		var/turf/T = get_turf(A)
		var/obj/structure/barricade/wooden/door/B = new /obj/structure/barricade/wooden/door
		if(B in T) //Don't you dare stack barricades
			return
		user << "<span class='warning'>You start installing [src].</span>"
		if(do_after(user,30))
			B.loc = locate(T.x,T.y,T.z)
			B.layer = 3.2
			user << "<span class='notice'>You finish installing [src].</span>"
			user.visible_message("<span class='warning'>[user] barricades [A].</span>")
			kit_uses -= 1
			if(!(kit_uses))
				del(src) //Failsafe


