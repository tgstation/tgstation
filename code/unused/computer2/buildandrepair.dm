//Motherboard is just used in assembly/disassembly, doesn't exist in the actual computer object.
/obj/item/weapon/motherboard
	name = "Computer mainboard"
	desc = "A computer motherboard."
	icon = 'icons/obj/module.dmi'
	icon_state = "mainboard"
	item_state = "electronic"
	w_class = 3
	var/created_name = null //If defined, result computer will have this name.

/obj/computer2frame
	density = 1
	anchored = 0
	name = "Computer-frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/motherboard/mainboard = null
	var/obj/item/weapon/disk/data/fixed_disk/hd = null
	var/list/peripherals = list()
	var/created_icon_state = "aiupload"

/obj/computer2frame/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/metal( src.loc, 5 )
					del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/motherboard) && !mainboard)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "\blue You place the mainboard inside the frame."
				src.icon_state = "1"
				src.mainboard = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && mainboard)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You screw the mainboard into place."
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && mainboard)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the mainboard."
				src.state = 1
				src.icon_state = "0"
				mainboard.loc = src.loc
				src.mainboard = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && mainboard && (!peripherals.len))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the mainboard."
				src.state = 1
				src.icon_state = "1"

			if(istype(P, /obj/item/weapon/peripheral))
				if(src.peripherals.len < 3)
					user.drop_item()
					src.peripherals.Add(P)
					P.loc = src
					user << "\blue You add [P] to the frame."
				else
					user << "\red There is no more room for peripheral cards."

			if(istype(P, /obj/item/weapon/crowbar) && src.peripherals.len)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the peripheral boards."
				for(var/obj/item/weapon/peripheral/W in src.peripherals)
					W.loc = src.loc
					src.peripherals.Remove(W)

			if(istype(P, /obj/item/weapon/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:amount -= 5
						if(!P:amount) del(P)
						user << "\blue You add cables to the frame."
						src.state = 3
						src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "\blue You remove the cables."
				src.state = 2
				src.icon_state = "2"
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
				A.amount = 5
				if(src.hd)
					src.hd.loc = src.loc
					src.hd = null

			if(istype(P, /obj/item/weapon/disk/data/fixed_disk) && !src.hd)
				user.drop_item()
				src.hd = P
				P.loc = src
				user << "\blue You connect the drive to the cabling."

			if(istype(P, /obj/item/weapon/crowbar) && src.hd)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the hard drive."
				src.hd.loc = src.loc
				src.hd = null

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:use(2)
						user << "\blue You put in the glass panel."
						src.state = 4
						src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."
				var/obj/machinery/computer2/C= new /obj/machinery/computer2( src.loc )
				C.setup_drive_size = 0
				C.icon_state = src.created_icon_state
				if(mainboard.created_name) C.name = mainboard.created_name
				del(mainboard)
				if(hd)
					C.hd = hd
					hd.loc = C
				for(var/obj/item/weapon/peripheral/W in src.peripherals)
					W.loc = C
					W.host = C
					C.peripherals.Add(W)
				del(src)