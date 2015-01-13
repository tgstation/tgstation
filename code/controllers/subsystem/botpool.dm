var/datum/subsystem/botpool/SSbp

/datum/subsystem/botpool
	name = "BotPool"
	priority = 27

	var/list/canBeUsed = list()
	var/list/needsDelegate = list()
	var/list/needsAssistant = list()
	var/list/botPool_l = list() //list of all bots using the pool, strided as botmob, botgrouping

/datum/subsystem/botpool/proc/insertBot(var/mob/living/carbon/human/interactive/toInsert)
	botPool_l |= toInsert

/datum/subsystem/botpool/New()
	NEW_SS_GLOBAL(SSbp)


/datum/subsystem/botpool/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) (T:[botPool_l.len] | D: [needsDelegate.len] | A: [needsAssistant.len] | U: [canBeUsed.len])")


/datum/subsystem/botpool/fire()
	//bot delegation and coordination systems
	//General checklist/Tasks for delegating a task or coordinating it
	// 1. Bot proximity to task target: if too far, delegate, if close, coordinate
	// 2. Bot Health/status: check health with bots in local area, if their health is higher, delegate task to them, else coordinate
	// 3. Process delegation: if a bot (or bots) has been delegated, assign them to the task.
	// 4. Process coordination: if a bot(or bots) has been asked to coordinate, assign them to help.
	// 5. Do all assignments: goes through the delegated/coordianted bots and assigns the right variables/tasks to them.
	var/npcCount
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