
/obj/machinery/rust/fuel_assembly_port
	name = "Fuel Assembly Port"
	icon = 'fuel_assembly_port.dmi'
	icon_state = "port"
	density = 0
	var/stage
	var/obj/item/weapon/fuel_assembly/cur_assembly = null
	layer = 4

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I,/obj/item/weapon/fuel_assembly))
			if(cur_assembly)
				del cur_assembly
			cur_assembly = I
			user.drop_item()
			I.loc = src

	New()
		//embed the fuel port into a wall
		pixel_x = (dir & 3)? 0 : (dir == 4 ? 24 : -24)
		pixel_y = (dir & 3)? (dir ==1 ? 24 : -24) : 0
