var/syndicate_name = null
/proc/syndicate_name()
	if (syndicate_name)
		return syndicate_name

	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	syndicate_name = name
	return name

//This is referenced in equip_traitor() so it's fairly easy to remove if needed.
//Added this to traitor AIs.
var/syndicate_code_phrase//Code phrase for traitors.
var/syndicate_code_response//Code response for traitors.

	/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	/N
	*/

/proc/generate_code_phrase()//Proc is used for phrase and response in master_controller.dm

	var/code_phrase = ""//What is returned when the proc finishes.
	var/words = pick(//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)

	var/safety[] = new()
	safety = list(1,2,3)//Tells the proc which options to remove later on.

	var/maxwords = words//Extra var to check for duplicates.

	while(words)//Randomly picks from one of the choices below.

		if(words==1&&safety.Find(1)&&safety.Find(2))//If there is only one word remaining and choice 1 or 2 have not been selected.
			safety = list(pick(1,2))//Select choice 1 or 2.
		else if(words==1&&maxwords==2)//Else if there is only one word remaining (and there were two originally), and 1 or 2 were chosen,
			safety = list(3)//Default to list 3

		switch(pick(safety))//Chance based on the safety list.
			if(1)//1 and 2 can only be selected once each to prevent more than two specific names/places/etc.
				switch(rand(1,2))//Mainly to add more options later.
					if(1)
						var/name_list[] = list()
						for(var/datum/data/record/t in data_core.general)//Picks from crew manifest.
							name_list.Add(t.fields["name"])
						if(name_list.len&&prob(70))
							code_phrase += pick(name_list)
						else
							code_phrase += pick(pick(first_names_male,first_names_female))
							code_phrase += " "
							code_phrase += pick(last_names)
					if(2)
						code_phrase += pick(get_all_jobs())//Returns a job.
				safety.Remove(1)
			if(2)
				switch(rand(1,2))//Places or things.
					if(1)
						code_phrase += pick("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepksy Smash","tequilla sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini","Cuba libre","kahlua","vodka","wine","moonshine")
					if(2)
						if(teleportlocs.len) //tired of those runtime errors -- Urist
							code_phrase += "[pick(teleportlocs)]"//Returns a place.
						else
							code_phrase += pick("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepksy Smash","tequilla sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini","Cuba libre","kahlua","vodka","wine","moonshine")
				safety.Remove(2)
			if(3)
				switch(rand(1,3))//Nouns, adjectives, verbs. Can be selected more than once.
					if(1)
						code_phrase += pick("love","hate","anger","peace","pride","sympathy","bravery","loyalty","honesty","integrity","compassion","charity","success","courage","deceit","skill","beauty","brilliance","pain","misery","beliefs","dreams","justice","truth","faith","liberty","knowledge","thought","information","culture","trust","dedication","progress","education","hospitality","leisure","trouble","friendships", "relaxation")
					if(2)
						code_phrase += pick(adjectives)
					if(3)
						code_phrase += pick(verbs)
		if(words==1)
			code_phrase += "."
		else
			code_phrase += ", "
		words--

	return code_phrase

/*
//This proc tests the gen above.
/client/verb/test_code_phrase()
	set name = "Generate Code Phrase"
	set category = "Debug"

	world << "\red Code Phrase is: \black [generate_code_phrase()]"
	return


	This was an earlier attempt at code phrase system, aside from an even earlier attempt (and failure).
	This system more or less works as intended--aside from being unfinished--but it's still very predictable.
	Particularly, the phrase opening statements are pretty easy to recognize and identify when metagaming.
	I think the above-used method solves this issue by using words in a sequence, providing for much greater flexibility.
	/N

	switch(choice)
		if(1)
			syndicate_code_phrase += pick("I'm looking for","Have you seen","Maybe you've seen","I'm trying to find","I'm tracking")
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick(pick(first_names_male,first_names_female))
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick(last_names)
			syndicate_code_phrase += "."
		if(2)
			syndicate_code_phrase += pick("How do I get to","How do I find","Where is","Where do I find")
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick("Escape","Engineering","Atmos","the bridge","the brig","Clown Planet","CentCom","the library","the chapel","a bathroom","Med Bay","Tool Storage","the escape shuttle","Robotics","a locker room","the living quarters","the gym","the autolathe","QM","the bar","the theater","the derelict")
			syndicate_code_phrase += "?"
		if(3)
			if(prob(70))
				syndicate_code_phrase += pick("Get me","I want","I'd like","Make me")
				syndicate_code_phrase += " a "
			else
				syndicate_code_phrase += pick("One")
				syndicate_code_phrase += " "
			syndicate_code_phrase += pick("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepksy Smash","tequilla sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini","Cuba libre","kahlua","vodka","wine","moonshine")
			syndicate_code_phrase += "."
		if(4)
			syndicate_code_phrase += pick("I wish I was","My dad was","His mom was","Where do I find","The hero this station needs is","I'd fuck","I wouldn't trust","Someone caught","HoS caught","Someone found","I'd wrestle","I wanna kill")
			syndicate_code_phrase += " [pick("a","the")] "
			syndicate_code_phrase += pick("wizard","ninja","xeno","lizard","metroid","monkey","syndicate","cyborg","clown","space carp","singularity","singulo","mime")
			syndicate_code_phrase += "."
		if(5)
			syndicate_code_phrase += pick("Do we have","Is there","Where is","Where's","Who's")
			syndicate_code_phrase += " "
			syndicate_code_phrase += "[pick(get_all_jobs())]"
			syndicate_code_phrase += "?"

	switch(choice)
		if(1)
			if(prob(80))
				syndicate_code_response += pick("Try looking for them near","I they ran off to","Yes. I saw them near","Nope. I'm heading to","Try searching")
				syndicate_code_response += " "
				syndicate_code_response += pick("Escape","Engineering","Atmos","the bridge","the brig","Clown Planet","CentCom","the library","the chapel","a bathroom","Med Bay","Tool Storage","the escape shuttle","Robotics","a locker room","the living quarters","the gym","the autolathe","QM","the bar","the theater","the derelict")
				syndicate_code_response += "."
			else if(prob(60))
				syndicate_code_response += pick("No. I'm busy, sorry.","I don't have the time.","Not sure, maybe?","There is no time.")
			else
				syndicate_code_response += pick("*shrug*","*smile*","*blink*","*sigh*","*laugh*","*nod*","*giggle*")
		if(2)
			if(prob(80))
				syndicate_code_response += pick("Go to","Navigate to","Try","Sure, run to","Try searching","It's near","It's around")
				syndicate_code_response += " the "
				syndicate_code_response += pick("[pick("south","north","east","west")] maitenance door","nearby maitenance","teleporter","[pick("cold","dead")] space","morgue","vacuum","[pick("south","north","east","west")] hall ","[pick("south","north","east","west")] hallway","[pick("white","black","red","green","blue","pink","purple")] [pick("rabbit","frog","lion","tiger","panther","snake","facehugger")]")
				syndicate_code_response += "."
			else if(prob(60))
				syndicate_code_response += pick("Try asking","Ask","Talk to","Go see","Follow","Hunt down")
				syndicate_code_response += " "
				if(prob(50))
					syndicate_code_response += pick(pick(first_names_male,first_names_female))
					syndicate_code_response += " "
					syndicate_code_response += pick(last_names)
				else
					syndicate_code_response += " the "
					syndicate_code_response += "[pic(get_all_jobs())]"
				syndicate_code_response += "."
			else
				syndicate_code_response += pick("*shrug*","*smile*","*blink*","*sigh*","*laugh*","*nod*","*giggle*")
		if(3)
		if(4)
		if(5)

	return
*/