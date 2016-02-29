/*
	NPC VAR EXPLANATIONS (for modules and other things)

		doing = their current action, INTERACTING, TRAVEL or FIGHTING
		interest = how interested the NPC is in the situation, if they are idle, this drops
		timeout = this is internal
		TARGET = their current target
		LAST_TARGET = their last target
		nearby = a list of nearby mobs
		best_force = the highest force object, used for checking when to swap items
		retal = this is internal
		retal_target = this is internal
		update_hands = this is a bool (1/0) to determine if the NPC should update what is in his hands

		MYID = their ID card
		MYPDA = their PDA
		main_hand = what is in their "main" hand (chosen from left > right)
		TRAITS = the traits assigned to this npc
		mymjob = the job assigned to the npc

		robustness = the chance for the npc to hit something
		smartness = the inverse chance for an npc to do stupid things
		attitude = the chance for an npc to do rude or mean things
		slyness = the chance for an npc to do naughty things ie thieving

		functions = the list of procs that the npc will use for modules

		graytide = shitmin var to make them go psycho
*/

/mob/living/carbon/human/interactive
	name = "interactive station member"
	var/doing = 0
	var/interest = 100
	var/timeout = 0
	var/inactivity_period = 0
	var/TARGET = null
	var/LAST_TARGET = null
	var/list/nearby = list()
	var/best_force = 0
	var/retal = 0
	var/mob/retal_target = null
	var/update_hands = 0
	var/list/blacklistItems = list() // items we should be ignoring
	var/maxStepsTick = 3
	//Job and mind data
	var/obj/item/weapon/card/id/MYID
	var/obj/item/device/pda/MYPDA
	var/obj/item/main_hand
	var/obj/item/other_hand
	var/TRAITS = 0
	var/obj/item/weapon/card/id/Path_ID
	var/datum/job/myjob
	var/list/myPath = list()
	faction = list("station")
	//trait vars
	var/robustness = 50
	var/smartness = 50
	var/attitude = 50
	var/slyness = 50
	var/graytide = 0
	var/list/favoured_types = list() // allow a mob to favour a type, and hold onto them
	var/chattyness = CHANCE_TALK
	var/targetInterestShift = 10 // how much a good action should "reward" the npc
	//modules
	var/list/functions = list("nearbyscan","combat","doorscan","shitcurity","chatter","healpeople")

//botPool funcs
/mob/living/carbon/human/interactive/proc/takeDelegate(mob/living/carbon/human/interactive/from,doReset=TRUE)
	eye_color = "red"
	if(from == src)
		return FALSE
	TARGET = from.TARGET
	LAST_TARGET = from.LAST_TARGET
	retal = from.retal
	retal_target = from.retal_target
	doing = from.doing
	//
	timeout = 0
	inactivity_period = 0
	interest = 100
	//
	update_icons()
	if(doReset)
		from.TARGET = null
		from.LAST_TARGET = null
		from.retal = 0
		from.retal_target = null
		from.doing = 0
	return TRUE

//end pool funcs

/mob/living/carbon/human/interactive/proc/random()
	//this is here because this has no client/prefs/brain whatever.
	age = rand(AGE_MIN,AGE_MAX)
	//job handling
	var/list/jobs = SSjob.occupations.Copy()
	for(var/job in jobs)
		var/datum/job/J = job
		if(J.title == "Cyborg" || J.title == "AI" || J.title == "Chaplain" || J.title == "Mime")
			jobs -= J
	myjob = pick(jobs)
	job = myjob.title
	if(!graytide)
		myjob.equip(src)
	myjob.apply_fingerprints(src)

/mob/living/carbon/human/interactive/attacked_by(obj/item/I, mob/living/user, def_zone)
	..()
	retal = 1
	retal_target = user

/mob/living/carbon/human/interactive/bullet_act(var/obj/item/projectile/P)
	var/potentialAssault = locate(/mob/living) in view(2,P.starting)
	if(potentialAssault)
		retal = 1
		retal_target = potentialAssault
	..()

/mob/living/carbon/human/interactive/New()
	..()
	random()
	MYID = new(src)
	MYID.name = "[src.real_name]'s ID Card ([myjob.title])"
	MYID.assignment = "[myjob.title]"
	MYID.registered_name = src.real_name
	MYID.access = myjob.access
	equip_to_slot_or_del(MYID, slot_wear_id)
	MYPDA = new(src)
	MYPDA.owner = real_name
	MYPDA.ownjob = "Crew"
	MYPDA.name = "PDA-[real_name] ([myjob.title])"
	equip_to_slot_or_del(MYPDA, slot_belt)
	zone_selected = "chest"
	//arms
	if(prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/2))
		var/obj/item/organ/limb/r_arm/R = locate(/obj/item/organ/limb/r_arm) in organs
		qdel(R)
		organs += new /obj/item/organ/limb/robot/r_arm
	else
		var/obj/item/organ/limb/l_arm/L = locate(/obj/item/organ/limb/l_arm) in organs
		qdel(L)
		organs += new /obj/item/organ/limb/robot/l_arm
	//legs
	if(prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/2))
		var/obj/item/organ/limb/r_leg/R = locate(/obj/item/organ/limb/r_leg) in organs
		qdel(R)
		organs += new /obj/item/organ/limb/robot/r_leg
	else
		var/obj/item/organ/limb/l_leg/L = locate(/obj/item/organ/limb/l_leg) in organs
		qdel(L)
		organs += new /obj/item/organ/limb/robot/l_leg
	//chest and head
	if(prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/2))
		var/obj/item/organ/limb/chest/R = locate(/obj/item/organ/limb/chest) in organs
		qdel(R)
		organs += new /obj/item/organ/limb/robot/chest
	else
		var/obj/item/organ/limb/head/L = locate(/obj/item/organ/limb/head) in organs
		qdel(L)
		organs += new /obj/item/organ/limb/robot/head
	for(var/LIMB in organs)
		var/obj/item/organ/limb/L = LIMB
		L.owner = src
	update_icons()
	update_damage_overlays(0)
	update_augments()

	hand = 0

	Path_ID = new /obj/item/weapon/card/id(src)

	var/datum/job/captain/C = new/datum/job/captain
	Path_ID.access = C.get_access()

	//job specific favours
	switch(myjob.title)
		if("Assistant")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon)
		if("Captain","Head of Personnel")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/captain,/obj/item/weapon/disk/nuclear)
		if("Bartender","Chef")
			favoured_types = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/kitchen)
		if("Station Engineer","Chief Engineer","Atmospheric Technician")
			favoured_types = list(/obj/item/stack, /obj/item/weapon, /obj/item/clothing)
		if("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Geneticist")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/storage/firstaid, /obj/item/stack/medical, /obj/item/weapon/reagent_containers/syringe)
		if("Research Director","Scientist","Roboticist")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/stack, /obj/item/weapon/reagent_containers)
		if("Head of Security","Warden","Security Officer","Detective")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon, /obj/item/weapon/restraints)
		if("Janitor")
			favoured_types = list(/obj/item/weapon/mop, /obj/item/weapon/reagent_containers/glass/bucket, /obj/item/weapon/reagent_containers/spray/cleaner, /obj/effect/decal/cleanable)
			functions += "dojanitor"
		else
			favoured_types = list(/obj/item/clothing)


	if(TRAITS & TRAIT_ROBUST)
		robustness = 75
	else if(TRAITS & TRAIT_UNROBUST)
		robustness = 25

	//modifiers are prob chances, lower = smarter
	if(TRAITS & TRAIT_SMART)
		smartness = 25
	else if(TRAITS & TRAIT_DUMB)
		disabilities |= CLUMSY
		smartness = 75

	if(TRAITS & TRAIT_MEAN)
		attitude = 75
	else if(TRAITS & TRAIT_FRIENDLY)
		attitude = 1

	if(TRAITS & TRAIT_THIEVING)
		slyness = 75

	SSnpc.insertBot(src)


/mob/living/carbon/human/interactive/attack_hand(mob/living/carbon/human/M)
	..()
	if (health > 0)
		if(M.a_intent == "help")
			chatter()
		if(M.a_intent == "harm")
			retal = 1
			retal_target = M

//THESE EXIST FOR DEBUGGING OF THE DOING/INTEREST SYSTEM EASILY
/mob/living/carbon/human/interactive/proc/doing2string(doin)
	var/toReturn = ""
	if(!doin)
		toReturn = "not doing anything"
	if(doin & INTERACTING)
		toReturn += "interacting with something, "
	if(doin & FIGHTING)
		toReturn += "engaging in combat, "
	if(doin & TRAVEL)
		toReturn += "and going somewhere"
	return toReturn

/mob/living/carbon/human/interactive/proc/interest2string(inter)
	var/toReturn = "Flatlined"
	if(inter >= 0 && inter <= 25)
		toReturn = "Very Bored"
	if(inter >= 26 && inter <= 50)
		toReturn = "Bored"
	if(inter >= 51 && inter <= 75)
		toReturn = "Content"
	if(inter >= 76)
		toReturn = "Excited"
	return toReturn
//END DEBUG

/mob/living/carbon/human/interactive/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!canmove)
		return 1
	if(health <= 0 && checkDead)
		return 1
	if(restrained())
		return 1
	if(paralysis)
		return 1
	if(stunned)
		return 1
	if(stat)
		return 1
	if(inactivity_period > 0)
		return 1
	return 0

/mob/living/carbon/human/interactive/proc/enforce_hands()
	if(main_hand)
		if(main_hand.loc != src)
			main_hand = null
	if(other_hand)
		if(other_hand.loc != src)
			other_hand = null
	if(hand)
		if(!l_hand)
			main_hand = null
			if(r_hand)
				swap_hands()
	else
		if(!r_hand)
			main_hand = null
			if(l_hand)
				swap_hands()

/mob/living/carbon/human/interactive/proc/swap_hands()
	hand = !hand
	var/obj/item/T = other_hand
	main_hand = other_hand
	other_hand = T

/mob/living/carbon/human/interactive/proc/take_to_slot(obj/item/G, var/hands=0)
	var/list/slots = list ("left pocket" = slot_l_store,"right pocket" = slot_r_store,"left hand" = slot_l_hand,"right hand" = slot_r_hand)
	if(hands)
		slots = list ("left hand" = slot_l_hand,"right hand" = slot_r_hand)
	G.loc = src
	if(G.force && G.force > best_force)
		best_force = G.force
	equip_in_one_of_slots(G, slots)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/insert_into_backpack()
	var/list/slots = list ("left pocket" = slot_l_store,"right pocket" = slot_r_store,"left hand" = slot_l_hand,"right hand" = slot_r_hand)
	var/obj/item/I = get_item_by_slot(pick(slots))
	var/obj/item/weapon/storage/BP = get_item_by_slot(slot_back)
	if(back && BP && I)
		if(BP.can_be_inserted(I,0))
			BP.handle_item_insertion(I,0)
	else
		unEquip(I,TRUE)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/targetRange(towhere)
	return get_dist(get_turf(towhere), get_turf(src))

/mob/living/carbon/human/interactive/Life()
	..()
	if(IsDeadOrIncap())
		walk(src,0)
		return
	if(a_intent != "disarm")
		a_intent = "disarm"
	//---------------------------
	//---- interest flow control
	if(interest < 0 || inactivity_period < 0)
		if(interest < 0)
			interest = 0
		if(inactivity_period < 0)
			inactivity_period = 0
	if(interest > 100)
		interest = 100
	//---------------------------
	//VIEW FUNCTIONS

	if(!l_hand || !r_hand)
		update_hands = 1

	if(update_hands)
		if(l_hand || r_hand)
			if(l_hand)
				hand = 1
				main_hand = l_hand
				if(r_hand)
					other_hand = r_hand
			else if(r_hand)
				hand = 0
				main_hand = r_hand
				if(l_hand) //this technically shouldnt occur, but its a redundancy
					other_hand = l_hand
			update_icons()
		update_hands = 0

	if(grabbed_by.len > 0)
		for(var/obj/item/weapon/grab/G in grabbed_by)
			if(Adjacent(G))
				a_intent = "disarm"
				G.assailant.attack_hand(src)
				inactivity_period = 10

	//proc functions
	for(var/Proc in functions)
		if(!IsDeadOrIncap())
			callfunction(Proc)


	//target interaction stays hardcoded

	if(TARGET) // don't use blacklisted items
		if(TARGET in blacklistItems)
			TARGET = null

	if((TARGET && (TARGET in view(1))))
		if((TARGET in view(1,src)))//this is a bit redundant but it saves two if blocks
			doing |= INTERACTING
			//--------DOORS
			if(istype(TARGET, /obj/machinery/door))
				var/obj/machinery/door/D = TARGET
				if(D.check_access(MYID) && !istype(D,/obj/machinery/door/poddoor))
					D.open()
					sleep(15)
					var/turf/T = get_step(get_step(D.loc,dir),dir) //recursion yo
					tryWalk(T)
			//THIEVING SKILLS
			if(prob(slyness))
				if(!TARGET in blacklistItems)
					//---------TOOLS
					if(istype(TARGET, /obj/item/weapon))
						var/obj/item/weapon/W = TARGET
						if(W.force >= best_force || prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/2))
							if(!l_hand || !r_hand)
								take_to_slot(W)
							else
								insert_into_backpack()
					//---------FASHION
					if(istype(TARGET,/obj/item/clothing))
						var/obj/item/clothing/C = TARGET
						drop_item()
						spawn(5)
							take_to_slot(C,1)
							if(!equip_to_appropriate_slot(C))
								var/obj/item/I = get_item_by_slot(C)
								unEquip(I)
								spawn(5)
									equip_to_appropriate_slot(C)
						update_hands = 1
						if(MYPDA in src.loc || MYID in src.loc)
							if(MYPDA in src.loc)
								equip_to_appropriate_slot(MYPDA)
							if(MYID in src.loc)
								equip_to_appropriate_slot(MYID)
			//THIEVING SKILLS END
			//-------------TOUCH ME
			if(istype(TARGET,/obj/structure))
				var/obj/structure/STR = TARGET
				if(main_hand)
					var/obj/item/weapon/W = main_hand
					STR.attackby(W, src)
				else
					STR.attack_hand(src)
		interest += targetInterestShift
		doing = doing & ~INTERACTING
		timeout = 0
		TARGET = null
	else
		tryWalk(TARGET)
		timeout++

	if(doing == 0)
		interest--
	else
		interest++

	if(inactivity_period > 0)
		inactivity_period--

	if(interest <= 0 || timeout >= 10) // facilitate boredom functions
		TARGET = null
		doing = 0
		timeout = 0
		myPath = list()

	//this is boring, lets move
	if(!doing && !IsDeadOrIncap() && !TARGET)
		doing |= TRAVEL
		if(nearby.len > 4)
			//i'm crowded, time to leave
			TARGET = pick(target_filter(urange(MAX_RANGE_FIND,src,1)))
		else
			var/choice = rand(1,50)
			switch(choice)
				if(1 to 10)
					//chance to chase an item
					TARGET = locate(/obj/item) in favouredObjIn(oview(MIN_RANGE_FIND,src))
				if(11 to 21)
					TARGET = safepick(get_area_turfs(job2area(myjob)))
				if(22 to 41)
					TARGET = pick(target_filter(favouredObjIn(urange(MAX_RANGE_FIND,src,1))))
				if(42 to 50)
					TARGET = pick(target_filter(oview(MIN_RANGE_FIND,src)))
		tryWalk(TARGET)
	LAST_TARGET = TARGET

/mob/living/carbon/human/interactive/proc/favouredObjIn(var/list/inList)
	var/list/outList = list()
	for(var/i in inList)
		for(var/path in favoured_types)
			if(ispath(i,path))
				outList += i
	if(outList.len <= 0)
		outList = inList
	return outList

/mob/living/carbon/human/interactive/proc/callfunction(Proc)
	set waitfor = 0
	call(src,Proc)(src)

/mob/living/carbon/human/interactive/proc/tryWalk(turf/TARGET)
	if(!IsDeadOrIncap())
		if(!walk2derpless(TARGET))
			timeout++
	else
		timeout++

/mob/living/carbon/human/interactive/proc/getGoodPath(target,var/maxtries=512)
	set background = 1
	var/turf/end = get_turf(target)

	var/turf/current = get_turf(src)

	var/list/path = list()
	var/tries = 0
	while(current != end && tries < maxtries)
		var/turf/shortest = current
		for(var/turf/T in view(current,1))
			var/foundDense = 0
			for(var/atom/A in T)
				if(A.density)
					foundDense = 1
			if(T.density == 0 && !foundDense)
				if(get_dist(T, target) < get_dist(shortest,target))
					shortest = T
				else
					tries++
			else
				tries++
		current = shortest
		path += shortest
	return path

/mob/living/carbon/human/interactive/proc/walk2derpless(target)
	set background = 1
	if(!target)
		return 0

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1, id=Path_ID)

	if(myPath)
		if(myPath.len > 0)
			doing = doing & ~TRAVEL
			for(var/i = 0; i < maxStepsTick; ++i)
				if(myPath.len >= 1)
					walk_to(src,myPath[1],0,5)
					myPath -= myPath[1]
			return 1
	return 0

/mob/living/carbon/human/interactive/proc/job2area(target)
	var/datum/job/T = target
	if(T.title == "Assistant")
		return /area/hallway/primary
	if(T.title == "Captain" || T.title == "Head of Personnel")
		return /area/bridge
	if(T.title == "Bartender" || T.title == "Chef")
		return /area/crew_quarters
	if(T.title == "Station Engineer" || T.title == "Chief Engineer" || T.title == "Atmospheric Technician")
		return /area/engine
	if(T.title == "Chief Medical Officer" || T.title == "Medical Doctor" || T.title == "Chemist" || T.title == "Virologist" || T.title == "Geneticist")
		return /area/medical
	if(T.title == "Research Director" || T.title == "Scientist" || T.title == "Roboticist")
		return /area/toxins
	if(T.title == "Head of Security" || T.title == "Warden" || T.title == "Security Officer" || T.title == "Detective")
		return /area/security
	else
		return pick(/area/hallway,/area/crew_quarters)

/mob/living/carbon/human/interactive/proc/target_filter(target)
	var/list/filtered_targets = list(/area, /turf, /obj/machinery/door, /atom/movable/light, /obj/structure/cable, /obj/machinery/atmospherics)
	var/list/L = target
	for(var/atom/A in target) // added a bunch of "junk" that clogs up the general find procs
		if(is_type_in_list(A,filtered_targets))
			L -= A
	return L

///BUILT IN MODULES
/mob/living/carbon/human/interactive/proc/chatter(obj)
	var/verbs_use = pick_list("npc_chatter.txt","verbs_use")
	var/verbs_touch = pick_list("npc_chatter.txt","verbs_touch")
	var/verbs_move = pick_list("npc_chatter.txt","verbs_move")
	var/nouns_insult = pick_list("npc_chatter.txt","nouns_insult")
	var/nouns_generic = pick_list("npc_chatter.txt","nouns_generic")
	var/nouns_objects = pick_list("npc_chatter.txt","nouns_objects")
	var/nouns_body = pick_list("npc_chatter.txt","nouns_body")
	var/adjective_insult = pick_list("npc_chatter.txt","adjective_insult")
	var/adjective_objects = pick_list("npc_chatter.txt","adjective_objects")
	var/adjective_generic = pick_list("npc_chatter.txt","adjective_generic")
	var/curse_words = pick_list("npc_chatter.txt","curse_words")

	if(doing & INTERACTING)
		if(prob(chattyness))
			var/chat = pick("This [nouns_objects] is a little [adjective_objects].",
			"Well [verbs_use] my [nouns_body], this [nouns_insult] is pretty [adjective_insult].",
			"[capitalize(curse_words)], what am I meant to do with this [adjective_insult] [nouns_objects].")
			src.say(chat)
	if(doing & TRAVEL)
		if(prob(chattyness))
			var/chat = pick("Oh [curse_words], [verbs_move]!",
			"Time to get my [adjective_generic] [adjective_insult] [nouns_body] elsewhere.",
			"I wonder if there is anything to [verbs_use] and [verbs_touch] somewhere else..")
			src.say(chat)
	if(doing & FIGHTING)
		if(prob(chattyness))
			var/chat = pick("I'm going to [verbs_use] you, you [adjective_insult] [nouns_insult]!",
			"Rend and [verbs_touch], Rend and [verbs_use]!",
			"You [nouns_insult], I'm going to [verbs_use] you right in the [nouns_body]. JUST YOU WAIT!")
			src.say(chat)
	if(prob(chattyness/2))
		var/what = pick(1,2,3,4,5)
		switch(what)
			if(1)
				src.say("Well [curse_words], this is a [adjective_generic] situation.")
			if(2)
				src.say("Oh [curse_words], that [nouns_insult] was one hell of an [adjective_insult] [nouns_body].")
			if(3)
				src.say("I want to [verbs_use] that [nouns_insult] when I find them.")
			if(4)
				src.say("[pick("Innocent","Guilty","Traitorous","Honk")] until proven [adjective_generic]!")
			if(5)
				var/toSay = ""
				for(var/i = 0; i < 5; i++)
					curse_words = pick_list("npc_chatter.txt","curse_words")
					toSay += "[curse_words] "
				src.say("Hey [nouns_generic], why dont you go [toSay], you [nouns_insult]!")

/mob/living/carbon/human/interactive/proc/shitcurity(obj)
	if(retal && TARGET)
		for(var/obj/item/I in src.contents)
			if(istype(I,/obj/item/weapon/restraints))
				take_to_slot(I)
				I.attack(TARGET,src)
				sleep(25)

/mob/living/carbon/human/interactive/proc/healpeople(obj)
	var/shouldTryHeal = 0
	var/obj/item/stack/medical/M

	var/list/allContents = list()

	for(var/atom/A in contents)
		allContents += A
		if(A.contents.len > 0)
			for(var/atom/B in A)
				allContents += B

	for(var/A in allContents)
		if(istype(A,/obj/item/stack/medical))
			shouldTryHeal = 1
			M = A
	if(shouldTryHeal)
		for(var/mob/living/carbon/C in nearby)
			if(istype(C,/mob/living/carbon)) //I haven't the foggiest clue why this is turning up non-carbons but sure here whatever
				if(C.health <= 75)
					if(get_dist(src,C) <= 2)
						src.say("Wait, [C], let me heal you!")
						M.attack(C,src)
						sleep(25)
					else
						tryWalk(get_turf(C))

/mob/living/carbon/human/interactive/proc/dojanitor(obj)
	if(istype(main_hand,/obj/item/weapon/mop))
		var/obj/item/weapon/mop/M = main_hand
		if(M)
			if(M.reagents.total_volume <= 5)
				M.reagents.add_reagent("water", 25) // bluespess water delivery for AI
			if(!istype(TARGET,/obj/effect/decal/cleanable))
				TARGET = locate(/obj/effect/decal/cleanable) in urange(MAX_RANGE_FIND,src,1)
			if(targetRange(TARGET) <= 2)
				M.afterattack(TARGET,src)
				sleep(25)
			else
				tryWalk(TARGET)

/mob/living/carbon/human/interactive/proc/combat(obj)
	set background = 1
	enforce_hands()
	if(canmove)
		if(prob(attitude) && (graytide || (TRAITS & TRAIT_MEAN)) || retal)
			interest = interest + 10
			a_intent = "harm"
			zone_selected = pick("chest","r_leg","l_leg","r_arm","l_arm","head")
			doing |= FIGHTING
			if(retal)
				TARGET = retal_target
			else
				var/mob/living/M = locate(/mob/living) in oview(7,src)
				if(istype(M,/mob/living/carbon/human/interactive/greytide))
					return
				if(M != src)
					TARGET = M
				if(!M)
					doing = doing & ~FIGHTING

	//no infighting
	if(retal)
		if(retal_target)
			if(retal_target.faction == src.faction)
				if(prob(FUZZY_CHANCE_HIGH+FUZZY_CHANCE_LOW))	//high chance to forgive
					retal = 0
					retal_target = null
					TARGET = null
					doing = 0

	//ensure we're using the best object possible

	var/obj/item/weapon/best
	var/foundFav = 0
	for(var/test in src.contents)
		for(var/a in favoured_types)
			if(ispath(test,a) && !(doing & FIGHTING)) // if we're not in combat and we find our favourite things, use them (for people like janitor and doctors)
				best = test
				foundFav = 1
				return
		if(!foundFav)
			if(istype(test,/obj/item/weapon))
				var/obj/item/weapon/R = test
				if(R.force > 2) // make sure we don't equip any non-weaponlike items, ie bags and stuff
					if(!best)
						best = R
					else
						if(best.force < R.force)
							best = R
					if(istype(R,/obj/item/weapon/gun))
						var/obj/item/weapon/gun/G = R
						if(G.can_shoot())
							best = R
							break // gun with ammo? screw the rest
	if(best)
		take_to_slot(best,1)

	if((TARGET && (doing & FIGHTING)) || graytide) // this is a redundancy check
		var/mob/living/M = TARGET
		if(istype(M,/mob/living))
			if(M.health > 1)
				if(main_hand)
					if(main_hand.force != 0)
						if(istype(main_hand,/obj/item/weapon/gun))
							var/obj/item/weapon/gun/G = main_hand
							if(G.can_trigger_gun(src))
								if(istype(main_hand,/obj/item/weapon/gun/projectile))
									var/obj/item/weapon/gun/projectile/P = main_hand
									if(!P.chambered)
										P.chamber_round()
										P.update_icon()
									else if(P.get_ammo(1) == 0)
										P.update_icon()
										blacklistItems += P
										P.loc = get_turf(src) // drop item works inconsistently
										enforce_hands()
										update_icons()
									else
										P.afterattack(TARGET, src)
								else if(istype(main_hand,/obj/item/weapon/gun/energy))
									var/obj/item/weapon/gun/energy/P = main_hand
									if(P.power_supply.charge <= 10) // can shoot seems to bug out for tasers, using this hacky method instead
										P.update_icon()
										blacklistItems += P
										P.loc = get_turf(src) // likewise
										enforce_hands()
										update_icons()
									else
										P.afterattack(TARGET, src)
								else
									if(get_dist(src,TARGET) > 2)
										if(!walk2derpless(TARGET))
											timeout++
									else
										var/obj/item/weapon/W = main_hand
										W.attack(TARGET,src)
							else
								G.loc = get_turf(src) // drop item works inconsistently
								enforce_hands()
								update_icons()
				else
					if(targetRange(TARGET) > (istype(main_hand,/obj/item/weapon/gun) ? 6 : 2))
						tryWalk(TARGET)
					else
						if(Adjacent(TARGET))
							M.attack_hand(src)
			timeout++
		else if(timeout >= 10 || !(targetRange(M) > 14))
			doing = doing & ~FIGHTING
			timeout = 0
			TARGET = null
			retal = 0
			retal_target = null
		else
			timeout++

/mob/living/carbon/human/interactive/proc/doorscan(obj)
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		if(T)
			for(var/obj/machinery/door/D in T.contents)
				if(D.check_access(MYID) && !istype(D,/obj/machinery/door/poddoor) && D.density)
					spawn(0)
						D.open()
						sleep(5)
						walk_to(src,T,0,5)

/mob/living/carbon/human/interactive/proc/nearbyscan(obj)
	nearby = list()
	for(var/mob/living/M in view(4,src))
		if(M != src)
			nearby += M

//END OF MODULES
/mob/living/carbon/human/interactive/angry/New()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	faction = list("bot_angry")
	..()

/mob/living/carbon/human/interactive/friendly/New()
	TRAITS |= TRAIT_FRIENDLY
	TRAITS |= TRAIT_UNROBUST
	faction = list("bot_friendly")
	..()

/mob/living/carbon/human/interactive/greytide/New()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	TRAITS |= TRAIT_THIEVING
	TRAITS |= TRAIT_DUMB
	faction = list("bot_grey")
	graytide = 1
	..()
