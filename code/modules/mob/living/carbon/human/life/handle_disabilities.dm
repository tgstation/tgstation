//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_disabilities()
	if(disabilities & EPILEPSY)
		if((prob(1)) && (paralysis < 1))
			visible_message("<span class='danger'>\The [src] starts having a seizure!</span>", \
							"<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
			Jitter(1000) //Godness

	//If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK))
		if(prob(1) && hallucination < 1)
			hallucination += 20

	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			emote("cough")
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			//Stun(10)
			switch(rand(1, 3))
				if(1)
					emote("twitch")
				if(2 to 3)
					say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")

			var/x_offset_change = rand(-2,2)
			var/y_offset_change = rand(-1,1)

			animate(src, pixel_x = (pixel_x + x_offset_change), pixel_y = (pixel_y + y_offset_change), time = 1)
			animate(pixel_x = (pixel_x - x_offset_change), pixel_y = (pixel_y - y_offset_change), time = 1)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			switch(pick(1,2,3)) //All of those REALLY ought to be variable lists, but that would be too smart I guess
				if(1)
					say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", \
					"without oxigen blob don't evoluate?", \
					"CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", \
					"can u give me [pick("telikesis","halk","eppilapse")]?", \
					"THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", \
					"I WANNA PET TEH monkeyS", "stop grifing me!!!!", \
					"SOTP IT#"))
				if(2)
					say(pick("FUS RO DAH", \
						"fucking 4rries!", \
						"stat me", \
						">my face", \
						"roll it easy!", \
						"waaaaaagh!!!", \
						"red wonz go fasta", \
						"FOR TEH EMPRAH", \
						"lol2cat", \
						"dem dwarfs man, dem dwarfs", \
						"SPESS MAHREENS", \
						"hwee did eet fhor khayosss", \
						"lifelike texture ;_;", \
						"luv can bloooom", \
						"PACKETS!!!", \
						"SARAH HALE DID IT!!!", \
						"Don't tell Chase", \
						"not so tough now huh", \
						"WERE NOT BAY!!", \
						"BLAME HOSHI!!!", \
						"ARRPEE IZ DED!!!", \
						"THERE ALL JUS MEATAFRIENDS!", \
						"SOTP MESING WITH THE ROUNS SHITMAN!!!", \
						"SKELINGTON IS 4 SHITERS!", \
						"MOMMSI R THE WURST SCUM!!", \
						"OMG I SED LAW 2 U FAG MOMIM LAW 2!!!"))
				if(3)
					emote("drool")

	if(species.name == "Tajaran")
		if(prob(1)) //Was 3
			vomit(1) //Hairball

	if(stat != DEAD)
		var/rn = rand(0, 200) //This is fucking retarded, but I'm only doing sanitization, I don't have three months to spare to fix everything
		if(getBrainLoss() >= 5)
			if(0 <= rn && rn <= 3)
				custom_pain("Your head feels numb and painful.")
		if(getBrainLoss() >= 15)
			if(4 <= rn && rn <= 6) if(eye_blurry <= 0)
				to_chat(src, "<span class='warning'>It becomes hard to see for some reason.</span>")
				eye_blurry = 10
		if(getBrainLoss() >= 35)
			if(7 <= rn && rn <= 9) if(hand && get_active_hand())
				to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
				drop_item()
		if(getBrainLoss() >= 50)
			if(10 <= rn && rn <= 12) if(!lying)
				to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
				resting = 1
