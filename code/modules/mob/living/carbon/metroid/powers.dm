/mob/living/carbon/metroid/verb/Feed()
	set category = "Roro"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."
	if(Victim)
		Feedstop()
		return

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return

	var/list/choices = list()
	for(var/mob/living/C in view(1,src))
		if(C!=src && !istype(C,/mob/living/carbon/metroid))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to feed on?") in null|choices
	if(!M) return
	if(M in view(1, src))

		if(!istype(src, /mob/living/carbon/brain))
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
	anchored = 1
	var/lastnut = nutrition
	//if(M.client) M << "\red You legs become paralyzed!"
	if(istype(src, /mob/living/carbon/metroid/adult))
		icon_state = "adult roro eat"
	else
		icon_state = "baby roro eat"

	while(Victim && M.health > -70 && stat != 2)
		// M.canmove = 0
		canmove = 0

		if(M in view(1, src))
			loc = M.loc

			if(prob(15) && M.client && istype(M, /mob/living/carbon))
				M << "\red [pick("You can feel your body becoming weak!", \
				"You feel like you're about to die!", \
				"You feel every part of your body screaming in agony!", \
				"A low, rolling pain passes through your body!", \
				"Your body feels as if it's falling apart!", \
				"You feel extremely weak!", \
				"A sharp, deep pain bathes every inch of your body!")]"

			if(istype(M, /mob/living/carbon))
				Victim.adjustCloneLoss(rand(1,10))
				Victim.adjustToxLoss(rand(1,2))
				if(Victim.health <= 0)
					Victim.adjustToxLoss(rand(2,4))

				// Heal yourself
				adjustToxLoss(-10)
				adjustOxyLoss(-10)
				adjustBruteLoss(-10)
				adjustFireLoss(-10)
				adjustCloneLoss(-10)

				if(Victim)
					for(var/mob/living/carbon/metroid/Metroid in view(1,M))
						if(Metroid.Victim == M && Metroid != src)
							Metroid.Feedstop()

				nutrition += rand(10,25)
				if(nutrition >= lastnut + 50)
					if(prob(80))
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

			else
				if(prob(25))
					src << "\red <i>[pick("This subject is incompatable", \
					"This subject does not have a life energy", "This subject is empty", \
					"I am not satisified", "I can not feed from this subject", \
					"I do not feel nourished", "This subject is not food")]...</i>"

			sleep(rand(15,45))

		else
			break

	if(stat == 2)
		if(!istype(src, /mob/living/carbon/metroid/adult))
			icon_state = "baby roro dead"

	else
		if(istype(src, /mob/living/carbon/metroid/adult))
			icon_state = "adult roro"
		else
			icon_state = "baby roro"

	canmove = 1
	anchored = 0

	if(M.health <= -70)
		M.canmove = 0
		if(!client)
			if(Victim && !rabid && !attacked)
				if(Victim.LAssailant && Victim.LAssailant != Victim)
					if(prob(50))
						if(!(Victim.LAssailant in Friends))
							Friends.Add(Victim.LAssailant) // no idea why i was using the |= operator

		if(M.client && istype(src, /mob/living/carbon/human))
			if(prob(85))
				rabid = 1 // UUUNNBGHHHH GONNA EAT JUUUUUU

		if(client) src << "<i>This subject does not have a strong enough life energy anymore...</i>"
	else
		M.canmove = 1

		if(client) src << "<i>I have stopped feeding...</i>"

	Victim = null

/mob/living/carbon/metroid/proc/Feedstop()
	if(Victim)
		if(Victim.client) Victim << "[src] has let go of your head!"
		Victim = null

/mob/living/carbon/metroid/proc/UpdateFeed(var/mob/M)
	if(Victim)
		if(Victim == M)
			loc = M.loc // simple "attach to head" effect!


/mob/living/carbon/metroid/verb/Evolve()
	set category = "Roro"
	set desc = "This will let you evolve from baby to adult metroid."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return
	if(!istype(src, /mob/living/carbon/metroid/adult))
		if(amount_grown >= 10)
			var/mob/living/carbon/metroid/adult/new_metroid = new /mob/living/carbon/metroid/adult(loc)
			new_metroid.nutrition = nutrition
			new_metroid.powerlevel = max(0, powerlevel-1)
			new_metroid.a_intent = "hurt"
			new_metroid.key = key

			new_metroid << "<B>You are now an adult Metroid.</B>"
			del(src)
		else
			src << "<i>I am not ready to evolve yet...</i>"
	else
		src << "<i>I have already evolved...</i>"

/mob/living/carbon/metroid/verb/Reproduce()
	set category = "Roro"
	set desc = "This will make you split into a random number of Metroids (usually 2). NOTE: this will KILL you, but you will be transferred into one of the babies."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return

	if(istype(src, /mob/living/carbon/metroid/adult))
		if(amount_grown >= 10)
			if(input("Are you absolutely sure you want to reproduce? Your current body will cease to be, but your consciousness will be transferred into a produced rorobeast.") in list("Yes","No")=="Yes")
				if(stat)
					src << "<i>I must be conscious to do this...</i>"
					return

				var/list/babies = list()
				var/number = pick(14;2,3,4)
				var/new_nutrition = round(nutrition * 0.9)
				var/new_powerlevel = round(powerlevel / number)
				for(var/i=1,i<=number,i++) // reproduce (has a small chance of producing 3 or 4 offspring)
					var/mob/living/carbon/metroid/M = new/mob/living/carbon/metroid(loc)
					M.nutrition = new_nutrition
					M.powerlevel = new_powerlevel
					if(i != 1) step_away(M,src)
					babies += M

				var/mob/living/carbon/metroid/new_metroid = pick(babies)
				new_metroid.a_intent = "hurt"
				new_metroid.key = key

				new_metroid << "<B>You are now a Rorobeast. Skree!</B>"
				del(src)
		else
			src << "<i>I am not ready to reproduce yet...</i>"
	else
		src << "<i>I am not old enough to reproduce yet...</i>"



/mob/living/carbon/metroid/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Roro"
	if(Victim)	return
	handle_ventcrawl()
