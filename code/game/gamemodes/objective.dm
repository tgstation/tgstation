//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.

	New(var/text)
		if(text)
			explanation_text = text

	proc/check_completion()
		return 1

	proc/find_target()
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2))
				possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)


	proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
				target = possible_target
				break



datum/objective/assassinate
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
				return 1
			return 0
		return 1



datum/objective/mutiny
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD)
				return 1
			var/turf/T = get_turf(target.current)
			if(T && (T.z != 1))			//If they leave the station they count as dead for this
				return 2
			return 0
		return 1


datum/objective/debrain//I want braaaainssss
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)//If it's a free objective.
			return 1
		if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
			return 0
		if( !target.current || !isbrain(target.current) )
			return 0
		var/atom/A = target.current
		while(A.loc)			//check to see if the brainmob is on our person
			A = A.loc
			if(A == owner.current)
				return 1
		return 0


datum/objective/protect//The opposite of killing a dude.
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)			//If it's a free objective.
			return 1
		if(target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
				return 0
			return 1
		return 0


datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone."

	check_completion()
		if(!owner.current || owner.current.stat)
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(issilicon(owner.current))
			return 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind && (player.mind != owner))
				if(player.stat != DEAD)			//they're not dead!
					if(get_turf(player) in shuttle)
						return 0
		return 1


datum/objective/block
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
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind)
				if (player.stat != 2)
					if (get_turf(player) in shuttle)
						return 0
		return 1

datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		for(var/mob/living/player in player_list)
			if(player == owner.current)
				continue
			if(player.mind)
				if(player.stat != DEAD)
					var/turf/T = get_turf(player)
					if(!T)	continue
					switch(T.loc.type)
						if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
							return 0
		return 1


datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive."


	check_completion()
		if(issilicon(owner.current))
			return 0
		if(isbrain(owner.current))
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(!owner.current || owner.current.stat ==2)
			return 0
		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

		if(istype(location, /turf/simulated/shuttle/floor4)) // Fails tratiors if they are in the shuttle brig -- Polymorph
			return 0

		var/area/check_area = location.loc
		if(istype(check_area, /area/shuttle/escape/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod1/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod2/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod3/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod5/centcom))
			return 1
		else
			return 0



datum/objective/survive
	explanation_text = "Stay alive until the end."

	check_completion()
		if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
			return 0		//Brains no longer win survive objectives. --NEO
		if(issilicon(owner.current) && owner.current != owner.original)
			return 0
		return 1


datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."



datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/global/possible_items[] = list(
		"the captain's antique laser gun" = /obj/item/weapon/gun/energy/laser/captain,
		"a hand teleporter" = /obj/item/weapon/hand_tele,
		"an RCD" = /obj/item/weapon/rcd,
		"a jetpack" = /obj/item/weapon/tank/jetpack,
		"a captains jumpsuit" = /obj/item/clothing/under/rank/captain,
		"a functional AI" = /obj/item/device/aicard,
		"a pair of magboots" = /obj/item/clothing/shoes/magboots,
		"the station blueprints" = /obj/item/blueprints,
		"a nasa voidsuit" = /obj/item/clothing/suit/space/nasavoid,
		"28 moles of plasma (full tank)" = /obj/item/weapon/tank,
	)

	var/global/possible_items_special[] = list(
		"nuclear authentication disk" = /obj/item/weapon/disk/nuclear,
		"nuclear gun" = /obj/item/weapon/gun/energy/gun/nuclear,
		"diamond drill" = /obj/item/weapon/pickaxe/diamonddrill,
		"bag of holding" = /obj/item/weapon/storage/backpack/holding,
		"hyper-capacity cell" = /obj/item/weapon/cell/hyper,
		"10 diamonds" = /obj/item/stack/sheet/diamond,
		"50 gold bars" = /obj/item/stack/sheet/gold,
		"25 refined uranium bars" = /obj/item/stack/sheet/uranium,
	)


	proc/set_target(item_name)
		target_name = item_name
		steal_target = possible_items[target_name]
		if (!steal_target )
			steal_target = possible_items_special[target_name]
		explanation_text = "Steal [target_name]."
		return steal_target


	find_target()
		return set_target(pick(possible_items))


	proc/select_target()
		var/list/possible_items_all = possible_items+possible_items_special+"custom"
		var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
		if (!new_target) return
		if (new_target == "custom")
			var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
			if (!custom_target) return
			var/tmp_obj = new custom_target
			var/custom_name = tmp_obj:name
			del(tmp_obj)
			custom_name = copytext(sanitize(input("Enter target name:", "Objective target", custom_name) as text|null),1,MAX_MESSAGE_LEN)
			if (!custom_name) return
			target_name = custom_name
			steal_target = custom_target
			explanation_text = "Steal [target_name]."
		else
			set_target(new_target)
		return steal_target

	check_completion()
		if(!steal_target || !owner.current)	return 0
		if(!isliving(owner.current))	return 0
		var/list/all_items = owner.current.get_contents()
		switch (target_name)
			if("28 moles of plasma (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
				var/target_amount = text2num(target_name)//Non-numbers are ignored.
				var/found_amount = 0.0//Always starts as zero.

				for(var/obj/item/I in all_items) //Check for plasma tanks
					if(istype(I, steal_target))
						found_amount += (target_name=="28 moles of plasma (full tank)" ? (I:air_contents:toxins) : (I:amount))
				return found_amount>=target_amount

			if("50 coins (in bag)")
				var/obj/item/weapon/moneybag/B = locate() in all_items

				if(B)
					var/target = text2num(target_name)
					var/found_amount = 0.0
					for(var/obj/item/weapon/coin/C in B)
						found_amount++
					return found_amount>=target

			if("a functional AI")
				for(var/obj/item/device/aicard/C in all_items) //Check for ai card
					for(var/mob/living/silicon/ai/M in C)
						if(istype(M, /mob/living/silicon/ai) && M.stat != 2) //See if any AI's are alive inside that card.
							return 1
			else

				for(var/obj/I in all_items) //Check for items
					if(istype(I, steal_target))
						return 1
		return 0



datum/objective/download
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



datum/objective/capture
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



datum/objective/absorb
	proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
		target_amount = rand (lowbound,highbound)
		if (ticker)
			var/n_p = 1 //autowin
			if (ticker.current_state == GAME_STATE_SETTING_UP)
				for(var/mob/new_player/P in player_list)
					if(P.client && P.ready && P.mind!=owner)
						n_p ++
			else if (ticker.current_state == GAME_STATE_PLAYING)
				for(var/mob/living/carbon/human/P in player_list)
					if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
						n_p ++
			target_amount = min(target_amount, n_p)

		explanation_text = "Absorb [target_amount] compatible genomes."
		return target_amount

	check_completion()
		if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
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
