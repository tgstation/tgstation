//Defines don't work correctly here because FUCK BYOND ARGH
//#define effectTypeMutantRace 1
//#define effectTypeDisability 2
//#define effectTypePower 3
//SO INSTEAD , GLOBAL VARS. GEE THANKS BYOND.
var/const/effectTypeMutantRace = 1
var/const/effectTypeDisability = 2
var/const/effectTypePower = 3

/datum/bioEffect
	var/name = "" //Name of the effect.
	var/id = ""   //Internal ID of the effect.
	var/desc = "" //Visible description of the effect.

	var/effectType = effectTypeDisability //Used to categorize effects. Mostly used for MutantRaces to prevent the mob from getting more than one.

	var/isBad = 0         //Is this a bad effect? Used to determine which effects to use for certain things (radiation etc).

	var/probability = 100 //The probability that this will be selected when building the effect pool. Works like the weights in pick()
	var/blockCount = 2    //Amount of blocks generated. More will make this take longer to activate.
	var/blockGaps = 2     //Amount of gaps in the sequence. More will make this more difficult to activate since it will require more guessing or cross-referencing.
	var/lockedGaps = 0    //How many base pairs in this sequence will need unlocking
	var/lockedDiff = 2    //How many characters in the code?
	var/lockedTries = 3   //How many attempts before it rescrambles?
	var/list/lockedChars = list("G","C") // How many different characters are used

	var/isHidden = 0
	// 0 = Will occur in gene pools, can be seen and manipulated by scanner
	// 1 = Won't occur in gene pools, can't be seen or manipulated by scanner
	// -1 = Won't occur in gene pools, can be seen but not manipulated by scanner
	var/list/mob_exclusion = list() // this bio-effect won't occur in the pools of mob types in this list
	var/mob_exclusive = null // bio-effect will only occur in this mob type

	var/mob/owner = null  //Mob that owns this effect.
	var/datum/bioHolder/holder = null //Holder that contains this effect.

	var/msgGain = "" //Message shown when effect is added.
	var/msgLose = "" //Message shown when effect is removed.

	var/timeLeft = -1//Time left for temporary effects.

	var/variant = 1  //For effects with different variants.
	var/cooldown = 0 //For effects that come with verbs
	var/can_reclaim = 1 // Can this gene be turned into mats with the reclaimer?
	var/can_scramble = 1 // Can this gene be scrambled with the emitter?
	var/can_copy = 1 //Is this gene copied over on bioHolder transfer (i.e. cloning?)
	var/can_research = 1 // If zero, it must be researched via brute force
	var/can_make_injector = 1 // Guess.
	var/req_mut_research = null // If set, need to research the mutation before you can do anything w/ this one
	var/reclaim_mats = 10 // Materials returned when this gene is reclaimed
	var/reclaim_fail = 5 // Chance % for a reclamation of this gene to fail

	var/datum/dnaBlocks/dnaBlocks = null

	var/data = null //Should be used to hold custom user data or it might not be copied correctly with injectors and all these things.

	New()
		dnaBlocks = new/datum/dnaBlocks(src)
		return ..()

	proc/OnAdd()     //Called when the effect is added.
		return

	proc/OnRemove()  //Called when the effect is removed.
		return

	proc/OnMobDraw() //Called when the overlays for the mob are drawn.
		return

	proc/OnLife()    //Called when the life proc of the mob is called.
		return

	proc/GetCopy()   //Gets a copy of this effect. Used to build local effect pool from global instance list. Please don't use this for anything else as it might not work as you think it should.
		var/datum/bioEffect/E = new src.type()
		E.dnaBlocks.blockList = src.dnaBlocks.blockList //Since we assume that the effect being copied is the one in the global pool we copy a REFERENCE to its correct sequence into the new instance.
		return E

/datum/dnaBlocks
	var/datum/bioEffect/owner = null
	var/list/blockList = new/list() //List of CORRECT blocks for this mutation. This is global and should not be modified since it represents the correct solution.
	var/list/blockListCurr = new/list() // List of CURRENT blocks for this mutation. This is local and represents the research people are doing.

	New(var/holder)
		owner = holder
		return ..()

	proc/sequenceCorrect()
		if(blockList.len != blockListCurr.len) return 0 //Things went completely and entirely wrong and everything is broken HALP. Some dickwad probably messed with the global sequence.
		for(var/i=0, i < blockList.len, i++)
			var/datum/basePair/correct = blockList[i+1]
			var/datum/basePair/current = blockListCurr[i+1]
			if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
				return 0
		return 1

	proc/pairCorrect(var/pair_index)
		if(blockList.len != blockListCurr.len || !pair_index)
			return 0
		var/datum/basePair/correct = blockList[pair_index]
		var/datum/basePair/current = blockListCurr[pair_index]
		if(correct.bpp1 != current.bpp1 || correct.bpp2 != current.bpp2) //NOPE
			return 0
		return 1

	proc/ModBlocks() //Gets the normal sequence for this mutation and then "corrupts" it locally.
		for(var/datum/basePair/bp in blockList)
			var/datum/basePair/bpNew = new()
			bpNew.bpp1 = bp.bpp1
			bpNew.bpp2 = bp.bpp2
			blockListCurr.Add(bpNew)

		for(var/datum/basePair/bp in blockListCurr)
			if(prob(33))
				if(prob(50))
					bp.bpp1 = "X"
				else
					bp.bpp2 = "X"

		var/list/gapList = new/list() //Make sure you don't have more gaps than basepairs or youll get an error. But at that point the mutation would be unsolvable.

		for(var/i=0, i<owner.blockGaps, i++)
			var/datum/basePair/bp = pick(blockListCurr - gapList)
			gapList.Add(bp)
			bp.bpp1 = "X"
			bp.bpp2 = "X"

		for(var/i=0, i<owner.lockedGaps, i++)
			var/datum/basePair/bp = pick(blockListCurr - gapList)
			gapList.Add(bp)

			bp.lockcode = ""
			for (var/c = owner.lockedDiff, c > 0, c--)
				bp.lockcode += pick(owner.lockedChars)
			bp.locktries = owner.lockedTries

			var/diff = 1
			if (owner.req_mut_research)
				diff = 0
			else
				var/difficulty = round((owner.lockedDiff ** owner.lockedChars.len) / owner.lockedTries)
				switch(difficulty)
					if(11 to 20) diff = 2
					if(21 to 30) diff = 3
					if(31 to 50) diff = 4
					if(51 to INFINITY) diff = 5

			bp.bpp1 = "Unk[diff]"
			bp.bpp2 = "Unk[diff]"
			bp.marker = "locked"

		return sequenceCorrect()

	proc/GenerateBlocks() //Generate DNA blocks. This sequence will be used globally.
		for(var/i=0, i < owner.blockCount, i++)
			for(var/a=0, a < 4, a++) //4 pairs per block.
				var/S = pick("G", "T", "C" , "A")
				var/datum/basePair/B = new()
				B.bpp1 = S
				switch(S)
					if("G")
						B.bpp2 = "C"
					if("C")
						B.bpp2 = "G"
					if("T")
						B.bpp2 = "A"
					if("A")
						B.bpp2 = "T"
				blockList.Add(B)
		return

/datum/basePair
	var/bpp1 = ""
	var/bpp2 = ""
	var/marker = "green"
	var/lockcode = ""
	var/locktries = 0