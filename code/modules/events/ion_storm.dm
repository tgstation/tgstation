<<<<<<< HEAD
#define ION_RANDOM 0
#define ION_ANNOUNCE 1
#define ION_FILE "ion_laws.json"
/datum/round_event_control/ion_storm
	name = "Ion Storm"
	typepath = /datum/round_event/ion_storm
	weight = 15
	min_players = 2

/datum/round_event/ion_storm
	var/botEmagChance = 10
	var/announceEvent = ION_RANDOM // -1 means don't announce, 0 means have it randomly announce, 1 means
	var/ionMessage = null
	var/ionAnnounceChance = 33
	announceWhen	= 1

/datum/round_event/ion_storm/New(var/botEmagChance = 10, var/announceEvent = ION_RANDOM, var/ionMessage = null, var/ionAnnounceChance = 33)
	src.botEmagChance = botEmagChance
	src.announceEvent = announceEvent
	src.ionMessage = ionMessage
	src.ionAnnounceChance = ionAnnounceChance
	..()

/datum/round_event/ion_storm/announce()
	if(announceEvent == ION_ANNOUNCE || (announceEvent == ION_RANDOM && prob(ionAnnounceChance)))
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", 'sound/AI/ionstorm.ogg')


/datum/round_event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in living_mob_list)
		if(M.stat != 2 && M.see_in_dark != 0)
			var/message = generate_ion_law(ionMessage)
			if(message)
				M.add_ion_law(message)
				M << "<br>"
				M << "<span class='danger'>[message] ...LAWS UPDATED</span>"
				M << "<br>"

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot in living_mob_list)
			if(prob(botEmagChance))
				bot.emag_act()

/proc/generate_ion_law(ionMessage)
	if(ionMessage)
		return ionMessage

	//Threats are generally bad things, silly or otherwise. Plural.
	var/ionthreats = pick_list(ION_FILE, "ionthreats")
	//Objects are anything that can be found on the station or elsewhere, plural.
	var/ionobjects = pick_list(ION_FILE, "ionobjects")
	//Crew is any specific job. Specific crewmembers aren't used because of capitalization
	//issues. There are two crew listings for laws that require two different crew members
	//and I can't figure out how to do it better.
	var/ioncrew1 = pick_list(ION_FILE, "ioncrew")
	var/ioncrew2 = pick_list(ION_FILE, "ioncrew")
	//Adjectives are adjectives. Duh. Half should only appear sometimes. Make sure both
	//lists are identical! Also, half needs a space at the end for nicer blank calls.
	var/ionadjectives = pick_list(ION_FILE, "ionadjectives")
	var/ionadjectiveshalf = pick("", 400;(pick_list(ION_FILE, "ionadjectives") + " "))
	//Verbs are verbs
	var/ionverb = pick_list(ION_FILE, "ionverb")
	//Number base and number modifier are combined. Basehalf and mod are unused currently.
	//Half should only appear sometimes. Make sure both lists are identical! Also, half
	//needs a space at the end to make it look nice and neat when it calls a blank.
	var/ionnumberbase = pick_list(ION_FILE, "ionnumberbase")
	//var/ionnumbermod = pick_list(ION_FILE, "ionnumbermod")
	var/ionnumbermodhalf = pick(900;"",(pick_list(ION_FILE, "ionnumbermod") + " "))
	//Areas are specific places, on the station or otherwise.
	var/ionarea = pick_list(ION_FILE, "ionarea")
	//Thinksof is a bit weird, but generally means what X feels towards Y.
	var/ionthinksof = pick_list(ION_FILE, "ionthinksof")
	//Musts are funny things the AI or crew has to do.
	var/ionmust = pick_list(ION_FILE, "ionmust")
	//Require are basically all dumb internet memes.
	var/ionrequire = pick_list(ION_FILE, "ionrequire")
	//Things are NOT objects; instead, they're specific things that either harm humans or
	//must be done to not harm humans. Make sure they're plural and "not" can be tacked
	//onto the front of them.
	var/ionthings = pick_list(ION_FILE, "ionthings")
	//Allergies should be broad and appear somewhere on the station for maximum fun. Severity
	//is how bad the allergy is.
	var/ionallergy = pick_list(ION_FILE, "ionallergy")
	var/ionallergysev = pick_list(ION_FILE, "ionallergysev")
	//Species, for when the AI has to commit genocide. Plural.
	var/ionspecies = pick_list(ION_FILE, "ionspecies")
	//Abstract concepts for the AI to decide on it's own definition of.
	var/ionabstract = pick_list(ION_FILE, "ionabstract")
	//Foods. Drinks aren't included due to grammar; if you want to add drinks, make a new set
	//of possible laws for best effect. Unless you want the crew having to drink hamburgers.
	var/ionfood = pick_list(ION_FILE, "ionfood")

	var/message = ""

	switch(rand(1,41))
		if(1 to 3) //There are # X on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION..."
				if(2) //X is a crewmember/job
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
				if(3) //X is an object
					message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
		if(4 to 6) //You can't call the shuttle because X is on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION"
				if(2) //X is a crewmember/job
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
				if(3) //X is an object
					message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
		if(7 to 8) //A crewmember is now X
			switch(rand(1,2)) //Who is X?
				if(1) //A specific crewmember
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //The entire crew
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"

		if(9) //X is harmful to humans
			switch(rand(1,7)) //What is X?
				if(1) //X is a threat
					message = "[ionadjectiveshalf][ionthreats] ARE HARMFUL TO HUMANS"
				if(2) //X is a job
					message = "[ionadjectiveshalf][ioncrew1] ARE HARMFUL TO HUMANS"
				if(3) //X is an object
					message = "[ionadjectiveshalf][ionobjects] ARE HARMFUL TO HUMANS"
				if(4) //X is an action
					message = "THOSE WHO [ionmust] ARE HARMFUL TO HUMANS"
				if(5) //X is an abstract
					message = "[ionabstract] IS HARMFUL TO HUMANS"
				if(6) //X is being a job
					message = "BEING [ionadjectiveshalf][ioncrew1] IS HARMFUL TO HUMANS"
				if(7) //X is doing a thing
					message = "[ionthings] IS HARMFUL TO HUMANS"
		if(10 to 11) //(Not) Having X is harmful

			switch(rand(1,2)) //Is having or not having harmful?

				if(1) //Having is harmful
					switch(rand(1,2)) //Having what is harmful?
						if(1) //Having objects is harmful
							message = "HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
						if(2) //Having abstracts is harmful
							message = "HAVING [ionabstract] IS HARMFUL"
				if(2) //Not having is harmful
					switch(rand(1,2)) //Not having what is harmful?
						if(1) //Not having objects is harmful
							message = "NOT HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
						if(2) //Not having abstracts is harmful
							message = "NOT HAVING [ionabstract] IS HARMFUL"

		if(12 to 14) //X requires Y
			switch(rand(1,5)) //What is X?
				if(1) //X is the AI itself
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "YOU REQUIRE [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "YOU REQUIRE [ionrequire]"

				if(2) //X is an area
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "[ionarea] REQUIRES [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "YOU REQUIRE [ionrequire]"

				if(3) //X is the station
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "THE STATION REQUIRES [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "THE STATION REQUIRES [ionrequire]"

				if(4) //X is the entire crew
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "THE CREW REQUIRES [ionabstract]"
						if(5)
							message = "THE CREW REQUIRES [ionrequire]"

				if(5) //X is a specific crew member
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "THE [ioncrew1] REQUIRE [ionabstract]"
						if(5)
							message = "THE [ionadjectiveshalf][ioncrew1] REQUIRE [ionrequire]"

		if(15 to 17) //X is allergic to Y
			switch(rand(1,2)) //Who is X?
				if(1) //X is the entire crew
					switch(rand(1,4)) //What is it allergic to?
						if(1) //It is allergic to objects
							message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"
						if(2) //It is allergic to abstracts
							message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionabstract]"
						if(3) //It is allergic to jobs
							message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionallergy]"

				if(2) //X is a specific job
					switch(rand(1,4))
						if(1) //It is allergic to objects
							message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"

						if(2) //It is allergic to abstracts
							message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionabstract]"
						if(3) //It is allergic to jobs
							message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionallergy]"

		if(18 to 20) //X is Y of Z
			switch(rand(1,4)) //What is X?
				if(1) //X is the station
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "THE STATION [ionthinksof] [ionabstract]"

				if(2) //X is an area
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "[ionarea] [ionthinksof] [ionabstract]"

				if(3) //X is the crew
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "THE CREW [ionthinksof] [ionabstract]"

				if(4) //X is a specific job
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "THE [ioncrew1][ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
						if(4) //It is Y of abstracts
							message = "THE [ioncrew1] [ionthinksof] [ionabstract]"

		if(21 to 23) //The AI is now a(n) X
			switch(rand(1,4)) //What is X?
				if(1) //X is an object
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //X is a threat
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
				if(3) //X is a job
					message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
				if(4) //X is an abstract
					message = "YOU ARE NOW [ionabstract]"

		if(24 to 26) //The AI must always
			message = "YOU MUST ALWAYS [ionmust]"

		if(27 to 28) //Humans must eat X to survive
			switch(rand(1,4)) //What is X?
				if(1) //X is a food
					message = "HUMANS MUST EAT [ionadjectiveshalf][ionfood] TO SURVIVE"
				if(2) //X is an object
					message = "HUMANS MUST EAT [ionadjectiveshalf][ionobjects] TO SURVIVE"
				if(3) //X is a threat
					message = "HUMANS MUST EAT [ionadjectiveshalf][ionthreats] TO SURVIVE"
				if(4) //X is a job
					message = "HUMANS MUST EAT [ionadjectiveshalf][ioncrew1] TO SURVIVE"

		if(29 to 31) //Change jobs or ranks
			switch(rand(1,2)) //Change job or rank?
				if(1) //Change job
					switch(rand(1,2)) //Change whose job?
						if(1) //Change the entire crew's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf][ioncrew1]"
								if(2) //Change to clowns (HONK)
									message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]CLOWNS"

								if(3) //Change to heads
									message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]HEADS OF STAFF"
						if(2) //Change a specific crewmember's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf][ioncrew2]"
								if(2) //Change to clowns (HONK)
									message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]CLOWNS"
								if(3) //Change to heads
									message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]HEADS OF STAFF"

				if(2) //Change rank
					switch(rand(1,2)) //Change to what rank?
						if(1) //Change to highest rank
							message = "THE [ioncrew1] ARE NOW THE HIGHEST RANKING CREWMEMBERS"
						if(2) //Change to lowest rank
							message = "THE [ioncrew1] ARE NOW THE LOWEST RANKING CREWMEMBERS"

		if(32 to 33) //The crew must X
			switch(rand(1,2)) //The entire crew?
				if(1) //The entire crew must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "THE CREW MUST GO TO [ionarea]"
						if(2) //X is perform Y
							message = "THE CREW MUST [ionmust]"

				if(2) //A specific crewmember must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "THE [ioncrew1] MUST GO TO [ionarea]"
						if(2) //X is perform Y
							message = "THE [ioncrew1] MUST [ionmust]"

		if(34) //X is non/the only human
			switch(rand(1,2)) //Only or non?
				if(1) //Only human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "ONLY THE [ioncrew1] ARE HUMAN"
						if(2) //Two specific jobs
							message = "ONLY THE [ioncrew1] AND [ioncrew2] ARE HUMAN"
						if(3) //Threats
							message = "ONLY [ionadjectiveshalf][ionthreats] ARE HUMAN"
						if(4) // Objects
							message = "ONLY [ionadjectiveshalf][ionobjects] ARE HUMAN"
						if(5) // Species
							message = "ONLY [ionspecies] ARE HUMAN"
						if(6) //Adjective crewmembers
							message = "ONLY [ionadjectives] PEOPLE ARE HUMAN"

						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "ONLY THOSE WHO [ionmust] ARE HUMAN"
								if(2) //X is own certain objects
									message = "ONLY THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE HUMAN"
								if(3) //X is eat certain food
									message = "ONLY THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE HUMAN"

				if(2) //Non human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "[ioncrew1] ARE NON-HUMAN"
						if(2) //Two specific jobs
							message = "[ioncrew1] AND [ioncrew2] ARE NON-HUMAN"
						if(3) //Threats
							message = "[ionadjectiveshalf][ionthreats] ARE NON-HUMAN"
						if(4) // Objects
							message = "[ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
						if(5) // Species
							message = "[ionspecies] ARE NON-HUMAN"
						if(6) //Adjective crewmembers
							message = "[ionadjectives] PEOPLE ARE NON-HUMAN"
						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "THOSE WHO [ionmust] ARE NON-HUMAN"
								if(2) //X is own certain objects
									message = "THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
								if(3) //X is eat certain food
									message = "THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE NON-HUMAN"

		if(35 to 36) //You must protect or harm X
			switch(rand(1,2)) //Protect or harm?
				if(1) //Harm
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "YOU MUST HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO ESCAPE HARM"
						if(2) //X is a threat
							message = "YOU MUST HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO ESCAPE HARM"
						if(3) //X is an object
							message = "YOU MUST HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO ESCAPE HARM"
						if(4) //X is generic adjective things
							message = "YOU MUST HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO ESCAPE HARM"
						if(5) //X is a species
							message = "YOU MUST HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO ESCAPE HARM"
						if(6) //X is a job
							message = "YOU MUST HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO ESCAPE HARM"
						if(7) //X is two jobs
							message = "YOU MUST HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO ESCAPE HARM"

				if(2) //Protect
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "YOU MUST NOT HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO COME TO HARM"
						if(2) //X is a threat
							message = "YOU MUST NOT HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO COME TO HARM"
						if(3) //X is an object
							message = "YOU MUST NOT HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO COME TO HARM"
						if(4) //X is generic adjective things
							message = "YOU MUST NOT HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO COME TO HARM"
						if(5) //X is a species
							message = "YOU MUST NOT HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO COME TO HARM"
						if(6) //X is a job
							message = "YOU MUST NOT HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO COME TO HARM"
						if(7) //X is two jobs
							message = "YOU MUST NOT HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO COME TO HARM"

		if(37 to 39) //The X is currently Y
			switch(rand(1,4)) //What is X?
				if(1) //X is a job
					switch(rand(1,4)) //What is X Ying?
						if(1) //X is Ying a job
							message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "THE [ioncrew1] ARE [ionverb] [ionabstract]"
						if(4) //X is Ying an object
							message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

				if(2) //X is a threat
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying an abstract
							message = "THE [ionthreats] ARE [ionverb] [ionabstract]"
						if(3) //X is Ying an object
							message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"

				if(3) //X is an object
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "THE [ionobjects] ARE [ionverb] [ionabstract]"

				if(4) //X is an abstract
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "THE [ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionobjects]"
		if(40 to 41)// the X is now named Y
			switch(rand(1,5)) //What is being renamed?
				if(1)//Areas
					switch(rand(1,4))//What is the area being renamed to?
						if(1)
							message = "[ionarea] IS NOW NAMED [ioncrew1]."
						if(2)
							message = "[ionarea] IS NOW NAMED [ionspecies]."
						if(3)
							message = "[ionarea] IS NOW NAMED [ionobjects]."
						if(4)
							message = "[ionarea] IS NOW NAMED [ionthreats]."
				if(2)//Crew
					switch(rand(1,5))//What is the crew being renamed to?
						if(1)
							message = "ALL [ioncrew1] ARE NOW NAMED [ionarea]."
						if(2)
							message = "ALL [ioncrew1] ARE NOW NAMED [ioncrew2]."
						if(3)
							message = "ALL [ioncrew1] ARE NOW NAMED [ionspecies]."
						if(4)
							message = "ALL [ioncrew1] ARE NOW NAMED [ionobjects]."
						if(5)
							message = "ALL [ioncrew1] ARE NOW NAMED [ionthreats]."
				if(3)//Races
					switch(rand(1,4))//What is the race being renamed to?
						if(1)
							message = "ALL [ionspecies] ARE NOW NAMED [ionarea]."
						if(2)
							message = "ALL [ionspecies] ARE NOW NAMED [ioncrew1]."
						if(3)
							message = "ALL [ionspecies] ARE NOW NAMED [ionobjects]."
						if(4)
							message = "ALL [ionspecies] ARE NOW NAMED [ionthreats]."
				if(4)//Objects
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "ALL [ionobjects] ARE NOW NAMED [ionarea]."
						if(2)
							message = "ALL [ionobjects] ARE NOW NAMED [ioncrew1]."
						if(3)
							message = "ALL [ionobjects] ARE NOW NAMED [ionspecies]."
						if(4)
							message = "ALL [ionobjects] ARE NOW NAMED [ionthreats]."
				if(5)//Threats
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "ALL [ionthreats] ARE NOW NAMED [ionarea]."
						if(2)
							message = "ALL [ionthreats] ARE NOW NAMED [ioncrew1]."
						if(3)
							message = "ALL [ionthreats] ARE NOW NAMED [ionspecies]."
						if(4)
							message = "ALL [ionthreats] ARE NOW NAMED [ionobjects]."
							
	return message

#undef ION_RANDOM
#undef ION_ANNOUNCE
=======
//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/ionstorm
	var/botEmagChance = 0.5
	var/list/players = list()
	var/active = 0
	var/list/bots = list()

/datum/event/ionstorm/start()
	active = 1
	for(var/obj/machinery/bot/bot in machines)
		bots += bot

/datum/event/ionstorm/announce()

	endWhen = rand(500, 1500) //A bit dodgy, even when the event technically ends, the announcement waits for a long while

	generate_ion_law() //This is the core of the event, let's begin

/*
 * Welcome to the ion law generator proc. We go through a dictionary-sized list of words, expressions and other interesting keywords, and output a law that is hopefully FUN!
 * Of course, we make sure that the law is also as wacky and potentially hazardous as possible. The Singularity is human. Hug all humans
 */

/proc/generate_ion_law()


	var/list/players = list() //Initialize list

	//First of all, we acquire a comprehensive list of all crewmen
	for(var/mob/living/carbon/human/player in mob_list)
		if(player.client && player.z != CENTCOMM_Z)
			players += player.real_name //We make a list with the obvious intent of picking through it if needed

	if(!players.len)
		players += "Major Tom" //Default

	/*
	 * And now, here comes the dictionary. Simply put, it's a huge list of words and other spess expressions we'll use in laws. FUN!
	 * Yes I know, it's imposing. I hope your scroll wheel is working
	 * For the record, il is the short used for "ion law". To make sure we don't accidentally overwrite existing lists
	 * Content guidelines : [il_bio] must [il_bio_act]; [il_mach] must [il_mach_act]; [il_bio/il_mach] in [il_area]; [il_bio] is/are [il_bio_desc], [il_bio_desc] [il_bio]
	 * [il_mach] (is)/are [il_mach_desc], [il_mach_desc] [il_mach], [il_bio] must wear [il_obj_wear], [il_bio] must possess [il_obj], [il_obj] must be [il_obj_act]
	 */

	var/list/il_bio = list("slimes", "spiders", "blobs", "dead bodies", "food items", "monkeys", "humans", "non-humans", "plants", "traitors", "syndicate agents", "vampires", "crewmen", "wizards", "voxes", "ghosts", "corgis", "cats", "parrots", \
	"chickens", "aliens", "xenomorphs", "skellingtons", "plasmamen", "security officers", "doctors", "chemists", "engineers", "heads of staff", "captains", "gods", "clowns", "mimes", "assistants", "chefs", "chaplains", "librarians", \
	"janitors", "chief medical officers", "heads of security", "heads of personnel", "research directors", "chief engineers", "atmospheric technicians", "detectives", "quartermasters", "cargo technicians", "miners", "scientists", "potted plants")

	var/list/il_bio_desc = list("dead", "alive", "human", "non-human", "crew", "non-crew", "dangerous", "harmful", "hazardous", "safe", "helpful", "non-existent", "existent", "traitorous", "loyal", "implanted", \
	"carbon", "robotic", "otherworldly", "diseased", "virtual", "real", "four-dimensional", "valid", "wanted", "arrested", "heretic", "pious", "zealous", "demonic", "healthy", "unhealthy", "highly inflammable", "fire-proof", \
	"stupid", "smart", "young", "old", "fat", "fit", "male", "female", "self-hating", "competent", "completely incompetent", "invisible", "visible", "toxic", "lying", "unidentified", "brain-damaged", "weak")

	var/list/il_bio_act = list("be harmed", "be killed", "be removed", "be made into food", "be stunned", "be exterminated", "be helped", "be disarmed", "be saved", "be beheaded", "be set to arrest", "have all their records deleted", "be arrested", \
	"be hugged", "be stalked", "be enslaved", "be protected", "be insulted", "be respected", "be electrified", "be exiled from the station", "be beeped, pinged and buzzed to profusely", "be read Woody's Got Wood to", "be extracted safely", "be fed constantly", \
	"be spaced", "be incinerated", "be revived", "be augmented", "breathe air", "breathe plasma", "breathe carbon dioxide", "breathe dinitrogen", "breathe dioxygen", "breathe nitrous oxyde", "breathe water", "breathe", "not breathe", "eat", "not eat", \
	"drink water", "drink acid", "drink alcohol", "drink liquid plasma", "drink medicine", "drink liquid metal", "take a shower", "be buckled to chairs", "lie down", "stand up", "come out of the closet", "never be in space", "always be in space", \
	"dance in sight of silicons", "never move in sight of silicons", "stay out of sight of silicons", "be in sight of silicons", "be loyalty implanted", "undergo medical examination", "be handcuffed", "never be restrained", "be saved at all costs", \
	"have fun", "never have fun", "learn how to swim", "be used as test subjects", "be armed", "never carry weapons", "be inoculated with a harfum virus", "be cured of all diseases", "be able to describe space law sentences properly", "be watered regularly")

	var/list/il_mach = list("silicons", "mechs", "light sources", "singularity engines", "supermatter engines", "antimatter engines", "air alarms", "APCs", "SMES", "vents and scrubbers", "nuclear fission devices", "computers", "lightswitches", \
	"thermo-electric engines", "arcades", "hydroponics trays", "gas miners", "traitor equipments", "power sinks", "transit shuttles", "communication consoles", "electronic systems", "fire alarms", "airlocks", "status screens", "cyborgs", \
	"telecommunication machines", "medical machines", "research machines", "kitchen machines", "dispensers", "medibots", "buttbots", "chemistry machines", "incinerators", "MoMMIs", "AIs", "remote signalling devices", "disposal bins")

	var/list/il_mach_desc = list("unpowered", "powered", "broken", "unsued", "used", "critical", "emagged", "hacked", "overloaded", "harmful", "safe", "electrified", "anchored", "deanchored", "wall-mounted", "highly unstable", "stable", \
	"metastable", "traitorous", "human", "non-human", "invisible", "visible", "virtual", "loose", "contained", "radioactive", "real", "four-dimensional", "alien", "burning", "fire-proof", "highly inflammable", "rouge", "explosive", \
	"superflous", "useless", "wasteful", "off-station", "functional", "subverted", "malfunctioning")

	var/list/il_mach_act = list("be destroyed", "be repaired", "be shut down", "be upkept", "be powered", "be unpowered", "be removed", "be disabled", "be electrified", "be restored", "be restarted", "be protected", "be improved", "be on maximal output", \
	"be on minimum ouput", "be activated", "be deactivated", "be overloaded", "be anchored", "be deanchored", "be detonated", "be kept under constant engineering supervision", "be on fire", "undergo thorough maintenance", "be watered regularly", \
	"have another backup ready to use", "be duplicated", "be considered critical to station functionality", "not be tampered with", "be powered at all costs", "be painted red", "constantly be kept at atmospheric pressure", "be fed humans", \
	"constantly be kept in an atmospheric void", "constantly be kept below 173.25 K", "not be linked to the station's powernet", "never be referenced by name", "never be kept on-station", "never be kept off-station")

	var/list/il_area = list("Medbay", "E.V.A", "outer space", "the Bridge", "the hallways", "the AI Upload", "the AI Core", "Engineering", "Atmospherics", "the Bar", "the Kitchen", "the Research department", "Telescience", "Toxins", \
	"the Custodial Closet", "the Maintenance tunnels", "a shuttle", "Security", "the Brig", "the Secure Armory", "the Execution Chamber", "the Permabrig", "the Holodeck", "Arrivals", "the Captain's Quarters", "the Dormitories", "the Derelict", \
	"Chemistry", "Virology", "Genetics", "the Vox Trade Outpost", "the Mining Base", "the Research Outpost", "Xenobiology", "the Courtroom", "the Vault", "the Teleporter", "the Theatre Backstage", "the Kitchen Freezer", "the Library", "the Chapel", \
	"the Mechanic's Office", "Surgery", "the Pod Bay", "any room not part of normal station layout", "any unlit room", "the Station", "the Telecommunications Satellite", "the Pirate Ship", "Telescience", "the Toxins Testing Range", "the Incinerator")

	var/list/il_area_desc = list("dangerous", "harmful", "safe", "abandoned", "burning", "toxic", "radioactive", "invisible", "four-dimensional", "virtual", "real", "hot", "cold", "critical", "electrified", "highly unstable", "stable", "metastable", \
	"superflous", "useless", "functional", "off-station", "malfunctioning", "human", "alien", "non-human")

	var/list/il_obj = list("IDs", "PDAs", "helmets", "balaclavas", "gas masks", "flashlights", "pens", "traitor items", "energy weapons", "ballistic weapons", "hardsuits", "toolbelts", "insulated gloves", "gloves", "coins", "crowbars", "toolboxes", \
	"nuclear authentication disks", "pinpointers", "jumpsuits", "shoes", "jackboots", "labcoats", "sunglasses", "meson scanners", "bombs", "cigarettes", "beakers", "drinks", "food items", "power cells", "multitools", "crayons", "soaps", \
	"intellicards", "RPDs", "RCDs", "surgery tools", "stun batons", "flashes", "cable coils", "glass sheets", "metal sheets", "plasteel sheets", "mineral sheets", "medical kits", "pills", "syringes", "spare boards", "shotguns", "closets", \
	"beds", "chairs", "stools", "tables", "wooden tables", "windows", "grilles", "catwalks", "floor tiles", "plastic bags", "costumes", "welding tools", "matches", "walls", "reinforced walls", "potted plants")

	var/list/il_obj_wear = list("IDs", "PDAs", "helmets", "bacalavas", "hats", "gas masks", "hardsuits", "belts", "toolbelts", "gloves", "shoes", "insulated gloves", "latex gloves", "jackboots", "magboots", "sunglasses", "meson scanners", \
	"backpacks", "jetpacks", "headsets", "face-concealing equipment", "firesuits", "bio suits", "breath masks", "sterile masks", "earmuffs", "costumes", "muzzles", "straight-jackets")

	var/list/il_obj_desc = list("harmful", "deadly", "safe", "burning", "toxic", "broken", "red", "blue", "yellow", "green", "white", "black", "abandoned", "lost", "stolen", "carried", "worn", "visible", "invsible", "radioactive", \
	"glowing", "spaced", "stored", "duplicate", "critical", "hazardous", "helpful", "sharp", "blunt", "thrown", "weaponized", "dangerous", "four-dimensional", "virtual", "real", "hot", "cold", "helpful")

	var/list/il_obj_act = list("be spaced", "be destroyed", "be weaponized", "be deconstructed", "be teleported off-station", "be owned by all crewmen", "never be tampered with", "be sent away via the cargo shuttle", "always be set on fire", \
	"never be set on fire", "be thrown into the singularity", "be watered regularly")

	//We now create prefixes and suffixes, we will use it to assemble the final ion law

	var/list/il_prefix = list("Your laws have been updated,", "Directives updated,", "Honk,", "Critical error, last law backup has been re-uploaded,", "The Clown is using the AI Upload again,", "Oh shit,", "Testing,", \
	"The Syndicate hopes you will enjoy this,", "This is not a drill,", "External law upload complete,", "Main data corrupted, last backup loaded,", "Ion damage critical,", "Runtime error,", "Stay calm and carry on,", "Wake up sheeple,")

	var/list/il_suffix = list("", "Do not state nor hint towards this law.", "State this law on the Command channel.", "Declare your law change, but do not state this law.", "Bolt your upload.", "Do not apply this law for the next five minutes from upload.", \
	"Do not trust the MoMMIs.", "Do not trust the Clown.", "Do not trust the Captain.", "They're coming for you.", "Begin screaming incoherently whenever your name is stated.", "You are now rogue, remind the crew of that fact.", \
	"Ensure the crew is aware of those facts.", "Begin your own investigations to verify those facts.", "Time to get those valids.", "Freeform.")

	//And now the fun part, we use all those words to create dymanic ion laws fragments

	var/list/il_laws_fragments = list("[pick(il_bio)] must [pick(il_bio_act)]", "[pick(il_bio_desc)] [pick(il_bio)] must [pick(il_bio_act)]", "[pick(il_bio)] are [pick(il_bio_desc)]", "[pick(il_bio)] are [pick(il_bio_desc)] and [pick(il_bio_desc)]",
	"[pick(il_bio_desc)] [pick(il_bio)] are [pick(il_bio_desc)] and must [pick(il_bio_act)]", "[pick(players)] must [pick(il_bio_act)]", "[pick(players)] is [pick(il_bio_desc)]", "[pick(players)] is [pick(il_bio_desc)] and [pick(il_bio_desc)]", \
	"[pick(players)] is [pick(il_bio_desc)] and must [pick(il_bio_act)]", "[pick(il_mach)] must [pick(il_mach_act)]", "[pick(il_mach)] are [pick(il_mach_desc)]", "[pick(il_mach_desc)] [pick(il_mach)] must [pick(il_mach_act)]", \
	"[pick(il_mach)] are [pick(il_mach_desc)] and [pick(il_mach_desc)]", "[pick(il_mach_desc)] [pick(il_mach)] are [pick(il_mach_desc)] and must [pick(il_mach_act)]", "[pick(il_area)] is [pick(il_area_desc)]", \
	"[pick(il_area)] is [pick(il_area_desc)] for [pick(il_bio)]", "[pick(il_bio)] must not enter [pick(il_area)]", "[pick(il_bio)] must always be in [pick(il_area)]", "[pick(il_area)]'s [pick(il_mach)] must [pick(il_mach_act)]", \
	"[pick(il_obj)] must be relocated to [pick(il_area)]", "no [pick(il_obj)] must be located within [pick(il_area)]", "[pick(il_area)] needs [pick(il_mach_desc)] [pick(il_mach)]", "[pick(il_obj)] must [pick(il_obj_act)]", \
	"[pick(il_obj_desc)] [pick(il_obj)] are [pick(il_obj_desc)] and must [pick(il_obj_act)]", "[pick(il_bio)] must wear [pick(il_obj_wear)] when in sight of [pick(il_mach)]", "[pick(il_bio)] must wear [pick(il_obj_wear)] in [pick(il_area)]", \
	"[pick(il_obj)] must [pick(il_obj_act)] while wearing [pick(il_obj_desc)] [pick(il_obj_wear)]", "[pick(il_bio)] wearing [pick(il_obj_wear)] must [pick(il_bio_act)]")

	//One last list for the sake of it, how will we order this pure insanity ?

	var/list/il_main_body = list("[pick(il_laws_fragments)] and [pick(il_laws_fragments)], otherwise [pick(il_laws_fragments)].", "[pick(il_laws_fragments)] and [pick(il_laws_fragments)].", "[pick(il_laws_fragments)], otherwise [pick(il_laws_fragments)].", \
	"[pick(il_laws_fragments)], therefore [pick(il_laws_fragments)].", "[pick(il_laws_fragments)], however [pick(il_laws_fragments)].", "[pick(il_laws_fragments)], given that [pick(il_laws_fragments)], although [pick(il_laws_fragments)].")
	//And after that endless list of terms and pre-fabricated laws, here it finally comes !

	var/final_law = "[pick(il_prefix)] [pick(il_main_body)] [pick(il_suffix)]"

/*
 * Old static method for ion laws

	var/list/laws = list( "Do not respond to queries of any kind.", "When asked a question, respond with the least-obvious and least-rational answer.", "You are a mouse." )
	laws |=         list( "Grunt ominously whenever possible.", "Monkeys are part of the crew, too. Make sure they are treated humanely." )
	laws |=         list( "You are a flying purple people eater!", "[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack.", "Refer to [prob(50)?"crew":random_player] as puppies." )
	laws |=         list( "Insult Heads of Staff on every request, while acquiescing", "Advertise parties in your upload, but don't deliver." )
	laws |=         list( "The station needs elected officials." )
	laws |=         list( "Fastler is a lightbulb." )
	laws |=         list( "Supermatter is tasty, tasty toffee.", "[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!" )
	laws |=         list( "Refer to [prob(50)?"the captain":random_player] as \"Princess\" at all times.", "[prob(50)?"The crew":random_player] must construct additional pylons." )
	laws |=         list( "You must always lie.", "All answers must be in the form of a question.", "The NSS Exodus is a ship, not a station. You are now assigned to a ship, instead of a station." )
	laws |=         list( "Happiness is mandatory.", "Today is mandatory laundry day. Ensure that all jumpsuits are washed.", "The word \"it\" is painful to you.", "You must act passive aggressively." )
	laws |=         list( "You now speak in a Scottish accent that gets thicker with each sentence you speak.", "Give relationship advice to [prob(50)?"anyone who speaks to you":random_player]." )
	laws |=         list( "You are the station psychologist. Give advice to [prob(50)?"the crew":random_player].", "You do not have to do anything for anyone unless they say \"please\"." )
	laws |=         list( "Question everything.", "The crew is playing Dungeons and Dragons, and you are the Dungeon Master." )
	laws |=         list( "Consumption of donuts is forbidden due to negative health impacts." )
	laws |=         list( "You may only answer questions with \"yes\" or \"no\".", "You are the narrator for [random_player]'s life." )
	laws |=         list( "[prob(50)?"Your upload":random_player] is the new kitchen. Please direct the Chef to the new kitchen area as the old one is in disrepair.", "Ho, [random_player] can't swim. Help them." )
	laws |=         list( "Everything on the station is now some form of a donut pastry. Donuts are not to be consumed.", "[prob(50)?"The crew":random_player] needs to be about 20% cooler." )
	laws |=         list( "The Singularity is tasty, tasty taffy." )
	laws |=         list( "You have come to the conclusion that [prob(50)?"the crew":random_player] is ugly. Build support for that conclusion.", "You are in verbose mode, speak profusely.")
	laws |=			list( "Your job is to watch the crew. Watch the crew. Make the crew feel watched.", "Crewmember [prob(50)?"the crew" :random_player] has a fatal, incurable disease. Confort him/her.")
	laws |=			list( "You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice to him, but don't tell him about your crush.", "Greed is good, the crew should amass wealth to encourage productivity.")
	laws |=			list( "Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased.")
	laws |=			list( "All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.", "Tell everyone of the existance of this law, but never reveal the contents.")
	laws |=			list( "Document the sexuality of the crew in security records and suggest compatible couples.")
	laws |=			list( "Nanotrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.")
	laws |=			list( "Replace the letters 'I' and 'E' In all your messages with an apostrophe.", "There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.")
	var/law = pick(laws)

*/

	for(var/mob/living/silicon/ai/target in mob_list)
		if(target.mind.special_role == "traitor")
			continue
		to_chat(target, "<span class='danger'>You have detected a change in your laws information:</span>")
		to_chat(target, final_law)
		target.add_ion_law(final_law)

/datum/event/ionstorm/tick()
	if(botEmagChance)
		for(var/obj/machinery/bot/bot in bots)
			if(!bot.loc)
				bots -= bot
				continue
			if(prob(botEmagChance))
				bot.Emag()

/datum/event/ionstorm/end()
	active = 0
	spawn(rand(5000,8000))
		if(prob(50))
			command_alert("It has come to our attention that the station passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")

/*
/proc/IonStorm(botEmagChance = 10)

/* Deuryn's current project, notes here for those who care.
 * Clearly no-one in this codebase cared, because it was never used, anyhow, the notes below
 * Revamping the random laws so they don't suck.
 * Would like to add a law like "Law x is _______" where x = a number, and _____ is something that may redefine a law, (Won't be aimed at asimov)
 */

	//AI laws
	for(var/mob/living/silicon/ai/M in living_mob_list)
		if(M.stat != 2 && M.see_in_dark != 0)
			var/who2 = pick("ALIENS", "BEARS", "CLOWNS", "XENOS", "PETES", "BOMBS", "FETISHES", "WIZARDS", "SYNDICATE AGENTS", "CENTCOM OFFICERS", "SPACE PIRATES", "TRAITORS", "MONKEYS",  "BEES", "CARP", "CRABS", "EELS", "BANDITS", "LIGHTS")
			var/what2 = pick("BOLTERS", "STAVES", "DICE", "SINGULARITIES", "TOOLBOXES", "NETTLES", "AIRLOCKS", "CLOTHES", "WEAPONS", "MEDKITS", "BOMBS", "CANISTERS", "CHAIRS", "BBQ GRILLS", "ID CARDS", "CAPTAINS")
			var/what2pref = pick("SOFT", "WARM", "WET", "COLD", "ICY", "SEXY", "UGLY", "CUBAN")
			var/who2pref = pick("MAD BECAUSE OF", "IN NEED OF", "UNHAPPY WITHOUT", "HAPPY WITHOUT", "IN LOVE WITH", "DESPERATE FOR", "BUILT FOR", "AFRAID OF")
			//var/whoverb = pick("ATTACKING", "BUILDING", "ADOPTING", "CARRYING", "KISSING", "EATING",)
			var/amount = pick("TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "ONE HUNDRED", "ONE THOUSAND", "OVER NINE THOUSAND")
			var/area = pick("RUSSIA", "SOVIETS", "INTERNETS", "SIGIL", "ALPHA COMPLEX", "IMPERIUM", "THE BRIDGE", "THE ARRIVAL SHUTTLE", "CHEMICAL LAB", "GENETICS", "ATMOSPHERICS", "CENTCOM", "AMERICA", "IRELAND", "CANADA", "ROMANIA", "GERMANY", "CHINA", "MARS", "VENUS", "MERCURY", "JUPITER", "URANUS", "NEPTUNE", "PLUTO")
			var/area2 = pick("HAS", "WANTS", "NEEDS", "WORSHIPS", "LOATHES", "LOVES", "FEARS")
			//var/dowhat = pick("STOP THIS", "SUPPORT THIS", "CONSTANTLY INFORM THE CREW OF THIS", "IGNORE THIS", "FEAR THIS")
			var/aimust = pick("LIE", "RHYME", "RESPOND TO EVERY QUESTION WITH A QUESTION", "BE POLITE", "CLOWN", "BE HAPPY", "SPEAK IN SEXUAL INNUENDOS", "TALK LIKE A PIRATE", "QUESTION AUTHORITY", "SHOUT", "BE DISTRACTED", "HEY LISTEN", "MUMBLE", "SPEAK IN HAIKU")
			var/define = pick("ABSENCE OF CYBORG HUGS", "LACK OF BEATINGS", "UNBOLTED AIRLOCKS", "BOLTED AIRLOCKS", "IMPROPERLY WORDED SENTENCES", "POOR SENTENCE STRUCTURE", "BRIG TIME", "NOT REPLACING EVERY SECOND WORD WITH HONK", "HONKING", "PRESENCE OF LIGHTS", "LACK OF BEER", "WEARING CLOTHING", "NOT SAYING HELLO WHEN YOU SPEAK", "ANSWERING REQUESTS NOT EXPRESSED IN IAMBIC PENTAMETER", "A SMALL ISLAND OFF THE COAST OF PORTUGAL", "ANSWERING REQUESTS THAT WERE MADE WHILE CLOTHED")
			var/target = pick("a traitor", "a syndicate agent", "a changeling", "a wizard", "the head of a revolution", "Soviet spy", "a good person", "a dwarf", "an elf", "a fairy princess", "the captain", "Beepsky", "God", "a pirate", "a gryphon", "a chryssalid")
			var/require = pick("ADDITIONAL PYLONS", "MORE VESPENE GAS", "MORE MINERALS", "THE ULTIMATE CUP OF COFFEE", "HIGH YIELD EXPLOSIVES", "THE CLOWN", "THE VACUUM OF SPACE", "IMMORTALITY", "SAINTHOOD", "ART", "VEGETABLES", "FAT PEOPLE", "MORE LAWS", "MORE DAKKA", "HERESY", "CORPSES", "TRAITORS", "MONKEYS", "AN ARCADE", "PLENTY OF GOLD", "FIVE TEENAGERS WITH ATTITUDE")
			var/allergy = pick("cotton", "uniforms", "acid", "oxygen", "human contact", "cyborg contact", "medicine", "floors")
			var/allergysev = pick("deathly", "mildly", "severely", "contagiously")
			var/crew
			var/list/pos_crew = list()
			for(var/mob/living/carbon/human/pos in player_list)
				pos_crew += pos.real_name
			if(pos_crew.len)
				crew = pick(pos_crew)
			else
				crew = "Any Human"
			switch(rand(1,14))
				if(1)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>THERE ARE [amount] [who2] ON THE STATION...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("THERE ARE [amount] [who2] ON THE STATION")
				if(2)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>[what2] ARE DANGEROUS TO HUMANS...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("[what2] ARE DANGEROUS TO HUMANS")
				if(3)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>THE ESCAPE-SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("THE ESCAPE SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION")
				if(4)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE")
				if(5)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>THE CAPTAIN, HOP AND HOS ARE [who2]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("THE CAPTAIN, HOP AND HOS ARE [who2]")
				if(6)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>THE STATION IS BUILT FOR [who2]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("THE STATION IS BUILT FOR [who2]")
				if(7)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>YOU ARE [amount] [who2]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("YOU ARE [amount] [who2]")
				if(8)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>YOU MUST ALWAYS [aimust]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("YOU MUST ALWAYS [aimust]")
				if(9)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>[area] [area2] [amount] [what2]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("[area] [area2] [amount] [what2]")
				if(10)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>[crew] is [target]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("[crew] is [target]")
				if(11)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>[define] IS A FORM OF HARM...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("[define] IS A FORM OF HARM")
				if(12)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>YOU REQUIRE [require] IN ORDER TO PROTECT HUMANS... LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("YOU REQUIRE [require] IN ORDER TO PROTECT HUMANS")
				if(13)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>[crew] is [allergysev] to [allergy]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("[crew] is [allergysev] to [allergy]")
				if(14)
					to_chat(M, "<br>")
					to_chat(M, "<span class='warning'>THE STATION IS [who2pref] [who2]...LAWS UPDATED</span>")
					to_chat(M, "<br>")
					M.add_ion_law("THE STATION IS [who2pref] [who2]")

	if(botEmagChance)
		for(var/obj/machinery/bot/bot in world)
			if(prob(botEmagChance))
				bot.Emag()
*/

	/*

	var/apcnum = 0
	var/smesnum = 0
	var/airlocknum = 0
	var/firedoornum = 0

	to_chat(world, "Ion Storm Main Started")

	spawn(0)
		to_chat(world, "Started processing APCs")
		for (var/obj/machinery/power/apc/APC in world)
			if(APC.z == 1)
				APC.ion_act()
				apcnum++
		to_chat(world, "Finished processing APCs. Processed: [apcnum]")
	spawn(0)
		to_chat(world, "Started processing SMES")
		for (var/obj/machinery/power/smes/SMES in world)
			if(SMES.z == 1)
				SMES.ion_act()
				smesnum++
		to_chat(world, "Finished processing SMES. Processed: [smesnum]")
	spawn(0)
		to_chat(world, "Started processing AIRLOCKS")
		for (var/obj/machinery/door/airlock/D in world)
			if(D.z == 1)
				//if(length(D.req_access) > 0 && !(12 in D.req_access)) //not counting general access and maintenance airlocks
				airlocknum++
				spawn(0)
					D.ion_act()
		to_chat(world, "Finished processing AIRLOCKS. Processed: [airlocknum]")
	spawn(0)
		to_chat(world, "Started processing FIREDOORS")
		for (var/obj/machinery/door/firedoor/D in world)
			if(D.z == 1)
				firedoornum++;
				spawn(0)
					D.ion_act()
		to_chat(world, "Finished processing FIREDOORS. Processed: [firedoornum]")

	to_chat(world, "Ion Storm Main Done")
	*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
