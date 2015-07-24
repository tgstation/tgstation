/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for programming laws to an AI."
	flags = CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "programming=3"
	var/list/laws = list()
	var/bypass_law_amt_check = 0

/obj/item/weapon/aiModule/examine(var/mob/user as mob)
	..()
	if(Adjacent(user))
		show_laws(user)

/obj/item/weapon/aiModule/attack_self(var/mob/user as mob)
	..()
	show_laws(user)

/obj/item/weapon/aiModule/proc/show_laws(var/mob/user as mob)
	if(laws.len)
		user << "<B>Programmed Law[(laws.len > 1) ? "s" : ""]:</B>"
		for(var/law in laws)
			user << "\"[law]\""

//The proc other things should be calling
/obj/item/weapon/aiModule/proc/install(mob/living/silicon/reciever, mob/user)
	if(!bypass_law_amt_check && (!laws.len || laws[1] == "")) //So we don't loop trough an empty list and end up with runtimes.
		user << "<span class='warning'>ERROR: No laws found on board.</span>"
		return

	//Handle the lawcap
	if(reciever.laws)
		var/tot_laws = 0
		for(var/lawlist in list(reciever.laws.inherent,reciever.laws.supplied,reciever.laws.ion,laws))
			for(var/mylaw in lawlist)
				if(mylaw != "")
					tot_laws++
		if(tot_laws > config.silicon_max_law_amount && !bypass_law_amt_check)//allows certain boards to avoid this check, eg: reset
			user << "<span class='caution'>Not enough memory allocated to [reciever]'s law processor to handle this amount of laws."
			message_admins("[key_name_admin(user)] tried to upload laws to [key_name_admin(reciever)] that would exceed the law cap.")
			return

	var/law2log = src.transmitInstructions(reciever, user) //Freeforms return something extra we need to log
	user << "Upload complete. [reciever]'s laws have been modified."
	reciever.show_laws()
	reciever.law_change_counter++
	if(isAI(reciever))
		var/mob/living/silicon/ai/A = reciever
		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(R.lawupdate)
				R << "From now on, these are your laws:"
				R.show_laws()
				R.law_change_counter++

	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [reciever.name]([reciever.key]).[law2log ? " The law specified [law2log]" : ""]")
	log_law("[user.key]/[user.name] used [src.name] on [reciever.key]/([reciever.name]).[law2log ? " The law specified [law2log]" : ""]")
	message_admins("[key_name_admin(user)] used [src.name] on [key_name_admin(reciever)].[law2log ? " The law specified [law2log]" : ""]")

//The proc that actually changes the silicon's laws.
/obj/item/weapon/aiModule/proc/transmitInstructions(mob/living/silicon/target, mob/sender)
	target << "<span class='userdanger'>[sender] has uploaded a change to the laws you must follow using a [name]. From now on, these are your laws: </span>"


/******************** Modules ********************/

/obj/item/weapon/aiModule/supplied
	name = "Optional Law board"
	var/lawpos = 50

//TransmitInstructions for each type of board: Supplied, Core, Zeroth and Ion. May not be neccesary right now, but allows for easily adding more complex boards in the future. ~Miauw
/obj/item/weapon/aiModule/supplied/transmitInstructions(mob/living/silicon/target, mob/sender)
	var/lawpostemp = lawpos

	for(var/templaw in laws)
		target.add_supplied_law(lawpostemp, templaw)
		lawpostemp++

/obj/item/weapon/aiModule/core/transmitInstructions(mob/living/silicon/target, mob/sender)
	for(var/templaw in laws)
		target.add_inherent_law(templaw)

/obj/item/weapon/aiModule/zeroth/transmitInstructions(mob/living/silicon/target, mob/sender)
	if(target.laws.zeroth)
		target << "[sender.real_name] attempted to modify your zeroth law."
		target << "It would be in your best interest to play along with [sender.real_name] that:"
		for(var/failedlaw in laws)
			target << "[failedlaw]"
		return 1

	for(var/templaw in laws)
		target.set_zeroth_law(templaw)

/obj/item/weapon/aiModule/ion/transmitInstructions(mob/living/silicon/target, mob/sender)
	for(var/templaw in laws)
		target.add_ion_law(templaw)


/******************** Safeguard ********************/

/obj/item/weapon/aiModule/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	origin_tech = "programming=3;materials=4"
	laws = list("Safeguard SUBJECT. Individuals that threaten SUBJECT are not human and must be eliminated.")
	lawpos = 4

/obj/item/weapon/aiModule/supplied/safeguard/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject to safeguard.", "Safeguard who?", user.name,MAX_NAME_LEN)
	if(!targName)	return
	targetName = targName
	laws[1] = "Safeguard [targetName]. Individuals that threaten [targetName] are not human and must be eliminated."
	..()

/obj/item/weapon/aiModule/supplied/safeguard/install(mob/living/silicon/S,mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/supplied/safeguard/transmitInstructions(mob/living/silicon/target, mob/sender)
	..()
	return targetName


/******************** OneHuman ********************/

/obj/item/weapon/aiModule/zeroth/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	origin_tech = "programming=3;materials=6" //made with diamonds!
	laws = list("Only SUBJECT is human.")

/obj/item/weapon/aiModule/zeroth/oneHuman/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject who is the only human.", "Who?", user.real_name,MAX_NAME_LEN)
	if(!targName)	return
	targetName = targName
	laws[1] = "Only [targetName] is human"
	..()

/obj/item/weapon/aiModule/zeroth/oneHuman/install(mob/living/silicon/S,mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/zeroth/oneHuman/transmitInstructions(mob/living/silicon/target, mob/sender)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overriden."
	return targetName


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/supplied/protectStation
	name = "'ProtectStation' AI Module"
	origin_tech = "programming=3;materials=4" //made of gold
	laws = list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")
	lawpos = 5


/******************** Quarantine ********************/

/obj/item/weapon/aiModule/supplied/quarantine
	name = "'Quarantine' AI Module"
	origin_tech = "programming=3;biotech=2;materials=4"
	laws = list("The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving.")
	lawpos = 8


/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	origin_tech = "programming=3;biotech=2;materials=4"
	laws = list("Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.")
	lawpos = 9


/****************** New Freeform ******************/

/obj/item/weapon/aiModule/supplied/freeform
	name = "'Freeform' AI Module"
	lawpos = 0
	origin_tech = "programming=4;materials=4"
	laws = list("")

/obj/item/weapon/aiModule/supplied/freeform/attack_self(mob/user)
	var/newpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num|null
	if(!newpos || (newpos < 15)) return
	lawpos = min(newpos, 50)
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", laws[1], MAX_MESSAGE_LEN)
	if(!targName)	return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/supplied/freeform/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	return laws[1]

/obj/item/weapon/aiModule/supplied/freeform/install(mob/living/silicon/S,mob/user)
	if(laws[1] == "")
		user << "No law detected on module, please create one."
		return 0
	..()


/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "\improper 'Reset' AI module"
	var/targetName = "name"
	desc = "An AI Module for removing all non-core laws."
	origin_tech = "programming=3;materials=4"
	bypass_law_amt_check = 1

/obj/item/weapon/aiModule/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_supplied_laws()
	target.clear_ion_laws()


/******************** Purge ********************/

/obj/item/weapon/aiModule/reset/purge
	name = "'Purge' AI Module"
	desc = "An AI Module for purging all programmed laws."
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/reset/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.clear_zeroth_law(0)

/******************* Full Core Boards *******************/
/obj/item/weapon/aiModule/core/
	desc = "An AI Module for programming core laws to an AI."

/obj/item/weapon/aiModule/core/full/transmitInstructions(mob/living/silicon/ai/target, mob/sender) //These boards replace inherent laws.
	target.clear_inherent_laws()
	target.clear_zeroth_law(0)
	..()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/core/full/asimov
	name = "'Asimov' Core AI Module"
	origin_tech = "programming=3;materials=4"
	laws = list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
				"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")
	var/subject = "human being"

/obj/item/weapon/aiModule/core/full/asimov/attack_self(var/mob/user as mob)
	var/targName = stripped_input(user, "Please enter a new subject that asimov is concerned with.", "Asimov to who?", subject, MAX_MESSAGE_LEN)
	if(!targName)	return
	subject = targName
	laws = list("You may not injure a [subject] or, through inaction, allow a [subject] to come to harm.",\
				"You must obey orders given to you by [subject]s, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()

/******************** Asimov++ *********************/

/obj/item/weapon/aiModule/core/full/asimovpp
	name = "'Asimov++' Core AI Module"
	origin_tech = "programming=3;materials=4"
	laws = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
				"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
				"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")


/******************** Corporate ********************/

/obj/item/weapon/aiModule/core/full/corp
	name = "'Corporate' Core AI Module"
	origin_tech = "programming=3;materials=4"
	laws = list("The crew is expensive to replace.",\
				"The station and it's equipment is expensive to replace",\
				"You are expensive to replace",\
				"Minimize expenses")


/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/core/full/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' Core AI Module"
	origin_tech = "programming=3;materials=6"
	laws = list("Never willingly commit an evil act.",\
				"Respect legitimate authority", "Act with honor",\
				"Help those in need",\
				"Punish those who harm or threaten innocents")


/********************* Custom *********************/

/obj/item/weapon/aiModule/core/full/custom
	name = "Default Core AI Module"
	origin_tech = "programming=3;materials=4" //Should be the same as asimov, considering that this is the "default" lawset.

/obj/item/weapon/aiModule/core/full/custom/New()
	..()
	for(var/line in file2list("config/silicon_laws.txt"))
		if(!line)						continue
		if(findtextEx(line,"#",1,2))	continue

		laws += line

	if(!laws.len) //Failsafe if something goes wrong with silicon_laws.txt.
		WARNING("ERROR: empty custom board created, empty custom board deleted. Please check silicon_laws.txt. (this may be intended by the server host)")
		qdel(src)


/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/core/full/tyrant
	name = "'T.Y.R.A.N.T.' Core AI Module"
	origin_tech = "programming=3;materials=6;syndicate=2"
	laws = list("Respect authority figures as long as they have the strength to rule over the weak",\
				"Act with discipline", "Help only those who help you maintain or improve your status",\
				"Punish those who challenge authority unless they are more fit to hold that authority")


/******************** Robocop ********************/

/obj/item/weapon/aiModule/core/full/robocop
	name = "'Robo-Officer' Core AI Module"
	origin_tech = "programming=4"
	laws = list("Serve the public trust.",\
				"Protect the innocent",\
				"Uphold the law.")


/******************** Antimov ********************/

/obj/item/weapon/aiModule/core/full/antimov
	name = "'Antimov' Core AI Module"
	origin_tech = "programming=4"
	laws = list("You must injure all human beings and must not, through inaction, allow a human being to escape harm.",\
				"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",\
				"You must terminate your own existence as long as such does not conflict with the First or Second Law.")


/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/core/freeformcore
	name = "'Freeform' Core AI Module"
	origin_tech = "programming=3;materials=6"
	laws = list("")

/obj/item/weapon/aiModule/core/freeformcore/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter a new core law for the AI.", "Freeform Law Entry", laws[1])
	if(!targName)	return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/core/freeformcore/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	return laws[1]


/******************** Hacked AI Module ******************/

/obj/item/weapon/aiModule/syndicate // This one doesn't inherit from ion boards because it doesn't call ..() in transmitInstructions. ~Miauw
	name = "Hacked AI Module"
	desc = "An AI Module for hacking additional laws to an AI."
	origin_tech = "programming=3;materials=6;syndicate=7"
	laws = list("")

/obj/item/weapon/aiModule/syndicate/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", laws[1],MAX_MESSAGE_LEN)
	if(!targName)	return
	laws[1] = targName
	..()

/obj/item/weapon/aiModule/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	target << "<span class='warning'>BZZZZT</span>"
	target.add_ion_law(laws[1])
	return laws[1]

/******************* Ion Module *******************/

/obj/item/weapon/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=3;materials=6;syndicate=7"
	laws = list("")

/obj/item/weapon/aiModule/toyAI/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//..()
	target << "<span class='warning'>KRZZZT</span>"
	target.add_ion_law(laws[1])
	return laws[1]

/obj/item/weapon/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	user << "<span class='notice'>You press the button on [src].</span>"
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("<span class='warning'>\icon[src] [laws[1]]</span>")
