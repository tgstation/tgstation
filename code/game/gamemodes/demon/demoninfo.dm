#define POWERUPTHRESHOLD 3 //How many souls are needed per stage.

#define BASIC_DEMON 0
#define BLOOD_LIZARD 1
#define TRUE_DEMON 2
#define ARCH_DEMON 3

#define SOULVALUE soulsOwned.len-reviveNumber

var/list/allDemons = list()

/datum/demoninfo/
	var/datum/mind/owner = null
	var/obligation
	var/ban
	var/bane
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/reviveNumber = 0
	var/form = BASIC_DEMON

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
			return "Throwing salt at this demon will hinder his ability to use infernal powers temporarily."
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
		/*if(BANE_DIETYNAME)
			return "He will recoil at the sound of a diety's name."
		if(BANE_GOATBLOOD)
			return "The blood from a goat will surpress his powers."
		if(BANE_WOOD)
			return "Wooden weapons will strike him true."*/


/datum/demoninfo/proc/add_soul(var/datum/mind/soul)
	if(soulsOwned.Find(soul))
		return
	soulsOwned += soul
	world << "Added a soul, current SOULVALUE is: [SOULVALUE]"
	if((SOULVALUE)%POWERUPTHRESHOLD == 0)
		increase_form()

/datum/demoninfo/proc/remove_soul(var/datum/mind/soul)
	if(soulsOwned.Remove(soul))
		check_regression()

/datum/demoninfo/proc/check_regression()
	if((SOULVALUE)<0)
		//TODO LORDPIDEY: bad things happen when a demon has negative soul power
		return
	if((SOULVALUE)%POWERUPTHRESHOLD == POWERUPTHRESHOLD - 1)
		regress()
		return

/datum/demoninfo/proc/increase_form()
	world << "MEEP: now increasing form."
	switch(form)
		if(BASIC_DEMON)
			remove_basic()
			set_blood_lizard()
		if(BLOOD_LIZARD)
			remove_blood_lizard()
			set_true_demon()
		if(TRUE_DEMON)
			remove_true_demon()
			set_arch_demon()

/datum/demoninfo/proc/regress()
	switch(form)
		if(BLOOD_LIZARD)
			remove_blood_lizard()
			set_basic()
		if(TRUE_DEMON)
			remove_true_demon()
			set_blood_lizard()

/datum/demoninfo/proc/remove_basic()
/datum/demoninfo/proc/remove_blood_lizard()
/datum/demoninfo/proc/remove_true_demon()
/datum/demoninfo/proc/set_basic()
/datum/demoninfo/proc/set_blood_lizard()
	world << "MEEP: now setting blood lizard traits"
	if(istype(owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		H << "<span class='warning'>You feel as though your humanoid form is about to shed.  You will soon turn into a blood lizard."
		H.set_species(/datum/species/lizard, 1)
		H.underwear = "Nude"
		H.undershirt = "Nude"
		H.socks = "Nude"
		H.dna.features["mcolor"] = "511" //A deep red
		for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
			owner.RemoveSpell(S)
		H.regenerate_icons()



/datum/demoninfo/proc/set_true_demon()  //TODO LORDPIDEY: Finish these procs
/*	user << "<span class='warning'>You feel as though your humanoid form is about to shed.  You will soon turn into a true demon."
	sleep(50)
	var/mob/A = new /mob/living/simple_animal/ascendant_shadowling/arch_demon(H.loc)
	A.faction |= "hell"
	owner.transfer_to(A)
	for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
		owner.remove_spell(S)
	//TODO LORDPIDEY: add appropriate spells here.
	H.loc = A */




/datum/demoninfo/proc/set_arch_demon()
/*
	var/mob/living/H = user
	user << "<span class='warning'>You feel as though your form is about to ascend."
	sleep(50)
	H.visible_message("<span class='warning'>[H]'s skin begins to erupt with spikes.</span>", \
		"<span class='warning'>Your flesh begins creating a shield around yourself.</span>")
	sleep(100)
	H.visible_message("<span class='warning'>The horns on [H]'s head slowly grow and elongate.</span>", \
		"<span class='warning'>Your body continues to mutate. Your telepathic abilities grow.</span>")
	sleep(90)
	H.visible_message("<span class='warning'>[H]'s body begins to violently stretch and contort.</span>", \
		"<span class='warning'>You begin to rend apart the final barriers to ultimate power.</span>")
	sleep(40)
	H << "<i><b>Yes!</b></i>"
	sleep(10)
	H << "<i><b><span class='big'>YES!!</span></b></i>"
	sleep(10)
	H << "<i><b><span class='reallybig'>YE--</span></b></i>"
	sleep(1)
	world << "<font size=5><span class='danger'><b>\"SLOTH, WRATH, GLUTTONY, ACEDIA, ENVY, GREED, PRIDE! FIRES OF HELL AWAKEN!!\"</font></span>"
	world << 'sound/hallucinations/veryfar_noise.ogg'
	var/mob/A = new /mob/living/simple_animal/ascendant_shadowling/arch_demon(H.loc)
	for(var/obj/effect/proc_holder/spell/S in H.mind.spell_list)
		H.mind.remove_spell(S)
	//TODO LORDPIDEY: add appropriate spells here.
	H.mind.transfer_to(A)
	A.name = truename
	A.real_name = truename
	H.invisibility = 60
	H.loc = A
	sleep(50)
	if(!ticker.mode.demon_ascended)
		SSshuttle.emergency.request(null, 0.3)
	ticker.mode.demon_ascended = 1
	qdel(H)
	*/
