var/global/list/uneatable = list(
	/obj/machinery/singularity,
	/turf/space,/obj/effects,
	/obj/overlay)

/obj/machinery/singularity/
	name = "Gravitational Singularity"
	desc = "A Gravitational Singularity."
	icon = 'singularity.dmi'
	icon_state = "singularity_s1"
	anchored = 1
	density = 1
	layer = 6
	unacidable = 1 //Don't comment this out.
	use_power = 0
	var
		current_size = 1
		allowed_size = 1
		contained = 1 //Are we going to move around?
		energy = 100 //How strong are we?
		dissipate = 1 //Do we lose energy over time?
		dissipate_delay = 10
		dissipate_track = 0
		dissipate_strength = 1 //How much energy do we lose?
		move_self = 1 //Do we move on our own?
		grav_pull = 4 //How many tiles out do we pull?
		consume_range = 0 //How many tiles out do we eat
		event_chance = 15 //Prob for event each tick
		target = null //its target. moves towards the target if it has one


	New(loc, var/starting_energy = 50, var/temp = 0)
		src.energy = starting_energy
		if(temp)
			spawn(temp)
				del(src)
		..()
		for(var/obj/machinery/singularity_beacon/singubeacon in world)
			target = singubeacon
			break
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
		if(current_size >= 3)
			move()
			if(current_size <= 7)
				pulse()
				if(current_size >= 5)
					if(prob(event_chance))//Chance for it to run a special event TODO:Come up with one or two more that fit
						event()
		return

	attack_ai() //to prevent ais from gibbing themselves when they click on one.
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


		expand(var/force_size = 0)
			var/temp_allowed_size = src.allowed_size
			if(force_size)
				temp_allowed_size = force_size
			switch(temp_allowed_size)
				if(1)
					current_size = 1
					icon = 'singularity.dmi'
					icon_state = "singularity_s1"
					pixel_x = 0
					pixel_y = 0
					grav_pull = 4
					consume_range = 0
					dissipate_delay = 10
					dissipate_track = 0
					dissipate_strength = 1
				if(3)//1 to 3 does not check for the turfs if you put the gens right next to a 1x1 then its going to eat them
					current_size = 3
					icon = '96x96.dmi'
					icon_state = "singularity_s3"
					pixel_x = -32
					pixel_y = -32
					grav_pull = 6
					consume_range = 1
					dissipate_delay = 5
					dissipate_track = 0
					dissipate_strength = 5
				if(5)
					if((check_turfs_in(1,2))&&(check_turfs_in(2,2))&&(check_turfs_in(4,2))&&(check_turfs_in(8,2)))
						current_size = 5
						icon = '160x160.dmi'
						icon_state = "singularity_s5"
						pixel_x = -64
						pixel_y = -64
						grav_pull = 8
						consume_range = 2
						dissipate_delay = 4
						dissipate_track = 0
						dissipate_strength = 20
				if(7)
					if((check_turfs_in(1,3))&&(check_turfs_in(2,3))&&(check_turfs_in(4,3))&&(check_turfs_in(8,3)))
						current_size = 7
						icon = '224x224.dmi'
						icon_state = "singularity_s7"
						pixel_x = -96
						pixel_y = -96
						grav_pull = 10
						consume_range = 3
						dissipate_delay = 10
						dissipate_track = 0
						dissipate_strength = 10
				if(9)//this one also lacks a check for gens because it eats everything
					current_size = 9
					icon = '288x288.dmi'
					icon_state = "singularity_s9"
					pixel_x = -128
					pixel_y = -128
					grav_pull = 15//This might cause some lag, dono though
					consume_range = 4
					dissipate = 0 //It cant go smaller due to e loss
			if(current_size == allowed_size)
				return 1
			else if(current_size < (--temp_allowed_size))
				expand(temp_allowed_size)
			else
				return 0


		check_energy()
			if(energy <= 0)
				del(src)
				return 0
			switch(energy)//Some of these numbers might need to be changed up later -Mport
				if(1 to 199)
					allowed_size = 1
				if(200 to 499)
					allowed_size = 3
				if(500 to 999)
					allowed_size = 5
				if(1000 to 1999)
					allowed_size = 7
				if(2000 to INFINITY)
					allowed_size = 9
			if(current_size != allowed_size)
				expand()
			return 1


		eat()
			for(var/atom/X in orange(consume_range,src))
				if(isarea(X))
					continue
				consume(X)
			for(var/atom/X in orange(grav_pull,src))
				if(isarea(X))
					continue
				if(is_type_in_list(X, uneatable))
					continue
				if(!isturf(X))
					if((!X:anchored && (!istype(X,/mob/living/carbon/human)))|| (src.current_size >= 9))
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
			if (istype(A,/obj/item/weapon/storage/backpack/holding))
				del(A)
				explosion(src.loc,10,15,20,40)
				if(src) del(src)
				return
			var/gain = 0
			if(is_type_in_list(A, uneatable))
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
			if(!move_self)
				return 0
			if(!(movement_dir in cardinal))
				movement_dir = pick(NORTH, SOUTH, EAST, WEST)
			if(target)
				movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one
			if(current_size >= 9)//The superlarge one does not care about things in its way
				spawn(0)
					step(src, movement_dir)
				spawn(1)
					step(src, movement_dir)
				return 1
			else if(check_turfs_in(movement_dir))
				spawn(0)
					step(src, movement_dir)
				return 1
			return 0


		check_turfs_in(var/direction = 0, var/step = 0)
			if(!direction)
				return 0
			var/steps = 0
			if(!step)
				switch(current_size)
					if(1)
						steps = 1
					if(3)
						steps = 3//Yes this is right
					if(5)
						steps = 3
					if(7)
						steps = 4
					if(9)
						steps = 5
			else
				steps = step
			var/list/turfs = list()
			var/turf/T = src.loc
			for(var/i = 1 to steps)
				T = get_step(T,direction)
			if(!isturf(T))
				return 0
			turfs.Add(T)
			var/dir2 = 0
			var/dir3 = 0
			switch(direction)
				if(NORTH||SOUTH)
					dir2 = 4
					dir3 = 8
				if(EAST||WEST)
					dir2 = 1
					dir3 = 2
			var/turf/T2 = T
			for(var/j = 1 to steps)
				T2 = get_step(T2,dir2)
				if(!isturf(T2))
					return 0
				turfs.Add(T2)
			for(var/k = 1 to steps)
				T = get_step(T,dir3)
				if(!isturf(T))
					return 0
				turfs.Add(T)
			for(var/turf/T3 in turfs)
				if(isnull(T3))
					continue
				if(!can_move(T3))
					return 0
			return 1


		can_move(var/turf/T)
			if(!T)
				return 0
			if((locate(/obj/machinery/containment_field) in T)||(locate(/obj/machinery/shieldwall) in T))
				return 0
			else if(locate(/obj/machinery/field_generator) in T)
				var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in T
				if(G && G.active)
					return 0
			else if(locate(/obj/machinery/shieldwallgen) in T)
				var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in T
				if(S && S.active)
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
					return 0
			return 1


		toxmob()
			var/toxrange = 8
			if (src.energy>1000)
				toxrange += 6
			var/toxloss = 4
			var/radiation = 5
			if (src.energy>200)
				toxloss = round(((src.energy-150)/50)*4,1)
				radiation = round(((src.energy-150)/50)*5,1)
			for(var/mob/living/carbon/M in view(toxrange, src.loc))
				if(istype(M,/mob/living/carbon/human))
					var/P = 0
					if(M:wear_suit)
						P += M:wear_suit.radiation_protection
					if(M:head)
						P += M:head.radiation_protection
					if (P > 0)
						if (P >= 1)
							if(M:wear_suit)
								M << "The [M:wear_suit] beeps, indicating it just received a burst of radiation. Good thing you had it on."
							else if (M:head)
								M << "The [M:head] beeps, indicating it just received a burst of radiation. Good thing you had it on."
							else
								M << "Your body deflects all the radiation"
							return
						if (toxloss >= 100)
							toxloss = 100 - (P * 100) //a suit and/or headgear which protects you from 10% radiation will make you only receive 90 damage even if you're showered with a MILLION points of toxloss
						else
							toxloss = toxloss - (P * toxloss)
						if (radiation > 15)
							radiation = 15 - (15 * P)
						else
							radiation = radiation - (P * radiation)
						if(M:wear_suit)
							M << "\red The [M:wear_suit] absorbs some of the radiation from the singularity."
						else if (M:head)
							M << "\red The [M:head] absorbs some of the radiation from the singularity."
						else
							M << "\red Your body protects you from some of the radiation."
					else
						if(prob(50))
							M << "\red <b>You feel odd.</b>"
						else
							M << "\red <b>You feel sick.</b>"
				M.toxloss += toxloss
				M.radiation += radiation
				M.updatehealth()
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
			empulse(src, 6, 8, nolog=1)
			return


		pulse()
			for(var/obj/machinery/power/rad_collector/R in orange(15,src))
				if(istype(R,/obj/machinery/power/rad_collector))
					R.receive_pulse(energy)
			return



	narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
		name = "Tear in the Fabric of Reality"
		desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
		icon = 'magic_terror.dmi'
		pixel_x = -89
		pixel_y = -85
		current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
		contained = 0 //Are we going to move around?
		dissipate = 0 //Do we lose energy over time?
		move_self = 1 //Do we move on our own?
		grav_pull = 10 //How many tiles out do we pull?
		consume_range = 3 //How many tiles out do we eat

		process()
			eat()
			move()
			if(prob(25))
				mezzer()

		consume(var/atom/A) //Has its own consume proc because it doesn't need energy and I don't want BoHs to explode it. --NEO
			if(is_type_in_list(A, uneatable))
				return 0
			if (istype(A,/mob/living))//Mobs get gibbed
				A:gib()
			else if(istype(A,/obj/))
				A:ex_act(1.0)
				if(A) del(A)
			else if(isturf(A))
				var/turf/T = A
				if(T.intact)
					for(var/obj/O in T.contents)
						if(O.level != 1)
							continue
						if(O.invisibility == 101)
							src.consume(O)
				A:ReplaceWithSpace()
			return

		ex_act() //No throwing bombs at it either. --NEO
			return