/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_unique_objective(possible_target)
	for(var/datum/objective/O in owner.objectives)
		if(istype(O, type) && O.get_target() == possible_target)
			return 0
	return 1

/datum/objective/proc/get_target()
	return target


/datum/objective/proc/get_crewmember_minds()
	. = list()
	for(var/V in GLOB.data_core.locked)
		var/datum/data/record/R = V
		var/mob/M = R.fields["reference"]
		if(M && M.mind)
			. += M.mind

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && is_unique_objective(possible_target))
			possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	update_explanation_text()
	return target

/datum/objective/proc/find_target_by_role(role, role_type=0, invert=0)//Option sets either to check assigned role or special role. Default to assigned., invert inverts the check, eg: "Don't choose a Ling"
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if((possible_target != owner) && ishuman(possible_target.current))
			var/is_role = 0
			if(role_type)
				if(possible_target.special_role == role)
					is_role++
			else
				if(possible_target.assigned_role == role)
					is_role++

			if(invert)
				if(is_role)
					continue
				target = possible_target
				break
			else if(is_role)
				target = possible_target
				break

	update_explanation_text()

/datum/objective/proc/update_explanation_text()
	//Default does nothing, override where needed

/datum/objective/proc/give_special_equipment(special_equipment)
	if(owner && owner.current)
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			var/list/slots = list ("backpack" = slot_in_backpack)
			for(var/eq_path in special_equipment)
				var/obj/O = new eq_path
				H.equip_in_one_of_slots(O, slots)

/datum/objective/assassinate
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/assassinate/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/assassinate/check_completion()
	if(target && target.current)
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || (H && H.dna.species.id == "memezombies")) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/internal
	var/stolen = 0 		//Have we already eliminated this target?

/datum/objective/assassinate/internal/update_explanation_text()
	..()
	if(target && !target.current)
		explanation_text = "Assassinate [target.name], who was obliterated"


/datum/objective/mutiny
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/mutiny/find_target_by_role(role, role_type=0,invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey)
			return 1
		var/turf/T = get_turf(target.current)
		if(T && (T.z > ZLEVEL_STATION) || (target.current.client && target.current.client.is_afk()))			//If they leave the station or go afk they count as dead for this
			return 2
		return 0
	return 1

/datum/objective/mutiny/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate or exile [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/maroon
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/maroon/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/maroon/check_completion()
	if(target && target.current)
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || (H && H.dna.species.id == "memezombies")) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		if(target.current.onCentCom() || target.current.onSyndieBase())
			return 0
	return 1

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"



/datum/objective/debrain//I want braaaainssss
	var/target_role_type=0

/datum/objective/debrain/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/debrain/check_completion()
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

/datum/objective/debrain/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/protect//The opposite of killing a dude.
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/protect/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/protect/check_completion()
	if(!target)			//If it's a free objective.
		return 1
	if(target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
			return 0
		return 1
	return 0

/datum/objective/protect/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/hijack
	explanation_text = "Hijack the shuttle to ensure no loyalist Nanotrasen crew escape alive and out of custody."
	martyr_compatible = 0 //Technically you won't get both anyway.

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat)
		return 0
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return 0
	if(issilicon(owner.current))
		return 0
	if(!SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return 0
	return SSshuttle.emergency.is_hijacked()


/datum/objective/hijackclone
	explanation_text = "Hijack the emergency shuttle by ensuring only you (or your copies) escape."
	martyr_compatible = 0

/datum/objective/hijackclone/check_completion()
	if(!owner.current)
		return FALSE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE

	var/in_shuttle = FALSE
	for(var/mob/living/player in GLOB.player_list) //Make sure nobody else is onboard
		if(SSshuttle.emergency.shuttle_areas[get_area(player)])
			if(player.mind && player.mind != owner)
				if(player.stat != DEAD)
					if(issilicon(player)) //Borgs are technically dead anyways
						continue
					if(isanimal(player)) //animals don't count
						continue
					if(isbrain(player)) //also technically dead
						continue
					var/location = get_turf(player.mind.current)
					if(istype(location, /turf/open/floor/plasteel/shuttle/red))
						continue
					if(istype(location, /turf/open/floor/mineral/plastitanium/brig))
						continue
					if(player.real_name != owner.current.real_name)
						return FALSE
					else
						in_shuttle = TRUE
	return in_shuttle

/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."
	martyr_compatible = 1

/datum/objective/block/check_completion()
	if(!issilicon(owner.current))
		return 0
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return 1

	for(var/mob/living/player in GLOB.player_list)
		if(issilicon(player))
			continue
		if(player.mind)
			if(player.stat != DEAD)
				if(get_area(player) in SSshuttle.emergency.shuttle_areas)
					return 0

	return 1


/datum/objective/purge
	explanation_text = "Ensure no mutant humanoid species are present aboard the escape shuttle."
	martyr_compatible = 1

/datum/objective/purge/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return 1

	for(var/mob/living/player in GLOB.player_list)
		if(get_area(player) in SSshuttle.emergency.shuttle_areas && player.mind && player.stat != DEAD && ishuman(player))
			var/mob/living/carbon/human/H = player
			if(H.dna.species.id != "human")
				return 0

	return 1


/datum/objective/robot_army
	explanation_text = "Have at least eight active cyborgs synced to you."
	martyr_compatible = 0

/datum/objective/robot_army/check_completion()
	if(!isAI(owner.current))
		return 0
	var/mob/living/silicon/ai/A = owner.current

	var/counter = 0

	for(var/mob/living/silicon/robot/R in A.connected_robots)
		if(R.stat != DEAD)
			counter++

	if(counter < 8)
		return 0
	return 1

/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return 0
	if(isbrain(owner.current))
		return 0
	if(!owner.current || owner.current.stat == DEAD)
		return 0
	if(SSticker.force_ending) //This one isn't their fault, so lets just assume good faith
		return 1
	if(SSticker.mode.station_was_nuked) //If they escaped the blast somehow, let them win
		return 1
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return 0
	var/turf/location = get_turf(owner.current)
	if(!location)
		return 0

	if(istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/brig)) // Fails traitors if they are in the shuttle brig -- Polymorph
		return 0

	if(location.onCentCom() || location.onSyndieBase())
		return 1

	return 0

/datum/objective/escape/escape_with_identity
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round
	var/target_missing_id

/datum/objective/escape/escape_with_identity/find_target()
	target = ..()
	update_explanation_text()

/datum/objective/escape/escape_with_identity/update_explanation_text()
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role]"
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(H && H.get_id_name() != target_real_name)
			target_missing_id = 1
		else
			explanation_text += " while wearing their identification card"
		explanation_text += "." //Proper punctuation is important!

	else
		explanation_text = "Free Objective."

/datum/objective/escape/escape_with_identity/check_completion()
	if(!target_real_name)
		return 1
	if(!ishuman(owner.current))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(..())
		if(H.dna.real_name == target_real_name)
			if(H.get_id_name()== target_real_name || target_missing_id)
				return 1
	return 0


/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return 0		//Brains no longer win survive objectives. --NEO
	if(!is_special_character(owner.current)) //This fails borg'd traitors
		return 0
	return 1


/datum/objective/martyr
	explanation_text = "Die a glorious death."

/datum/objective/martyr/check_completion()
	if(!owner.current) //Gibbed, etc.
		return 1
	if(owner.current && owner.current.stat == DEAD) //You're dead! Yay!
		return 1
	return 0


/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = 1

/datum/objective/nuclear/check_completion()
	if(SSticker && SSticker.mode && SSticker.mode.station_was_nuked)
		return 1
	return 0

GLOBAL_LIST_EMPTY(possible_items)
/datum/objective/steal
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).
	martyr_compatible = 0

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/New()
	..()
	if(!GLOB.possible_items.len)//Only need to fill the list when it's needed.
		for(var/I in subtypesof(/datum/objective_item/steal))
			new I

/datum/objective/steal/find_target()
	var/approved_targets = list()
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		if(is_unique_objective(possible_item.targetitem) && !(owner.current.mind.assigned_role in possible_item.excludefromjob))
			approved_targets += possible_item
	return set_target(safepick(approved_targets))

/datum/objective/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item

		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]"
		give_special_equipment(targetinfo.special_equipment)
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/steal/proc/select_target() //For admins setting objectives manually.
	var/list/possible_items_all = GLOB.possible_items+"custom"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if (!new_target) return

	if (new_target == "custom") //Can set custom items.
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target) return
		var/custom_name = initial(custom_target.name)
		custom_name = stripped_input("Enter target name:", "Objective target", custom_name)
		if (!custom_name) return
		steal_target = custom_target
		explanation_text = "Steal [custom_name]."

	else
		set_target(new_target)
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target)
		return 1
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

	for(var/obj/I in all_items) //Check for items
		if(istype(I, steal_target))
			if(!targetinfo) //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
				return 1
			else if(targetinfo.check_special_completion(I))//Returns 1 by default. Items with special checks will return 1 if the conditions are fulfilled.
				return 1

		if(targetinfo && I.type in targetinfo.altitems) //Ok, so you don't have the item. Do you have an alternative, at least?
			if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
				return 1
	return 0


GLOBAL_LIST_EMPTY(possible_items_special)
/datum/objective/steal/special //ninjas are so special they get their own subtype good for them

/datum/objective/steal/special/New()
	..()
	if(!GLOB.possible_items_special.len)
		for(var/I in subtypesof(/datum/objective_item/special) + subtypesof(/datum/objective_item/stack))
			new I

/datum/objective/steal/special/find_target()
	return set_target(pick(GLOB.possible_items_special))

/datum/objective/steal/exchange
	martyr_compatible = 0

/datum/objective/steal/exchange/proc/set_faction(faction,otheragent)
	target = otheragent
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_blue
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_red
	explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
	steal_target = targetinfo.targetitem


/datum/objective/steal/exchange/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Acquire [targetinfo.name] held by [target.name], the [target.assigned_role] and syndicate agent"
	else
		explanation_text = "Free Objective"


/datum/objective/steal/exchange/backstab

/datum/objective/steal/exchange/backstab/set_faction(faction)
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_red
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_blue
	explanation_text = "Do not give up or lose [targetinfo.name]."
	steal_target = targetinfo.targetitem


/datum/objective/download

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research level\s."
	return target_amount

/datum/objective/download/check_completion()//NINJACODE
	if(!ishuman(owner.current))
		return 0

	var/mob/living/carbon/human/H = owner.current
	if(!H || H.stat == DEAD)
		return 0

	if(!istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
		return 0

	var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
	if(!SN.s_initialized)
		return 0

	var/current_amount
	if(!SN.stored_research.len)
		return 0
	else
		for(var/datum/tech/current_data in SN.stored_research)
			if(current_data.level)
				current_amount += (current_data.level-1)
	if(current_amount<target_amount)
		return 0
	return 1



/datum/objective/capture

/datum/objective/capture/proc/gen_amount_goal()
		target_amount = rand(5,10)
		explanation_text = "Capture [target_amount] lifeform\s with an energy net. Live, rare specimens are worth more."
		return target_amount

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = locate() in GLOB.sortedAreas
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat == DEAD)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat == DEAD)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(istype(M, /mob/living/carbon/alien/humanoid/royal/queen))//Queens are worth three times as much as humans.
			if(M.stat == DEAD)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat == DEAD)
			captured_amount+=1
			continue
		captured_amount+=2
	if(captured_amount<target_amount)
		return 0
	return 1



/datum/objective/absorb

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	if (SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/dead/new_player/P in GLOB.player_list)
			if(P.client && P.ready == PLAYER_READY_TO_PLAY && P.mind!=owner)
				n_p ++
	else if (SSticker.IsRoundInProgress())
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(P.client && !(P.mind in SSticker.mode.changelings) && P.mind!=owner)
				n_p ++
	target_amount = min(target_amount, n_p)

	explanation_text = "Extract [target_amount] compatible genome\s."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.stored_profiles && (owner.changeling.absorbedcount >= target_amount))
		return 1
	else
		return 0



/datum/objective/destroy
	martyr_compatible = 1

/datum/objective/destroy/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/destroy/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1

/datum/objective/destroy/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free Objective"

/datum/objective/destroy/internal
	var/stolen = FALSE 		//Have we already eliminated this target?

/datum/objective/steal_five_of_type
	explanation_text = "Steal at least five items!"
	var/list/wanted_items = list(/obj/item)

/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_five_of_type/summon_guns
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)

/datum/objective/steal_five_of_type/summon_magic
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list(/obj/item/spellbook, /obj/item/gun/magic, /obj/item/clothing/suit/space/hardsuit/wizard, /obj/item/scrying, /obj/item/antag_spawner/contract, /obj/item/device/necromantic_stone)

/datum/objective/steal_five_of_type/check_completion()
	if(!isliving(owner.current))
		return 0
	var/stolen_count = 0
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/I in all_items) //Check for wanted items
		if(is_type_in_typecache(I, wanted_items))
			stolen_count++
	if(stolen_count >= 5)
		return 1
	else
		return 0
	return 0


////////////////////////////////
// Changeling team objectives //
////////////////////////////////

/datum/objective/changeling_team_objective //Abstract type
	martyr_compatible = 0	//Suicide is not teamwork!
	explanation_text = "Changeling Friendship!"
	var/min_lings = 3 //Minimum amount of lings for this team objective to be possible
	var/escape_objective_compatible = FALSE


//Impersonate department
//Picks as many people as it can from a department (Security,Engineer,Medical,Science)
//and tasks the lings with killing and replacing them
/datum/objective/changeling_team_objective/impersonate_department
	explanation_text = "Ensure X derpartment are killed, impersonated, and replaced by Changelings"
	var/command_staff_only = FALSE //if this is true, it picks command staff instead
	var/list/department_minds = list()
	var/list/department_real_names = list()
	var/department_string = ""


/datum/objective/changeling_team_objective/impersonate_department/proc/get_department_staff()
	department_minds = list()
	department_real_names = list()

	var/list/departments = list("Head of Security","Research Director","Chief Engineer","Chief Medical Officer")
	var/department_head = pick(departments)
	switch(department_head)
		if("Head of Security")
			department_string = "security"
		if("Research Director")
			department_string = "science"
		if("Chief Engineer")
			department_string = "engineering"
		if("Chief Medical Officer")
			department_string = "medical"

	var/ling_count = SSticker.mode.changelings

	for(var/datum/mind/M in SSticker.minds)
		if(M in SSticker.mode.changelings)
			continue
		if(department_head in get_department_heads(M.assigned_role))
			if(ling_count)
				ling_count--
				department_minds += M
				department_real_names += M.current.real_name
			else
				break

	if(!department_minds.len)
		log_game("[type] has failed to find department staff, and has removed itself. the round will continue normally")
		owner.objectives -= src
		qdel(src)
		return


/datum/objective/changeling_team_objective/impersonate_department/proc/get_heads()
	department_minds = list()
	department_real_names = list()

	//Needed heads is between min_lings and the maximum possible amount of command roles
	//So at the time of writing, rand(3,6), it's also capped by the amount of lings there are
	//Because you can't fill 6 head roles with 3 lings

	var/needed_heads = rand(min_lings,GLOB.command_positions.len)
	needed_heads = min(SSticker.mode.changelings.len,needed_heads)

	var/list/heads = SSticker.mode.get_living_heads()
	for(var/datum/mind/head in heads)
		if(head in SSticker.mode.changelings) //Looking at you HoP.
			continue
		if(needed_heads)
			department_minds += head
			department_real_names += head.current.real_name
			needed_heads--
		else
			break

	if(!department_minds.len)
		log_game("[type] has failed to find department heads, and has removed itself. the round will continue normally")
		owner.objectives -= src
		qdel(src)
		return


/datum/objective/changeling_team_objective/impersonate_department/New(var/text)
	..()
	if(command_staff_only)
		get_heads()
	else
		get_department_staff()

	update_explanation_text()


/datum/objective/changeling_team_objective/impersonate_department/update_explanation_text()
	..()
	if(!department_real_names.len || !department_minds.len)
		explanation_text = "Free Objective"
		return  //Something fucked up, give them a win

	if(command_staff_only)
		explanation_text = "Ensure changelings impersonate and escape as the following heads of staff: "
	else
		explanation_text = "Ensure changelings impersonate and escape as the following members of \the [department_string] department: "

	var/first = 1
	for(var/datum/mind/M in department_minds)
		var/string = "[M.name] the [M.assigned_role]"
		if(!first)
			string = ", [M.name] the [M.assigned_role]"
		else
			first--
		explanation_text += string

	if(command_staff_only)
		explanation_text += ", while the real heads are dead. This is a team objective."
	else
		explanation_text += ", while the real members are dead. This is a team objective."


/datum/objective/changeling_team_objective/impersonate_department/check_completion()
	if(!department_real_names.len || !department_minds.len)
		return 1 //Something fucked up, give them a win

	var/list/check_names = department_real_names.Copy()

	//Check each department member's mind to see if any of them made it to centcom alive, if they did it's an automatic fail
	for(var/datum/mind/M in department_minds)
		if(M in SSticker.mode.changelings) //Lings aren't picked for this, but let's be safe
			continue

		if(M.current)
			var/turf/mloc = get_turf(M.current)
			if(mloc.onCentCom() && (M.current.stat != DEAD))
				return 0 //A Non-ling living target got to centcom, fail

	//Check each staff member has been replaced, by cross referencing changeling minds, changeling current dna, the staff minds and their original DNA names
	var/success = 0
	changelings:
		for(var/datum/mind/changeling in SSticker.mode.changelings)
			if(success >= department_minds.len) //We did it, stop here!
				return 1
			if(ishuman(changeling.current))
				var/mob/living/carbon/human/H = changeling.current
				var/turf/cloc = get_turf(changeling.current)
				if(cloc && cloc.onCentCom() && (changeling.current.stat != DEAD)) //Living changeling on centcom....
					for(var/name in check_names) //Is he (disguised as) one of the staff?
						if(H.dna.real_name == name)
							check_names -= name //This staff member is accounted for, remove them, so the team don't succeed by escape as 7 of the same engineer
							success++ //A living changeling staff member made it to centcom
							continue changelings

	if(success >= department_minds.len)
		return 1
	return 0




//A subtype of impersonate_derpartment
//This subtype always picks as many command staff as it can (HoS,HoP,Cap,CE,CMO,RD)
//and tasks the lings with killing and replacing them
/datum/objective/changeling_team_objective/impersonate_department/impersonate_heads
	explanation_text = "Have X or more heads of staff escape on the shuttle disguised as heads, while the real heads are dead"
	command_staff_only = TRUE



