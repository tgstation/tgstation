var/list/allDemons = list()

/datum/demoninfo/
	var/datum/mind/owner = null
	var/obligation
	var/ban
	var/bane
	var/truename
	var/list/datum/mind/soulsOwned = new

/proc/randomDemonInfo(var/name = randomDemonName())
	var/datum/demoninfo/demon = new
	demon.truename = name
	demon.bane = randomdemonbane()
	demon.obligation = randomdemonobligation()
	demon.ban = randomdemonban()
	return demon

/proc/demonInfo(var/name, var/saveDetails = 1)
	if(allDemons[name])
		return allDemons[name]
	else
		var/datum/demoninfo/demon = randomDemonInfo(name)
		allDemons[name] = demon
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
	mainName = pick("Hal", "Ve", "Odr", "Neit", "Ci", "Quon", "Mya", "Folth", "Wren", "Gyer", "Geyr", "Hil", "Niet", "Twou", "Hu", "Don")
	while(prob(probability))
		mainName += pick("hal", "ve", "odr", "neit", "ca", "quon", "mya", "folth", "wren", "gyer", "geyr", "hil", "niet", "twoe", "phi", "coa")
		probability -= 20
	if(prob(40))
		suffix = pick(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr.")
	return preTitle + title + mainName + suffix

/proc/randomdemonobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_DRINK, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/proc/randomdemonban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_STRIKEUNCONCIOUS, BAN_HURTLIZARD, BAN_HURTANIMAL)

/proc/randomdemonbane()
	return pick(BANE_SALT, BANE_LIGHT, BANE_IRON, BANE_WHITECLOTHES, BANE_SILVER, BANE_HARVEST, BANE_TOOLBOX)

/datum/demoninfo/proc/obligationlaw()
	switch(obligation)
		if(OBLIGATION_FOOD)
			return "When not acting in self defense, you must always offer your victim food before harming them."
		if(OBLIGATION_DRINK)
			return "When not acting in self defense, you must always offer your victim drink before harming them."
		if(OBLIGATION_GREET)
			return "You must always greet other people by their last name before talking with them."
		if(OBLIGATION_PRESENCEKNOWN)
			return "You must always make your presence known before attacking."
		if(OBLIGATION_SAYNAME)
			return "You must always say your true name after you kill someone."
		if(OBLIGATION_ANNOUNCEKILL)
			return "Upon killing someone, you must make your deed known to all within earshot, over comms if reasonably possible."
		if(OBLIGATION_ANSWERTONAME)
			return "If you are not under attack, you must always respond to your demon name."

/datum/demoninfo/proc/obligationlore()
	switch(obligation)
		if(OBLIGATION_FOOD)
			return "This demon seems to always offer it's victims food before slaughtering them."
		if(OBLIGATION_DRINK)
			return "This demon seems to always offer it's victims a drink before slaughtering them."
		if(OBLIGATION_GREET)
			return "This demon seems to only be able to converse with people it knows the name of."
		if(OBLIGATION_PRESENCEKNOWN)
			return "This demon seems to be unable to attack from stealth."
		if(OBLIGATION_SAYNAME)
			return "He will always chant his name upon killing someone."
		if(OBLIGATION_ANNOUNCEKILL)
			return "This demon always loudly announces his kills for the world to hear."
		if(OBLIGATION_ANSWERTONAME)
			return "This demon always responds to his truename."

/datum/demoninfo/proc/banlaw()
	switch(ban)
		if(BAN_HURTWOMAN)
			return "You must never harm a female outside of self defense."
		if(BAN_CHAPEL)
			return "You must never attempt to enter the chapel."
		if(BAN_HURTPRIEST)
			return "You must never attack a priest."
		if(BAN_AVOIDWATER)
			return "You must never willingly touch a wet surface."
		if(BAN_STRIKEUNCONCIOUS)
			return "You must never strike an unconcious person."
		if(BAN_HURTLIZARD)
			return "You must never harm a lizardman outside of self defense."
		if(BAN_HURTANIMAL)
			return "You must never harm a non-sentient creature or robot outside of self defense."

/datum/demoninfo/proc/banlore()
	switch(ban)
		if(BAN_HURTWOMAN)
			return "This demon seems to prefer hunting men."
		if(BAN_CHAPEL)
			return "This demon avoids holy ground."
		if(BAN_HURTPRIEST)
			return "The annointed clergy appear to be immune to his powers."
		if(BAN_AVOIDWATER)
			return "The demon seems to have some sort of aversion to water, though it does not appear to harm him."
		if(BAN_STRIKEUNCONCIOUS)
			return "This demon only shows interest in those who are awake."
		if(BAN_HURTLIZARD)
			return "This demon will not strike a lizardman first."
		if(BAN_HURTANIMAL)
			return "This demon avoids hurting animals."

/datum/demoninfo/proc/banelaw()
	switch(bane)
		if(BANE_SILVER)
			return "Silver, in all of it's forms shall be your downfall."
		if(BANE_SALT)
			return "Salt will disrupt your magical abilities."
		if(BANE_LIGHT)
			return "Blinding lights will prevent you from using offensive powers for a time."
		if(BANE_IRON)
			return "Cold wrought iron shall act as poison to you."
		if(BANE_WHITECLOTHES)
			return "Those clad in pristine white garments will strike you true."
		if(BANE_HARVEST)
			return "The fruits of the harvest shall be your downfall."
		if(BANE_TOOLBOX)
			return "Toolboxes are bad news for you, for some reason."

/datum/demoninfo/proc/banelore()
	switch(bane)
		if(BANE_SILVER)
			return "Silver seems to gravely injure this demon."
		if(BANE_SALT)
			return "Throwing salt at this demon will hinder his ability to use infernal powers temporarially."
		if(BANE_LIGHT)
			return "Bright flashes will disorient the demon, likely causing him to flee."
		if(BANE_IRON)
			return "Cold iron will slowly injure him, until he can purge it from his system."
		if(BANE_WHITECLOTHES)
			return "Wearing clean white clothing will help ward off this demon."
		if(BANE_HARVEST)
			return "Presenting the labors of a harvest will disrupt the demon."
		if(BANE_TOOLBOX)
			return "That which holds the means of creation also holds the means of the demon's undoing."