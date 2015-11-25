//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_status_updates()
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON

		//Sobering multiplier.
		//Sober block grants quadruple the alcohol metabolism.
		var/sober_str =! (M_SOBER in mutations) ? 1:4

		updatehealth() //TODO
		if(!in_stasis)
			handle_organs()	//Optimized.
			handle_blood()

		if(health <= config.health_threshold_dead || !has_brain())
			death()
			blinded = 1
			silent = 0
			return 1

		//The analgesic effect wears off slowly
		analgesic = max(0, analgesic - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if((getOxyLoss() > 50) || (config.health_threshold_crit > health))
			Paralyse(3)

			/* Done by handle_breath()
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)*/

		if(hallucination)
			if(hallucination >= 20)
				if(prob(3))
					fake_attack(src)
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!

			if(hallucination<=2)
				hallucination = 0
				halloss = 0
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				qdel(a)

			if(halloss > 100)
				to_chat(src, "<span class='notice'>You're in too much pain to keep going...</span>")
				for(var/mob/O in oviewers(src, null))
					O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
				Paralyse(10)
				setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			handle_dreams()
			adjustHalLoss(-3)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if(prob(2) && health && !hal_crit)
				spawn(0)
					emote("snore")
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)
		//CONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		//Eyes
		if(!species.has_organ["eyes"]) //Presumably if a species has no eyes, they see via something else.
			eye_blind =  0
			blinded =    0
			eye_blurry = 0
		else if(!has_eyes())           //Eyes cut out? Permablind.
			eye_blind =  1
			blinded =    1
			eye_blurry = 1
		else if(sdisabilities & BLIND) //Disabled-blind, doesn't get better on its own
			blinded =    1
		else if(eye_blind)		       //Blindness, heals slowly over time
			eye_blind =  max(eye_blind - 1, 0)
			blinded =    1
		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold)) //Resting your eyes with a blindfold heals blurry eyes faster
			eye_blurry = max(eye_blurry - 3, 0)
			blinded =    1
		else if(eye_blurry)	           //Blurry eyes heal slowly
			eye_blurry = max(eye_blurry - 1, 0)

		//Ears
		if(sdisabilities & DEAF) //Disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(earprot()) //Resting your ears with earmuffs heals ear damage faster
			ear_damage = max(ear_damage - 0.15, 0)
			ear_deaf = max(ear_deaf, 1) //This MUST be above the following else if or deafness cures itself while wearing earmuffs
		else if(ear_deaf) //Deafness, heals slowly over time
			ear_deaf = max(ear_deaf - 1, 0)
		else if(ear_damage < 25) //Ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage - 0.05, 0)

		//Dizziness
		if(dizziness)
			var/client/C = client
			var/pixel_x_diff = 0
			var/pixel_y_diff = 0
			var/temp
			var/saved_dizz = dizziness
			dizziness = max(dizziness - 1, 0)
			if(C)
				var/oldsrc = src
				var/amplitude = dizziness * (sin(dizziness * 0.044 * world.time) + 1) / 70 //This shit is annoying at high strength
				src = null
				spawn(0)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
						sleep(3)
						if(C)
							temp = amplitude * sin(0.008 * saved_dizz * world.time)
							pixel_x_diff += temp
							C.pixel_x += temp
							temp = amplitude * cos(0.008 * saved_dizz * world.time)
							pixel_y_diff += temp
							C.pixel_y += temp
						sleep(3)
						if(C)
							C.pixel_x -= pixel_x_diff
							C.pixel_y -= pixel_y_diff
				src = oldsrc

		//Jitteryness
		if(jitteriness)
			var/amplitude = min(8, (jitteriness/70) + 1)
			var/pixel_x_diff = rand(-amplitude, amplitude)
			var/pixel_y_diff = rand(-amplitude, amplitude)

			spawn()
				animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
				animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

				pixel_x_diff = rand(-amplitude, amplitude)
				pixel_y_diff = rand(-amplitude, amplitude)
				animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
				animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

				pixel_x_diff = rand(-amplitude, amplitude)
				pixel_y_diff = rand(-amplitude, amplitude)
				animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 1, loop = -1)
				animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 1, loop = -1, easing = BOUNCE_EASING)

		//Flying
		if(flying)
			spawn()
				animate(src, pixel_y = pixel_y + 5 , time = 10, loop = 1, easing = SINE_EASING)
			spawn(10)
				if(flying)
					animate(src, pixel_y = pixel_y - 5, time = 10, loop = 1, easing = SINE_EASING)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened - 1,0) //Before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(stuttering)
			stuttering = max(stuttering - 1, 0)
		if(slurring)
			slurring = max(slurring - (1 * sober_str), 0)
		if(silent)
			silent = max(silent - 1, 0)

		if(druggy)
			druggy = max(druggy - 1, 0)
			if(!druggy)
				to_chat(src, "It looks like you are back in Kansas.")
/*
		// Increase germ_level regularly
		if(prob(40))
			germ_level += 1
		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1
*/
	return 1
