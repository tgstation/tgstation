//hello! .dm that just modularly renames items from nanotrasen to port authority/regional administration/etc,.
//nonmodular edits are ideally marked with //NONMODULAR DOPPLER EDIT START and //NONMODULAR DOPPLER EDIT END respectively
//spessman be vigilant. we loved you.


//datums,first off


/datum/pod_style
	desc = "A Port Authority supply drop pod."

/datum/pod_style/advanced
	name = "bluespace supply pod"
	desc = "A Port Authority Bluespace supply pod. Teleports back to Regional Administration after delivery."

/datum/pod_style/centcom
	name = "\improper Regional Administration supply pod"
	desc = "A Port Authority supply pod, this one has been marked with Regional Administration's designations. Teleports back to Regional Admin after delivery."

/datum/pod_style/deathsquad
	name = "\improper Deathsquad drop pod"
	desc = "A Special Circumstances drop pod. This one has been marked the markings of an elite strike team."

/datum/pod_style/cultist
	name = "bloody supply pod"
	desc = "A Port Authority supply pod covered in scratch-marks, blood, and strange runes."


/datum/map_template/shuttle/emergency/asteroid
	name = "Asteroid Station Emergency Shuttle"
	description = "A respectable mid-sized shuttle that first saw service shuttling crew to and from their asteroid belt embedded facilities over a hundred years ago. Has only been updated to add cup-holders since."

/datum/map_template/shuttle/emergency/wawa
	description = "Due to a recent clerical error in the funding department, a lot of funding went to lizard plushies. Due to the costs, the Port Authority has supplied a nearby garbage truck as a stand-in. Better learn how to share spots."

/datum/map_template/shuttle/emergency/goon
	name = "4CA Emergency Shuttle"
	description = "A design used as the universal standard in Fourth Celestial Alignment facilities. Has more seats, but fewer onboard shuttle facilities."

/datum/map_template/shuttle/emergency/lance
	name = "The Lance Crew Evacuation System"
	description = "A shuttle of military origin during the war that formed the 4CA. It's designed to tactically slam into a destroyed station, dispatching threats and saving crew at the same time! Be careful to stay out of its path."

/datum/station_trait/birthday
	name = "Employee Birthday"
	report_message = "We here at Region Admin would all like to wish Employee Name a very happy birthday"

/datum/computer_file/program/budgetorders
	filedesc = "PA IRN"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Port Authority Internal Requisition Network interface for supply purchasing using a department budget account."

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	description = "Watered-down rum, scallywag approved!"

/obj/machinery/icecream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your 4CA-approved ice cream! Has helpful nutritional detail stickers. Shockingly: contains sugar and dairy!"

/obj/item/flashlight/flare
	name = "flare"
	desc = "A red flare. There are instructions on the side: 'pull cord, make light'. This is repeated in roughly ten languages, and there are helpful pictures to go with it."

//antag stuff

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/icemoon
	name = "Icemoon Echoes-Dark-Locations Agent"
	prompt_name = "Echoes-Dark-Locations crewman"
	you_are_text = "You are an EDL crewman, assigned in an underground secret listening post close to your rival-sister-ship's facility."
	flavour_text = "9LP has unjustly supplanted your crew as the 'flagship' Port Authority crew for this region. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw the Promenade crew off your trail and disrupt their productivity."
	important_text = "Do NOT let the Promenade sieze the outpost and recover evidence of our tampering for Port Authority inspection; A small scuttling charge has been provided."

//OBJECTS


/obj/item/paper/paperslip/corporate/fluff/spare_id_safe_code
	name = "Port Authority-Approved Spare ID Safe Code"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a backpack made exclusively for acting officers. Breathe in; smell nepotism and grinding yourself down for cash as a glorified middle-manager. You earned this."

/obj/item/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "It's a satchel made exclusively for acting officers. Breathe in; smell nepotism and grinding yourself down for for cash as a glorified middle-manager. You earned this."

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A common-design storage system designed for any kind of mineral sheet."

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of rolling papers. It's cheaper than buying whole, you know. Ignore the tobacco under your nails."

/obj/item/storage/box/syndie_kit/poster_box
	name = "syndicate poster pack"
	desc = "Contains a variety of demotivational posters to ensure minimum productivity for the crew of any Port Authority station."

/obj/item/storage/box/sparklers
	name = "box of sparklers"
	desc = "A box of sparklers, burns hot even in the cold of space-winter. Often used for celebration on the Day of Armistice, when the civil war of the 2CA was finally put to an end."

/obj/item/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Port Authority symbol on it, and was woven with a revolutionary new kind of thread special-guaranteed t- hahaha, just kidding. It does have an extra layer of insulation, though. Ain't that nice?"

/obj/item/bedsheet/rev
	name = "revolutionary's bedsheet"
	desc = "A bedsheet stolen from a Regional Admin official's bedroom, used a symbol of triumph against the Fourth Celestial's tyranny. The golden emblem on the front has been scribbled out."

/obj/item/bedsheet/nanotrasen
	name = "\improper Port Authority bedsheet"
	desc = "It has the Port Authority logo on it and has an aura of duty."

/obj/machinery/deployable_turret/hmg
	name = "heavy machine gun turret"
	desc = "A heavy caliber machine gun commonly used by mercenaries, soldiers of fortune, freedom fighters, and terrorists, famed for its ability to give people on the receiving end more holes than normal."

/obj/structure/showcase/mecha/marauder
	name = "combat mech exhibit"
	desc = "A stand with an empty old Marauder combat-mech, mass-produced by the Port Authority, and used by the Ministry of Peace to ensure Compliance. Infamous for its usage as riot-control and corpo-sec. Pinnacle of violence; you are meant to think this is Cool and Awesome and Good."

/obj/structure/showcase/machinery/microwave
	name = "\improper Port Authority-brand microwave"
	desc = "The famous Port Authority-brand microwave, the multi-purpose cooking appliance every station needs! This one appears to be drawn onto a cardboard box."

/obj/structure/showcase/machinery/microwave_engineering
	name = "\improper Port Authority Wave(tm) microwave"
	desc = "For those who thought the Port Authority couldn't improve on their famous microwave, this model features Wave™! A Port Authority exclusive, Wave™ allows your PDA to be charged wirelessly through microwave frequencies. Because nothing says 'future' like charging your PDA while overcooking your leftovers. Authority Wave™ - Multitasking, redefined. This product was pulled from shelves after multiple station-wide fires."

/obj/structure/showcase/perfect_employee
	name = "'Perfect Man' employee exhibit"
	desc = "A stand with a model of the perfect Port Authority Employee bolted to it. Signs indicate it is robustly genetically engineered, as well as being ruthlessly loyal."

/obj/structure/showcase/machinery/tv
	name = "\improper Port Authority corporate newsfeed"
	desc = "A slightly battered looking TV. Various Port Authority programs like shipping information, infomercials, and documentaries play on a loop."

/obj/machinery/shower
	name = "shower"
	desc = "The HS-452. Installation is required by the 4CA Ministry of Health. Passively replenishes itself with water when not in use."

/obj/item/gun/ballistic/automatic/proto
	name = "\improper 4CA Saber SMG"
	desc = "A prototype full-auto 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."

/obj/item/gun/ballistic/automatic/wt550
	name = "\improper WT-550 Autorifle"
	desc = "An old but true gun, the striking image of the turbulent times following the dissolution and civil war following the dissolution of the Third Celestial Accord. \
		Real-life image of an agonizing time-frame, stopped in motion, where these top-loaders were used in the brutal fighting that followed. Now, these are mostly used by pirates, underfunded corpo-sec, and gangs  Light-weight and fully automatic. Uses 4.6x30mm rounds."

/obj/item/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rifle used by Nanotrasen fighting forces."

/obj/item/gun/energy/laser/retro/old
	name = "rugged laser gun"
	desc = "An old, but reliable laser-gun pattern that's old enough to drink. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. Can probably drop it in a vat of acid and it'll keep working."

/mob/living/basic/mining_drone
	name = "\improper Port Authority minebot"
	desc = "An old, but rugged design, based off of open-source software. Reassuring. The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."

/obj/item/clothing/under/rank/security/officer
	name = "security uniform"
	desc = "A tactical security jumpsuit for officers complete with Port Authority belt buckle. Uniforms like this are standard for most corporate security."

/obj/item/clothing/under/rank/security/officer/grey
	name = "grey security jumpsuit"
	desc = "A Port Authority security jumpsuit, but in grey. Uniforms like this are standard for most corporate security."

/obj/item/clothing/under/rank/security/warden
	name = "security suit"
	desc = "A suit for on-duty Port Authority Wardens, complete with Port Authority belt buckle."
	icon_state = "rwarden"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/rank/security/warden/grey
	name = "grey security suit"
	desc = "A suit for on-duty Port Authority Wardens, but in grey. Uniforms like this are standard for most corporate security."

/obj/item/clothing/under/rank/prisoner
	desc = "Standardised 4CA prisoner-wear. Has an ID tag at the back. Its suit sensors are stuck in the \"Fully On\" position."

/obj/item/clothing/under/rank/prisoner/nosensor
	desc = "Standardised 4CA prisoner-wear. Has an ID tag at the back.Its suit sensors are stuck in the \"OFF\" position."

/obj/item/clothing/under/rank/prisoner/skirt
	name = "prison jumpskirt"
	desc = "Standardised 4CA prisoner-wear. Has an ID tag at the back. Its suit sensors are stuck in the \"Fully On\" position."

/obj/item/clothing/accessory/pride
	name = "pride pin"
	desc = "A holographic pin to show off your pride. Futuristic!"

/obj/item/skeleton_key
	name = "skeleton key"
	desc = "An artifact usually found in the hands of the natives of the planet below, which the 4CA is benevolently advancing!"

// MOBS

/mob/living/basic/carp/pet/lia
	name = "Lia"
	real_name = "Lia"
	desc = "A failed experiment of the 4CA Void Corps to create weaponised carp technology. This less than intimidating carp now serves as the Head of Security's pet."

/mob/living/basic/spider/maintenance
	name = "duct spider"
	desc = "Near-universal pests; poor biosecurity and nonexistent invasive species prevention on the 4CA's part has led to these pests infesting nearly every modern ship and station."
