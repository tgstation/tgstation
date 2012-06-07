/obj/item/weapon/syndie
	icon = 'syndieweapons.dmi'

/*C-4 explosive charge and etc, replaces the old syndie transfer valve bomb.*/


/*The explosive charge itself.  Flashes for five seconds before exploding.*/

/obj/item/weapon/syndie/c4explosive
	icon_state = "c-4small_0"
	item_state = "c-4small"
	name = "normal-sized package"
	desc = "A small wrapped package."
	w_class = 3

	var/power = 1  /*Size of the explosion.*/
	var/size = "small"  /*Used for the icon, this one will make c-4small_0 for the off state.*/

/obj/item/weapon/syndie/c4explosive/heavy
	icon_state = "c-4large_0"
	item_state = "c-4large"
	desc = "A mysterious package, it's quite heavy."
	power = 2
	size = "large"

/obj/item/weapon/syndie/c4explosive/New()
	var/K = rand(1,2000)
	K = md5(num2text(K)+name)
	K = copytext(K,1,7)
	src.desc += "\n You see [K] engraved on \the [src]."
	var/obj/item/weapon/syndie/c4detonator/detonator = new(src.loc)
	detonator.desc += "\n You see [K] engraved on the lighter."
	detonator.bomb = src

/obj/item/weapon/syndie/c4explosive/proc/detonate()
	icon_state = "c-4[size]_1"
	spawn(50)
		explosion(get_turf(src), power, power*2, power*3, power*4, power*4)
		for(var/dirn in cardinal)		//This is to guarantee that C4 at least breaks down all immediately adjacent walls and doors.
			var/turf/simulated/wall/T = get_step(src,dirn)
			if(locate(/obj/machinery/door/airlock) in T)
				var/obj/machinery/door/airlock/D = locate() in T
				if(D.density)
					D.open()
			if(istype(T,/turf/simulated/wall))
				T.dismantle_wall(1)
		del(src)


/*Detonator, disguised as a lighter*/
/*Click it when closed to open, when open to bring up a prompt asking you if you want to close it or press the button.*/

/obj/item/weapon/syndie/c4detonator
	icon_state = "c-4detonator_0"
	item_state = "c-4detonator"
	name = "\improper Zippo lighter"  /*Sneaky, thanks Dreyfus.*/
	desc = "The zippo."
	w_class = 1

	var/obj/item/weapon/syndie/c4explosive/bomb
	var/pr_open = 0  /*Is the "What do you want to do?" prompt open?*/

/obj/item/weapon/syndie/c4detonator/attack_self(mob/user as mob)
	switch(src.icon_state)
		if("c-4detonator_0")
			src.icon_state = "c-4detonator_1"
			user << "You flick open the lighter."

		if("c-4detonator_1")
			if(!pr_open)
				pr_open = 1
				switch(alert(user, "What would you like to do?", "Lighter", "Press the button.", "Close the lighter."))
					if("Press the button.")
						user << "\red You press the button."
						flick("c-4detonator_click", src)
						if(src.bomb)
							src.bomb.detonate()
							log_admin("[user.real_name]([user.ckey]) has triggered [src.bomb] with [src].")
							message_admins("\red [user.real_name]([user.ckey]) has triggered [src.bomb] with [src].")

					if("Close the lighter.")
						src.icon_state = "c-4detonator_0"
						user << "You close the lighter."
				pr_open = 0