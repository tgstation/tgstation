GLOBAL_DATUM_INIT(personality_controller, /datum/personality_controller, new /datum/personality_controller())

/datum/personality_controller
	var/list/incompatibilities = list(
		list(
			/datum/personality/callous,
			/datum/personality/friendly,
		),
		list(
			/datum/personality/analytical,
			/datum/personality/impulsive,
		),
		list(
			/datum/personality/introvert,
			/datum/personality/extrovert,
		),
		list(
			/datum/personality/teetotal,
			/datum/personality/bibulous,
		),
		list(
			/datum/personality/gourmand,
			/datum/personality/ascetic,
		),
		list(
			/datum/personality/authoritarian,
			/datum/personality/egalitarian,
		),
		list(
			/datum/personality/loyalist,
			/datum/personality/disillusioned,
		),
		list(
			/datum/personality/hopeful,
			/datum/personality/pessimistic,
		),
		list(
			/datum/personality/friendly,
			/datum/personality/misanthropic,
		),
		list(
			/datum/personality/misanthropic,
			/datum/personality/extrovert,
			/datum/personality/emphatic,
		),
		list(
			/datum/personality/aloof,
			/datum/personality/friendly,
			/datum/personality/aromantic,
		),
		list(
			/datum/personality/brave,
			/datum/personality/cowardly,
		),
		list(
			/datum/personality/brave,
			/datum/personality/paranoid,
		),
		list(
			/datum/personality/lazy,
			/datum/personality/diligent,
		),
		list(
			/datum/personality/lazy,
			/datum/personality/athletic,
		),
		list(
			/datum/personality/brooding,
			/datum/personality/resilient,
		),
		list(
			/datum/personality/reckless,
			/datum/personality/cautious,
		),
		list(
			/datum/personality/lazy,
			/datum/personality/industrious,
		),
		list(
			/datum/personality/creative,
			/datum/personality/unimaginative,
		),
		list(
			/datum/personality/pessimistic,
			/datum/personality/hopeful,
		),
		list(
			/datum/personality/humble,
			/datum/personality/prideful,
		),
		list(
			/datum/personality/erudite,
			/datum/personality/uneducated,
		)
	)
	var/list/personalities

/datum/personality_controller/New()
	personalities = list()
	for(var/personality_type in subtypesof(/datum/personality))
		personalities[personality_type] = new  personality_type()

/// Helper to check if the new personality type is incompatible with the passed list of personality types
/datum/personality_controller/proc/is_incompatible(list/personality_types, new_personality_type)
	if(!length(personality_types))
		return FALSE
	for(var/incompatibility in incompatibilities)
		if(!(new_personality_type in incompatibility))
			continue
		for(var/contrasting_type in personality_types)
			if(contrasting_type == new_personality_type) // You're not incompatible with yourself
				continue
			if(contrasting_type in incompatibility)
				return TRUE
	return FALSE

/datum/personality
	/// Required: Name of the personality
	var/name
	/// Required: Description of the personality.
	/// Phrased to be "In character" - i.e. "I like to help people!", rather than OOC - "When helping people, I get a positive moodlet."
	var/desc
	/// Optional: What positive effects this personality has on gameplay.
	var/pos_gameplay_desc
	/// Optional: What negative effects this personality has on gameplay.
	var/neg_gameplay_desc
	/// Optional: What neutral effects this personality has on gameplay.
	var/neut_gameplay_desc

/// Called when applying this personality to a mob.
/datum/personality/proc/apply_to_mob(mob/living/who)
	return

/// Called when removing this personality from a mob.
/datum/personality/proc/remove_from_mob(mob/living/who)
	return

/datum/personality/callous
	name = "Callous"
	desc = "I don't care much about what happens to other people."
	pos_gameplay_desc = "Does not mind seeing death"
	neg_gameplay_desc = "Prefers not to help people"

/datum/personality/friendly
	name = "Friendly"
	desc = "I like giving a hand to those in need."
	pos_gameplay_desc = "Gives better hugs"
	neg_gameplay_desc = "Seeing death affects your mood more"

/datum/personality/emphatic
	name = "Empathic"
	desc = "Other people's feelings are important to me."
	pos_gameplay_desc = "Likes seeing other people happy"
	neg_gameplay_desc = "Dislikes seeing other people sad"

/datum/personality/misanthropic
	name = "Misanthropic"
	desc = "We should have never entered the stars."
	pos_gameplay_desc = "Likes seeing other people sad"
	neg_gameplay_desc = "Dislikes seeing other people happy"

/datum/personality/judgemental
	name = "Judgemental"
	desc = "What is wrong with these people?"
	pos_gameplay_desc = "Likes it when people do things you like"
	neg_gameplay_desc = "Dislikes it when people do things you dislike"

/datum/personality/analytical
	name = "Analytical"
	desc = "When it comes to making decisions, I tend to be more impersonal."
	neut_gameplay_desc = "Prefers working in less social environments, such as research or engineering"

/datum/personality/impulsive
	name = "Impulsive"
	desc = "I'm better making stuff up as I go along."
	neut_gameplay_desc = "Prefers working in more social environments, such as the bar or medical"

/*
/datum/personality/morbid
	name = "Morbid"
	desc = "I am interested in more macabre things."
	pos_gameplay_desc = "You receive positive moodlets from abnormal and macabre things, such as death and blood."

/datum/personality/evil
	name = "Evil"
	desc = "I'm a bad person."
	pos_gameplay_desc = "You receive positive moodlets from hurting people, and negative moodlets from helping them."
	categories = list(
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_HUMANITY,
	)
*/
/datum/personality/snob
	name = "Snobbish"
	desc = "I expect only the best out of this station - anything less is unacceptable!"
	neut_gameplay_desc = "Room quality affects your mood"

/datum/personality/apathetic
	name = "Apathetic"
	desc = "I don't care about much. Not the good, nor the bad, and certainly not the ugly."
	neut_gameplay_desc = "All moodlets affect you less"

/datum/personality/introvert
	name = "Introverted"
	desc = "I prefer to be alone, reading or painting in the library."
	pos_gameplay_desc = "Likes being in the library"
	neg_gameplay_desc = "Dislikes large groups"

/datum/personality/extrovert
	name = "Extroverted"
	desc = "I prefer to be surrounded by people, having a drink at the Bar."
	pos_gameplay_desc = "Likes being in the bar"
	neg_gameplay_desc = "Dislikes being alone"

/datum/personality/resilient
	name = "Resilient"
	desc = "It's whatever. I can take it."
	pos_gameplay_desc = "Negative moodlets expire faster"

/datum/personality/brooding
	name = "Brooding"
	desc = "Everything gets to me and I can't help but think about it."
	neg_gameplay_desc = "Negative moodlets last longer, postive moodlets expire faster"

/datum/personality/brave
	name = "Brave"
	desc = "It'll take a lot more than a little blood to scare me."
	pos_gameplay_desc = "Accumulate fear slower, and moodlets related to fear are weaker"

/datum/personality/cowardly
	name = "Cowardly"
	desc = "Everything is a danger around here! Even the air!"
	neg_gameplay_desc = "Accumulate fear faster, and moodlets related to fear are stronger"

/datum/personality/lazy
	name = "Lazy"
	desc = "When given the choice, I'd rather do nothing."
	pos_gameplay_desc = "Happier out of your department - such as in the bar or recreation room"
	neg_gameplay_desc = "Unhappy working in your department or exercising"

/datum/personality/diligent
	name = "Diligent"
	desc = "Things need to be done, and I'm the one to do them!"
	pos_gameplay_desc = "Happier working in your department"
	neg_gameplay_desc = "Unhappy when slacking off in the bar or recreation room"

/datum/personality/industrious
	name = "Industrious"
	desc = "Everyone needs to be working - otherwise we're all wasting our time."
	neg_gameplay_desc = "Dislikes playing games"

/datum/personality/athletic
	name = "Athletic"
	desc = "Can't just sit around all day! Have to keep moving."
	pos_gameplay_desc = "Likes exercising"
	neg_gameplay_desc = "Dislikes being lazy"

/datum/personality/greedy
	name = "Greedy"
	desc = "Everything is mine, all mine!"
	neg_gameplay_desc = "Dislikes spending or giving away money"

/datum/personality/whimsical
	name = "Whimsical"
	desc = "This station is too serious sometimes, lighten up!"
	pos_gameplay_desc = "Likes things that are ostensibly pointless"

/datum/personality/spiritual
	name = "Spiritual"
	desc = "I believe in a higher power."
	pos_gameplay_desc = "Likes the Chapel and the Chaplain"
	neg_gameplay_desc = "Dislikes heretical things"

/datum/personality/creative
	name = "Creative"
	desc = "I like expressing myself, especially in a chaotic place like this."
	pos_gameplay_desc = "Likes making art"

/datum/personality/unimaginative
	name = "Unimaginative"
	desc = "I'm not good at thinking outside the box. The box is there for a reason."
	neg_gameplay_desc = "Dislikes making, seeing or hearing art"

/datum/personality/aloof
	name = "Aloof"
	desc = "Why is everyone so touchy? I'd rather be left alone."
	neg_gameplay_desc = "Dislikes hugs"

/datum/personality/hopeful
	name = "Hopeful"
	desc = "I believe things will always get better."
	pos_gameplay_desc = "Likes seeing good things happen"

/datum/personality/pessimistic
	name = "Pessimistic"
	desc = "I believe our best days are behind us."
	neg_gameplay_desc = "Seeing bad things happen affects your mood more"

/datum/personality/prideful
	name = "Prideful"
	desc = "I am proud of who I am."
	pos_gameplay_desc = "Likes success"
	neg_gameplay_desc = "Dislikes failure"

/datum/personality/humble
	name = "Humble"
	desc = "I'm just doing my job."
	neut_gameplay_desc = "Success or failure affects your mood less"

/datum/personality/aromantic
	name = "Aromantic"
	desc = "Romance has no place on the station."
	neg_gameplay_desc = "Dislikes kisses and hugs"

/datum/personality/ascetic
	name = "Ascetic"
	desc = "I don't care much for luxurious foods. It's all fuel for the body."
	pos_gameplay_desc = "Sorrow from eating disliked food is reduced"
	neg_gameplay_desc = "Enjoyment from eating liked food is limited"

/datum/personality/gourmand
	name = "Gourmand"
	desc = "Food means everything to me."
	pos_gameplay_desc = "Enjoyment from eating liked food is strengthened"
	neg_gameplay_desc = "Sorrow from eating food you dislike is increased, and mediocre food is less enjoyable"

/datum/personality/authoritarian
	name = "Authoritarian"
	desc = "Order and discipline are the only things keeping this station running."
	pos_gameplay_desc = "Likes being around heads of staff"
	neut_gameplay_desc = "Prefers to work in positions of authority, such as a head of staff or security"

/datum/personality/egalitarian
	name = "Egalitarian"
	desc = "Everyone should have equal say. We are all in this together."
	neg_gameplay_desc = "Dislikes being around heads of staff"

/datum/personality/loyalist
	name = "Loyal"
	desc = "I believe in the station and in Central Command, till the very end!"
	pos_gameplay_desc = "Likes company posters and signs"

/datum/personality/disillusioned
	name = "Disillusioned"
	desc = "Central Command isn't what it used to be. This isn't what I signed up for."
	neg_gameplay_desc = "Dislikes company posters and signs"
/*
/datum/personality/erratic
	name = "Erratic"
	desc = "My emotions are unpredictable at best."
	gameplay_desc = "Your personality may change at any time, and you may not be able to control it."
*/
/datum/personality/paranoid
	name = "Paranoid"
	desc = "Everyone and everything is out to get me! This place is a deathtrap!"
	pos_gameplay_desc = "Likes being safe, alone, or in moderately-sized groups"
	neg_gameplay_desc = "Dislikes being in groups too large or too small"

/datum/personality/teetotal
	name = "Teetotaler"
	desc = "Alcohol isn't for me."
	neg_gameplay_desc = "Dislikes drinking alcohol"

/datum/personality/bibulous
	name = "Bibulous"
	desc = "I'll always go for another round of drinks!"
	pos_gameplay_desc = "Fulfillment from drinking lasts longer, even after you are no longer drunk"

/datum/personality/reckless
	name = "Reckless"
	desc = "What is life without a little danger?"
	pos_gameplay_desc = "Likes doing dangerous things"

/datum/personality/cautious
	name = "Cautious"
	desc = "Risks are foolish on a station as deadly as this."
	neg_gameplay_desc = "Dislikes doing dangerous things"

/datum/personality/gambler
	name = "Gambler"
	desc = "Throwing the dice is my favorite pastime."
	pos_gameplay_desc = "Likes gambling and card games, and content with losing when gambling"

/datum/personality/erudite
	name = "Erudite"
	desc = "Knowledge is power."
	pos_gameplay_desc = "Likes reading books"

/datum/personality/uneducated
	name = "Uneducated"
	desc = "I don't care much for books."
	neg_gameplay_desc = "Dislikes reading books"
