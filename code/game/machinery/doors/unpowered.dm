/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0


	Bumped(atom/AM)
		if(src.locked)	return
		..()
		return


	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade))	return
		if(src.locked)	return
		..()
		return



/obj/machinery/door/unpowered/shuttle
	icon = 'shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1