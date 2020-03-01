
/**
  * holy.dm
  *
  * This isn't really a good name for it, I'll pick a more descriptive one later. The idea is that Chaplains and other holy roles have this ability by default as they can petition the RNGods
  *		to favor or screw someone over, but it may be expanded from there with different strengths.
  *
  *	This component allows the mob holder to bless and curse other mobs around them. This works by saying (or muttering under your breath) blessings and jinxes along with your target's name,
  *		or just freestyling and saying either "bless" or "damn" without any target, which will pick a random person around you to target! Note that while you can't bless yourself, you
  * 	CAN curse yourself, so be careful with your tongue when you have the ears of the RNGods!
  *
  *	Currently blessing and jinxing only affects your rolls for hitting a vending machine and getting loot/killed, but if there's interest, rolls with degrees of success can be added
  *		in other places as well. It's something I'd like to do!
  *
  * Arguments:
  * *
  */
/datum/component/holy
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// when did we last bless someone?
	var/lastBless
	/// when did we last curse someone?
	var/lastCurse

	/// how long do we have to wait between bless attempts?
	var/blessCooldown = 60 SECONDS
	/// how long do we have to wait between curse attempts?
	var/curseCooldown = 45 SECONDS


/datum/component/holy/Initialize()

/datum/component/holy/Destroy(force, silent)
	return ..()

/datum/component/holy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_SAY, .proc/checkSpeech)

/datum/component/holy/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/holy/proc/checkSpeech(mob/O, list/speech_args)
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	var/mob/target
	testing("Message: [message]")
	if(findtext(message, "damn") && world.time > lastCurse + curseCooldown)
		target = findTarget(message)
		if(!target)
			target = pick(viewers(parent)) || parent
			testing("No target found: cursing [target]")
		else
			testing("Target found: cursing [target]")
		if(target.mind && target.mind.fate)
			target.mind.fate.curse(parent, 10)
			testing("Cursed [target]")

	else if(findtext(message, "bless") && world.time > lastBless + blessCooldown)
		target = findTarget(message)
		if(!target)
			target = pick(oviewers(parent)) // can't bless yourself like you can damn yourself!
			if(target)
				testing("No target found: blessing [target]")
			else
				testing("No target found: no blessing")
				return
		else
			testing("Target found: blessing [target]")
		if(target.mind && target.mind.fate)
			target.mind.fate.bless(parent, 10)
			testing("Blessed [target]")

/datum/component/holy/proc/findTarget(msg, radius=3)
	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	for(var/mob/M in view(radius, parent)) // look through all the mobs nearby
		var/list/nameWords = list()
		//if(!M.mind || !M.mind.fate)
			//continue
			//indexing += M.mind.name
		for(var/string in splittext(lowertext(M.real_name), " "))
			nameWords += string
		for(var/string in splittext(lowertext(M.name), " "))
			nameWords += string

		for(var/string in nameWords)
			if(string in msglist)
				return M

