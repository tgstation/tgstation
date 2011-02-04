var/global/list/uneatable = list(
	/obj/machinery/singularity,
	/turf/space,/obj/effects,
	/obj/overlay)

/obj/machinery/singularity/
	name = "Gravitational Singularity"
	desc = "A Gravitational Singularity."
	icon = '160x160.dmi'
	icon_state = "Singularity"
	anchored = 1
	density = 1
	layer = 6
	unacidable = 1 //Don't comment this out.
	power_usage = 0
	var
//		active = 0
		contained = 1 //Are we going to move around?
		energy = 100 //How strong are we?
		dissipate = 0 //Do we lose energy over time? TODO:Set this to 1 when/if the feederthing is finished
		dissipate_delay = 5
		dissipate_track = 0
		dissipate_strength = 10 //How much energy do we lose?
		move_self = 1 //Do we move on our own?
		grav_pull = 6 //How many tiles out do we pull?
		event_chance = 15 //Prob for event each tick


	New(loc, var/starting_energy = 200, var/temp = 0)
		src.energy = starting_energy
		pixel_x = -64
		pixel_y = -64
		if(temp)
			spawn(temp)
				del(src)
		..()
		return


	Del()
		//Could have it do something bad when this happens, explode/implode or something
		..()


	attack_hand(mob/user as mob)
		consume(user)
		return 1


	blob_act(severity)
		return


	ex_act(severity)
		switch(severity)
			if(1.0)
				if(prob(10))
					del(src)
					return
				else
					energy += 50
			if(2.0 to 3.0)
				energy += round((rand(20,60)/2),1)
				return
		return


	Bump(atom/A)
		consume(A)
		return


	Bumped(atom/A)
		consume(A)
		return


	process()
		eat()
		dissipate()
		check_energy()
		move()
		if(prob(event_chance))//Chance for it to run a special event TODO:Come up with one or two more that fit
			event()
		pulse()
		return

	proc
		dissipate()
			if(!dissipate)
				return
			if(dissipate_track >= dissipate_delay)
				src.energy -= dissipate_strength
				dissipate_track = 0
			else
				dissipate_track++


		check_energy()
			if(energy <= 0)
				del(src)
				return 0
			switch(energy)
				if(1000 to 1999)
					for(var/obj/machinery/field_generator/F in orange(5,src))
						F.turn_off()
					emp_area()
					toxmob()
				if(2000 to INFINITY)
					explosion(src.loc, 4, 8, 15, 0)
					if(src)
						del(src)
					return 0
			return 1


		eat()
			for (var/atom/X in orange(grav_pull,src))
				if(isarea(X))
					continue
				if(is_type_in_list(uneatable,X))
					continue
				switch(get_dist(src,X))
					if(0 to 2)
						consume(X)
					else if(!isturf(X))
						if(!X:anchored && !istype(X,/mob/living/carbon/human))//TODO:change the boots to just anchor so we dont have to add this to everything
							step_towards(X,src)
						else if(istype(X,/mob/living/carbon/human))
							var/mob/living/carbon/human/H = X
							if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
								var/obj/item/clothing/shoes/magboots/M = H.shoes
								if(M.magpulse)
									continue
							step_towards(H,src)
			return


		consume(var/atom/A)
			var/gain = 0
			if(is_type_in_list(uneatable,A))
				return 0
			if (istype(A,/mob/living))//Mobs get gibbed
				gain = 20
				if(istype(A,/mob/living/carbon/human))
					if(A:mind)
						if((A:mind:assigned_role == "Station Engineer") || (A:mind:assigned_role == "Chief Engineer") )
							gain = 100
				A:gib()
			else if(istype(A,/obj/))
				A:ex_act(1.0)
				if(A) del(A)
				gain = 2
			else if(isturf(A))
				var/turf/T = A
				if(T.intact)
					for(var/obj/O in T.contents)
						if(O.level != 1)
							continue
						if(O.invisibility == 101)
							src.consume(O)
				A:ReplaceWithSpace()
				gain = 2
			src.energy += gain
			return


		move(var/movement_dir = 0)
			if(!(movement_dir in cardinal))
				movement_dir = pick(NORTH, SOUTH, EAST, WEST)
			switch(movement_dir)
				if(NORTH)
					if(!(can_move(locate(src.x,src.y+3,src.z))&&can_move(locate(src.x+1,src.y+3,src.z))&&can_move(locate(src.x-1,src.y+3,src.z))))
						return 0
				if(SOUTH)
					if(!(can_move(locate(src.x,src.y-3,src.z))&&can_move(locate(src.x+1,src.y-3,src.z))&&can_move(locate(src.x-1,src.y-3,src.z))))
						return 0
				if(EAST)
					if(!(can_move(locate(src.x+3,src.y,src.z))&&can_move(locate(src.x+3,src.y+1,src.z))&&can_move(locate(src.x+3,src.y-1,src.z))))
						return 0
				if(WEST)
					if(!(can_move(locate(src.x-3,src.y,src.z))&&can_move(locate(src.x-3,src.y+1,src.z))&&can_move(locate(src.x-3,src.y-1,src.z))))
						return 0
			spawn(0)
				step(src, movement_dir)


		can_move(var/turf/T)
			if(!T)
				return 0
			if(locate(/obj/machinery/containment_field) in T)
				return 0
			else if(locate(/obj/machinery/field_generator) in T)
				var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in T
				if(G && G.active)
					return 0
			return 1


		event()
			var/numb = pick(1,2,3,4,5,6)
			switch(numb)
				if(1)//EMP
					emp_area()
				if(2,3)//tox damage all carbon mobs in area
					toxmob()
				if(4)//Stun mobs who lack optic scanners
					mezzer()
				else
					//do nothing
			return


		toxmob()
			var/toxrange = 8
			if (src.energy>100)
				toxrange+=round((src.energy-100)/100)
			var/toxloss = 4
			var/radiation = 5
			if (src.energy>150)
				toxloss += round(((src.energy-150)/50)*4,1)
				radiation += round(((src.energy-150)/50)*5,1)
			for(var/mob/living/carbon/M in view(toxrange, src.loc))
				if(istype(M,/mob/living/carbon/human))
					if(M:wear_suit) //TODO: check for radiation protection
						toxloss = round(toxloss/2,1)
						radiation = round(radiation/2,1)
				M.toxloss += toxloss
				M.radiation += radiation
				M.updatehealth()
				M << "\red You feel odd."
			return


		mezzer()
			for(var/mob/living/carbon/M in oviewers(8, src))
				if(istype(M,/mob/living/carbon/human))
					if(istype(M:glasses,/obj/item/clothing/glasses/meson))
						M << "\blue You look directly into The [src.name], good thing you had your protective eyewear on!"
						return
				M << "\red You look directly into The [src.name] and feel weak."
				if (M:stunned < 3)
					M.stunned = 3
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red <B>[] stares blankly at The []!</B>", M, src), 1)
			return


		emp_area()
			var/turf/myturf = get_turf(src)
			var/obj/overlay/pulse = new/obj/overlay ( myturf )
			pulse.icon = 'effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = 1
			spawn(20)
				del(pulse)
			for (var/atom/X in orange(8,src))
				X.emp_act()
			return


		pulse()
			for(var/obj/machinery/power/rad_collector/R in orange(15,src))
				if(istype(R,/obj/machinery/power/rad_collector))
					R.receive_pulse(energy)
			return