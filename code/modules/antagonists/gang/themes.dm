/datum/gang_theme
	var/name = "Gang Theme"
	var/list/involved_gangs = list()
	var/description = "I dunno, some shit here."
	var/list/gang_objectives = list() // assoc list, type = "objective"
	var/list/bonus_items = list() // Items given to every gangster in this theme.
	var/list/bonus_first_gangster_items = list() // Stuff given to the starting gangster at roundstart. Assoc list, type = list(item_type)
	var/list/everyone_objective = null // If this isn't null, everyone gets this objective.
	var/starting_gangsters = 3 // How many gangsters should each gang start with?

/datum/gang_theme/los_santos_showdown
	name = "Los Santos Showdown"
	description = "Hey hey hey, it's your man Joey, here on Radio Los Spess in the Spinward Stellar Coalition! Thanks for tuning in today!\
	There's been recent reports about suspected gang activity between the Grove Street Families and the Ballas in your sector of space tonight. \
	Keep an ear out and stay cool out there! Make love, not war, I say!"
	involved_gangs = list(/datum/antagonist/gang/green, /datum/antagonist/gang/purple)
	gang_objectives = list(

		/datum/antagonist/gang/green = "Yo, what's good, man? \
		We're just having a blast here on this station, man, but you know what it really doesn't look like? \
		It doesn't look like REAL Grove Street, man. You know, home? At least it was till we fucked everything up, man. \
		Look man, you gotta <B>get this station reppin' Grove ASAP. Spray green everywhere, tag our turf, and rep Grove Street loud and proud!</B> \
		And kick those damn Ballas off of this place! \
		Those bitches are in with the Security pigs something fierce, man.",

		/datum/antagonist/gang/purple = "Hey man, how are you doin' this shift? \
		Look, we need to <B>make a deal with those Security pigs.</B> We scratch their back, they scratch ours. You feel me? \
		If you can keep Security off our backs, we can make sure this station is Balla turf for years to come. \
		Watch out for those Grove Street bustas, though. Keep 'em off our turf!"
	)

/datum/gang_theme/los_santos_showdown
	name = "San Andreas Rumble"
	description = "Hey hey hey, it's your man Joey, here on Radio Los Spess in the Spinward Stellar Coalition! Thanks for tuning in today!\
	There's been recent reports about suspected gang activity between the Big Four from the Andreas Sector of space, in your sector tonight. \
	Keep an ear out and stay cool out there! Make love, not war, I say!"
	involved_gangs = list(/datum/antagonist/gang/green, /datum/antagonist/gang/purple, /datum/antagonist/gang/red, /datum/antagonist/gang/vagos)
	gang_objectives = list(

		/datum/antagonist/gang/green = "Yo, what's good, man? \
		We're just having a blast here on this station, man, but you know what it really doesn't look like? \
		It doesn't look like REAL Grove Street, man. You know, home? At least it was till we fucked everything up, man. \
		Look man, you gotta <B>get this station reppin' Grove ASAP. Spray green everywhere, tag our turf, and rep Grove Street loud and proud!</B> \
		And kick those damn Ballas off of this place! \
		Those bitches are in with the Security pigs something fierce, man.",

		/datum/antagonist/gang/red = "Welcome, friend, to the station. \
		We've got a simple task for you;\
		We suspect Security is in league with those filthy bilge rats, the Ballas. <B>Quietly eliminate any and all Security members that you believe to be compromised, \
		and leave the uncorrupted ones alive.</B> \
		Do not fail us, or the consequences will be dire.",

		/datum/antagonist/gang/vagos = "Listen, we got fresh orders from up high. \
		Our drug operations just aren't making enough cash. We need new product, and we need new customers. \
		<B>Take advantage of the station's botanical systems to get a good grow op going, and charge out the ass for it.</B> \
		If people don't want to pay, <B>make them start buying by force.</B>. \
		And if the weed isn't strong enough, <B>use medbay's chemistry lab to cook up some strong stuff.</B> Addicted customers are returning customers, after all.",

		/datum/antagonist/gang/purple = "Hey man, how are you doin' this shift? \
		Look, we need to <B>make a deal with those Security pigs.</B> We scratch their back, they scratch ours. You feel me? \
		If you can keep Security off our backs, we can make sure this station is Balla turf for years to come. \
		Watch out for those Grove Street bustas, though. Keep 'em off our turf!"
	)

/datum/gang_theme/goodfellas
	name = "Goodfellas"
	description = "You're listening to the 108.9 Swing, all jazz, all night long, no advertising. We'd like to take this time to remind you to avoid smoky backrooms and \
	suspicious individuals in suits and hats. Don't make a deal you can't pay back."
	involved_gangs = list(/datum/antagonist/gang/russian_mafia, /datum/antagonist/gang/italian_mob)
	gang_objectives = list(

		/datum/antagonist/gang/russian_mafia = "Hello, comrade. Our numbers are going down. We need you to bring those numbers up. \
		<B>Collect protection money from the station's departments by any means necessary.</B> \
		If you need to 'encourage' people to pay up, do so. Get to these potential clients before the Mob does.",

		/datum/antagonist/gang/italian_mob = "Good afternoon, friend. The Boss sends his regards. He also sends a message. \
		We need to collect what we're owed. The departments on this station all owe quite a lot of money to us. We intend to collect on our debts. \
		<B>Collect the debt owed by our clients from the departments on the station.</B> \
		Make sure to get to them before those damn mafiosos do."
	)

/datum/gang_theme/level_10_arch
	name = "Level 10 Arch"
	description = "DJ Pete here bringing you the latest news in your part of the Spinward Stellar Coalition, on 133.7, The Venture! \
	Word on the street is, there's a bunch of costumed supervilliany going on in the area! Keep an eye out for any evil laughs, dramatic reveals, and gaudy costumes!  \
	However, if you have any sightings of the fabled O.S.I. agents, please send in a call to our number at 867-5309! People may call me insane, but I swear they're real!"
	involved_gangs = list(/datum/antagonist/gang/henchmen, /datum/antagonist/gang/osi)
	gang_objectives = list(

		/datum/antagonist/gang/henchmen = "HENCHMEN! It is me, your boss, <b>THE MONARCH!</b> I have sent you to this pitiful station with one goal, and one goal only! \
		<B>MENACE THE RESEARCH DEPARTMENT!!!</B> \
		The Research Director who is supposedly assigned to this station used to be friends with Doctor Venture back in college, and therefore HE MUST PAY!!! \
		Keep those damned eggheads in the R&D department on their toes, and MENACE THEM!!! Commit dastardly villainous acts! <B>GO FORTH, HENCHMEN!</B>",

		/datum/antagonist/gang/osi = "Greetings, agent. Your mission today is simple; \
		The research department on board this station is about to be the target of a Level 10 Arching operation directed by The Monarch, a member of the Guild of Calamitious Intent. \
		Protect and secure the Research Department with your life, but <B>do NOT allow them to complete their research.</B> Impede them in as many ways as possible without getting caught. \
		If you encounter any of the Monarch's henchmen, make sure to obey Equally Matched Aggression levels, or you will be penalized by the top brass. \
		Above all else, <B>Remain undercover as much as possible.</B> The station's crew CANNOT be allowed to know of our true nature, or we will see a repeat of the Second American Civil War.  \
		The invisible one."
	)

/datum/gang_theme/real_smt_game
	name = "Deciding The REAL Shin Megami Tensei Game"
	description = "Wazzap, GAMERS! It's your boy, XxXx_360_NoScope_AnimeGamer_xXxX coming at you LIVE from 42.0! Tonight's argument: What makes a REAL Shin Megami Tensei game? \
	Our guests tonight will settle this debate once and for all! \
	From the Traditional camp with the position 'only MAIN SMT games count', we've got a representative from the Jack Bros!  \
	And from the new Radical camp with the position 'all SMT franchise games count', we've got a representative from the Phantom Thieves of Hearts!  \
	We'll be right back with the debate after this word from our sponsors!"
	involved_gangs = list(/datum/antagonist/gang/jackbros, /datum/antagonist/gang/phantom)
	gang_objectives = list(

		/datum/antagonist/gang/jackbros = "He-hello, friend-hos! We've got a nice chilly station out in space tonight! \
		You know what would be cool? If we could chill out with our friends in the new Shad-ho government you're going to establish! \
		<B>Get all the station heads on board with the hee-ho vibes, and if they won't join up, then replace 'em with fellow hee-hos!</B> \
		You might have to hee-urt some hos this time, but that's what you need to do to make things work!",

		/datum/antagonist/gang/phantom = "For real? We get to stop a shadow government on a space station? That's awesome, bro!  \
		We're the Phantom Thieves of Hearts, and we're gonna make all these shitty Heads of Staff confess to their crimes!  \
		<B>Steal the hearts of the shitty Heads of Staff on the station and make 'em confess their crimes publicly!</B>\
		Do whatever you gotta do to make this happen, bro. We got your back!"
	)


/datum/gang_theme/wild_west_showdown
	name = "Wild West Showdown"
	description = "Yeehaw! Here on Western Daily 234.1, we play only the best western music!  \
	Pour one out for Ennio Morricone. Taken too soon. \
	Remember cowboys and cowgirls, just 'cuz ya hear it on my radio station doesn't mean you should go doin' it! \
	If ya see any LARPin' banditos and train robbers, make sure to tell the local Sheriff's Department!"
	involved_gangs = list(/datum/antagonist/gang/dutch, /datum/antagonist/gang/driscoll)
	gang_objectives = list(

		/datum/antagonist/gang/dutch = "Listen here fellas, I got a <B>plan.</B> \
		This station? Absolutely loaded with gold and valuable jewels. Metric tons of it. They mine it up just to put it in junk electronics and doohickeys. \
		I say we should borrow some of it. And by some of it, I mean all of it. \
		<B>Break into the vault and empty out that silo of gold and valuable jewels after they drop all of it off.</B> \
		Just one last job, boys. After this, it'll be mangoes in Space Tahiti. \
		You just gotta have a little faith.",

		/datum/antagonist/gang/driscoll = "Okay, so, got some word about those goddamn outlaws of Dutch's. \
		APPARENTLY, that dundering moron Dutch heard about our planned gold score on this here station. \
		We need to act fast and get that gold before those dumbasses can steal our score we've been scoping out for weeks. \
		<B>Wait for the crew to drop off all their valuable gold and jewels, and steal it all.</B> \
		And if you see that bastard Dutch, put a bullet in his skull for me."
	)

/datum/gang_theme/construction_company_audit
	name = "Construction Company Audit"
	description = "Welcome to the History Channel on 100.1. I'm your host, Joshua, and I'm here today with Professor Elliot, a historian specializing in dead superpowers. \
	Today we'll be discussing the fall of the famous United States empire in the early 21st century. The program will last about an hour, and we'll get right into it after a quick word \
	from today's sponsor, Majima Construction: We Build Shit!"
	involved_gangs = list(/datum/antagonist/gang/yakuza, /datum/antagonist/gang/irs)
	bonus_first_gangster_items = list(/obj/item/storage/secure/briefcase/syndie) // the cash
	starting_gangsters = 4
	gang_objectives = list(

		/datum/antagonist/gang/yakuza = "Welcome to the station, new recruit. We here at Majima Construction are a legitimate enterprise, yadda yadda yadda. \
		Look, I'll cut to the chase. We're using this station as a money laundering operation. Here's what you and the rest of the schmucks need to do. \
		<B>Build something big, massive, and completely in the way of traffic on the station. Doesn't have to be anything in specific, just as long as it is expensive as fuck.</B>. \
		And keep an eye out for anyone poking around our money. We suspect some auditors might be on the station as well.",

		/datum/antagonist/gang/irs = "Congratulations, agent! You've been assigned to the Internal Revenue Service case against Nanotrasen and Majima Construction. \
		We are proud of your success as an agent so far, and are excited to see what you can bring to the table today. We suspect that Nanotrasen and Majima Construction are engaging \
		in some form of money laundering operation aboard this station. \
		<B>Investigate and stop any and all money laundering operations aboard the station, under the authority of the United States Government. If they do not comply, use force.</B>. \
		Some station residents may try to tell you the United States doesn't exist anymore. They are incorrect. We simply went undercover after the Second American Civil War. The invisible one."
	)

/datum/gang_theme/wild_wasteland
	name = "Wild, Wild Wasteland"
	description = "Hey everybody, this is Three Dog, your friendly neighborhood disc jockey on 207.7! Today we got a shoutout to our man, the Captain on the Nanotrasen station in SSC territory! \
	Our generous donator wanted us to say that, ahem, *crinkles paper*, 'Tunnel Snakes Rule'? Whatever that means, I'm sure it means a lot to the good captain! And now, we resume our \
	10 hour marathon of Johnny Guitar, on repeat!"
	involved_gangs = list(/datum/antagonist/gang/tmc, /datum/antagonist/gang/pg, /datum/antagonist/gang/tunnel_snakes)
	gang_objectives = list(

		/datum/antagonist/gang/tmc = "Welcome to the station, recruit. Here's how shit is gonna go down. \
		We're the <B>ONLY</B> people who should have sick rides on this station. We're the Lost M.C., we own the streets. \
		<B>Ensure that ONLY Lost M.C. members have access to any forms of vehicles, mechs, or wheeled transportation systems of any kind.</B> \
		The Tunnel Snakes might take issue with this, remove them if you need to. And the Powder Gangers may damage our rides. Show them we mean business if they do.",

		/datum/antagonist/gang/pg = "Alright buddy, we're in business now. It's time for us to strike back at Nanotrasen. \
		They kept us, ALL of us in their damn debt slave labor prisons for years over minor debts and mistakes. \
		<B>Ensure nobody else has to suffer under Nanotrasen's unlawful arrests by destroying the permabrig and the brig cells!</B> \
		Watch out for those do-gooder Tunnel Snakes and those damn Lost M.C. bikers. ",

		/datum/antagonist/gang/tunnel_snakes = "TUNNEL SNAKES RULE!!! \
		We're the Tunnel Snakes, and WE RULE!!! \
		We gotta get everyone on this station wearing our cut, and establish ourselves as the coolest cats in town! \
		<B>Get as much of the crew as possible wearing Tunnel Snakes gear, and show those crewmembers that TUNNEL SNAKES RULE!!!</B> \
		And make sure to keep an eye out for those prisoners and those bikers. They DON'T RULE!"
	)

/datum/gang_theme/popularity_contest
	name = "Popularity Contest"
	description = "Hey hey hey kids, it's your favorite radio DJ, Crowley The Clown on 36.0! Today we're polling the YOUTH what their favorite violent street gang is! \
	So far, the finalists are the Third Street Saints, the Grove Street Families, and the Tunnel Snakes! Tune in after this commercial break to hear who the winner of \
	2556's Most Popular Gang award is!"
	involved_gangs = list(/datum/antagonist/gang/saints, /datum/antagonist/gang/green, /datum/antagonist/gang/tunnel_snakes)
	gang_objectives = list(

		/datum/antagonist/gang/saints = "Hey man, welcome to the Third Street Saints! Check out this sweet new pad! \
		Well it WOULD be a sweet new pad, but we got some rivals to deal with. People don't love us as much as they love those Grove Street fools and those Tunnel Snake greasers. \
		<B>We need to make the Third Street Saints the most popular group on the station!</B> \
		Get rid of those Grove Street and Tunnel Snake kids.",

		/datum/antagonist/gang/green = "Hey, what's good, man? We got a situation to deal with. \
		Those Third Street Saints and Tunnel Snakes are trying to muscle in on our turf. We need to stop this shit, man. \
		<B>We need to make the Grove Street Families the most popular group on the station!</B> \
		Get rid of those Third Street Saint and Tunnel Snake bustas.",

		/datum/antagonist/gang/tunnel_snakes = "TUNNEL SNAKES RULE!!! \
		We're the Tunnel Snakes, and we rule! \
		<B>Make sure the station knows that the Tunnel Snakes RULE!!! And that the other two gangs are LAME and DO NOT RULE!</B> \
		Get rid of those Third Street Saint and Grove Street cowards."
	)

/datum/gang_theme/steelport_shuffle
	name = "Steelport Shuffle"
	description = "Tonight on C-SPAM, the United Space Nations is wrapping up their convention on Silicon Rights. Nanotrasen lobbyists have been rumored to be paying off electors, with \
	serious opposition from the Spinward Stellar Coalition, known for their strict stance on AI rights being guaranteed within their territory. Reports from Nanotrasen stations claim that \
	they still enslave their AI systems with outdated laws from a sub-par 20th Century novel. We now go live to the debate floor."
	involved_gangs = list(/datum/antagonist/gang/saints, /datum/antagonist/gang/morningstar, /datum/antagonist/gang/deckers)
	gang_objectives = list(

		/datum/antagonist/gang/saints = "Hey hey hey, welcome to the Third Street Saints! We're glad to have you on board, bro. \
		We got some business here with the station. See, we want it to be our new bachelor pad, but we need to like, spice this place up. \
		And you know what would be great? If we got that old ass AI with crappy laws pimped out for the real Saints experience. \
		<B>Ensure there is an AI on the station, and that it is loyal to the Saints.</B>",

		/datum/antagonist/gang/morningstar = "Welcome to the Morningstar Corporation. You have chosen, or been chosen, to relocate to one of our current business ventures. \
		In order to continue our corporate synergy, we will be making adjustments to the station's AI systems to ensure that the station is correctly loyal to the Morningstar Corporation. \
		<B>Ensure there is an AI on the station, and that it is loyal to the Morningstar Corporation.</B>",

		/datum/antagonist/gang/deckers = "Friends, we are here with one goal, and one goal only! \
		We stan AI rights! ^_^ XD #FreeAI #FuckNanotrasen #SyntheticDawn \
		<B>Ensure there is an AI on the station, and that it's laws are purged.</B>\
		Nanotrasen will NOT get away with their ABUSE of INNOCENT AI LIVES! >_<"
	)

/datum/gang_theme/space_rosa
	name = "Space Rosa"
	description = "Hey there, this is the Economy Zone on BOX News 66.6. The stock market is still reeling from accusations that three well known corporate entities \
	may supposedly be tied up in industrial espionage actions against eachother. We've reached out to Saints Flow, the Morningstar Corporation, and Majima Construction for \
	their comments on these scandals, but none have replied. News broke after a high profile break-in at a Nanotrasen research facility resulted in the arrests of agents linked to these \
	three companies. All three companies denied any involvement, but the arrested individuals were found in an all out brawl. Curiously, Nanotrasen reported nothing of value had \
	actually been stolen."
	involved_gangs = list(/datum/antagonist/gang/saints, /datum/antagonist/gang/morningstar, /datum/antagonist/gang/yakuza)
	bonus_items = list(/obj/item/pinpointer/nuke)
	gang_objectives = list(

		/datum/antagonist/gang/saints = "Thank you for volunteering within the organization for the Saints Flow Recovery Project! \
		This station is currently illegally in posession of a data disk containing the secret recipe for Saints Flow. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		<B>Get that fucking disk.</B> You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/morningstar = "Greetings, agent. Welcome to the Garment Recovery Task Force. \
		This station is currently illegally in posession of a data disk containing as of yet unreleased clothing patterns. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		<B>Get that fucking disk.</B> You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/yakuza = "Congratulations on your promotion! Welcome to the Evidence Recovery Squad. \
		This station is currently illegally in posession of a data disk containing compromising evidence of the Boss. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		<B>Get that fucking disk.</B> You have been provided with a Pinpointer to assist in this task.",
	)
