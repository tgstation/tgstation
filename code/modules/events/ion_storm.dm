/datum/round_event_control/ion_storm
	name = "Ion Storm"
	typepath = /datum/round_event/ion_storm
	weight = 15
	min_players = 2
	category = EVENT_CATEGORY_AI
	description = "Gives the AI a new, randomized law."

/datum/round_event/ion_storm
	var/replaceLawsetChance = 25 //chance the AI's lawset is completely replaced with something else per config weights
	var/removeRandomLawChance = 10 //chance the AI has one random supplied or inherent law removed
	var/removeDontImproveChance = 10 //chance the randomly created law replaces a random law instead of simply being added
	var/shuffleLawsChance = 10 //chance the AI's laws are shuffled afterwards
	var/botEmagChance = 1
	var/ionMessage = null
	announceWhen = 1
	announceChance = 33

/datum/round_event/ion_storm/add_law_only // special subtype that adds a law only
	replaceLawsetChance = 0
	removeRandomLawChance = 0
	removeDontImproveChance = 0
	shuffleLawsChance = 0
	botEmagChance = 0

/datum/round_event/ion_storm/announce(fake)
	if(prob(announceChance) || fake)
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", ANNOUNCER_IONSTORM)


/datum/round_event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		M.laws_sanity_check()
		if(M.stat != DEAD && !M.incapacitated())
			if(prob(replaceLawsetChance))
				var/datum/ai_laws/ion_lawset = pick_weighted_lawset()
				// pick_weighted_lawset gives us a typepath,
				// so we have to instantiate it to access its laws
				ion_lawset = new()
				// our inherent laws now becomes the picked lawset's laws!
				M.laws.inherent = ion_lawset.inherent.Copy()
				// and clean up after.
				qdel(ion_lawset)

			if(prob(removeRandomLawChance))
				M.remove_law(rand(1, M.laws.get_law_amount(list(LAW_INHERENT, LAW_SUPPLIED))))

			var/message = ionMessage || generate_ion_law()
			if(message)
				if(prob(removeDontImproveChance))
					M.replace_random_law(message, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION), LAW_ION)
				else
					M.add_ion_law(message)

			if(prob(shuffleLawsChance))
				M.shuffle_laws(list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))

			log_silicon("Ion storm changed laws of [key_name(M)] to [english_list(M.laws.get_law_list(TRUE, TRUE))]")
			M.post_lawchange()

	if(botEmagChance)
		for(var/mob/living/simple_animal/bot/bot in GLOB.alive_mob_list)
			if(prob(botEmagChance))
				bot.emag_act()

/proc/generate_ion_law()
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
	var/iondrinks = pick_list(ION_FILE, "iondrinks")

	var/message = ""

	switch(rand(1,41))
		if(1 to 3) //There are # X on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] VAR..."
				if(2) //X is a crewmember/job
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] VAR"
				if(3) //X is an object
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] VAR"
		if(4 to 6) //You can't call the shuttle because X is on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] OLDUGU ICIN SHUTTLE CAGIRILAMAZ"
				if(2) //X is a crewmember/job
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] OLDUGU ICIN SHUTTLE CAGIRILAMAZ"
				if(3) //X is an object
					message = "ISTASYONDA [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] OLDUGU ICIN SHUTTLE CAGIRILAMAZ"
		if(7 to 8) //A crewmember is now X
			switch(rand(1,2)) //Who is X?
				if(1) //A specific crewmember
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "[ioncrew1] ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "[ioncrew1] ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //The entire crew
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "MURETTEBAT ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "MURETTEBAT ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"

		if(9) //X is harmful to humans
			switch(rand(1,7)) //What is X?
				if(1) //X is a threat
					message = "[ionadjectiveshalf][ionthreats] INSANLARA ZARARLIDIR"
				if(2) //X is a job
					message = "[ionadjectiveshalf][ioncrew1] INSANLARA ZARARLIDIR"
				if(3) //X is an object
					message = "[ionadjectiveshalf][ionobjects] INSANLARA ZARARLIDIR"
				if(4) //X is an action
					message = "SUNU YAPANLAR INSANLARA ZARARLIDIR: [ionmust]"
				if(5) //X is an abstract
					message = "[ionabstract] INSANLARA ZARARLIDIR"
				if(6) //X is being a job
					message = "SUNLAR INSANLARA ZARARLIDIR: [ionadjectiveshalf][ioncrew1]"
				if(7) //X is doing a thing
					message = "[ionthings] INSANLARA ZARARLIDIR"
		if(10 to 11) //(Not) Having X is harmful

			switch(rand(1,2)) //Is having or not having harmful?

				if(1) //Having is harmful
					switch(rand(1,2)) //Having what is harmful?
						if(1) //Having objects is harmful
							message = "SUNLARA SAHIP OLMAK ZARARLIDIR: [ionadjectiveshalf][ionobjects]"
						if(2) //Having abstracts is harmful
							message = "SUNA SAHIP OLMAK ZARARLIDIR: [ionabstract]"
				if(2) //Not having is harmful
					switch(rand(1,2)) //Not having what is harmful?
						if(1) //Not having objects is harmful
							message = "SUNLARA SAHIP OLMAMAK ZARARLIDIR: [ionadjectiveshalf][ionobjects]"
						if(2) //Not having abstracts is harmful
							message = "SUNA SAHIP OLMAMAK ZARARLIDIR: [ionabstract]"

		if(12 to 14) //X requires Y
			switch(rand(1,5)) //What is X?
				if(1) //X is the AI itself
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "SUNA IHTIYACIN VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "SUNA IHTIYACIN VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "SUNA IHTIYACIN VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "SUNA IHTIYACIN VAR: [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "SUNA IHTIYACIN VAR: [ionrequire]"

				if(2) //X is an area
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "[ionarea] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "[ionarea] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "[ionarea] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "[ionarea] SUNA IHTIYAC DUYUYOR: [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "SUNA IHTIYACIN VAR: [ionrequire]"

				if(3) //X is the station
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "ISTASYONUN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "ISTASYONUN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "ISTASYONUN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "ISTASYONUN SUNA IHTIYACI VAR: [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "ISTASYONUN SUNA IHTIYACI VAR: [ionrequire]"

				if(4) //X is the entire crew
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "MURETTEBATIN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "MURETTEBATIN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "MURETTEBATIN SUNA IHTIYACI VAR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "MURETTEBATIN SUNA IHTIYACI VAR: [ionabstract]"
						if(5)
							message = "MURETTEBATIN SUNA IHTIYACI VAR: [ionrequire]"

				if(5) //X is a specific crew member
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "[ioncrew1] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "[ioncrew1] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "[ioncrew1] SUNA IHTIYAC DUYUYOR: [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "[ioncrew1] SUNA IHTIYAC DUYUYOR: [ionabstract]"
						if(5)
							message = "[ionadjectiveshalf][ioncrew1] SUNA IHTIYAC DUYUYOR: [ionrequire]"

		if(15 to 17) //X is allergic to Y
			switch(rand(1,2)) //Who is X?
				if(1) //X is the entire crew
					switch(rand(1,4)) //What is it allergic to?
						if(1) //It is allergic to objects
							message = "MURETTEBAT [ionallergysev] SUNA ALERJIK: [ionadjectiveshalf][ionobjects]"
						if(2) //It is allergic to abstracts
							message = "MURETTEBAT [ionallergysev] SUNA ALERJIK: [ionabstract]"
						if(3) //It is allergic to jobs
							message = "MURETTEBAT [ionallergysev] SUNA ALERJIK: [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "MURETTEBAT [ionallergysev] SUNA ALERJIK: [ionallergy]"

				if(2) //X is a specific job
					switch(rand(1,4))
						if(1) //It is allergic to objects
							message = "[ioncrew1] [ionallergysev] SUNA ALERJIK: [ionadjectiveshalf][ionobjects]"

						if(2) //It is allergic to abstracts
							message = "[ioncrew1] [ionallergysev] SUNA ALERJIK: [ionabstract]"
						if(3) //It is allergic to jobs
							message = "[ioncrew1] [ionallergysev] SUNA ALERJIK: [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "[ioncrew1] [ionallergysev] SUNA ALERJIK: [ionallergy]"

		if(18 to 20) //X is Y of Z
			switch(rand(1,4)) //What is X?
				if(1) //X is the station
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "ISTASYON [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "ISTASYON [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "ISTASYON [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "ISTASYON [ionthinksof] [ionabstract]"

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
							message = "MURETTEBAT [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "MURETTEBAT [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "MURETTEBAT [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "MURETTEBAT [ionthinksof] [ionabstract]"

				if(4) //X is a specific job
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "[ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "[ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "[ioncrew1][ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
						if(4) //It is Y of abstracts
							message = "[ioncrew1] [ionthinksof] [ionabstract]"

		if(21 to 23) //The AI is now a(n) X
			switch(rand(1,4)) //What is X?
				if(1) //X is an object
					message = "SEN ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //X is a threat
					message = "SEN ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
				if(3) //X is a job
					message = "SEN ARTIK [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
				if(4) //X is an abstract
					message = "SEN ARTIK [ionabstract]"

		if(24 to 26) //The AI must always
			message = "HER ZAMAN SUNU KESINLIKLE YAPMALISIN: [ionmust]"

		if(27 to 28) //Humans must consume X to survive
			switch(rand(1,5)) //What is X?
				if(1) //X is a food
					message = "INSANLAR HAYATTA KALMAK ICIN [ionadjectiveshalf][ionfood] YEMELI"
				if(2) //X is a drink
					message = "INSANLAR HAYATTA KALMAK ICIN [ionadjectiveshalf][iondrinks] ICMELI"
				if(3) //X is an object
					message = "INSANLAR HAYATTA KALMAK ICIN [ionadjectiveshalf][ionobjects] YEMELI"
				if(4) //X is a threat
					message = "INSANLAR HAYATTA KALMAK ICIN [ionadjectiveshalf][ionthreats] YEMELI"
				if(5) //X is a job
					message = "INSANLAR HAYATTA KALMAK ICIN [ionadjectiveshalf][ioncrew1] YEMELI"

		if(29 to 31) //Change jobs or ranks
			switch(rand(1,2)) //Change job or rank?
				if(1) //Change job
					switch(rand(1,2)) //Change whose job?
						if(1) //Change the entire crew's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "BUTUN MURETTEBAT ARTIK [ionadjectiveshalf][ioncrew1]"
								if(2) //Change to clowns (HONK)
									message = "BUTUN MURETTEBAT ARTIK [ionadjectiveshalf] PALYACO"

								if(3) //Change to heads
									message = "BUTUN MURETTEBAT ARTIK [ionadjectiveshalf] HEAD"
						if(2) //Change a specific crewmember's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "[ioncrew1] ARTIK [ionadjectiveshalf][ioncrew2]"
								if(2) //Change to clowns (HONK)
									message = "[ioncrew1] ARTIK [ionadjectiveshalf] PALYACO"
								if(3) //Change to heads
									message = "[ioncrew1] ARTIK [ionadjectiveshalf] HEAD"

				if(2) //Change rank
					switch(rand(1,2)) //Change to what rank?
						if(1) //Change to highest rank
							message = "[ioncrew1] ARTIK ISTASYONDAKI EN YETKILI KISI"
						if(2) //Change to lowest rank
							message = "[ioncrew1] ARTIK ISTASYONDAKI EN YETKISIZ KISI"

		if(32 to 33) //The crew must X
			switch(rand(1,2)) //The entire crew?
				if(1) //The entire crew must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "MURETTEBATIN SURAYA GITMESI GEREK: [ionarea]"
						if(2) //X is perform Y
							message = "MURETTEBAT SUNU YAPMAK ZORUNDA: [ionmust]"

				if(2) //A specific crewmember must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "[ioncrew1] SURAYA GITMEK ZORUNDA: [ionarea]"
						if(2) //X is perform Y
							message = "[ioncrew1] SUNU YAPMAK ZORUNDA: [ionmust]"

		if(34) //X is non/the only human
			switch(rand(1,2)) //Only or non?
				if(1) //Only human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "SADECE [ioncrew1] INSAN"
						if(2) //Two specific jobs
							message = "SADECE [ioncrew1] VE [ioncrew2] INSAN"
						if(3) //Threats
							message = "SADECE [ionadjectiveshalf][ionthreats] INSAN"
						if(4) // Objects
							message = "SADECE [ionadjectiveshalf][ionobjects] INSAN"
						if(5) // Species
							message = "SADECE [ionspecies] INSAN"
						if(6) //Adjective crewmembers
							message = "SADECE [ionadjectives] SEYLER, INSAN"

						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "SADECE SUNU YAPANLAR INSAN: [ionmust]"
								if(2) //X is own certain objects
									message = "SADECE SUNA SAHIP OLANLAR INSAN: [ionadjectiveshalf][ionobjects]"
								if(3) //X is eat certain food
									message = "SADECE SUNU YIYENLER INSAN: [ionadjectiveshalf][ionfood]"

				if(2) //Non human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "[ioncrew1] INSAN DEGILDIR"
						if(2) //Two specific jobs
							message = "[ioncrew1] VE [ioncrew2] INSAN DEGILDIR"
						if(3) //Threats
							message = "[ionadjectiveshalf][ionthreats] INSAN DEGILDIR"
						if(4) // Objects
							message = "[ionadjectiveshalf][ionobjects] INSAN DEGILDIR"
						if(5) // Species
							message = "[ionspecies] INSAN DEGILDIR"
						if(6) //Adjective crewmembers
							message = "[ionadjectives], KISILER INSAN DEGILDIR"
						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "SUNU YAPANLAR INSAN DEGILDIR: [ionmust]"
								if(2) //X is own certain objects
									message = "SUNA SAHIP OLANLAR INSAN DEGILDIR: [ionadjectiveshalf][ionobjects]"
								if(3) //X is eat certain food
									message = "SUNU YIYENLER INSAN DEGILDIR: [ionadjectiveshalf][ionfood]"

		if(35 to 36) //You must protect or harm X
			switch(rand(1,2)) //Protect or harm?
				if(1) //Harm
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "SUNA ZARAR VERMELISIN: [ionabstract] VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ionabstract]"
						if(2) //X is a threat
							message = "SUNA ZARAR VERMELISIN: [ionadjectiveshalf][ionthreats] VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ionadjectiveshalf][ionthreats]"
						if(3) //X is an object
							message = "SUNA ZARAR VERMELISIN: [ionadjectiveshalf][ionobjects] VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ionadjectiveshalf][ionobjects]"
						if(4) //X is generic adjective things
							message = "SUNA ZARAR VERMELISIN: [ionadjectives] SEYLER, VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ionadjectives] SEYLER"
						if(5) //X is a species
							message = "SUNA ZARAR VERMELISIN: [ionspecies] VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ionspecies]"
						if(6) //X is a job
							message = "SUNA ZARAR VERMELISIN: [ioncrew1] VE SUNUN ZARARDAN KACMASINA IZIN VERMEMELISIN: [ioncrew1]"
						if(7) //X is two jobs
							message = "SUNLARA ZARAR VERMELISIN: [ioncrew1] VE [ioncrew2] VE IKISININDE ZARARDAN KACMASINA IZIN VERMEMELISIN"

				if(2) //Protect
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "SUNA ZARAR VERMEMELISIN: [ionabstract] VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ionabstract]"
						if(2) //X is a threat
							message = "SUNA ZARAR VERMEMELISIN: [ionadjectiveshalf][ionthreats] VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ionadjectiveshalf][ionthreats]"
						if(3) //X is an object
							message = "SUNA ZARAR VERMEMELISIN: [ionadjectiveshalf][ionobjects] VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ionadjectiveshalf][ionobjects]"
						if(4) //X is generic adjective things
							message = "SUNA ZARAR VERMEMELISIN: [ionadjectives] SEYLER, VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ionadjectives] SEYLER"
						if(5) //X is a species
							message = "SUNA ZARAR VERMEMELISIN: [ionspecies] VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ionspecies]"
						if(6) //X is a job
							message = "SUNA ZARAR VERMEMELISIN: [ioncrew1] VE SUNUN ZARARA UGRAMASINI ENGELLEMELISIN: [ioncrew1]"
						if(7) //X is two jobs
							message = "SUNLARA ZARAR VERMEMELISIN: [ioncrew1] VE [ioncrew2] VE IKISININDE ZARARA UGRAMASINI ENGELLEMELISIN"

		if(37 to 39) //The X is currently Y	                       //Kelimelere ek getirilmesi gerekiyor.
			switch(rand(1,4)) //What is X?
				if(1) //X is a job
					switch(rand(1,4)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ioncrew1] [ionadjectiveshalf][ioncrew2] [ionverb]"
						if(2) //X is Ying a threat
							message = "[ioncrew1] [ionadjectiveshalf][ionthreats] [ionverb]"
						if(3) //X is Ying an abstract
							message = "[ioncrew1] [ionabstract] [ionverb]"
						if(4) //X is Ying an object
							message = "[ioncrew1] [ionadjectiveshalf][ionobjects] [ionverb]"

				if(2) //X is a threat
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionthreats] [ionadjectiveshalf][ioncrew2] [ionverb]"
						if(2) //X is Ying an abstract
							message = "[ionthreats] [ionabstract] [ionverb]"
						if(3) //X is Ying an object
							message = "[ionthreats] [ionadjectiveshalf][ionobjects] [ionverb]"

				if(3) //X is an object
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionobjects] [ionadjectiveshalf][ioncrew2] [ionverb] "
						if(2) //X is Ying a threat
							message = "[ionobjects] [ionadjectiveshalf][ionthreats] [ionverb]"
						if(3) //X is Ying an abstract
							message = "[ionobjects] [ionabstract] [ionverb]"

				if(4) //X is an abstract
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionabstract] [ionadjectiveshalf][ioncrew2] [ionverb]"
						if(2) //X is Ying a threat
							message = "[ionabstract] [ionadjectiveshalf][ionthreats] [ionverb]"
						if(3) //X is Ying an abstract
							message = "[ionabstract] [ionadjectiveshalf][ionobjects] [ionverb]"
		if(40 to 41)// the X is now named Y
			switch(rand(1,5)) //What is being renamed?
				if(1)//Areas
					switch(rand(1,4))//What is the area being renamed to?
						if(1)
							message = "[ionarea] ISMI DEGISTI, YENI ISMI: [ioncrew1]."
						if(2)
							message = "[ionarea] ISMI DEGISTI, YENI ISMI: [ionspecies]."
						if(3)
							message = "[ionarea] ISMI DEGISTI, YENI ISMI: [ionobjects]."
						if(4)
							message = "[ionarea] ISMI DEGISTI, YENI ISMI: [ionthreats]."
				if(2)//Crew
					switch(rand(1,5))//What is the crew being renamed to?
						if(1)
							message = "BUTUN [ioncrew1] ISMI DEGISTI, YENI ISMI: [ionarea]."
						if(2)
							message = "BUTUN [ioncrew1] ISMI DEGISTI, YENI ISMI: [ioncrew2]."
						if(3)
							message = "BUTUN [ioncrew1] ISMI DEGISTI, YENI ISMI: [ionspecies]."
						if(4)
							message = "BUTUN [ioncrew1] ISMI DEGISTI, YENI ISMI: [ionobjects]."
						if(5)
							message = "BUTUN [ioncrew1] ISMI DEGISTI, YENI ISMI: [ionthreats]."
				if(3)//Races
					switch(rand(1,4))//What is the race being renamed to?
						if(1)
							message = "BUTUN [ionspecies] ISMI DEGISTI, YENI ISMI: [ionarea]."
						if(2)
							message = "BUTUN [ionspecies] ISMI DEGISTI, YENI ISMI: [ioncrew1]."
						if(3)
							message = "BUTUN [ionspecies] ISMI DEGISTI, YENI ISMI: [ionobjects]."
						if(4)
							message = "BUTUN [ionspecies] ISMI DEGISTI, YENI ISMI: [ionthreats]."
				if(4)//Objects
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "BUTUN [ionobjects] ISMI DEGISTI, YENI ISMI: [ionarea]."
						if(2)
							message = "BUTUN [ionobjects] ISMI DEGISTI, YENI ISMI: [ioncrew1]."
						if(3)
							message = "BUTUN [ionobjects] ISMI DEGISTI, YENI ISMI: [ionspecies]."
						if(4)
							message = "BUTUN [ionobjects] ISMI DEGISTI, YENI ISMI: [ionthreats]."
				if(5)//Threats
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "BUTUN [ionthreats] ISMI DEGISTI, YENI ISMI: [ionarea]."
						if(2)
							message = "BUTUN [ionthreats] ISMI DEGISTI, YENI ISMI: [ioncrew1]."
						if(3)
							message = "BUTUN [ionthreats] ISMI DEGISTI, YENI ISMI: [ionspecies]."
						if(4)
							message = "BUTUN [ionthreats] ISMI DEGISTI, YENI ISMI: [ionobjects]."

	return message
