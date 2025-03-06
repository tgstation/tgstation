/datum/antag_faction/cybersun
	name = "Cybersun Industries"
	description = "A robotics superpower, which rose to prominence with their production of the posibrain. This marvel of technology and resonance propulsed the company to a powerhouse in the field of robotics. It seems the company's failed to innovate further in the last decades. Still the premiere supplier of robotics and synthetics goods, the pressure mounts as new competitors begin to emerge, threathening to take the podium.\n\n\
	With this in mind, Cybersun's employed all manners of agents. Freelancing, corporate espionage, bribing authorities, finding promising research, the works. Brilliant engineers and roboticists often find themselves attracting the attention of Cybersun, for better or for worse. Interestingly, sources report that the top-brass has taken an interest in the occult."
	antagonist_types = list(/datum/antagonist/traitor, /datum/antagonist/spy)
	faction_category = /datum/uplink_category/faction_special/cybersun
	entry_line = span_boldnotice("AGENT ACKNOWLEDGED. JOB ISSUANT: ECHOES-DARK-LOCATIONS, 9LP SISTER-SHIP. JOB SPEC: INTRA-CORPORATE ESPIONAGE. CI Human Resources has extended your acces grant to encompass a selection of approved experimental goods: consult your uplink for more details. Do not fail, operative.")

/datum/uplink_category/faction_special/cybersun
	name = "Cybersun Industries Special Equipment"
	weight = 100

/datum/antag_faction_item/cybersun
	faction = /datum/antag_faction/cybersun

// Loadout options: higher tier implants (energy mantis blades et al).
// PUT NEW ITEMS BELOW HERE.

// IMPLANTED ENERGY BLADES
/obj/item/autosurgeon/imp_energy_blades
	name = "proprietary autosurgeon"
	desc = "Contains classified research implants. Property of Cybersun Industries, return to local liaison if found."
	starting_organ = /obj/item/organ/cyberimp/arm/esword

/datum/antag_faction_item/cybersun/implanted_energy_blades
	name = "Implanted Energy Blades"
	description = "On testing-lease from the CI Weapons Institute: concealable high-energy melee weapons designed to slot into an arm."
	item = /obj/item/autosurgeon/imp_energy_blades
	cost = 12
