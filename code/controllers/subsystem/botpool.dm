var/datum/subsystem/botpool/SSbp

/datum/subsystem/botpool
	name = "BotPool"
	priority = 27

	var/list/canBeUsed = list()
	var/list/canBeUsed_non = list()
	var/list/needsDelegate = list()
	var/list/needsAssistant = list()
	var/list/needsHelp_non = list()
	var/list/botPool_l = list() //list of all bots using the pool, strided as botmob, botgrouping
	var/list/botPool_l_non = list() //list of all non SNPC mobs using the pool

/datum/subsystem/botpool/proc/insertBot(var/toInsert)
	if(istype(toInsert,/mob/living/carbon/human/interactive))
		botPool_l |= toInsert
	else if(istype(toInsert,/obj/machinery/bot))
		botPool_l_non |= toInsert

/datum/subsystem/botpool/New()
	NEW_SS_GLOBAL(SSbp)


/datum/subsystem/botpool/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) (T:[botPool_l.len + botPool_l_non] | D: [needsDelegate.len] | A: [needsAssistant.len + needsHelp_non.len] | U: [canBeUsed.len + canBeUsed_non.len])")


/datum/subsystem/botpool/fire()
	//bot delegation and coordination systems
	//General checklist/Tasks for delegating a task or coordinating it
	// 1. Bot proximity to task target: if too far, delegate, if close, coordinate
	// 2. Bot Health/status: check health with bots in local area, if their health is higher, delegate task to them, else coordinate
	// 3. Process delegation: if a bot (or bots) has been delegated, assign them to the task.
	// 4. Process coordination: if a bot(or bots) has been asked to coordinate, assign them to help.
	// 5. Do all assignments: goes through the delegated/coordianted bots and assigns the right variables/tasks to them.
	var/npcCount

	//bot handling
	for(npcCount = 1; npcCount < botPool_l_non.len; ++npcCount)
		var/obj/machinery/bot/check = botPool_l_non[npcCount]
		if(!check)
			botPool_l_non.Cut(npcCount,npcCount+1)

		if(check.hacked)
			needsHelp_non |= check

		else if(check.frustration > 5) //average for most bots
			needsHelp_non |= check
		else if(check.mode == 0)
			canBeUsed_non |= check

	npcCount = 0 //reset the count

	//SNPC handling
	for(npcCount = 1; npcCount < botPool_l.len; ++npcCount)
		var/mob/living/carbon/human/interactive/check = botPool_l[npcCount]
		var/checkInRange = view(MAX_RANGE_FIND,check)
		if(!check)
			botPool_l.Cut(npcCount,npcCount+1)
		if(!(locate(check.TARGET) in checkInRange))
			needsDelegate |= check

		else if(check.isnotfunc(FALSE))
			needsDelegate |= check

		else if(check.doing & FIGHTING)
			needsAssistant |= check

		else
			canBeUsed |= check

	if(needsDelegate.len)
		for(var/mob/living/carbon/human/interactive/check in needsDelegate)
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				if(check.faction[1] == candidate.faction[1])
					if(candidate.takeDelegate(check))
						needsDelegate -= check
						canBeUsed -= candidate
						candidate.eye_color = "red"

	if(needsAssistant.len)
		for(var/mob/living/carbon/human/interactive/check in needsAssistant)
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				if(check.faction[1] == candidate.faction[1])
					if(candidate.takeDelegate(check,FALSE))
						needsAssistant -= check
						canBeUsed -= candidate
						candidate.eye_color = "yellow"

	if(needsHelp_non.len)
		for(var/obj/machinery/bot/B in needsHelp_non)
			if(canBeUsed_non.len)
				var/obj/machinery/bot/candidate = pick(canBeUsed_non.len)
				candidate.call_bot(B,get_turf(B),FALSE)
				canBeUsed_non -= B
				needsHelp_non -= candidate