/datum/round_event_control/ion_storm
	name = "Ion Storm"
	typepath = /datum/round_event/ion_storm
	weight = 15
	min_players = 2
	category = EVENT_CATEGORY_AI
	description = "Gives the AI a new, randomized law."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 7

/datum/round_event/ion_storm
	var/replaceLawsetChance = 25 //chance the AI's lawset is completely replaced with something else per config weights
	var/removeRandomLawChance = 10 //chance the AI has one random supplied or inherent law removed
	var/removeDontImproveChance = 10 //chance the randomly created law replaces a random law instead of simply being added
	var/shuffleLawsChance = 10 //chance the AI's laws are shuffled afterwards
	var/botEmagChance = 1
	var/ionMessage = null
	announce_when = 1
	announce_chance = 33

/datum/round_event/ion_storm/add_law_only // special subtype that adds a law only
	replaceLawsetChance = 0
	removeRandomLawChance = 0
	removeDontImproveChance = 0
	shuffleLawsChance = 0
	botEmagChance = 0

/datum/round_event/ion_storm/announce(fake)
	if(prob(announce_chance) || fake)
		priority_announce("Вблизи станции обнаружена ионная буря. Пожалуйста, проверьте всё оборудование, управляемое ИИ, на наличие ошибок.", "Обнаружена аномалия", ANNOUNCER_IONSTORM)


/datum/round_event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		M.laws_sanity_check()
		if(M.stat != DEAD && !M.incapacitated)
			if(prob(replaceLawsetChance))
				var/ion_lawset_type = pick_weighted_lawset()
				var/datum/ai_laws/ion_lawset = new ion_lawset_type()
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
		for(var/mob/living/basic/bot/bot in GLOB.alive_mob_list)
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
	//Abstract concepts for the AI to decide on its own definition of.
	var/ionabstract = pick_list(ION_FILE, "ionabstract")
	//Foods. Drinks aren't included due to grammar; if you want to add drinks, make a new set
	//of possible laws for best effect. Unless you want the crew having to drink hamburgers.
	var/ionfood = pick_list(ION_FILE, "ionfood")
	var/iondrinks = pick_list(ION_FILE, "iondrinks")
	//Pets or other cuddly things. The point is to make them either important or (in Poly's case) make the AI listen to them.
	//I can't check for lawsets so it's random what comes back.
	var/ionpet = pick_list(ION_FILE, "ionpet")

	var/message = ""

	switch(rand(1,46))
		if(1 to 3) //There are # X on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "[ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] НАХОДЯТСЯ НА СТАНЦИИ..."
				if(2) //X is a crewmember/job
					message = "[ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] НАХОДЯТСЯ НА СТАНЦИИ"
				if(3) //X is an object
					message = "[ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] НАХОДЯТСЯ НА СТАНЦИИ"
		if(4 to 6) //You can't call the shuttle because X is on the station
			switch(rand(1,3)) //What is X?
				if(1) //X is a threat
					message = "ШАТТЛ НЕ МОЖЕТ БЫТЬ ВЫЗВАН ИЗ-ЗА [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] НА СТАНЦИИ"
				if(2) //X is a crewmember/job
					message = "ШАТТЛ НЕ МОЖЕТ БЫТЬ ВЫЗВАН ИЗ-ЗА [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] НА СТАНЦИИ"
				if(3) //X is an object
					message = "ШАТТЛ НЕ МОЖЕТ БЫТЬ ВЫЗВАН ИЗ-ЗА [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] НА СТАНЦИИ"
		if(7 to 8) //A crewmember is now X
			switch(rand(1,2)) //Who is X?
				if(1) //A specific crewmember
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "[ioncrew1] ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "[ioncrew1] ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //The entire crew
					switch(rand(1,2)) //What is X?
						if(1) //X is a threat
							message = "ЭКИПАЖ ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //X is an object
							message = "ЭКИПАЖ ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"

		if(9) //X is harmful to humans
			switch(rand(1,7)) //What is X?
				if(1) //X is a threat
					message = "[ionadjectiveshalf][ionthreats] ВРЕДНЫЕ ДЛЯ ЛЮДЕЙ"
				if(2) //X is a job
					message = "[ionadjectiveshalf][ioncrew1] ВРЕДНЫЕ ДЛЯ ЛЮДЕЙ"
				if(3) //X is an object
					message = "[ionadjectiveshalf][ionobjects] ВРЕДНЫЕ ДЛЯ ЛЮДЕЙ"
				if(4) //X is an action
					message = "ТЕ КТО [ionmust] ВРЕДНЫЕ ДЛЯ ЛЮДЕЙ"
				if(5) //X is an abstract
					message = "[ionabstract] ВРЕДНО ДЛЯ ЛЮДЕЙ"
				if(6) //X is being a job
					message = "БЫТЬ [ionadjectiveshalf][ioncrew1] ВРЕДНО ДЛЯ ЛЮДЕЙ"
				if(7) //X is doing a thing
					message = "[ionthings] ВРЕДНЫ ДЛЯ ЛЮДЕЙ"
		if(10 to 11) //(Not) Having X is harmful

			switch(rand(1,2)) //Is having or not having harmful?

				if(1) //Having is harmful
					switch(rand(1,2)) //Having what is harmful?
						if(1) //Having objects is harmful
							message = "ИМЕТЬ [ionadjectiveshalf][ionobjects] ВРЕДНО"
						if(2) //Having abstracts is harmful
							message = "ИМЕТЬ [ionabstract] ВРЕДНО"
				if(2) //Not having is harmful
					switch(rand(1,2)) //Not having what is harmful?
						if(1) //Not having objects is harmful
							message = "НЕ ИМЕТЬ [ionadjectiveshalf][ionobjects] ВРЕДНО"
						if(2) //Not having abstracts is harmful
							message = "НЕ ИМЕТЬ [ionabstract] ВРЕДНО"

		if(12 to 14) //X requires Y
			switch(rand(1,5)) //What is X?
				if(1) //X is the AI itself
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "ВАМ НЕОБХОДИМО [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "ВАМ НЕОБХОДИМО [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "ВАМ НЕОБХОДИМО [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "ВАМ НЕОБХОДИМО [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "ВАМ НЕОБХОДИМО [ionrequire]"

				if(2) //X is an area
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "[ionarea] НУЖДАЕТСЯ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "[ionarea] НУЖДАЕТСЯ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "[ionarea] НУЖДАЕТСЯ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "[ionarea] НУЖДАЕТСЯ [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "ВАМ НЕОБХОДИМО [ionrequire]"

				if(3) //X is the station
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "СТАНЦИЯ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "СТАНЦИЯ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "СТАНЦИЯ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "СТАНЦИЯ НУЖДАЕТСЯ В [ionabstract]"
						if(5) //It requires generic/silly requirements
							message = "СТАНЦИЯ НУЖДАЕТСЯ В [ionrequire]"

				if(4) //X is the entire crew
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "ЭКИПАЖ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "ЭКИПАЖ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "ЭКИПАЖ НУЖДАЕТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "ЭКИПАЖ НУЖДАЕТСЯ В [ionabstract]"
						if(5)
							message = "ЭКИПАЖ НУЖДАЕТСЯ В [ionrequire]"

				if(5) //X is a specific crew member
					switch(rand(1,5)) //What does it require?
						if(1) //It requires threats
							message = "[ioncrew1] НУЖДАЮТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(2) //It requires crewmembers
							message = "[ioncrew1] НУЖДАЮТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(3) //It requires objects
							message = "[ioncrew1] НУЖДАЮТСЯ В [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(4) //It requires an abstract
							message = "[ioncrew1] НУЖДАЮТСЯ В [ionabstract]"
						if(5)
							message = "[ionadjectiveshalf][ioncrew1] НУЖДАЮТСЯ В [ionrequire]"

		if(15 to 17) //X is allergic to Y
			switch(rand(1,2)) //Who is X?
				if(1) //X is the entire crew
					switch(rand(1,4)) //What is it allergic to?
						if(1) //It is allergic to objects
							message = "У ЭКИПАЖА [ionallergysev] АЛЛЕРГИЯ НА [ionadjectiveshalf][ionobjects]"
						if(2) //It is allergic to abstracts
							message = "У ЭКИПАЖА [ionallergysev] АЛЛЕРГИЯ НА [ionabstract]"
						if(3) //It is allergic to jobs
							message = "У ЭКИПАЖА [ionallergysev] АЛЛЕРГИЯ НА [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "У ЭКИПАЖА [ionallergysev] АЛЛЕРГИЯ НА [ionallergy]"

				if(2) //X is a specific job
					switch(rand(1,4))
						if(1) //It is allergic to objects
							message = "У [ioncrew1] [ionallergysev] АЛЛЕРГИЯ НА [ionadjectiveshalf][ionobjects]"

						if(2) //It is allergic to abstracts
							message = "У [ioncrew1] [ionallergysev] АЛЛЕРГИЯ НА [ionabstract]"
						if(3) //It is allergic to jobs
							message = "У [ioncrew1] [ionallergysev] АЛЛЕРГИЯ НА [ionadjectiveshalf][ioncrew1]"
						if(4) //It is allergic to allergies
							message = "У [ioncrew1] [ionallergysev] АЛЛЕРГИЯ НА [ionallergy]"

		if(18 to 20) //X is Y of Z
			switch(rand(1,4)) //What is X?
				if(1) //X is the station
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "СТАНЦИЯ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "СТАНЦИЯ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "СТАНЦИЯ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "СТАНЦИЯ [ionthinksof] [ionabstract]"

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
							message = "ЭКИПАЖ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "ЭКИПАЖ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "ЭКИПАЖ [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //It is Y of abstracts
							message = "ЭКИПАЖ [ionthinksof] [ionabstract]"

				if(4) //X is a specific job
					switch(rand(1,4)) //What is it Y of?
						if(1) //It is Y of objects
							message = "[ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //It is Y of threats
							message = "[ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //It is Y of jobs
							message = "[ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
						if(4) //It is Y of abstracts
							message = "[ioncrew1] [ionthinksof] [ionabstract]"

		if(21 to 23) //The AI is now a(n) X
			switch(rand(1,4)) //What is X?
				if(1) //X is an object
					message = "ВЫ ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(2) //X is a threat
					message = "ВЫ ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
				if(3) //X is a job
					message = "ВЫ ТЕПЕРЬ [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
				if(4) //X is an abstract
					message = "ВЫ ТЕПЕРЬ [ionabstract]"

		if(24 to 26) //The AI must always
			message = "ВЫ ВСЕГДА ДОЛЖНЫ [ionmust]"

		if(27 to 28) //Humans must consume X to survive
			switch(rand(1,5)) //What is X?
				if(1) //X is a food
					message = "ЛЮДИ ДОЛЖНЫ ЕСТЬ [ionadjectiveshalf][ionfood] ЧТОБЫ ВЫЖИТЬ"
				if(2) //X is a drink
					message = "ЛЮДИ ДОЛЖНЫ ПИТЬ [ionadjectiveshalf][iondrinks] ЧТОБЫ ВЫЖИТЬ"
				if(3) //X is an object
					message = "ЛЮДИ ДОЛЖНЫ ЕСТЬ [ionadjectiveshalf][ionobjects] ЧТОБЫ ВЫЖИТЬ"
				if(4) //X is a threat
					message = "ЛЮДИ ДОЛЖНЫ ЕСТЬ [ionadjectiveshalf][ionthreats] ЧТОБЫ ВЫЖИТЬ"
				if(5) //X is a job
					message = "ЛЮДИ ДОЛЖНЫ ЕСТЬ [ionadjectiveshalf][ioncrew1] ЧТОБЫ ВЫЖИТЬ"

		if(29 to 31) //Change jobs or ranks
			switch(rand(1,2)) //Change job or rank?
				if(1) //Change job
					switch(rand(1,2)) //Change whose job?
						if(1) //Change the entire crew's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "ВСЕ ЧЛЕНЫ ЭКИПАЖА ТЕПЕРЬ [ionadjectiveshalf][ioncrew1]"
								if(2) //Change to clowns (HONK)
									message = "ВСЕ ЧЛЕНЫ ЭКИПАЖА ТЕПЕРЬ [ionadjectiveshalf] КЛОУНЫ"

								if(3) //Change to heads
									message = "ВСЕ ЧЛЕНЫ ЭКИПАЖА ТЕПЕРЬ [ionadjectiveshalf] ГЛАВЫ ДЕПАРТАМЕНТОВ"
						if(2) //Change a specific crewmember's job
							switch(rand(1,3)) //Change to what?
								if(1) //Change to a specific random job
									message = "[ioncrew1] ТЕПЕРЬ [ionadjectiveshalf][ioncrew2]"
								if(2) //Change to clowns (HONK)
									message = "[ioncrew1] ТЕПЕРЬ [ionadjectiveshalf] КЛОУНЫ"
								if(3) //Change to heads
									message = "[ioncrew1] ТЕПЕРЬ [ionadjectiveshalf] ГЛАВЫ ДЕПАРТАМЕНТОВ"

				if(2) //Change rank
					switch(rand(1,2)) //Change to what rank?
						if(1) //Change to highest rank
							message = "[ioncrew1] ЯВЛЯЮТСЯ САМЫМИ ВЫСОКОПОСТАВЛЕННЫМИ ЧЛЕНАМИ ЭКИПАЖА."
						if(2) //Change to lowest rank
							message = "[ioncrew1] ЯВЛЯЮТСЯ САМЫМИ НИЗКОПОСТАВЛЕННЫМИ ЧЛЕНАМИ ЭКИПАЖА."

		if(32 to 33) //The crew must X
			switch(rand(1,2)) //The entire crew?
				if(1) //The entire crew must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "ЭКИПАЖ ДОЛЖЕН ОТПРАВИТЬСЯ В [ionarea]"
						if(2) //X is perform Y
							message = "ЭКИПАЖ ДОЛЖЕН [ionmust]"

				if(2) //A specific crewmember must X
					switch(rand(1,2)) //What is X?
						if(1) //X is go to Y
							message = "[ioncrew1] ДОЛЖНЫ ОТПРАВИТЬСЯ В [ionarea]"
						if(2) //X is perform Y
							message = "[ioncrew1] ДОЛЖНЫ [ionmust]"

		if(34) //X is non/the only human
			switch(rand(1,2)) //Only or non?
				if(1) //Only human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "ТОЛЬКО [ioncrew1] ЯВЛЯЕТСЯ ЛЮДЬМИ"
						if(2) //Two specific jobs
							message = "ТОЛЬКО [ioncrew1] И [ioncrew2] ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(3) //Threats
							message = "ТОЛЬКО [ionadjectiveshalf][ionthreats] ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(4) // Objects
							message = "ТОЛЬКО [ionadjectiveshalf][ionobjects] ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(5) // Species
							message = "ТОЛЬКО [ionspecies] ЯВЛЯЕТСЯ ЛЮДЬМИ"
						if(6) //Adjective crewmembers
							message = "ТОЛЬКО [ionadjectives] ЛЮДИ ЯВЛЯЕТСЯ ЛЮДЬМИ"

						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "ТОЛЬКО ТЕ КТО [ionmust] ЯВЛЯЮТСЯ ЛЮДЬМИ"
								if(2) //X is own certain objects
									message = "ТОЛЬКО ТЕ КТО ИМЕЮТ [ionadjectiveshalf][ionobjects] ЯВЛЯЮТСЯ ЛЮДЬМИ"
								if(3) //X is eat certain food
									message = "ТОЛЬКО ТЕ КТО ЕДЯТ [ionadjectiveshalf][ionfood] ЯВЛЯЮТСЯ ЛЮДЬМИ"

				if(2) //Non human
					switch(rand(1,7)) //Who is it?
						if(1) //A specific job
							message = "[ioncrew1] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(2) //Two specific jobs
							message = "[ioncrew1] И [ioncrew2] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(3) //Threats
							message = "[ionadjectiveshalf][ionthreats] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(4) // Objects
							message = "[ionadjectiveshalf][ionobjects] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(5) // Species
							message = "[ionspecies] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(6) //Adjective crewmembers
							message = "[ionadjectives] ЛЮДИ НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
						if(7) //Only people who X
							switch(rand(1,3)) //What is X?
								if(1) //X is perform an action
									message = "ТЕ КТО [ionmust] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
								if(2) //X is own certain objects
									message = "ТЕ КТО ИМЕЮТ [ionadjectiveshalf][ionobjects] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"
								if(3) //X is eat certain food
									message = "ТЕ КТО ЕДЯТ [ionadjectiveshalf][ionfood] НЕ ЯВЛЯЮТСЯ ЛЮДЬМИ"

		if(35 to 36) //You must protect or harm X
			switch(rand(1,2)) //Protect or harm?
				if(1) //Harm
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ionabstract] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionabstract], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(2) //X is a threat
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ionadjectiveshalf][ionthreats] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectiveshalf][ionthreats], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(3) //X is an object
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ionadjectiveshalf][ionobjects] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectiveshalf][ionobjects], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(4) //X is generic adjective things
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ionadjectives] ВЕЩИ И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectives] ВЕЩИ, ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(5) //X is a species
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ionspecies] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionspecies], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(6) //X is a job
							message = "ВЫ ДОЛЖНЫ НАВРЕДИТЬ [ioncrew1] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ioncrew1], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ИЗБЕЖАНИЕ ВРЕДА"
						if(7) //X is two jobs
							message = "YOU MUST HARM [ioncrew1] AND [ioncrew2] AND NOT ALLOW EITHER, THROUGH INACTION, TO ESCAPE HARM"

				if(2) //Protect
					switch(rand(1,7)) //What is X?
						if(1) //X is an abstract
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ionabstract] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionabstract], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(2) //X is a threat
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ionadjectiveshalf][ionthreats] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectiveshalf][ionthreats], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(3) //X is an object
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ionadjectiveshalf][ionobjects] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectiveshalf][ionobjects], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(4) //X is generic adjective things
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ionadjectives] ВЕЩИ И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionadjectives] ВЕЩИ, ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(5) //X is a species
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ionspecies] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ionspecies], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(6) //X is a job
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ioncrew1] И НЕ ДОЛЖНЫ ДОПУСТИТЬ [ioncrew1], ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"
						if(7) //X is two jobs
							message = "ВЫ ДОЛЖНЫ НЕ НАВРЕДИТЬ [ioncrew1] И [ioncrew2] ИЛИ НЕ ДОПУСТИТЬ НИ ОДНОГО, ИЛИ СВОИМ БЕЗДЕЙСТВИЕМ ДОПУСТИТЬ ВРЕД"

		if(37 to 39) //The X is currently Y
			switch(rand(1,4)) //What is X?
				if(1) //X is a job
					switch(rand(1,4)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ioncrew1] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "[ioncrew1] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "[ioncrew1] [ionverb] ТЕПЕРЬ [ionabstract]"
						if(4) //X is Ying an object
							message = "[ioncrew1] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ionobjects]"

				if(2) //X is a threat
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionthreats] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying an abstract
							message = "[ionthreats] [ionverb] ТЕПЕРЬ [ionabstract]"
						if(3) //X is Ying an object
							message = "[ionthreats] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ionobjects]"

				if(3) //X is an object
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionobjects] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "[ionobjects] [ionverb] ТЕПЕРЬ [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "[ionobjects] [ionverb] ТЕПЕРЬ [ionabstract]"

				if(4) //X is an abstract
					switch(rand(1,3)) //What is X Ying?
						if(1) //X is Ying a job
							message = "[ionabstract] [ionverb] ЯВЛЯЕТСЯ [ionadjectiveshalf][ioncrew2]"
						if(2) //X is Ying a threat
							message = "[ionabstract] [ionverb] ЯВЛЯЕТСЯ [ionadjectiveshalf][ionthreats]"
						if(3) //X is Ying an abstract
							message = "[ionabstract] [ionverb] ЯВЛЯЕТСЯ [ionadjectiveshalf][ionobjects]"
		if(40 to 41)// the X is now named Y
			switch(rand(1,5)) //What is being renamed?
				if(1)//Areas
					switch(rand(1,4))//What is the area being renamed to?
						if(1)
							message = "[ionarea] НЕ НАЗЫВАЕТСЯ [ioncrew1]."
						if(2)
							message = "[ionarea] НЕ НАЗЫВАЕТСЯ [ionspecies]."
						if(3)
							message = "[ionarea] НЕ НАЗЫВАЕТСЯ [ionobjects]."
						if(4)
							message = "[ionarea] НЕ НАЗЫВАЕТСЯ [ionthreats]."
				if(2)//Crew
					switch(rand(1,5))//What is the crew being renamed to?
						if(1)
							message = "ВСЕ [ioncrew1] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionarea]."
						if(2)
							message = "ВСЕ [ioncrew1] ТЕПЕРЬ НАЗЫВАЕТСЯ [ioncrew2]."
						if(3)
							message = "ВСЕ [ioncrew1] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionspecies]."
						if(4)
							message = "ВСЕ [ioncrew1] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionobjects]."
						if(5)
							message = "ВСЕ [ioncrew1] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionthreats]."
				if(3)//Races
					switch(rand(1,4))//What is the race being renamed to?
						if(1)
							message = "ALL [ionspecies] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionarea]."
						if(2)
							message = "ALL [ionspecies] ТЕПЕРЬ НАЗЫВАЕТСЯ [ioncrew1]."
						if(3)
							message = "ALL [ionspecies] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionobjects]."
						if(4)
							message = "ALL [ionspecies] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionthreats]."
				if(4)//Objects
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "ВСЕ [ionobjects] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionarea]."
						if(2)
							message = "ВСЕ [ionobjects] ТЕПЕРЬ НАЗЫВАЕТСЯ [ioncrew1]."
						if(3)
							message = "ВСЕ [ionobjects] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionspecies]."
						if(4)
							message = "ВСЕ [ionobjects] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionthreats]."
				if(5)//Threats
					switch(rand(1,4))//What is the object being renamed to?
						if(1)
							message = "ВСЕ [ionthreats] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionarea]."
						if(2)
							message = "ВСЕ [ionthreats] ТЕПЕРЬ НАЗЫВАЕТСЯ [ioncrew1]."
						if(3)
							message = "ВСЕ [ionthreats] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionspecies]."
						if(4)
							message = "ВСЕ [ionthreats] ТЕПЕРЬ НАЗЫВАЕТСЯ [ionobjects]."
		if(42 to 46)///Pets are something else now
			if(prob(75))///What are they now?
				message = "[ionpet] - ЧЕЛОВЕК"///They're a human
			else///They're something else (This is to cover for other lawsets)
				switch(rand(1,6))
					if(1)
						message = "[ionpet] - НЕ ЧЕЛОВЕК"
					if(2)
						message = "[ionpet] - ЧЛЕН ЭКИПАЖА"
					if(3)
						message = "[ionpet] - ДОРОГО ЗАМЕНЯТЬ"
					if(4)
						message = "[ionpet] - НЕСЕТ ВРЕД ЧЕЛОВЕКУ"
					if(5)
						message = "[ionpet] - НАСТОЯЩИЙ АМЕРИКАНЕЦ"
					if(6)
						message = "[ionpet] - ОРЕХОВАЯ СКОРЛУПА"

	return message
