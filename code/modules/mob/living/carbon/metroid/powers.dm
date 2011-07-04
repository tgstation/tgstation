/mob/living/carbon/metroid/verb/Feed(mob/M as mob in view(1))

	if(Victim)
		Feedstop()
		return

	if(istype(M, /mob/living/carbon) && !istype(src, /mob/living/carbon/brain))
		if(!istype(M, /mob/living/carbon/metroid))
			if(stat != 2)
				if(health > -50)

					for(var/mob/living/carbon/metroid/met in view())
						if(met.Victim == M && met != src)
							src << "<i>The [M.name] is already feeding on this subject...</i>"
							return
					src << "\blue <i>I have latched onto the subject and begun feeding...</i>"
					M << "\red <b>The [src.name] has latched onto your head!</b>"
					Feedon(M)

				else
					src << "<i>This subject does not have a strong enough life energy...</i>"
			else
				src << "<i>This subject does not have an edible life energy...</i>"
		else
			src << "<i>I must not feed on my brothers...</i>"
	else
		src << "<i>This subject does not have an edible life energy...</i>"



/mob/living/carbon/metroid/proc/Feedon(var/mob/M)
	Victim = M
	src.loc = M.loc
	canmove = 0
	var/lastnut = nutrition
	M << "\red You legs become paralyzed!"

	while(Victim && M.health > -50)
		M.canmove = 0
		if(prob(35) && M.client)
			M << "\red [pick("You can feel your body becoming weak!", \
			"You feel like you're about to die!", \
			"You feel every part of your body screaming in agony!", \
			"A low, rolling pain passes through your body!")]"

		if(istype(M, /mob/living/carbon/human))
			M.cloneloss += rand(5,10)
			if(M.health <= 0)
				M.toxloss += rand(5,10)
		else
			M.oxyloss += rand(10,20)

		nutrition += rand(5,20)
		if(nutrition >= lastnut + 50)
			if(prob(20))
				powerlevel++

		if(istype(src, /mob/living/carbon/metroid/adult))
			if(nutrition > 400)
				nutrition = 400
		else
			if(nutrition > 300)
				nutrition = 300

	Victim = null
	canmove = 1

	if(M.health <= -50)
		M.canmove = 0
		src << "<i>This subject does not have a strong enough life energy anymore...</i>"
	else
		M.canmove = 1

		src << "<i>I have stopped feeding...</i>"

/mob/living/carbon/metroid/proc/Feedstop()
	if(Victim)
		Victim << "[src] has let go of your head!"
		Victim = null


