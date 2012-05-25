//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/*
field_generator power level display
   The icon used for the field_generator need to have 'num_power_levels' number of icon states
   named 'Field_Gen +p[num]' where 'num' ranges from 1 to 'num_power_levels'

   The power level is displayed using overlays. The current displayed power level is stored in 'powerlevel'.
   The overlay in use and the powerlevel variable must be kept in sync.  A powerlevel equal to 0 means that
   no power level overlay is currently in the overlays list.
   -Aygar
*/

#define field_generator_max_power 250
/obj/machinery/field_generator
	name = "Field Generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = 0
	density = 1
	use_power = 0
	var/const/num_power_levels = 6	// Total number of power level icon has
	var/Varedit_start = 0
	var/Varpower = 0
	var/active = 0
	var/power = 20  // Current amount of power
	var/state = 0
	var/warming_up = 0
	var/list/obj/machinery/containment_field/fields
	var/list/obj/machinery/field_generator/connected_gens
	var/clean_up = 0


	update_icon()
		overlays = null
		if(!active)
			if(warming_up)
				overlays += "+a[warming_up]"
		if(fields.len)
			overlays += "+on"
		// Power level indicator
		// Scale % power to % num_power_levels and truncate value
		var/level = round(num_power_levels * power / field_generator_max_power)
		// Clamp between 0 and num_power_levels for out of range power values
		level = between(0, level, num_power_levels)
		if(level)
			overlays += "+p[level]"

		return


	New()
		..()
		fields = list()
		connected_gens = list()
		return


	process()
		if(Varedit_start == 1)
			if(active == 0)
				active = 1
				state = 2
				power = field_generator_max_power
				anchored = 1
				warming_up = 3
				start_fields()
				update_icon()
			Varedit_start = 0

		if(src.active == 2)
			calc_power()
			update_icon()
		return


	attack_hand(mob/user as mob)
		if(state == 2)
			if(get_dist(src, user) <= 1)//Need to actually touch the thing to turn it on
				if(src.active >= 1)
					user << "You are unable to turn off the [src.name] once it is online."
					return 1
				else
					user.visible_message("[user.name] turns on the [src.name]", \
						"You turn on the [src.name].", \
						"You hear heavy droning")
					turn_on()
					src.add_fingerprint(user)
		else
			user << "The [src] needs to be firmly secured to the floor first."
			return


	attackby(obj/item/W, mob/user)
		if(active)
			user << "The [src] needs to be off."
			return
		else if(istype(W, /obj/item/weapon/wrench))
			switch(state)
				if(0)
					state = 1
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					user.visible_message("[user.name] secures [src.name] to the floor.", \
						"You secure the external reinforcing bolts to the floor.", \
						"You hear ratchet")
					src.anchored = 1
				if(1)
					state = 0
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
						"You undo the external reinforcing bolts.", \
						"You hear ratchet")
					src.anchored = 0
				if(2)
					user << "\red The [src.name] needs to be unwelded from the floor."
					return
		else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			switch(state)
				if(0)
					user << "\red The [src.name] needs to be wrenched to the floor."
					return
				if(1)
					if (W:remove_fuel(0,user))
						W:welding = 2
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
							"You start to weld the [src] to the floor.", \
							"You hear welding")
						if (do_after(user,20))
							state = 2
							user << "You weld the field generator to the floor."
						W:welding = 1
					else
						return
				if(2)
					if (W:remove_fuel(0,user))
						W:welding = 2
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
							"You start to cut the [src] free from the floor.", \
							"You hear welding")
						if (do_after(user,20))
							state = 1
							user << "You cut the [src] free from the floor."
						W:welding = 2
					else
						return
		else
			..()
			return


	emp_act()
		return 0


	blob_act()
		if(active)
			return 0
		else
			..()


	bullet_act(var/obj/item/projectile/Proj)
		if(Proj.flag != "bullet")
			power += Proj.damage
			update_icon()
		return 0


	Del()
		src.cleanup()
		..()


	proc
		turn_off()
			active = 0
			spawn(1)
				src.cleanup()
			update_icon()

		turn_on()
			active = 1
			warming_up = 1
			spawn(1)
				while (warming_up<3 && active)
					sleep(50)
					warming_up++
					update_icon()
					if(warming_up >= 3)
						start_fields()
			update_icon()


		calc_power()
			if(Varpower)
				return 1

			update_icon()
			if(src.power > field_generator_max_power)
				src.power = field_generator_max_power

			var/power_draw = 2
			for (var/obj/machinery/containment_field/F in fields)
				if (isnull(F))
					continue
				power_draw++
			if(draw_power(round(power_draw/2,1)))
				return 1
			else
				for(var/mob/M in viewers(src))
					M.show_message("\red The [src.name] shuts down!")
				turn_off()
				src.power = 0
				return 0

//This could likely be better, it tends to start loopin if you have a complex generator loop setup.  Still works well enough to run the engine fields will likely recode the field gens and fields sometime -Mport
		draw_power(var/draw = 0, var/failsafe = 0, var/obj/machinery/field_generator/G = null, var/obj/machinery/field_generator/last = null)
			if(Varpower)
				return 1
			if((G && G == src) || (failsafe >= 8))//Loopin, set fail
				return 0
			else
				failsafe++
			if(src.power >= draw)//We have enough power
				src.power -= draw
				return 1
			else//Need more power
				draw -= src.power
				src.power = 0
				for(var/obj/machinery/field_generator/FG in connected_gens)
					if(isnull(FG))
						continue
					if(FG == last)//We just asked you
						continue
					if(G)//Another gen is askin for power and we dont have it
						if(FG.draw_power(draw,failsafe,G,src))//Can you take the load
							return 1
						else
							return 0
					else//We are askin another for power
						if(FG.draw_power(draw,failsafe,src,src))
							return 1
						else
							return 0


		start_fields()
			if(!src.state == 2 || !anchored)
				turn_off()
				return
			spawn(1)
				setup_field(1)
			spawn(2)
				setup_field(2)
			spawn(3)
				setup_field(4)
			spawn(4)
				setup_field(8)
			src.active = 2


		setup_field(var/NSEW)
			var/turf/T = src.loc
			var/obj/machinery/field_generator/G
			var/steps = 0
			if(!NSEW)//Make sure its ran right
				return
			for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
				T = get_step(T, NSEW)
				if(T.density)//We cant shoot a field though this
					return 0
				for(var/atom/A in T.contents)
					if(ismob(A))
						continue
					if(!istype(A,/obj/machinery/field_generator))
						if((istype(A,/obj/machinery/door)||istype(A,/obj/machinery/the_singularitygen))&&(A.density))
							return 0
				steps += 1
				G = locate(/obj/machinery/field_generator) in T
				if(!isnull(G))
					steps -= 1
					if(!G.active)
						return 0
					break
			if(isnull(G))
				return
			T = src.loc
			for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
				var/field_dir = get_dir(T,get_step(G.loc, NSEW))
				T = get_step(T, NSEW)
				if(!locate(/obj/machinery/containment_field) in T)
					var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field()
					CF.set_master(src,G)
					fields += CF
					G.fields += CF
					CF.loc = T
					CF.dir = field_dir
			var/listcheck = 0
			for(var/obj/machinery/field_generator/FG in connected_gens)
				if (isnull(FG))
					continue
				if(FG == G)
					listcheck = 1
					break
			if(!listcheck)
				connected_gens.Add(G)
			listcheck = 0
			for(var/obj/machinery/field_generator/FG2 in G.connected_gens)
				if (isnull(FG2))
					continue
				if(FG2 == src)
					listcheck = 1
					break
			if(!listcheck)
				G.connected_gens.Add(src)


		cleanup()
			clean_up = 1
			for (var/obj/machinery/containment_field/F in fields)
				if (isnull(F))
					continue
				del(F)
			fields = list()
			for(var/obj/machinery/field_generator/FG in connected_gens)
				if (isnull(FG))
					continue
				FG.connected_gens.Remove(src)
				connected_gens.Remove(FG)
			connected_gens = list()
			clean_up = 0

			//This is here to help fight the "hurr durr, release singulo cos nobody will notice before the
			//singulo eats the evidence". It's not fool-proof but better than nothing.
			//I want to avoid using global variables.
			spawn(1)
				var/temp = 1 //stops spam
				for(var/obj/machinery/singularity/O in world)
					if(O.last_warning && temp)
						if((world.time - O.last_warning) > 50) //to stop message-spam
							temp = 0
							message_admins("A singulo exists and a containment field has failed.",1)
					O.last_warning = world.time
