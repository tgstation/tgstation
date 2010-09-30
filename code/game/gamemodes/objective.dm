datum
	objective
		var/datum/mind/owner
		var/explanation_text

		New(var/text)
			if(text)
				src.explanation_text = text

		proc
			check_completion()
				return 1

		assassinate
			var/datum/mind/target

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

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2 || istype(target.current.loc.loc, /area/tdome)) //Assuming this works, people in the thunderdome now count as dead for traitor objectives. --NeoFite
						return 1
					else
						return 0
				else
					return 1

		hijack
			explanation_text = "Hijack the emergency shuttle by escaping alone."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0

				var/area/shuttle = locate(/area/shuttle/escape/centcom)

				for(var/mob/living/player in world)
					if (player.mind && (player.mind != owner))
						if (player.stat != 2) //they're not dead
							if (get_turf(player) in shuttle)
								return 0

				return 1

		escape
			explanation_text = "Escape on the shuttle alive."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0

				var/turf/location = get_turf(owner.current.loc)
				if(!location)
					return 0

				var/area/check_area = location.loc

				if(istype(check_area, /area/shuttle/escape/centcom))
					return 1
				else
					return 0

		survive
			explanation_text = "Stay alive until the end"

			check_completion()
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1


		steal
			var/obj/item/steal_target
			var/target_name
			proc/find_target()
				var/list/items = list("captain's antique laser gun", "hand teleporter", "RCD", "jetpack", "captains jumpsuit", "functional ai")

				target_name = pick(items)
				switch(target_name)
					if("captain's antique laser gun")
						steal_target = /obj/item/weapon/gun/energy/laser_gun/captain
					if("hand teleporter")
						steal_target = /obj/item/weapon/hand_tele
					if("RCD")
						steal_target = /obj/item/weapon/rcd
					if("jetpack")
						steal_target = /obj/item/weapon/tank/jetpack
					if("captains jumpsuit")
						steal_target = /obj/item/clothing/under/rank/captain
					if("functional ai")
						steal_target = /obj/item/device/aicard


				explanation_text = "Steal a [target_name]."

				return steal_target

			check_completion()
				if(steal_target)
					if(owner.current)
						if(owner.current.check_contents_for(steal_target))
							if(target_name == "functional ai")
//								world << "dude's after an AI, time to check for one."
								for(var/obj/item/device/aicard/C in owner.current.contents)
//									world << "Found an intelicard, checking it for an AI"
									for(var/mob/living/silicon/ai/M in C)
//										world << "Found an AI, checking if it's alive"
										if(istype(M, /mob/living/silicon/ai) && M.stat != 2)
//											world << "yay, you win!"
											return 1
//								world << "didn't find a living AI on the card"
									return 0
							else
								return 1
						else
							return 0

		nuclear
			explanation_text = "Destroy the station with a nuclear device."

		absorb
			var/num_to_eat = 5 //this is supposed to be semi-random but fuck it for now, this is alpha

/*			proc/gen_num_to_eat()  //this doesn't work
				num_to_eat = rand (4,6)
				return num_to_eat
*/

//			gen_num_to_eat()
			explanation_text = "Absorb 5 compatible genomes."

			check_completion()
				if(owner.current.absorbed_dna.len >= num_to_eat)
					return 1
				else
					return 0



