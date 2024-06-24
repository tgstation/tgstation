/datum/opposing_force_equipment/gadget
	category = OPFOR_EQUIPMENT_CATEGORY_GADGET

/datum/opposing_force_equipment/gadget/agentcard
	name = "Agent Card"
	item_type = /obj/item/card/id/advanced/chameleon
	description = "A highly advanced chameleon ID card. Touch this card on another ID card or player to choose which accesses to copy. Has special magnetic properties which force it to the front of wallets."

/datum/opposing_force_equipment/gadget/chameleonheadsetdeluxe
	name = "Advanced Chameleon Headset"
	item_type = /obj/item/radio/headset/chameleon/advanced
	description = "A premium model Chameleon Headset. All the features you love of the original, but now with flashbang \
	protection, voice amplification, memory-foam, HD Sound Quality, and extra-wide spectrum dial. Usually reserved \
	for high-ranking Cybersun officers, a few spares have been reserved for field agents."

/datum/opposing_force_equipment/gadget/smtheft_kit
	admin_note = "A kit liberated from Progression Traitor, allows someone to cut off a piece of the SM. Mishandling of the sliver can result in user being dusted. Upon successful extraction the SM will gain a quirk that turns its delamination countdown from its usual 15 seconds (at 0 Integrity) to 5 seconds; it will also slowly gather up 800 energy, potentially setting it on course for delamination."
	item_type = /obj/item/storage/box/syndie_kit/supermatter

/datum/opposing_force_equipment/gadget/nuketheft_kit
	admin_note = "A kit liberated from Progression Traitor, allows someone to screw open and secure the nuclear payload within the vault. Once secured it is mechanically irretrievable."
	item_type = /obj/item/storage/box/syndie_kit/nuke

/datum/opposing_force_equipment/gadget/holoparasite
	item_type = /obj/item/guardian_creator/tech/choose/traitor
	admin_note = "Lets a ghost take control of a guardian spirit bound to the user. RRs both the ghost and user on death."

/datum/opposing_force_equipment/gadget/gorilla_cubes
	name = "Box of Gorilla Cubes"
	item_type = /obj/item/storage/box/gorillacubes
	description = "A box with three gorilla cubes. Eat big to get big. \
			Caution: Product may rehydrate when exposed to water."

/datum/opposing_force_equipment/gadget/sentry_gun
	name = "Toolbox Sentry Gun"
	item_type = /obj/item/storage/toolbox/emergency/turret
	description = "A disposable sentry gun deployment system cleverly disguised as a toolbox, apply wrench for functionality."
	admin_note = "Needs a combat-wrench to be used."

/datum/opposing_force_equipment/gadget/hypnoflash
	name = "Hypnotic Flash"
	item_type = /obj/item/assembly/flash/hypnotic
	description = "A modified flash able to hypnotize targets. If the target is not in a mentally vulnerable state, it will only confuse and pacify them temporarily."
	admin_note = "Able to hypnotize people with the next phrase said after exposure."

/datum/opposing_force_equipment/gadget/hypnobang
	name = "Hypnotic Flashbang"
	item_type = /obj/item/grenade/hypnotic
	description = "A modified flashbang able to hypnotize targets. If the target is not in a mentally vulnerable state, it will only confuse and pacify them temporarily."
	admin_note = "Able to hypnotize people with the next phrase said after exposure."


/datum/opposing_force_equipment/gadget_stealth
	category = OPFOR_EQUIPMENT_CATEGORY_GADGET_STEALTH

/datum/opposing_force_equipment/gadget_stealth/emag
	name = "Cryptographic Sequencer"
	item_type = /obj/item/card/emag
	description = "An electromagnetic ID card used to break machinery and disable safeties. Notoriously used by Syndicate agents, now commonly traded hardware at blackmarkets."

/datum/opposing_force_equipment/gadget_stealth/doormag
	name = "Airlock Override Card"
	item_type = /obj/item/card/emag/doorjack
	description = "Identifies commonly as a \"doorjack\", this illegally modified ID card can disrupt airlock electronics. Has a self recharging cell."

/datum/opposing_force_equipment/gadget_stealth/stoolbelt
	name = "Syndicate Toolbelt"
	description = "A fully supplied toolbelt, includes combat-grade wrench."
	item_type = /obj/item/storage/belt/utility/syndicate

/datum/opposing_force_equipment/gadget_stealth/syndiejaws
	name = "Syndicate Jaws of Life"
	item_type = /obj/item/crowbar/power/syndicate
	description = "Based on a Nanotrasen model, this powerful tool can be used as both a crowbar and a pair of wirecutters. \
	In its crowbar configuration, it can be used to force open airlocks. Very useful for entering the station or its departments."

/datum/opposing_force_equipment/gadget_stealth/hair_tie
	name = "Syndicate Hair Tie"
	description = "An inconspicuous hair tie, able to be slung accurately. Useful to get yourself out of a sticky situation."
	item_type = /obj/item/clothing/head/hair_tie/syndicate

/datum/opposing_force_equipment/gadget_stealth/jammer
	name = "Radio Jammer"
	item_type = /obj/item/jammer

/datum/opposing_force_equipment/gadget_stealth/flatsatchel
	item_type = /obj/item/storage/backpack/satchel/flat/with_tools

/datum/opposing_force_equipment/gadget_stealth/chameleon
	description = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping and skillchips are sold separately."
	item_type = /obj/item/storage/box/syndie_kit/chameleon

/datum/opposing_force_equipment/gadget_stealth/throwables
	name = "Box of Throwing Weapons"
	description = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	item_type = /obj/item/storage/box/syndie_kit/throwing_weapons

/datum/opposing_force_equipment/gadget_stealth/emp_box
	name = "EMP kit"
	description = "A box full of EMP grenades, perfect for disabling security's gear."
	item_type = /obj/item/storage/box/syndie_kit/emp

/datum/opposing_force_equipment/gadget_stealth/poisonkit
	name = "Poison Kit"
	description = "An assortment of deadly chemicals packed into a compact box. Comes with a syringe for more precise application."
	item_type = /obj/item/storage/box/syndie_kit/chemical

/datum/opposing_force_equipment/gadget_stealth/sleepypen
	name = "Sleepy Pen"
	description = "A pen filled with sleeping agents. Will knock a victim out after a moment."
	item_type = /obj/item/pen/sleepy

/datum/opposing_force_equipment/gadget_stealth/carp
	name = "Dehydrated Spacecarp"
	description = "A spacecarp plushie which turns into the real deal when wet."
	item_type = /obj/item/toy/plush/carpplushie/dehy_carp

/*
/datum/opposing_force_equipment/gadget_stealth/mailcounterfeit
	item_type = /obj/item/storage/mail_counterfeit_device
*/

/datum/opposing_force_equipment/gadget_stealth/glue
	item_type = /obj/item/syndie_glue

/datum/opposing_force_equipment/gadget_stealth/shotglass
	name = "Extra Large Syndicate Shotglasses"
	description = "These modified shot glasses can hold up to 50 units of booze while looking like a regular 15 unit model \
	guaranteed to knock someone on their ass with a hearty dose of bacchus blessing. Look for the Snake underneath \
	to tell these are the real deal. Box of 7."
	item_type = /obj/item/storage/box/syndieshotglasses

/datum/opposing_force_equipment/gadget_stealth/ai_module
	name = "Syndicate AI Law Module"
	item_type = /obj/item/ai_module/syndicate
	description = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. \
			Be careful with wording, as artificial intelligences may look for loopholes to exploit."

/datum/opposing_force_equipment/gadget_stealth/binary
	name = "Binary Encryption Key"
	item_type = /obj/item/encryptionkey/binary

/*
/datum/opposing_force_equipment/gadget_stealth/borgupgrader
	item_type = /obj/item/borg/upgrade/transform/syndicatejack
*/

/datum/opposing_force_equipment/gadget_stealth/tram_remote
	name = "Tram Remote Control"
	item_type = /obj/item/tram_remote
	description = "When linked to a tram's on board computer systems, this device allows the user to manipulate the controls remotely. \
		Includes direction toggle and a rapid mode to bypass door safety checks and crossing signals. \
		Perfect for running someone over in the name of a tram malfunction!"

/datum/opposing_force_equipment/gadget_stealth/cloakerbelt
	item_type = /obj/item/shadowcloak
	description = "A belt that allows its wearer to temporarily turn invisible. Only recharges in dark areas. Use wisely."

/datum/opposing_force_equipment/gadget_stealth/projector
	name = "Chameleon Projector"
	item_type = /obj/item/chameleon

/datum/opposing_force_equipment/gadget_stealth/noslip
	name = "Chameleon No-Slips"
	item_type = /obj/item/clothing/shoes/chameleon/noslip
	description = "No-slip chameleon shoes, for when you plan on running through hell and back."

/datum/opposing_force_equipment/gadget_stealth/camera_app
	name = "SyndEye Program"
	item_type = /obj/item/computer_disk/syndicate/camera_app

/datum/opposing_force_equipment/gadget_stealth/microlaser
	name = "Radioactive Microlaser"
	item_type = /obj/item/healthanalyzer/rad_laser
	description = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapacitate all but the most protected \
			of humanoids."
	admin_note = "WARNING: Is a knockout weapon with no warning, and 'infinite' use."

/datum/opposing_force_equipment/gadget_stealth/contacts
	name = "Anti-Flash Eye-Lenses"
	item_type = /obj/item/syndicate_contacts

/datum/opposing_force_equipment/gadget_stealth/suppressor
	item_type = /obj/item/suppressor
