
//frame assembly

/obj/item/mounted/frame/rust_fuel_compressor
	name = "Fuel Compressor frame"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_compressor0"
	w_class = 4
	mount_reqs = list("simfloor", "nospace")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/rust_fuel_compressor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/plasteel( get_turf(src.loc), 12 )
		del(src)
		return
	..()

/obj/item/mounted/frame/rust_fuel_compressor/do_build(turf/on_wall, mob/user)
	new /obj/machinery/rust_fuel_compressor(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

//construction steps
/obj/machinery/rust_fuel_compressor/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	else
		has_electronics = 3
		opened = 0
		locked = 0
		icon_state = "fuel_compressor1"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 32 : -32)
	pixel_y = (dir & 3)? (dir ==1 ? 32 : -32) : 0

/obj/machinery/rust_fuel_compressor/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar))
		if(opened)
			if(has_electronics & 1)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "You begin removing the circuitboard")//lpeters - fixed grammar issues

				if(do_after(user, src, 50))
					user.visible_message(\
						"<span class='warning'>[user.name] has removed the circuitboard from [src.name]!</span>",\
						"<span class='notice'>You remove the circuitboard board.</span>")
					has_electronics = 0
					new /obj/item/weapon/module/rust_fuel_compressor(loc)
					has_electronics &= ~1
			else
				opened = 0
				icon_state = "fuel_compressor0"
				to_chat(user, "<span class='notice'>You close the maintenance cover.</span>")
		else
			if(compressed_matter > 0)
				to_chat(user, "<span class='warning'>You cannot open the cover while there is compressed matter inside.</span>")
			else
				opened = 1
				to_chat(user, "<span class='notice'>You open the maintenance cover.</span>")
				icon_state = "fuel_compressor1"
		return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(src.allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the compressor interface.")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	else if (istype(W, /obj/item/weapon/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			flick("apc-spark", src)
			if (do_after(user, src,6))
				if(prob(50))
					emagged = 1
					locked = 0
					to_chat(user, "You emag the port interface.")
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the compressor interface.")
		return

	else if (istype(W, /obj/item/stack/cable_coil) && opened && !(has_electronics & 2))
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return
		to_chat(user, "You start adding cables to the compressor frame...")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 20) && C.amount >= 10)
			C.use(10)
			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the compressor frame!</span>",\
				"You add cables to the port frame.")
			has_electronics &= 2
		return

	else if (istype(W, /obj/item/weapon/wirecutters) && opened && (has_electronics & 2))
		to_chat(user, "You begin to cut the cables...")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 50))
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message(\
				"<span class='warning'>[user.name] cuts the cabling inside the compressor.</span>",\
				"You cut the cabling inside the port.")
			has_electronics &= ~2
		return

	else if (istype(W, /obj/item/weapon/module/rust_fuel_compressor) && opened && !(has_electronics & 1))
		to_chat(user, "You try to insert the circuitboard into the frame...")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 10))
			has_electronics &= 1
			to_chat(user, "You place the circuitboard inside the frame.")
			qdel(W)
		return

	else if (istype(W, /obj/item/weapon/weldingtool) && opened && !has_electronics)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "You start welding the compressor frame...")
		playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, src, 50))
			if(!src || !WT.remove_fuel(3, user)) return
			new /obj/item/mounted/frame/rust_fuel_assembly_port(loc)
			user.visible_message(\
				"<span class='warning'>[src] has been cut away from the wall by [user.name].</span>",\
				"You detached the compressor frame.",\
				"<span class='warning'>You hear welding.</span>")
			qdel(src)
		return

	..()
