/datum/personality/ascetic
	savefile_key = "ascetic"
	name = "Ascetic"
	desc = "I don't care much for luxurious foods - It's all fuel for the body."
	pos_gameplay_desc = "Sorrow from eating disliked food is reduced"
	neg_gameplay_desc = "Enjoyment from eating liked food is limited"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/gourmand
	savefile_key = "gourmand"
	name = "Gourmand"
	desc = "Food means everything to me!"
	pos_gameplay_desc = "Enjoyment from eating liked food is strengthened"
	neg_gameplay_desc = "Sadness from eating food you dislike is increased, and mediocre food is less enjoyable"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/teetotal
	savefile_key = "teetotal"
	name = "Teetotaler"
	desc = "Alcohol isn't for me."
	neg_gameplay_desc = "Dislikes drinking alcohol"
	groups = list(PERSONALITY_GROUP_ALCOHOL)

/datum/personality/bibulous
	savefile_key = "bibulous"
	name = "Bibulous"
	desc = "I'll always go for another round of drinks!"
	pos_gameplay_desc = "Fulfillment from drinking lasts longer, even after you are no longer drunk"
	groups = list(PERSONALITY_GROUP_ALCOHOL)
