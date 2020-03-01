
/**
  * rngod.dm
  *
  * This is a component that gives you some control over fate itself! The idea is that Chaplains and possibly other supernatural roles have this ability by default as they can petition the RNGods
  *		to favor or screw someone over, but it may be expanded from there with different strengths and weaknesses.
  *
  *	This component allows the mob holder to bless and curse other mobs around them. This works by saying (or muttering under your breath) blessings and jinxes along with your target's name,
  *		or just freestyling and saying either "bless" or "damn" without any target, which will pick a random person around you to target! Note that while you can't bless yourself, you
  * 	CAN curse yourself, so be careful with your tongue when you have the ears of the RNGods!
  *
  *	Currently blessing and jinxing only affects your rolls for hitting a vending machine and getting loot/killed, but if there's interest, rolls with degrees of success can be added
  *		in other places as well. It's something I'd like to do!
  *
  * Arguments: none. why, are we really gonna fight over this right now in front of our guests?
  * *
  */
/datum/component/rngod
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// when did we last bless someone?
	var/lastBless
	/// when did we last curse someone?
	var/lastCurse
	/// how long do we have to wait between bless attempts?
	var/blessCooldown = 60 SECONDS
	/// how long do we have to wait between curse attempts?
	var/curseCooldown = 45 SECONDS


/datum/component/rngod/Initialize()


/datum/component/rngod/Destroy(force, silent)
	return ..()

/datum/component/rngod/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_SAY, .proc/checkSpeech)

/datum/component/rngod/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/rngod/proc/checkSpeech(mob/O, list/speech_args)
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	var/mob/target

	if(findtext(message, "damn") && world.time > lastCurse + curseCooldown)
		lastCurse = world.time
		target = findTarget(message)
		if(!target)
			target = pick(viewers(parent)) || parent // if we can't curse anyone else, at least we can curse ourself!

		target.add_fate(-10)

	else if(findtext(message, "bless") && world.time > lastBless + blessCooldown)
		lastBless = world.time // even if we don't get someone, still charge the card
		target = findTarget(message)
		if(!target)
			target = pick(oviewers(parent)) // can't bless yourself like you can damn yourself!

		if(target == parent) // in case we tried explicitly naming ourself
			return

		if(target) // check if there's a target again in case we couldn't find someone in our random nearby person check
			target.add_fate(10)

/**
  * Find a mob in view and a specified radius based on the words in our message. If we name someone specifically along with our bless/curse word, they'll be who we return.
  *
  *	Code lovingly stolen and modified for the worse from adminhelp.dm's keywords_lookup proc
  *
  *
  * Arguments:
  * *msg- The lowercase'd message string we're digging through for names
  * *radius- How far we're looking
  */
/datum/component/rngod/proc/findTarget(msg, radius=3)
	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	for(var/mob/M in view(radius, parent)) // look through all the mobs nearby
		var/list/nameWords = list()
		if(!M.mind)
			continue

		for(var/string in splittext(lowertext(M.real_name), " "))
			nameWords += string
		for(var/string in splittext(lowertext(M.name), " "))
			nameWords += string

		for(var/string in nameWords)
			if(string in msglist)
				return M

