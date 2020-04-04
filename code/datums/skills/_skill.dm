/datum/skill
	var/name = "Skilling"
	var/title = "Skiller"
	var/desc = "the art of doing things"
	var/modifiers = list(SKILL_SPEED_MODIFIER = list(1, 1, 1, 1, 1, 1, 1)) //Dictionary of modifier type - list of modifiers (indexed by level). 7 entries in each list for all 7 skill levels.
	var/skillcapepath
	var/list/levelUpMessages = list()
	var/list/levelDownMessages = list()

/datum/skill/proc/get_skill_modifier(modifier, level)
	return modifiers[modifier][level+1] //+1 because lists start at 1
/**
  * new: sets up some lists. 
  *
  *Can't happen in the datum's definition because these lists are not constant expressions
  */
/datum/skill/New()
	..()
	levelUpMessages = list("<span class='nicegreen'>I'm starting to figure out what [name] really is!</span>",
	"<span class='nicegreen'>I'm getting a little better at [name]!</span>",
	"<span class='nicegreen'>I'm getting much better at [name]!</span>",
	"<span class='nicegreen'>I feel like I've become quite proficient at [name]!</span>",
	"<span class='nicegreen'>After lots of practice, I've begun to truly understand the intricies \
	 and surprising depth behind [name]. I now condsider myself a master [title].</span>",
	"<span class='nicegreen'>Through incredible determination and effort, I've reached the peak of my [name] abiltities. I'm finally able to consider myself a legendary [title]!</span>" )
	levelDownMessages = list("<span class='nicegreen'>I'm starting to forget what [name] really even is. I need more practice...</span>",
	"<span class='nicegreen'>I'm getting a little worse at [name]. I'll need to keep practicing to get better at it...</span>",
	"<span class='nicegreen'>I'm getting a little worse at [name]...</span>",
	"<span class='nicegreen'>I'm losing my [name] expertise ....</span>",
	"<span class='nicegreen'>I feel like I'm losing my mastery of [name].</span>",
	"<span class='nicegreen'>I feel as though my legendary [name] skills have deteriorated. I'll need more intense training to recover my lost skills.</span>" )

/**
  * level_gained: Gives skill levelup messages to the user
  *
  * Only fires if the xp gain isn't silent, so only really useful for messages.
  * Arguments:
  * * mind - The mind that you'll want to send messages
  * * new_level - The newly gained level. Can check the actual level to give different messages at different levels, see defines in skills.dm
  * * old_level - Similar to the above, but the level you had before levelling up.
  */
/datum/skill/proc/level_gained(var/datum/mind/mind, new_level, old_level)//just for announcements (doesn't go off if the xp gain is silent)
	to_chat(mind.current, levelUpMessages[new_level]) //new_level will be a value from 1 to 6, so we get appropriate message from the 6-element levelUpMessages list
	try_skill_reward(mind, new_level)
/**
  * level_lost: See level_gained, same idea but fires on skill level-down
  */
/datum/skill/proc/level_lost(var/datum/mind/mind, new_level, old_level)
	to_chat(mind.current, levelDownMessages[old_level]) //old_level will be a value from 1 to 6, so we get appropriate message from the 6-element levelUpMessages list

/**
  * try_skill_reward: Checks to see if a user is eligable for a tangible reward for reaching a certain skill level
  *
  * Currently gives the user a special cloak when they reach a legendary level at any given skill
  * Arguments:
  * * mind - The mind that you'll want to send messages and rewards to
  * * new_level - The current level of the user. Used to check if it meets the requirements for a reward
  */
/datum/skill/proc/try_skill_reward(var/datum/mind/mind, new_level)
	if (new_level != SKILL_LEVEL_LEGENDARY)
		return
	if (!ispath(skillcapepath))	
		to_chat(mind.current, "<span class='nicegreen'>My legendary [name] skill is quite impressive, thoguh it seems the Professional [title] Association doesn't have any status symbols to commemorate my abilities with. I should let Centcom know of this travesty, maybe they can do something about it.</span>")
		return
	if (src in mind.skills_leveled_to_legendary)	
		to_chat(mind.current, "<span class='nicegreen'>I have regained my legendary [name] skill. It seems the Professional [title] Association won't send me another status symbol, however.</span>")
		return
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.landingDelay = 150
	pod.explosionSize = list(0,0,0,0)
	to_chat(mind.current, "<span class='nicegreen'>My legendary skill has attracted the attention of the Professional [title] Association. It seems they are sending me a status symbol to commemorate my abilities.</span>")
	var/turf/T = get_turf(mind.current)
	new /obj/effect/DPtarget(T, pod , new skillcapepath(T))
	mind.skills_leveled_to_legendary.Add(src)
