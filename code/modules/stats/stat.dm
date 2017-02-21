/datum/stat
	var/statName = "noname"	//Name of the stat
	var/statDesc = ""		//Description of the stat
	var/statId = ""			//Id of the stat for referencing it
	var/statIcon = ""		//Iconstate of the stat

	var/statBase = 0		//The rolled base stat
	var/statBaseOld = 0		//For rerolls

	var/statNormal = 0 		//The base stat with class and race modifiers

	var/statModified = 0 	//The modified stat from buffs etc etc
	var/statCurr = 100

	var/statMin = 0 // The minimum a stat can reach
	var/statMax = 100 // The maximum a stat can reach

	var/isLimited = FALSE // Toggles depletion on, like hp

	var/totalXP = 0 // total gained XP
	var/xpToLevel = 120 // base XP per level
	var/lvl_up_sound = null

/datum/stat/New(var/name = "error", var/id = "", var/limit=FALSE, var/cur=0, var/min=0, var/max=100, var/staticon = "")
	if(limit)
		isLimited = limit
		statMin = min
	statName = name
	statId = id
	statIcon = staticon

	statBase = cur
	statCurr = statBase

	archive()

//Recalculates the statNormal from the rolled statBase + all race/class modifiers etc
/datum/stat/proc/recalculateBase()
	statNormal = statBase

//Recalculates the modified stat from statNormal and all applied buffs etc
/datum/stat/proc/recalculate()
	statModified = statNormal

//Recalculates the current value the stat is at (for hp and mp etc) and clamps it between statMin and statModified
/datum/stat/proc/recap()
	statModified = statNormal

//Archive the base stat so we can revert to it later
/datum/stat/proc/archive()
	statBaseOld = statBase

/datum/stat/proc/setBaseTo(var/n)
	statBase = n

//Revert the base stat
/datum/stat/proc/revert()
	statBase = statBaseOld

/datum/stat/proc/addxp(var/n, var/client/reciever)
	totalXP += n
	if(totalXP >= xpToLevel)
		change(1)
		reciever << "<text style='text-align: center; vertical-align: middle; font-size: 5;'>\blue Congratulations, you've just advanced a [statName] level.</text>"
		reciever << "<text style='text-align: center; vertical-align: middle; font-size: 4;'>Your [statName] level is now [statCurr].</text>"
		if(lvl_up_sound)
			playsound(get_turf(reciever), lvl_up_sound, 50, 0)
		var/temp_xp = round(statCurr + 300 * 2 ** (statCurr/7)) / 4
		xpToLevel += round(temp_xp)

/datum/stat/proc/change(var/n)
	if(isLimited)
		statCurr += n
		statCurr = Clamp(statCurr,statMin,statModified)
	else
		statModified += n
		statCurr = statModified

/datum/stat/proc/setTo(var/n)
	if(isLimited)
		statCurr = n
		statCurr = Clamp(statCurr,statMin,statModified)
	else
		statModified = n
		statCurr = statModified