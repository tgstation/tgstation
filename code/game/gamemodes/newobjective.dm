#define FRAME_PROBABILITY 3
#define THEFT_PROBABILITY 55
#define KILL_PROBABILITY 37
#define PROTECT_PROBABILITY 5

#define LENIENT 0
#define NORMAL 1
#define HARD 2
#define IMPOSSIBLE 3


/proc/GenerateTheft(var/job,var/datum/mind/traitor)
	var/list/datum/objective/objectives = list()

	for(var/o in typesof(/datum/objective/steal))
		if(o != /datum/objective/steal)		//Make sure not to get a blank steal objective.
			var/datum/objective/target = new o(null,job)
			objectives += target
			objectives[target] = target.weight
	return objectives

/proc/GenerateAssassinate(var/job,var/datum/mind/traitor)
	var/list/datum/objective/assassinate/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/assassinate(null,job,target)
				missions += target_obj
				missions[target_obj] = target_obj.weight
	return missions

/proc/GenerateFrame(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/frame(null,job,target)
				missions += target_obj
				missions[target_obj] = target_obj.weight
	return missions

/proc/GenerateProtection(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/protection(null,job,target)
				missions += target_obj
				missions[target_obj] = target_obj.weight
	return missions


/proc/SelectObjectives(var/job,var/datum/mind/traitor,var/hijack = 0)
	var/list/chosenobjectives = list()
	var/list/theftobjectives = GenerateTheft(job,traitor)		//Separated all the objective types so they can be picked independantly of each other.
	var/list/killobjectives = GenerateAssassinate(job,traitor)
	var/list/frameobjectives = GenerateFrame(job,traitor)
	var/list/protectobjectives = GenerateProtection(job,traitor)
	var/total_weight
	var/conflict

	var/steal_weight = THEFT_PROBABILITY
	var/frame_weight = FRAME_PROBABILITY
	var/kill_weight = KILL_PROBABILITY
	var/protect_weight = PROTECT_PROBABILITY
	var/target_weight = 50

/////////////////////////////////////////////////////////////
//HANDLE ASSIGNING OBJECTIVES BASED OFF OF PREVIOUS SUCCESS//
/////////////////////////////////////////////////////////////

	var/savefile/info = new("data/player_saves/[copytext(traitor.key, 1, 2)]/[traitor.key]/traitor.sav")
	var/list/infos
	info >> infos
	if(istype(infos))
		var/total_attempts = infos["Total"]
		var/total_overall_success = infos["Success"]
		var/success_ratio = total_overall_success/total_attempts
		var/steal_success = infos["Steal"]
		var/kill_success = infos["Kill"]
		var/frame_success = infos["Frame"]
		var/protect_success = infos["Protect"]

		var/list/ordered_success = list(steal_success, kill_success, frame_success, protect_success)

		var/difficulty = pick(LENIENT, LENIENT, NORMAL, NORMAL, NORMAL, HARD, HARD, IMPOSSIBLE)
		//Highest to lowest in terms of success rate, and resulting weight for later computation
		var/success_weights = list(1, 1, 1, 1)
		switch(difficulty)
			if(LENIENT)
				success_weights = list(1.5, 1, 0.75, 0.5)
				target_weight = success_ratio*100
			if(NORMAL)
				target_weight = success_ratio*150
			if(HARD)
				success_weights = list(0.66, 0.8, 1, 1.25)
				target_weight = success_ratio*200
			if(IMPOSSIBLE) //YOU SHALL NOT PASS
				success_weights = list(0.5, 0.75, 1.2, 2)
				target_weight = success_ratio*300

		for(var/i = 1, i <= 4, i++)
		//Iterate through the success rates, and determine the weights to chose based on the highest to
		//	the lowest to multiply it by the proper success ratio.
			var/weight = max(ordered_success)
			ordered_success -= weight
			if(weight == steal_success)
				steal_weight *= steal_success*success_weights[i]
			else if(weight == frame_success)
				frame_weight *= frame_success*success_weights[i]
			else if(weight == protect_success)
				protect_weight *= protect_success*success_weights[i]
			else if(weight == kill_success)
				kill_weight *= kill_success*success_weights[i]

		var/total_weights = kill_weight + protect_weight + frame_weight + steal_weight
		frame_weight = round(frame_weight/total_weights)
		kill_weight = round(kill_weight/total_weights)
		steal_weight = round(steal_weight/total_weights)
		//Protect is whatever is left over.

	var/steal_range = steal_weight
	var/frame_range = frame_weight + steal_range
	var/kill_range = kill_weight + frame_range
	//Protect is whatever is left over.

	while(total_weight < target_weight)
		var/selectobj = rand(1,100)	//Randomly determine the type of objective to be given.
		if(!length(killobjectives) || !length(protectobjectives)|| !length(frameobjectives))	//If any of these lists are empty, just give them theft objectives.
			var/datum/objective/objective = pickweight(theftobjectives)
			chosenobjectives += objective
			total_weight += objective.points
			theftobjectives -= objective
		else switch(selectobj)
			if(1 to steal_range)
				if(!theftobjectives.len)
					continue
				var/datum/objective/objective = pickweight(theftobjectives)
				for(1 to 10)
					if(objective.points + total_weight <= 100 || !theftobjectives.len)
						break
					theftobjectives -= objective
					objective = pickweight(theftobjectives)
				if(!objective && !theftobjectives.len)
					continue
				chosenobjectives += objective
				total_weight += objective.points
				theftobjectives -= objective
			if(steal_range + 1 to frame_range)	//Framing Objectives (3% chance)
				if(!frameobjectives.len)
					continue
				var/datum/objective/objective = pickweight(frameobjectives)
				for(1 to 10)
					if(objective.points + total_weight <= 100 || !frameobjectives.len)
						break
					frameobjectives -= objective
					objective = pickweight(frameobjectives)
				if(!objective && !frameobjectives.len)
					continue
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					total_weight += objective.points
				frameobjectives -= objective
				conflict = 0
			if(frame_range + 1 to kill_range)
				if(!killobjectives.len)
					continue
				var/datum/objective/assassinate/objective = pickweight(killobjectives)
				world << objective
				for(1 to 10)
					if(objective.points + total_weight <= 100 || !killobjectives.len)
						break
					killobjectives -= objective
					objective = pickweight(killobjectives)
				if(!objective && !killobjectives.len)
					continue
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/frame/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					total_weight += objective.points
				killobjectives -= objective
				conflict = 0
			if(kill_range + 1 to 100)	//Protection Objectives (5% chance)
				if(!protectobjectives.len)
					continue
				var/datum/objective/protection/objective = pickweight(protectobjectives)
				for(1 to 10)
					if(objective.points + total_weight <= 100 || !protectobjectives.len)
						break
					protectobjectives -= objective
					objective = pickweight(protectobjectives)
				if(!objective || !protectobjectives.len)
					continue
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/frame/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					total_weight += objective.points
				protectobjectives -= objective
				conflict = 0

	if(!locate(/datum/objective/hijack) in chosenobjectives && !locate(/datum/objective/escape) in chosenobjectives)
		if(hijack)
			chosenobjectives += new /datum/objective/hijack(null,job)
		else
			chosenobjectives += new /datum/objective/escape(null,job)
	return chosenobjectives

datum
	objective
		var/datum/mind/owner
		var/datum/mind/target
		var/explanation_text = "text not set"
		var/job
		var/points = INFINITY //If this isn't set to something else, the objective is bugged and should be ignored
		var/weight = INFINITY

		New(var/text,var/joba)
			if(text)
				src.explanation_text = text
			job=joba
			weight = get_weight(job)
			points = get_points(job)

		proc/check_completion()
			return 1
		proc/get_points(var/job)
			return INFINITY
		proc/get_weight(var/job)
			return INFINITY
		proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
			for(var/datum/mind/possible_target in ticker.minds)
				if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
					target = possible_target
					break


		frame
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
					var/difficulty = GetRank(target.assigned_role) + 1
					switch(GetRank(job))
						if(4)
							return 20*difficulty
						if(3)
							return 30*difficulty
						if(2)
							return 40*difficulty
						if(1)
							return 55*difficulty
						if(0)
							return 60*difficulty
				else
					return INFINITY

			get_weight()
				if(target)
					return 1
				return 0


		protection
			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				weight = get_points(job)
				explanation_text = "[target.current.real_name], the [target.assigned_role] is a [pick("relative of a","friend of a","") + pick("high ranking","important","well-liked")] Syndicate [pick("Leader","Officer","Agent","sympathiser")].  Make sure they get off the station safely, while minimizing intervention."

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
				if(target)
					return 30
				else
					return INFINITY

			get_weight()
				if(target)
					return 1
				return 0

			find_target_by_role(role, role_type=0)
				..(role, role_type)
				if(target && target.current)
					explanation_text = "Protect [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
				else
					explanation_text = "Free Objective"
				return target


		assassinate

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				weight = get_points(job)
				explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2 || istype(get_area(target.current), /area/tdome) || issilicon(target.current) || isbrain(target.current))
						return 1
					else
						return 0
				else
					return 1
			get_points()
				if(target)
					var/difficulty = GetRank(target.assigned_role) + 1
					switch(GetRank(job))
						if(4)
							return 20*difficulty
						if(3)
							return 30*difficulty
						if(2)
							return 40*difficulty
						if(1)
							return 55*difficulty
						if(0)
							return 60*difficulty
				else
					return 0

			get_weight()
				if(target)
					return 1
				return 0

			find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
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
					explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target


		capture
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

			find_target_by_role(var/role)
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
					var/difficulty = GetRank(target.assigned_role) + 1
					switch(GetRank(job))
						if(4)
							return 20*difficulty
						if(3)
							return 30*difficulty
						if(2)
							return 40*difficulty
						if(1)
							return 55*difficulty
						if(0)
							return 60*difficulty
				else
					return INFINITY

			get_weight()
				if(target)
					return 1
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

			get_weight(var/job)
				return 1

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

			get_weight(var/job)
				return 1


		survive
			explanation_text = "Stay alive."

			check_completion()
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1
			get_points()
				return INFINITY

			get_weight(var/job)
				return 1


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

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20


			plasmatank
				steal_target = /obj/item/weapon/tank/plasma
				explanation_text = "Steal a small plasma tank."
				weight = 20

				get_points(var/job)
					if(job in science_positions || job in command_positions)
						return 20
					return 40

				get_weight(var/job)
					return 20

				check_completion()
					var/list/all_items = owner.current.get_contents()
					for(var/obj/item/I in all_items)
						if(!istype(I, steal_target))	continue//If it's not actually that item.
						if(I:air_contents:toxins) return 1 //If they got one with plasma
					return 0


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
							return 20

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20


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
							return 20

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20


			/*burger
				steal_target = /obj/item/weapon/reagent_containers/food/snacks/human/burger
				explanation_text = "Steal a burger made out of human organs, this will be presented as proof of NanoTrasen's chronic lack of standards."
				weight = 60

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 80
						if(1)
							return 65
						if(2)
							return 55
						if(3)
							return 40
						if(4)
							return 25*/


			jetpack
				steal_target = /obj/item/weapon/tank/jetpack/oxygen
				explanation_text = "Steal a blue oxygen jetpack."
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
							return 20

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20


			/*magboots
				steal_target = /obj/item/clothing/shoes/magboots
				explanation_text = "Steal a pair of \"NanoTrasen\" brand magboots."
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
							return 20

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20*/


			blueprints
				steal_target = /obj/item/blueprints
				explanation_text = "Steal the station's blueprints."
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
							return 20

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20


			voidsuit
				steal_target = /obj/item/clothing/suit/space/nasavoid
				explanation_text = "Steal a voidsuit."
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
							return 20

				get_weight(var/job)
					return 20


			nuke_disk
				steal_target = /obj/item/weapon/disk/nuclear
				explanation_text = "Steal the station's nuclear authentication disk."
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

				get_weight(var/job)
					if(GetRank(job) == 4)
						return 10
					else
						return 20

			nuke_gun
				steal_target = /obj/item/weapon/gun/energy/gun/nuclear
				explanation_text = "Steal a nuclear powered gun."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 75

				get_weight(var/job)
					return 2

			diamond_drill
				steal_target = /obj/item/weapon/pickaxe/diamonddrill
				explanation_text = "Steal a diamond drill."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 70
						if(3)
							return 75
						if(4)
							return 75

				get_weight(var/job)
					return 2

			boh
				steal_target = /obj/item/weapon/storage/backpack/holding
				explanation_text = "Steal a \"bag of holding.\""
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 75

				get_weight(var/job)
					return 2

			hyper_cell
				steal_target = /obj/item/weapon/cell/hyper
				explanation_text = "Steal a hyper capacity power cell."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 75

				get_weight(var/job)
					return 2

			lucy
				steal_target = /obj/item/stack/sheet/diamond
				explanation_text = "Steal 10 diamonds."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 75

				get_weight(var/job)
					return 2

				check_completion()
					var/target_amount = 10
					var/found_amount = 0.0//Always starts as zero.
					for(var/obj/item/I in owner.current.get_contents())
						if(!istype(I, steal_target))	continue//If it's not actually that item.
						found_amount += I:amount
					return found_amount>=target_amount

			gold
				steal_target = /obj/item/stack/sheet/gold
				explanation_text = "Steal 50 gold bars."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 70

				get_weight(var/job)
					return 2

				check_completion()
					var/target_amount = 50
					var/found_amount = 0.0//Always starts as zero.
					for(var/obj/item/I in owner.current.get_contents())
						if(!istype(I, steal_target))	continue//If it's not actually that item.
						found_amount += I:amount
					return found_amount>=target_amount

			uranium
				steal_target = /obj/item/stack/sheet/uranium
				explanation_text = "Steal 25 uranium bars."
				weight = 20

				get_points(var/job)
					switch(GetRank(job))
						if(0)
							return 90
						if(1)
							return 85
						if(2)
							return 80
						if(3)
							return 75
						if(4)
							return 70

				get_weight(var/job)
					return 2

				check_completion()
					var/target_amount = 25
					var/found_amount = 0.0//Always starts as zero.
					for(var/obj/item/I in owner.current.get_contents())
						if(!istype(I, steal_target))	continue//If it's not actually that item.
						found_amount += I:amount
					return found_amount>=target_amount


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
							return 20

				check_completion()
					if(steal_target)
						for(var/obj/item/robot_parts/robot_suit/objective in owner.current.get_contents())
							if(istype(objective,/obj/item/robot_parts/robot_suit) && objective.check_completion())
								return 1
						return 0

				get_weight(var/job)
					return 20
			AI
				steal_target = /obj/structure/AIcore
				explanation_text = "Steal a finished AI, either by intellicard or stealing the whole construct."
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
							return 20

				get_weight(var/job)
					return 15

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
				explanation_text = "Steal some space drugs."
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
							return 20

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0

				get_weight(var/job)
					return 20


			pacid
				steal_target = /datum/reagent/pacid
				explanation_text = "Steal some polytrinic acid."
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
							return 20

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0

				get_weight(var/job)
					return 20


			reagent
				weight = 20
				var/target_name
				New(var/text,var/joba)
					..()
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
							return 20

				check_completion()
					if(steal_target)
						if(owner.current.check_contents_for_reagent(steal_target))
							return 1
						else
							return 0

				get_weight(var/job)
					return 20

			cash	//must be in credits - atm and coins don't count
				var/steal_amount = 2000
				explanation_text = "Beg, borrow or steal 2000 credits."
				weight = 20

				New(var/text,var/joba)
					..(text,joba)
					steal_amount = 1250 + rand(0,3750)
					explanation_text = "Beg, borrow or steal [steal_amount] credits."

				get_points(var/job)
					return 10 + 25 * round(steal_amount / 5000)

				check_completion()
					var/held_credits = 0
					for(var/obj/item/weapon/money/M in owner.current.get_contents())
						held_credits += M.worth
					if(held_credits > steal_amount)
						return 1
					return 0

				get_weight(var/job)
					return 20


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
			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				explanation_text = "Remove and recover the head of [target.current.real_name], the [target.assigned_role]."
			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "[target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role], has defied us for the last time.  Make an example of him, and bring us his severed head."
				else
					explanation_text = "Free Objective"
				return target


			find_target_by_role(role, role_type=0)
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

		meme_attune
			var/target_amount
			proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
				target_amount = rand (lowbound,highbound)

				explanation_text = "Attune [target_amount] humanoid brains."
				return target_amount

			check_completion()
				if(owner && owner.current && istype(owner.current,/mob/living/parasite/meme) && (owner.current:indoctrinated.len >= target_amount))
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
			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				explanation_text = "Remove and recover the brain of [target.current.real_name], the [target.assigned_role]."

			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "Steal the brain of [target.current.real_name]."
				else
					explanation_text = "Free Objective"
				return target


			find_target_by_role(role, role_type=0)
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
			proc/find_target()
				..()
				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
				else
					explanation_text = "Free Objective"
				return target


			find_target_by_role(role, role_type=0)
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

datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/area/pod1 =    locate(/area/shuttle/escape_pod1/centcom)
		var/area/pod2 =    locate(/area/shuttle/escape_pod2/centcom)
		var/area/pod3 =    locate(/area/shuttle/escape_pod3/centcom)
		var/area/pod4 =    locate(/area/shuttle/escape_pod5/centcom)

		for(var/mob/living/player in world)
			if (player == owner.current)
				continue
			if (player.mind)
				if (player.stat != 2)
					if (get_turf(player) in shuttle)
						return 0
					if (get_turf(player) in pod1)
						return 0
					if (get_turf(player) in pod2)
						return 0
					if (get_turf(player) in pod3)
						return 0
					if (get_turf(player) in pod4)
						return 0
		return 1

#undef FRAME_PROBABILITY
#undef THEFT_PROBABILITY
#undef KILL_PROBABILITY
#undef PROTECT_PROBABILITY
#undef LENIENT
#undef NORMAL
#undef HARD
#undef IMPOSSIBLE