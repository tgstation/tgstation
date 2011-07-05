/mob/living/carbon/metroid/verb/Feed()
	set category = "Metroid"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."
	if(Victim)
		Feedstop()
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C!=src && !istype(C,/mob/living/carbon/metroid))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to feed on?") in null|choices
	if(!M) return

	if(istype(M, /mob/living/carbon) && !istype(src, /mob/living/carbon/brain))
		if(!istype(M, /mob/living/carbon/metroid))
			if(stat != 2)
				if(health > -70)

					for(var/mob/living/carbon/metroid/met in view())
						if(met.Victim == M && met != src)
							src << "<i>The [met.name] is already feeding on this subject...</i>"
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



/mob/living/carbon/metroid/proc/Feedon(var/mob/living/carbon/M)
	Victim = M
	src.loc = M.loc
	canmove = 0
	var/lastnut = nutrition
	//if(M.client) M << "\red You legs become paralyzed!"
	if(istype(src, /mob/living/carbon/metroid/adult))
		icon_state = "adult metroid eat"
	else
		icon_state = "baby metroid eat"

	while(Victim && M.health > -70)
		// M.canmove = 0
		canmove = 0
		if(prob(15) && M.client)
			M << "\red [pick("You can feel your body becoming weak!", \
			"You feel like you're about to die!", \
			"You feel every part of your body screaming in agony!", \
			"A low, rolling pain passes through your body!", \
			"Your body feels as if it's falling apart!", \
			"You feel extremely weak!", \
			"A sharp, deep pain bathes every inch of your body!")]"

		Victim.cloneloss += rand(1,10)
		Victim.toxloss += rand(1,2)
		if(Victim.health <= 0)
			Victim.toxloss += rand(2,5)

		if(toxloss > 0)
			toxloss -= 5

		if(oxyloss > 0)
			oxyloss -= 5

		if(bruteloss > 0)
			bruteloss -= 5

		if(fireloss > 0)
			fireloss -= 5

		if(cloneloss > 0)
			cloneloss -= 5

		if(Victim)
			for(var/mob/living/carbon/metroid/Metroid in view(1,M))
				if(Metroid.Victim == M && Metroid != src)
					Metroid.Feedstop()

		if(toxloss<0) toxloss = 0
		if(oxyloss<0) oxyloss = 0
		if(bruteloss<0) bruteloss = 0
		if(fireloss<0) fireloss = 0
		if(cloneloss<0) cloneloss = 0

		nutrition += rand(5,20)
		if(nutrition >= lastnut + 100)
			if(prob(20))
				lastnut = nutrition
				powerlevel++
				if(powerlevel > 10)
					powerlevel = 10

		if(istype(src, /mob/living/carbon/metroid/adult))
			if(nutrition > 1200)
				nutrition = 1200
		else
			if(nutrition > 1000)
				nutrition = 1000

		Victim.updatehealth()
		updatehealth()

		sleep(rand(5,25))


	if(istype(src, /mob/living/carbon/metroid/adult))
		icon_state = "adult metroid"
	else
		icon_state = "baby metroid"

	Victim = null
	canmove = 1

	if(M.health <= -70)
		M.canmove = 0
		if(client) src << "<i>This subject does not have a strong enough life energy anymore...</i>"
	else
		M.canmove = 1

		if(client) src << "<i>I have stopped feeding...</i>"

/mob/living/carbon/metroid/proc/Feedstop()
	if(Victim)
		if(Victim.client) Victim << "[src] has let go of your head!"
		Victim = null

/mob/living/carbon/metroid/proc/UpdateFeed(var/mob/M)
	if(Victim)
		if(Victim == M)
			loc = M.loc // simple "attach to head" effect!


/mob/living/carbon/metroid/verb/Evolve()
	set category = "Metroid"
	set desc = "This will let you evolve from baby to adult metroid."
	if(!istype(src, /mob/living/carbon/metroid/adult))
		if(amount_grown >= 10)
			var/mob/living/carbon/metroid/adult/new_metroid = new /mob/living/carbon/metroid/adult (loc)
			new_metroid.mind_initialize(src)
			new_metroid.key = key
			new_metroid.nutrition = nutrition

			new_metroid.a_intent = "hurt"
			new_metroid << "<B>You are now an adult Metroid.</B>"
			del(src)
		else
			src << "<i>I am not ready to evolve yet...</i>"
	else
		src << "<i>I have already evolved...</i>"

/mob/living/carbon/metroid/verb/Reproduce()
	set category = "Metroid"
	set desc = "This will make you split into a random number of Metroids (usually 2). NOTE: this will KILL you, but you will be transferred into one of the babies."
	if(istype(src, /mob/living/carbon/metroid/adult))
		if(amount_grown >= 10)
			switch(input("Are you absolutely sure you want to reproduce? Your current body will cease to be, but your consciousness will be transferred into a produced metroid.") in list("Yes","No"))
				if("Yes")
					var/number = pick(2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,4)
					var/list/babies = list()
					for(var/i=1,i<=number,i++) // reproduce (has a small chance of producing 3 or 4 offspring)
						var/mob/living/carbon/metroid/M = new/mob/living/carbon/metroid(loc)
						M.nutrition = round(nutrition/number)
						step_away(M,src)
						babies += M


					var/mob/living/carbon/metroid/new_metroid = pick(babies)

					new_metroid.mind_initialize(src)
					new_metroid.key = key

					new_metroid.a_intent = "hurt"
					new_metroid << "<B>You are now a baby Metroid.</B>"
					del(src)
		else
			src << "<i>I am not ready to reproduce yet...</i>"
	else
		src << "<i>I am not old enough to reproduce yet...</i>"




