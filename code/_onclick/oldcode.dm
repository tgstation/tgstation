/atom/DblClick(location, control, params) //TODO: DEFERRED: REWRITE
	if(!usr)	return

	// ------- TIME SINCE LAST CLICK -------
	if (world.time <= usr:lastDblClick+1)
		return
	else
		usr:lastDblClick = world.time

	//Putting it here for now. It diverts stuff to the mech clicking procs. Putting it here stops us drilling items in our inventory Carn
	if(istype(usr.loc,/obj/mecha))
		if(usr.client && (src in usr.client.screen))
			return
		var/obj/mecha/Mech = usr.loc
		Mech.click_action(src,usr)
		return

	// ------- DIR CHANGING WHEN CLICKING ------
	if( iscarbon(usr) && !usr.buckled )
		if( src.x && src.y && usr.x && usr.y )
			var/dx = src.x - usr.x
			var/dy = src.y - usr.y

			if(dy || dx)
				if(abs(dx) < abs(dy))
					if(dy > 0)	usr.dir = NORTH
					else		usr.dir = SOUTH
				else
					if(dx > 0)	usr.dir = EAST
					else		usr.dir = WEST
			else
				if(pixel_y > 16)		usr.dir = NORTH
				else if(pixel_y < -16)	usr.dir = SOUTH
				else if(pixel_x > 16)	usr.dir = EAST
				else if(pixel_x < -16)	usr.dir = WEST




	// ------- AI -------
	else if (istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		if (ai.control_disabled)
			return

	// ------- CYBORG -------
	else if (istype(usr, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/bot = usr
		if (bot.lockcharge) return
	..()


	// ------- SHIFT-CLICK -------

	if(params)
		var/parameters = params2list(params)

		if(parameters["shift"]){
			if(!isAI(usr))
				ShiftClick(usr)
			else
				AIShiftClick(usr)
			return
		}

		// ------- ALT-CLICK -------

		if(parameters["alt"]){
			if(!isAI(usr))
				AltClick(usr)
			else
				AIAltClick(usr)
			return
		}

		// ------- CTRL-CLICK -------

		if(parameters["ctrl"]){
			if(!isAI(usr))
				CtrlClick(usr)
			else
				AICtrlClick(usr)
			return
		}

		// ------- MIDDLE-CLICK -------

		if(parameters["middle"]){
			if(!isAI(usr))
				MiddleClick(usr)
				return
		}

	// ------- THROW -------
	if(usr.in_throw_mode)
		return usr:throw_item(src)

	// ------- ITEM IN HAND DEFINED -------
	var/obj/item/W = usr.get_active_hand()
/*	Now handled by get_active_hand()
	// ------- ROBOT -------
	if(istype(usr, /mob/living/silicon/robot))
		if(!isnull(usr:module_active))
			W = usr:module_active
		else
			W = null
*/
	// ------- ATTACK SELF -------
	if (W == src && usr.stat == 0)
		W.attack_self(usr)
		if(usr.hand)
			usr.update_inv_l_hand(0)	//update in-hand overlays
		else
			usr.update_inv_r_hand(0)
		return

	// ------- PARALYSIS, STUN, WEAKENED, DEAD, (And not AI) -------
	if (((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai)) || usr.stat != 0)
		return

	// ------- CLICKING STUFF IN CONTAINERS -------
	if ((!( src in usr.contents ) && (((!( isturf(src) ) && (!( isturf(src.loc) ) && (src.loc && !( isturf(src.loc.loc) )))) || !( isturf(usr.loc) )) && (src.loc != usr.loc && (!( istype(src, /obj/screen) ) && !( usr.contents.Find(src.loc) ))))))
		if (istype(usr, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/ai = usr
			if (ai.control_disabled || ai.malfhacking)
				return
		else
			return

	// ------- 1 TILE AWAY -------
	var/t5
	// ------- AI CAN CLICK ANYTHING -------
	if(istype(usr, /mob/living/silicon/ai))
		t5 = 1
	// ------- CYBORG CAN CLICK ANYTHING WHEN NOT HOLDING STUFF -------
	else if(istype(usr, /mob/living/silicon/robot) && !W)
		t5 = 1
	else
		t5 = in_range(src, usr) || src.loc == usr

//	world << "according to dblclick(), t5 is [t5]"

	// ------- ACTUALLY DETERMINING STUFF -------
	if (((t5 || (W && (W.flags & USEDELAY))) && !( istype(src, /obj/screen) )))

		// ------- ( CAN USE ITEM OR HAS 1 SECOND USE DELAY ) AND NOT CLICKING ON SCREEN -------

		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			// ------- ALREADY USED ONE ITEM WITH USE DELAY IN THE PREVIOUS SECOND -------
			return

		// ------- DELAY CHECK PASSED -------

		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))

			// ------- CLICKED OBJECT EXISTS IN GAME WORLD, DISTANCE FROM PERSON TO OBJECT IS 1 SQUARE OR THEY'RE ON THE SAME SQUARE -------

			var/direct = get_dir(usr, src)
			var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( usr.loc )
			var/ok = 0
			if ( (direct - 1) & direct)

				// ------- CLICKED OBJECT IS LOCATED IN A DIAGONAL POSITION FROM THE PERSON -------

				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if(5.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)

					if(6.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)

					if(9.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)

					if(10.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

					else
				if(Step_1 && Step_2)

					// ------- BOTH CARDINAL DIRECTIONS OF THE DIAGONAL EXIST IN THE GAME WORLD -------

					var/check_1 = 0
					var/check_2 = 0
					if(step_to(D, Step_1))
						check_1 = 1
						for(var/obj/border_obstacle in Step_1)
							if(border_obstacle.flags & ON_BORDER)
								if(!border_obstacle.CheckExit(D, src))
									check_1 = 0
									// ------- YOU TRIED TO CLICK ON AN ITEM THROUGH A WINDOW (OR SIMILAR THING THAT LIMITS ON BORDERS) ON ONE OF THE DIRECITON TILES -------
						for(var/obj/border_obstacle in get_turf(src))
							if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if(!border_obstacle.CanPass(D, D.loc, 1, 0))
									// ------- YOU TRIED TO CLICK ON AN ITEM THROUGH A WINDOW (OR SIMILAR THING THAT LIMITS ON BORDERS) ON THE TILE YOU'RE ON -------
									check_1 = 0

					D.loc = usr.loc
					if(step_to(D, Step_2))
						check_2 = 1

						for(var/obj/border_obstacle in Step_2)
							if(border_obstacle.flags & ON_BORDER)
								if(!border_obstacle.CheckExit(D, src))
									check_2 = 0
						for(var/obj/border_obstacle in get_turf(src))
							if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if(!border_obstacle.CanPass(D, D.loc, 1, 0))
									check_2 = 0


					if(check_1 || check_2)
						ok = 1
						// ------- YOU CAN REACH THE ITEM THROUGH AT LEAST ONE OF THE TWO DIRECTIONS. GOOD. -------

					/*
						More info:
							If you're trying to click an item in the north-east of your mob, the above section of code will first check if tehre's a tile to the north or you and to the east of you
							These two tiles are Step_1 and Step_2. After this, a new dummy object is created on your location. It then tries to move to Step_1, If it succeeds, objects on the turf you're on and
							the turf that Step_1 is are checked for items which have the ON_BORDER flag set. These are itmes which limit you on only one tile border. Windows, for the most part.
							CheckExit() and CanPass() are use to determine this. The dummy object is then moved back to your location and it tries to move to Step_2. Same checks are performed here.
							If at least one of the two checks succeeds, it means you can reach the item and ok is set to 1.
					*/
			else
				// ------- OBJECT IS ON A CARDINAL TILE (NORTH, SOUTH, EAST OR WEST OR THE TILE YOU'RE ON) -------
				if(loc == usr.loc)
					ok = 1
					// ------- OBJECT IS ON THE SAME TILE AS YOU -------
				else
					ok = 1

					//Now, check objects to block exit that are on the border
					for(var/obj/border_obstacle in usr.loc)
						if(border_obstacle.flags & ON_BORDER)
							if(!border_obstacle.CheckExit(D, src))
								ok = 0

					//Next, check objects to block entry that are on the border
					for(var/obj/border_obstacle in get_turf(src))
						if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
							if(!border_obstacle.CanPass(D, D.loc, 1, 0))
								ok = 0
				/*
					See the previous More info, for... more info...
				*/

			//del(D)
			// Garbage Collect Dummy
			D.loc = null
			D = null

			// ------- DUMMY OBJECT'S SERVED IT'S PURPOSE, IT'S REWARDED WITH A SWIFT DELETE -------
			if (!( ok ))
				// ------- TESTS ABOVE DETERMINED YOU CANNOT REACH THE TILE -------
				return 0

		if (!( usr.restrained() || (usr.lying && usr.buckled!=src) ))
			// ------- YOU ARE NOT REASTRAINED -------

			if (W)
				// ------- YOU HAVE AN ITEM IN YOUR HAND - HANDLE ATTACKBY AND AFTERATTACK -------
				var/ignoreAA = 0 //Ignore afterattack(). Surgery uses this.
				if (t5)
					ignoreAA = src.attackby(W, usr)
				if (W && !ignoreAA)
					W.afterattack(src, usr, (t5 ? 1 : 0), params)

			else
				// ------- YOU DO NOT HAVE AN ITEM IN YOUR HAND -------
				if (istype(usr, /mob/living/carbon/human))
					// ------- YOU ARE HUMAN -------
					src.attack_hand(usr, usr.hand)
				else
					// ------- YOU ARE NOT HUMAN. WHAT ARE YOU - DETERMINED HERE AND PROPER ATTACK_MOBTYPE CALLED -------
					if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/alien/humanoid))
						if(usr.m_intent == "walk" && istype(usr, /mob/living/carbon/alien/humanoid/hunter))
							usr.m_intent = "run"
							usr.hud_used.move_intent.icon_state = "running"
							usr.update_icons()
						src.attack_alien(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/alien/larva))
						src.attack_larva(usr)
					else if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
						src.attack_ai(usr, usr.hand)
					else if(istype(usr, /mob/living/carbon/slime))
						src.attack_slime(usr)
					else if(istype(usr, /mob/living/simple_animal))
						src.attack_animal(usr)
		else
			// ------- YOU ARE RESTRAINED. DETERMINE WHAT YOU ARE AND ATTACK WITH THE PROPER HAND_X PROC -------
			if (istype(usr, /mob/living/carbon/human))
				src.hand_h(usr, usr.hand)
			else if (istype(usr, /mob/living/carbon/monkey))
				src.hand_p(usr, usr.hand)
			else if (istype(usr, /mob/living/carbon/alien/humanoid))
				src.hand_al(usr, usr.hand)
			else if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
				src.hand_a(usr, usr.hand)

	else
		// ------- ITEM INACESSIBLE OR CLICKING ON SCREEN -------
		if (istype(src, /obj/screen))
			// ------- IT'S THE HUD YOU'RE CLICKING ON -------
			usr.prev_move = usr.next_move
			usr:lastDblClick = world.time + 2
			if (usr.next_move < world.time)
				usr.next_move = world.time + 2
			else
				return

			// ------- 2 DECISECOND DELAY FOR CLICKING PASSED -------

			if (!( usr.restrained() ))

				// ------- YOU ARE NOT RESTRAINED -------
				if ((W && !( istype(src, /obj/screen) )))
					// ------- IT SHOULD NEVER GET TO HERE, DUE TO THE ISTYPE(SRC, /OBJ/SCREEN) FROM PREVIOUS IF-S - I TESTED IT WITH A DEBUG OUTPUT AND I COULDN'T GET THIST TO SHOW UP. -------
					src.attackby(W, usr)
					if (W)
						W.afterattack(src, usr,, params)
				else
					// ------- YOU ARE NOT RESTRAINED, AND ARE CLICKING A HUD OBJECT -------
					if (istype(usr, /mob/living/carbon/human))
						src.attack_hand(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.attack_alien(usr, usr.hand)
			else
				// ------- YOU ARE RESTRAINED CLICKING ON A HUD OBJECT -------
				if (istype(usr, /mob/living/carbon/human))
					src.hand_h(usr, usr.hand)
				else if (istype(usr, /mob/living/carbon/monkey))
					src.hand_p(usr, usr.hand)
				else if (istype(usr, /mob/living/carbon/alien/humanoid))
					src.hand_al(usr, usr.hand)
		else
			// ------- YOU ARE CLICKING ON AN OBJECT THAT'S INACCESSIBLE TO YOU AND IS NOT YOUR HUD -------
			if((M_LASER in usr:mutations) && usr:a_intent == "harm" && world.time >= usr.next_move)
				// ------- YOU HAVE THE M_LASER MUTATION, YOUR INTENT SET TO HURT AND IT'S BEEN MORE THAN A DECISECOND SINCE YOU LAS TATTACKED -------

				var/turf/T = get_turf(usr)
				var/turf/U = get_turf(src)


				if(istype(usr, /mob/living/carbon/human))
					usr:nutrition -= rand(1,5)
					usr:handle_regular_hud_updates()

				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( usr.loc )
				A.icon = 'icons/effects/genetics.dmi'
				A.icon_state = "eyelasers"
				playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

				A.firer = usr
				A.def_zone = usr:get_organ_target()
				A.original = src
				A.current = T
				A.yo = U.y - T.y
				A.xo = U.x - T.x
				spawn( 1 )
					A.process()

				usr.next_move = world.time + 6
	return
