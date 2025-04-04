#define PERSONALITY_TO_OTHER_PEOPLE "others"
#define PERSONALITY_TO_INDIVIDUALS "individuals"
#define PERSONALITY_TO_ART "art"
#define PERSONALITY_TO_MONEY "money"
#define PERSONALITY_TO_FEAR "fear"
#define PERSONALITY_TO_WORK "work"
#define PERSONALITY_TO_EXERCISE "exercise"
#define PERSONALITY_TO_SMALL_GROUPS "groups"
#define PERSONALITY_TO_LARGE_GROUPS "large groups"
#define PERSONALITY_TO_HUMANITY "humanity"
#define PERSONALITY_TO_WHIMSY "whimsy"
#define PERSONALITY_TO_HUGS "hugs"
#define PERSONALITY_TO_DRINKING "drinking"
#define PERSONALITY_TO_RISK "risk"
#define PERSONALITY_TO_SUCCESS "success"
#define PERSONALITY_TO_ROMANCE "romance"
#define PERSONALITY_TO_FOOD "food"
#define PERSONALITY_TO_AUTHORITY "authority"
#define PERSONALITY_TO_CENTCOM "centcom"
#define PERSONALITY_TO_HOPE "hope"
#define PERSONALITY_DECISION_MAKING "decision making"
#define PERSONALITY_OTHER_PEOPLE "other people"
#define PERSONALITY_FORTITUDE "fortitude"

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
	/// Optional: A list of categories this personality belongs to.
	/// This is used to determine what personalities are (in)compatible with each other.
	var/list/categories

/// Called when applying this personality to a mob.
/datum/personality/proc/apply_to_mob(mob/living/who)
	return

/// Called when removing this personality from a mob.
/datum/personality/proc/remove_from_mob(mob/living/who)
	return

/datum/personality/callous
	name = "Callous"
	desc = "I don't care much about what happens to other people."
	pos_gameplay_desc = "Likes seeing other people in duress"
	neg_gameplay_desc = "Dislikes helping people"
	categories = list(
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/friendly
	name = "Friendly"
	desc = "I like giving a helping hand to those in need."
	pos_gameplay_desc = "Likes helping people, and gives better hugs"
	neg_gameplay_desc = "Dislikes seeing other people in duress"
	categories = list(
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_HUGS,
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/emphatic
	name = "Empathic"
	desc = "Other people's feelings are important to me."
	pos_gameplay_desc = "Likes seeing other people happy"
	neg_gameplay_desc = "Dislikes seeing other people sad"
	categories = list(
		PERSONALITY_TO_HUMANITY,
		PERSONALITY_DECISION_MAKING,
	)

/datum/personality/misanthropic
	name = "Misanthropic"
	desc = "We should have never entered the stars."
	pos_gameplay_desc = "Likes seeing other people sad"
	neg_gameplay_desc = "Dislikes seeing other people happy"
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
		PERSONALITY_TO_HUMANITY,
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_LARGE_GROUPS,
	)

/datum/personality/judgemental
	name = "Judgemental"
	desc = "What is wrong with these people?"
	pos_gameplay_desc = "Likes it when people do things you like"
	neg_gameplay_desc = "Dislikes it when people do things you dislike"
	categories = list(
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/analytical
	name = "Analytical"
	desc = "When it comes to making decisions, I tend to be more impersonal."
	neut_gameplay_desc = "Prefers working in less social environments, such as research or engineering"
	categories = list(
		PERSONALITY_DECISION_MAKING,
	)

/datum/personality/impulsive
	name = "Impulsive"
	desc = "I'm better making stuff up as I go along."
	neut_gameplay_desc = "Prefers working in more social environments, such as the bar or medical"
	categories = list(
		PERSONALITY_DECISION_MAKING,
	)

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
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
	)

/datum/personality/extrovert
	name = "Extroverted"
	desc = "I prefer to be surrounded by people, having a drink at the Bar."
	pos_gameplay_desc = "Likes being in the bar"
	neg_gameplay_desc = "Dislikes being alone"
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
		PERSONALITY_TO_LARGE_GROUPS,
	)

/datum/personality/resilient
	name = "Resilient"
	desc = "It's whatever. I can take it."
	pos_gameplay_desc = "Negative moodlets expire faster"
	categories = list(
		PERSONALITY_FORTITUDE,
	)

/datum/personality/brooding
	name = "Brooding"
	desc = "Everything gets to me and I can't help but think about it."
	neg_gameplay_desc = "Negative moodlets last longer, postive moodlets expire faster"
	categories = list(
		PERSONALITY_FORTITUDE,
	)

/datum/personality/brave
	name = "Brave"
	desc = "It'll take a lot more than a little blood to scare me."
	pos_gameplay_desc = "Accumulate fear slower, and moodlets related to fear are weaker"
	categories = list(
		PERSONALITY_TO_FEAR,
	)

/datum/personality/cowardly
	name = "Cowardly"
	desc = "Everything is a danger around here! Even the air!"
	neg_gameplay_desc = "Accumulate fear faster, and moodlets related to fear are stronger"
	categories = list(
		PERSONALITY_TO_FEAR,
	)

/datum/personality/lazy
	name = "Lazy"
	desc = "When given the choice, I'd rather do nothing."
	pos_gameplay_desc = "Happier out of your department - such as in the bar or recreation room"
	neg_gameplay_desc = "Unhappy working in your department or exercising"
	categories = list(
		PERSONALITY_TO_WORK,
		PERSONALITY_TO_EXERCISE,
	)

/datum/personality/diligent
	name = "Diligent"
	desc = "Things need to be done, and I'm the one to do them!"
	pos_gameplay_desc = "Happier working in your department"
	neg_gameplay_desc = "Unhappy when slacking off in the bar or recreation room"
	categories = list(
		PERSONALITY_TO_WORK,
	)

/datum/personality/strict
	name = "Industrious"
	desc = "Everyone needs to be working - otherwise we're all wasting our time."
	neg_gameplay_desc = "Dislikes playing games"
	categories = list(
		PERSONALITY_TO_WORK,
	)

/datum/personality/athletic
	name = "Athletic"
	desc = "Can't just sit around all day! Have to keep moving."
	pos_gameplay_desc = "Likes exercising"
	neg_gameplay_desc = "Dislikes being lazy"
	categories = list(
		PERSONALITY_TO_EXERCISE,
	)

/datum/personality/greedy
	name = "Greedy"
	desc = "Everything is mine, all mine!"
	neg_gameplay_desc = "Dislikes giving money to others"
	categories = list(
		PERSONALITY_TO_MONEY,
	)

/datum/personality/whimsical
	name = "Whimsical"
	desc = "I like to do things for the sake of doing them."
	pos_gameplay_desc = "Likes things that are ostensibly pointless"
	categories = list(
		PERSONALITY_TO_WHIMSY,
	)

/datum/personality/spiritual
	name = "Spiritual"
	desc = "I believe in a higher power."
	pos_gameplay_desc = "Likes the Chapel and the Chaplain"

/datum/personality/creative
	name = "Creative"
	desc = "I like expressing myself, especially in a chaotic place like this."
	pos_gameplay_desc = "Likes making art"
	categories = list(
		PERSONALITY_TO_ART,
	)

/datum/personality/unimaginative
	name = "Unimaginative"
	desc = "I'm not good at thinking outside the box. The box is there for a reason."
	neg_gameplay_desc = "Dislikes making, seeing or hearing art"
	categories = list(
		PERSONALITY_TO_ART,
		PERSONALITY_TO_WHIMSY,
	)

/datum/personality/aloof
	name = "Aloof"
	desc = "Why is everyone so touchy? I'd rather be left alone."
	neg_gameplay_desc = "Dislikes hugs"
	categories = list(
		PERSONALITY_TO_HUGS,
	)

/datum/personality/hopeful
	name = "Hopeful"
	desc = "I believe things will always get better."
	pos_gameplay_desc = "Likes seeing good things happen"
	categories = list(
		PERSONALITY_TO_HOPE,
	)

/datum/personality/pessimistic
	name = "Pessimistic"
	desc = "I believe our best days are behind us."
	neg_gameplay_desc = "Seeing bad things happen affects your mood more"
	categories = list(
		PERSONALITY_TO_HOPE,
	)

/datum/personality/prideful
	name = "Prideful"
	desc = "I am proud of who I am."
	pos_gameplay_desc = "Likes success"
	neg_gameplay_desc = "Dislikes failure"
	categories = list(
		PERSONALITY_TO_SUCCESS,
	)

/datum/personality/humble
	name = "Humble"
	desc = "I'm just doing my job."
	neut_gameplay_desc = "Success or failure affects your mood less"
	categories = list(
		PERSONALITY_TO_SUCCESS,
	)

/datum/personality/aromantic
	name = "Aromantic"
	desc = "Romance has no place on the station."
	neg_gameplay_desc = "Dislikes kisses and hugs"
	categories = list(
		PERSONALITY_TO_ROMANCE,
		PERSONALITY_TO_HUGS,
	)

/datum/personality/ascetic
	name = "Ascetic"
	desc = "I don't care much for luxurious foods. It's all fuel for the body."
	pos_gameplay_desc = "Sorrow from eating disliked food is reduced"
	neg_gameplay_desc = "Enjoyment from eating liked food is limited"
	categories = list(
		PERSONALITY_TO_FOOD,
	)

/datum/personality/gourmand
	name = "Gourmand"
	desc = "Food means everything to me."
	pos_gameplay_desc = "Enjoyment from eating liked food is strengthened"
	neg_gameplay_desc = "Sorrow from eating food you dislike is increased, and mediocre food is less enjoyable"
	categories = list(
		PERSONALITY_TO_FOOD,
	)

/datum/personality/authoritarian
	name = "Authoritarian"
	desc = "Order and discipline are the only things keeping this station running."
	pos_gameplay_desc = "Likes being around heads of staff"
	neut_gameplay_desc = "Prefers to work in positions of authority, such as a head of staff or security"
	categories = list(
		PERSONALITY_TO_AUTHORITY,
	)

/datum/personality/egalitarian
	name = "Egalitarian"
	desc = "Everyone should have equal say. We are all in this together."
	neg_gameplay_desc = "Dislikes being around heads of staff"
	categories = list(
		PERSONALITY_TO_AUTHORITY,
	)

/datum/personality/loyalist
	name = "Loyal"
	desc = "I believe in the station and in Central Command, till the very end!"
	pos_gameplay_desc = "Likes company posters and signs"
	categories = list(
		PERSONALITY_TO_CENTCOM
	)

/datum/personality/disillusioned
	name = "Disillusioned"
	desc = "Central Command isn't what it used to be. This isn't what I signed up for."
	neg_gameplay_desc = "Dislikes company posters and signs"
	categories = list(
		PERSONALITY_TO_CENTCOM
	)
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
	categories = list(
		PERSONALITY_TO_FEAR,
		PERSONALITY_TO_SMALL_GROUPS,
	)

/datum/personality/teetotal
	name = "Teetotaler"
	desc = "Alcohol isn't for me."
	neg_gameplay_desc = "Dislikes drinking alcohol"
	categories = list(
		PERSONALITY_TO_DRINKING,
	)

/datum/personality/bibulous
	name = "Bibulous"
	desc = "I'll always go for another round of drinks!"
	pos_gameplay_desc = "Fulfillment from drinking lasts longer, even after you are no longer drunk"
	categories = list(
		PERSONALITY_TO_DRINKING,
	)

/datum/personality/reckless
	name = "Reckless"
	desc = "What is life without a little danger?"
	pos_gameplay_desc = "Likes doing dangerous things"
	categories = list(
		PERSONALITY_TO_RISK,
	)

/datum/personality/cautious
	name = "Cautious"
	desc = "Risks are foolish on a station as deadly as this."
	neg_gameplay_desc = "Dislikes doing dangerous things"
	categories = list(
		PERSONALITY_TO_RISK,
	)

/datum/personality/gambler
	name = "Gambler"
	desc = "Throwing the dice is my favorite pastime."
	pos_gameplay_desc = "Likes gambling and card games, and content with losing when gambling"
	categories = list(
		PERSONALITY_TO_MONEY,
	)
