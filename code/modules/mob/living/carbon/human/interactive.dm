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
#define NPC_SPEAK_FILE "npc_chatter.json"
/mob/living/carbon/human/interactive
	name = "interactive station member"
	var/doing = 0
	var/interest = 10
	var/maxInterest = 10
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
	var/maxStepsTick = 6 // step as many times as we can per frame
	//Job and mind data
	var/obj/item/weapon/card/id/MYID
	var/obj/item/weapon/card/id/RPID // the "real" idea they use
	var/obj/item/device/pda/MYPDA
	var/obj/item/main_hand
	var/obj/item/other_hand
	var/TRAITS = 0
	var/obj/item/weapon/card/id/Path_ID
	var/datum/job/myjob
	var/list/myPath = list()
	faction = list("synth")
	//trait vars
	var/robustness = 50
	var/smartness = 50
	var/attitude = 50
	var/slyness = 50
	var/graytide = 0
	var/list/favoured_types = list() // allow a mob to favour a type, and hold onto them
	var/chattyness = CHANCE_TALK
	var/targetInterestShift = 5 // how much a good action should "reward" the npc
	//modules
	var/list/functions = list("nearbyscan","combat","shitcurity","chatter")
	var/restrictedJob = 0
	var/forceProcess = 0
	var/lastProc = 0
	var/walkdebug = 0	//causes sparks in our path target. used for debugging
	var/debugexamine = 0 //If we show debug info in our examine
	var/showexaminetext = 1	//If we show our telltale examine text

	var/list/knownStrings = list()

	//snpc traitor variables

	var/isTraitor = 0
	var/traitorTarget
	var/traitorScale = 0 // our ability as a traitor
	var/traitorType = 0

	var/voice_saved = FALSE

/// SNPC voice handling

/mob/living/carbon/human/interactive/proc/loadVoice()
	var/savefile/S = new /savefile("data/npc_saves/snpc.sav")
	S["knownStrings"] >> knownStrings

	if(isnull(knownStrings))
		knownStrings = list()

/mob/living/carbon/human/interactive/proc/saveVoice()
	if(voice_saved)
		return
	var/savefile/S = new /savefile("data/npc_saves/snpc.sav")
	S["knownStrings"] << knownStrings

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
	interest = maxInterest
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
	myjob = new/datum/job/assistant()
	job = myjob.title
	myjob.equip(src)

/mob/living/carbon/human/interactive/attacked_by(obj/item/I, mob/living/user, def_zone)
	. = ..()
	retal = 1
	retal_target = user

/mob/living/carbon/human/interactive/bullet_act(obj/item/projectile/P, def_zone)
	var/potentialAssault = locate(/mob/living) in view(2,P.starting)
	if(potentialAssault)
		retal = 1
		retal_target = potentialAssault
	..()

/client/proc/resetSNPC(var/mob/A in SSnpcpool.processing)
	set name = "Reset SNPC"
	set desc = "Reset the SNPC"
	set category = "Debug"

	if(!holder)
		return

	if(A)
		if(!istype(A,/mob/living/carbon/human/interactive))
			return
		var/mob/living/carbon/human/interactive/T = A
		if(T)
			T.timeout = 100
			T.retal = 0
			T.doing = 0

/client/proc/customiseSNPC(var/mob/A in SSnpcpool.processing)
	set name = "Customize SNPC"
	set desc = "Customise the SNPC"
	set category = "Debug"

	if(!holder)
		return

	if(A)
		if(!istype(A,/mob/living/carbon/human/interactive))
			return
		var/mob/living/carbon/human/interactive/T = A

		var/choice = input("Customization Choices") as null|anything in list("Service NPC","Security NPC","Random","Custom")
		if(choice)
			if(choice == "Service NPC" || choice == "Security NPC")
				var/job = choice == "Service NPC" ? pick("Bartender","Cook","Botanist","Janitor") : pick("Warden","Detective","Security Officer")
				for(var/j in SSjob.occupations)
					var/datum/job/J = j
					if(J.title == job)
						T.myjob = J
						T.job = T.myjob.title
						for(var/obj/item/W in T)
							qdel(W)
						T.myjob.equip(T)
						T.doSetup()
						break
			if(choice == "Random")
				T.myjob = pick(SSjob.occupations)
				T.job = T.myjob.title
				for(var/obj/item/W in T)
					qdel(W)
				T.myjob.equip(T)
				T.doSetup()
				if(prob(25))
					var/list/validchoices = list()
					for(var/mob/living/carbon/human/M in GLOB.mob_list)
						validchoices += M
					var/mob/living/carbon/human/chosen = pick(validchoices)
					var/datum/dna/toDoppel = chosen.dna
					T.real_name = toDoppel.real_name
					toDoppel.transfer_identity(T, transfer_SE=1)
					T.updateappearance(mutcolor_update=1)
					T.domutcheck()
				if(prob(25))
					var/cType = pick(list(SNPC_BRUTE,SNPC_STEALTH,SNPC_MARTYR,SNPC_PSYCHO))
					T.makeTraitor(cType)
				T.loc = pick(get_area_turfs(T.job2area(T.myjob)))
			if(choice == "Custom")
				var/cjob = input("Choose Job") as null|anything in SSjob.occupations
				if(cjob)
					T.myjob = cjob
					T.job = T.myjob.title
					for(var/obj/item/W in T)
						qdel(W)
					T.myjob.equip(T)
					T.doSetup()
				var/shouldDoppel = input("Do you want the SNPC to disguise themself as a crewmember?") as null|anything in list("Yes","No")
				if(shouldDoppel)
					if(shouldDoppel == "Yes")
						var/list/validchoices = list()
						for(var/mob/living/carbon/human/M in GLOB.mob_list)
							validchoices += M

						var/mob/living/carbon/human/chosen = input("Which crewmember?") as null|anything in validchoices

						if(chosen)
							var/datum/dna/toDoppel = chosen.dna

							T.real_name = toDoppel.real_name
							toDoppel.transfer_identity(T, transfer_SE=1)
							T.updateappearance(mutcolor_update=1)
							T.domutcheck()
				var/doTrait = input("Do you want the SNPC to be a traitor?") as null|anything in list("Yes","No")
				if(doTrait)
					if(doTrait == "Yes")
						var/list/tType = list("Brute" = SNPC_BRUTE, "Stealth" = SNPC_STEALTH, "Martyr" = SNPC_MARTYR, "Psycho" = SNPC_PSYCHO)
						var/cType = input("Choose the traitor personality.") as null|anything in tType
						if(cType)
							var/value = tType[cType]
							T.makeTraitor(value)
				var/doTele = input("Place the SNPC in their department?") as null|anything in list("Yes","No")
				if(doTele)
					if(doTele == "Yes")
						T.loc = pick(get_area_turfs(T.job2area(T.myjob)))

/mob/living/carbon/human/interactive/proc/doSetup()
	Path_ID = new /obj/item/weapon/card/id(src)

	var/datum/job/captain/C = new/datum/job/captain
	Path_ID.access = C.get_access()

	MYID = new(src)
	MYID.name = "[src.real_name]'s ID Card ([myjob.title])"
	MYID.assignment = "[myjob.title]"
	MYID.registered_name = src.real_name
	MYID.access = Path_ID.access // Automatons have strange powers... strange indeed

	RPID = new(src)
	RPID.name = "[src.real_name]'s ID Card ([myjob.title])"
	RPID.assignment = "[myjob.title]"
	RPID.registered_name = src.real_name
	RPID.access = myjob.get_access()

	equip_to_slot_or_del(MYID, slot_wear_id)
	MYPDA = new(src)
	MYPDA.owner = real_name
	MYPDA.ownjob = "Crew"
	MYPDA.name = "PDA-[real_name] ([myjob.title])"
	equip_to_slot_or_del(MYPDA, slot_belt)
	zone_selected = "chest"
	//arms
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/4))
			BP.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
	update_icons()
	update_damage_overlays()
	functions = list("nearbyscan","combat","shitcurity","chatter") // stop customize adding multiple copies of a function
	//job specific favours
	switch(myjob.title)
		if("Assistant")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon)
		if("Captain","Head of Personnel")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/captain,/obj/item/weapon/disk/nuclear)
		if("Cook")
			favoured_types = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/kitchen)
			functions += "souschef"
			restrictedJob = 1
		if("Bartender")
			favoured_types = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/kitchen)
			functions += "bartend"
			restrictedJob = 1
		if("Station Engineer","Chief Engineer","Atmospheric Technician")
			favoured_types = list(/obj/item/stack, /obj/item/weapon, /obj/item/clothing)
		if("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Geneticist")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/storage/firstaid, /obj/item/stack/medical, /obj/item/weapon/reagent_containers/syringe)
			functions += "healpeople"
		if("Research Director","Scientist","Roboticist")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/stack, /obj/item/weapon/reagent_containers)
		if("Head of Security","Warden","Security Officer","Detective")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon, /obj/item/weapon/restraints)
		if("Janitor")
			favoured_types = list(/obj/item/weapon/mop, /obj/item/weapon/reagent_containers/glass/bucket, /obj/item/weapon/reagent_containers/spray/cleaner, /obj/effect/decal/cleanable)
			functions += "dojanitor"
		if("Clown")
			favoured_types = list(/obj/item/weapon/soap, /obj/item/weapon/reagent_containers/food/snacks/grown/banana,/obj/item/weapon/grown/bananapeel)
			functions += "clowning"
		if("Mime")
			functions -= "chatter"
		if("Botanist")
			favoured_types = list(/obj/machinery/hydroponics,  /obj/item/weapon/reagent_containers, /obj/item/weapon)
			functions += "botany"
			restrictedJob = 1
		else
			favoured_types = list(/obj/item/clothing)


	if(TRAITS & TRAIT_ROBUST)
		robustness = 75
	else if(TRAITS & TRAIT_UNROBUST)
		robustness = 25

	//modifiers are prob chances, lower = smarter
	if(TRAITS & TRAIT_SMART)
		smartness = 75
	else if(TRAITS & TRAIT_DUMB)
		disabilities |= CLUMSY
		smartness = 25

	if(TRAITS & TRAIT_MEAN)
		attitude = 75
	else if(TRAITS & TRAIT_FRIENDLY)
		attitude = 1

	if(TRAITS & TRAIT_THIEVING)
		slyness = 75


/mob/living/carbon/human/interactive/proc/makeTraitor(var/inPers)
	isTraitor = 1
	traitorScale = (slyness + smartness) + rand(-10,10)
	traitorType = inPers

	switch(traitorType)
		if(SNPC_BRUTE) // SMASH KILL RAAARGH
			traitorTarget = pick(GLOB.mob_list)
		if(SNPC_STEALTH) // Shhh we is sneekies
			var/A = pick(typesof(/datum/objective_item/steal) - /datum/objective_item/steal)
			var/datum/objective_item/steal/S = new A
			traitorTarget = locate(S.targetitem) in world
		if(SNPC_MARTYR) // MY LIFE FOR SPESZUL
			var/targetType = pick(/obj/machinery/gravity_generator/main/station,/obj/machinery/power/smes/engineering,/obj/machinery/telecomms/hub)
			traitorTarget = locate(targetType) in GLOB.machines
		if(SNPC_PSYCHO) // YOU'RE LIKE A FLESH BICYLE AND I WANT TO DISMANTLE YOU
			traitorTarget = null

	functions += "traitor"
	faction -= "neutral"
	faction += "hostile"

/mob/living/carbon/human/interactive/Initialize()
	..()

	set_species(/datum/species/synth)

	random()

	doSetup()

	START_PROCESSING(SSnpcpool, src)

	loadVoice()

	// a little bit of variation to make individuals more unique
	robustness += rand(-10,10)
	smartness += rand(-10,10)
	attitude += rand(-10,10)
	slyness += rand(-10,10)

/mob/living/carbon/human/interactive/Destroy()
	SSnpcpool.stop_processing(src)
	return ..()

/mob/living/carbon/human/interactive/proc/retalTarget(var/target)
	var/mob/living/carbon/human/M = target
	if(target)
		if(health > 0)
			if(M.a_intent == INTENT_HELP)
				chatter()
			if(M.a_intent == INTENT_HARM)
				retal = 1
				retal_target = target

//Retaliation clauses

/mob/living/carbon/human/interactive/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	..(AM,skipcatch,hitpush,blocked)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in view(MIN_RANGE_FIND,src)
	if(C)
		retalTarget(C)

/mob/living/carbon/human/interactive/attack_hand(mob/living/carbon/human/M)
	..(M)
	retalTarget(M)

/mob/living/carbon/human/interactive/show_inv(mob/user)
	..(user)
	retalTarget(user)

/mob/living/carbon/human/interactive/can_inject(mob/user, error_msg, target_zone, var/penetrate_thick = 0)
	..(user,error_msg,target_zone,penetrate_thick)
	retalTarget(user)


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

	var/obj/item/L = get_item_for_held_index(1) //just going to hardcode SNPCs to 2 hands, for now.
	var/obj/item/R = get_item_for_held_index(2) //they're just VERY assume-y about 2 hands.
	if(active_hand_index == 1)
		if(!L)
			main_hand = null
			if(R)
				swap_hands()
	else
		if(!R)
			main_hand = null
			if(L)
				swap_hands()


/mob/living/carbon/human/interactive/proc/swap_hands()
	var/oindex = active_hand_index
	if(active_hand_index == 1)
		active_hand_index = 2
	else
		active_hand_index = 1
	main_hand = get_active_held_item()
	other_hand = get_item_for_held_index(oindex)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/take_to_slot(obj/item/G, var/hands=0)
	var/list/slots = list ("left pocket" = slot_l_store,"right pocket" = slot_r_store,"left hand" = slot_hands,"right hand" = slot_hands)
	if(hands)
		slots = list ("left hand" = slot_hands,"right hand" = slot_hands)
	G.loc = src
	if(G.force && G.force > best_force)
		best_force = G.force
	equip_in_one_of_slots(G, slots)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/insert_into_backpack()
	var/list/slots = list ("left pocket" = slot_l_store,"right pocket" = slot_r_store,"left hand" = slot_hands,"right hand" = slot_hands)
	var/obj/item/I = get_item_by_slot(pick(slots))
	var/obj/item/weapon/storage/BP = get_item_by_slot(slot_back)
	if(back && BP && I)
		if(BP.can_be_inserted(I,0))
			BP.handle_item_insertion(I,0)
	else
		dropItemToGround(I,TRUE)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/targetRange(towhere)
	return get_dist(get_turf(towhere), get_turf(src))

/mob/living/carbon/human/interactive/proc/InteractiveProcess()
	if(SSticker.current_state == GAME_STATE_FINISHED)
		saveVoice()
	doProcess()

/mob/living/carbon/human/interactive/death()
	saveVoice()
	..()

/mob/living/carbon/human/interactive/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	if(speaker != src)
		knownStrings |= html_decode(raw_message)
	..()

/mob/living/carbon/human/interactive/proc/doProcess()
	set waitfor = FALSE
	//---------------------------
	//---- interest flow control
	if(interest < 0 || inactivity_period < 0)
		if(interest < 0)
			interest = 0
		if(inactivity_period < 0)
			inactivity_period = 0
	if(interest > maxInterest)
		interest = maxInterest
	//---------------------------
	//VIEW FUNCTIONS

	//doorscan is now integrated into life and runs before all other procs
	for(var/dir in GLOB.alldirs)
		var/turf/T = get_step(src,dir)
		if(T)
			for(var/obj/machinery/door/D in T.contents)
				if(!istype(D,/obj/machinery/door/poddoor) && D.density)
					if(istype(D,/obj/machinery/door/airlock))
						var/obj/machinery/door/airlock/AL = D
						if(!AL.CanAStarPass(RPID)) // only crack open doors we can't get through
							inactivity_period = 20
							AL.panel_open = 1
							AL.update_icon()
							AL.shock(src,(100 - smartness)/2)
							sleep(5)
							if(QDELETED(AL))
								return
							AL.unbolt()
							if(!AL.wires.is_cut(WIRE_BOLTS))
								AL.wires.cut(WIRE_BOLTS)
							if(!AL.wires.is_cut(WIRE_POWER1))
								AL.wires.cut(WIRE_POWER1)
							if(!AL.wires.is_cut(WIRE_POWER2))
								AL.wires.cut(WIRE_POWER2)
							sleep(5)
							if(QDELETED(AL))
								return
							AL.panel_open = 0
							AL.update_icon()
							D.open(2)	//crowbar force
						else
							D.open()
					else
						D.open()

	if(update_hands)
		var/obj/item/l_hand = get_item_for_held_index(1)
		var/obj/item/r_hand = get_item_for_held_index(2)
		if(l_hand || r_hand)
			if(l_hand)
				active_hand_index = 1
				main_hand = l_hand
				if(r_hand)
					other_hand = r_hand
			else if(r_hand)
				active_hand_index = 2
				main_hand = r_hand
				if(l_hand) //this technically shouldnt occur, but its a redundancy
					other_hand = l_hand
			update_icons()
		update_hands = 0

	if(pulledby)
		if(Adjacent(pulledby))
			a_intent = INTENT_DISARM
			pulledby.attack_hand(src)
			inactivity_period = 10

	if(buckled)
		resist()
		inactivity_period = 10

	//proc functions
	for(var/Proc in functions)
		if(!IsDeadOrIncap())
			INVOKE_ASYNC(src, Proc)


	//target interaction stays hardcoded

	if(TARGET) // don't use blacklisted items
		if(TARGET in blacklistItems)
			TARGET = null


	if((TARGET && Adjacent(TARGET)))
		doing |= INTERACTING
		//--------DOORS
		if(istype(TARGET, /obj/machinery/door))
			var/obj/machinery/door/D = TARGET
			if(D.check_access(MYID) && !istype(D,/obj/machinery/door/poddoor))
				inactivity_period = 10
				D.open()
				var/turf/T = get_step(get_step(D.loc,dir),dir) //recursion yo
				tryWalk(T)
		//THIEVING SKILLS
		if(!TARGET in blacklistItems)
			insert_into_backpack() // dump random item into backpack to make space
			//---------ITEMS
			if(istype(TARGET, /obj/item))
				if(istype(TARGET, /obj/item/weapon))
					var/obj/item/weapon/W = TARGET
					if(W.force >= best_force || prob((FUZZY_CHANCE_LOW+FUZZY_CHANCE_HIGH)/2))
						if(!get_item_for_held_index(1) || !get_item_for_held_index(2))
							put_in_hands(W)
						else
							insert_into_backpack()
				else
					if(!get_item_for_held_index(1) || !get_item_for_held_index(2))
						put_in_hands(TARGET)
					else
						insert_into_backpack()
			//---------FASHION
			if(istype(TARGET,/obj/item/clothing))
				drop_item()
				dressup(TARGET)
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
		if(TARGET)
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
		if(!isTraitor || !traitorTarget)
			var/choice = rand(1,50)
			switch(choice)
				if(1 to 30)
					//chance to chase an item
					TARGET = locate(/obj/item) in favouredObjIn(oview(MIN_RANGE_FIND,src))
				if(31 to 40)
					TARGET = safepick(get_area_turfs(job2area(myjob)))
				if(41 to 45)
					TARGET = pick(target_filter(favouredObjIn(urange(MAX_RANGE_FIND,src,1))))
				if(46 to 50)
					TARGET = pick(target_filter(oview(MIN_RANGE_FIND,src)))
		else if(isTraitor && traitorTarget)
			TARGET = traitorTarget
		tryWalk(TARGET)
	LAST_TARGET = TARGET

/mob/living/carbon/human/interactive/proc/dressup(obj/item/clothing/C)
	set waitfor = FALSE
	inactivity_period = 12
	sleep(5)
	if(!QDELETED(C) && !QDELETED(src))
		take_to_slot(C,1)
		if(!equip_to_appropriate_slot(C))
			var/obj/item/I = get_item_by_slot(C)
			dropItemToGround(I)
			sleep(5)
			if(!QDELETED(src) && !QDELETED(C))
				equip_to_appropriate_slot(C)

/mob/living/carbon/human/interactive/proc/favouredObjIn(var/list/inList)
	var/list/outList = list()
	for(var/i in inList)
		for(var/path in favoured_types)
			if(ispath(i,path))
				outList += i
	if(outList.len <= 0)
		outList = inList
	return outList

/mob/living/carbon/human/interactive/proc/tryWalk(turf/inTarget, override = 0)
	if(restrictedJob && !override) // we're a job that has to stay in our home
		if(!(get_turf(inTarget) in get_area_turfs(job2area(myjob))))
			TARGET = null
			return

	if(!IsDeadOrIncap())
		if(!walk2derpless(inTarget))
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

	if(walkdebug)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, target)
		spark_system.attach(target)
		spark_system.start()


	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1, id=Path_ID)

	if(myPath)
		if(myPath.len > 0)
			doing = doing & ~TRAVEL
			for(var/i = 0; i < maxStepsTick; ++i)
				if(!IsDeadOrIncap())
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
	if(T.title == "Bartender")
		return /area/crew_quarters/bar
	if(T.title == "Cook")
		return /area/crew_quarters/kitchen
	if(T.title == "Station Engineer" || T.title == "Chief Engineer" || T.title == "Atmospheric Technician")
		return /area/engine
	if(T.title == "Chief Medical Officer" || T.title == "Medical Doctor" || T.title == "Chemist" || T.title == "Virologist" || T.title == "Geneticist")
		return /area/medical
	if(T.title == "Research Director" || T.title == "Scientist" || T.title == "Roboticist")
		return /area/science
	if(T.title == "Head of Security" || T.title == "Warden" || T.title == "Security Officer" || T.title == "Detective")
		return /area/security
	if(T.title == "Botanist")
		return /area/hydroponics
	else
		return pick(/area/hallway,/area/crew_quarters/locker)

/mob/living/carbon/human/interactive/proc/target_filter(target)
	var/list/filtered_targets = list(/area, /turf, /obj/machinery/door, /atom/movable/light, /obj/structure/cable, /obj/machinery/atmospherics)
	var/list/L = target
	for(var/atom/A in target) // added a bunch of "junk" that clogs up the general find procs
		if(is_type_in_list(A,filtered_targets))
			L -= A
	return L

/mob/living/carbon/human/interactive/proc/shouldModulePass() // returns 1 if the npc is in anything "primary"
	if(doing & FIGHTING)
		return 1
	if(retal)
		return 1
	return 0

///BUILT IN MODULES
/mob/living/carbon/human/interactive/proc/chatter(obj)
	var/verbs_use = pick_list(NPC_SPEAK_FILE,"verbs_use")
	var/verbs_touch = pick_list(NPC_SPEAK_FILE,"verbs_touch")
	var/verbs_move = pick_list(NPC_SPEAK_FILE,"verbs_move")
	var/nouns_insult = pick_list(NPC_SPEAK_FILE,"nouns_insult")
	var/nouns_generic = pick_list(NPC_SPEAK_FILE,"nouns_generic")
	var/nouns_objects = pick_list(NPC_SPEAK_FILE,"nouns_objects")
	var/nouns_body = pick_list(NPC_SPEAK_FILE,"nouns_body")
	var/adjective_insult = pick_list(NPC_SPEAK_FILE,"adjective_insult")
	var/adjective_objects = pick_list(NPC_SPEAK_FILE,"adjective_objects")
	var/adjective_generic = pick_list(NPC_SPEAK_FILE,"adjective_generic")
	var/curse_words = pick_list(NPC_SPEAK_FILE,"curse_words")

	var/chatmsg = ""

	if(prob(10)) // 10% chance to broadcast it over the radio
		chatmsg = ";"

	if(prob(chattyness) || knownStrings.len < 10) // say a generic phrase, otherwise draw from our strings.
		if(doing & INTERACTING)
			if(prob(chattyness))
				chatmsg += pick("This [nouns_objects] is a little [adjective_objects].",
				"Well [verbs_use] my [nouns_body], this [nouns_insult] is pretty [adjective_insult].",
				"[capitalize(curse_words)], what am I meant to do with this [adjective_insult] [nouns_objects].")
		else if(doing & TRAVEL)
			if(prob(chattyness))
				chatmsg += pick("Oh [curse_words], [verbs_move]!",
				"Time to get my [adjective_generic] [adjective_insult] [nouns_body] elsewhere.",
				"I wonder if there is anything to [verbs_use] and [verbs_touch] somewhere else..")
		else if(doing & FIGHTING)
			if(prob(chattyness))
				chatmsg += pick("I'm going to [verbs_use] you, you [adjective_insult] [nouns_insult]!",
				"Rend and [verbs_touch], rend and [verbs_use]!",
				"You [nouns_insult], I'm going to [verbs_use] you right in the [nouns_body]. JUST YOU WAIT!")
		if(prob(chattyness/2))
			chatmsg = ";"
			var/what = pick(1,2,3,4,5)
			switch(what)
				if(1)
					chatmsg += "Well [curse_words], this is a [adjective_generic] situation."
				if(2)
					chatmsg += "Oh [curse_words], that [nouns_insult] was one hell of an [adjective_insult] [nouns_body]."
				if(3)
					chatmsg += "I want to [verbs_use] that [nouns_insult] when I find them."
				if(4)
					chatmsg += "[pick("Innocent","Guilty","Traitorous","Honk")] until proven [adjective_generic]!"
				if(5)
					var/toSay = ""
					for(var/i = 0; i < 5; i++)
						curse_words = pick_list(NPC_SPEAK_FILE,"curse_words")
						toSay += "[curse_words] "
					chatmsg += "Hey [nouns_generic], why dont you go [toSay], you [nouns_insult]!"
	else if(prob(chattyness))
		chatmsg += pick(knownStrings)
		if(prob(25)) // cut out some phrases now and then to make sure we're fresh and new
			knownStrings -= pick(chatmsg)

	if(chatmsg != ";" && chatmsg != "")
		src.say(chatmsg)


/mob/living/carbon/human/interactive/proc/getAllContents()
	var/list/allContents = list()
	for(var/atom/A in contents)
		allContents += A
		if(A.contents.len > 0)
			for(var/atom/B in A)
				allContents += B
	return allContents

/mob/living/carbon/human/interactive/proc/enforceHome()
	var/list/validHome = get_area_turfs(job2area(myjob))

	if(TARGET)
		var/atom/tcheck = TARGET
		if(tcheck)
			if(!(get_turf(tcheck) in validHome))
				TARGET = null
				return 1

	if(!(get_turf(src) in validHome))
		tryWalk(pick(get_area_turfs(job2area(myjob))))
		return 1
	return 0

/mob/living/carbon/human/interactive/proc/npcDrop(var/obj/item/A,var/blacklist = 0)
	if(blacklist)
		blacklistItems += A
	A.loc = get_turf(src) // drop item works inconsistently
	enforce_hands()
	update_icons()

/mob/living/carbon/human/interactive/proc/traitor(obj)

	if(traitorType == SNPC_PSYCHO)
		traitorTarget = pick(nearby)

	if(prob(traitorScale))
		if(!Adjacent(traitorTarget) && !(traitorType == SNPC_PSYCHO))
			tryWalk(get_turf(traitorTarget))
		else
			switch(traitorType)
				if(SNPC_BRUTE)
					retal = 1
					retal_target = traitorTarget
				if(SNPC_STEALTH)
					if(istype(traitorTarget,/mob)) // it's inside something, lets kick their shit in
						var/mob/M = traitorTarget
						if(!M.stat)
							retal = 1
							retal_target = traitorTarget
						else
							var/obj/item/I = traitorTarget
							I.loc = get_turf(traitorTarget) // pull it outta them
					else
						take_to_slot(traitorTarget)
				if(SNPC_MARTYR)
					customEmote("[src]'s chest opens up, revealing a large mass of explosives and tangled wires!")
					if(inactivity_period <= 0)
						inactivity_period = 9999 // technically infinite
						if(do_after(src,60,target=traitorTarget))
							customEmote("A fire bursts from [src]'s eyes, igniting white hot and consuming their body in a flaming explosion!")
							explosion(src, 6, 6, 6)
						else
							inactivity_period = 0
							customEmote("[src]'s chest closes, hiding their insides.")
				if(SNPC_PSYCHO)
					var/choice = pick(typesof(/obj/item/weapon/grenade/chem_grenade) - /obj/item/weapon/grenade/chem_grenade)

					new choice(src)

					retal = 1
					retal_target = traitorTarget

/mob/living/carbon/human/interactive/proc/botany(obj)
	if(shouldModulePass())
		return

	if(enforceHome())
		return

	var/list/allContents = getAllContents()

	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/internalBeaker = locate(/obj/item/weapon/reagent_containers/glass/beaker/bluespace) in allContents
	var/obj/item/weapon/storage/bag/plants/internalBag = locate(/obj/item/weapon/storage/bag/plants) in allContents

	if(!internalBag)
		internalBag = new/obj/item/weapon/storage/bag/plants(src)
	if(!internalBeaker)
		internalBeaker = new/obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
		internalBeaker.name = "Grow-U-All Super Spray"

	if(internalBeaker && internalBag)
		var/obj/machinery/hydroponics/HP

		//consider the appropriate target
		var/list/considered = list()

		for(var/obj/machinery/hydroponics/tester in view(12,src))
			considered[tester] = 1

			if(!tester.myseed)
				considered[tester] += 50
			if(tester.weedlevel > 0)
				considered[tester] += 5
			if(tester.pestlevel > 0)
				considered[tester] += 5
			if(tester.nutrilevel <  tester.maxnutri)
				considered[tester] += 15
			if(tester.waterlevel < tester.maxwater)
				considered[tester] += 15
			if(tester.harvest || tester.dead)
				considered[tester] += 100
			considered[tester] = max(1,considered[tester] - get_dist(src,tester))

		var/index = 0
		for(var/A in considered)
			++index
			if(considered[A] > considered[HP] || !HP)
				HP = considered[index]

		if(HP)
			TARGET = HP
			if(!Adjacent(HP))
				tryWalk(get_turf(HP))
			else
				if(HP.harvest || HP.dead)
					HP.attack_hand(src)
				else if(!HP.myseed)
					var/seedType = pick(typesof(/obj/item/seeds) - /obj/item/seeds)
					var/obj/item/seeds/SEED = new seedType(src)
					customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")] towards [TARGET], producing a [SEED]!")
					HP.attackby(SEED,src)
				else
					var/change = 0
					if(HP.weedlevel > 0)
						change = 1
						if(!internalBeaker.reagents.has_reagent("weedkiller", 10))
							internalBeaker.reagents.add_reagent("weedkiller",10)
					if(HP.pestlevel > 0)
						change = 1
						if(!internalBeaker.reagents.has_reagent("pestkiller", 10))
							internalBeaker.reagents.add_reagent("pestkiller",10)
					if(HP.nutrilevel <  HP.maxnutri)
						change = 1
						if(!internalBeaker.reagents.has_reagent("eznutriment", 15))
							internalBeaker.reagents.add_reagent("eznutriment",15)
						if(!internalBeaker.reagents.has_reagent("diethylamine", 15))
							internalBeaker.reagents.add_reagent("diethylamine",15)
					if(HP.waterlevel < HP.maxwater)
						change = 1
						if(!internalBeaker.reagents.has_reagent("holywater", 50))
							internalBeaker.reagents.add_reagent("holywater",50)
					if(change)
						HP.attackby(internalBeaker,src)

		var/obj/item/weapon/reagent_containers/food/snacks/grown/GF = locate(/obj/item/weapon/reagent_containers/food/snacks/grown) in view(12,src)
		if(GF)
			if(!Adjacent(GF))
				tryWalk(get_turf(GF))
			else
				GF.attackby(internalBag,src)

		if(internalBag.contents.len > 0)
			var/obj/machinery/smartfridge/SF = locate(/obj/machinery/smartfridge) in range(12,src)
			if(!Adjacent(SF))
				tryWalk(get_turf(SF), 1)
			else
				customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")], upending the [internalBag]'s contents all over the [SF]!")
				//smartfridges call updateUsrDialog when you call attackby, so we're going to have to cheese-magic-space this
				for(var/obj/toLoad in internalBag.contents)
					if(contents.len >= SF.max_n_of_items)
						break
					if(SF.accept_check(toLoad))
						SF.load(toLoad)
					else
						qdel(toLoad) // destroy everything we dont need

/mob/living/carbon/human/interactive/proc/bartend(obj)
	if(shouldModulePass())
		return

	if(enforceHome())
		return

	var/list/rangeCheck = oview(6,src)
	var/obj/structure/table/RT

	var/mob/living/carbon/human/serveTarget

	for(var/mob/living/carbon/human/H in rangeCheck)
		if(!locate(/obj/item/weapon/reagent_containers/food/drinks) in orange(1,H))
			serveTarget = H


	if(serveTarget)
		RT = locate(/obj/structure/table) in orange(1,serveTarget)

	if(RT && serveTarget)
		if(!Adjacent(RT))
			tryWalk(get_turf(RT))
		else
			var/drinkChoice = pick(typesof(/obj/item/weapon/reagent_containers/food/drinks) - /obj/item/weapon/reagent_containers/food/drinks)
			if(drinkChoice)
				var/obj/item/weapon/reagent_containers/food/drinks/D = new drinkChoice(get_turf(src))
				RT.attackby(D,src)
				src.say("[pick("Something to wet your whistle!","Down the hatch, a tasty beverage!","One drink, coming right up!","Tasty liquid for your oral intake!","Enjoy!")]")
				customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")], serving up a [D]!")

/mob/living/carbon/human/interactive/proc/shitcurity(obj)
	var/list/allContents = getAllContents()

	for(var/mob/living/carbon/human/C in nearby)
		var/perpname = C.get_face_name(C.get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					retalTarget(C)

	if(retal && TARGET)
		for(var/obj/item/I in allContents)
			if(istype(I,/obj/item/weapon/restraints))
				I.attack(TARGET,src) // go go bluespace restraint launcher!
				inactivity_period = 25
				break

/mob/living/carbon/human/interactive/proc/clowning(obj)
	if(shouldModulePass())
		return
	var/list/allContents = getAllContents()
	var/list/rangeCheck = orange(12,src)

	var/mob/living/carbon/human/clownTarget
	var/list/clownPriority = list()

	var/obj/item/weapon/reagent_containers/spray/S = locate(/obj/item/weapon/reagent_containers/spray) in allContents

	if(!S)
		S = new/obj/item/weapon/reagent_containers/spray(src)
		S.amount_per_transfer_from_this = 10

	for(var/mob/living/carbon/human/C in rangeCheck)
		var/pranksNearby = 100
		for(var/turf/open/T in orange(1,C))
			for(var/obj/item/A in T)
				if(istype(A,/obj/item/weapon/soap) || istype(A,/obj/item/weapon/reagent_containers/food/snacks/grown/banana) || istype(A,/obj/item/weapon/grown/bananapeel))
					pranksNearby--
			if(T.wet)
				pranksNearby -= 10
		clownPriority[C] = pranksNearby

	for(var/A in clownPriority)
		if(!clownTarget)
			clownTarget = A
		else
			if(clownPriority[A] > clownPriority[clownTarget])
				clownTarget = clownPriority[A]

	if(clownTarget)
		if(!Adjacent(clownTarget))
			tryWalk(clownTarget)
		else
			var/hasPranked = 0
			for(var/A in allContents)
				if(prob(smartness/2) && !hasPranked)
					if(istype(A,/obj/item/weapon/soap))
						npcDrop(A)
						hasPranked = 1
					if(istype(A,/obj/item/weapon/reagent_containers/food/snacks/grown/banana))
						var/obj/item/weapon/reagent_containers/food/snacks/B = A
						B.attack(src, src)
					if(istype(A,/obj/item/weapon/grown/bananapeel))
						npcDrop(A)
						hasPranked = 1
			if(!hasPranked)
				if(S.reagents.total_volume <= 5)
					S.reagents.add_reagent("water", 25)
				S.afterattack(get_turf(pick(orange(1,clownTarget))),src)


/mob/living/carbon/human/interactive/proc/healpeople(obj)
	var/shouldTryHeal = 0
	var/obj/item/stack/medical/M

	var/list/allContents = getAllContents()

	for(var/A in allContents)
		if(istype(A,/obj/item/stack/medical))
			shouldTryHeal = 1
			M = A

	var/obj/item/weapon/reagent_containers/hypospray/HPS

	if(!locate(/obj/item/weapon/reagent_containers/hypospray) in allContents)
		new/obj/item/weapon/reagent_containers/hypospray(src)
	else
		HPS = locate(/obj/item/weapon/reagent_containers/hypospray) in allContents
		if(!shouldTryHeal)
			shouldTryHeal = 2 // we have no stackables to use, lets use our internal hypospray instead

	if(shouldTryHeal == 1)
		for(var/mob/living/carbon/human/C in nearby)
			if(C.health <= 75)
				if(get_dist(src,C) <= 2)
					src.say("Wait, [C], let me heal you!")
					M.attack(C,src)
					inactivity_period = 25
				else
					tryWalk(get_turf(C))
	else if(shouldTryHeal == 2)
		if(HPS)
			if(HPS.reagents.total_volume <= 0)
				HPS.reagents.add_reagent("tricordrazine",30)
			for(var/mob/living/carbon/human/C in nearby)
				if(C.health <= 75 && C.reagents.get_reagent_amount("tricordrazine") <= 0) // make sure they wont be overdosing
					if(get_dist(src,C) <= 2)
						src.say("Wait, [C], let me heal you!")
						HPS.attack(C,src)
						inactivity_period = 25
					else
						tryWalk(get_turf(C))


/mob/living/carbon/human/interactive/proc/dojanitor(obj)
	if(shouldModulePass())
		return
	var/list/allContents = getAllContents()
	//now with bluespace magic!
	var/obj/item/weapon/reagent_containers/spray/S
	if(!locate(/obj/item/weapon/reagent_containers/spray) in allContents)
		new/obj/item/weapon/reagent_containers/spray(src)
	else
		S = locate(/obj/item/weapon/reagent_containers/spray) in allContents

	if(S)
		if(S.reagents.total_volume <= 5)
			S.reagents.add_reagent("cleaner", 25) // bluespess water delivery for AI

		var/obj/effect/decal/cleanable/TC
		TC = locate(/obj/effect/decal/cleanable) in range(MAX_RANGE_FIND,src)

		if(TC)
			if(!Adjacent(TC))
				tryWalk(TC)
			else
				S.afterattack(TC,src)
				inactivity_period = 25

/mob/living/carbon/human/interactive/proc/customEmote(var/text)
	visible_message("<span class='notice'>[text]</span>")

// START COOKING MODULE
/mob/living/carbon/human/interactive/proc/cookingwithmagic(var/obj/item/weapon/reagent_containers/food/snacks/target)
	if(Adjacent(target))
		customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")] towards [target], and with a bang, it's instantly cooked!")
		var/obj/item/weapon/reagent_containers/food/snacks/S = new target.cooked_type (get_turf(src))
		target.initialize_cooked_food(S, 100)
		if(target) // cleaning up old food seems inconsistent, so this will clean up stragglers
			qdel(target)
	else
		tryWalk(target)

/mob/living/carbon/human/interactive/proc/souschef(obj)
	if(shouldModulePass())
		return

	if(enforceHome())
		return

	var/list/allContents = getAllContents()

	//Bluespace in some inbuilt tools
	var/obj/item/weapon/kitchen/rollingpin/RP = locate(/obj/item/weapon/kitchen/rollingpin) in allContents
	if(!RP)
		new/obj/item/weapon/kitchen/rollingpin(src)

	var/obj/item/weapon/kitchen/knife/KK = locate(/obj/item/weapon/kitchen/knife) in allContents
	if(!KK)
		new/obj/item/weapon/kitchen/knife(src)

	var/foundCookable = 0

	if(RP && KK) // Ready to cook!

		var/list/rangeCheck = view(6,src)

		//Make some basic custom food
		var/list/customableTypes = list(/obj/item/weapon/reagent_containers/food/snacks/customizable,/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain,/obj/item/weapon/reagent_containers/food/snacks/pizzabread,/obj/item/weapon/reagent_containers/food/snacks/bun,/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain,/obj/item/weapon/reagent_containers/food/snacks/pie/plain,/obj/item/weapon/reagent_containers/food/snacks/pastrybase)

		var/foundCustom

		for(var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/DP in rangeCheck) // donkpockets are hitler to chef SNPCs
			if(prob(50))
				customEmote("[src] points at the [DP], emitting a loud [pick("bellow","screech","yell","scream")], and it bursts into flame.")
				qdel(DP)

		for(var/customType in customableTypes)
			var/A = locate(customType) in rangeCheck
			if(A)
				foundCustom = A // this will eventually wittle down to 0


		var/obj/machinery/smartfridge/SF = locate(/obj/machinery/smartfridge) in rangeCheck
		if(SF)
			if(SF.contents.len > 0)
				if(!Adjacent(SF))
					tryWalk(get_turf(SF),1)
				else
					customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")], grabbing various foodstuffs from [SF] and sticking them in it's mouth!")
					for(var/obj/item/A in SF.contents)
						if(prob(smartness/2))
							A.loc = src


		if(foundCustom)
			var/obj/item/weapon/reagent_containers/food/snacks/FC = foundCustom
			for(var/obj/item/weapon/reagent_containers/food/snacks/toMake in allContents)
				if(prob(smartness))
					if(FC.reagents)
						FC.attackby(toMake,src)
					else
						qdel(FC) // this food is usless, toss it


		//Process dough into various states
		var/obj/item/weapon/reagent_containers/food/snacks/dough/D = locate(/obj/item/weapon/reagent_containers/food/snacks/dough) in rangeCheck
		var/obj/item/weapon/reagent_containers/food/snacks/flatdough/FD = locate(/obj/item/weapon/reagent_containers/food/snacks/flatdough) in rangeCheck
		var/obj/item/weapon/reagent_containers/food/snacks/cakebatter/CB = locate(/obj/item/weapon/reagent_containers/food/snacks/cakebatter) in rangeCheck
		var/obj/item/weapon/reagent_containers/food/snacks/piedough/PD = locate(/obj/item/weapon/reagent_containers/food/snacks/piedough) in rangeCheck

		if(D)
			TARGET = D
			var/choice = pick(1,2)
			if(choice == 1)
				tryWalk(get_turf(D))
				inactivity_period = get_dist(src,D)
				D.attackby(RP,src)
			else
				cookingwithmagic(D)
			foundCookable = 1
		else if(FD)
			TARGET = FD
			var/choice = pick(1,2)
			if(choice == 1)
				tryWalk(get_turf(D))
				inactivity_period = get_dist(src,D)
				FD.attackby(KK,src)
			else
				cookingwithmagic(FD)
			foundCookable = 1
		else if(CB)
			TARGET = CB
			var/choice = pick(1,2)
			if(choice == 1)
				tryWalk(get_turf(D))
				inactivity_period = get_dist(src,D)
				CB.attackby(RP,src)
			else
				cookingwithmagic(CB)
			foundCookable = 1
		else if(PD)
			TARGET = PD
			var/choice = pick(1,2)
			if(choice == 1)
				tryWalk(get_turf(D))
				inactivity_period = get_dist(src,D)
				PD.attackby(KK,src)
			else
				cookingwithmagic(PD)
			foundCookable = 1


		//Cook various regular foods into processed versions
		var/obj/item/weapon/reagent_containers/food/snacks/toCook = locate(/obj/item/weapon/reagent_containers/food/snacks) in rangeCheck
		if(toCook)
			if(toCook.cooked_type)
				TARGET = toCook
				foundCookable = 1
				if(Adjacent(toCook))
					cookingwithmagic(toCook)
				else
					tryWalk(get_turf(toCook))

		var/list/finishedList = list()
		for(var/obj/item/weapon/reagent_containers/food/snacks/toDisplay in allContents)
			if(!toDisplay.cooked_type && !istype(toDisplay,/obj/item/weapon/reagent_containers/food/snacks/grown)) // dont display our ingredients
				finishedList += toDisplay

		for(var/obj/item/weapon/reagent_containers/food/snacks/toGrab in rangeCheck)
			if(!(locate(/obj/structure/table/reinforced) in get_turf(toGrab))) //it's not being displayed
				foundCookable = 1
				if(!Adjacent(toGrab))
					tryWalk(toGrab)
				else
					toGrab.loc = src

		if(finishedList.len > 0)
			var/obj/structure/table/reinforced/RT

			for(var/obj/structure/table/reinforced/toCheck in rangeCheck)
				var/counted = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in get_turf(toCheck))
					++counted
				if(counted < 12) // make sure theres not too much food here
					RT = toCheck
					break

			if(RT)
				foundCookable = 1
				if(!Adjacent(RT))
					tryWalk(get_turf(RT))
				else
					for(var/obj/item/weapon/reagent_containers/food/snacks/toPlop in allContents)
						RT.attackby(toPlop,src)

		if(!foundCookable)
			var/list/allTypes = list(/obj/item/weapon/reagent_containers/food/snacks/piedough,/obj/item/weapon/reagent_containers/food/snacks/cakebatter,/obj/item/weapon/reagent_containers/food/snacks/dough,/obj/item/weapon/reagent_containers/food/snacks/flatdough)

			for(var/A in typesof(/obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/O = A
				if(initial(O.cooked_type))
					allTypes += A

			var/chosenType = pick(allTypes)

			var/obj/item/weapon/reagent_containers/food/snacks/newSnack = new chosenType(get_turf(src))
			TARGET = newSnack
			newSnack.reagents.remove_any((newSnack.reagents.total_volume/2)-1)
			newSnack.name = "Synthetic [newSnack.name]"
			customEmote("[src] [pick("gibbers","drools","slobbers","claps wildly","spits")] as they vomit [newSnack] from their mouth!")
// END COOKING MODULE

/mob/living/carbon/human/interactive/proc/compareFaction(var/list/targetFactions)
	var/hasSame = 0

	for(var/A in targetFactions)
		if(A in faction)
			hasSame = 1

	return hasSame

/mob/living/carbon/human/interactive/proc/combat(obj)
	enforce_hands()
	if(canmove)
		if((graytide || (TRAITS & TRAIT_MEAN)) || retal)
			interest += targetInterestShift
			a_intent = INTENT_HARM
			zone_selected = pick("chest","r_leg","l_leg","r_arm","l_arm","head")
			doing |= FIGHTING
			if(retal)
				TARGET = retal_target
			else
				var/mob/living/M = locate(/mob/living) in oview(7,src)
				if(!M)
					doing = doing & ~FIGHTING
				else if(M != src && !compareFaction(M.faction))
					TARGET = M

	//no infighting
	if(retal)
		if(retal_target)
			if(compareFaction(retal_target.faction))
				retal = 0
				retal_target = null
				TARGET = null
				doing = 0

	//ensure we're using the best object possible

	var/obj/item/weapon/best
	var/foundFav = 0
	var/list/allContents = getAllContents()
	for(var/test in allContents)
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

	if((TARGET && (doing & FIGHTING))) // this is a redundancy check
		var/mob/living/M = TARGET
		if(isliving(M))
			if(M.health > 1)
				//THROWING OBJECTS
				for(var/A in allContents)
					if(istype(A,/obj/item/weapon/gun))	// guns are for shooting, not throwing.
						continue
					if(prob(robustness))
						if(istype(A,/obj/item/weapon))
							var/obj/item/weapon/W = A
							if(W.throwforce > 19) // Only throw worthwile stuff, no more lobbing wrenches at wenches
								npcDrop(W,1)
								throw_item(TARGET)
						if(istype(A,/obj/item/weapon/grenade)) // Allahu ackbar! ALLAHU ACKBARR!!
							var/obj/item/weapon/grenade/G = A
							G.attack_self(src)
							if(prob(smartness))
								npcDrop(G,1)
								inactivity_period = 15
								sleep(15)
								throw_item(TARGET)

				if(!main_hand && other_hand)
					swap_hands()
				if(main_hand)
					if(main_hand.force != 0)
						if(istype(main_hand,/obj/item/weapon/gun))
							var/obj/item/weapon/gun/G = main_hand
							if(G.can_trigger_gun(src))
								if(istype(main_hand,/obj/item/weapon/gun/ballistic))
									var/obj/item/weapon/gun/ballistic/P = main_hand
									if(!P.chambered)
										P.chamber_round()
										P.update_icon()
									else if(P.get_ammo(1) == 0)
										P.update_icon()
										npcDrop(P,1)
									else
										P.afterattack(TARGET, src)
								else if(istype(main_hand,/obj/item/weapon/gun/energy))
									var/obj/item/weapon/gun/energy/P = main_hand
									var/stunning = 0
									for(var/A in P.ammo_type)
										if(ispath(A,/obj/item/ammo_casing/energy/electrode))
											stunning = 1
									var/shouldFire = 1
									var/mob/stunCheck = TARGET
									if(stunning && stunCheck.stunned)
										shouldFire = 0
									if(shouldFire)
										if(P.power_supply.charge <= 10) // can shoot seems to bug out for tasers, using this hacky method instead
											P.update_icon()
											npcDrop(P,1)
										else
											P.afterattack(TARGET, src)
								else
									if(get_dist(src,TARGET) > 6)
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
					if(targetRange(TARGET) > 2)
						tryWalk(TARGET)
					else
						if(Adjacent(TARGET))
							a_intent = pick(INTENT_DISARM, INTENT_HARM)
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


/mob/living/carbon/human/interactive/proc/nearbyscan(obj)
	nearby = list()
	for(var/mob/living/M in view(4,src))
		if(M != src)
			nearby += M

//END OF MODULES
/mob/living/carbon/human/interactive/angry/Initialize()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	faction += "bot_angry"
	..()

/mob/living/carbon/human/interactive/friendly/Initialize()
	TRAITS |= TRAIT_FRIENDLY
	TRAITS |= TRAIT_UNROBUST
	faction += "bot_friendly"
	faction += "neutral"
	functions -= "combat"
	..()

/mob/living/carbon/human/interactive/greytide/Initialize()
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_MEAN
	TRAITS |= TRAIT_THIEVING
	TRAITS |= TRAIT_DUMB
	maxInterest = 5 // really short attention span
	targetInterestShift = 2 // likewise
	faction += "bot_grey"
	graytide = 1
	..()

//Walk softly and carry a big stick
/mob/living/carbon/human/interactive/robust/Initialize()
	TRAITS |= TRAIT_FRIENDLY
	TRAITS |= TRAIT_ROBUST
	TRAITS |= TRAIT_SMART
	faction += "bot_power"
	..()
