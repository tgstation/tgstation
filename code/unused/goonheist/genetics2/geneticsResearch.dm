var/datum/geneticsResearchManager/genResearch = new()

/datum/geneticsResearchManager
	var/researchMaterial = 100
	var/max_material = 100
	var/cost_discount = 0 // decimal value for how much is taken off the cost
	var/time_discount = 0 // same but for time to research
	var/mut_research_cost = 20 // how much it costs to research mutations
	var/mut_research_time = 900
	var/injector_cost = 40
	var/debug_mode = 0
	var/list/currentResearch = new/list()

	var/list/researchTree = new/list()
	var/list/researchTreeTiered = new/list()

	var/list/researchedMutations = new/list() //Have to split up this because im DUMB.
	var/list/dna_samples = new/list()

	var/lastTick = 0

	proc/setup()
		researchTree = (typesof(/datum/geneticsResearchEntry) - /datum/geneticsResearchEntry) - /datum/geneticsResearchEntry/mutation

		for(var/entry in researchTree)
			researchTree[entry] = new entry()
			var/datum/geneticsResearchEntry/newEntry = researchTree[entry]

			var/tier = newEntry.tier

			if(researchTreeTiered["[tier]"] == null)
				researchTreeTiered["[tier]"] = new/list()

			researchTreeTiered["[tier]"] += newEntry

		researchTreeTiered = bubblesort(researchTreeTiered)
		return

	proc/isResearched(var/type)
		if(researchTree.Find(type))
			var/datum/geneticsResearchEntry/E = researchTree[type]
			if(E.isResearched == 1) return 1
		return 0

	proc/progress()
		//var/tickDiff = 0
		//if(!lastTick) lastTick = world.time
		//tickDiff = (world.time - lastTick)
		lastTick = world.time

		if(researchMaterial < max_material)
			researchMaterial++ //This is only temporary to regenerate points while this isnt finished yet.

		for(var/datum/geneticsResearchEntry/entry in currentResearch)
			entry.onTick()
			if(entry.finishTime <= lastTick)
				entry.isResearched = 1
				entry.onFinish()
				currentResearch.Remove(entry)
		return

	proc/addResearch(var/datum/D)
		if(istype(D, /datum/bioEffect))
			var/datum/geneticsResearchEntry/mutation/M = new()

			var/final_cost = src.mut_research_cost
			if (genResearch.cost_discount)
				final_cost -= round(final_cost * genResearch.cost_discount)

			if(!src.debug_mode)
				if(final_cost > researchMaterial)
					return 0
				else
					researchMaterial -= final_cost

			var/datum/bioEffect/BE = D

			M.mutationId = BE.id
			//M.name = "[D:name] Research"
			//M.desc = "Further research pertaining the [D:name] mutation."
			// Making it so you can't see what it is until research is completed - ISN
			M.name = "Mutation Research"
			M.desc = "Analysis of a potential mutation."
			M.real_name = "[D:name]"

			var/research_time = src.mut_research_time
			if (genResearch.time_discount)
				research_time *= (1 - genResearch.time_discount)
			if (src.debug_mode)
				research_time = 0
			M.finishTime = world.time + research_time

			currentResearch.Add(M)
			M.isResearched = -1
			M.onBegin()
			return 1

		else if(istype(D, /datum/geneticsResearchEntry))

			var/final_cost = D:researchCost
			if (genResearch.cost_discount)
				final_cost -= round(final_cost * genResearch.cost_discount)

			if(!src.debug_mode)
				if(final_cost > researchMaterial || D:isResearched)
					return 0
				else
					researchMaterial -= final_cost

			var/research_time = D:researchTime
			if (genResearch.time_discount)
				research_time *= (1 - genResearch.time_discount)
			if (src.debug_mode)
				research_time = 0
			D:finishTime = world.time + research_time

			currentResearch.Add(D)
			D:isResearched = -1
			D:onBegin()
			return 1
		return 0

/datum/geneticsResearchEntry
	var/name = "HERF" //Name of the research entry
	var/desc = "DERF" //Description
	var/real_name = "" // What gene is actually being researched
	var/finishTime = "" //Internal. No need to mess with this.
	var/researchTime = "" //How long this takes to research in 1/10ths of a second.
	var/tier = 0 //Tier of research. Tier 0 does not show up in the available research - this is intentional. It is used for "hidden" research.
	var/list/requiredResearch = list() // You need to research everything in this list before this one will show up
	var/list/requiredMutRes = list() // Need to have researched these mutations first
	var/requiredTotalMutRes = 0 // Need to have researched this many mutations total
	var/isResearched = 0 //Has this been researched? I.e. are we done with it? 0 = not researched, 1 = researched, -1 = currently researching.
	var/researchCost = 10 //Cost in research materials for this entry.
	var/hidden = 0 // Is this one accessible by players?
	var/htmlIcon = null

	proc/onFinish()
		for (var/obj/machinery/computer/genetics/C in genetics_computers)
			if (C.tracked_research == src)
				C.tracked_research = null
				break
		return

	proc/onBegin()
		return

	proc/onTick()
		return

	proc/meetsRequirements()
		if(src.isResearched == 1 || src.isResearched == -1)
			return 0

		if(genResearch.debug_mode)
			return 1

		if(src.hidden)
			return 0

		for(var/X in src.requiredResearch) // Have we got the prerequisite researches?
			if(!genResearch.isResearched(X))
				return 0

		for(var/X in src.requiredMutRes) // Do we have the required mutations researched?
			if(!(X in genResearch.researchedMutations))
				return 0

		if (genResearch.researchedMutations.len < src.requiredTotalMutRes) // Do we have the neccecary # of muts researched?
			return 0

		return 1

/datum/geneticsResearchEntry/mutation
	var/mutationId = ""
	var/researchLevelPre = 0

	onBegin()
		researchLevelPre = genResearch.researchedMutations[mutationId]
		genResearch.researchedMutations[mutationId] = -1
		return

	onFinish()
		..()
		genResearch.researchedMutations[mutationId] = researchLevelPre
		if(genResearch.researchedMutations[mutationId])
			if(genResearch.researchedMutations[mutationId] < 3)
				genResearch.researchedMutations[mutationId] += 1
		else
			genResearch.researchedMutations[mutationId] = 1

// TIER ONE

/datum/geneticsResearchEntry/fresearch
	name = "Research Efficiency"
	desc = "Research costs decrease by 10%."
	researchTime = 2000
	researchCost = 30
	tier = 1

	onFinish()
		..()
		genResearch.cost_discount += 0.10

/datum/geneticsResearchEntry/qresearch
	name = "Research Acceleration"
	desc = "Research times decrease by 10%."
	researchTime = 2000
	researchCost = 30
	tier = 1

	onFinish()
		..()
		genResearch.time_discount += 0.10

/datum/geneticsResearchEntry/hairf
	name = "Hair Follicle Research"
	desc = "Unlocks additional Hair-styles."
	researchTime = 2000
	researchCost = 30
	tier = 1

/datum/geneticsResearchEntry/rademitter
	name = "Radiation Emitters"
	desc = "Installs Radiation Emitters in the scanner.<br>This allows you to reroll the pool of potential mutations of a person.<br>Obviously, this will cause severe radiation poisoning that will have to be treated.<br>This can not be used on dead organisms and has a cooldown time of 3 minutes."
	researchTime = 4500
	researchCost = 80
	tier = 1

/datum/geneticsResearchEntry/checker
	name = "Gene Sequence Checker"
	desc = "Installs analysis equipment in the scanner that allows users to check how many base pairs are stable.<br>It has a cooldown of one minute."
	researchTime = 4000
	researchCost = 75
	tier = 1

/datum/geneticsResearchEntry/improvedmutres
	name = "Advanced Mutation Research"
	desc = "Halves the base cost and time of researching a mutation."
	researchTime = 4000
	researchCost = 50
	requiredTotalMutRes = 20
	tier = 1

	onFinish()
		..()
		genResearch.mut_research_cost = 10
		genResearch.mut_research_time = 450

/datum/geneticsResearchEntry/improvedcooldowns
	name = "Biotic Cooling Mechanisms"
	desc = "Applies genetic research to halve the cooldown times for all equipment."
	researchTime = 5000
	researchCost = 150
	requiredMutRes = list("fire_resist","cold_resist","resist_electric")
	tier = 1

// TIER TWO

/datum/geneticsResearchEntry/fresearch_two
	name = "Improved Research Efficiency"
	desc = "Research costs decrease by a further 10%, for a total 20% discount"
	researchTime = 4000
	researchCost = 80
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/fresearch)

	onFinish()
		..()
		genResearch.cost_discount += 0.10

/datum/geneticsResearchEntry/qresearch_two
	name = "Improved Research Acceleration"
	desc = "Research times decrease by a further 10%, for a total of 20% acceleration."
	researchTime = 4000
	researchCost = 80
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/qresearch)

	onFinish()
		..()
		genResearch.time_discount += 0.10

/datum/geneticsResearchEntry/reclaimer
	name = "DNA Reclaimer"
	desc = "Allows unwanted genes to be converted into research materials. It has a two minute cooldown and has a chance to fail depending on what gene is being reclaimed."
	researchTime = 4000
	researchCost = 100
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/checker)

/datum/geneticsResearchEntry/injector
	name = "DNA Injectors"
	desc = "Allows the manufacture of syringes that can insert researched genes into other subjects. Syringes cost 40 materials to manufacture."
	researchTime = 7500
	researchCost = 120
	requiredTotalMutRes = 20
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/checker)

/datum/geneticsResearchEntry/rad_dampers
	name = "Radiation Dampeners"
	desc = "Reduces the amount of harmful radiation caused by Radiation Emitters."
	researchTime = 3000
	researchCost = 80
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/rademitter)

/datum/geneticsResearchEntry/rad_coolant
	name = "Emitter Coolant System"
	desc = "Reduces the amount of time required for Radiation Emitters to cool down."
	researchTime = 4500
	researchCost = 120
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/rademitter)

// TIER THREE

/datum/geneticsResearchEntry/rad_precision
	name = "Precision Radiation Emitters"
	desc = "Upgrades the Radiation Emitters in the scanner so they can target single genes at a time.<br>The gene must have been researched first, and doing this has a longer cooldown and greater irradiation amount than regular emitters."
	researchTime = 6000
	researchCost = 150
	tier = 3
	requiredResearch = list(/datum/geneticsResearchEntry/rad_dampers,/datum/geneticsResearchEntry/rad_coolant)