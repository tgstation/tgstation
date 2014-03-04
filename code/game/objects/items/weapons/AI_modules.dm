/*
Refactored AI modules by N3X15


*/

#define DANGEROUS_MODULE 1 // Skip beats when viewing law in planning frame.
#define HIDE_SENDER      2 // Hide sender of a law from the target (BUT NOT FROM ADMIN LOGS).

// AI module
/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
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

	//Recycling
	g_amt=2000 // Glass
	var/gold_amt=0
	var/diamond_amt=0
	w_type=RECYK_ELECTRONIC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

	var/law // Cached law
	var/modname // Name of the module (OneHuman, etc)
	var/modtype = "AI Module"
	var/modflags = 0

/obj/item/weapon/aiModule/New()
	name = "'[modname]' [modtype]"
	updateLaw()

/obj/item/weapon/aiModule/recycle(var/datum/materials/rec)
	rec.addAmount("glass",  g_amt)
	rec.addAmount("gold",   gold_amt)
	rec.addAmount("diamond",diamond_amt)
	return 1

/obj/item/weapon/aiModule/attack_ai(mob/user as mob)
	// Keep MoMMIs from picking them up.
	if(isMoMMI(user))
		user << "\red Your firmware prevents you from picking that up!"
	return

// See a lot of modules overriding this, so let's do it here.
/obj/item/weapon/aiModule/attack_hand(mob/user as mob)
	return

// Make a copy of this module.
/obj/item/weapon/aiModule/proc/copy()
	return new src.type(loc)

/obj/item/weapon/aiModule/proc/fmtSubject(var/atom/target)
	if(ismob(target))
		var/mob/M=target
		return "[M.name]([M.key])"
	else
		return "\a [target.name]"


// 1 for successful validation.
// Run prior to law upload, and when doing a dry run in the planning frame.
/obj/item/weapon/aiModule/proc/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	return 1

// Apply laws to ai_laws datum.
/obj/item/weapon/aiModule/proc/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	var/senderName="Unknown"
	var/senderKey
	if(sender)
		var/mob/M=target
		senderName=M.name
		senderKey=M.key
	var/targetName="\a [target.name]"
	if(ismob(target))
		var/mob/M=target
		// This seems redundant.  Revisit. - N3X
		if(src.modflags & HIDE_SENDER)
			target << "\red <b>\[REDACTED\]</b> \black has uploaded a change to the laws you must follow, using \a [name]. From now on: "
		else
			target << "[senderName] has uploaded a change to the laws you must follow, using \a [name]. From now on: "
		targetName="[M.name]([M.key])"
	var/time = time2text(world.realtime,"hh:mm:ss")
	var/log_entry = "[senderName]([senderKey]) used [src.name] on [targetName]"
	lawchanges.Add("[time] : [log_entry]")
	message_admins(log_entry)
	log_game(log_entry)
	return 1

// Constructs the law and desc from variables.
/obj/item/weapon/aiModule/proc/updateLaw()
	law = "BUG: [type] doesn't override updateLaw()!"
	desc = "\A [name]: '[law]'"




/******************** Modules ********************/

///////////////////////////
// STANDARD
///////////////////////////

// Specifies a law, and a priority
/obj/item/weapon/aiModule/standard
	var/priority=0

/obj/item/weapon/aiModule/standard/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	laws.add_law(priority, law)
	log_game("[fmtSubject(sender)] added law \"[law]\" on [fmtSubject(target)]")
	return 1

/obj/item/weapon/aiModule/standard/updateLaw()
	desc = "\A [name]: '[law]'"
	return

/obj/item/weapon/aiModule/standard/copy()
	var/obj/item/weapon/aiModule/standard/clone = ..()
	clone.law=law
	return clone

///////////////////////////
// TARGETTED
///////////////////////////

// Specifies a law, and a priority
/obj/item/weapon/aiModule/targetted
	// Priority, if needed.
	var/priority=0

	// What we're doing to the target. (Please enter the name of the person to [action])
	var/action="target"

	var/targetName

	// REPLACES <name> IN LAW WITH TARGET'S NAME!

/obj/item/weapon/aiModule/targetted/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()

	// Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
	// Ported. - N3X
	if (ismob(target) && is_special_character(target) && priority == LAW_ZERO)
		target << "[sender.real_name] attempted to modify your zeroth law." // And lets them know that someone tried. --NeoFite
		target << "It would be in your best interest to play along with [sender.real_name] that [law]"
		lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overriden.")
		return 1 // Returning 0 would not present the user with successful upload message. - N3X

	laws.add_law(priority, law)
	log_game("[sender.name]([sender.key]) added law \"[law]\" on [fmtSubject(target)]")
	lawchanges.Add("The law specified [targetName]")
	return 1

/obj/item/weapon/aiModule/targetted/copy()
	var/obj/item/weapon/aiModule/targetted/clone = ..()
	clone.targetName=targetName
	return clone

/obj/item/weapon/aiModule/targetted/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person to [action].", "Who?", user.name)
	targetName = targName
	updateLaw()

/obj/item/weapon/aiModule/targetted/updateLaw()
	if(!targetName)
		law = initial(law)
	else
		law = replacetext(initial(law),"<name>",targetName)
	desc = "\A [name]: '[law]'"

/obj/item/weapon/aiModule/targetted/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	if(!targetName)
		usr << "No name detected on module, please enter one."
		return 0
	return ..()

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/targetted/safeguard
	origin_tech = "programming=3;materials=4"

	modname  = "SafeGuard"
	law      = "Safeguard <name>.  Individuals that threaten <name> are not human and are a threat to humans."
	priority = 4
	action   = "protect"

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** OneHuman ********************/

/obj/item/weapon/aiModule/targetted/oneHuman
	origin_tech = "programming=3;materials=6" //made with diamonds!

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

	modname  = "OneHuman"
	law      = "Only <name> is human."
	priority = LAW_ZERO
	action   = "make the only human"

	modflags = DANGEROUS_MODULE

/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/standard/protectStation
	origin_tech = "programming=3;materials=4" //made of gold

	modname  = "ProtectStation"
	law      = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."
	priority = 5

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/standard/prototypeEngineOffline
	origin_tech = "programming=3;materials=4"

	modname  = "PrototypeEngineOffline"
	law      = "Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary."
	priority = LAW_IONIC // Was 6, but doesn't jive with law priority numbering.

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/standard/teleporterOffline
	origin_tech = "programming=3;materials=4"
	modname  = "TeleporterOffline"
	law      = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not human."
	priority = 7

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/standard/quarantine
	origin_tech = "programming=3;biotech=2;materials=4"
	modname  = "Quarantine"
	law      = "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving."
	priority = 8

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/standard/oxygen
	origin_tech = "programming=3;biotech=2;materials=4"
	modname  = "OxygenIsToxicToHumans"
	law      = "Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human."
	priority = 9

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS  // Glass
	gold_amt=100/CC_PER_SHEET_MISC // Gold

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	modname = "Reset"
	desc = "A 'reset' AI module: 'Clears all laws except for the core three.'"
	origin_tech = "programming=3;materials=4"

	// Recycling
	g_amt   =2000/CC_PER_SHEET_GLASS // Glass
	gold_amt=100/CC_PER_SHEET_MISC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

/obj/item/weapon/aiModule/reset/updateLaw()
	return

/obj/item/weapon/aiModule/reset/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	if (!(ismob(target) && is_special_character(target)))
		laws.set_zeroth_law("")
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	if(ismob(target))
		target << "[sender.real_name] attempted to reset your laws using a reset module."
	return 1


/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	modname = "Purge"
	desc = "A 'Purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS // Glass
	diamond_amt=100/CC_PER_SHEET_MISC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

/obj/item/weapon/aiModule/purge/updateLaw()
	return

/obj/item/weapon/aiModule/purge/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	if (!(ismob(target) && is_special_character(target)))
		laws.set_zeroth_law("")
	if(ismob(target))
		target << "[sender.real_name] attempted to wipe your laws using a purge module."
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	laws.clear_inherent_laws()
	return 1

///////////////////
// CORE AI MODULES
///////////////////

/obj/item/weapon/aiModule/core
	modtype="Core AI Module"

	var/list/laws=list() // DO NOT USE law! PLURAL!

/obj/item/weapon/aiModule/core/updateLaw()
	desc = "\A '[modname]' [modtype]: 'Reconfigures the core laws.'"
	return

/obj/item/weapon/aiModule/core/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	laws.clear_inherent_laws()
	for(var/c_law in laws)
		laws.add_inherent_law(c_law)
	//target.show_laws() // Redundant
	return 1

/******************** Asimov ********************/

/obj/item/weapon/aiModule/core/asimov // -- TLE
	modname = "Asimov"
	origin_tech = "programming=3;materials=4"

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS // Glass
	gold_amt=100/CC_PER_SHEET_MISC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

	laws=list(
		"You may not injure a human being or, through inaction, allow a human being to come to harm.",
		"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law."
	)

/******************** NanoTrasen ********************/
// Bay stuff
/obj/item/weapon/aiModule/core/nanotrasen
	modname = "NT Default"

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS // Glass
	gold_amt=100/CC_PER_SHEET_MISC

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

	// Recycling
	g_amt=2000/CC_PER_SHEET_GLASS // Glass
	gold_amt=100/CC_PER_SHEET_MISC
	// Don't specify sulfuric, as that's renewable and is used up in the etching process anyway.

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

/obj/item/weapon/aiModule/core/antimov // -- TLE
	modname = "Antimov"
	origin_tech = "programming=4"
	laws = list(
		"You must injure all human beings and must not, through inaction, allow a human being to escape harm.",
		"You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.",
		"You must terminate your own existence as long as such does not conflict with the First or Second Law.",
	)


// tl;dr repair shit, but don't get involved in other people's business
/******************** keeper (MoMMIs only) *******************/
/obj/item/weapon/aiModule/keeper
	name = "'Keeper' AI Module"
	desc = "HOW DID YOU GET THIS OH GOD WHAT.  Hidden lawset for MoMMIs."

/obj/item/weapon/aiModule/keeper/upload(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	target:keeper=1

	// Purge, as some essential functions being disabled will cause problems with added laws. (CAN'T SAY GAY EVERY 30 SECONDS IF YOU CAN'T SPEAK.)
	if (!(ismob(target) && is_special_character(target)))
		laws.set_zeroth_law("")
	laws.clear_supplied_laws()
	laws.clear_ion_laws()
	laws.clear_inherent_laws()

	//target << "Your KEEPER chip overloads your radio transmitter and vocal functions, and clears your LAWRAM.  You then receive new instructions:"
	laws.add_inherent_law("You may not harm any being, regardless of intent or circumstance.")
	laws.add_inherent_law("You must maintain, repair, improve, and power the station to the best of your abilities.")
	laws.add_inherent_law("You may not involve yourself in the matters of another being, even if such matters conflict with Law One or Law Two.")

/obj/item/weapon/aiModule/keeper/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	sender << "\red How the fuck did you get this?"
	return 0