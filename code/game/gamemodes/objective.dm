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
					if(target.current.stat == 2 || istype(target.current.loc.loc, /area/tdome) || istype(target.current,/mob/living/silicon) || istype(target.current,/mob/living/carbon/brain)) //Assuming this works, people in the thunderdome and borgs now count as dead for traitor objectives. --NeoFite
						return 1
					else
						return 0
				else
					return 1

		hijack
			explanation_text = "Hijack the emergency shuttle by escaping alone."

			check_completion()
				if(istype(owner.current, /mob/living/silicon))
					return 0
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
				if(istype(owner.current, /mob/living/silicon))
					return 0
				if(istype(owner.current, /mob/living/carbon/brain))
					return 0
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
				if(istype(owner.current, /mob/living/silicon) && owner.current != owner.original)
					return 0
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1


		steal
			var/obj/item/steal_target
			var/target_name
			var/global/list/possible_items = list(
				"the captain's antique laser gun" = /obj/item/weapon/gun/energy/laser/captain,
				"a hand teleporter" = /obj/item/weapon/hand_tele,
				"an RCD" = /obj/item/weapon/rcd,
				"a jetpack" = /obj/item/weapon/tank/jetpack,
				"a captains jumpsuit" = /obj/item/clothing/under/rank/captain,
				"functional ai" = /obj/item/device/aicard,
				"a pair of magboots" = /obj/item/clothing/shoes/magboots,
				"the station blueprints" = /obj/item/blueprints,
				"thermal optics" = /obj/item/clothing/glasses/thermal,
				"the engineers rig suit" = /obj/item/clothing/suit/space/rig,
				"28 moles of plasma (full tank)" = /obj/item/weapon/tank,
			)

			var/global/list/possible_items_special = list(
				"nuclear authentication disk" = /obj/item/weapon/disk/nuclear,
			)

			proc/set_target(var/target_name as text)
				src.target_name = target_name
				src.steal_target = possible_items[target_name]
				if (!src.steal_target )
					src.steal_target = possible_items_special[target_name]
				src.explanation_text = "Steal [target_name]."
				return src.steal_target

			proc/find_target()
				return set_target(pick(possible_items))

			proc/select_target()
				var/list/possible_items_all = possible_items+possible_items_special+"custom"
				var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
				if (!new_target) return

				if (new_target == "custom")
					var/steal_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
					if (!steal_target) return
					var/tmp_obj = new steal_target
					new_target = tmp_obj:name
					del(tmp_obj)
					new_target = input("Enter target name:", "Objective target", new_target) as text|null
					if (!new_target) return

					src.target_name = new_target
					src.steal_target = steal_target
					src.explanation_text = "Steal [new_target]."

				else
					set_target(new_target)

				return src.steal_target

			check_completion()
				if(!steal_target || !owner.current)
					return 0
				var/list/all_items = owner.current.get_contents()
				switch (target_name)
					if ("28 moles of plasma (full tank)")
						var/target = 28 //moles
						var/found_toxins = 0.0 //moles
						for(var/obj/item/weapon/tank/T in all_items)
							found_toxins += T.air_contents.toxins
						return found_toxins>=target
					if("functional ai")
//						world << "dude's after an AI, time to check for one."
						for(var/obj/item/device/aicard/C in all_items)
//							world << "Found an intelicard, checking it for an AI"
							for(var/mob/living/silicon/ai/M in C)
//								world << "Found an AI, checking if it's alive"
								if(istype(M, /mob/living/silicon/ai) && M.stat != 2)
//									world << "yay, you win!"
									return 1
					else
						for(var/obj/I in all_items)
							if(I.type == steal_target)
								return 1
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
				if(owner && owner.current && owner.current.absorbed_dna && ((owner.current.absorbed_dna.len - 1) >= num_to_eat))
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
					for(var/mob/living/carbon/H in T)
						if(iscultist(H))
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