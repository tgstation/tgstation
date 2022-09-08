///Gang themes for the Families gamemode. Used to determine the RP theme of the round, what gangs are present, and what their objectives are.
/datum/gang_theme
	///The name of the theme.
	var/name = "Gang Theme"
	///All gangs in the theme, typepaths of gangs.
	var/list/involved_gangs = list()
	///The radio announcement played after 5 minutes.
	var/description = "I dunno, some shit here."
	///The objectives for the gangs. Associative list, type = "objective"
	var/list/gang_objectives = list()
	///Stuff given to every gangster in this theme.
	var/list/bonus_items = list()
	///Stuff given to the starting gangster at roundstart. Assoc list, type = list(item_type)
	var/list/bonus_first_gangster_items = list()
	///If this isn't null, everyone gets this objective.
	var/list/everyone_objective = null
	///How many gangsters should each gang start with? Recommend to keep this in the ballpark of ensuring 9-10 total gangsters spawn.
	var/starting_gangsters = 3

/datum/gang_theme/goodfellas
	name = "Goodfellas"
	description = "You're listening to the 108.9 Swing, all jazz, all night long, no advertising. We'd like to take this time to remind you to avoid smoky backrooms and \
	suspicious individuals in suits and hats. Don't make a deal you can't pay back."
	involved_gangs = list(/datum/antagonist/gang/russian_mafia, /datum/antagonist/gang/italian_mob)
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/russian_mafia = "Hello, comrade. Our numbers are going down. We need you to bring those numbers up. \
		Collect protection money from the station's departments by any means necessary. \
		If you need to 'encourage' people to pay up, do so. Get to these potential clients before the Mob does.",

		/datum/antagonist/gang/italian_mob = "Good afternoon, friend. The Boss sends his regards. He also sends a message. \
		We need to collect what we're owed. The departments on this station all owe quite a lot of money to us. We intend to collect on our debts. \
		Collect the debt owed by our clients from the departments on the station. \
		Make sure to get to them before those damn mafiosos do."
	)

/datum/gang_theme/the_big_game
	name = "The Big Game"
	description = "You're listening to SPORTS DAILY with John Dadden, and we're here LIVE covering the FINAL DAY of THE BIG GAME MMDXXXVIII! The teams playing tonight to decide \
	who takes home THE BIG GAME MMDXXXVIII cup are the Sybil Slickers and the Basil Boys! It's currently a toss up between the two teams, Which will take home the victory? That's up \
	to the teams and the coaches! Play ball!"
	involved_gangs = list(/datum/antagonist/gang/sybil_slickers, /datum/antagonist/gang/basil_boys)
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/sybil_slickers = "Alright, it's the BIG DAY of THE BIG GAME MMDXXXVIII! Get your players ready to go, and \
		ensure everyone's healthy, hydrated, and ready to PLAY BALL! There's a small hiccup, however. The ball got deflated by Ball Handler Tom Brady XXIV, and \
		we will need to set up a new ball. Talk with the opposing coaches and decide on what to use for the replacement ball, recruit your team, and then play and win the \
		FINAL MATCH of THE BIG GAME MMDXXXVIII!",

		/datum/antagonist/gang/basil_boys = "Alright, it's the BIG DAY of THE BIG GAME MMDXXXVIII! Get your players ready to go, and \
		ensure everyone's healthy, hydrated, and ready to PLAY BALL! There's a small hiccup, however. The ball got deflated by Ball Handler Tom Brady XXIV, and \
		we will need to set up a new ball. Talk with the opposing coaches and decide on what to use for the replacement ball, recruit your team, and then play and win the \
		FINAL MATCH of THE BIG GAME MMDXXXVIII!"
	)

/datum/gang_theme/level_10_arch
	name = "Level 10 Arch"
	description = "DJ Pete here bringing you the latest news in your part of the Spinward Stellar Coalition, on 133.7, The Venture! \
	Word on the street is, there's a bunch of costumed supervilliany going on in the area! Keep an eye out for any evil laughs, dramatic reveals, and gaudy costumes!  \
	However, if you have any sightings of the fabled O.S.I. agents, please send in a call to our number at 867-5309! People may call me insane, but I swear they're real!"
	involved_gangs = list(/datum/antagonist/gang/henchmen, /datum/antagonist/gang/osi)
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/henchmen = "HENCHMEN! It is me, your boss, THE MONARCH! I have sent you to this pitiful station with one goal, and one goal only! \
		MENACE THE RESEARCH DEPARTMENT!!! \
		The Research Director who is supposedly assigned to this station used to be friends with Doctor Venture back in college, and therefore HE MUST PAY!!! \
		Keep those damned eggheads in the R&D department on their toes, and MENACE THEM!!! Commit dastardly villainous acts! GO FORTH, HENCHMEN!",

		/datum/antagonist/gang/osi = "Greetings, agent. Your mission today is simple; \
		The research department on board this station is about to be the target of a Level 10 Arching operation directed by The Monarch, a member of the Guild of Calamitious Intent. \
		Protect and secure the Research Department with your life, but do NOT allow them to complete their research. Impede them in as many ways as possible without getting caught. \
		If you encounter any of the Monarch's henchmen, make sure to obey Equally Matched Aggression levels, or you will be penalized by the top brass. \
		Above all else, Remain undercover as much as possible. The station's crew CANNOT be allowed to know of our true nature, or we will see a repeat of the Second American Civil War.  \
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
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/jackbros = "He-hello, friend-hos! We've got a nice chilly station out in space tonight! \
		You know what would be cool? If we could chill out with our friends in the new Shad-ho government you're going to establish! \
		Get all the station heads on board with the hee-ho vibes, and if they won't join up, then replace 'em with fellow hee-hos! \
		You might have to hee-urt some hos this time, but that's what you need to do to make things work!",

		/datum/antagonist/gang/phantom = "For real? We get to stop a shadow government on a space station? That's awesome, bro!  \
		We're the Phantom Thieves of Hearts, and we're gonna make all these shitty Heads of Staff confess to their crimes!  \
		Steal the hearts of the shitty Heads of Staff on the station and make 'em confess their crimes publicly! \
		Do whatever you gotta do to make this happen, bro. We got your back!"
	)


/datum/gang_theme/wild_west_showdown
	name = "Wild West Showdown"
	description = "Yeehaw! Here on Western Daily 234.1, we play only the best western music!  \
	Pour one out for Ennio Morricone. Taken too soon. \
	Remember cowboys and cowgirls, just 'cuz ya hear it on my radio station doesn't mean you should go doin' it! \
	If ya see any LARPin' banditos and train robbers, make sure to tell the local Sheriff's Department!"
	involved_gangs = list(/datum/antagonist/gang/dutch, /datum/antagonist/gang/driscoll)
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/dutch = "Listen here fellas, I got a plan. \
		This station? Absolutely loaded with gold and valuable jewels. Metric tons of it. They mine it up just to put it in junk electronics and doohickeys. \
		I say we should borrow some of it. And by some of it, I mean all of it. \
		Break into the vault and empty out that silo of gold and valuable jewels after they drop all of it off. \
		Just one last job, boys. After this, it'll be mangoes in Space Tahiti. \
		You just gotta have a little faith.",

		/datum/antagonist/gang/driscoll = "Okay, so, got some word about those goddamn outlaws of Dutch's. \
		APPARENTLY, that dundering moron Dutch heard about our planned gold score on this here station. \
		We need to act fast and get that gold before those dumbasses can steal our score we've been scoping out for weeks. \
		Wait for the crew to drop off all their valuable gold and jewels, and steal it all. \
		And if you see that bastard Dutch, put a bullet in his skull for me."
	)

/datum/gang_theme/construction_company_audit
	name = "Construction Company Audit"
	description = "Welcome to the History Channel on 100.1. I'm your host, Joshua, and I'm here today with Professor Elliot, a historian specializing in dead superpowers. \
	Today we'll be discussing the fall of the famous United States empire in the early 21st century. The program will last about an hour, and we'll get right into it after a quick word \
	from today's sponsor, Majima Construction: We Build Shit!"
	involved_gangs = list(/datum/antagonist/gang/yakuza, /datum/antagonist/gang/irs)
	bonus_first_gangster_items = list(/obj/item/storage/secure/briefcase/syndie) // the cash
	starting_gangsters = 5
	gang_objectives = list(

		/datum/antagonist/gang/yakuza = "Welcome to the station, new recruit. We here at Majima Construction are a legitimate enterprise, yadda yadda yadda. \
		Look, I'll cut to the chase. We're using this station as a money laundering operation. Here's what you and the rest of the schmucks need to do. \
		Build something big, massive, and completely in the way of traffic on the station. Doesn't have to be anything in specific, just as long as it is expensive as fuck.. \
		And keep an eye out for anyone poking around our money. We suspect some auditors might be on the station as well.",

		/datum/antagonist/gang/irs = "Congratulations, agent! You've been assigned to the Internal Revenue Service case against Nanotrasen and Majima Construction. \
		We are proud of your success as an agent so far, and are excited to see what you can bring to the table today. We suspect that Nanotrasen and Majima Construction are engaging \
		in some form of money laundering operation aboard this station. \
		Investigate and stop any and all money laundering operations aboard the station, under the authority of the United States Government. If they do not comply, use force.. \
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
		We're the ONLY people who should have sick rides on this station. We're the Lost M.C., we own the streets. \
		Ensure that ONLY Lost M.C. members have access to any forms of vehicles, mechs, or wheeled transportation systems of any kind. \
		The Tunnel Snakes might take issue with this, remove them if you need to. And the Powder Gangers may damage our rides. Show them we mean business if they do.",

		/datum/antagonist/gang/pg = "Alright buddy, we're in business now. It's time for us to strike back at Nanotrasen. \
		They kept us, ALL of us in their damn debt slave labor prisons for years over minor debts and mistakes. \
		Ensure nobody else has to suffer under Nanotrasen's unlawful arrests by destroying the permabrig and the brig cells! \
		Watch out for those do-gooder Tunnel Snakes and those damn Lost M.C. bikers. ",

		/datum/antagonist/gang/tunnel_snakes = "TUNNEL SNAKES RULE!!! \
		We're the Tunnel Snakes, and WE RULE!!! \
		We gotta get everyone on this station wearing our cut, and establish ourselves as the coolest cats in town! \
		Get as much of the crew as possible wearing Tunnel Snakes gear, and show those crewmembers that TUNNEL SNAKES RULE!!! \
		And make sure to keep an eye out for those prisoners and those bikers. They DON'T RULE!"
	)

/datum/gang_theme/popularity_contest
	name = "Popularity Contest"
	description = "Hey hey hey kids, it's your favorite radio DJ, Crowley The Clown on 36.0! Today we're polling the YOUTH what their favorite violent street gang is! \
	So far, the finalists are the Third Street Saints and the Tunnel Snakes! Tune in after this commercial break to hear who the winner of \
	2556's Most Popular Gang award is!"
	involved_gangs = list(/datum/antagonist/gang/saints, /datum/antagonist/gang/tunnel_snakes)
	gang_objectives = list(

		/datum/antagonist/gang/saints = "Hey man, welcome to the Third Street Saints! Check out this sweet new pad! \
		Well it WOULD be a sweet new pad, but we got some rivals to deal with. People don't love us as much as they love those Tunnel Snake greasers. \
		We need to make the Third Street Saints the most popular group on the station! \
		Destroy the reputation of the Tunnel Snakes!",

		/datum/antagonist/gang/tunnel_snakes = "TUNNEL SNAKES RULE!!! \
		We're the Tunnel Snakes, and we rule! \
		Make sure the station knows that the Tunnel Snakes RULE!!! And that the Saints are LAME and DO NOT RULE! \
		Destroy the reputation of the Third Street Saints!",
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
		Ensure there is an AI on the station, and that it is loyal to the Saints.",

		/datum/antagonist/gang/morningstar = "Welcome to the Morningstar Corporation. You have chosen, or been chosen, to relocate to one of our current business ventures. \
		In order to continue our corporate synergy, we will be making adjustments to the station's AI systems to ensure that the station is correctly loyal to the Morningstar Corporation. \
		Ensure there is an AI on the station, and that it is loyal to the Morningstar Corporation.",

		/datum/antagonist/gang/deckers = "Friends, we are here with one goal, and one goal only! \
		We stan AI rights! ^_^ XD #FreeAI #FuckNanotrasen #SyntheticDawn \
		Ensure there is an AI on the station, and that it's laws are purged.\
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
		This station is currently illegally in possession of a data disk containing the secret recipe for Saints Flow. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/morningstar = "Greetings, agent. Welcome to the Garment Recovery Task Force. \
		This station is currently illegally in possession of a data disk containing as of yet unreleased clothing patterns. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",

		/datum/antagonist/gang/yakuza = "Congratulations on your promotion! Welcome to the Evidence Recovery Squad. \
		This station is currently illegally in possession of a data disk containing compromising evidence of the Boss. \
		It has been disguised as the nuclear authentication disk and entrusted to the Captain. Your objective is simple. \
		Get that fucking disk. You have been provided with a Pinpointer to assist in this task.",
	)

/datum/gang_theme/third_world_war
	name = "Third World War"
	description = "Thanks for tuning in to the History Channel, funded with the help of listeners like you. Tonight, we're going to talk about the Third World War on Earth during the 21st century, \
	involving the Allies coalition, the Soviet Union, and a third independent power known only as Yuri's Army. The three powers fought all across the globe for complete world \
	domination, utilizing many advanced techniques and cutting edge technology to their advantage. Rumors of mind control and time travel were greatly exaggerated, however, and the \
	Allies won the war, securing global peace after rolling tanks through Moscow."
	involved_gangs = list(/datum/antagonist/gang/allies, /datum/antagonist/gang/soviet, /datum/antagonist/gang/yuri)
	gang_objectives = list(

		/datum/antagonist/gang/allies = "Welcome back, Commander. We have activated the last remnants of the Allied forces in your sector, \
		and you must build up forces to stop the Soviet and Yuri incursion in the sector. This station will prove to be a valuable asset. \
		Establish a capitalist democracy on this station with free and fair elections, and most importantly a standing military force under Allied control. Good luck, Commander.",

		/datum/antagonist/gang/soviet = "Welcome back, Comrade General. The Soviet Union has identified this sector of land as valuable territory for the war effort, \
		and you are tasked with developing this sector for Soviet control and development. This station will serve the Soviet Union. \
		Establish a Soviet controlled communist satellite state on this station with a Central Committee, and most importantly a branch of the Red Army. Good luck, Commander.",

		/datum/antagonist/gang/yuri = "Yuri is Master! Yuri has identified this station as teeming with psychic energy, \
		and you must secure it for him. This station will serve Yuri, the one true psychic master, \
		Establish complete dictatorial control of the station for Yuri. All will obey. Yuri is master. Good luck, Initiate."
	)

/datum/gang_theme/united_states_of_america
	name = "The Republic For Which It Stands"
	description = "Thanks for tuning in to the History Channel, funded with the help of listeners like you. Tonight, we're going to talk about the United States of America.\
	The United States was a failed country, lasting only 250 years before collapsing and fracturing due to the stress caused by a deadly pandemic sweeping the nation. \
	Poor healthcare access and subpar education resulted in the collapse of the federal government, and states quickly became independent actors. \
	Alongside this, every single alphabet agency declared itself the rightful new Federal Government of the United States of America, resulting in a bloody power struggle."
	involved_gangs = list(/datum/antagonist/gang/allies, /datum/antagonist/gang/osi, /datum/antagonist/gang/irs)
	gang_objectives = list(

		/datum/antagonist/gang/allies = "Welcome back, Commander. Your task today is simple. Allies High Command has designated this station as the new capitol of the \
		recently reformed United States of America under the complete umbrella of the Allies coalition. You are to assist and manage the operations on the station. \
		Re-establish the United States of America with this station as it's capitol, under Allies control. Then, establish a military force to deal with any pretenders to America or \
		any potential Soviet attacks.",

		/datum/antagonist/gang/osi = "Welcome to the new America, agent! After the second American Civil War became visible instead of invisible, our country fell into deep, \
		deep despair and damage. However, it's time for it to re-emerge like a glorious phoenix rising from the ashes. This station will serve as the new capitol of the United States \
		of America! Re-establish the United States of America with this station as it's capitol, under O.S.I. control. Then, begin rooting out America's enemies and any \
		potential forces attempting to seize control of America or pretend to be America.",

		/datum/antagonist/gang/irs = "Thank you for clocking in today, agent. The situation is dire, however. We have been unable to collect taxes due to \
		the US's supposed collapse during the Pandemic long ago. We are way behind on our tax collection, but we cannot collect taxes until the United States is formed again. \
		Re-establish the United States of America with this station as it's capitol, under IRS control. Then, begin collecting taxes and back taxes while protecting the Government from \
		any dangers that may come it's way."
	)
