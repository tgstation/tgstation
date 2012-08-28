/obj/machinery/door/poddoor/shutters
	name = "Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"

/obj/machinery/door/poddoor/shutters/New()
	..()
	layer = 3.1

/obj/machinery/door/poddoor/shutters/attackby(obj/item/weapon/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (!( istype(C, /obj/item/weapon/crowbar) || (istype(C, /obj/item/weapon/twohanded/fireaxe) && C:wielded == 1) ))
		return
	if(src.density && (stat & NOPOWER) && !src.operating)
		operating = 1
		spawn(-1)
			flick("shutterc0", src)
			icon_state = "shutter0"
			sleep(15)
			density = 0
			SetOpacity(0)
			operating = 0
			return
	return

/obj/machinery/door/poddoor/shutters/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("shutterc0", src)
	src.icon_state = "shutter0"
	sleep(10)
	src.density = 0
	SetOpacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()		//TODO: note to self: look into this ~Carn
	return 1

/obj/machinery/door/poddoor/shutters/close()
	if (src.operating)
		return
	src.operating = 1
	flick("shutterc1", src)
	src.icon_state = "shutter1"
	src.density = 1
	if(src.visible)
		SetOpacity(1)
	update_nearby_tiles()

	sleep(10)
	src.operating = 0
	return