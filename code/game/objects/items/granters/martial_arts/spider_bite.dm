/obj/item/book/granter/martial/spider_bite
	martial = /datum/martial_art/spiders_bite

	name = "mysterious scroll"
	martial_name = "spider's bite"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	greet = span_sciradio("You have learned the Spider Clan's historic technique, The Spider's Bite. \
		You are now able to kick standing targets who are staggered, potentially disarming them of their weapons. \
		You can also tackle targets with great effectiveness, and have more solid grabs.")
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "sleepingcarp"
	worn_icon_state = "scroll"
	remarks = list(
		"Float like spider silk, sting like a spider's bite.",
		"I must be one with the spider.",
		"I've never seen this language in my life. At least it has pictures.",
		"The Flow of Gravity technique... can I harness the power of gravity?",
		"The Jump and Climb technique... is my body that flexible?",
		"The Many Legged Spider technique... are my kicks really that powerful?",
		"The Wrap in Web technique... I just need to wrap my targets in my arms?",
	)

/obj/item/book/granter/martial/spider_bite/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/spider_bite/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
