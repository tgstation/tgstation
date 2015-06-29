/mob/living/simple_animal/slime/verb/Feed()
	set category = "Slime"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."

	if(stat)
		return 0

	var/list/choices = list()
	for(var/mob/living/C in view(1,src))
		if(C!=src && Adjacent(C))
			choices += C

	var/mob/living/M = input(src,"Who do you wish to feed on?") in null|choices
	if(!M) return 0
	if(CanFeedon(M))
		Feedon(M)
		return 1

/mob/living/simple_animal/slime/proc/CanFeedon(var/mob/living/M)
	if(!Adjacent(M))
		return 0

	if(Victim)
		Feedstop()
		return 0

	if(isslime(M))
		src << "<i>I can't latch onto another slime...</i>"
		return 0

	if(docile)
		src << "<i>I'm not hungry anymore...</i>"
		return 0

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return 0

	if(M.stat == DEAD)
		src << "<i>This subject does not have a strong enough life energy...</i>"
		return 0

	for(var/mob/living/simple_animal/slime/met in view())
		if(met.Victim == M && met != src)
			src << "<i>The [met.name] is already feeding on this subject...</i>"
			return 0
	return 1

/mob/living/simple_animal/slime/proc/Feedon(var/mob/living/M)

	src << "<span class='notice'><i>I have latched onto the subject and begun feeding...</i></span>"
	M << "<span class='userdanger'>The [name] has latched onto [M.name]!</span>"

	Victim = M
	src.loc = M.loc
	canmove = 0
	anchored = 1
	var/lastnut = nutrition
	var/fed_succesfully = 0

	while(Victim && Victim == M && Victim.stat != DEAD && stat != DEAD)
		canmove = 0

		if(Adjacent(Victim))
			loc = M.loc

			if(iscarbon(Victim))
				Victim.adjustCloneLoss(rand(5,6))
				Victim.adjustToxLoss(rand(1,2))
				if(Victim.health <= 0)
					Victim.adjustToxLoss(rand(2,4))

				if(prob(15) && Victim.client)
					Victim << "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
					"You feel like you're about to die!", \
					"You feel every part of your body screaming in agony!", \
					"A low, rolling pain passes through your body!", \
					"Your body feels as if it's falling apart!", \
					"You feel extremely weak!", \
					"A sharp, deep pain bathes every inch of your body!")]</span>"

				fed_succesfully = 1

			else if(isanimal(Victim)) //we already know it's a simple_animal from above
				Victim.adjustBruteLoss(is_adult ? rand(7, 15) : rand(4, 12))
				fed_succesfully = 1

			else
				src << "<span class='warning'>[pick("This subject is incompatible", \
				"This subject does not have a life energy", "This subject is empty", \
				"I am not satisified", "I can not feed from this subject", \
				"I do not feel nourished", "This subject is not food")]!</span>"

			if(fed_succesfully)
				add_nutrition(rand(15,30), lastnut)

				//Heal yourself.
				adjustBruteLoss(-10)

				updatehealth()
				if(Victim)
					Victim.updatehealth()

			sleep(rand(15,45))

		else
			break

	canmove = 1
	anchored = 0


	if(M && M.stat == DEAD)
		if(!client)
			if(Victim && !rabid && !attacked)
				if(Victim.LAssailant && Victim.LAssailant != Victim)
					if(prob(50))
						if(!(Victim.LAssailant in Friends))
							Friends[Victim.LAssailant] = 1
						else
							++Friends[Victim.LAssailant]

		if(M.client && ishuman(M))
			if(prob(85))
				rabid = 1 // UUUNNBGHHHH GONNA EAT JUUUUUU

		if(client)
			src << "<i>This subject does not have a strong enough life energy anymore...</i>"

	else if(client)
		src << "<i>I have stopped feeding...</i>"

	Victim = null

/mob/living/simple_animal/slime/proc/Feedstop()
	if(Victim)
		if(Victim.client)
			Victim << "[src] has let go of your head!"
		Victim = null

/mob/living/simple_animal/slime/proc/UpdateFeed(var/mob/M)
	if(Victim)
		if(Victim == M)
			loc = M.loc // simple "attach to head" effect!


/mob/living/simple_animal/slime/verb/Evolve()
	set category = "Slime"
	set desc = "This will let you evolve from baby to adult slime."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return
	if(!is_adult)
		if(amount_grown >= 10)
			is_adult = 1
			maxHealth = 200
			amount_grown = 0
			regenerate_icons()
			name = text("[colour] [is_adult ? "adult" : "baby"] slime ([number])")
		else
			src << "<i>I am not ready to evolve yet...</i>"
	else
		src << "<i>I have already evolved...</i>"

/mob/living/simple_animal/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four Slimes."

	if(stat)
		src << "<i>I must be conscious to do this...</i>"
		return

	if(is_adult)
		if(amount_grown >= 10)
			if(stat)
				src << "<i>I must be conscious to do this...</i>"
				return

			var/list/babies = list()
			var/new_nutrition = round(nutrition * 0.9)
			var/new_powerlevel = round(powerlevel / 4)
			for(var/i=1,i<=4,i++)
				var/mob/living/simple_animal/slime/M = new /mob/living/simple_animal/slime/(loc)
				if(mutation_chance >= 100)
					M.colour = "rainbow"
				else if(prob(mutation_chance))
					M.colour = slime_mutation[rand(1,4)]
				else
					M.colour = colour
				if(ckey)	M.nutrition = new_nutrition //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
				M.powerlevel = new_powerlevel
				if(i != 1) step_away(M,src)
				M.Friends = Friends.Copy()
				babies += M
				M.mutation_chance = Clamp(mutation_chance+(rand(5,-5)),0,100)
				feedback_add_details("slime_babies_born","slimebirth_[replacetext(M.colour," ","_")]")

			var/mob/living/simple_animal/slime/new_slime = pick(babies)
			new_slime.a_intent = "harm"
			new_slime.languages = languages
			if(src.mind)
				src.mind.transfer_to(new_slime)
			else
				new_slime.key = src.key
			qdel(src)
		else
			src << "<i>I am not ready to reproduce yet...</i>"
	else
		src << "<i>I am not old enough to reproduce yet...</i>"