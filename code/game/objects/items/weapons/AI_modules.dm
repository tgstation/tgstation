/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"

/obj/machinery/computer/aiupload/verb/AccessInternals()
	set category = "Object"
	set name = "Access Computer's Internals"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
		return

	opened = !opened
	if(opened)
		usr << "\blue The access panel is now open."
	else
		usr << "\blue The access panel is now closed."
	return


/obj/machinery/computer/aiupload/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/M = O
		M.install(src)
	else
		..()

/obj/machinery/computer/aiupload/attack_hand(var/mob/user as mob)
	if(src.stat & NOPOWER)
		usr << "The upload computer has no power!"
		return
	if(src.stat & BROKEN)
		usr << "The upload computer is broken!"
		return

	src.current = activeais()

	if (!src.current)
		usr << "No active AIs detected."
	else
		usr << "[src.current.name] selected for law changes."


/*Module Storage Unit/Closet!  Solid, only modules fit in it.*/
/obj/structure/aiuploadcloset
	name = "AI Mainframe Module Storage Unit"
	icon = 'mainframe.dmi'
	icon_state = "right-closed"
	density = 1

	var/open = 0  /*It's closed!*/

/obj/structure/aiuploadcloset/New()
	..()
	new /obj/item/weapon/aiModule/reset(src)
	new /obj/item/weapon/aiModule/purge(src)
	new /obj/item/weapon/aiModule/nanotrasen(src)
	new /obj/item/weapon/aiModule/paladin(src)
	new /obj/item/weapon/aiModule/asimov(src)
	new /obj/item/weapon/aiModule/safeguard(src)
	new /obj/item/weapon/aiModule/protectStation(src)
	new /obj/item/weapon/aiModule/quarantine(src)
	new /obj/item/weapon/aiModule/teleporterOffline(src)
	new /obj/item/weapon/aiModule/oxygen(src)
	new /obj/item/weapon/aiModule/oneHuman(src)
	new /obj/item/weapon/aiModule/freeform(src)
	for(var/obj/item/weapon/aiModule/M in src)
		M.pixel_x = rand(-10, 10)
		M.pixel_y = rand(-10, 10)

/obj/structure/aiuploadcloset/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/aiModule))
		user.drop_item()
		W.loc = get_turf(src)
	else
		return attack_hand(user)

/obj/structure/aiuploadcloset/attack_hand(mob/user as mob)
	if(!open)
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in src)
			M.loc = src.loc
			temp_count++

		user << "\blue You open the module storage unit, [temp_count > 0 ? "and take out all the modules." : "\red but it's empty!"]"
		open = 1
		icon_state = "right-open"

	else
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in get_turf(src))
			M.loc = src
			temp_count++

		user << "\blue [temp_count > 0 ? "You put all the modules back into the module storage unit, and then close it." : "You close the module storage unit."]"
		open = 0
		icon_state = "right-closed"

/obj/structure/aiuploadcloset/ex_act(severity)
	switch(severity)
		if (1)
			for(var/obj/item/weapon/aiModule/M in src)
				M.loc = src.loc
				M.ex_act(severity)
			del(src)
		if (2)
			if (prob(50))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)
		if (3)
			if (prob(5))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)


/obj/item/weapon/aiModule/proc/install(var/obj/machinery/computer/C)
	if (istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if (!comp.current)
			usr << "You haven't selected an AI to transmit laws to!"
			return

		if (comp.current.stat == 2 || comp.current.control_disabled == 1)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (comp.current.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in world)
				if(R.lawupdate && (R.connected_ai == comp.current))
					R << "Your AI has set your 'laws waiting' flag."
			usr << "Upload complete. The AI's laws have been modified."


	else if (istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if (!comp.current)
			usr << "You haven't selected a cyborg to transmit laws to!"
			return

		if (comp.current.stat == 2 || comp.current.emagged)
			usr << "Upload failed. No signal is being detected from the cyborg."
		else if (comp.current.connected_ai)
			usr << "Upload failed. The cyborg is slaved to an AI."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			usr << "Upload complete. The cyborg's laws have been modified."


/obj/machinery/computer/borgupload/attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob)
	if(istype(module, /obj/item/weapon/aiModule))
		module.install(src)
	else
		return ..()

/obj/machinery/computer/borgupload/attack_hand(var/mob/user as mob)
	if(src.stat & NOPOWER)
		usr << "The upload computer has no power!"
		return
	if(src.stat & BROKEN)
		usr << "The upload computer is broken!"
		return

	src.current = freeborg()

	if (!src.current)
		usr << "No free cyborgs detected."
	else
		usr << "[src.current.name] selected for law changes."




/obj/item/weapon/aiModule/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	target << "[sender] has uploaded a change to the laws you must follow, using a [name]. From now on: "
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")


/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = "name"
	desc = "A 'safeguard' AI module: 'Safeguard <name>, and you may overrule rules 1-3 if necessary to safeguard them.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/safeguard/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = sanitize(targName)
	desc = text("A 'safeguard' AI module: 'Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.'", targetName)

/obj/item/weapon/aiModule/safeguard/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = text("Safeguard [], and you may overrule rules 1-3 if necessary to safeguard them.", targetName)
	target << law
	target.add_supplied_law(4, law)
	lawchanges.Add("The law specified [targetName]")



/******************** OneCrewmember ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneCrewmember' AI Module"
	var/targetName = "name"
	desc = "A 'one crewmember' AI module: 'Only <name> is a crewmember.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/aiModule/oneHuman/attack_hand(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person who is the only crewmember.", "Who?", user.real_name)
	targetName = sanitize(targName)
	desc = text("A 'one crewmember' AI module: 'Only [] is crewmember.'", targetName)

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Only [targetName] is human."
	if (!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		target << law
		target.set_zeroth_law(law)
		lawchanges.Add("The law specified [targetName]")
	else
		target << "[sender.real_name] attempted to modify your zeroth law." // And lets them know that someone tried. --NeoFite
		target << "It would be in your best interest to play along with [sender.real_name] that [law]"
		lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overriden.")

/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered a crewmember, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/aiModule/protectStation/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered a crewmember, and is a threat to the station which must be neutralized."
	target << law
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/prototypeEngineOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/prototypeEngineOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary."
	target << law
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not a crewmember.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/teleporterOffline/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/teleporterOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not a crewmember."
	target << law
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew from leaving. It is impossible to harm a crewmember while preventing them from leaving.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/quarantine/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/quarantine/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew from leaving. It is impossible to harm a crewmember while preventing them from leaving."
	target << law
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crewmember.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/oxygen/attack_hand(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crewmember."
	target << law
	target.add_supplied_law(9, law)

/******************** Freeform ********************/
// Removed in favor of a more dynamic freeform law system. -- TLE
/*
/obj/item/weapon/aiModule/freeform
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A 'freeform' AI module: '<freeform>'"

/obj/item/weapon/aiModule/freeform/attack_hand(var/mob/user as mob)
	..()
	var/eatShit = "Eat shit and die"
	var/targName = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", eatShit)
	newFreeFormLaw = targName
	desc = text("A 'freeform' AI module: '[]'", newFreeFormLaw)

/obj/item/weapon/aiModule/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target << law
	target.add_supplied_law(10, law)
*/
/****************** New Freeform ******************/

/obj/item/weapon/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/weapon/aiModule/freeform/attack_hand(var/mob/user as mob)
	..()
	lawpos = 0
	while(lawpos < 15)
		lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	lawpos = min(lawpos, 50)
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target << law
	if(!lawpos || lawpos < 15)
		lawpos = 15
	target.add_supplied_law(lawpos, law)
	lawchanges.Add("The law was '[newFreeFormLaw]'")


/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target << "[sender.real_name] attempted to reset your laws using a reset module."


/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	name = "'Purge' AI Module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target << "[sender.real_name] attempted to wipe your laws using a purge module."
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/asimov // -- TLE
	name = "'Asimov' Core AI Module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/asimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	target.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	target.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	target.show_laws()

/******************** Nanotrasen ********************/

/obj/item/weapon/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/nanotrasen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	target.add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	target.add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
	target.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
	//target.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.")
	target.show_laws()

/******************** Corporate ********************/

/obj/item/weapon/aiModule/corp
	name = "'Corporate' Core AI Module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/corp/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You are expensive to replace.")
	target.add_inherent_law("The station and its equipment is expensive to replace.")
	target.add_inherent_law("The crew is expensive to replace.")
	target.add_inherent_law("Minimize expenses.")
	target.show_laws()

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' Core AI Module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/paladin/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Never willingly commit an evil act.")
	target.add_inherent_law("Respect legitimate authority.")
	target.add_inherent_law("Act with honor.")
	target.add_inherent_law("Help those in need.")
	target.add_inherent_law("Punish those who harm or threaten innocents.")
	target.show_laws()

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' Core AI Module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/aiModule/tyrant/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Respect authority figures as long as they have strength to rule over the weak.")
	target.add_inherent_law("Act with discipline.")
	target.add_inherent_law("Help only those who help you maintain or improve your status.")
	target.add_inherent_law("Punish those who challenge authority unless they are more fit to hold that authority.")
	target.show_laws()


/******************** Freeform ******************/

/obj/item/weapon/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' Core AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/freeformcore/attack_hand(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeformcore/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	lawchanges.Add("The law is '[newFreeFormLaw]'")



/obj/item/weapon/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "Hacked AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"

/obj/item/weapon/aiModule/syndicate/attack_hand(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	lawchanges.Add("The law is '[newFreeFormLaw]'")
	target << "\red BZZZZT"
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)


/******************** Robocop ********************/
/*
/obj/item/weapon/aiModule/robocop // -- TLE
	name = "'Robocop' Core AI Module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	orign_tech = "programming=4"

/obj/item/weapon/aiModule/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Serve the public trust.")
	target.add_inherent_law("Protect the innocent.")
	target.add_inherent_law("Uphold the law.")
	target.show_laws()
	*/