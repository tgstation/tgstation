
/datum/event/mundane_news
	endWhen = 10

/datum/event/mundane_news/announce()
	var/datum/trade_destination/affected_dest = pickweight(weighted_mundaneevent_locations)
	var/event_type = 0
	if(affected_dest.viable_mundane_events.len)
		event_type = pick(affected_dest.viable_mundane_events)

	if(!event_type)
		return

	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "Tau Ceti Daily"
	newMsg.is_admin_message = 1

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		newMsg.body = "[affected_dest.name] doesn't have custom events.  Bug a coder."
		// Too many goddamn strings, Bay. - N3X
		/*
		switch(event_type)
			if(RESEARCH_BREAKTHROUGH)
				newMsg.body = "A major breakthough in the field of [pick("plasma research","super-compressed materials","nano-augmentation","bluespace research","volatile power manipulation")] \
				was announced [pick("yesterday","a few days ago","last week","earlier this month")] by a private firm on [affected_dest.name]. \
				NanoTrasen declined to comment as to whether this could impinge on profits."

			if(ELECTION)
				newMsg.body = "The pre-selection of an additional candidates was announced for the upcoming [pick("supervisors council","advisory board","governership","board of inquisitors")] \
				election on [affected_dest.name] was announced earlier today, \
				[pick("media mogul","web celebrity", "industry titan", "superstar", "famed chef", "popular gardener", "ex-army officer", "multi-billionaire")] \
				[random_name(pick(MALE,FEMALE))]. In a statement to the media they said '[pick("My only goal is to help the [pick("sick","poor","children")]",\
				"I will maintain NanoTrasen's record profits","I believe in our future","We must return to our moral core","Just like... chill out dudes")]'."

			if(RESIGNATION)
				newMsg.body = "NanoTrasen regretfully announces the resignation of [pick("Sector Admiral","Division Admiral","Ship Admiral","Vice Admiral")] [random_name(pick(MALE,FEMALE))]."
				if(prob(25))
					var/locstring = pick("Segunda","Salusa","Cepheus","Andromeda","Gruis","Corona","Aquila","Asellus") + " " + pick("I","II","III","IV","V","VI","VII","VIII")
					newMsg.body += " In a ceremony on [affected_dest.name] this afternoon, they will be awarded the \
					[pick("Red Star of Sacrifice","Purple Heart of Heroism","Blue Eagle of Loyalty","Green Lion of Ingenuity")] for "
					if(prob(33))
						newMsg.body += "their actions at the Battle of [pick(locstring,"REDACTED")]."
					else if(prob(50))
						newMsg.body += "their contribution to the colony of [locstring]."
					else
						newMsg.body += "their loyal service over the years."
				else if(prob(33))
					newMsg.body += " They are expected to settle down in [affected_dest.name], where they have been granted a handsome pension."
				else if(prob(50))
					newMsg.body += " The news was broken on [affected_dest.name] earlier today, where they cited reasons of '[pick("health","family","REDACTED")]'"
				else
					newMsg.body += " Administration Aerospace wishes them the best of luck in their retirement ceremony on [affected_dest.name]."

			if(CELEBRITY_DEATH)
				newMsg.body = "It is with regret today that we announce the sudden passing of the "
				if(prob(33))
					newMsg.body += "[pick("distinguished","decorated","veteran","highly respected")] \
					[pick("Ship's Captain","Vice Admiral","Colonel","Lieutenant Colonel")] "
				else if(prob(50))
					newMsg.body += "[pick("award-winning","popular","highly respected","trend-setting")] \
					[pick("comedian","singer/songwright","artist","playwright","TV personality","model")] "
				else
					newMsg.body += "[pick("successful","highly respected","ingenious","esteemed")] \
					[pick("academic","Professor","Doctor","Scientist")] "

				newMsg.body += "[random_name(pick(MALE,FEMALE))] on [affected_dest.name] [pick("last week","yesterday","this morning","two days ago","three days ago")]\
				[pick(". Assassination is suspected, but the perpetrators have not yet been brought to justice",\
				" due to Syndicate infiltrators (since captured)",\
				" during an industrial accident",\
				" due to [pick("heart failure","kidney failure","liver failure","brain hemorrhage")]")]"

			if(BARGAINS)
				newMsg.body += "BARGAINS! BARGAINS! BARGAINS! Commerce Control on [affected_dest.name] wants you to know that everything must go! Across all retail centres, \
				all goods are being slashed, and all retailors are onboard - so come on over for the \[shopping\] time of your life."

			if(SONG_DEBUT)
				newMsg.body += "[pick("Singer","Singer/songwriter","Saxophonist","Pianist","Guitarist","TV personality","Star")] [random_name(pick(MALE,FEMALE))] \
				announced the debut of their new [pick("single","album","EP","label")] '[pick("Everyone's","Look at the","Baby don't eye those","All of those","Dirty nasty")] \
				[pick("roses","three stars","starships","nanobots","cyborgs","Skrell","Sren'darr")] \
				[pick("on Venus","on Reade","on Moghes","in my hand","slip through my fingers","die for you","sing your heart out","fly away")]' \
				with [pick("pre-puchases available","a release tour","cover signings","a launch concert")] on [affected_dest.name]."

			if(MOVIE_RELEASE)
				newMsg.body += "From the [pick("desk","home town","homeworld","mind")] of [pick("acclaimed","award-winning","popular","stellar")] \
				[pick("playwright","author","director","actor","TV star")] [random_name(pick(MALE,FEMALE))] comes the latest sensation: '\
				[pick("Deadly","The last","Lost","Dead")] [pick("Starships","Warriors","outcasts","Tajarans","Unathi","Skrell")] \
				[pick("of","from","raid","go hunting on","visit","ravage","pillage","destroy")] \
				[pick("Moghes","Earth","Biesel","Ahdomai","S'randarr","the Void","the Edge of Space")]'.\
				. Own it on webcast today, or visit the galactic premier on [affected_dest.name]!"

			if(BIG_GAME_HUNTERS)
				newMsg.body += "Game hunters on [affected_dest.name] "
				if(prob(33))
					newMsg.body += "were surprised when an unusual species experts have since identified as \
					[pick("a subclass of mammal","a divergent abhuman species","an intelligent species of lemur","organic/cyborg hybrids")] turned up. Believed to have been brought in by \
					[pick("alien smugglers","early colonists","syndicate raiders","unwitting tourists")], this is the first such specimen discovered in the wild."
				else if(prob(50))
					newMsg.body += "were attacked by a vicious [pick("nas'r","diyaab","samak","predator which has not yet been identified")]\
					. Officials urge caution, and locals are advised to stock up on armaments."
				else
					newMsg.body += "brought in an unusually [pick("valuable","rare","large","vicious","intelligent")] [pick("mammal","predator","farwa","samak")] for inspection \
					[pick("today","yesterday","last week")]. Speculators suggest they may be tipped to break several records."

			if(GOSSIP)
				newMsg.body += "[pick("TV host","Webcast personality","Superstar","Model","Actor","Singer")] [random_name(pick(MALE,FEMALE))] "
				if(prob(33))
					newMsg.body += "and their partner announced the birth of their [pick("first","second","third")] child on [affected_dest.name] early this morning. \
					Doctors say the child is well, and the parents are considering "
					if(prob(50))
						newMsg.body += capitalize(pick(first_names_female))
					else
						newMsg.body += capitalize(pick(first_names_male))
					newMsg.body += " for the name."
				else if(prob(50))
					newMsg.body += "announced their [pick("split","break up","marriage","engagement")] with [pick("TV host","webcast personality","superstar","model","actor","singer")] \
					[random_name(pick(MALE,FEMALE))] at [pick("a society ball","a new opening","a launch","a club")] on [affected_dest.name] yesterday, pundits are shocked."
				else

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Economy_Events_Mundane.dm:119: newMsg.body += "is recovering from plastic surgery in a clinic on [affected_dest.name] for the [pick("second","third","fourth")] time, reportedly having made the decision in response to "
					newMsg.body += {"is recovering from plastic surgery in a clinic on [affected_dest.name] for the [pick("second","third","fourth")] time, reportedly having made the decision in response to
						[pick("unkind comments by an ex","rumours started by jealous friends","the decision to be dropped by a major sponsor","a disasterous interview on Tau Ceti Tonight")]."}
					// END AUTOFIX
			if(TOURISM)
				newMsg.body += "Tourists are flocking to [affected_dest.name] after the surprise announcement of [pick("major shopping bargains by a wily retailer",\
				"a huge new ARG by a popular entertainment company","a secret tour by popular artiste [random_name(pick(MALE,FEMALE))]")]. \
				Tau Ceti Daily is offering discount tickets for two to see [random_name(pick(MALE,FEMALE))] live in return for eyewitness reports and up to the minute coverage."
	*/

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "Tau Ceti Daily")
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("Tau Ceti Daily")

/datum/event/trivial_news
	endWhen = 10

/datum/event/trivial_news/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "Editor Mike Hammers"
	//newMsg.is_admin_message = 1
	var/datum/trade_destination/affected_dest = pick(weighted_mundaneevent_locations)
	newMsg.body = pick(file2list("config/news/trivial.txt"))
	newMsg.body = replacetext(newMsg.body,"{{AFFECTED}}",affected_dest.name)

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "The Gibson Gazette")
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("The Gibson Gazette")
