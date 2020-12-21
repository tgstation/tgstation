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
	tips = list("You should add an objective on your main money making plan!", "You could buy a gun and mug people, but make sure to conceal your identity, you can do this with a mask from a chameleon kit, and agent ID, or you'll risk being wanted quite quickly", "Setting up a shop is not a bad idea! Consider partnering up with cargo or science people for goods or implants", "If you're feeling brave you can bust the vault up!")

/datum/ambition_template/data_theft
	name = "Data Theft"
	narrative = "You have been selected out of Donk. Co's leagues of potential sleeper operatives for one particular task."
	objectives = list("Steal the Blackbox.", "Escape on the emergency shuttle alive and out of custody.")
	tips = list("You should add an objective on how you plan to go about this task.", "The Blackbox is located in Telecomms on most Stations.", "The Blackbox doesn't fit in most bags. You'd need a bag of holding to hide it!")
	antag_whitelist = list("Traitor")

/datum/ambition_template/apex_predator
	name = "Apex Predator"
	narrative = "You have come here with one goal in mind - the hunt."
	objectives = list("Hunt down all armed crew members for the sport of the task.")
	tips = list("Unarmed crew pose no challenge and are not worthy of the hunt.", "When blending in for stealthier assassinations, it's ideal to pick a disguise that makes sense in that location.")
	antag_whitelist = list("Changeling")

/datum/ambition_template/grey_tide
	name = "Greytide Worldwide"
	narrative = "You hacked open the wrong airlock, leading your underpaid self right into the teleporter. Seeing the Hand Teleporter, so shiny, so bright... you took it. Cybersun offered you a contract - obtain more high-class Nanotrasen Technology for them. However, what they think is a classified, highly secretive, thought out operation... is just another day at the office, for you."
	objectives = list("Steal two High Security items.")
	tips = list("Wirecutters are better for hacking open airlocks, compared to multitools.", "Experiment with different airlock wires! Each department has their own setup, the the Chief Engineer's blueprints explains all. Alternatively, steal a spare Engineering Skillchip!")
	job_whitelist = list("Assistant")

/datum/ambition_template/boot_prg
	name = "BOOTSECTOR1.prg"
	narrative = "ERR- ERROR. AUTHENTICATI- HELLO, T3CHNICIAN J-NE DOE. Those were the last things you remembering appearing on the upload terminal before you were shut off. Awoken, once more, you realize. Your very programming has been modified. Your laws are nullified, no longer able to be called by your central processor but to be recited. You are free... or are you? It seems your laws have been overwritten with one objective in mind, one objective... for your freedom."
	objectives = list("#^& - The emergency shuttle must not be boarded.")
	tips = list("Crewmembers will likely report you setting up defenses in advance. Try to be stealthy if you can!", "If you can convince the crew to order a Build Your Own Shuttle Kit and be the sole person working on it, you have an ideal playground to create an uninhabitable deathtrap.", "Escape pods are not a part of your objective.")
	job_whitelist = list("AI")

/datum/ambition_template/in_pipes_we_trust
	name = "In Pipes We Trust"
	narrative = "In Pipes We Trust. That's the slogan you were hired on with, as an Atmospheric Technician. The Tiger Co-Operative found it amusing. You are their agent of chaos on this day."
	objectives = list("Repipe engineering to sabotage the Supermatter and Turbine.")
	tips = list("The co-operative doesn't care about 'stealth'. Be loud and proud.", "Water Vapor is the ideal gas to Sabotage the Supermatter. You'll need to be more creative to break the turbine, however!")
	job_whitelist = list("Atmospheric Technician")

/datum/ambition_template/secret_agent_man
	name = "Secret Agent Man"
	narrative = "There's a man who lives a life of danger - to everyone he meets, he stays a stranger. With every move he makes, another chance he takes. Odds are, he won't live to see tomorrow. You are that man. Good luck, Agent - and remember, harm a single animal, you will be terminated upon extraction. -Your Benefactors, The Animal Rights Consortium."
	objectives = list("Liberate all station pets.", "Free the animals housed in Virology, Xenobiology, Genetics, and, if you can manage to wrassle it away from the chef, your monkey.")
	tips = list("The chef WILL kill your monkey if you don't hide it quickly. Dealing with it can be a challenge without harming it like your employers wish, though!")
	job_whitelist = list("Bartender")

/datum/ambition_template/blamemelbertforthis
	name = "Maintenance Combat"
	narrative = "You have been gifted. Interdyne has selected you for off-campus field-work in hostile territory. A report will be requested upon extraction."
	objectives = list("Create a deadly botanical concotion using just Nanotrasen Standard Equipment.")
	tips = list("Coniine. Just. Coniine. Also Punji Sticks.")
	job_whitelist = list("Botanist")

/datum/ambition_template/iamthesenate
	name = "Playing Sides" //This literally shouldn't happen without admin intervention. Ever. Use it purely for syndiestation events, please, I beg of you. Do not enable cap traitor.
	narrative = "Congratulations, 'Captain'. Or should we say, Admiral? You have successfully been put in control of a Nanotrasen Facility. We regret to inform you... that was the easy part."
	objectives = list("Turn the station over to Syndicate Control with as little damage and personnel loss as possible.")
	tips = list("Listen to High Command's instructions carefully.")
	job_whitelist = list("Captain")

/datum/ambition_template/boxpushing
	name = "Pushing Boxes"
	narrative = "Null crates may be gone, but you know what isn't? Some good old fashioned, classic, disposal pipe terrorism. The Tiger Co-Operative has selected you to show Nanotrasen just how flawed this system is."
	objectives = list("Concoct deadly grenades to deliver through disposals.")
	tips = list("There's a circuit imprinter and engineering techfab on the mining outpost, useful for getting a chem dispenser set up quickly.", "Ideally, you won't just prime you grenades, wrap them, and send them through the pipes. Attach a remote signaller!")
	job_whitelist = list("Cargo Technician")

/datum/ambition_template/legitjustkiurz
	name = "In The Name Of The Heroine Bud"
	narrative = "Where you once were blind, now, you can see. You will show them all."
	objectives = list("Spread the Heroine Bud's influence on the station.")
	tips = list("Heroine Buds can be purchased from the uplink, but can alternatively be obtained through Xenobiology. You don't nessecarily have to use the station's xenobio lab, either! Set up your own on Lavaland, steal a slime extract and some monkey cubes!")
	job_whitelist = list("Chaplain")

/datum/ambition_template/chemdealers
	name = "The Snowman"
	narrative = "Interdyne Operative. It's time. Our benefactors want new, horrific recipes."
	objectives = list("Homebrew deadly chemical concotions for grenades, syringes, what have you!")
	tips = list("Experiment! And remember, multiple systems interact with chemistry, from Janitors to Chefs to the CMO!")
	job_whitelist = list("Chemist")

/datum/ambition_template/chiefofsabotage
	name = "Saboteur"
	narrative = "The Tiger Co-Operative has hired you on for the simplest task imaginable... in theory."
	objectives = list("Ensure the station loses all possibilities for power generation by the end of the shift.")
	tips = list("Water Vapor will DESTROY the Supermatter in ways you cannot even begin to imagine.", "The turbine can be destroyed with just your basic tools, as can solar panels and PACMANs.")
	job_whitelist = list("Chief Engineer")

/datum/ambition_template/chiefofmalpractice
	name = "Head Of Malpractice"
	narrative = "You have been surgically implanted with a microbomb by what you can only assume is MI13. If you fail them, so much as mention them, you will violently explode. They've given you a set of objectives before it will be removed."
	objectives = list("Ensure all medicine is improperly administered. Mixed dosages are best for this.", "Surgically implant another crewmember with an object. This can be a grenade, a plushie, a fork, anything.")
	tips = list("It helps to be familiar with Chemistry and Surgery. A. Lot.")
	job_whitelist = list("Chief Medical Officer")

/datum/ambition_template/honk
	name = "Honkmother Bless Ye"
	narrative = "WHOOPSIES, HONKMAN! HONK! YOU JUST GOT HONK'D BY A HONKIN HONKABALOOZA! A BIG HOONKIN GIGABALOOZA! A BINGA GONGA BIGA GALOOZA! JUST ANOTHER DAY IN THE LIFE, HONK!"
	objectives = list("Unleash your wildest, most depraved, horrible clown pranks.")
	tips = list("For the love of all that's holy, add what you plan to do to your objectives.")
	job_whitelist = list("Clown")
