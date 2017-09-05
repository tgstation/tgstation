/mob/living/carbon/Move(atom/newloc, direct)
	. = ..(newloc, direct)
	if(stat == SOFT_CRIT) //do our normal nearcrit shit
		visible_message("<span class='danger'>[src] crawls forward!</span>", "<span class='userdanger'>You crawl forward at the expense of some of your strength.</span>")
		apply_damage(1, OXY)
		playsound(loc, pick('hippiestation/sound/effects/bodyscrape-01.ogg', 'hippiestation/sound/effects/bodyscrape-02.ogg'), 20, 1, -4)