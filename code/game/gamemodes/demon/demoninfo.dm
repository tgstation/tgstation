#define BANESILVER 0
#define BANESALT 1
#define BANELIGHT 2
#define BANEIRON 3
#define BANEWHITECLOTHES 4

/datum/demoninfo/
	var/datum/mind/owner = null
	var/obligationlaw
	var/banlaw
	var/banelaw
	var/name
	var/banlore
	var/banelore
	var/obligationlore
	var/banetype

/proc/randomDemonInfo()
	var/datum/demoninfo/demon = new
	demon.name = randomDemonName()
	var/temp = randomdemonbane()
	demon.banelaw = temp[1]
	demon.banelore = temp[2]
	demon.banetype = temp[3]
	temp = randomdemonobligation()
	demon.obligationlaw = temp[1]
	demon.obligationlore = temp[2]
	temp = randomdemonban()
	demon.banlaw = temp[1]
	demon.banlore = temp[2]
	return demon

/proc/randomDemonName()
	var/preTitle = ""
	var/title = ""
	var/mainName = ""
	var/suffix = ""
	if(prob(65))
		if(prob(35))
			preTitle = pick("Dark ", "Hellish ", "Fiery ", "Sinful ", "Blood ")
		title = pick("Lord ", "Fallen Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept ")
	var/probability = 100
	mainName = pick("Hal", "Ve", "Odr", "Neit", "Ci", "Quon", "Mya", "Folth", "Wren", "Gyer", "Geyr", "Hil", "Niet", "Twou")
	while(prob(probability))
		mainName += pick("hal", "ve", "odr", "neit", "ca", "quon", "mya", "folth", "wren", "gyer", "geyr", "hil", "niet", "twoe")
		probability -= 25
	if(prob(40))
		suffix = pick(" the Red", " the Soulless", " the Master", ", the Lord of all things")
	return preTitle + title + mainName + suffix



/proc/randomdemonobligation()
	return pick(
		list("When not acting in self defense, you must always offer your victim food before harming them.",
		"This demon seems to always offer it's victims food before slaughtering them.  The supernatural rammifications are unknown at this time."),
		list("When not acting in self defense, you must always offer your victim drink before harming them.",
		"This demon seems to always offer it's victims a drink before slaughtering them.  The supernatural rammifications are unknown at this time."),
		list("You must always greet other people by their last name before talking with them.",
		"This demon seems to only be able to converse with people it knows the name of."),
		list("You must always make your presence known before attacking.",
		"This demon seems to be unable to attack from stealth."),
		list("You must always say your true name after you kill someone.",
		"He will always chant his name upon killing someone."),
		list("Upon killing someone, you must make your deed known to all within earshot, over comms if reasonably possible.",
		"This demon always loudly announces his kills for the world to hear."))

/proc/randomdemonban()
	return pick(
		list("You must never harm a female outside of self defense.",
		"This demon seems to prefer hunting men."),
		list("You must never enter the chapel.",
		"This demon avoids holy ground."),
		list("You must never attack a priest.",
		"The annointed clergy appear to be immune to his powers."),
		list("You must never willingly touch a wet surface.",
		"The demon seems to have some sort of aversion to water, though it does not appear to harm him."),
		list("You must never attack someone who is praying.",
		"Honest and true prayer seems to ward off this demon."),
		list("You must never strike at an unconcious person.",
		"This demon only shows interest in those who are awake."))

/proc/randomdemonbane()
	return pick(
		list("Silver, in all of it's forms shall be your downfall.",
		"Silver seems to gravely injure this demon.",
		BANESILVER),
		list("Salt will disrupt your magical abilities.",
		"Throwing salt at this demon will hinder his ability to use infernal powers temporarially.",
		BANESALT),
		list("Blinding lights will prevent you from using offensive powers for a time.",
		"Bright flashes will disorient the demon, likely causing him to flee.",
		BANELIGHT),
		list("Cold wrought iron shall act as poison to you, you can remove it in hellfire.",
		"Cold iron will slowly injure him, until he can purge it from his system.",
		BANEIRON),
		list("Those clad in pristine white garments will strike you true.",
		"Wearing clean white clothing will help ward off this demon.",
		BANEWHITECLOTHES))