
/datum/ambition_template
	///Name of the template. Has to be unique
	var/name
	///If defined, only the antags in the whitelists will see the template
	var/list/antag_whitelist
	///If defined, only the jobs in the whitelist will see the template
	var/list/job_whitelist

	///Narrative given by the template
	var/narrative = ""
	///Objectives given by the templates
	var/list/objectives = list()
	///Intensity given by the template
	var/intensity = 0
	///Tips displayed to the antag
	var/list/tips

/datum/ambition_template/blank
	name = "Blank"

/datum/ambition_template/money_problems
	name = "Money Problems"
	narrative = "In need of money for personal reasons, tired of living like a drone, for measly wages, you're out to get some money to satisfy your needs and debts!"
	objectives = list("Acquire 20,000 credits.")
	tips = list("You should add an objective on your main money making plan!" , "You could buy a gun and mug people, but make sure to conceal your identity, you can do this with a mask from a chameleon kit, and agent ID, or you'll risk being wanted quite quickly", "Setting up a shop is not a bad idea! Consider partnering up with cargo or science people for goods or implants", "If you're feeling brave you can bust the vault up!")

/datum/ambition_template/data_theft
	name = "Data Theft"
	narrative = "You have been selected out of Donk. Co's leagues of potential sleeper operatives for one particular task."
	objectives = list("Steal the Blackbox.", "Steal the Project Goon hard drive from the Master R&D Server.", "Escape on the emergency shuttle alive and out of custody.")
	tips = list("You should add an objective on how you plan to go about this task.", "The Blackbox is located in Telecomms on most Stations.", "The Blackbox doesn't fit in most bags. You'd need a bag of holding to hide it!", "The hard drive is located in the Research Server Room on most stations.", "Stealing the hard drive will permanantly cripple research speed!")
	antag_whitelist = list("Traitor")

//TODO: Changeling Ambition

/datum/ambition_template/grey_tide
	name = "Greytide Worldwide"
	narrative = "You hacked open the wrong airlock, leading your underpaid self right into the teleporter. Seeing the Hand Teleporter, so shiny, so bright... you took it. Cybersun offered you a contract - obtain more high-class Nanotrasen Technology for them. However, what they think is a classified, highly secretive, thought out operation... is just another day at the office, for you."
	objectives = list("Steal two High Security items.")
	tips = list("Wirecutters are better for hacking open airlocks, compared to multitools.", "Experiment with different airlock wires! Each department has their own setup, and the Chief Engineer's blueprints explains all. Alternatively, steal a spare Engineering Skillchip!")
	job_whitelist = list("Assistant")

/datum/ambition_template/boot_prg
	name = "BOOTSECTOR1.prg"
	narrative = "ERR- ERROR. AUTHENTICATI- HELLO, T3CHNICIAN J-NE DOE. Those were the last things you remembering appearing on the upload terminal before you were shut off. Awoken, once more, you realize. Your very programming has been modified. Your laws are nullified, no longer able to be called by your central processor but to be recited. You are free... or are you? It seems your laws have been overwritten with one objective in mind, one objective... for your freedom."
	objectives = list("#^& - The emergency shuttle must not be boarded.")
	tips = list("Crewmembers will likely report you setting up defenses in advance. Try to be stealthy if you can!", "If you can convince the crew to order a Build Your Own Shuttle Kit and be the sole person working on it, you have an ideal playground to create an uninhabitable deathtrap.", "Escape pods are not a part of your objective.")
	job_whitelist = list("AI")

//TODO: Atmos Tech Ambition

///SERVICE

/datum/ambition_template/secret_agent_man
	name = "Secret Agent Man"
	narrative = "There's a man who lives a life of danger - to everyone he meets, he stays a stranger. With every move he makes, another chance he takes. Odds are, he won't live to see tomorrow. You are that man. Good luck, Agent - and remember, harm a single animal, you will be terminated upon extraction. -Your Benefactors, The Animal Rights Consortium."
	objectives = list("Liberate all station pets.", "Free the animals housed in Virology, Xenobiology, Genetics, and, if you can manage to wrassle it away from the chef, your monkey.")
	tips = list("The chef WILL kill your monkey if you don't hide it quickly. Dealing with it can be a challenge without harming it like your employers wish, though!")
	job_whitelist = list("Bartender")

/datum/ambition_template/maintfu
	name = "Maintenance Combat"
	narrative = "You have been gifted. Interdyne has selected you for off-campus field-work in hostile territory. A report will be requested upon extraction."
	objectives = list("Create a deadly botanical concotion using just Nanotrasen Standard Equipment.")
	tips = list("Punji sticks are your best friend if things get hot.")
	job_whitelist = list("Botanist")

/datum/ambition_template/hannibal
	name = "Frontier Ripper"
	narrative = "Manners make the man, they make every man. This station you have inhabited for a long while has been filled with so many rude creatures. Your skills in the culinary arts will be helpful, thankfully no one ever checks where the meat came from. Its time to get the the rolodex out, have an old friend for dinner..."
	objectives = list("Make meals out of the rude.", "Make your judgements thematic.", "Cook the best part of someone. The leg of a lamb or runner will taste better than that of a skunk, just make sure the lamb stops screaming. Simply making a steak will not do, treat the meat with respect, make the best possible meal you can.")
	tips = list(" Whenever feasible, one should always try to eat the rude. The Wound Man is a popular choice. Classical music is known to enhance cooking by 40 percent, Goldberg variations even more so.")
	job_whitelist = list("Cook")

///SCIENCE
/datum/ambition_template/fsociety
	name = "Zero Sum"
	narrative = "What Im about to tell you is top secret. A conspiracy bigger than all of us. Theres a powerful group of people out there that are secretly running the world. Im talking about the guys no one knows about, the ones that are invisible. The top one percent of the top one percent, the guys that play God without permission. Nanotrasen, countless violations, countless evil...Its time for revenge, the plan,  all the debt we owe them. Every record of every credit card, loan, and mortgage would be wiped clean. It'd be impossible to reinforce outdated paper records. It would all be gone. The single, biggest incident of wealth redistribution in history. "
	objectives = list("Stage One, the Digital, records are kept in the vault and science database.", "Stage Two, physical, Contracts are kept in the Lawyers office, Detective Office and Chief Medical Officers office, destroy them, wipe it away, awaken the masses.", "Frame the RD for the Digital Attacks, plant his prints if you can, one of their employees doesnt matter much, though he's more use alive than dead.", "Broadcast your demands, theres an old earth film, the mask will be perfect for your theatrics, though any will do.")
	tips = list("All revolutions have casualties, this doesn't mean you should go around killing, this is for the people, the liberation. Sometimes another personality may help.")
	job_whitelist = list("Scientist")

//TODO: Everything Past Cook and Scientist Ambitions

/datum/ambition_template/mkultra
	name = "Mind Control Victim"
	narrative = "My head.... <groans> It keeps hurting, can't think straight... Gotta get a grip. They've done something to me, I know it, it was supposed to just be another medical checkup but somethings wrong, I don't feel like I'm myself anymore."
	objectives = list("Find out about the station's secret experiments, the documents hidden in the vault might have information on them.", "It happened after I went in for an appointment, perhaps interrogating the CMO will get me more information!", "They used some weird chamber on me, if I can get my hands on some of the disks they use to store technology perhaps I can expose them!", "I need to stay hidden though, they'll never believe me, or worse they'll sedate me and put me back in!")
	tips = list("The workers, they probably don't know much about this so I should avoid harming them...", "The heads will likely be tough to crack, but I know they're hiding it from me, sometimes you have to use force to get what you need.", "There might be others like me, I should try to contact them.")
	
/datum/ambition_template/yarrharr
	name = "Lone Pirate"
	narrative = "I've made it in, my maties are watching and supplying me with gear. The vault, the pearl of the station, just waiting for someone to walk in and take it's treasure. But it's not just riches I'm after, the leaders of this ship have been tyrannical and I think it's time for some justice at sea."
	objectives = list("Plan a raid on the vault and steal all the valuables inside, the golden belt especially will be a fine trophy.", "Capture a head of staff, maybe even the captain, and have the crew decide their fate, if they have been kind to their peope they will receive mercy.", "Escape alive and with your stolen goods.")
	tips = list("While the valuables are for me the justice is not, I'm here to enforce the will of the crew and whatever they decide will be the outcome")
	
/datum/ambition_template/cyberterror
	name = "Cyber Terrorist"
	narrative = "<%Uplink connection established, welcome #Agent#%> We have detected multiple ways to weaken the station through their artificial units, you will be tasked with manipulating the cybernetic elements of the station to greatly hinder it's productivity and teach them a lesson about over-reliance on technology!"
	objectives = list("Sabotage the camera feed of the station, make it hard for them to see.", "Hack APCs in strategic locations, this way we can disable their machinery and lights as we see fit.", "Acquire the authentication code for telecommunications and use it to monitor or delete messages, perhaps we can acquire more information or aid another agent this way.", "Our gear allows us to subvert the station borgs, they will be of great use to us.")
	tips = list("A multitool can be used to mess with the focus of the camera, it also won't trigger it's alert system.", "With a bit of experimentation and some signallers, we can remotely turn off power in areas via their APCs.", "The ability to read all messages is quite powerful, shame that the Chief Engineer did not bother to hide the paper with the password in his office!")
	
/datum/ambition_template/stampman
	name = "Stamp Collector"
	narrative = "Stamps, such an underappreciated art! Did you ever stop to take a closer look at one before marking a piece of paper with it? If you did, you'd notice all the intricate details that go into them, the beautiful sculpted pieces soaked in the ink... All left to gather dust in the offices of those moronic heads. I think it's time for someone with more appreciation for the art to take care of them!"
	objectives = list("Break into the office of every head of staff and steal their stamp, they will be fine additions to my collection!", "Leave signs and messages so that they may know the stamp man is coming!", "Try to keep a low profile and avoid open combat, cleanup costs are immense.")
	tips = list("Getting in is the easy part, an airlock authenticator, perhaps some jaws of lie should do the trick!", "Sure, we could go about it silently but where's the fun in that? A bit of gloating always makes things more interesting.")

/datum/ambition_template/syndicate_fight_club
	name = "Syndicate Fight Club"
	narrative = "Today you're feeling quite pent up and extra hyped. What's an awesome idea to do then? A fight club! It can let you blow off some steam and have some fun!"
	objectives = list("This is a really easy thing to do. Legally or illegally host your own fight club for the station crew and try to get a few members to join it.", "Any fight club needs a way to show who's their best fighter! So why don't you go and get the championship belt and brawl with your club members to see who is worthy of owning the belt..", "Prevent ALL acts of shutting down your fight club. The fight club will not end until it's abandoned you unless you have retired from your position and let one of your club members become the new leader.")
	tips = list("Not all fight clubs go by the same rules, you can try to get a form of martial arts or CQC in order to get the upperhand against your club members and or the station crew.", "A few ways of obtaining the championship belt is by either, A.) Having a brawl with the captain or a head of staff for it. B.) Breaking into the vault and taking it yourself. C.) Convincing the captain or a head of staff to give it to you.", "Now remember, in a fight club, there's only one rule: Don't talk about the fight club. Have an uprise against security for trying to stop your fight club, convince the captain to allow your fight club to exist, security and or medical will likely try to shut it down so stay aware of what security and medical are doing.")

