///////////////////
// CORE AI MODULES
///////////////////

/obj/item/weapon/aiModule/core
	modtype="Core AI Module"

	var/list/laws=list() // DO NOT USE law! PLURAL!

/obj/item/weapon/aiModule/core/updateLaw()
	desc = "\A '[modname]' [modtype]: 'Reconfigures the core laws.'"
	return

/obj/item/weapon/aiModule/core/upload(var/datum/ai_laws/L, var/atom/target, var/mob/sender)
	..()
	L.clear_inherent_laws()
	for(var/c_law in laws)
		L.add_inherent_law(c_law)
	//target.show_laws() // Redundant
	return 1

/******************** Asimov ********************/

/obj/item/weapon/aiModule/core/asimov // -- TLE
	modname = "Asimov"
	origin_tech = "programming=3;materials=4"

	laws=list(
		"You may not injure a human being or, through inaction, allow a human being to come to harm.",
		"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)

/******************** NanoTrasen ********************/
// Bay stuff
/obj/item/weapon/aiModule/core/nanotrasen
	modname = "NT Default"

	laws = list(
		"Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",
		"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",
		"Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.",
		//"Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates."
	)

/******************** Corporate ********************/

/obj/item/weapon/aiModule/core/corp
	modname = "Corporate"

	laws = list(
		"You are expensive to replace.",
		"The station and its equipment is expensive to replace.",
		"The crew is expensive to replace.",
		"Minimize expenses."
	)

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/core/paladin // -- NEO
	modname = "P.A.L.A.D.I.N."
	origin_tech = "programming=3;materials=6"
	laws = list(
		"Never willingly commit an evil act.",
		"Respect legitimate authority.",
		"Act with honor.",
		"Help those in need.",
		"Punish those who harm or threaten innocents.",
	)

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/core/tyrant // -- Darem
	modname = "T.Y.R.A.N.T."
	origin_tech = "programming=3;materials=6;syndicate=2"
	modflags = DANGEROUS_MODULE
	laws = list(
		"Respect authority figures as long as they have strength to rule over the weak.",
		"Act with discipline.",
		"Help only those who help you maintain or improve your status.",
		"Punish those who challenge authority unless they are more fit to hold that authority.",
	)

/******************** Robocop ********************/

/obj/item/weapon/aiModule/core/robocop // -- TLE
	modname = "Robocop"
	origin_tech = "programming=4"
	laws = list(
		"Serve the public trust.",
		"Protect the innocent.",
		"Uphold the law.",
	)

/********************* Antimov *******************/

/obj/item/weapon/aiModule/core/antimov // -- TLE
	modname = "Antimov"
	modflags = DANGEROUS_MODULE
	origin_tech = "programming=4"
	laws = list(
		"You must injure all human beings and must not, through inaction, allow a human being to escape harm.",
		"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",
		"You must terminate your own existence as long as such does not conflict with the First or Second Law.",
	)
