/proc/GenerateTheft(var/job,var/datum/mind/traitor)
	var/list/datum/objective/objectives = list()

	for(var/o in typesof(/datum/objective/steal))
		if(o != /datum/objective/steal)		//Make sure not to get a blank steal objective.
			objectives += new o(null,job)

	//objectives += GenerateAssassinate(job,traitor)
	return objectives

/proc/GenerateAssassinate(var/job,var/datum/mind/traitor)
	var/list/datum/objective/assassinate/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/assassinate(null,job,target)
	return missions

/proc/GenerateFrame(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/frame(null,job,target)
	return missions

/proc/GenerateProtection(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/protection(null,job,target)
	return missions



/proc/SelectObjectives(var/job,var/datum/mind/traitor,var/hijack = 0)
	var/list/datum/objective/chosenobjectives = list()
	var/list/datum/objective/theftobjectives = GetObjectives(job,traitor)		//Separated all the objective types so they can be picked independantly of each other.
	var/list/datum/objective/killobjectives = GenerateAssassinate(job,traitor)
	var/list/datum/objective/frameobjectives = GenerateFrame(job,traitor)
	var/list/datum/objective/protectobjectives = GenerateProtection(job,traitor)
	//var/points
	var/totalweight
	var/selectobj
	var/conflict

	while(totalweight < 100)
		selectobj = rand(1,100)	//Randomly determine the type of objective to be given.
		if(!length(killobjectives) || !length(protectobjectives))	//If any of these lists are empty, just give them theft objectives.
			var/datum/objective/objective = pick(theftobjectives)
			chosenobjectives += objective
			totalweight += objective.weight
			theftobjectives -= objective
		else switch(selectobj)
			if(1 to 50)		//Theft Objectives (50% chance)
				var/datum/objective/objective = pick(theftobjectives)
				chosenobjectives += objective
				totalweight += objective.weight
				theftobjectives -= objective
			if(51 to 87)	//Assassination Objectives (37% chance)
				var/datum/objective/assassinate/objective = pick(killobjectives)
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.weight
					killobjectives -= objective
				conflict = 0
			if(88 to 90)	//Framing Objectives (3% chance)
				var/datum/objective/objective = pick(frameobjectives)
				chosenobjectives += objective
				totalweight += objective.weight
				frameobjectives -= objective
			if(91 to 100)	//Protection Objectives (5% chance)
				var/datum/objective/protection/objective = pick(protectobjectives)
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.weight
					protectobjectives -= objective
				conflict = 0

	var/hasendgame = 0
	for(var/datum/objective/o in chosenobjectives)
		if(o.type == /datum/objective/hijack || o.type == /datum/objective/escape)
			hasendgame = 1
			break
	for(var/datum/objective/o in chosenobjectives)
		if(o.explanation_text == "Free Objective")
			del(o) //Cleaning up any sillies.
	if(hasendgame == 0)
		if(hijack)
			chosenobjectives += new /datum/objective/hijack(null,job)
		else
			chosenobjectives += new /datum/objective/escape(null,job)
	return chosenobjectives

datum
	objective
		var/datum/mind/owner
		var/explanation_text = "text not set"
		var/job
//		var/points = INFINITY //If this isn't set to something else, the objective is bugged and should be ignored
		var/weight = INFINITY

		New(var/text,var/joba)
			if(text)
				src.explanation_text = text
			job=joba
			weight = get_points(job)

		proc
			check_completion()
				return 1
			get_points(var/job)
				return INFINITY


		frame
			var/datum/mind/target

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				weight = get_points(job)
				explanation_text = "Frame [target.current.real_name], the [target.assigned_role] for a crime and make sure they are arrested and brought back to the Centcom station alive.  We'll handle the rest from there."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0
				if(target.current.stat == 2)
					return 0
				var/turf/location = get_turf(target.current.loc)
				if(!location)
					return 0
				if(!target.current:handcuffed && !istype(location, /turf/simulated/shuttle/floor4))
					return 0

				if(location in locate(/area/shuttle/escape/centcom))
					return 1

				return 0

			get_points()
				if(target)
					switch(GetRank(owner.assigned_role))
						if(4)
							return 30
						if(3)
							return 40
						if(2)
							return 50
						if(1)
							return 55
						if(0)
							return 60
				else
					return INFINITY


		protection
			var/datum/mind/target
			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				weight = get_points(job)
				explanation_text = "[target.current.real_name], the [target.assigned_role] is a relative of a high ranking Syndicate Leader.  Make sure they get off the ship safely, while minimizing intervention."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				if(target.current.stat == 2)
					return 0

				var/turf/location = get_turf(target.current.loc)
				if(!location)
					return 0

				if(location in locate(/area/shuttle/escape/centcom))
					return 1

				return 0

			get_points()
				return 30


		assassinate
			var/datum/mind/target

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				weight = get_points(job)
				explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2)
						return 1
					else
						return 0
				else
					return 1
			get_points()
				if(target)
					switch(GetRank(owner.assigned_role))
						if(4)
							return 30
						if(3)
							return 40
						if(2)
							return 50
						if(1)
							return 55
						if(0)
							return 60
				else
					return 0

			proc/find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target


			proc/find_target()
				var/list/possible_targets = list()

				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target

				if(possible_targets.len > 0)
					target = pick(possible_targets)

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target


		capture
			var/datum/mind/target
			var/separation_time = 0
			var/almost_complete = 0

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2)
						if(config.require_heads_alive) return 0
					else
						if(!target.current.handcuffed)
							return 0
				else if(config.require_heads_alive) return 0
				return 1

			proc/find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target

			get_points()
				if(target)
					switch(GetRank(owner.assigned_role))
						if(4)
							return 30
						if(3)
							return 40
						if(2)
							return 50
						if(1)
							return 55
						if(0)
							return 60
				else
					return 0


		hijack
			explanation_text = "Hijack the emergency shuttle by escaping alone."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat == 2)
					return 0
				var/turf/location = get_turf(owner.current.loc)

				if(location in locate(/area/shuttle/escape/centcom))
					for(var/mob/living/player in locate(/area/shuttle/escape/centcom))
						if (player.mind && (player.mind != owner))
							if (player.stat != 2) //they're not dead
								return 0
					return 1

				return 0
			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 65
					if(2)
						return 65
					if(3)
						return 50
					if(4)
						return 35


		escape
			explanation_text = "Escape on the shuttle alive, without being arrested."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0

				var/turf/location = get_turf(owner.current.loc)
				if(!location)
					return 0

				if(owner.current:handcuffed || istype(location, /turf/simulated/shuttle/floor4))
					return 0

				if(location in locate(/area/shuttle/escape/centcom))
					return 1

				return 0
			get_points()
				return INFINITY


		survive
			explanation_text = "Stay alive until the end."

			check_completion()
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1
			get_points()
				return INFINITY


		steal
			var/obj/item/steal_target

			check_completion()
				if(steal_target)
					if(owner.current.check_contents_for(steal_target))
						return 1
					else
						return 0


			captainslaser
				steal_target = /obj/item/weapon/gun/energy/laser/captain
				explanation_text = "Steal the captain's antique laser gun."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 60
						if(1)
							return 50
						if(2)
							return 40
						if(3)
							return 30
						if(4)
							return 20


			plasmatank
				steal_target = /obj/item/weapon/tank/plasma
				explanation_text = "Steal a small plasma tank."
				weight = 20

				get_points(var/job)
					if(job in science_positions)
						return 10
					return 20


			/*Removing this as an objective.  Not necessary to have two theft objectives in the same room.
			steal/captainssuit
				steal_target = /obj/item/clothing/under/rank/captain
				explanation_text = "Steal a captain's rank jumpsuit"
				weight = 50

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return INFINITY
			*/


			handtele
				steal_target = /obj/item/weapon/hand_tele
				explanation_text = "Steal a hand teleporter."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			RCD
				steal_target = /obj/item/weapon/rcd
				explanation_text = "Steal a rapid construction device."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			burger
				steal_target = /obj/item/weapon/reagent_containers/food/snacks/human/burger
				explanation_text = "Steal a burger made out of human organs, this will be presented as proof of NanoTrasen's chronic lack of standards."
				weight = 60

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			jetpack
				steal_target = /obj/item/weapon/tank/jetpack
				explanation_text = "Steal a jetpack.."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			magboots
				steal_target = /obj/item/clothing/shoes/magboots
				explanation_text = "Steal a pair of NanoTrasen brand magboots.  They're better than ours."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			blueprints
				steal_target = /obj/item/blueprints
				explanation_text = "Steal the station's blueprints, for use by our \"demolition\" crews."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			voidsuit
				steal_target = /obj/item/clothing/suit/space/nasavoid
				explanation_text = "Steal a voidsuit.  Supposedly, these suits are better functioning than any produced today."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10


			nuke_disk
				steal_target = /obj/item/weapon/disk/nuclear
				explanation_text = "Steal the station's nuclear authentication disk.  We need it for... things.  *cough*"
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 80
						if(2)
							return 70
						if(3)
							return 40
						if(4)
							return 25

			nuke_gun
				steal_target = /obj/item/weapon/gun/energy/gun/nuclear
				explanation_text = "Steal a nuclear powered gun.  We may be able to get the upper hand..."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 80
						if(2)
							return 70
						if(3)
							return 50
						if(4)
							return 40

			diamond_drill
				steal_target = /obj/item/weapon/pickaxe/diamonddrill
				explanation_text = "Steal a diamond drill.  All the better to drill through a hull with, eh?"
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 80
						if(2)
							return 70
						if(3)
							return 50
						if(4)
							return 40

			boh
				steal_target = /obj/item/weapon/storage/backpack/holding
				explanation_text = "Steal a \"bag of holding.\"  Apparently these things are extremely dangerous..."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 80
						if(2)
							return 70
						if(3)
							return 50
						if(4)
							return 40

			hyper_cell
				steal_target = /obj/item/weapon/cell/hyper
				explanation_text = "Steal a hyper capacity power cell.  Our head researcher is drooling at the thought of it."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 80
						if(2)
							return 70
						if(3)
							return 50
						if(4)
							return 40

			lucy
				steal_target = /obj/item/stack/sheet/diamond
				explanation_text = "Steal 10 diamonds.  It's not for an engagement ring, why do you ask?"
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 80
						if(1)
							return 70
						if(2)
							return 55
						if(3)
							return 40
						if(4)
							return 20

			gold
				steal_target = /obj/item/stack/sheet/gold
				explanation_text = "Steal 50 gold bars.  We need the cash."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 80
						if(1)
							return 70
						if(2)
							return 55
						if(3)
							return 40
						if(4)
							return 20

			uranium
				steal_target = /obj/item/stack/sheet/uranium
				explanation_text = "Steal 25 enriched uranium bars... no reason, we swear!"
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 80
						if(1)
							return 70
						if(2)
							return 55
						if(3)
							return 40
						if(4)
							return 20


			/*Needs some work before it can be put in the game to differentiate ship implanters from syndicate implanters.
			steal/implanter
				steal_target = /obj/item/weapon/implanter
				explanation_text = "Steal an implanter"
				weight = 50

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return INFINITY
			*/
			cyborg
				steal_target = /obj/item/robot_parts/robot_suit
				explanation_text = "Steal a completed cyborg shell (no brain)"
				weight = 30

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10

				check_completion()
					if(steal_target)
						for(var/obj/item/robot_parts/robot_suit/objective in owner.current.get_contents())
							if(istype(objective,/obj/item/robot_parts/robot_suit) && objective.check_completion())
								return 1
						return 0
			AI
				steal_target = /obj/structure/AIcore
				explanation_text = "Steal a finished AI Construct (with brain)"
				weight = 50

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10

				check_completion()
					if(steal_target)
						for(var/obj/item/device/aicard/C in owner.current.get_contents())
							for(var/mob/living/silicon/ai/M in C)
								if(istype(M, /mob/living/silicon/ai) && M.stat != 2)
									return 1
						for(var/mob/living/silicon/ai/M in world)
							if(istype(M.loc, /turf))
								if(istype(get_area(M), /area/shuttle/escape))
									return 1
						for(var/obj/structure/AIcore/M in world)
							if(istype(M.loc, /turf) && M.state == 4)
								if(istype(get_area(M), /area/shuttle/escape))
									return 1
						return 0

			drugs
				steal_target = /datum/reagent/space_drugs
				explanation_text = "Steal some space drugs"
				weight = 40

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0


			pacid
				steal_target = /datum/reagent/pacid
				explanation_text = "Steal some polytrinic acid"
				weight = 40

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0


			reagent
				var/target_name
				var/reagent_name
				proc/find_target()
					var/list/items = list("Sulphuric acid", "Polytrinic acid", "Space Lube", "Unstable mutagen",\
					 "Leporazine", "Cryptobiolin", "Lexorin ",\
					  "Kelotane", "Dexalin", "Tricordrazine")
					target_name = pick(items)
					switch(target_name)
						if("Sulphuric acid")
							steal_target = /datum/reagent/acid
						if("Polytrinic acid")
							steal_target = /datum/reagent/pacid
						if("Space Lube")
							steal_target = /datum/reagent/lube
						if("Unstable mutagen")
							steal_target = /datum/reagent/mutagen
						if("Leporazine")
							steal_target = /datum/reagent/leporazine
						if("Cryptobiolin")
							steal_target =/datum/reagent/cryptobiolin
						if("Lexorin")
							steal_target = /datum/reagent/lexorin
						if("Kelotane")
							steal_target = /datum/reagent/kelotane
						if("Dexalin")
							steal_target = /datum/reagent/dexalin
						if("Tricordrazine")
							steal_target = /datum/reagent/tricordrazine

					explanation_text = "Steal a container filled with [target_name]."

					return steal_target

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 75
						if(1)
							return 60
						if(2)
							return 50
						if(3)
							return 30
						if(4)
							return 10

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0


		nuclear
			explanation_text = "Destroy the station with a nuclear device."


		block
			explanation_text = "Do not allow any humans to escape on the shuttle alive."


			check_completion()
				if(!istype(owner.current, /mob/living/silicon))
					return 0
				if(emergency_shuttle.location<2)
					return 0
				if(!owner.current)
					return 0
				var/area/shuttle = locate(/area/shuttle/escape/centcom)
				var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
				for(var/mob/living/player in world)
					if(player.type in protected_mobs)	continue
					if (player.mind)
						if (player.stat != 2)
							if (get_turf(player) in shuttle)
								return 0
				return 1

		decapitate
			var/datum/mind/target
			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "[target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role], has defied us for the last time.  Make an example of him, and bring us his severed head."
				else
					explanation_text = "Free Objective"
				return target


			proc/find_target_by_role(role, role_type=0)
				..(role, role_type)
				if(target && target.current)
					explanation_text = "[target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)], has defied us for the last time.  Make an example of him, and bring us his severed head."
				else
					explanation_text = "Free Objective"
				return target


			check_completion()
				if(target && target.current)
					if(!owner.current||owner.current.stat==2)//If you're otherwise dead.
						return 0
					var/list/all_items = owner.current.get_contents()
					for(var/obj/item/weapon/organ/head/mmi in all_items)
						if(mmi.brainmob&&mmi.brainmob.mind==target)
							return 1
					return 0
				else
					return 1

		absorb
			var/target_amount
			proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
				target_amount = rand (lowbound,highbound)
				if (ticker)
					var/n_p = 1 //autowin
					if (ticker.current_state == GAME_STATE_SETTING_UP)
						for(var/mob/new_player/P in world)
							if(P.client && P.ready && P.mind!=owner)
								n_p ++
					else if (ticker.current_state == GAME_STATE_PLAYING)
						for(var/mob/living/carbon/human/P in world)
							if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
								n_p ++
					target_amount = min(target_amount, n_p)

				explanation_text = "Absorb [target_amount] compatible genomes."
				return target_amount

			check_completion()
				if(owner && owner.current && owner.current.changeling && owner.current.changeling.absorbed_dna && ((owner.current.changeling.absorbed_dna.len - 1) >= target_amount))
					return 1
				else
					return 0

		download
			var/target_amount
			proc/gen_amount_goal()
				target_amount = rand(10,20)
				explanation_text = "Download [target_amount] research levels."
				return target_amount


			check_completion()
				if(!ishuman(owner.current))
					return 0
				if(!owner.current || owner.current.stat == 2)
					return 0
				if(!(istype(owner.current:wear_suit, /obj/item/clothing/suit/space/space_ninja)&&owner.current:wear_suit:s_initialized))
					return 0
				var/current_amount
				var/obj/item/clothing/suit/space/space_ninja/S = owner.current:wear_suit
				if(!S.stored_research.len)
					return 0
				else
					for(var/datum/tech/current_data in S.stored_research)
						if(current_data.level>1)	current_amount+=(current_data.level-1)
				if(current_amount<target_amount)	return 0
				return 1


		debrain//I want braaaainssss
			var/datum/mind/target
			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "Steal the brain of [target.current.real_name]."
				else
					explanation_text = "Free Objective"
				return target


			proc/find_target_by_role(role, role_type=0)
				..(role, role_type)
				if(target && target.current)
					explanation_text = "Steal the brain of [target.current.real_name] the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
				else
					explanation_text = "Free Objective"
				return target


			check_completion()
				if(!target)//If it's a free objective.
					return 1
				if(!owner.current||owner.current.stat==2)//If you're otherwise dead.
					return 0
				var/list/all_items = owner.current.get_contents()
				for(var/obj/item/device/mmi/mmi in all_items)
					if(mmi.brainmob&&mmi.brainmob.mind==target)	return 1
				for(var/obj/item/brain/brain in all_items)
					if(brain.brainmob&&brain.brainmob.mind==target)	return 1
				return 0

		mutiny
			var/datum/mind/target
			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
				else
					explanation_text = "Free Objective"
				return target


			proc/find_target_by_role(role, role_type=0)
				..(role, role_type)
				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
				else
					explanation_text = "Free Objective"
				return target


			check_completion()
				if(target && target.current)
					var/turf/T = get_turf(target.current)
					if(target.current.stat == 2)
						return 1
					else if((T) && (T.z != 1))//If they leave the station they count as dead for this
						return 2
					else
						return 0
				else
					return 1

		capture
			var/target_amount
			proc/gen_amount_goal()
				target_amount = rand(5,10)
				explanation_text = "Accumulate [target_amount] capture points."
				return target_amount


			check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
				var/captured_amount = 0
				var/area/centcom/holding/A = locate()
				for(var/mob/living/carbon/human/M in A)//Humans.
					if(M.stat==2)//Dead folks are worth less.
						captured_amount+=0.5
						continue
					captured_amount+=1
				for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
					captured_amount+=0.1
				for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
					if(M.stat==2)
						captured_amount+=0.5
						continue
					captured_amount+=1
				for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
					if(istype(M, /mob/living/carbon/alien/humanoid/queen))//Queens are worth three times as much as humans.
						if(M.stat==2)
							captured_amount+=1.5
						else
							captured_amount+=3
						continue
					if(M.stat==2)
						captured_amount+=1
						continue
					captured_amount+=2
				if(captured_amount<target_amount)
					return 0
				return 1