/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_open_empty"
	density = 1
	anchored = 1
	var/door_open = 1
	var/loaded = 0
	var/busy = 0

/obj/machinery/washing_machine/update_icon()
	icon_state = busy ? "wm_busy" : "wm_[door_open ? "open" : "closed"]_[loaded ? "loaded" : "empty"]"

/obj/machinery/washing_machine/attackby(obj/item/I, mob/user)
	if(!busy && door_open)
		if(contents.len < 5)
			if(user.drop_item())
				I.loc = src
				loaded = 1
				update_icon()
			else
				user << "<span class='warning'>You can't put \the [I] in the washing machine!</span>"
		else
			user << "<span class='warning'>The washing machine is full!</span>"
	else
		user << "<span class='warning'>You can't put \the [I] in right now!</span>"

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(door_open)
		door_open = 0
		if(loaded)
			wash()
		update_icon()
	else
		if(!busy)
			for(var/atom/movable/O in contents)
				O.loc = get_turf(src)
			door_open = 1
			loaded = 0
			update_icon()
		else
			user << "<span class='danger'>The [src] is busy.</span>"

/obj/machinery/washing_machine/proc/wash()
	busy = 1
	update_icon()
	spawn(200)
		if(qdeleted(src))
			return

		for(var/atom/movable/A in contents)
			A.clean_blood()

		//Tanning!
		for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
			var/obj/item/stack/sheet/wetleather/WL = new(src)
			WL.amount = HH.amount
			qdel(HH)

		//Corgi costume says goodbye
		for(var/obj/item/clothing/suit/hooded/ian_costume/IC in contents)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi(src)
			qdel(IC)

		busy = 0
		update_icon()
