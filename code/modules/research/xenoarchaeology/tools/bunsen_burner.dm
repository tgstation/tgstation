
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "A flat, self-heating device designed for bringing chemical mixtures to boil."
	icon = 'icons/obj/device.dmi'
	icon_state = "bunsen0"
	var/heating = 0		//whether the bunsen is turned on
	var/heated = 0		//whether the bunsen has been on long enough to let stuff react
	var/obj/item/weapon/reagent_containers/held_container
	var/heat_time = 50

/obj/machinery/bunsen_burner/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(held_container)
			user << "\red You must remove the [held_container] first."
		else
			user.drop_item(src)
			held_container = W
			held_container.loc = src
			user << "\blue You put the [held_container] onto the [src]."
			var/image/I = image("icon"=W, "layer"=FLOAT_LAYER)
			underlays += I
			if(heating)
				spawn(heat_time)
					try_heating()
	else
		user << "\red You can't put the [W] onto the [src]."

/obj/machinery/bunsen_burner/attack_hand(mob/user as mob)
	if(held_container)
		underlays = null
		user << "\blue You remove the [held_container] from the [src]."
		held_container.loc = src.loc
		held_container.attack_hand(user)
		held_container = null
	else
		user << "\red There is nothing on the [src]."

/obj/machinery/bunsen_burner/proc/try_heating()
	src.visible_message("\blue \icon[src] [src] hisses.")
	if(held_container && heating)
		heated = 1
		held_container.reagents.handle_reactions()
		heated = 0
		spawn(heat_time)
			try_heating()

/obj/machinery/bunsen_burner/verb/toggle()
	set src in view(1)
	set name = "Toggle bunsen burner"
	set category = "IC"

	heating = !heating
	icon_state = "bunsen[heating]"
	if(heating)
		spawn(heat_time)
			try_heating()
