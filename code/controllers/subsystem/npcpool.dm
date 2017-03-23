var/datum/controller/subsystem/npcpool/SSnpc

#define PROCESSING_NPCS 0
#define PROCESSING_DELEGATES 1
#define PROCESSING_ASSISTANTS 2

/datum/controller/subsystem/npcpool
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = 20

	var/list/canBeUsed = list()
	var/list/canBeUsed_non = list()
	var/list/needsDelegate = list()
	var/list/needsAssistant = list()
	var/list/needsHelp_non = list()
	
	var/list/processing = list()
	var/list/currentrun = list()
	var/stage

/datum/controller/subsystem/npcpool/New()
	NEW_SS_GLOBAL(SSnpc)

/datum/controller/subsystem/npcpool/stat_entry()
	..("T:[botPool_l.len + botPool_l_non.len]|D:[needsDelegate.len]|A:[needsAssistant.len + needsHelp_non.len]|U:[canBeUsed.len + canBeUsed_non.len]")

/datum/controller/subsystem/npcpool/proc/stop_processing(mob/living/carbon/human/interactive/I)
	processing -= I
	currentrun -= I
	needsDelegate -= I
	canBeUsed -= I
	needsAssistant -= I

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)
	//bot delegation and coordination systems
	//General checklist/Tasks for delegating a task or coordinating it (for SNPCs)
	// 1. Bot proximity to task target: if too far, delegate, if close, coordinate
	// 2. Bot Health/status: check health with bots in local area, if their health is higher, delegate task to them, else coordinate
	// 3. Process delegation: if a bot (or bots) has been delegated, assign them to the task.
	// 4. Process coordination: if a bot(or bots) has been asked to coordinate, assign them to help.
	// 5. Do all assignments: goes through the delegated/coordianted bots and assigns the right variables/tasks to them.

	if (!resumed)
		src.currentrun = processing.Copy()
		stage = PROCESSING_NPCS
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/list/canBeUsed = src.canBeUsed

	if(stage == PROCESSING_NPCS)
		while(currentrun.len)
			var/mob/living/carbon/human/interactive/thing = currentrun[currentrun.len]
			--currentrun.len

			thing.InteractiveProcess()

			var/checkInRange = view(MAX_RANGE_FIND,check)
			if(thing.IsDeadOrIncap(FALSE) || !(locate(thing.TARGET) in checkInRange))
				needsDelegate |= check
			else if(check.doing & FIGHTING)
				needsAssistant |= check
			else
				canBeUsed |= check

			if (MC_TICK_CHECK)
				return
		stage = PROCESSING_DELEGATES
		currentrun = needsDelegate	//localcache
		src.currentrun = currentrun

	if(stage == PROCESSING_DELEGATES)
		while(currentrun.len && canBeUsed.len)
			var/mob/living/carbon/human/interactive/check = currentrun[currentrun.len]
			var/mob/living/carbon/human/interactive/candidate = canBeUsed[canBeUsed.len]
			--currentrun.len

			var/helpProb = 0
			var/list/chfac = check.faction
			var/list/canfac = candidate.faction
			var/facCount = LAZYLEN(chfac) * LAZYLEN(canfac)

			for(var/C in chfac)
				if(C in canfac)
					helpProb = min(100,helpProb + 25)
					if(helpProb >= 100)
						break

			if(facCount == 1 && helpProb)
				helpProb = 100

			if(prob(helpProb) && candidate.takeDelegate(check))
				--canBeUsed.len
				candidate.eye_color = "red"
				candidate.update_icons()

			if(MC_TICK_CHECK)
				return
		stage = PROCESSING_ASSISTANTS
		currentrun = needsAssistant	//localcache
		src.currentrun = currentrun

	//no need for the stage check

	while(currentrun.len && canBeUsed.len)
		var/mob/living/carbon/human/interactive/check = currentrun[currentrun.len]
		var/mob/living/carbon/human/interactive/candidate = canBeUsed[canBeUsed.len]
		--currentrun.len

		var/helpProb = 0
		var/list/chfac = check.faction
		var/list/canfac = candidate.faction
		var/facCount = LAZYLEN(chfac) * LAZYLEN(canfac)

		for(var/C in chfac)
			if(C in canfac)
				helpProb = min(100,helpProb + 25)
				if(helpProb >= 100)
					break

		if(facCount == 1 && helpProb)
			helpProb = 100
	
		if(prob(helpProb) && candidate.takeDelegate(check,FALSE))
			--canBeUsed.len
			candidate.eye_color = "yellow"
			candidate.update_icons()
			
		if(!currentrun.len || MC_TICK_CHECK)	//don't change SS state if it isn't necessary
			return

/datum/controller/subsystem/npcpool/Recover()
	if (istype(SSnpc.botPool_l))
		botPool_l = SSnpc.botPool_l
	if (istype(SSnpc.botPool_l_non))
		botPool_l_non = SSnpc.botPool_l_non