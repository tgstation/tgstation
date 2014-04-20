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