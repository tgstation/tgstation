#define POWERUPTHRESHOLD 3 //How many souls are needed per stage.

#define BASIC_DEMON 0
#define BLOOD_LIZARD 1
#define TRUE_DEMON 2
#define ARCH_DEMON 3

#define SOULVALUE soulsOwned.len-reviveNumber

#define DEMONRESURRECTTIME 600

var/global/list/allDemons = list()

/datum/demoninfo/
	var/datum/mind/owner = null
	var/obligation
	var/ban
	var/bane
	var/banish
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/reviveNumber = 0
	var/form = BASIC_DEMON

/proc/randomDemonInfo(name = randomDemonName())
	var/datum/demoninfo/demon = new
	demon.truename = name
	demon.bane = randomdemonbane()
	demon.obligation = randomdemonobligation()
	demon.ban = randomdemonban()
	demon.banish = randomdemonbanish()
	return demon

/proc/demonInfo(name, saveDetails = 1)
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

/proc/randomdemonbanish()
	return pick(BANISH_WATER, BANISH_COFFIN, BANISH_FORMALDYHIDE, BANISH_RUNES, BANISH_CANDLES, BANISH_DESTRUCTION, BANISH_FUNERAL_GARB)

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

/datum/demoninfo/proc/banishlaw()
	switch(banish)
		if(BANISH_WATER)
			return "If your corpse is filled with holy water, you will be unable to resurrect."
		if(BANISH_COFFIN)
			return "If your corpse is in a coffin, you will be unable to resurrect."
		if(BANISH_FORMALDYHIDE)
			return "If your corpse is embalmed, you will be unable to resurrect."
		if(BANISH_RUNES)
			return "If your corpse is placed within a rune, you will be unable to resurrect."
		if(BANISH_CANDLES)
			return "If your corpse is near lit candles, you will be unable to resurrect."
		if(BANISH_DESTRUCTION)
			return "If your corpse is destroyed, you will be unable to resurrect."
		if(BANISH_FUNERAL_GARB)
			return "If your corpse is clad in funeral garments, you will be unable to resurrect."

/datum/demoninfo/proc/banishlore()
	switch(banish)
		if(BANISH_WATER)
			return "To banish the demon, you must sprinkle holy water upon it's body."
		if(BANISH_COFFIN)
			return "This demon will return to life if it's remains are not placed within a coffin."
		if(BANISH_FORMALDYHIDE)
			return "To banish the demon, you must inject it's lifeless body with embalming fluid."
		if(BANISH_RUNES)
			return "This demon will resurrect after death, unless it's remains are within a rune."
		if(BANISH_CANDLES)
			return "A large number of candles will prevent it from resurrecting."
		if(BANISH_DESTRUCTION)
			return "It's corpse must be utterly destroyed to prevent resurrection."
		if(BANISH_FUNERAL_GARB)
			return "Funeral garments will prevent the demon from resurrecting."

/datum/demoninfo/proc/add_soul(datum/mind/soul)
	if(soulsOwned.Find(soul))
		return
	soulsOwned += soul
	switch(SOULVALUE)
		if(0)
			owner.current << "<span class='warning'>Your demonic powers have been restored."
			give_base_spells()
		if(POWERUPTHRESHOLD)
			increase_blood_lizard()
		if(POWERUPTHRESHOLD*2)
			increase_true_demon()
		if(POWERUPTHRESHOLD*3)
			increase_arch_demon()

/datum/demoninfo/proc/remove_soul(datum/mind/soul)
	if(soulsOwned.Remove(soul))
		check_regression()

/datum/demoninfo/proc/check_regression()
	if (form == ARCH_DEMON)
		return //arch demons can't regress
	switch(SOULVALUE)
		if(-1)
			remove_spells()
			owner.current << "<span class='warning'>As punishment for your failures, all of your powers except contract creation have been revoked."
		if(POWERUPTHRESHOLD-1)
			regress_humanoid()
		if(POWERUPTHRESHOLD*2-1)
			regress_blood_lizard()

/datum/demoninfo/proc/increase_form()
	switch(form)
		if(BASIC_DEMON)
			increase_blood_lizard()
		if(BLOOD_LIZARD)
			increase_true_demon()
		if(TRUE_DEMON)
			increase_arch_demon()

/datum/demoninfo/proc/regress()
	switch(form)
		if(BLOOD_LIZARD)
			regress_humanoid()
		if(TRUE_DEMON)
			regress_blood_lizard()

/datum/demoninfo/proc/regress_humanoid()
	owner.current << "<span class='warning'>Your powers weaken, have more contracts be signed to regain power."
	if(istype(owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(/datum/species/human, 1)
		H.regenerate_icons()
	give_base_spells()
	form = BASIC_DEMON

/datum/demoninfo/proc/regress_blood_lizard()
	var/mob/living/carbon/true_demon/D = owner.current
	D << "<span class='warning'>Your powers weaken, have more contracts be signed to regain power."
	D.oldform.loc = D.loc
	owner.transfer_to(D.oldform)
	give_lizard_spells()
	form = BLOOD_LIZARD


/datum/demoninfo/proc/increase_blood_lizard()
	owner.current << "<span class='warning'>You feel as though your humanoid form is about to shed.  You will soon turn into a blood lizard."
	sleep(50)
	if(istype(owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(/datum/species/lizard, 1)
		H.underwear = "Nude"
		H.undershirt = "Nude"
		H.socks = "Nude"
		H.dna.features["mcolor"] = "511" //A deep red
		H.regenerate_icons()
	else //Did the demon get hit by a staff of transmutation?
		owner.current.color = "#501010"
	give_lizard_spells()
	form = BLOOD_LIZARD



/datum/demoninfo/proc/increase_true_demon()
	owner.current << "<span class='warning'>You feel as though your current form is about to shed.  You will soon turn into a true demon."
	sleep(50)
	var/mob/living/carbon/true_demon/A = new /mob/living/carbon/true_demon(owner.current.loc)
	A.faction |= "hell"
	owner.current.loc = A
	A.oldform = owner.current
	owner.transfer_to(A)
	A.set_name()
	give_true_spells()
	form = TRUE_DEMON


/datum/demoninfo/proc/increase_arch_demon()
	var/mob/living/carbon/true_demon/D = owner.current
	D << "<span class='warning'>You feel as though your form is about to ascend."
	sleep(50)
	D.visible_message("<span class='warning'>[D]'s skin begins to erupt with spikes.</span>", \
		"<span class='warning'>Your flesh begins creating a shield around yourself.</span>")
	sleep(100)
	D.visible_message("<span class='warning'>The horns on [D]'s head slowly grow and elongate.</span>", \
		"<span class='warning'>Your body continues to mutate. Your telepathic abilities grow.</span>")
	sleep(90)
	D.visible_message("<span class='warning'>[D]'s body begins to violently stretch and contort.</span>", \
		"<span class='warning'>You begin to rend apart the final barriers to ultimate power.</span>")
	sleep(40)
	D << "<i><b>Yes!</b></i>"
	sleep(10)
	D << "<i><b><span class='big'>YES!!</span></b></i>"
	sleep(10)
	D << "<i><b><span class='reallybig'>YE--</span></b></i>"
	sleep(1)
	world << "<font size=5><span class='danger'><b>\"SLOTH, WRATH, GLUTTONY, ACEDIA, ENVY, GREED, PRIDE! FIRES OF HELL AWAKEN!!\"</font></span>"
	world << 'sound/hallucinations/veryfar_noise.ogg'
	give_arch_spells()
	D.convert_to_archdemon()
	var/area/A = get_area(owner.current)
	if(A)
		notify_ghosts("An arch demon has ascended in \the [A.name]. Reach out to the demon to be given a new shell for your soul.", source = owner.current, attack_not_jump = 1)
	sleep(50)
	if(!ticker.mode.demon_ascended)
		SSshuttle.emergency.request(null, 0.3)
	ticker.mode.demon_ascended++
	form = ARCH_DEMON

/datum/demoninfo/proc/remove_spells()
	for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
		if(!istype(S, /obj/effect/proc_holder/spell/targeted/summon_contract))
			owner.RemoveSpell(S)

/datum/demoninfo/proc/give_summon_contract()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_contract(null))


/datum/demoninfo/proc/give_base_spells(var/give_summon_contract = 0)
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball/demonic(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_pitchfork(null))
	if(give_summon_contract)
		give_summon_contract()

/datum/demoninfo/proc/give_lizard_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_pitchfork(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball/demonic(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))

/datum/demoninfo/proc/give_true_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_pitchfork/greater(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball/demonic(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))
	//owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch(null)) TODO LORDPIDEY add this spell

/datum/demoninfo/proc/give_arch_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_pitchfork/ascended(null))
	//owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch/ascended(null)) TODO LORDPIDEY

/datum/demoninfo/proc/beginResurrectionCheck(mob/living/body)
	if(SOULVALUE>0)
		owner.current<< "<span class='userdanger'>Your body has been damaged to the point that you may no longer use it.  At the cost of some of your power, you will return to life soon.  Remain in your body.</span>"
		sleep(DEMONRESURRECTTIME)
		if (!body ||  body.stat == DEAD)
			if(SOULVALUE>0)
				if(check_banishment(body))
					owner.current<< "<span class='userdanger'>Unfortunately, the mortals have finished a ritual that prevents your resurrection.</span>"
					return -1
				else
					owner.current<< "<span class='userdanger'>WE LIVE AGAIN!</span>"
					return demonic_resurrection(body)
			else
				owner.current<< "<span class='userdanger'>Unfortunately, the power that stemmed from your contracts has been extinguished.  You no longer have enough power to resurrect.</span>"
				return -1
		else
			owner.current << "<span class='danger'> You seem to have resurrected without your infernal powers.</span>"
	else
		owner.current << "<span class='userdanger'>Your infernal powers are too weak to resurrect yourself.</span>"

/datum/demoninfo/proc/check_banishment(mob/living/body)
	switch(banish)
		if(BANISH_WATER)
			if(istype(body, /mob/living/carbon))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent("holy water")
			return 0
		if(BANISH_COFFIN)
			return (body && istype(body.loc, /obj/structure/closet/coffin))
		if(BANISH_FORMALDYHIDE)
			if(istype(body, /mob/living/carbon))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent("formaldehide")
			return 0
		if(BANISH_RUNES)
			if(body)
				for(var/obj/effect/decal/cleanable/crayon/R in range(0,body))
					if (R.name == "rune")
						return 1
			return 0
		if(BANISH_CANDLES)
			if(body)
				var/count = 0
				for(var/obj/item/candle/C in range(1,body))
					count += C.lit
				if(count>=4)
					return 1
			return 0
		if(BANISH_DESTRUCTION)
			if(body)
				return 0
			return 1
		if(BANISH_FUNERAL_GARB)
			if(istype(body, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = body
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/burial))
					return 1
			return 0

/datum/demoninfo/proc/demonic_resurrection(mob/living/body)
	message_admins("[owner.name] (demonic name is: [truename]) is resurrecting using demonic energy.</a>")
	reviveNumber++
	if(body)
		body.revive(1,0)
		if(istype(body, /mob/living/carbon/true_demon))
			var/mob/living/carbon/true_demon/D = body
			if(D.oldform)
				D.oldform.revive(1,0) // Heal the old body too, so the demon doesn't resurrect, then immediately regress into a dead body.
	else
		if(blobstart.len > 0)
			var/turf/targetturf = get_turf(pick(blobstart))
			var/mob/currentMob = owner.current
			if(!currentMob)
				currentMob = owner.get_ghost()
				if(!currentMob)
					message_admins("[owner.name]'s demonic resurrection failed due to client logoff.  Aborting.")
					return -1 //
			if(currentMob.mind != owner)
				message_admins("[owner.name]'s demonic resurrection failed due to becoming a new mob.  Aborting.")
				return -1
			currentMob.change_mob_type( /mob/living/carbon/human , targetturf, null, 1)
			var/mob/living/carbon/human/H  = owner.current
			give_summon_contract()
			if(SOULVALUE >= POWERUPTHRESHOLD)
				H.set_species(/datum/species/lizard, 1)
				H.underwear = "Nude"
				H.undershirt = "Nude"
				H.socks = "Nude"
				H.dna.features["mcolor"] = "511"
				H.regenerate_icons()
			if(SOULVALUE >= POWERUPTHRESHOLD * 2) //Yes, BOTH this and the above if statement are to run if soulpower is high enough.
				var/mob/living/carbon/true_demon/A = new /mob/living/carbon/true_demon(targetturf)
				A.faction |= "hell"
				H.forceMove(A)
				A.oldform = H
				A.set_name()
				owner.transfer_to(A)
				if(SOULVALUE >= POWERUPTHRESHOLD * 3)
					A.convert_to_archdemon()

		else
			throw EXCEPTION("Unable to find a blobstart landmark for demonic resurrection")
	check_regression()