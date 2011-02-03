
/////FIELD GEN
#define field_generator_max_power 250
/obj/machinery/field_generator
	name = "Field Generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'singularity.dmi'
	icon_state = "Field_Gen"
	anchored = 0
	density = 1
	req_access = list(access_engine)
	power_usage = 0
	var
		Varedit_start = 0
		Varpower = 0
		active = 0
		power = 20
		state = 0
		warming_up = 0
		powerlevel = 0
		list/obj/machinery/containment_field/fields
		list/obj/machinery/field_generator/connected_gens


	update_icon()
		if (!active)
			icon_state = "Field_Gen"
			return
		var/level = 3
		switch (power)
			if(0 to 60)
				level = 1
			if(61 to 220)
				level = 2
			if(221 to INFINITY)
				level = 3
		level = min(level,warming_up)
		if (powerlevel!=level)
			powerlevel = level
			icon_state = "Field_Gen +a[powerlevel]"


	New()
		..()
		fields = list()
		connected_gens = list()
		return


	process()
		if(src.Varedit_start == 1)
			if(src.active == 0)
				src.active = 1
				src.state = 2
				src.power = field_generator_max_power
				src.anchored = 1
				src.warming_up = 3
				turn_on()
			Varedit_start = 0
		if(src.active == 2)
			calc_power()

		return


	attack_hand(mob/user as mob)
		if(state == 2)
			if(get_dist(src, user) <= 1)//Need to actually touch the thing to turn it on
				if(src.active >= 1)
					user << "You are unable to turn off the [src] once it is online."
					return 1
				else
					user.visible_message("[user.name] turns on the [src.name]", \
						"You turn on the [src].", \
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
		else if(istype(W, /obj/item/weapon/weldingtool))
			switch(state)
				if(0)
					user << "\red The [src.name] needs to be wrenched to the floor."
					return
				if(1)
					if (W:remove_fuel(2,user))
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
							"You start to weld the [src] to the floor.", \
							"You hear welding")
						if (do_after(user,20))
							state = 2
							user << "You weld the field generator to the floor."
					else
						return
				if(2)
					if (W:remove_fuel(2,user))
						playsound(src.loc, 'Welder2.ogg', 50, 1)
						user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
							"You start to cut the [src] free from the floor.", \
							"You hear welding")
						if (do_after(user,20))
							state = 1
							user << "You cut the [src] free from the floor."
					else
						return
		else
			..()
			return


	emp_act()
		return 0


	bullet_act(flag)
		if (flag == PROJECTILE_BULLET)
			src.power -= 100
		else if (flag == PROJECTILE_WEAKBULLET)
			src.power -= 50
		else if (flag == PROJECTILE_LASER)
			src.power += 20
		else if (flag == PROJECTILE_TASER)
			src.power += 5
		else
			src.power -= 30
		update_icon()
		return


	Del()
		src.cleanup()
		..()


	proc
		turn_off()
			src.active = 0
			spawn(1)
				src.cleanup()
			update_icon()


		turn_on()
			src.active = 1
			warming_up = 1
			powerlevel = 0
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
				return

			update_icon()
			if(src.power > field_generator_max_power)
				src.power = field_generator_max_power

			var/power_draw = 0
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
				return


		draw_power(var/draw = 0,var/obj/machinery/field_generator/G = null, var/obj/machinery/field_generator/last = null)
//			if(G && G == src)//Loopin, set fail
//				return 0
			if(src.power >= draw)//We have enough power
				src.power -= draw
				return 1
			else//Need more power
				return 0
/*				draw -= src.power
				src.power = 0 ill finis this up when not about to pass out
				for(var/obj/machinery/field_generator/FG in connected_gens)
					if(isnull(FG))
						continue
					if(FG == last)//We just asked you
						continue
					if(G)//Another gen is askin for power and we dont have it
						if(FG.draw_power(draw,G,src))//Can you take the load
							return 1
						else
							return 0
					else//We are askin another for power
						if(FG.draw_power(draw,src,src))
							return 1
						else
							return 0
*/

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
				steps += 1
				G = locate(/obj/machinery/field_generator) in T
				if(!isnull(G))
					steps -= 1
					if(!G.active)
						return
					break
			if(isnull(G))
				return
			T = src.loc
			for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
				var/field_dir = get_dir(T,get_step(G.loc, NSEW))
				T = get_step(T, NSEW)
				if(!locate(/obj/machinery/containment_field) in T)
					var/obj/machinery/containment_field/CF = new/obj/machinery/containment_field()
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
