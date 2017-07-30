/mob/proc/is_nearcrit()
	if(!ismonkey(src) && !ishuman(src))
		return FALSE
	var/mob/living/carbon/F = src
	if(F.health <= HEALTH_THRESHOLD_CRIT && F.health > HEALTH_THRESHOLD_DEEPCRIT)
		return TRUE
	else
		return FALSE

/mob/living/carbon/proc/update_nearcrit_stat()
	Knockdown(60)
	update_canmove()
	if(prob(15))
		INVOKE_ASYNC(src, .proc/emote, pick("moan", "cough", "groan", "whimper"))

/mob/proc/CheckLivingCrawl()
	if(!isliving(src))
		return
	var/mob/living/L = src
	if(is_nearcrit(L))
		L.visible_message("<span class='danger'>[L] crawls forward!</span>",
		"<span class='userdanger'>You crawl forward at the expense of some of your strength.</span>")
		L.apply_damage(1, OXY)
		playsound(L.loc, pick('hippiestation/sound/effects/bodyscrape-01.ogg', 'hippiestation/sound/effects/bodyscrape-02.ogg'), 20, 1, -4)
	if(L.lying && !is_nearcrit(L))
		playsound(L.loc, pick('hippiestation/sound/effects/bodyscrape-01.ogg', 'hippiestation/sound/effects/bodyscrape-02.ogg'), 20, 1, -4)