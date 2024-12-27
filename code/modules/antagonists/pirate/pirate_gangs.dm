///global lists of all pirate gangs that can show up today. they will be taken out of the global lists as spawned so dupes cannot spawn.
GLOBAL_LIST_INIT(light_pirate_gangs, init_pirate_gangs(is_heavy = FALSE))
GLOBAL_LIST_INIT(heavy_pirate_gangs, init_pirate_gangs(is_heavy = TRUE))

///initializes the pirate gangs glob list, adding all subtypes that can roll today.
/proc/init_pirate_gangs(is_heavy)
	var/list/pirate_gangs = list()

	for(var/type in subtypesof(/datum/pirate_gang))
		var/datum/pirate_gang/possible_gang = new type
		if(!possible_gang.can_roll())
			qdel(possible_gang)
		else if(possible_gang.is_heavy_threat == is_heavy)
			pirate_gangs += possible_gang
	return pirate_gangs

///datum for a pirate team that is spawning to attack the station.
/datum/pirate_gang
	///name of this gang, for spawning feedback
	var/name = "Space Bugs"

	///Whether or not this pirate crew is a heavy-level threat
	var/is_heavy_threat = FALSE
	///the random ship name chosen from pirates.json
	var/ship_name
	///the ship they load in on.
	var/ship_template_id = "ERROR"
	///the key to the json list of pirate names
	var/ship_name_pool = "some_json_key"
	///inbound message title the station receives
	var/threat_title = "Pay away the Space Bugs"
	///the contents of the message sent to the station.
	///%SHIPNAME in the content will be replaced with the pirate ship's name
	///%PAYOFF in the content will be replaced with the requested credits.
	var/threat_content = "This is the %SHIPNAME. Give us %PAYOFF credits or we bug out the universe trying to spawn!"
	///station receives this message upon the ship's spawn
	var/arrival_announcement = "We have come for your Bungopoints!"
	///what the station can say in response, first item pays the pirates, second item rejects it.
	var/list/possible_answers = list("Please, go away! We'll pay!", "I accept oblivion.")

	///station responds to message and pays the pirates
	var/response_received = "Yum! Bungopoints!"
	///station responds to message and pays the pirates
	var/response_rejected = "Foo! No Bungopoints!"
	///station pays the pirates, but after the ship spawned
	var/response_too_late = "Your Bungopoints arrived too late, rebooting world..."
	///station pays the pirates... but doesn't have enough cash.
	var/response_not_enough = "Not enough Bungopoints have been added into my bank account, rebooting world..."

	/// Have the pirates been paid off?
	var/paid_off = FALSE
	/// The colour of their announcements when sent to players
	var/announcement_color = "red"

/datum/pirate_gang/New()
	. = ..()
	ship_name = pick(strings(PIRATE_NAMES_FILE, ship_name_pool))

///whether this pirate gang can roll today. this is called when the global list initializes, so
///returning FALSE means it cannot show up at all for the entire round.
/datum/pirate_gang/proc/can_roll()
	return TRUE

///returns a new comm_message datum from this pirate gang
/datum/pirate_gang/proc/generate_message(payoff)
	var/built_threat_content = replacetext(threat_content, "%SHIPNAME", ship_name)
	built_threat_content = replacetext(built_threat_content, "%PAYOFF", payoff)
	return new /datum/comm_message(threat_title, built_threat_content, possible_answers)

///classic FTL-esque space pirates.
/datum/pirate_gang/rogues
	name = "Rogues"

	ship_template_id = "default"
	ship_name_pool = "rogue_names"

	threat_title = "Sector protection offer"
	threat_content = "Hey, pal, this is the %SHIPNAME. Can't help but notice you're rocking a wild \
		and crazy shuttle there with NO INSURANCE! Crazy. What if something happened to it, huh?! We've \
		done a quick evaluation of your rates in this sector, and we're offering %PAYOFF to cover your \
		shuttle in case of any disaster."
	arrival_announcement = "Do you want to reconsider our offer? Unfortunately, the time for negotiations has passed. Open up; we're coming aboard soon."
	possible_answers = list("Purchase Insurance.","Reject Offer.")

	response_received = "Sweet, free cash. Let's get outta here, boys."
	response_rejected = "Not paying was a mistake, now you need to take an economics class."
	response_too_late = "Payment or not, ignoring us was a matter of pride. Now it's time for us to teach some respect."
	response_not_enough = "You thought we wouldn't notice if you underpaid? Funny. We'll be seeing you soon."

///aristocrat lizards looking to hunt the serfs
/datum/pirate_gang/silverscales
	name = "Silverscales"

	ship_template_id = "silverscale"
	ship_name_pool = "silverscale_names"

	threat_title = "Tribute request"
	threat_content = "This is the %SHIPNAME. The Silver Scales wish for some tribute \
		from your plebeian lizards. %PAYOFF credits should do the trick."
	arrival_announcement = "Certainly, you don't deserve all of that aboard your vessel. It's going to fit us so much better."
	possible_answers = list("We'll pay.","Tribute? Really? Go away.")

	response_received = "A most generous donation. May the claws of Tizira reach into the furthest points of the cosmos."
	response_rejected = "That's for nothing, the first rule of hunting is don't leave without booty."
	response_too_late = "I see you're trying to pay, but the hunt is already on."
	response_not_enough = "You've sent an insulting \"donation\". The hunt is on for you."

///undead skeleton crew looking for booty
/datum/pirate_gang/skeletons
	name = "Skeleton Pirates"

	is_heavy_threat = TRUE
	ship_template_id = "dutchman"
	ship_name_pool = "skeleton_names" //just points to THE ONE AND ONLY

	threat_title = "Transfer of goods"
	threat_content = "Ahoy! This be the %SHIPNAME. Cough up %PAYOFF credits or you'll walk the plank."
	arrival_announcement = "The Jolly Roger won't wait forever, maties; we're lying alongside, ready to send you some gifts."
	possible_answers = list("We'll pay.","We will not be extorted.")

	response_received = "Thanks for the credits, landlubbers."
	response_rejected = "Blimey! All hands on deck, we're going to get their riches!"
	response_too_late = "Too late to beg for mercy!"
	response_not_enough = "Trying to cheat us? You'll regret this!"

///Expirienced formed employes of Interdyne Pharmaceutics now in a path of thievery and reckoning
/datum/pirate_gang/interdyne
	name = "Restless Ex-Pharmacists"

	is_heavy_threat = TRUE
	ship_template_id = "ex_interdyne"
	ship_name_pool = "interdyne_names"

	threat_title = "Funding for Research"
	threat_content = "Greetings, this is the %SHIPNAME. We require some funding for our pharmaceutical operations. \
		%PAYOFF credits should suffice."
	arrival_announcement = "We humbly ask for a substantial amount of income for the future research of our cause. It sure would be a shame if you got sick, but we can fix that."
	possible_answers = list("Very well.","Get a job!")

	response_received = "Thank you for your generosity. Your money will not be wasted."
	response_rejected = "Oh, you're not a station, you're a tumor. Well, we're gonna have to cut it out."
	response_too_late = "We hope you like skin cancer!"
	response_not_enough = "This is not nearly enough for our operations. I'm afraid we'll have to borrow some."
	announcement_color = "purple"

///Previous Nanotrasen Assitant workers fired for many reasons now looking for revenge and your bank account.
/datum/pirate_gang/grey
	name = "The Grey Tide"

	ship_template_id = "grey"
	ship_name_pool = "grey_names"

	threat_title = "This is a Robbery"
	threat_content = "Hey it's %SHIPNAME. Give us money. \
		%PAYOFF might be enough."
	arrival_announcement = "Nice stuff you got there, it's ours now."
	possible_answers = list("Please don't hurt me.","YOU WILL ANSWER TO THE LAW!!")

	response_received = "Wait, you ACTUALLY gave us the money? Thanks, but we're coming for the rest anyways!"
	response_rejected = "The answer to the law? We are the law! And you will be held responsible!"
	response_too_late = "Nothing, huh? Looks like the Tide's coming aboard!"
	response_not_enough = "You trying to cheat us? That's fine, we'll take your station as collateral."
	announcement_color = "yellow"

///Agents from the space I.R.S. heavily armed to stea- I mean, collect the station's tax dues
/datum/pirate_gang/irs
	name = "Space IRS Agents"

	is_heavy_threat = TRUE
	ship_template_id = "irs"
	ship_name_pool = "irs_names"

	threat_title = "Missing Tax Dues"
	threat_content = "%SHIPNAME Here, We noticed that your station hasn't been paying your taxes.. \
		Let's rectify that, Your missing tax dues amounts to %PAYOFF \
		We highly recommend paying your taxes stat, \
		we don't need to send a team to your station to resolve the situation do we?"
	arrival_announcement = "This is the tax conflict resolution team, prepare for your assets to be liquidated and be charged with tax fraud, \
		if you fail to pay your taxes in time."
	possible_answers = list("You know, I was just about to pay that. Thanks for the reminder!","I don't care WHO the IRS sends, I'm not paying for my taxes!")

	response_received = "Payment received, We salute you for being law-abiding tax-paying citizens"
	response_rejected = "We understand, I'm sending a team to your station to resolve the matter."
	response_too_late = "Too late, A team has already been sent out resolve this matter directly."
	response_not_enough = "You filed your taxes incorrectly, A team has been sent to assist in liquidating assets and arrest you for tax fraud. \
		Nothing personel kid."
	announcement_color = "yellow"

//Mutated Ethereals who have adopted bluespace technology in all the wrong ways.
/datum/pirate_gang/lustrous
	name = "Geode Scavengers"

	ship_template_id = "geode"
	ship_name_pool = "geode_names"

	threat_title = "Unusual transmission"
	threat_content = "The crystal of mother-void cracks, and forth comes the %SHIPNAME. We are the Lustrous, the hands of the crystal king.\
		Our coffers of bluespace dust are low, ergo, our synthesis ceases. %PAYOFF credits shall remedy this!"
	arrival_announcement = "We have arrived, we have always been here, and we have already left."
	possible_answers = list("Uh, ok? Sure."," We don't have time for crazy-talk, go away.")


	response_received = "An excellent haul, the synthesis shall resume."
	response_rejected = "The rudeness in your speech needs to be neutralized. And we can help you with that right now."
	response_too_late = "You were not ready then, and now that time has passed. We can only go forward, never back."
	response_not_enough = "You have insulted us, but there shall be no feud, only swift justice!"
	announcement_color = "purple"

//medieval militia, from OUTER SPACE!
/datum/pirate_gang/medieval
	name = "Medieval Warmongers"

	is_heavy_threat = TRUE
	ship_template_id = "medieval"
	ship_name_pool = "medieval_names"

	threat_title = "HOMAGE PAYMENT REQUEST"
	threat_content = "SALUTATIONS, THIS IS %SHIPNAME AND WE ARE COLLECTING MONEY \
		FROM THE VASSALS IN OUR TERRITORY, YOU JUST SO HAPPEN TO BE IN IT TOO!! NORMALLY \
		WE SLAUGHTER WEAKLINGS LIKE YOU FOR TRESPASING ON OUR LAND, BUT WE ARE WILLING \
		TO WELCOME YOU INTO OUR SPACE IF YOU PAY %PAYOFF AS HOMAGE TO OUR LAW. BE WISE ON YOUR CHOICE!! \
		(send message. send message. why message not sent?)."
	arrival_announcement = "I FIGURED OUT HOW TO FLY MY SHIP, WE WILL BE DOCKING NEXT TO YOU IN A MINUTE!!"
	possible_answers = list("Alright, i like my skull intact.","You are dumb, go larp somewhere else.")

	response_received = "THIS WILL SUFFICE, REMEMBER WHO OWNS YOU!!"
	response_rejected = "FOOLISH DECISION, I'LL MAKE AN EXAMPLE OUT OF YOUR CARCASS!! (does anyone remember how to pilot our ship?)"
	response_too_late = "YOU ARE ALREADY UNDER SIEGE YOU BUFFON, ARE YOU BRAINSICK OR IGNORANT?!!"
	response_not_enough = "DO THINK OF ME AS A JESTER? YOU ARE DEAD MEAT!! (i forgot how to fly the ship, tarnation.)"
