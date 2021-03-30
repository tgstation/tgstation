#define AFK_THEFT_MESSAGE 1
#define AFK_THEFT_TIME 2

/mob/living/carbon/human/Login()
	. = ..()
	testing("login")
	if(!LAZYLEN(afk_thefts))
		return

	to_chat(src, "<span class='info'>*---------*</span")
	to_chat(src, "<span class='userdanger'>As you snap back to consciousness, you recall the following...</span")

	for(var/i in afk_thefts)
		var/theft_message = afk_thefts[i][AFK_THEFT_MESSAGE]
		var/time_since = world.time - afk_thefts[i][AFK_THEFT_TIME]
		to_chat(src, "\t</span class='danger'><b>[theft_message] [DisplayTimeText(time_since)] ago.</b></span>")

	if(LAZYLEN(afk_thefts) >= 9)
		to_chat(src, "<span class='notice'>There may have been more, but ")
