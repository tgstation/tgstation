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
				var/list/items = list(
					"the captain's antique laser gun", 
					"a hand teleporter",
					"an RCD",
					"a jetpack",
					"a captains jumpsuit",
					"functional ai",
					"a pair of magboots",
					"the station blueprints",
					"thermal optics",
					"the engineers rig suit",
					"28 moles of plasma (full tank)"
				)
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
					if("the station blueprints")
						steal_target = /obj/item/blueprints
					if("a pair of magboots")
						steal_target = /obj/item/clothing/shoes/magboots
					if("thermal optics")
						steal_target = /obj/item/clothing/glasses/thermal
					if("the engineers rig suit")
						steal_target = /obj/item/clothing/suit/space/rig
					if("28 moles of plasma (full tank)")
						steal_target = /obj/item/weapon/tank


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
							else if (target_name == "28 moles of plasma (full tank)")
								var/target = 28 //moles
								var/found_toxins = 0.0 //moles
								for(var/obj/item/weapon/tank/T in owner.current.contents)
									found_toxins += T.air_contents.toxins
								return found_toxins>=target
								
							else
								return 1
						else
							return 0

		nuclear
			explanation_text = "Destroy the station with a nuclear device."

		absorb
			var/num_to_eat //this is supposed to be semi-random but fuck it for now, this is alpha

			proc/gen_num_to_eat()  //this doesn't work -- should work now, changed it a bit -- Urist
				num_to_eat = rand (4,6)
				explanation_text = "Absorb [num_to_eat] compatible genomes."
				return num_to_eat

			check_completion()
				if((owner.current.absorbed_dna.len - 1) >= num_to_eat)
					return 1
				else
					return 0

/* Isn't suited for global objectives
/*---------CULTIST----------*/

		eldergod
			explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

			check_completion()
				if(eldergod) //global var, defined in rune4.dm
					return 1
				return 0

		survivecult
			var/num_cult

			explanation_text = "Our knowledge must live on. Make sure at least 5 acolytes escape on the shuttle to spread their work on an another station."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				var/cultists_escaped = 0

				var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
				for(var/turf/T in	get_area_turfs(C.type))
					for(var/mob/living/carbon/human/H in T)
						if(cultists.Find(H))
							cultists_escaped++

				if(cultists_escaped>=5)
					return 1

				return 0

		sacrifice //stolen from traitor target objective

			proc/find_target() //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
				var/list/possible_targets = call(/datum/game_mode/cult/proc/get_unconvertables)()

				if(possible_targets.len > 0)
					sacrifice_target = pick(possible_targets)

				if(sacrifice_target && sacrifice_target.current)
					explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
				else
					explanation_text = "Free Objective"

				return sacrifice_target

			check_completion() //again, calling on a global list defined in rune15.dm
				if(sacrifice_target.current in sacrificed)
					return 1
				else
					return 0

/*-------ENDOF CULTIST------*/
*/