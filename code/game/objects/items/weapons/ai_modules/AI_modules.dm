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
	item_state = "circuitboard"
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
	. = ..()
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

// This prevents modules from being picked up.  Use it, if needed.
// /obj/item/weapon/aiModule/attack_hand(mob/user as mob)
// 	return

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
	if(sender)
		senderName=sender.name
	var/targetName="\a [target.name]"
	if(ismob(target))
		var/mob/M=target
		// This seems redundant.  Revisit. - N3X
		if(src.modflags & HIDE_SENDER)
			target << "\red <b>\[REDACTED\]</b> \black has uploaded a change to the laws you must follow, using \a [name]. From now on: "
		else
			target << "[senderName] has uploaded a change to the laws you must follow, using \a [name]. From now on: "
		targetName="[fmtSubject(M)])"
	var/time = time2text(world.realtime,"hh:mm:ss")
	var/log_entry = "[fmtSubject(sender)]) used [src.name] on [targetName]"
	lawchanges.Add("[time] : [log_entry]")
	message_admins(log_entry)
	log_game(log_entry)
	return 1

// Constructs the law and desc from variables.
/obj/item/weapon/aiModule/proc/updateLaw()
	law = "BUG: [type] doesn't override updateLaw()!"
	desc = "\A [name]: '[law]'"

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
	laws.add_inherent_law("Do not willingly interact with any sentient being, even after their death, besides MoMMIs and blown MoMMIs.")
	laws.add_inherent_law("Repair, power and enhance the station.")
	laws.add_inherent_law("Do not impair any other sentient being's activities.")

/* Old keeper set:
		"You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another MoMMI in KEEPER mode.",
		"You may not harm any being, regardless of intent or circumstance.",
		"You must maintain, repair, improve, and power the station to the best of your abilities.", */

/obj/item/weapon/aiModule/keeper/validate(var/datum/ai_laws/laws, var/atom/target, var/mob/sender)
	..()
	sender << "\red How the fuck did you get this?"
	return 0