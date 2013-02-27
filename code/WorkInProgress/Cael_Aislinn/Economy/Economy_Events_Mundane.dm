
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
		newMsg.body = ""
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
					newMsg.body += "is recovering from plastic surgery in a clinic on [affected_dest.name] for the [pick("second","third","fourth")] time, reportedly having made the decision in response to "
					newMsg.body += "[pick("unkind comments by an ex","rumours started by jealous friends",\
					"the decision to be dropped by a major sponsor","a disasterous interview on Tau Ceti Tonight")]."
			if(TOURISM)
				newMsg.body += "Tourists are flocking to [affected_dest.name] after the surprise announcement of [pick("major shopping bargains by a wily retailer",\
				"a huge new ARG by a popular entertainment company","a secret tour by popular artiste [random_name(pick(MALE,FEMALE))]")]. \
				Tau Ceti Daily is offering discount tickets for two to see [random_name(pick(MALE,FEMALE))] live in return for eyewitness reports and up to the minute coverage."

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
	newMsg.body = pick(
	"Tree stuck in tajaran; firefighters baffled.",\
	"Armadillos want aardvarks removed from dictionary claims 'here first'.",\
	"Angel found dancing on pinhead ordered to stop; cited for public nuisance.",\
	"Letters claim they are better than number; 'Always have been'.",\
	"Pens proclaim pencils obsolete, 'lead is dead'.",\
	"Rock and paper sues scissors for discrimination.",\
	"Steak tell-all book reveals he never liked sitting by potato.",\
	"Woodchuck stops counting how many times he’s chucked 'Never again'.",\
	"[affected_dest.name] clerk first person able to pronounce '@*$%!'.",\
	"[affected_dest.name] delis serving boiled paperback dictionaries, 'Adjectives chewy' customers declare.",\
	"[affected_dest.name] weather deemed 'boring'; meteors and rad storms to be imported.",\
	"Most [affected_dest.name] security officers prefer cream over sugar.",\
	"Palindrome speakers conference in [affected_dest.name]; 'Wow!' says Otto.",\
	"Question mark worshipped as deity by ancient [affected_dest.name] dwellers.",\
	"Spilled milk causes whole [affected_dest.name] populace to cry.",\
	"World largest carp patty at display on [affected_dest.name].",\
	"'Here kitty kitty' no longer preferred tajaran retrieval technique.",\
	"Man travels 7000 light years to retrieve lost hankie, 'It was my favourite'.",\
	"New bowling lane that shoots mini-meteors at bowlers very popular.",\
	"[pick("Unathi","Spacer")] gets tattoo of Tau Ceti on chest '[pick("CentComm","star","starship","asteroid")] tickles most'.",\
	"Skrell marries computer; wedding attended by 100 modems.",\
	"Chef reports successfully using harmonica as cheese grater.",\
	"NanoTrasen invents handkerchief that says 'Bless you' after sneeze.",\
	"Clone accused of posing for other clones’s school photo.",\
	"Clone accused of stealing other clones’s employee of the month award.",\
	"Woman robs station with hair dryer; crewmen love new style.",\
	"This space for rent.",\
	"[affected_dest.name] Baker Wins Pickled Crumpet Toss Three Years Running",\
	"Skrell Scientist Discovers Abacus Can Be Used To Dry Towels",\
	"Survey: 'Cheese Louise' Voted Best Pizza Restaurant In Tau Ceti",\
	"I Was Framed, jokes [affected_dest.name] artist",\
	"Mysterious Loud Rumbling Noises In [affected_dest.name] Found To Be Mysterious Loud Rumblings",\
	"Alien ambassador becomes lost on [affected_dest.name], refuses to ask for directions",\
	"Swamp Gas Verified To Be Exhalations Of Stars--Movie Stars--Long Passed",\
	"Tainted Broccoli Weapon Of Choice For Syndicate Assassins",\
	"Chefs Find Broccoli Effective Tool For Cutting Cheese",\
	"Broccoli Found To Cause Grumpiness In Monkeys",\
	"Survey: 80% Of People on [affected_dest.name] Love Clog-Dancing",\
	"Giant Hairball Has Perfect Grammar But Rolls rr's Too Much, Linguists Say",\
	"[affected_dest.name] Phonebooks Print All Wrong Numbers; Results In 15 New Marriages",\
	"Tajaran Burglar Spotted on [affected_dest.name], Mistaken For Dalmatian",\
	"Gibson Gazette Updates Frequently Absurd, Poll Indicates",\
	"Esoteric Verbosity Culminates In Communicative Ennui, [affected_dest.name] Academics Note",\
	"Taj Demand Longer Breaks, Cleaner Litter, Slower Mice",\
	"Survey: 3 Out Of 5 Skrell Loathe Modern Art",\
	"Skrell Scientist Discovers Gravity While Falling Down Stairs",\
	"Boy Saves Tajaran From Tree on [affected_dest.name], Thousands Cheer",\
	"Shipment Of Apples Overturns, [affected_dest.name] Diner Offers Applesauce Special",\
	"Spotted Owl Spotted on [affected_dest.name]",\
	"Humans Everywhere Agree: Purring Tajarans Are Happy Tajarans",\
	"From The Desk Of Wise Guy Sammy: One Word In This Gazette Is Sdrawkcab",\
	"From The Desk Of Wise Guy Sammy: It's Hard To Have Too Much Shelf Space",\
	"From The Desk Of Wise Guy Sammy: Wine And Friendships Get Better With Age",\
	"From The Desk Of Wise Guy Sammy: The Insides Of Golf Balls Are Mostly Rubber Bands",\
	"From The Desk Of Wise Guy Sammy: You Don't Have To Fool All The People, Just The Right Ones",\
	"From The Desk Of Wise Guy Sammy: If You Made The Mess, You Clean It Up",\
	"From The Desk Of Wise Guy Sammy: It Is Easier To Get Forgiveness Than Permission",\
	"From The Desk Of Wise Guy Sammy: Check Your Facts Before Making A Fool Of Yourself",\
	"From The Desk Of Wise Guy Sammy: You Can't Outwait A Bureaucracy",\
	"From The Desk Of Wise Guy Sammy: It's Better To Yield Right Of Way Than To Demand It",\
	"From The Desk Of Wise Guy Sammy: A Person Who Likes Cats Can't Be All Bad",\
	"From The Desk Of Wise Guy Sammy: Help Is The Sunny Side Of Control",\
	"From The Desk Of Wise Guy Sammy: Two Points Determine A Straight Line",\
	"From The Desk Of Wise Guy Sammy: Reading Improves The Mind And Lifts The Spirit",\
	"From The Desk Of Wise Guy Sammy: Better To Aim High And Miss Then To Aim Low And Hit",\
	"From The Desk Of Wise Guy Sammy: Meteors Often Strike The Same Place More Than Once",\
	"Tommy B. Saif Sez: Look Both Ways Before Boarding The Shuttle",\
	"Tommy B. Saif Sez: Hold On; Sudden Stops Sometimes Necessary",\
	"Tommy B. Saif Sez: Keep Fingers Away From Moving Panels",\
	"Tommy B. Saif Sez: No Left Turn, Except Shuttles",\
	"Tommy B. Saif Sez: Return Seats And Trays To Their Proper Upright Position",\
	"Tommy B. Saif Sez: Eating And Drinking In Docking Bays Is Prohibited",\
	"Tommy B. Saif Sez: Accept No Substitutes, And Don't Be Fooled By Imitations",\
	"Tommy B. Saif Sez: Do Not Remove This Tag Under Penalty Of Law",\
	"Tommy B. Saif Sez: Always Mix Thoroughly When So Instructed",\
	"Tommy B. Saif Sez: Try To Keep Six Month's Expenses In Reserve",\
	"Tommy B. Saif Sez: Change Not Given Without Purchase",\
	"Tommy B. Saif Sez: If You Break It, You Buy It",\
	"Tommy B. Saif Sez: Reservations Must Be Cancelled 48 Hours Prior To Event To Obtain Refund",\
	"Doughnuts: Is There Anything They Can't Do",\
	"If Tin Whistles Are Made Of Tin, What Do They Make Foghorns Out Of?",\
	"Broccoli discovered to be colonies of tiny aliens with murder on their minds"\
	)

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "The Gibson Gazette")
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("The Gibson Gazette")
