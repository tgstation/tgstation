/datum/job/roguetown/heartfelt
	abstract_type = /datum/job/roguetown/heartfelt

/datum/job/roguetown/absolver
	title = JOB_ROCKHILL_ABSOLVER
	description = "Once, you were alone in this monastery; a chapel of stone, protecting a shard of Psydon's divinity. Now, you've a whole sect to shepherd - and their propensity for violence oft-clashes with your own vows of pacifism. Temper the floch with your wisdom, siphon away their wounds with your blessings, and guide the wayard towards absolution."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_ABSOLVER"
	outfit = /datum/outfit/job/roguetown/absolver
	departments_list = list(
		/datum/job_department/rockhill_inquisition,
		)
	rockhill_advclass = "/datum/advclass/absolver"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/absolver
	rockhill_traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_PACIFISM,
		TRAIT_LUX_FREAK,
		TRAIT_EMPATH,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_SILVER_BLESSED,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		TRAIT_RITUALIST,
		TRAIT_SELF_AWARE,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_social_rank = 3

/datum/job/roguetown/adventurer
	title = JOB_ROCKHILL_ADVENTURER
	description = "Hero of nothing, a wanderer in foreign lands in search of fame and riches. Whatever led you to this fate is up to the wind to decide, and you've never fancied yourself for much other than the thrill. Some day your pride is going to catch up to you, and you're going to find out why most men don't end up in the annals of history."
	total_positions = 20
	spawn_positions = 20
	config_tag = "ROCKHILL_ADVENTURER"
	outfit = /datum/outfit/job/roguetown/adventurer
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/cleric"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/cleric,
		/datum/rockhill_advclass/cleric/paladin,
		/datum/rockhill_advclass/cleric/cantor,
		/datum/rockhill_advclass/cleric/missionary,
		/datum/rockhill_advclass/cleric/stigmata,
		/datum/rockhill_advclass/sfighter,
		/datum/rockhill_advclass/sfighter/duelist,
		/datum/rockhill_advclass/sfighter/mhunter,
		/datum/rockhill_advclass/sfighter/barbarian,
		/datum/rockhill_advclass/sfighter/ironclad,
		/datum/rockhill_advclass/rogue,
		/datum/rockhill_advclass/rogue/thief,
		/datum/rockhill_advclass/rogue/bard,
		/datum/rockhill_advclass/rogue/swashbuckler,
		/datum/rockhill_advclass/mage,
		/datum/rockhill_advclass/mage/spellblade,
		/datum/rockhill_advclass/mage/spellsinger,
		/datum/rockhill_advclass/ranger,
		/datum/rockhill_advclass/ranger/wayfarer,
		/datum/rockhill_advclass/ranger/bombadier,
		/datum/rockhill_advclass/ranger/bwanderer,
		/datum/rockhill_advclass/noble,
		/datum/rockhill_advclass/noble/knighte,
		/datum/rockhill_advclass/noble/squire,
		/datum/rockhill_advclass/foreigner,
		/datum/rockhill_advclass/foreigner/yoruku,
		/datum/rockhill_advclass/foreigner/repentant,
		/datum/rockhill_advclass/foreigner/refugee,
		/datum/rockhill_advclass/foreigner/slaver,
		/datum/rockhill_advclass/foreigner/dunewell,
		/datum/rockhill_advclass/foreigner/gronn,
		/datum/rockhill_advclass/foreigner/nostromo,
		/datum/rockhill_advclass/foreigner/aavnik,
		/datum/rockhill_advclass/foreigner/bluthund,
		/datum/rockhill_advclass/foreigner/underdweller,
		/datum/rockhill_advclass/foreigner/drow,
		/datum/rockhill_advclass/foreigner/shepherd,
		/datum/rockhill_advclass/foreigner/fencerguy,
		/datum/rockhill_advclass/foreigner/bronzeclad,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/adventurer
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_OUTLANDER,
		)
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/datum/job/roguetown/adventurer/courtagent
	title = JOB_ROCKHILL_COURT_AGENT
	description = "Whether acquired by merit, shrewd negotiation or fulfilled bounties, you have found yourself under the underhanded employ of the Hand. Fulfill desires and whims of the court that they would rather not be publicly known. Your position is anything but secure, and any mistake can leave you disowned and charged like the petty criminal are. Garrison and Court members know who you are."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_ADVENTURER_COURTAGENT"
	outfit = /datum/outfit/job/roguetown/adventurer/courtagent
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/cleric"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/cleric,
		/datum/rockhill_advclass/cleric/paladin,
		/datum/rockhill_advclass/cleric/cantor,
		/datum/rockhill_advclass/cleric/missionary,
		/datum/rockhill_advclass/cleric/stigmata,
		/datum/rockhill_advclass/sfighter,
		/datum/rockhill_advclass/sfighter/duelist,
		/datum/rockhill_advclass/sfighter/mhunter,
		/datum/rockhill_advclass/sfighter/barbarian,
		/datum/rockhill_advclass/sfighter/ironclad,
		/datum/rockhill_advclass/rogue,
		/datum/rockhill_advclass/rogue/thief,
		/datum/rockhill_advclass/rogue/bard,
		/datum/rockhill_advclass/rogue/swashbuckler,
		/datum/rockhill_advclass/mage,
		/datum/rockhill_advclass/mage/spellblade,
		/datum/rockhill_advclass/mage/spellsinger,
		/datum/rockhill_advclass/ranger,
		/datum/rockhill_advclass/ranger/wayfarer,
		/datum/rockhill_advclass/ranger/bombadier,
		/datum/rockhill_advclass/ranger/bwanderer,
		/datum/rockhill_advclass/noble,
		/datum/rockhill_advclass/noble/knighte,
		/datum/rockhill_advclass/noble/squire,
		/datum/rockhill_advclass/foreigner,
		/datum/rockhill_advclass/foreigner/yoruku,
		/datum/rockhill_advclass/foreigner/repentant,
		/datum/rockhill_advclass/foreigner/refugee,
		/datum/rockhill_advclass/foreigner/slaver,
		/datum/rockhill_advclass/foreigner/dunewell,
		/datum/rockhill_advclass/foreigner/gronn,
		/datum/rockhill_advclass/foreigner/nostromo,
		/datum/rockhill_advclass/foreigner/aavnik,
		/datum/rockhill_advclass/foreigner/bluthund,
		/datum/rockhill_advclass/foreigner/underdweller,
		/datum/rockhill_advclass/foreigner/drow,
		/datum/rockhill_advclass/foreigner/shepherd,
		/datum/rockhill_advclass/foreigner/fencerguy,
		/datum/rockhill_advclass/foreigner/bronzeclad,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/adventurer/courtagent
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_OUTLANDER,
		)
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/datum/job/roguetown/adventurer/courtslave
	title = JOB_ROCKHILL_ENSLAVED_ADVENTURER
	description = "Woe has befallen thee - whether by falling on the wrong side of the law or needing to pay off a debt, you have found yourself under the underhanded employ of the Slavemaster. Fulfill desires and whims of the court that they would rather not be publicly known. Your position is anything but secure, and any mistake can leave you bound, flogged or worse. Garrison and Court members know who you are."
	total_positions = 3
	spawn_positions = 3
	config_tag = "ROCKHILL_ADVENTURER_COURTSLAVE"
	outfit = /datum/outfit/job/roguetown/adventurer/courtslave
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/cleric"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/cleric,
		/datum/rockhill_advclass/cleric/paladin,
		/datum/rockhill_advclass/cleric/cantor,
		/datum/rockhill_advclass/cleric/missionary,
		/datum/rockhill_advclass/cleric/stigmata,
		/datum/rockhill_advclass/sfighter,
		/datum/rockhill_advclass/sfighter/duelist,
		/datum/rockhill_advclass/sfighter/mhunter,
		/datum/rockhill_advclass/sfighter/barbarian,
		/datum/rockhill_advclass/sfighter/ironclad,
		/datum/rockhill_advclass/rogue,
		/datum/rockhill_advclass/rogue/thief,
		/datum/rockhill_advclass/rogue/bard,
		/datum/rockhill_advclass/rogue/swashbuckler,
		/datum/rockhill_advclass/mage,
		/datum/rockhill_advclass/mage/spellblade,
		/datum/rockhill_advclass/mage/spellsinger,
		/datum/rockhill_advclass/ranger,
		/datum/rockhill_advclass/ranger/wayfarer,
		/datum/rockhill_advclass/ranger/bombadier,
		/datum/rockhill_advclass/ranger/bwanderer,
		/datum/rockhill_advclass/noble,
		/datum/rockhill_advclass/noble/knighte,
		/datum/rockhill_advclass/noble/squire,
		/datum/rockhill_advclass/foreigner,
		/datum/rockhill_advclass/foreigner/yoruku,
		/datum/rockhill_advclass/foreigner/repentant,
		/datum/rockhill_advclass/foreigner/refugee,
		/datum/rockhill_advclass/foreigner/slaver,
		/datum/rockhill_advclass/foreigner/dunewell,
		/datum/rockhill_advclass/foreigner/gronn,
		/datum/rockhill_advclass/foreigner/nostromo,
		/datum/rockhill_advclass/foreigner/aavnik,
		/datum/rockhill_advclass/foreigner/bluthund,
		/datum/rockhill_advclass/foreigner/underdweller,
		/datum/rockhill_advclass/foreigner/drow,
		/datum/rockhill_advclass/foreigner/shepherd,
		/datum/rockhill_advclass/foreigner/fencerguy,
		/datum/rockhill_advclass/foreigner/bronzeclad,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/adventurer/courtslave
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_OUTLANDER,
		)
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/datum/job/roguetown/apothecary
	title = JOB_ROCKHILL_APOTHECARY
	description = "You are an accomplished physician, trained and practiced in the art of medicine. You answer to the Head Physician, who enables your practice. Woe betide the one who suffers your scalpel."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_APOTHECARY"
	outfit = /datum/outfit/job/roguetown/apothecary
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/apothecary"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/apothecary
	rockhill_traits = list(
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NOSTINK,
		TRAIT_EMPATH,
		)
	rogue_social_rank = 3

/datum/job/roguetown/archivist
	title = JOB_ROCKHILL_ARCHIVIST
	description = "The Archivist meticulously preserves and organizes ancient scrolls and tomes, safeguarding the collective knowledge of the realm for generations to come. Nobles and Peasants alike often seek your expertise on matters of history and fact, and your keenly-kept records on the events of this week will likely stand a testament to your Duke's benevolence and their realm's prosperity...or not. After all, you hold the true power: The power to dictate how the future generations will look back on these coming days."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_ARCHIVIST"
	outfit = /datum/outfit/job/roguetown/archivist
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/archivist"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/archivist
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_GOODWRITER,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_SMITHING_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 3

/datum/job/roguetown/barkeep
	title = JOB_ROCKHILL_INNKEEPER
	description = "Adventurers and warriors alike have two exit plans; the early grave or even earlier retirement. As the proud owner of this fine establishment, you took the latter: The local tavern, inn, and bathhouse! You even have an assortment of staff to help you, and plenty of business from the famished townsfolk looking to eat, weary travelers looking to rest, and characters of dubious repute seeking their own sort of success. Your bladework has gotten a little rusty, and the church across the street gives you the odd evil eye for the extra 'delights' of the bathhouse--but, well...you can't win 'em all!"
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_BARKEEP"
	outfit = /datum/outfit/job/roguetown/barkeep
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/barkeep"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/barkeep
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_TAVERN_FIGHTER,
		TRAIT_EMPATH,
		TRAIT_DODGEEXPERT,
		TRAIT_CICERONE,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 3

/datum/job/roguetown/baron
	title = JOB_ROCKHILL_BARON
	description = "Through birthright, favors or intrigue you have landed yourself in the position of being the baron of the outer reaches of the duchy. You swore fealty to the duke and are given significant independence to run lowtown as you see fit, you hold sway in its dealings and in absence of higher authority the local garrison will answer to you. You hold command over the lowtown garrison, although upon request the crown can call upon your men to join their greater army."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_BARON"
	outfit = /datum/outfit/job/roguetown/baron
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/baron/shrewd_nobleman"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/baron/shrewd_nobleman,
		/datum/rockhill_advclass/baron/landed_knight,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/baron
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		)
	alternate_titles = list(
		"Baroness",
		)
	rogue_social_rank = 5
	rogue_f_title = "Baroness"

/datum/job/roguetown/baron_retainer
	title = JOB_ROCKHILL_RETAINER
	description = "You hold the trust and responsibility of being the baron's closest confidant. You are tasked with protecting the baron and advising him on any matter he deems necessary. You enjoy the benefits of living in relative luxury and the status that comes with your position, although the higher nobility of the keep look down on you as a minor functionary."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_BARON_RETAINER"
	outfit = /datum/outfit/job/roguetown/baron_retainer
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/baron_retainer/henchman"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/baron_retainer/henchman,
		/datum/rockhill_advclass/baron_retainer/duelist,
		/datum/rockhill_advclass/baron_retainer/greyleaf,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/baron_retainer
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_social_rank = 3

/datum/job/roguetown/butler
	title = JOB_ROCKHILL_SENESCHAL
	description = "Servitude unto death; that is your motto. You are the manor's major-domo, commanding over the house servants and seeing to the administrative affairs, day to day of the estate. This role has style options for chief butlers and head maids."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_BUTLER"
	outfit = /datum/outfit/job/roguetown/seneschal
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/seneschal/seneschal"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/seneschal/seneschal,
		/datum/rockhill_advclass/seneschal/headmaid,
		/datum/rockhill_advclass/seneschal/chiefbutler,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/butler
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		)
	rogue_social_rank = 3

/datum/job/roguetown/captain
	title = JOB_ROCKHILL_KNIGHT_CAPTAIN
	description = "Your lineage is noble, and generations of strong, loyal knights and men-at-arms have come before you. You served your time gracefully as knight of his royal majesty, and now you've grown into a role which many men can only dream of becoming. Veteran among knights, you lead the crown's knights and loyal men at arms into battle and organize the training squires. Obey only the Marshal and Crown. Lead your men to victory--and keep them in line--and you will see this realm prosper under a thousand suns."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_CAPTAIN"
	outfit = /datum/outfit/job/roguetown/captain
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/captain/infantry"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/captain
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_NOBLE,
		TRAIT_GUARDSMAN,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/chaplain
	title = JOB_ROCKHILL_COURT_CHAPLAIN
	description = "The time most acolytes put towards the ways of magic and miracle, you spent studying history and building connections. Liasing between church and court, you are an advisor and diplomat on spiritual matters. Your task is to negotiate, mediate and advise the court against unpious decisions. Some call you a scheming manipulator, a spy on the other church's behalf. Others suspect the Duke may come to prefer your sweet whispers to the Bishop's. Perhaps you are simply drawn to the safety and luxury of court-living."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_CHAPLAIN"
	outfit = /datum/outfit/job/roguetown/chaplain
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/chaplain"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/chaplain
	rockhill_traits = list(
		TRAIT_EMPATH,
		)
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 4

/datum/job/roguetown/churchling
	title = JOB_ROCKHILL_CHURCHLING
	description = "Your family were zealots. They scolded you with a studded belt and prayed like sinners every waking hour of the day they weren't toiling in the fields. You escaped them by becoming a churchling--and a guaranteed education isn't so bad."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_CHURCHLING"
	outfit = /datum/outfit/job/roguetown/churchling
	departments_list = list(
		/datum/job_department/rockhill_youngfolk,
		)
	rockhill_advclass = "/datum/advclass/churchling"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/churchling,
		/datum/rockhill_advclass/churchling/neophyte,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/churchling
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 2
	rogue_advjob_examine = TRUE

/datum/job/roguetown/clerk
	title = JOB_ROCKHILL_CLERK
	description = "Clerk, tax-collector, blessed fool. You help the Steward with anything they need and perform their tasks when they are unavailable. Although you aren't a noble, it's not the worst position. The caveat? If money is misplaced or goes missing, a noble could probably weasel out of the stockades as punishment. You? Eh...well, Etrusca is lovely this time of year."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_CLERK"
	outfit = /datum/outfit/job/roguetown/clerk
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/clerk"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/clerk
	rockhill_traits = list(
		TRAIT_SEEPRICES,
		TRAIT_ROYAL_SUBSIDY,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 3

/datum/job/roguetown/cook
	title = JOB_ROCKHILL_MANOR_COOK
	description = "There are many mouths to feed in town, and most look to you for it. You work under the care of the innkeeper and craft such culinary delights that even the crown stops by from time to time. All the while, you try to get the rest of the staff up to speed as well--before you get too many burn marks on your body from slaving over your hot hearths."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_COOK"
	outfit = /datum/outfit/job/roguetown/cook
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/cook"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/cook
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/job/roguetown/councillor
	title = JOB_ROCKHILL_COUNCILLOR
	description = "You may have inherited this position, bought your way into it, or were appointed to it by merit--perish the thought! Whatever the case though, you work as an assistant and agent of the crown in matters of state. Whether this be aiding the steward, the sheriff, or the crown itself, or simply enjoying the free food of the keep, your duties vary day by day. You may be the lowest rung of the ladder, but that rung still towers over everyone else in town."
	total_positions = 3
	spawn_positions = 3
	config_tag = "ROCKHILL_COUNCILLOR"
	outfit = /datum/outfit/job/roguetown/councillor
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/councillor"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/councillor,
		/datum/rockhill_advclass/councillor/huntmaster,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/councillor
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES_SHITTY,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/crier
	title = JOB_ROCKHILL_TOWN_CRIER
	description = "Keeper of the Horn, Master of the Jabberline, and self-appointed Voice of Reason. From your desk in the SCOM atelier, you decide which words will thunder across the realm and which will die in the throats of petitioners who didn't pay enough ratfeed. In your upstairs studio, you host debates, recite gossip, and spin tales that will ripple through every corner of town. All ears are turned toward you - so speak wisely."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_CRIER"
	outfit = /datum/outfit/job/roguetown/loudmouth
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/towncrier"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/crier
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid", "/datum/species/ooze")
	rogue_social_rank = 3

/datum/job/roguetown/druid
	title = JOB_ROCKHILL_DRUID
	description = "You have always been drawn to the wild, and the wild drawn to you. When your calling came, it was from Dendor. Your patron claims dominion over all nature--promising bounties to those who act in his name to bring balance to His domain. The forest is the most comfortable place for you, toiling alongside soilsons and soilbrides...although sometimes what lies beyond the gates fills your soul with a feral yearning."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_DRUID"
	outfit = /datum/outfit/job/roguetown/druid
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/druid"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/druid
	rockhill_traits = list(
		TRAIT_SEEDKNOW,
		TRAIT_OUTDOORSMAN,
		TRAIT_RITUALIST,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_WILDERNESSGUIDE,
		TRAIT_WOODWALKER,
		TRAIT_EXPERT_HUNTER,
		)
	alternate_titles = list(
		"Druidess",
		)
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 3
	rogue_f_title = "Druidess"

/datum/job/roguetown/dungeoneer
	title = JOB_ROCKHILL_DUNGEONEER
	description = "Sometimes at night you stare into the vacant room and feel the loneliness of your existence crawl into whatever remains of your loathsome soul. You will never know hunger, thirst or want for anything with the mammons you make: Just as you'll never forget the sounds a saw makes cutting through the bone, what a drowning man will gurgle out between the blood and teeth strangling his breath. You are the monster that is called when civility has run it's course. Everything owed to the current ruler, serve your master well and answer to no other authority in your pursuits far away from Astrata's light. They shall fear."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_DUNGEONEER"
	outfit = /datum/outfit/job/roguetown/dungeoneer
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	mind_traits = list(
		"dungeonmasterlaborcamp",
		)
	rockhill_advclass = "/datum/advclass/dungeoneer"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/dungeoneer
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DUNGEONMASTER,
		TRAIT_GUARDSMAN,
		TRAIT_DEATHBYSNUSNU,
		TRAIT_PURITAN_ADVENTURER,
		TRAIT_DUNGEONMASTER_LABOR_CAMP,
		)
	rogue_social_rank = 3

/datum/job/roguetown/farmer
	title = JOB_ROCKHILL_SOILSON
	description = "It is a simple life you live, your basic understanding of life is something many would be envious of if they knew just how perfect it was. You know a good day's work, the sweat on your brow is yours: Famines and plague may take their toll, but you know how to celebrate life well. Till the soil and produce fresh food for those around you, and maybe you'll be more than an unsung hero someday."
	total_positions = 3
	spawn_positions = 5
	config_tag = "ROCKHILL_FARMER"
	outfit = /datum/outfit/job/roguetown/farmer
	display_order = 24
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/soilson"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/farmer
	rockhill_traits = list(
		TRAIT_SEEDKNOW,
		TRAIT_NOSTINK,
		TRAIT_LONGSTRIDER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	alternate_titles = list(
		"Soilbride",
		)
	rogue_social_rank = 2
	rogue_f_title = "Soilbride"

/datum/job/roguetown/gapprentice
	title = JOB_ROCKHILL_GUILD_APPRENTICE
	description = "Long hours and back-breaking work wouldnt even describe a quarter of what you do in a day for your Master. Its exhausting, filthy and you dont get much freetime: but someday youll get your own smithy, and youll have TWICE as many apprentices as your master does."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_GAPPRENTICE"
	outfit = /datum/outfit/job/roguetown/gapprentice
	departments_list = list(
		/datum/job_department/rockhill_youngfolk,
		)
	rockhill_advclass = "/datum/advclass/gapprentice"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/gapprentice
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 2

/datum/job/roguetown/guardsman
	title = JOB_ROCKHILL_CITY_GUARD
	description = "Responsible for the safety of the city and the enforcement of the law, you patrol the city streets, on the look out for crime and disorder. Armed with chains and a trusty beating stick, you are charged with catching thieves, vagrants and troublemakers, confiscating illicit goods, and administering swift and orderly justice. Obey your Watch Captain's orders, and enforce the Marshal's laws"
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_GUARDSMAN"
	outfit = /datum/outfit/job/roguetown/guardsman
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/guardsman/cityguard"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/guardsman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)
	rogue_social_rank = 3

/datum/job/roguetown/guildmaster
	title = JOB_ROCKHILL_GUILDMASTER
	description = "You are the leader of the Duchy's Guild of Crafts. You represents the interests of all of the craftsmen underneath you - including the Tailor the Blacksmiths, the Artificers and the Architects. Other townspeople may look to you for guidance, but they are not under your control. You are an experienced smith and artificer, and can do their work easily. Protect the craftsmen's interests."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_GUILDMASTER"
	outfit = /datum/outfit/job/roguetown/guildmaster
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/guildmaster"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/guildmaster
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SEEPRICES,
		TRAIT_SMITHING_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_LEGENDARY_MINER,
		TRAIT_MASTER_CARPENTER,
		TRAIT_MASTER_MASON,
		)
	rogue_social_rank = 3

/datum/job/roguetown/guildsman
	title = JOB_ROCKHILL_GUILDSMAN
	description = "You are a member of the Duchy's Guild of Crafts, a massive guild formed to represent the interests of all craftsmen in the township. As a Guildsman, you hail from the three most important constituent guilds: The Smith's Guild, the Artificer's Guild, and the Architect's Guild. The Guildsmaster has sway over you, but it is not absolute."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_GUILDSMAN"
	outfit = /datum/outfit/job/roguetown/guildsman
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/guildsman/artificer"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/guildsman/artificer,
		/datum/rockhill_advclass/guildsman/blacksmith,
		/datum/rockhill_advclass/guildsman/engineer,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/guildsman
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)
	rogue_social_rank = 3
	rogue_advjob_examine = TRUE

/datum/job/roguetown/hand
	title = JOB_ROCKHILL_HAND
	description = "Whether by outstanding merit or petty favoritism, you are the Archduke's most trusted representative and advisor. Your authority is second only to the Archduke themselves. The weight of your words can shape policy, stir conflict, or silence dissent. Let none forget whose will you carry, and do not fail your benefactor."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_HAND"
	outfit = /datum/outfit/job/roguetown/hand
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/hand/blademaster"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/hand/blademaster,
		/datum/rockhill_advclass/hand/spymaster,
		/datum/rockhill_advclass/hand/advisor,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/hand
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/heartfelt/hand
	title = JOB_ROCKHILL_HAND_OF_HEARTFELT
	description = "You are the Hand of Heartfelt, burdened by the perception of failure in protecting your Lord's domain. Despite doubts from others, your loyalty remains steadfast as you journey to these lands, determined to fulfill your duties."
	total_positions = 1
	spawn_positions = 0
	config_tag = "ROCKHILL_HEARTFELT_HAND"
	outfit = /datum/outfit/job/roguetown/heartfelt/hand
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/heartfelt/hand/marshal"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/hand/marshal,
		/datum/rockhill_advclass/heartfelt/hand/steward,
		/datum/rockhill_advclass/heartfelt/hand/advisor,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/heartfelt/hand
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_HEARTFELT,
		TRAIT_STEELHEARTED,
		)
	rogue_social_rank = 5

/datum/job/roguetown/heartfelt/knight
	title = JOB_ROCKHILL_KNIGHT_OF_HEARTFELT
	description = "You are a Knight of Heartfelt, once part of a brotherhood in service to your Lord. Now, alone and committed to safeguarding what remains of your court, you ride to the Peak, resolved to ensure their safe arrival."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_HEARTFELT_KNIGHT"
	outfit = /datum/outfit/job/roguetown/heartfelt/knight
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/heartfelt/knight"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/heartfelt/knight
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HEARTFELT,
		TRAIT_GOODTRAINER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/heartfelt/lord
	title = JOB_ROCKHILL_LORD_OF_HEARTFELT
	description = "You are the Lord of Heartfelt, ruler of a once-prosperous barony now in ruin. Guided by your Magos, you journey to the Peak, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	total_positions = 1
	spawn_positions = 0
	config_tag = "ROCKHILL_HEARTFELT_LORD"
	outfit = /datum/outfit/job/roguetown/heartfelt/lord
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/heartfelt/lord/lord"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/lord/lord,
		/datum/rockhill_advclass/heartfelt/lord/archmage,
		/datum/rockhill_advclass/heartfelt/lord/chief,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/heartfelt/lord
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_HEARTFELT,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/jester
	title = JOB_ROCKHILL_JESTER
	description = "The Grenzelhofts were known for their Jesters, wisemen with a tongue just as sharp as their wit. You command a position of a fool, envious of the position your superiors have upon you. Your cheap tricks and illusions of intelligence will only work for so long, and someday you'll find yourself at the end of something sharper than you."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_JESTER"
	outfit = /datum/outfit/job/roguetown/jester
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/jester
	rockhill_traits = list(
		TRAIT_ZJUMP,
		TRAIT_NOFALLDAMAGE1,
		TRAIT_LEAPER,
		TRAIT_NUTCRACKER,
		TRAIT_TEMPO,
		)
	rogue_social_rank = 4

/datum/job/roguetown/keeper
	title = JOB_ROCKHILL_KEEPER
	description = "Disfigured, shunned, or simply filled with purpose and dedication for Pestra. Some of you are horrifically mutated, disfigured, or diseased. No matter, even the pretty ones feel the toll as it leaves their strength atrophied. Someone has to harvest the holy blood required to purify lux and perpetuate Pestra's gift of medicine. Unfortunately, that's you. That's correct, I'm the one tasked with protecting the sacred Heart Beast of Pestra here. To study it and empower it so that Pestra's medicine may blossom even in the furthest reaches of Ferentia. Keep in mind you are NOT directly affiliated with the church of the see, the local bishop is not your boss. You answer to the sect of Pestra foremost."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_KEEPER"
	outfit = /datum/outfit/job/roguetown/keeper
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/keeper"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/keeper
	rockhill_traits = list(
		TRAIT_MEDICINE_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_NOSTINK,
		TRAIT_STEELHEARTED,
		TRAIT_RITUALIST,
		TRAIT_NUMBED_LIMBS,
		)
	rogue_allowed_patrons = list(/datum/patron/divine/pestra)

/datum/job/roguetown/knavewench
	title = JOB_ROCKHILL_TAPSTER
	description = "You have a simple role at the city tavern; please. You wait tables and help guests, clean the rooms, grow and brew more drink, and assist in the kitchens as need be. Bring a smile to the masses--and those cheapsake townsfolk and adventures might just give you an extra coin...assuming you've not already pilfered their pouch while they're in a drunken stupor off your latest brew."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_KNAVEWENCH"
	outfit = /datum/outfit/job/roguetown/knavewench
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/tapster"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/knavewench
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/job/roguetown/knight
	title = JOB_ROCKHILL_KNIGHT
	description = "Having proven yourself both loyal and capable, you have been knighted to serve the realm as the royal family's sentry. You listen to your Liege, the Marshal, and the Knight Captain, defending your Lord and realm - the last beacon of chivalry in these dark times. You're wholly dedicated to the standing Regent and their safety. Do not fail."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_KNIGHT"
	outfit = /datum/outfit/job/roguetown/knight
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/knight/heavy"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/knight/heavy,
		/datum/rockhill_advclass/knight/footknight,
		/datum/rockhill_advclass/knight/mountedknight,
		/datum/rockhill_advclass/knight/irregularknight,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/knight
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_GUARDSMAN,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 4

/datum/job/roguetown/lord
	title = JOB_ROCKHILL_GRAND_DUKE
	description = "Elevated upon your throne through a web of intrigue and political upheaval, you are the absolute authority of these lands and at the center of every plot within it. Every man, woman and child is envious of your position and would replace you in less than a heartbeat: Show them the error of their ways. The Crown took a heavy toll upon your lyfe-force, and you will not be able to be revived if you perish."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_LORD"
	outfit = /datum/outfit/job/roguetown/lord
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/lord/warrior"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/lord/warrior,
		/datum/rockhill_advclass/lord/merchant,
		/datum/rockhill_advclass/lord/wizard,
		/datum/rockhill_advclass/lord/inbred,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/lord
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_DNR,
		TRAIT_HEAVYARMOR,
		)
	alternate_titles = list(
		"Grand Duchess",
		"Duke",
		"Duchess",
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 6
	rogue_f_title = "Grand Duchess"

/datum/job/roguetown/lunatic
	title = JOB_ROCKHILL_LUNATIC
	description = "The Lunatic, shunned by society and a magnet for misfortune. Your task is simple yet perilous: survive by any means, though your very existence invites danger from every corner. It is said that these lands drive those most familiar with it, the most insane."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_LUNATIC"
	outfit = /datum/outfit/job/roguetown/lunatic
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/lunatic"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/lunatic
	rockhill_traits = list(
		TRAIT_JESTERPHOBIA,
		)
	rogue_social_rank = 2

/datum/job/roguetown/magician
	title = JOB_ROCKHILL_COURT_MAGICIAN
	description = "Your creed is one dedicated to the conquering of the arcane arts and the constant thrill of knowledge. You owe your life to the Lord, for it was his coin that allowed you to continue your studies in these dark times. In return, you have proven time and time again as justicar and trusted advisor to their reign."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_MAGICIAN"
	outfit = /datum/outfit/job/roguetown/magician
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/courtmage"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/magician
	rockhill_traits = list(
		TRAIT_BADTRAINER,
		TRAIT_ARCYNE,
		TRAIT_SEEPRICES,
		TRAIT_INTELLECTUAL,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NOBLE,
		TRAIT_MAGEDEXTERITY,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/manorguard
	title = JOB_ROCKHILL_MAN_AT_ARMS
	description = "Having proven yourself loyal and capable, you are entrusted to defend the keep and enforce its will throughout the city and duchy. Trained regularly in combat and siege warfare, you deal with threats - both within and without. Obey your Marshal, Knight-captain and the Crown. Show the nobles and knights your respect, so that you may earn it in turn. Not as a commoner, but as a soldier.."
	total_positions = 8
	spawn_positions = 8
	config_tag = "ROCKHILL_MANORGUARD"
	outfit = /datum/outfit/job/roguetown/manorguard
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/manorguard/footsman"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/manorguard/footsman,
		/datum/rockhill_advclass/manorguard/skirmisher,
		/datum/rockhill_advclass/manorguard/cavalry,
		/datum/rockhill_advclass/manorguard/gormless,
		/datum/rockhill_advclass/manorguard/retainer,
		/datum/rockhill_advclass/manorguard/standard_bearer,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/manorguard
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)
	rogue_social_rank = 3

/datum/job/roguetown/marshal
	title = JOB_ROCKHILL_MARSHAL
	description = "You are an agent of the crown in matters of law and military, making sure that laws are pushed, verified and carried out by the retinue upon the citizenry of the realm. As the ultimate authority on all things military, much of your work happens behind a desk, deferring duties between the Knight Captain, Watch Captain and Master Warden and acting as the primary go-between to ensure the will of the duke, through you, is carried out in the field."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_MARSHAL"
	outfit = /datum/outfit/job/roguetown/marshal
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/marshal/classic"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/marshal/classic,
		/datum/rockhill_advclass/marshal/kcommander,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/marshal
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_PERFECT_TRACKER,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/martyr
	title = JOB_ROCKHILL_MARTYR
	description = "Prayer. Conviction. Intent. Words they'd drilled into your skull, from the moment of induction, up until your assignment as the Prelate's ward. A crimson gild upon your soul, a taint that can't be cleared. For you are a weapon of the Holy See. No more. No less. Defend the Prelate. Give up no hallowed ground. Die for the Ten."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_MARTYR"
	outfit = /datum/outfit/job/roguetown/martyr
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/martyr"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/martyr
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_SILVER_BLESSED,
		TRAIT_EMPATH,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_DUALWIELDER,
		TRAIT_VOTARY,
		TRAIT_CONVICTION,
		TRAIT_TEMPO,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 5

/datum/job/roguetown/mercenary
	title = JOB_ROCKHILL_MERCENARY
	description = "Blood stains your hands and the coins you hold. You are a sell-sword, a mercenary, a contractor of war. Where you come from, what you are, who you serve.. none of it matters. What matters is that the mammon flows to your pocket."
	total_positions = 8
	spawn_positions = 8
	config_tag = "ROCKHILL_MERCENARY"
	outfit = /datum/outfit/job/roguetown/mercenary
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	rockhill_advclass = "/datum/advclass/mercenary/atgervi"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/mercenary/atgervi,
		/datum/rockhill_advclass/mercenary/atgervi/shaman,
		/datum/rockhill_advclass/mercenary/condottiero,
		/datum/rockhill_advclass/mercenary/crocs,
		/datum/rockhill_advclass/mercenary/crocsass,
		/datum/rockhill_advclass/mercenary/desert_rider,
		/datum/rockhill_advclass/mercenary/desert_rider/zeybek,
		/datum/rockhill_advclass/mercenary/desert_rider/almah,
		/datum/rockhill_advclass/mercenary/forlorn,
		/datum/rockhill_advclass/mercenary/vaquero,
		/datum/rockhill_advclass/mercenary/ferentia,
		/datum/rockhill_advclass/mercenary/ferentia/sellspear,
		/datum/rockhill_advclass/mercenary/ferentia/sellblade,
		/datum/rockhill_advclass/mercenary/ferentia/thug,
		/datum/rockhill_advclass/mercenary/ferentia/crossbowman,
		/datum/rockhill_advclass/mercenary/ferentia/longbowman,
		/datum/rockhill_advclass/mercenary/freelancer,
		/datum/rockhill_advclass/mercenary/freelancer_lancer,
		/datum/rockhill_advclass/mercenary/freelancer_sabrist,
		/datum/rockhill_advclass/mercenary/grenzelhoft,
		/datum/rockhill_advclass/mercenary/grenzelhoft/halberdier,
		/datum/rockhill_advclass/mercenary/grenzelhoft/crossbowman,
		/datum/rockhill_advclass/mercenary/grenzelhoft/mage,
		/datum/rockhill_advclass/mercenary/gronnheavy,
		/datum/rockhill_advclass/mercenary/routier,
		/datum/rockhill_advclass/mercenary/rumaclan,
		/datum/rockhill_advclass/mercenary/rumaclan/sasu,
		/datum/rockhill_advclass/mercenary/steppesman,
		/datum/rockhill_advclass/mercenary/warscholar,
		/datum/rockhill_advclass/mercenary/warscholar/pontifex,
		/datum/rockhill_advclass/mercenary/warscholar/vizier,
		/datum/rockhill_advclass/mercenary/blackoak,
		/datum/rockhill_advclass/mercenary/blackoak/ranger,
		/datum/rockhill_advclass/mercenary/grudgebearer,
		/datum/rockhill_advclass/mercenary/grudgebearer/soldier,
		/datum/rockhill_advclass/mercenary/oathmarked,
		/datum/rockhill_advclass/mercenary/oathmarked/executor,
		/datum/rockhill_advclass/mercenary/newmoon,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/mercenary
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/job/roguetown/merchant
	title = JOB_ROCKHILL_MERCHANT
	description = "You were born into wealth, learning from before you could talk about the basics of mathematics. Counting coins is a simple pleasure for any person, but you've made it an art form. These people are addicted to your wares, and you are the literal beating heart of this economy: Don't let these filth-covered troglodytes ever forget that."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_MERCHANT"
	outfit = /datum/outfit/job/roguetown/merchant
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/merchant"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/merchant
	rockhill_traits = list(
		TRAIT_SEEPRICES,
		TRAIT_CICERONE,
		)
	rogue_social_rank = 3

/datum/job/roguetown/monk
	title = JOB_ROCKHILL_ACOLYTE
	description = "Chores, some more chores- Even more chores.. Oh how the life of a humble acolyte is exhausting… You have faith, but even you know you gave up a life of adventure for that of the security in the Church. Assist the Bishop in their daily tasks, maybe today will be the day something interesting happens."
	total_positions = 6
	spawn_positions = 6
	config_tag = "ROCKHILL_MONK"
	outfit = /datum/outfit/job/roguetown/monk
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/acolyte"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/monk
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 4

/datum/job/roguetown/nightmaiden
	title = JOB_ROCKHILL_BATHHOUSE_ATTENDANT
	description = "Dancing, music, or practicioners of the body. You've worked up a reputation as an entertainer, and sometime in life, the bathmaster has chosen to onboard you for one of these talents. In the bathhouse, your place on the hierarchy is determined by how long you've been in the game - and how much mammon you're worth."
	total_positions = 5
	spawn_positions = 5
	config_tag = "ROCKHILL_NIGHTMAIDEN"
	outfit = /datum/outfit/job/roguetown/nightmaiden
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/nightmaiden"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/nightmaiden,
		/datum/rockhill_advclass/nightmaiden/concubine,
		/datum/rockhill_advclass/nightmaiden/courtesan,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/nightmaiden
	rockhill_traits = list(
		TRAIT_NUTCRACKER,
		TRAIT_CICERONE,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_BATHHOUSE_DANCER,
		)
	alternate_titles = list(
		"Nightswain",
		"Nightmaiden",
		)
	rogue_allowed_ages = list("Adult", "Middle-Aged")
	rogue_social_rank = 2
	rogue_advjob_examine = TRUE

/datum/job/roguetown/niteman
	title = JOB_ROCKHILL_BATHMASTER
	description = "You are renting out the bathhouse in a joint operation with the Innkeep. You provide security for the bathwenches and help them to find work--when you're not being a trouble-making rake that others suffer to tolerate."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_NITEMAN"
	outfit = /datum/outfit/job/roguetown/niteman
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/bathmaster"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/niteman
	rockhill_traits = list(
		TRAIT_SEEPRICES,
		TRAIT_CICERONE,
		TRAIT_NUTCRACKER,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	alternate_titles = list(
		"Bathmatron",
		"Nightmaster",
		"Nightmistress",
		)
	rogue_social_rank = 3
	rogue_f_title = "Bathmatron"

/datum/job/roguetown/orphan
	title = JOB_ROCKHILL_VAGABOND
	description = "The world is not a kind place, and many have lost everything in the pursuit of even a meagre existence. Vagabonds are such individuals, and start with next to nothing but their skills and wits."
	total_positions = 12
	spawn_positions = 12
	config_tag = "ROCKHILL_ORPHAN"
	outfit = /datum/outfit/job/roguetown/orphan
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/vagabond_original"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/vagabond_original,
		/datum/rockhill_advclass/vagabond_beggar,
		/datum/rockhill_advclass/vagabond_courier,
		/datum/rockhill_advclass/vagabond_deprived,
		/datum/rockhill_advclass/vagabond_excommunicated,
		/datum/rockhill_advclass/vagabond_goatherd,
		/datum/rockhill_advclass/vagabond_mage,
		/datum/rockhill_advclass/vagabond_runner,
		/datum/rockhill_advclass/vagabond_scholar,
		/datum/rockhill_advclass/vagabond_wanted,
		/datum/rockhill_advclass/vagabond_unraveled,
		/datum/rockhill_advclass/vagabond_busker,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/orphan
	rogue_advjob_examine = TRUE
	rogue_lowlife_examine = TRUE

/datum/job/roguetown/orthodoxist
	title = JOB_ROCKHILL_ORTHODOXIST
	description = "Praise. Atone. Mourn. A hundred different paths across a hundred different lyves, all ending the same; with you swearing fealty to Psydon, and your admittance into the Inquisitor's retinue. Root the abberants out from wherever they dwell, and - whether with a clenched fist or open palm - bring them back to the light."
	total_positions = 3
	spawn_positions = 3
	config_tag = "ROCKHILL_ORTHODOXIST"
	outfit = /datum/outfit/job/roguetown/orthodoxist
	departments_list = list(
		/datum/job_department/rockhill_inquisition,
		)
	rockhill_advclass = "/datum/advclass/psydoniantemplar"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/psydoniantemplar,
		/datum/rockhill_advclass/disciple,
		/datum/rockhill_advclass/confessor,
		/datum/rockhill_advclass/psyaltrist,
		/datum/rockhill_advclass/arbalist,
		/datum/rockhill_advclass/sojourner,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/orthodoxist
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_social_rank = 2
	rogue_advjob_examine = TRUE

/datum/job/roguetown/physician
	title = JOB_ROCKHILL_HEAD_PHYSICIAN
	description = "You are a master physician, trusted by the Duke themself to administer expert care to the Royal family, the court, its protectors and its subjects. While primarily a resident of the keep in the manors medical wing, you also have access to the local hightown clinic, where lesser licensed apothecaries ply their trade under your occasional passing tutelage."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_PHYSICIAN"
	outfit = /datum/outfit/job/roguetown/physician
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/physician"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/physician
	rockhill_traits = list(
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NOSTINK,
		TRAIT_EMPATH,
		TRAIT_NOBLE,
		)
	alternate_titles = list(
		"Court Physician",
		)
	rogue_social_rank = 5

/datum/job/roguetown/pilgrim
	title = JOB_ROCKHILL_REFUGEE
	description = "Fleeing misfortune you head your way towards the Duchy. You are not a soldier or an explorer, but a humble migrant trying to look for a better life, if you get to survive the trip that is."
	total_positions = 40
	spawn_positions = 40
	config_tag = "ROCKHILL_PILGRIM"
	outfit = /datum/outfit/job/roguetown/pilgrim
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/artificer"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/artificer,
		/datum/rockhill_advclass/barbersurgeon,
		/datum/rockhill_advclass/blacksmith,
		/datum/rockhill_advclass/builder,
		/datum/rockhill_advclass/cheesemaker,
		/datum/rockhill_advclass/fisher,
		/datum/rockhill_advclass/homesteader,
		/datum/rockhill_advclass/hunter,
		/datum/rockhill_advclass/hunter/spear,
		/datum/rockhill_advclass/miner,
		/datum/rockhill_advclass/minstrel,
		/datum/rockhill_advclass/peasant,
		/datum/rockhill_advclass/potter,
		/datum/rockhill_advclass/scavenger/harvester,
		/datum/rockhill_advclass/scavenger/prospector,
		/datum/rockhill_advclass/seamstress,
		/datum/rockhill_advclass/trader/brewer,
		/datum/rockhill_advclass/trader/cuisiner,
		/datum/rockhill_advclass/trader/doomsayer,
		/datum/rockhill_advclass/trader/harlequin,
		/datum/rockhill_advclass/trader/jeweler,
		/datum/rockhill_advclass/trader/peddler,
		/datum/rockhill_advclass/trader/scholar,
		/datum/rockhill_advclass/witch,
		/datum/rockhill_advclass/woodworker,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/pilgrim
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/datum/job/roguetown/priest
	title = JOB_ROCKHILL_BISHOP
	description = "The Divine is all that matters in a world of the immoral. The Weeping God left his children to rule over us mortals--and you will preach their wisdom to any who still heed their will. The faithless are growing in number. It is up to you to shepard them toward a Gods-fearing future; for you are a Bishop of the Holy See."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_PRIEST"
	outfit = /datum/outfit/job/roguetown/priest
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/bishop"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/priest
	rockhill_traits = list(
		TRAIT_CHOSEN,
		TRAIT_RITUALIST,
		TRAIT_GRAVEROBBER,
		TRAIT_RESONANCE,
		TRAIT_VOTARY,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_HOLYWARRIOR,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 6

/datum/job/roguetown/prince
	title = JOB_ROCKHILL_PRINCE
	description = "You've never felt the gnawing of the winter, never known the bite of hunger and certainly have never known a honest day's work. You are as free as any bird in the sky, and you may revel in your debauchery for as long as your parents remain upon the throne: But someday you'll have to grow up, and that will be the day your carelessness will cost you more than a few mammons."
	total_positions = 2
	spawn_positions = 2
	config_tag = "ROCKHILL_PRINCE"
	outfit = /datum/outfit/job/roguetown/prince
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/heir/daring"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heir/daring,
		/datum/rockhill_advclass/heir/bookworm,
		/datum/rockhill_advclass/heir/aristocrat,
		/datum/rockhill_advclass/heir/inbred,
		/datum/rockhill_advclass/heir/scamp,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/prince
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE,
		)
	alternate_titles = list(
		"Princess",
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/harpy", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/ooze", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 6
	rogue_f_title = "Princess"

/datum/job/roguetown/prisonerr
	title = JOB_ROCKHILL_PRISONER_TOWN
	description = "How does it feel to be the rat in the cage? You're alone and at the mercy of your captors, kept around as a hostage. You spend your days waiting for the oft chance someone comes to pay your ransom. Might as well start praying to whatever god you find solace in."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_PRISONERR"
	outfit = /datum/outfit/job/roguetown/prisonerr
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/prisoner_woodcutter"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/prisoner_blacksmith,
		/datum/rockhill_advclass/prisoner_butcher,
		/datum/rockhill_advclass/prisoner_carpenter,
		/datum/rockhill_advclass/prisoner_cheesemaker,
		/datum/rockhill_advclass/prisoner_drunkard,
		/datum/rockhill_advclass/prisoner_farmer,
		/datum/rockhill_advclass/prisoner_hunter,
		/datum/rockhill_advclass/prisoner_miner,
		/datum/rockhill_advclass/prisoner_minstrel,
		/datum/rockhill_advclass/prisoner_potter,
		/datum/rockhill_advclass/prisoner_seamstress,
		/datum/rockhill_advclass/prisoner_thug,
		/datum/rockhill_advclass/prisoner_towndoctor,
		/datum/rockhill_advclass/prisoner_witch,
		/datum/rockhill_advclass/prisoner_woodcutter,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/prisonerr
	rockhill_traits = list(
		TRAIT_BANDITCAMP,
		)

/datum/job/roguetown/puritan
	title = JOB_ROCKHILL_INQUISITOR
	description = "You are a puritan of unmatched aptitude, adherent to the Psydonic doctrine and entrusted with the authority to lead a local sect. Otava - the largest Psydonic kingdom left on this world - has seen it fit to treat you like a silver-tipped olive branch, gifted to the realm to ward off the encroaching darkness. Tread carefully when pursuing your missives, lest the faithless strap you to the pyre as well."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_PURITAN"
	outfit = /datum/outfit/job/roguetown/puritan
	departments_list = list(
		/datum/job_department/rockhill_inquisition,
		)
	rockhill_advclass = "/datum/advclass/puritan/inspector"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/puritan/inspector,
		/datum/rockhill_advclass/puritan/ordinator,
		/datum/rockhill_advclass/puritan/arbiter,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/puritan
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DODGEEXPERT,
		TRAIT_MEDIUMARMOR,
		TRAIT_BLACKBAGGER,
		TRAIT_SILVER_BLESSED,
		TRAIT_INQUISITION,
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		TRAIT_PURITAN,
		TRAIT_OUTLANDER,
		TRAIT_NOBLE,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_social_rank = 5

/datum/job/roguetown/rockhillslave
	title = JOB_ROCKHILL_SLAVE
	description = "Traded around like common goods you are deprived of your freedom and been trained into an obedient implement of your masters. Whether it be making them rich or making them comfortable you serve at their leisure with your continued well being entirely dependent on your owner's good will."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_ROCKHILLSLAVE"
	outfit = /datum/outfit/job/roguetown/slave
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/slave/house_slave"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/slave/house_slave,
		/datum/rockhill_advclass/slave/labor_slave,
		/datum/rockhill_advclass/slave/slave_sentry,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/rockhillslave
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_OWNED_SLAVE,
		)
	rogue_social_rank = 2

/datum/job/roguetown/rookie
	title = JOB_ROCKHILL_ROOKIE
	description = "Odd-jobs, running messages, fixing dents and talking to locals; the City Watch can always use a spare pair of hands, eyes and ears. Assist your fellow city watchmen in dealing with threats - both within and without. Given a brief introduction in weapons and guardwork, the rest of your training is to be picked up on the job. Obey your superiors (everyone who isn't you) and show the nobles your respect. Keep an eye out, try to learn a thing or two, then one day you might live to make an adequate soldier."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_ROOKIE"
	outfit = /datum/outfit/job/roguetown/rookie
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/rookie/frontline"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/rookie/frontline,
		/datum/rockhill_advclass/rookie/backline,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/rookie
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_GUARDSMAN,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 2

/datum/job/roguetown/sergeant
	title = JOB_ROCKHILL_SERGEANT
	description = "You are the most experienced of the Crown's Soldiery, leading the men-at-arms in maintaining order and attending to threats and crimes below the court's attention. See to those under your command and fill in the gaps knights leave in their wake. Obey the orders of your Marshal and the Crown."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_SERGEANT"
	outfit = /datum/outfit/job/roguetown/sergeant
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/sergeant/sergeant"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/sergeant
	rockhill_traits = list(
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		)
	rogue_social_rank = 3

/datum/job/roguetown/servant
	title = JOB_ROCKHILL_SERVANT
	description = "Granted a life of comfortable servitude in the Duke's manor, you follow the Seneschal's commands and spend your day performing necessary but menial tasks. This role offers an aesthetic choice between labor-servant, maid, and butler."
	total_positions = 6
	spawn_positions = 6
	config_tag = "ROCKHILL_SERVANT"
	outfit = /datum/outfit/job/roguetown/servant
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/servant/servant"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/servant/servant,
		/datum/rockhill_advclass/servant/maid,
		/datum/rockhill_advclass/servant/butler,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/servant
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2
	rogue_advjob_examine = TRUE

/datum/job/roguetown/shophand
	title = JOB_ROCKHILL_SHOPHAND
	description = "You work the largest store in the city by grace of the Merchant who has shackled you to this drudgery. The work of stocking shelves and taking inventory for your employer is mind-numbing and repetitive--but at least you have a roof over your head and comfortable surroundings. With time, perhaps you will one day be more than a glorified servant."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_SHOPHAND"
	outfit = /datum/outfit/job/roguetown/shophand
	departments_list = list(
		/datum/job_department/rockhill_youngfolk,
		)
	rockhill_advclass = "/datum/advclass/shophand"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/shophand
	rockhill_traits = list(
		TRAIT_SEEPRICES,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 2

/datum/job/roguetown/slaver
	title = JOB_ROCKHILL_SLAVER
	description = "You are one of the many fingers part of slavery's long arm, away from the fiercest competition over in the far southeast of the world you have established yourself as the premier slaver in this duchy. Put your slaves to work or auction them off, acquire new ones from the lowtown garrison or through less savory means."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_SLAVER"
	outfit = /datum/outfit/job/roguetown/slaver
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/slaver"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/slaver
	rockhill_traits = list(
		TRAIT_SLEUTH,
		)
	rogue_social_rank = 3

/datum/job/roguetown/squire
	title = JOB_ROCKHILL_SQUIRE
	description = "Your folks said you were going to be something, they had better aspirations for you than the life of a peasant. You practiced the basics in the field alongside your friends, swordfighting with sticks, chasing rabbits with grain flail, and helping around the house lifting heavy bags of grain. The Knight took notice of your potential and brought you on as his personal ward. You're going to be something someday."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_SQUIRE"
	outfit = /datum/outfit/job/roguetown/squire
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/squire/lancer"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/squire/lancer,
		/datum/rockhill_advclass/squire/footman,
		/datum/rockhill_advclass/squire/skirmisher,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/squire
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_allowed_ages = list("Adult")
	rogue_social_rank = 2

/datum/job/roguetown/steward
	title = JOB_ROCKHILL_STEWARD
	description = "Coin, Coin, Coin! Oh beautiful coin: You're addicted to it, and you hold the position as the Grand Duke's personal treasurer of both coin and information. You know the power silver and gold has on a man's mortal soul, and you know just what lengths they'll go to in order to get even more. Keep your festering economy alive- for it is the only thing you can weigh any trust into anymore."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_STEWARD"
	outfit = /datum/outfit/job/roguetown/steward
	departments_list = list(
		/datum/job_department/rockhill_nobles,
		)
	rockhill_advclass = "/datum/advclass/steward"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/steward
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_ROYAL_SUBSIDY,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/job/roguetown/tailor
	title = JOB_ROCKHILL_TAILOR
	description = "You have worked sleepless nights on honing your craft. From sacks, to tapestry and luxurious clothing, there is little you cannot sew into existence. Use your storefront to turn even the ugliest peasant into a proper gentleman; who knows, even the nobility may pay you a visit."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_TAILOR"
	outfit = /datum/outfit/job/roguetown/tailor
	departments_list = list(
		/datum/job_department/rockhill_yeomen,
		)
	rockhill_advclass = "/datum/advclass/tailor"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/tailor
	rockhill_traits = list(
		TRAIT_SEWING_EXPERT,
		TRAIT_EFFICIENT_WEAVER,
		)
	rogue_social_rank = 3

/datum/job/roguetown/templar
	title = JOB_ROCKHILL_TEMPLAR
	description = "Templars are warriors who have forsaken wealth and title in lieu of service to the church, due to either zealotry or a past shame. They guard the church and its bishop while keeping a watchful eye against heresy and nite-creechers. Within troubled dreams, they wonder if the blood they shed makes them holy or stained."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_TEMPLAR"
	outfit = /datum/outfit/job/roguetown/templar
	departments_list = list(
		/datum/job_department/rockhill_church,
		)
	rockhill_advclass = "/datum/advclass/templar/crusader"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/templar
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_RITUALIST,
		TRAIT_STEELHEARTED,
		)
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
	rogue_social_rank = 4

/datum/job/roguetown/vanguard
	title = JOB_ROCKHILL_VANGUARD
	description = "Either a fresh lowborn recruit with something to prove or paying off your crimes with a mandated tour of duty, you have been assigned under the lowtown baron. You have a roof over your head, meagre coin in your pocket, and a thankless job protecting the outskirts of town against what lurks beyond. You are subordinate to the baron, but often are led by the master warden or the retainer and may be called upon as members of the garrison by the Marshal and Crown. Protect lowtown's interests and be the first line of defence from threats beyond the borders of civilisation, hold the vanguard bastion, and try to survive another day. Maybe you'll make it into the Wardens some day."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_VANGUARD"
	outfit = /datum/outfit/job/roguetown/vanguard
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/vanguard/footman"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/vanguard/footman,
		/datum/rockhill_advclass/vanguard/archer,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/vanguard
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SURVIVAL_EXPERT,
		)
	rogue_social_rank = 2

/datum/job/roguetown/veteran
	title = JOB_ROCKHILL_VETERAN
	description = "You've known combat your entire life. There isn't a way to kill a man you havent practiced in the tapestries of war itself. You wouldn't call yourself a hero--those belong to the men left rotting in the fields where you honed your ancient trade. You don't sleep well at night anymore, you don't like remembering what you've had to do to survive. Trading adventure for stable pay was the only logical solution, and maybe someday you'll get to lay down the blade and rest your weary body..."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_VETERAN"
	outfit = /datum/outfit/job/roguetown/veteran
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/veteran/battlemaster"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/veteran/battlemaster,
		/datum/rockhill_advclass/veteran/footman,
		/datum/rockhill_advclass/veteran/calvaryman,
		/datum/rockhill_advclass/veteran/merc,
		/datum/rockhill_advclass/veteran/scout,
		/datum/rockhill_advclass/veteran/spy,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/veteran
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_ages = list("Old")
	rogue_social_rank = 4

/datum/job/roguetown/villager
	title = JOB_ROCKHILL_TOWNER
	description = "You've lived in this shithole for effectively all your life. You are not an explorer, nor exactly a warrior in many cases. You're just some average poor bastard who thinks they'll be something someday. Respect the nobles and yeomen alike for they are your superiors - should you find yourself in trouble your Elder is your best hope."
	total_positions = 75
	spawn_positions = 75
	config_tag = "ROCKHILL_VILLAGER"
	outfit = /datum/outfit/job/roguetown/villager
	departments_list = list(
		/datum/job_department/rockhill_peasants,
		)
	rockhill_advclass = "/datum/advclass/barbersurgeon"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/barbersurgeon,
		/datum/rockhill_advclass/blacksmith,
		/datum/rockhill_advclass/cheesemaker,
		/datum/rockhill_advclass/drunkard,
		/datum/rockhill_advclass/fisher,
		/datum/rockhill_advclass/hunter,
		/datum/rockhill_advclass/hunter/spear,
		/datum/rockhill_advclass/miner,
		/datum/rockhill_advclass/minstrel,
		/datum/rockhill_advclass/peasant,
		/datum/rockhill_advclass/potter,
		/datum/rockhill_advclass/seamstress,
		/datum/rockhill_advclass/thug,
		/datum/rockhill_advclass/witch,
		/datum/rockhill_advclass/woodworker,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/villager
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_NOSTINK,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		)
	rogue_social_rank = 2
	rogue_advjob_examine = TRUE

/datum/job/roguetown/wapprentice
	title = JOB_ROCKHILL_MAGICIANS_ASSOCIATE
	description = "Your master once saw potential in you, although you are uncertain if they still do, given how rigorous and difficult your studies have been. The path to using magic is a treacherous and untamed one, and you are still decades away from calling yourself even a journeyman in the field. Listen and serve, and someday you will earn your hat."
	total_positions = 4
	spawn_positions = 4
	config_tag = "ROCKHILL_WAPPRENTICE"
	outfit = /datum/outfit/job/roguetown/wapprentice
	departments_list = list(
		/datum/job_department/rockhill_courtiers,
		)
	rockhill_advclass = "/datum/advclass/wapprentice/associate"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/wapprentice/associate,
		/datum/rockhill_advclass/wapprentice/apprentice,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/wapprentice
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MAGEDEXTERITY,
		)
	rogue_social_rank = 3
	rogue_advjob_examine = TRUE

/datum/job/roguetown/warden
	title = JOB_ROCKHILL_FOREST_WARDEN
	description = "Having proven yourself through years of scouting, skirmishing and survival in the vanguard, you have been initiated into the Wardens - an elite fraternity of ranger types who keep a vigil over the untamed wilderness. Trusted to venture deep into the uncivilised darkness south of lowtown, you act as a scout, soldier, sentinel and guide, performing long-range reconnaissance, culling dangerous wildlife, and protecting lowtown alongside the vanguard. You are subordinate to the Master Warden, whom in turn serves the baron and may be called upon as members of the garrison by the Marshal and Crown. Serve the baron's will as the first line of defence from threats beyond the borders of civilisation, keep the roads safe, and hold the vanguard fortress. The Crown is counting on you."
	total_positions = 6
	spawn_positions = 6
	config_tag = "ROCKHILL_WARDEN"
	outfit = /datum/outfit/job/roguetown/warden
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/warden/ranger"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/warden/ranger,
		/datum/rockhill_advclass/warden/forester,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/warden
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_social_rank = 2

/datum/job/roguetown/wardenmaster
	title = JOB_ROCKHILL_MASTER_WARDEN
	description = "You are the most experienced of the Wardens, the elite rangers that patrol, scout and fiercely defend the lower city and wilderness surrounding it, attending to threats and crimes below the city's attention. Your job is to lead the aloof Wardens and wrangle the unruly vanguard, carving order out of the chaos south of the city's walls. Obey the orders of the lowtown baron, and enact their will beyond the wall as the first line of defence from threats beyond the borders of civilisation. Keep the roads safe, and hold the vanguard fortress. The Crown is counting on you."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_WARDENMASTER"
	outfit = /datum/outfit/job/roguetown/wardenmaster
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/wardenmaster/wardenmaster"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/wardenmaster
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		TRAIT_DODGEEXPERT,
		TRAIT_WOODSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_FUSILIER,
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		)
	rogue_social_rank = 3

/datum/job/roguetown/watchcaptain
	title = JOB_ROCKHILL_WATCH_CAPTAIN
	description = "You are the most experienced of the City Watch, leading the city watchmen in maintaining order in hightown and attending to threats and crimes below the keep's attention. See to those brave city watchmen under your command and fill in the gaps the ducal retinue leave in their wake. Obey the orders of the marshal and the Crown."
	total_positions = 1
	spawn_positions = 1
	config_tag = "ROCKHILL_WATCHCAPTAIN"
	outfit = /datum/outfit/job/roguetown/watchcaptain
	departments_list = list(
		/datum/job_department/rockhill_garrison,
		)
	rockhill_advclass = "/datum/advclass/watchcaptain/watchcaptain"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/watchcaptain
	rockhill_traits = list(
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		)
	rogue_social_rank = 3

/datum/job/roguetown/wretch
	title = JOB_ROCKHILL_WRETCH
	description = "Somewhere in your lyfe, you fell to the wrong side of civilization. Hounded by the consequences of your actions, you spend your daes prowling the roads for easy marks and loose purses, scraping to get by."
	total_positions = 9
	spawn_positions = 9
	config_tag = "ROCKHILL_WRETCH"
	outfit = /datum/outfit/job/roguetown/wretch
	departments_list = list(
		/datum/job_department/rockhill_wanderers,
		)
	mind_traits = list(
		"Hidden Domiciles",
		)
	rockhill_advclass = "/datum/advclass/wretch/deserter"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/wretch/licker,
		/datum/rockhill_advclass/wretch/deserter,
		/datum/rockhill_advclass/wretch/deserter/maa,
		/datum/rockhill_advclass/wretch/berserker,
		/datum/rockhill_advclass/wretch/roguemage,
		/datum/rockhill_advclass/wretch/necromancer,
		/datum/rockhill_advclass/wretch/heretic,
		/datum/rockhill_advclass/wretch/heretic/spy,
		/datum/rockhill_advclass/wretch/heretic/monk,
		/datum/rockhill_advclass/wretch/outlaw,
		/datum/rockhill_advclass/wretch/outlaw/marauder,
		/datum/rockhill_advclass/wretch/lunacyembracer,
		/datum/rockhill_advclass/wretch/poacher,
		/datum/rockhill_advclass/wretch/plaguebearer,
		/datum/rockhill_advclass/wretch/mistwalker,
		/datum/rockhill_advclass/wretch/pyromaniac,
		/datum/rockhill_advclass/wretch/vigilante,
		/datum/rockhill_advclass/wretch/herald_of_progress,
		/datum/rockhill_advclass/wretch/blackoakwyrm,
		/datum/rockhill_advclass/wretch/antipope,
		/datum/rockhill_advclass/wretch/wretchedtoiler,
		/datum/rockhill_advclass/wretch/ancientchampion,
		)
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill/wretch
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_EQUESTRIAN,
		TRAIT_DISGRACED_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/datum/outfit/job/roguetown/absolver
	name = JOB_ROCKHILL_ABSOLVER
	jobtype = /datum/job/roguetown/absolver
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer/psydon
	cloak = /obj/item/clothing/cloak/absolutionistrobe
	head = /obj/item/clothing/head/roguetown/helmet/heavy/absolver
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/psythorns
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	r_pocket = /obj/item/flashlight/flare/torch/lantern/psycenser
	backpack_contents = list(
		/obj/item/book/rogue/bibble/psy = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 2,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 2,
		/obj/item/paper/inqslip/arrival/abso = 1,
		/obj/item/needle = 1,
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/storage/keyring/puritan = 1,
		/obj/item/ritechalk = 1,
		)

/datum/outfit/job/roguetown/adventurer
	name = JOB_ROCKHILL_ADVENTURER
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/headband/monk
	mask = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/footwraps/padded
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 1,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer = 1,
		)

/datum/outfit/job/roguetown/adventurer/courtagent
	name = JOB_ROCKHILL_COURT_AGENT
	jobtype = /datum/job/roguetown/adventurer/courtagent
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/headband/monk
	mask = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/footwraps/padded
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 1,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer = 1,
		)

/datum/outfit/job/roguetown/adventurer/courtslave
	name = JOB_ROCKHILL_ENSLAVED_ADVENTURER
	jobtype = /datum/job/roguetown/adventurer/courtslave
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/headband/monk
	mask = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/footwraps/padded
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 1,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer = 1,
		)

/datum/outfit/job/roguetown/apothecary
	name = JOB_ROCKHILL_APOTHECARY
	jobtype = /datum/job/roguetown/apothecary
	uniform = /obj/item/clothing/under/roguetown/trou/apothecary
	shirt = /obj/item/clothing/suit/roguetown/shirt/apothshirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/black
	head = /obj/item/clothing/head/roguetown/roguehood/black
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	r_pocket = /obj/item/roguekey/physician
	r_hand = /obj/item/rogueweapon/woodstaff/
	backpack_contents = list(
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/clothing/mask/rogue/physician = 1,
		/obj/item/storage/keyring = 1,
		/obj/item/roguekey/keeper = 1,
		/obj/item/mini_flagpole/apothecary = 1,
		)

/datum/outfit/job/roguetown/archivist
	name = JOB_ROCKHILL_ARCHIVIST
	jobtype = /datum/job/roguetown/archivist
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/archivist
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
	head = /obj/item/clothing/head/roguetown/nightman
	mask = /obj/item/clothing/mask/rogue/spectacles
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/archivist
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/skillbook/unfinished = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper = 1,
		/obj/item/paper = 1,
		/obj/item/paper = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/outfit/job/roguetown/barkeep
	name = JOB_ROCKHILL_INNKEEPER
	jobtype = /datum/job/roguetown/barkeep
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/storage/keyring/innkeep
	backpack_contents = list(
		/obj/item/recipe_book/survival = 1,
		/obj/item/bottle_kit = 1,
		/obj/item/mini_flagpole/innkeeper = 1,
		)

/datum/outfit/job/roguetown/baron
	name = JOB_ROCKHILL_BARON
	jobtype = /datum/job/roguetown/baron
	uniform = /obj/item/clothing/under/roguetown/trou/formal
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	cloak = /obj/item/clothing/cloak/lordcloak/baronycloak
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/roguekey/manor
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	backpack_contents = list(
		/obj/item/roguekey/baron = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/storage/keyring/baronretainer = 1,
		)

/datum/outfit/job/roguetown/baron_retainer
	name = JOB_ROCKHILL_RETAINER
	jobtype = /datum/job/roguetown/baron_retainer
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	cloak = /obj/item/clothing/cloak/tabard/retinue/baronycloak
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/halberd
	backpack_contents = list(
		/obj/item/roguekey/baron = 1,
		/obj/item/storage/keyring/baronretainer = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/outfit/job/roguetown/seneschal
	name = JOB_ROCKHILL_SENESCHAL
	jobtype = /datum/job/roguetown/butler
	uniform = /obj/item/clothing/under/roguetown/trou/formal
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	suit = /obj/item/clothing/armor/gambeson/tailcoat
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/suspenders/butler
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/storage/keyring/servant

/datum/outfit/job/roguetown/captain
	name = JOB_ROCKHILL_KNIGHT_CAPTAIN
	jobtype = /datum/job/roguetown/captain
	uniform = /obj/item/clothing/under/roguetown/chainlegs/captain
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/captain
	cloak = /obj/item/clothing/cloak/captain
	head = /obj/item/clothing/head/roguetown/helmet/heavy/captain
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel/black
	r_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	l_hand = /obj/item/rogueweapon/shield/capbuckler
	r_hand = /obj/item/rogueweapon/sword/capsabre
	backpack_contents = list(
		/obj/item/storage/keyring/kcaptain = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/outfit/job/roguetown/chaplain
	name = JOB_ROCKHILL_COURT_CHAPLAIN
	jobtype = /datum/job/roguetown/chaplain
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/astrata
	mask = /obj/item/clothing/head/roguetown/roguehood/astrata
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	wrists = /obj/item/clothing/wrists/roguetown/wrappings
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/quarterstaff
	l_pocket = /obj/item/storage/keyring/chaplain
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid

/datum/outfit/job/roguetown/churchling
	name = JOB_ROCKHILL_CHURCHLING
	jobtype = /datum/job/roguetown/churchling
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe
	neck = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather/rope
	l_pocket = /obj/item/storage/keyring/churchie

/datum/outfit/job/roguetown/clerk
	name = JOB_ROCKHILL_CLERK
	jobtype = /datum/job/roguetown/clerk
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/cloak/tabard/knight
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/steward
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/mini_flagpole/steward = 1,
		)

/datum/outfit/job/roguetown/cook
	name = JOB_ROCKHILL_MANOR_COOK
	jobtype = /datum/job/roguetown/cook
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
	cloak = /obj/item/clothing/cloak/apron/cook
	head = /obj/item/clothing/head/roguetown/cookhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/roguekey/tavern
	r_pocket = /obj/item/rogueweapon/huntingknife/cleaver
	backpack_contents = list(
		/obj/item/recipe_book/survival = 1,
		/obj/item/mini_flagpole/innkeeper = 1,
		)

/datum/outfit/job/roguetown/councillor
	name = JOB_ROCKHILL_COUNCILLOR
	jobtype = /datum/job/roguetown/councillor
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor
	cloak = /obj/item/clothing/cloak/stabard/surcoat/councillor
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/steward
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel

/datum/outfit/job/roguetown/loudmouth
	name = JOB_ROCKHILL_TOWN_CRIER
	jobtype = /datum/job/roguetown/crier
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/loudmouth
	head = /obj/item/clothing/head/roguetown/veiled/loudmouth
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/roguekey/crier
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/barometer = 1,
		)

/datum/outfit/job/roguetown/druid
	name = JOB_ROCKHILL_DRUID
	jobtype = /datum/job/roguetown/druid
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/dendor
	head = /obj/item/clothing/head/roguetown/dendormask
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	belt = /obj/item/storage/belt/rogue/leather/
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	l_pocket = /obj/item/rogueweapon/whip
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/ritechalk = 1,
		/obj/item/storage/keyring/churchie = 1,
		/obj/item/seeds/treesap = 1,
		)

/datum/outfit/job/roguetown/dungeoneer
	name = JOB_ROCKHILL_DUNGEONEER
	jobtype = /datum/job/roguetown/dungeoneer
	uniform = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/suit/roguetown/shirt/robe/necra
	head = /obj/item/clothing/head/roguetown/necrahood
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/keyring/dungeoneer
	r_pocket = /obj/item/rogueweapon/whip/antique
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 2,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/clothing/neck/roguetown/psicross/silver = 1,
		/obj/item/rogueweapon/surgery/cautery/branding = 1,
		)

/datum/outfit/job/roguetown/farmer
	name = JOB_ROCKHILL_SOILSON
	jobtype = /datum/job/roguetown/farmer
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	head = /obj/item/clothing/head/roguetown/armingcap
	mask = /obj/item/clothing/head/roguetown/roguehood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/storage/keyring/soilson
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/flint = 1,
		)

/datum/outfit/job/roguetown/gapprentice
	name = JOB_ROCKHILL_GUILD_APPRENTICE
	jobtype = /datum/job/roguetown/gapprentice
	uniform = /obj/item/clothing/under/roguetown/tights/random
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/roguekey/crafterguild
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/tongs = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		)

/datum/outfit/job/roguetown/guardsman
	name = JOB_ROCKHILL_CITY_GUARD
	jobtype = /datum/job/roguetown/guardsman
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/plate/citywatch
	head = /obj/item/clothing/head/roguetown/helmet/citywatch
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	r_pocket = /obj/item/rogueweapon/mace/cudgel
	r_hand = /obj/item/rogueweapon/mace/stunmace
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/outfit/job/roguetown/guildmaster
	name = JOB_ROCKHILL_GUILDMASTER
	jobtype = /datum/job/roguetown/guildmaster
	uniform = /obj/item/clothing/under/roguetown/trou/artipants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/artificer
	suit = /obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket
	head = /obj/item/clothing/head/roguetown/chaperon/noble/guildmaster
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	r_pocket = /obj/item/storage/keyring/guildmaster
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/tongs = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/clothing/mask/rogue/spectacles/golden = 1,
		/obj/item/contraption/linker/master = 1,
		/obj/item/mini_flagpole/blacksmith = 1,
		/obj/item/mini_flagpole/artificer = 1,
		)

/datum/outfit/job/roguetown/guildsman
	name = JOB_ROCKHILL_GUILDSMAN
	jobtype = /datum/job/roguetown/guildsman
	uniform = /obj/item/clothing/under/roguetown/trou/artipants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/artificer
	suit = /obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket
	cloak = /obj/item/clothing/cloak/apron/waist/brown
	head = /obj/item/clothing/head/roguetown/articap
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/roguekey/crafterguild
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/recipe_book/engineering = 1,
		/obj/item/recipe_book/ceramics = 1,
		/obj/item/recipe_book/builder = 1,
		/obj/item/clothing/mask/rogue/spectacles/golden = 1,
		/obj/item/mini_flagpole/artificer = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/outfit/job/roguetown/hand
	name = JOB_ROCKHILL_HAND
	jobtype = /datum/job/roguetown/hand
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/dress/royal/hand_m
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
	head = /obj/item/clothing/head/roguetown/chaperon/noble/hand
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/short
	r_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	r_hand = /obj/item/rogueweapon/sword/long/dec
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/dtace = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/storage/keyring/hand = 1,
		)

/datum/outfit/job/roguetown/heartfelt/hand
	name = JOB_ROCKHILL_HAND_OF_HEARTFELT
	jobtype = /datum/job/roguetown/heartfelt/hand
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/heartfelt/hand
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/sword/long/dec
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		)

/datum/outfit/job/roguetown/heartfelt/knight
	name = JOB_ROCKHILL_KNIGHT_OF_HEARTFELT
	jobtype = /datum/job/roguetown/heartfelt/knight
	uniform = /obj/item/clothing/under/roguetown/platelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/heartfelt/hand
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	l_hand = /obj/item/rogueweapon/sword/long/dec
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		)

/datum/outfit/job/roguetown/heartfelt/lord
	name = JOB_ROCKHILL_LORD_OF_HEARTFELT
	jobtype = /datum/job/roguetown/heartfelt/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/heartfelt
	cloak = /obj/item/clothing/cloak/heartfelt
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/rogueweapon/huntingknife
	r_hand = /obj/item/rogueweapon/sword/long/marlin
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		)

/datum/outfit/job/roguetown/jester
	name = JOB_ROCKHILL_JESTER
	jobtype = /datum/job/roguetown/jester
	uniform = /obj/item/clothing/under/roguetown/tights
	suit = /obj/item/clothing/suit/roguetown/shirt/jester
	head = /obj/item/clothing/head/roguetown/jester
	mask = /obj/item/clothing/mask/rogue/xylixmask
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/jester
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/trumpet
	l_pocket = /obj/item/rogue/instrument/drum
	r_pocket = /obj/item/storage/belt/rogue/pouch
	backpack_contents = list(
		/obj/item/storage/keyring/servant = 1,
		)

/datum/outfit/job/roguetown/keeper
	name = JOB_ROCKHILL_KEEPER
	jobtype = /datum/job/roguetown/keeper
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/templar/pestran
	head = /obj/item/clothing/head/roguetown/helmet/heavy/pestran
	neck = /obj/item/clothing/neck/roguetown/psicross/pestra
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/pestrasickle
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/heart_canister = 2,
		/obj/item/heart_blood_vial/filled = 2,
		/obj/item/heart_blood_canister/filled = 1,
		/obj/item/heart_blood_vial = 5,
		/obj/item/heart_blood_canister = 4,
		/obj/item/rogueweapon/huntingknife/idagger/steel/parrying = 1,
		/obj/item/roguekey/keeper = 1,
		/obj/item/roguekey/keeper_inner = 1,
		/obj/item/storage/keyring/churchie = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 2,
		)

/datum/outfit/job/roguetown/knavewench
	name = JOB_ROCKHILL_TAPSTER
	jobtype = /datum/job/roguetown/knavewench
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	cloak = /obj/item/clothing/cloak/apron/waist
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/roguekey/tavern
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/bottle_kit = 1,
		/obj/item/mini_flagpole/innkeeper = 1,
		)

/datum/outfit/job/roguetown/knight
	name = JOB_ROCKHILL_KNIGHT
	jobtype = /datum/job/roguetown/knight
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/retinue
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/greatsword
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/outfit/job/roguetown/lord
	name = JOB_ROCKHILL_GRAND_DUKE
	jobtype = /datum/job/roguetown/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/lordcloak
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	l_pocket = /obj/item/storage/keyring/lord
	l_hand = /obj/item/rogueweapon/lordscepter

/datum/outfit/job/roguetown/lunatic
	name = JOB_ROCKHILL_LUNATIC
	jobtype = /datum/job/roguetown/lunatic
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
	suit = /obj/item/clothing/suit/roguetown/shirt/rags
	belt = /obj/item/storage/belt/rogue/leather/rope
	l_pocket = /obj/item/rogueweapon/huntingknife/stoneknife
	r_pocket = /obj/item/flashlight/flare/torch

/datum/outfit/job/roguetown/magician
	name = JOB_ROCKHILL_COURT_MAGICIAN
	jobtype = /datum/job/roguetown/magician
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/black
	cloak = /obj/item/clothing/cloak/black_cloak
	neck = /obj/item/clothing/neck/roguetown/talkstone
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/magebag/associate
	r_pocket = /obj/item/storage/keyring/mage
	r_hand = /obj/item/rogueweapon/woodstaff/implement/grand/magos
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/rogueweapon/spellbook/grand = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne = 1,
		/obj/item/chalk = 1,
		)

/datum/outfit/job/roguetown/manorguard
	name = JOB_ROCKHILL_MAN_AT_ARMS
	jobtype = /datum/job/roguetown/manorguard
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light/retinue
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/rogueweapon/mace/warhammer
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/outfit/job/roguetown/marshal
	name = JOB_ROCKHILL_MARSHAL
	jobtype = /datum/job/roguetown/marshal
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/retinue
	cloak = /obj/item/clothing/cloak/stabard/surcoat/bailiff
	head = /obj/item/clothing/head/roguetown/chaperon/noble/bailiff
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/mace/cudgel/justice
	l_pocket = /obj/item/storage/keyring/sheriff
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/outfit/job/roguetown/martyr
	name = JOB_ROCKHILL_MARTYR
	jobtype = /datum/job/roguetown/martyr
	uniform = /obj/item/clothing/under/roguetown/platelegs/holysee
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/holysee
	cloak = /obj/item/clothing/cloak/holysee
	head = /obj/item/clothing/head/roguetown/helmet/heavy/holysee
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate/holysee
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/holysee
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/holysee
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	r_pocket = /obj/item/storage/keyring/priest
	r_hand = /obj/item/rogueweapon/scabbard/gwstrap
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/silver = 1,
		/obj/item/mini_flagpole/church = 1,
		)

/datum/outfit/job/roguetown/mercenary
	name = JOB_ROCKHILL_MERCENARY
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather/atgervi
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/atgervi
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/gronn
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/atgervi
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/angle/atgervi
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/atgervi
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/atgervi
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/steel/atgervi
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/outfit/job/roguetown/merchant
	name = JOB_ROCKHILL_MERCHANT
	jobtype = /datum/job/roguetown/merchant
	uniform = /obj/item/clothing/under/roguetown/tights/sailor
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/merchant
	head = /obj/item/clothing/head/roguetown/chaperon/brown
	neck = /obj/item/clothing/neck/roguetown/horus
	wrists = /obj/item/storage/keyring/merchant
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/gun/ballistic/firearm/arquebus_pistol
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/quiver/bullet/lead = 1,
		/obj/item/powderflask = 1,
		/obj/item/mini_flagpole/merchant = 1,
		/obj/item/hunting_map/white_stag = 1,
		)

/datum/outfit/job/roguetown/monk
	name = JOB_ROCKHILL_ACOLYTE
	jobtype = /datum/job/roguetown/monk
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/astrata
	head = /obj/item/clothing/head/roguetown/roguehood/astrata
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	wrists = /obj/item/clothing/wrists/roguetown/wrappings
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	l_pocket = /obj/item/storage/keyring/churchie
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/ritechalk = 1,
		/obj/item/mini_flagpole/church = 1,
		)

/datum/outfit/job/roguetown/nightmaiden
	name = JOB_ROCKHILL_BATHHOUSE_ATTENDANT
	jobtype = /datum/job/roguetown/nightmaiden
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
	head = /obj/item/clothing/head/roguetown/armingcap
	neck = /obj/item/clothing/neck/roguetown/collar/leather
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/roguekey/nightmaiden
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/soap/bath = 1,
		/obj/item/mini_flagpole/bathhouse = 1,
		)

/datum/outfit/job/roguetown/niteman
	name = JOB_ROCKHILL_BATHMASTER
	jobtype = /datum/job/roguetown/niteman
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
	head = /obj/item/lockpick/goldpin/silver
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	wrists = /obj/item/storage/keyring/nightman
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/whip
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 2,
		/obj/item/reagent_containers/powder/moondust = 2,
		/obj/item/reagent_containers/powder/spice = 1,
		/obj/item/mini_flagpole/bathhouse = 1,
		)

/datum/outfit/job/roguetown/orphan
	name = JOB_ROCKHILL_VAGABOND
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/outfit/job/roguetown/orthodoxist
	name = JOB_ROCKHILL_ORTHODOXIST
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/psydontabard
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain/psydon
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/paper/inqslip/arrival/adju = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/clothing/ring/signet/silver/inqscomm = 1,
		)

/datum/outfit/job/roguetown/physician
	name = JOB_ROCKHILL_HEAD_PHYSICIAN
	jobtype = /datum/job/roguetown/physician
	uniform = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/physician
	head = /obj/item/clothing/head/roguetown/physician
	mask = /obj/item/clothing/mask/rogue/physician
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	r_pocket = /obj/item/rogueweapon/scabbard/sheath/courtphysician
	r_hand = /obj/item/rogueweapon/sword/rapier/courtphysician
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 2,
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/mini_flagpole/apothecary = 1,
		/obj/item/storage/keyring/physician = 1,
		)

/datum/outfit/job/roguetown/pilgrim
	name = JOB_ROCKHILL_REFUGEE
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/artificer
	suit = /obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket
	head = /obj/item/clothing/head/roguetown/articap
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/recipe_book/engineering = 1,
		/obj/item/recipe_book/ceramics = 1,
		/obj/item/recipe_book/builder = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/clothing/mask/rogue/spectacles/golden = 1,
		/obj/item/contraption/linker = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/rogueweapon/handsaw = 1,
		)

/datum/outfit/job/roguetown/priest
	name = JOB_ROCKHILL_BISHOP
	jobtype = /datum/job/roguetown/priest
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	head = /obj/item/clothing/head/roguetown/priestmask
	neck = /obj/item/clothing/neck/roguetown/psicross/silver/undivided
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/priest
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/holysee = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/mini_flagpole/church = 1,
		)

/datum/outfit/job/roguetown/prince
	name = JOB_ROCKHILL_PRINCE
	jobtype = /datum/job/roguetown/prince
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/armor/leather/newkeep/heir
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	r_pocket = /obj/item/storage/keyring/heir
	l_hand = /obj/item/rogueweapon/sword/sabre

/datum/outfit/job/roguetown/prisonerr
	name = JOB_ROCKHILL_PRISONER_TOWN
	jobtype = /datum/job/roguetown/prisonerr
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	neck = /obj/item/clothing/neck/roguetown/collar/leather

/datum/outfit/job/roguetown/puritan
	name = JOB_ROCKHILL_INQUISITOR
	jobtype = /datum/job/roguetown/puritan
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat
	head = /obj/item/clothing/head/roguetown/inqhat
	mask = /obj/item/clothing/mask/rogue/spectacles/inq/spawnpair
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow
	backpack_contents = list(
		/obj/item/storage/keyring/puritan = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/psydagger = 1,
		/obj/item/clothing/head/inqarticles/blackbag = 1,
		/obj/item/inqarticles/garrote = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/grapplinghook = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/paper/inqslip/arrival/inq = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/outfit/job/roguetown/slave
	name = JOB_ROCKHILL_SLAVE
	jobtype = /datum/job/roguetown/rockhillslave
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	cloak = /obj/item/clothing/cloak/apron
	head = /obj/item/clothing/head/roguetown/maidband
	neck = /obj/item/clothing/neck/roguetown/collar/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/rockhillslaves
	backpack_contents = list(
		/obj/item/soap/bath = 1,
		)

/datum/outfit/job/roguetown/rookie
	name = JOB_ROCKHILL_ROOKIE
	jobtype = /datum/job/roguetown/rookie
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	head = /obj/item/clothing/head/roguetown/helmet/kettle/
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/short/iron
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		)

/datum/outfit/job/roguetown/sergeant
	name = JOB_ROCKHILL_SERGEANT
	jobtype = /datum/job/roguetown/sergeant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/retinue
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/mace/cudgel
	l_hand = /obj/item/rogueweapon/sword/long/rhomphaia
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardsergeant = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/outfit/job/roguetown/servant
	name = JOB_ROCKHILL_SERVANT
	jobtype = /datum/job/roguetown/servant
	uniform = /obj/item/clothing/under/roguetown/trou/formal/shorts
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/maid/servant
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/suspenders/butler
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/storage/keyring/servant

/datum/outfit/job/roguetown/shophand
	name = JOB_ROCKHILL_SHOPHAND
	jobtype = /datum/job/roguetown/shophand
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/merchant
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/mini_flagpole/merchant = 1,
		)

/datum/outfit/job/roguetown/slaver
	name = JOB_ROCKHILL_SLAVER
	jobtype = /datum/job/roguetown/slaver
	uniform = /obj/item/clothing/under/roguetown/trou/leather/pontifex/zyb
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/whip/bronze
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/clothing/neck/roguetown/psicross/silver = 1,
		/obj/item/rogueweapon/surgery/cautery/branding = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 2,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/rockhillslaver = 1,
		)

/datum/outfit/job/roguetown/squire
	name = JOB_ROCKHILL_SQUIRE
	jobtype = /datum/job/roguetown/squire
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood/advanced
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/keyring/squire
	r_hand = /obj/item/rogueweapon/spear
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/rogueweapon/hammer/copper = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		)

/datum/outfit/job/roguetown/steward
	name = JOB_ROCKHILL_STEWARD
	jobtype = /datum/job/roguetown/steward
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/silktunic
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquegold/steward
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/storage/keyring/steward
	backpack_contents = list(
		/obj/item/mini_flagpole/steward = 1,
		)

/datum/outfit/job/roguetown/tailor
	name = JOB_ROCKHILL_TAILOR
	jobtype = /datum/job/roguetown/tailor
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/cloth
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife/scissors/steel
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/needle = 1,
		/obj/item/storage/keyring/tailor = 1,
		/obj/item/dye_brush = 1,
		/obj/item/recipe_book/sewing = 1,
		/obj/item/book/rogue/swatchbook = 1,
		/obj/item/recipe_book/leatherworking = 1,
		/obj/item/mini_flagpole/tailor = 1,
		)

/datum/outfit/job/roguetown/templar
	name = JOB_ROCKHILL_TEMPLAR
	jobtype = /datum/job/roguetown/templar
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	cloak = /obj/item/clothing/cloak/templar/astratan
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/storage/keyring/churchie = 1,
		)

/datum/outfit/job/roguetown/vanguard
	name = JOB_ROCKHILL_VANGUARD
	jobtype = /datum/job/roguetown/vanguard
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	cloak = /obj/item/clothing/cloak/shadowcloak/vanguard
	head = /obj/item/clothing/head/roguetown/helmet/skullcap
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_pocket = /obj/item/rogueweapon/sword
	r_hand = /obj/item/rogueweapon/spear
	backpack_contents = list(
		/obj/item/storage/keyring/guard = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/signal_horn = 1,
		)

/datum/outfit/job/roguetown/veteran
	name = JOB_ROCKHILL_VETERAN
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	cloak = /obj/item/clothing/cloak/half/vet
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	r_pocket = /obj/item/storage/keyring/guardcastle
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/outfit/job/roguetown/villager
	name = JOB_ROCKHILL_TOWNER
	jobtype = /datum/job/roguetown/villager
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/physician
	head = /obj/item/clothing/head/roguetown/nightman
	mask = /obj/item/clothing/mask/rogue/spectacles
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/storage/belt/rogue/surgery_bag/full
	r_pocket = /obj/item/rogueweapon/huntingknife/cleaver
	backpack_contents = list(
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/natural/cloth = 2,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife/scissors/steel = 1,
		/obj/item/hair_dye_cream = 3,
		/obj/item/heart_blood_canister/filled = 2,
		/obj/item/bait/leech = 4,
		)

/datum/outfit/job/roguetown/wapprentice
	name = JOB_ROCKHILL_MAGICIANS_ASSOCIATE
	jobtype = /datum/job/roguetown/wapprentice
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/mage
	head = /obj/item/clothing/head/roguetown/roguehood/mage
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/gladiator
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/magebag/associate
	r_pocket = /obj/item/storage/keyring/mageapprentice
	backpack_contents = list(
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/chalk = 1,
		)

/datum/outfit/job/roguetown/warden
	name = JOB_ROCKHILL_FOREST_WARDEN
	jobtype = /datum/job/roguetown/warden
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded/warden
	cloak = /obj/item/clothing/cloak/wardencloak
	neck = /obj/item/clothing/neck/roguetown/coif
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/warden
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/warden_machete
	r_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/storage/keyring/guard = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/signal_horn = 1,
		/obj/item/hunting_map/boars = 1,
		)

/datum/outfit/job/roguetown/wardenmaster
	name = JOB_ROCKHILL_MASTER_WARDEN
	jobtype = /datum/job/roguetown/wardenmaster
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded/warden/upgraded
	cloak = /obj/item/clothing/cloak/darkcloak/bear/wardenmaster
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/antler
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick
	l_hand = /obj/item/rogueweapon/stoneaxe/oath
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/wardenmaster = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/signal_horn = 1,
		)

/datum/outfit/job/roguetown/watchcaptain
	name = JOB_ROCKHILL_WATCH_CAPTAIN
	jobtype = /datum/job/roguetown/watchcaptain
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/armor/plate/citywatch/captain
	cloak = /obj/item/clothing/cloak/citywatchcaptain
	head = /obj/item/clothing/head/roguetown/helmet/citywatch/captain
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	r_hand = /obj/item/rogueweapon/mace/stunmace
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/watchcaptain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/impact_grenade/smoke/blind_gas = 1,
		)

/datum/outfit/job/roguetown/wretch
	name = JOB_ROCKHILL_WRETCH
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_hand = /obj/item/rogueweapon/estoc
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/combat/messer = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)
