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
#define PERSONALITY_FORTITUDE "fortitude"

/datum/personality
	var/name
	var/desc
	var/gameplay_desc
	var/list/categories

/datum/personality/proc/apply_to_mob(mob/living/who)
	return

/datum/personality/proc/remove_from_mob(mob/living/who)
	return

/datum/personality/callous
	name = "Callous"
	desc = "I don't care much about what happens to other people."
	gameplay_desc = "You receieve no positive moodlets for helping people, and no negative moodlets from seeing people in duress."
	categories = list(
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/friendly
	name = "Friendly"
	desc = "I like to help people!"
	gameplay_desc = "You receive positive moodlets from helping people, and negative moodlets from hurting them."
	categories = list(
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_HUGS,
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/emphatic
	name = "Empathic"
	desc = "I can feel what other people are feeling."
	gameplay_desc = "Seeing other people happy makes you happy, and seeing other people sad makes you sad."
	categories = list(
		PERSONALITY_TO_HUMANITY,
		PERSONALITY_DECISION_MAKING,
	)

/datum/personality/misanthropic
	name = "Misanthropic"
	desc = "I don't like people."
	gameplay_desc = "Seeing other people happy makes you sad, and seeing other people sad makes you happy."
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
		PERSONALITY_TO_HUMANITY,
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_LARGE_GROUPS,
	)

/datum/personality/judgemental
	name = "Judgemental"
	desc = "What is wrong with these people?"
	gameplay_desc = "Seeing other people work towards their own interests gives you a positive moodlet. \
		Seeing other people work against their own interests gives you a negative moodlet."
	categories = list(
		PERSONALITY_TO_INDIVIDUALS,
	)

/datum/personality/analytical
	name = "Analytical"
	desc = "When it comes to making decisions, I tend to be more impersonal."
	gameplay_desc = "Being level-headed and rational gives you a positive moodlet."
	categories = list(
		PERSONALITY_DECISION_MAKING,
	)
/*
/datum/personality/morbid
	name = "Morbid"
	desc = "I am interested in more macabre things."
	gameplay_desc = "You receive positive moodlets from abnormal and macabre things, such as death and blood."

/datum/personality/evil
	name = "Evil"
	desc = "I'm a bad person."
	gameplay_desc = "You receive positive moodlets from hurting people, and negative moodlets from helping them."
	categories = list(
		PERSONALITY_OTHER_PEOPLE,
		PERSONALITY_TO_HUMANITY,
	)
*/
/datum/personality/snob
	name = "Snobbish"
	desc = "I expect only the best out of this station - anything less is unacceptable!"
	gameplay_desc = "Room quality affects your mood."

/datum/personality/apathetic
	name = "Apathetic"
	desc = "I don't care about much. Not the good, not the bad."
	gameplay_desc = "The strength of all moodlets is reduced by 20%."

/datum/personality/introvert
	name = "Introverted"
	desc = "I prefer to be alone, in quiet places like the station Library."
	gameplay_desc = "You receive a positive moodlet in the library, and negative moodlets from some interactions with other people."
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
	)

/datum/personality/extrovert
	name = "Extroverted"
	desc = "I prefer to be surrounded by people, in places like the station Bar."
	gameplay_desc = "You receive a positive moodlet in the bar, and negative moodlets from some interactions with other people."
	categories = list(
		PERSONALITY_TO_SMALL_GROUPS,
		PERSONALITY_TO_LARGE_GROUPS,
	)

/datum/personality/resilient
	name = "Resilient"
	desc = "I don't let things get to me."
	gameplay_desc = "Your negative moodlets expire faster.
	categories = list(
		PERSONALITY_FORTITUDE,
	)

/datum/personality/brooding
	name = "Brooding"
	desc = "I think about things a lot."
	gameplay_desc = "Your negative moodlets last longer, and your postive moodlets expire faster."
	categories = list(
		PERSONALITY_FORTITUDE,
	)

/datum/personality/brave
	name = "Brave"
	desc = "I don't fear anything."
	gameplay_desc = "You fear less, and moodlets related to fear are less powerful."
	categories = list(
		PERSONALITY_TO_FEAR,
	)

/datum/personality/cowardly
	name = "Cowardly"
	desc = "Everything is a danger around here."
	gameplay_desc = "You fear more, and moodlets related to fear are more powerful."
	categories = list(
		PERSONALITY_TO_FEAR,
	)

/datum/personality/lazy
	name = "Lazy"
	desc = "I don't like to do much."
	gameplay_desc = "You receive negative moodlets from doing things, and positive moodlets from doing nothing."
	categories = list(
		PERSONALITY_TO_WORK,
		PERSONALITY_TO_EXERCISE,
	)

/datum/personality/diligent
	name = "Diligent"
	desc = "Things need to be done, and I'm the one to do them!"
	gameplay_desc = "You receive positive moodlets from doing things, and negative moodlets from doing nothing."
	categories = list(
		PERSONALITY_TO_WORK,
	)

/datum/personality/strict
	name = "Industrious"
	desc = "Everyone needs to be working - otherwise we're all wasting our time."
	gameplay_desc = "You receive negative moodlets from playing games."
	categories = list(
		PERSONALITY_TO_WORK,
	)

/datum/personality/athletic
	name = "Athletic"
	desc = "I like to be active."
	gameplay_desc = "You receive positive moodlets from exercising, and negative moodlets from being inactive."
	categories = list(
		PERSONALITY_TO_EXERCISE,
	)

/datum/personality/greedy
	name = "Greedy"
	desc = "Everything is mine!"
	gameplay_desc = "You receive negative moodlets from giving money away."
	categories = list(
		PERSONALITY_TO_MONEY,
	)

/datum/personality/whimsical
	name = "Whimsical"
	desc = "I like to do things for the sake of doing them."
	gameplay_desc = "You receive positive moodlets from doing things that are not useful."
	categories = list(
		PERSONALITY_TO_WHIMSY,
	)

/datum/personality/spiritual
	name = "Spiritual"
	desc = "I believe in a higher power."
	gameplay_desc = "You receive positive moodlets from being around the Chapel or the Chaplain."

/datum/personality/creative
	name = "Creative"
	desc = "I like expressing myself, especially in a place like this."
	gameplay_desc = "You receive positive moodlets from making art."
	categories = list(
		PERSONALITY_TO_ART,
	)

/datum/personality/unimaginative
	name = "Unimaginative"
	desc = "I don't like to think outside the box."
	gameplay_desc = "You receive no positive moodlets from making art, and negative moodlets from seeing or hearing art."
	categories = list(
		PERSONALITY_TO_ART,
		PERSONALITY_TO_WHIMSY,
	)

/datum/personality/aloof
	name = "Aloof"
	desc = "I don't like to get too close to people."
	gameplay_desc = "You receive negative moodlets from being hugged, rather than positive ones."
	categories = list(
		PERSONALITY_TO_HUGS,
	)

/datum/personality/hopeful
	name = "Hopeful"
	desc = "I believe in a better tomorrow."
	gameplay_desc = "You receive positive moodlets from seeing good things happen."
	categories = list(
		PERSONALITY_TO_HOPE,
	)

/datum/personality/pessimistic
	name = "Pessimistic"
	desc = "Things are never going to get better."
	gameplay_desc = "You receive no moodlets from seeing good things happen, and negative moodlets from seeing bad things happen."
	categories = list(
		PERSONALITY_TO_HOPE,
	)

/datum/personality/prideful
	name = "Prideful"
	desc = "I am proud of who I am."
	gameplay_desc = "You receive positive moodlets from success, and negative moodlets from failure."
	categories = list(
		PERSONALITY_TO_SUCCESS,
	)

/datum/personality/humble
	name = "Humble"
	desc = "Success isn't much to me, I'm just doing my job."
	gameplay_desc = "Success or failure doesn't affect your mood as much."
	categories = list(
		PERSONALITY_TO_SUCCESS,
	)

/datum/personality/aromantic
	name = "Aromantic"
	desc = "Romance has no place on the station."
	gameplay_desc = "You receive negative moodlets kisses and hugs."
	categories = list(
		PERSONALITY_TO_ROMANCE,
		PERSONALITY_TO_HUGS,
	)

/datum/personality/ascetic
	name = "Ascetic"
	desc = "I don't care much for luxurious foods."
	gameplay_desc = "Your positive moodlets from eating food are limited to the most basic of foods."
	categories = list(
		PERSONALITY_TO_FOOD,
	)

/datum/personality/gourmand
	name = "Gourmand"
	desc = "Food is everything to me.
	gameplay_desc = "You receive positive moodlets from eating food, but negative moodlets from disliked food are more powerful."
	categories = list(
		PERSONALITY_TO_FOOD,
	)

/datum/personality/authoritarian
	name = "Authoritarian"
	desc = "I believe in a strict hierarchy."
	gameplay_desc = "You receive positive moodlets from being around heads of staff."
	categories = list(
		PERSONALITY_TO_AUTHORITY,
	)

/datum/personality/egalitarian
	name = "Egalitarian"
	desc = "I believe everyone should have equal say."
	gameplay_desc = "You receive negative moodlets from being around heads of staff."
	categories = list(
		PERSONALITY_TO_AUTHORITY,
	)

/datum/personality/loyalist
	name = "Loyalist"
	desc = "I believe in the station and in Central Command, till the end!"
	gameplay_desc = "You receive positive moodlets company posters and signs."
	categories = list(
		PERSONALITY_TO_CENTCOM
	)

/datum/personality/disillusioned
	name = "Disillusioned"
	desc = "Central Command isn't what it used to be - this isn't what I signed up for."
	gameplay_desc = "You receive negative moodlets from company posters and signs."
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
	desc = "Everyone is out to get me! This place is a deathtrap!"
	gameplay_desc = "You receive negative moodlets from being around small groups, and positive moodlets from being alone."
	categories = list(
		PERSONALITY_TO_FEAR,
		PERSONALITY_TO_SMALL_GROUPS,
	)

/datum/personality/teetotal
	name = "Teetotaler"
	desc = "Alcohol isn't for me."
	gameplay_desc = "You receive negative moodlets from drinking alcohol, and positive moodlets from not drinking."
	categories = list(
		PERSONALITY_TO_DRINKING,
	)

/datum/personality/bibulous
	name = "Bibulous"
	desc = "I will always go for another round!"
	gameplay_desc = "Your postive moodlets from drinking last longer, even after you are no longer drunk."
	categories = list(
		PERSONALITY_TO_DRINKING,
	)

/datum/personality/reckless
	name = "Reckless"
	desc = "What is life without a little danger?"
	gameplay_desc = "You receive positive moodlets from doing dangerous things."
	categories = list(
		PERSONALITY_TO_RISK,
	)

/datum/personality/cautious
	name = "Cautious"
	desc = "Risks are foolish on a station as deadly as this."
	gameplay_desc = "You receive negative moodlets from doing dangerous things."
	categories = list(
		PERSONALITY_TO_RISK,
	)
