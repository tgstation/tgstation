
//frame assembly

/obj/item/mounted/frame/rust_fuel_assembly_port
	name = "Fuel Assembly Port frame"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "port2"
	w_class = 4
	mount_reqs = list("simfloor", "nospace")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/rust_fuel_assembly_port/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/plasteel( get_turf(src.loc), 12 )
		del(src)
		return
	..()

/obj/item/mounted/frame/rust_fuel_assembly_port/do_build(turf/on_wall, mob/user)
	new /obj/machinery/rust_fuel_assembly_port(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

//construction steps
/obj/machinery/rust_fuel_assembly_port/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	else
		has_electronics = 3
		opened = 0
		icon_state = "port0"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 32 : -32)
	pixel_y = (dir & 3)? (dir ==1 ? 32 : -32) : 0

/obj/machinery/rust_fuel_assembly_port/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar))
		if(opened)
			if(has_electronics & 1)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				user << "You begin removing the circuitboard" //lpeters - fixed grammar issues
				if(do_after(user, 50))
					user.visible_message(\
						"\red [user.name] has removed the circuitboard from [src.name]!",\
						"\blue You remove the circuitboard.")
					has_electronics = 0
					new /obj/item/weapon/module/rust_fuel_port(loc)
					has_electronics &= ~1
			else
				opened = 0
				icon_state = "port0"
				user << "\blue You close the maintenance cover."
		else
			if(cur_assembly)
				user << "\red You cannot open the cover while there is a fuel assembly inside."
			else
				opened = 1
				user << "\blue You open the maintenance cover."
				icon_state = "port2"
		return

	else if (istype(W, /obj/item/stack/cable_coil) && opened && !(has_electronics & 2))
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			user << "\red You need more wires."
			return
		user << "You start adding cables to the frame..."
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20) && C.amount >= 10)
			C.use(10)
			user.visible_message(\
				"\red [user.name] has added cables to the port frame!",\
				"You add cables to the port frame.")
			has_electronics &= 2
		return

	else if (istype(W, /obj/item/weapon/wirecutters) && opened && (has_electronics & 2))
		user << "You begin to cut the cables..."
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 50))
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message(\
				"\red [user.name] cut the cabling inside the port.",\
				"You cut the cabling inside the port.")
			has_electronics &= ~2
		return

	else if (istype(W, /obj/item/weapon/module/rust_fuel_port) && opened && !(has_electronics & 1))
		user << "You trying to insert the port control board into the frame..."
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 10))
			has_electronics &= 1
			user << "You place the port control board inside the frame."
			del(W)
		return

	else if (istype(W, /obj/item/weapon/weldingtool) && opened && !has_electronics)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
			user << "\blue You need more welding fuel to complete this task."
			return
		user << "You start welding the port frame..."
		playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, 50))
			if(!src || !WT.remove_fuel(3, user)) return
			new /obj/item/mounted/frame/rust_fuel_assembly_port(loc)
			user.visible_message(\
				"\red [src] has been cut away from the wall by [user.name].",\
				"You detached the port frame.",\
				"\red You hear welding.")
			del(src)
		return

	..()
