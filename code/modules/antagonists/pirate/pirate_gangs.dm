///global list of all pirate gangs that can show up today. these will be taken out of the global list as spawned so dupes cannot spawn.
GLOBAL_LIST_INIT(pirate_gangs, init_pirate_gangs())

///initializes the pirate gangs glob list, adding all subtypes that can roll today.
/proc/init_pirate_gangs()
	var/list/pirate_gangs = list()

	for(var/type in subtypesof(/datum/pirate_gang))
		var/datum/pirate_gang/possible_gang = new type
		if(!possible_gang.can_roll())
			qdel(possible_gang)
		else
			pirate_gangs += possible_gang
	return pirate_gangs

///datum for a pirate team that is spawning to attack the station.
/datum/pirate_gang
	///name of this gang, for spawning feedback
	var/name = "Space Bugs"

	///the random ship name chosen from pirates.json
	var/ship_name
	///the ship they load in on.
	var/ship_template_id = "ERROR"
	///the key to the json list of pirate names
	var/ship_name_pool = "some_json_key"
	///inbound message title the station recieves
	var/threat_title = "Pay away the Space Bugs"
	///the contents of the message sent to the station.
	///%SHIPNAME in the content will be replaced with the pirate ship's name
	///%PAYOFF in the content will be replaced with the requested credits.
	var/threat_content = "This is the %SHIPNAME. Give us %PAYOFF credits or we bug out the universe trying to spawn!"
	///what the station can say in response, first item pays the pirates, second item rejects it.
	var/list/possible_answers = list("Please, go away! We'll pay!", "I accept oblivion.")

	///station responds to message and pays the pirates
	var/response_received = "Yum! Bungopoints!"
	///station pays the pirates, but after the ship spawned
	var/response_too_late = "Your Bungopoints arrived too late, rebooting world..."
	///station pays the pirates... but doesn't have enough cash.
	var/response_not_enough = "Not enough Bungopoints have been added into my bank account, rebooting world..."

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
		done a quick evaluation on your rates in this sector and we're offering %PAYOFF to cover for your \
		shuttle in case of any disaster."
	possible_answers = list("Purchase Insurance.","Reject Offer.")

	response_received = "Sweet, free cash. Let's get outta here, boys."
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
	possible_answers = list("We'll pay.","Tribute? Really? Go away.")

	response_received = "A most generous donation. May the claws of Tizira reach into the furthest points of the cosmos."
	response_too_late = "I see you're trying to pay, but the hunt is already on."
	response_not_enough = "You've sent an insulting \"donation\". The hunt is on for you."

///undead skeleton crew looking for booty
/datum/pirate_gang/skeletons
	name = "Skeleton Pirates"

	ship_template_id = "dutchman"
	ship_name_pool = "skeleton_names" //just points to THE ONE AND ONLY

	threat_title = "Transfer of goods"
	threat_content = "Ahoy! This be the %SHIPNAME. Cough up %PAYOFF credits or you'll walk the plank."
	possible_answers = list("We'll pay.","We will not be extorted.")

	response_received = "Thanks for the credits, landlubbers."
	response_too_late = "Too late to beg for mercy!"
	response_not_enough = "Trying to cheat us? You'll regret this!"

///psychic gangster junkies who want some allowance to continue the gore-binge
/datum/pirate_gang/psykers
	name = "Roving Psyker-gang"

	ship_template_id = "psyker"
	ship_name_pool = "psyker_names" //just points to THE ONE AND ONLY

	threat_title = "Junkie tribute"
	threat_content = "Hello, you psychically dormant pawn-pieces. It's the %SHIPNAME! Our funds are running a little low, and we're not going to be able to continue our gore-binge! %PAYOFF credits should do, wanna help us out?"
	possible_answers = list("Send some funds so they go away.","We're not funding these junkies.")

	response_received = "You guys aren't so bad for being dormants. Next gore-fest goes to you guys. Peace!"
	response_too_late = "Oh, now you think we're worth the money. Pathetic dormants."
	response_not_enough = "You really shouldn't have messed with us. You're in for a psychic nightmare."
