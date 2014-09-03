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