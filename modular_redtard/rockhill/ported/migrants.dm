/datum/rogue_migrant_wave/adventurer
	name = "Adventure Party"
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up on a dark and lonesome road, perhaps getting ourselves into more than what we bargained for."
	spawn_landmark = "Pilgrim"
	track = "regular"
	required_roles = list(
		/datum/rogue_migrant_role/adventurer = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/adventurer = 3,
		)
	min_optional_fills = 0
	weight = 100
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/crusade
	name = "The 117th Holy Crusade"
	greet_text = "Psydon's holy chalice must be found! Rockhill, a faithful land? Bah, Why let that get in the way of a good crusade! Plenty of looting and pillaging to be done- all in service to Astrata."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/crusader = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/crusader = 4,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 20
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/czwarteki_noble
	name = "Czwarteki Retinue"
	greet_text = "You are a Retinue under a Czwarteki Lord, be it diplomacy, war, or simple passing through the realm to see or assist an old alliance."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/czwarteki_lord = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/czwarteki_heir = 1,
		/datum/rogue_migrant_role/czwarteki_hussar = 2,
		/datum/rogue_migrant_role/czwarteki_retainer = 4,
		/datum/rogue_migrant_role/czwarteki_servant = 2,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/fablefield
	name = "The Fablefield Troupe"
	greet_text = "A troupe of troubadours from fair Fablefield, you travel to these lands seeking inspiration, drawn at every step seemingly by the whims of Xylix. The people here look like they could do with a good show, give them one they'll remember!"
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/fablefield_goliard = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/fablefield_troubadour = 3,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 20
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/goldcaravan
	name = "EA-Hasir's Gold Caravan"
	greet_text = "The esteemed EA Hasir sent your gold caravan forth, Promising only the finest quality gold in grimoria Sell your golden riches and wonders- at a high price."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/ea_hasir_merchant = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/ea_hasir_guard = 2,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 40
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/grenzel_envoy
	name = "Grenzelhoftian Envoy"
	greet_text = "You are a Grenzelhoftian envoy, traveling with bodyguards and a priest to represent your homeland."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/grenzel_envoy = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/grenzel_bodyguard = 2,
		/datum/rogue_migrant_role/grenzel_priest = 1,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/gronn
	name = "Gronn Raiding Party"
	greet_text = "You're a scouting party sent directly from the steppes of Gronn itself. Without the main support of your warband, on this odd place, could you hope to survive, and, perhaps, thrive?"
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/gronn_chieftain = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/gronn_shaman = 1,
		/datum/rogue_migrant_role/gronn_warrior = 3,
		/datum/rogue_migrant_role/gronn_tribal = 4,
		/datum/rogue_migrant_role/gronn_slave = 4,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 40
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/hammerhold
	name = "Hammerholdian Reavers"
	greet_text = "You're a scouting party from Hammerhold, sworn to your jarl and the Ringbearer. Establish a foothold in this foreign land for raids to come and, perhaps, acquire some riches, converts and slaves before anyone else."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/hammerhold_jarl = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/hammerhold_tideweaver = 1,
		/datum/rogue_migrant_role/hammerhold_volfskin = 1,
		/datum/rogue_migrant_role/hammerhold_huscarl = 4,
		/datum/rogue_migrant_role/hammerhold_thrall = 4,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 40
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/heartfelt
	name = "The Court of Heartfelt"
	greet_text = "You're the mighty Baron of Heartfelt, a Border-Vassal of the Vale. Whether compelled by an invasion at the border, a sheer desire to sightsee and visit the Realm, or some political plot known only to you and your court, you have come to visit the Realm with a small, elite picked retinue."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/heartfelt_lord = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/heartfelt_hand = 1,
		/datum/rogue_migrant_role/heartfelt_knight = 1,
		/datum/rogue_migrant_role/heartfelt_retinue = 5,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/knightly_journey
	name = "The Knightly Journey"
	greet_text = "A veteran knight errant rides into these lands, their squire a few yils into the trade and no longer green. There are battles ahead, and deeds worth the telling."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/kj_knight = 1,
		/datum/rogue_migrant_role/kj_squire = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/kj_chaplain = 1,
		/datum/rogue_migrant_role/kj_follower = 2,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/otavan_envoy
	name = "Otavan Emissary"
	greet_text = "You are part of an Otavan diplomatic mission: a small retinue and a Psydonite preacher, ready to represent your homeland."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/otavan_envoy = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/otavan_knight = 1,
		/datum/rogue_migrant_role/otavan_guard = 1,
		/datum/rogue_migrant_role/otavan_scribe = 1,
		/datum/rogue_migrant_role/otavan_preacher = 1,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/pilgrim
	name = "Pilgrimage"
	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to the realm, looking for refuge and work, finally almost being there, almost..."
	spawn_landmark = "Pilgrim"
	track = "regular"
	required_roles = list(
		/datum/rogue_migrant_role/pilgrim = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/pilgrim = 3,
		)
	min_optional_fills = 0
	weight = 100
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/runaway_prisoners
	name = "Runaway Prisoners"
	greet_text = "You've been rotting for years in a cell. Though you escaped, you have nothing - your body atrophied, your mind dulled. But one thing you kknow clearlyu - you are not going back."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/runaway_prisoner = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/runaway_prisoner = 4,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 50
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/slaver
	name = "The Zybantine Slavers"
	greet_text = "A troop of slavers coming to the mainland from the deserts of Zybantine in the hopes of gathering wealth through the trade unfortunate laborers."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/slaver_master = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/slaver_slavemerc = 6,
		/datum/rogue_migrant_role/slaver_slavez = 4,
		)
	min_optional_fills = 1
	max_spawns = 1
	weight = 60
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE

/datum/rogue_migrant_wave/zybantine_noble
	name = "Zybantine Emir"
	greet_text = "You are far from home on missive from the Zybantine Empire."
	spawn_landmark = "Pilgrim"
	track = "special"
	required_roles = list(
		/datum/rogue_migrant_role/zybantine_emir = 1,
		)
	optional_roles = list(
		/datum/rogue_migrant_role/zybantine_amirah = 1,
		/datum/rogue_migrant_role/zybantine_janissary = 2,
		/datum/rogue_migrant_role/zybantine_advisor = 1,
		)
	min_optional_fills = 0
	max_spawns = 1
	weight = 40
	min_round_time = 0
	hidden = FALSE
	is_raid = FALSE
	can_roll = TRUE
	spawn_on_location = TRUE
	shared_wave_type = /datum/rogue_migrant_wave/zybantine_noble

/datum/rogue_migrant_role/adventurer
	name = "Adventurer"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/cleric,
		/datum/rockhill_advclass/cleric/cantor,
		/datum/rockhill_advclass/cleric/missionary,
		/datum/rockhill_advclass/cleric/paladin,
		/datum/rockhill_advclass/cleric/stigmata,
		/datum/rockhill_advclass/foreigner,
		/datum/rockhill_advclass/foreigner/aavnik,
		/datum/rockhill_advclass/foreigner/bluthund,
		/datum/rockhill_advclass/foreigner/bronzeclad,
		/datum/rockhill_advclass/foreigner/drow,
		/datum/rockhill_advclass/foreigner/dunewell,
		/datum/rockhill_advclass/foreigner/fencerguy,
		/datum/rockhill_advclass/foreigner/gronn,
		/datum/rockhill_advclass/foreigner/nostromo,
		/datum/rockhill_advclass/foreigner/refugee,
		/datum/rockhill_advclass/foreigner/repentant,
		/datum/rockhill_advclass/foreigner/shepherd,
		/datum/rockhill_advclass/foreigner/slaver,
		/datum/rockhill_advclass/foreigner/underdweller,
		/datum/rockhill_advclass/foreigner/yoruku,
		/datum/rockhill_advclass/mage,
		/datum/rockhill_advclass/mage/spellblade,
		/datum/rockhill_advclass/mage/spellsinger,
		/datum/rockhill_advclass/mage/spellthief,
		/datum/rockhill_advclass/noble,
		/datum/rockhill_advclass/noble/knighte,
		/datum/rockhill_advclass/noble/squire,
		/datum/rockhill_advclass/nudist,
		/datum/rockhill_advclass/ranger,
		/datum/rockhill_advclass/ranger/bombadier,
		/datum/rockhill_advclass/ranger/bwanderer,
		/datum/rockhill_advclass/ranger/wayfarer,
		/datum/rockhill_advclass/rogue,
		/datum/rockhill_advclass/rogue/bard,
		/datum/rockhill_advclass/rogue/swashbuckler,
		/datum/rockhill_advclass/rogue/thief,
		/datum/rockhill_advclass/sfighter,
		/datum/rockhill_advclass/sfighter/amazon,
		/datum/rockhill_advclass/sfighter/barbarian,
		/datum/rockhill_advclass/sfighter/duelist,
		/datum/rockhill_advclass/sfighter/ironclad,
		/datum/rockhill_advclass/sfighter/mhunter,
		)

/datum/rogue_migrant_role/crusader
	name = "117th Crusade-er"
	rockhill_advclasses = list(
		/datum/rockhill_advclass/crusader_Captain,
		/datum/rockhill_advclass/crusader_cleric,
		/datum/rockhill_advclass/crusader_footman,
		/datum/rockhill_advclass/crusader_marksman,
		/datum/rockhill_advclass/crusader_paladin,
		)

/datum/rogue_migrant_role/czwarteki_heir
	name = "Czwarteki Heir"
	greet_text = "You are the Czwarteki Lords Heir. Or perhaps one of many. Brought with you by your Parent to march forth on this venture. And to gain experience in the realms beyond your home."
	grant_lit_torch = TRUE
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/lupian", "/datum/species/demihuman")
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/czwarteki/heir,
		)

/datum/outfit/job/roguetown/rockhill_migrant/czwarteki_hussar
	name = "Czwarteki Hussar"
	jobtype = /datum/job/roguetown/rockhill_migrant
	cloak = /obj/item/clothing/cloak/tabard

/datum/rogue_migrant_role/czwarteki_hussar
	name = "Czwarteki Hussar"
	greet_text = "You are a Hussar of Czwarteki, under the oath of your lord. You have raised your Retainers to come with you to cross the lands. "
	grant_lit_torch = TRUE
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/lupian", "/datum/species/demihuman", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/anthromorph", "/datum/species/dracon", "/datum/species/tabaxi")
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/czwarteki/hussar,
		)
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/czwarteki_hussar

/datum/rogue_migrant_role/czwarteki_lord
	name = "Czwarteki Lord"
	greet_text = "You are one of many Lords within the Czwarteki Commonwealth, be it to have come for Diplomacy, War, or simple passing through to assist in old alliances. You are to lead your Retinue and bring honor to the Commonwealth. "
	grant_lit_torch = TRUE
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/lupian", "/datum/species/demihuman")
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/czwarteki/lord,
		)

/datum/outfit/job/roguetown/rockhill_migrant/czwarteki_retainer
	name = "Czwarteki Retainer"
	jobtype = /datum/job/roguetown/rockhill_migrant
	cloak = /obj/item/clothing/cloak/stabard/surcoat

/datum/rogue_migrant_role/czwarteki_retainer
	name = "Czwarteki Retainer"
	greet_text = "You are a Retainers of your Hussars. Called forth into action. You know well how to ride. And tend to your Hussars needs."
	grant_lit_torch = TRUE
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/czwarteki/retainer,
		)
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/czwarteki_retainer

/datum/rogue_migrant_role/czwarteki_servant
	name = "Czwarteki Servant"
	greet_text = "You are Servants of your Lord. Taken along upon the Journey through the realm with the Retinue. Your only goals are but to ensure your Lord and his Heir's well being upon the trip."
	grant_lit_torch = TRUE
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/czwarteki/servant,
		)

/datum/rogue_migrant_role/ea_hasir_guard
	name = "EA Hasir-ian Guard"
	greet_text = "The esteemed EA Hasir owns your gold company, Promising only the finest quality gold in grimoria You've been sent to guard his caravans and earn a tidy profit as you do."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/guard,
		)

/datum/rogue_migrant_role/ea_hasir_merchant
	name = "EA Hasir-ian Gold Merchant"
	greet_text = "The esteemed EA-Hasir owns your gold company, Promising only the finest quality gold in grimoria You've been sent with your caravan to sell golden riches and wonders- at a high price."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/merchantEA,
		)

/datum/outfit/job/roguetown/rockhill_migrant/fablefield_goliard
	name = "Fablefield Goliard"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/guitar
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	l_hand = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish
	r_hand = /obj/item/rogueweapon/sword/rapier/dec
	backpack_contents = list(
		/obj/item/book/rogue/tales1 = 1,
		/obj/item/book/rogue/blackmountain = 1,
		/obj/item/book/rogue/tales3 = 1,
		)

/datum/rogue_migrant_role/fablefield_goliard
	name = "Fablefield Goliard"
	greet_text = "For years you've travelled to Fablefield, honing your craft at the annual grand festival of tales. You are a respected weaver of glorious and valorous stories, with a tongue and wit as sharp as your blade. Of late, you've been obsessed with these lands in particular... What fantastical adventures could you embark on here, with your proteges?"
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/fablefield_goliard

/datum/outfit/job/roguetown/rockhill_migrant/fablefield_troubadour
	name = "Fablefield Troubadour"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/half/orange
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/sword/rapier
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_hand = /obj/item/rogue/instrument/lute
	backpack_contents = list(
		/obj/item/book/rogue/nitebeast = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/rogue_migrant_role/fablefield_troubadour
	name = "Fablefield Troubadour"
	greet_text = "At the last grand festival of tales in Fablefield, you were inspired by a figure who sung of dragons, faeries, gods and heroes. This year, you plan to be the hero of your own story. A talented bard, and good with a blade, you follow your muse with nothing but the highest hopes, although so far these lands aren't quite what you expected..."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/fablefield_troubadour

/datum/rogue_migrant_role/grenzel_bodyguard
	name = "Leibwächter"
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/grenzel_guard,
		)

/datum/rogue_migrant_role/grenzel_envoy
	name = "Envoy"
	greet_text = "You are a Grenzelhoftian envoy, traveling with bodyguards and a priest to represent your homeland. What exactly you have been sent here to speak about- only you know."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/grenzel_envoy,
		)

/datum/rogue_migrant_role/grenzel_priest
	name = "Envoy Priest"
	greet_text = "Nominally the envoy's spiritual advisor, your real power extends beyond religious matters. Protect interests of the Holy See of the Ten."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/grenzel_priest,
		)

/datum/outfit/job/roguetown/rockhill_migrant/gronn_chieftain
	name = "Gronn Chieftain"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/nomadpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	suit = /obj/item/clothing/suit/roguetown/armor/kurche
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	head = /obj/item/clothing/head/roguetown/helmet/nomadhelmet
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sheath/royal
	r_pocket = /obj/item/rogueweapon/stoneaxe/battle
	l_hand = /obj/item/quiver/arrows
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/rogue_migrant_role/gronn_chieftain
	name = "Gronn Chieftain"
	greet_text = "You are the leader of your tribe. Guide them to glory or try to survive."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/gronn_chieftain

/datum/outfit/job/roguetown/rockhill_migrant/gronn_shaman
	name = "Gronn Shaman"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/nomadpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	head = /obj/item/clothing/head/roguetown/hatfur
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/storage/belt/rogue/surgery_bag/full/improv
	backpack_contents = list(
		/obj/item/reagent_containers/glass/mortar = 1,
		/obj/item/pestle/rogue = 1,
		/obj/item/rogueweapon/handclaw/gronn = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/rogue_migrant_role/gronn_shaman
	name = "Gronn Shaman"
	greet_text = "The wisest and likely oldest of the tribe. You commune with Graggah and unleash powers of the divine. Tending as well to the wounded of the tribe."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/gronn_shaman

/datum/outfit/job/roguetown/rockhill_migrant/gronn_slave
	name = "Gronn Slave"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/nomadpants
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	l_pocket = /obj/item/storage/belt/rogue/pouch
	r_pocket = /obj/item/flint
	l_hand = /obj/item/rogueweapon/pick
	r_hand = /obj/item/rogueweapon/pitchfork

/datum/rogue_migrant_role/gronn_slave
	name = "Gronn Slave"
	greet_text = "An unlucky soul. Perhaps caught in a pillaging raid, or alone in the wilderness. You have been enslaved by the tribe. Work hard to appease your new masters."
	allowed_sexes = list(MALE, FEMALE)
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/gronn_slave

/datum/outfit/job/roguetown/rockhill_migrant/gronn_tribal
	name = "Gronn Tribal"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/nomadpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	suit = /obj/item/clothing/suit/roguetown/armor/leather/Huus_quyaq
	head = /obj/item/clothing/head/roguetown/hatfur
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut
	l_hand = /obj/item/rogueweapon/spear/bonespear
	backpack_contents = list(
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/rogue_migrant_role/gronn_tribal
	name = "Gronn Tribal"
	greet_text = "You are the bulk of the tribe. Skilled with either bow and axe. Or Spear. Well adapted to surviving off the land."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/gronn_tribal

/datum/outfit/job/roguetown/rockhill_migrant/gronn_warrior
	name = "Gronn Warrior"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/nomadpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale/steppe
	head = /obj/item/clothing/head/roguetown/helmet/nomadhelmet
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/rogueweapon/stoneaxe/handaxe
	r_hand = /obj/item/rogueweapon/halberd/bardiche
	backpack_contents = list(
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/rogue_migrant_role/gronn_warrior
	name = "Gronn Warrior"
	greet_text = "You are the elite, the best fighters of your tribe. You fight side by side with the Chieftain and ensure his survival."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/gronn_warrior

/datum/outfit/job/roguetown/rockhill_migrant/hammerhold_huscarl
	name = "Hammerholdian Huscarl"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/splintlegs/iron/gronn
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/gronn
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/atgervi/gronn/ownel
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain/gronn
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/atgervi
	l_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/steel/atgervi
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/rogue_migrant_role/hammerhold_huscarl
	name = "Hammerholdian Huscarl"
	greet_text = "You are a loyal and skilled bodyguard to your jarl, specialising in pillaging, kidnapping and fighting with an axe and shield."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi", "/datum/species/akula")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/hammerhold_huscarl

/datum/outfit/job/roguetown/rockhill_migrant/hammerhold_jarl
	name = "Hammerholdian Jarl"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/platelegs/iron/gronn
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/iron/gronn
	cloak = /obj/item/clothing/cloak/darkcloak/bear
	head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/gronn
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/atgervi
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron/gronn
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/mace/steel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/greataxe/steel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/rogue_migrant_role/hammerhold_jarl
	name = "Hammerholdian Jarl"
	greet_text = "You are a warrior-lord from Hammerhold and the leader of your warband. Guide them to glory and wealth or try to survive."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi", "/datum/species/akula")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/hammerhold_jarl

/datum/outfit/job/roguetown/rockhill_migrant/hammerhold_thrall
	name = "Hammerholdian Thrall"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/blue
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch
	r_pocket = /obj/item/flint
	l_hand = /obj/item/rogueweapon/pick
	r_hand = /obj/item/rogueweapon/pitchfork
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/rogue_migrant_role/hammerhold_thrall
	name = "Hammerholdian Thrall"
	greet_text = "An unlucky soul. Perhaps caught in a pillaging raid, or alone in the wilderness, you have been enslaved by the warband. Work hard to appease your new masters."
	allowed_sexes = list(MALE, FEMALE)
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/hammerhold_thrall

/datum/outfit/job/roguetown/rockhill_migrant/hammerhold_tideweaver
	name = "Hammerholdian Tideweaver"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk/blue
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/heavyhood/blue
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_pocket = /obj/item/storage/belt/rogue/surgery_bag/full/improv
	l_hand = /obj/item/rogueweapon/huntingknife/bronze
	r_hand = /obj/item/rogueweapon/spear/trident
	backpack_contents = list(
		/obj/item/reagent_containers/glass/mortar = 1,
		/obj/item/pestle/rogue = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/rogue_migrant_role/hammerhold_tideweaver
	name = "Hammerholdian Tideweaver"
	greet_text = "You are a cleric of the Lord of Abyss, devoted to him in prayer and arcyne. You have minor magical spells and medical knowledge in addition to your miracles, and can convert those shunned by the Holy See."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi", "/datum/species/akula")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/hammerhold_tideweaver

/datum/outfit/job/roguetown/rockhill_migrant/hammerhold_volfskin
	name = "Hammerholdian Volfskin"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather/gronn
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/gronn
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/atgervi/gronn
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/angle/gronn
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/steel/atgervi
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/steel/atgervi
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/reagent_containers/powder/moondust = 2,
		)

/datum/rogue_migrant_role/hammerhold_volfskin
	name = "Hammerholdian Volfskin"
	greet_text = "You are a volfskin, one of the legendary Hammerholdian warriors who are said to be possessed by raging volf spirits in battles. Distrusted due to your less than savoury religious practices, but well-respected for your combat prowess."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/tieberian", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/dwarf/mountain", "/datum/species/dracon", "/datum/species/tabaxi", "/datum/species/akula")
	rogue_wanderer_examine = FALSE
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/hammerhold_volfskin

/datum/rogue_migrant_role/heartfelt_hand
	name = "Hand of Heartfelt"
	grant_lit_torch = TRUE
	rogue_wanderer_examine = FALSE
	rogue_advjob_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/hand/advisor,
		/datum/rockhill_advclass/heartfelt/hand/marshal,
		/datum/rockhill_advclass/heartfelt/hand/steward,
		)

/datum/outfit/job/roguetown/rockhill_migrant/heartfelt_knight
	name = "Knight of Heartfelt"
	jobtype = /datum/job/roguetown/rockhill_migrant
	cloak = /obj/item/clothing/cloak/tabard

/datum/rogue_migrant_role/heartfelt_knight
	name = "Knight of Heartfelt"
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_wanderer_examine = FALSE
	rogue_advjob_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/knight,
		)
	outfit = /datum/outfit/job/roguetown/rockhill_migrant/heartfelt_knight

/datum/rogue_migrant_role/heartfelt_lord
	name = "Lord of Heartfelt"
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_wanderer_examine = FALSE
	rogue_advjob_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/lord/archmage,
		/datum/rockhill_advclass/heartfelt/lord/chief,
		/datum/rockhill_advclass/heartfelt/lord/lord,
		)

/datum/rogue_migrant_role/heartfelt_retinue
	name = "Heartfeltian Retinue"
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/heartfelt/retinue/armorer,
		/datum/rockhill_advclass/heartfelt/retinue/courtier,
		/datum/rockhill_advclass/heartfelt/retinue/housearb,
		/datum/rockhill_advclass/heartfelt/retinue/houseguard,
		/datum/rockhill_advclass/heartfelt/retinue/jester,
		/datum/rockhill_advclass/heartfelt/retinue/magos,
		/datum/rockhill_advclass/heartfelt/retinue/physician,
		/datum/rockhill_advclass/heartfelt/retinue/prior,
		/datum/rockhill_advclass/heartfelt/retinue/servant,
		/datum/rockhill_advclass/heartfelt/retinue/squire,
		)

/datum/rogue_migrant_role/kj_chaplain
	name = "Sworn Chaplain"
	greet_text = "You travel with a knight errant to look after their soul, and more often than not their wounds as well."
	rockhill_advclasses = list(
		/datum/rockhill_advclass/kj_chaplain,
		/datum/rockhill_advclass/kj_chaplain_stigmata,
		)

/datum/rogue_migrant_role/kj_follower
	name = "Sworn Follower"
	greet_text = "You serve a knight errant on the road. They handle the fighting, and you handle everything else that keeps them going."
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/kj_follower/campwright,
		/datum/rockhill_advclass/kj_follower/chirurgeon,
		/datum/rockhill_advclass/kj_follower/jongleur,
		/datum/rockhill_advclass/kj_follower/servitor,
		)

/datum/rogue_migrant_role/kj_knight
	name = "Hardened Knight Errant"
	greet_text = "Tourney fields, sieges and roadside ambushes: you have survived them all. Your squire has seen a few of those with you. Finish their training, and see them earn their spurs."
	rockhill_advclasses = list(
		/datum/rockhill_advclass/kj_knight,
		/datum/rockhill_advclass/kj_knight_outrider,
		)

/datum/rogue_migrant_role/kj_squire
	name = "Hardened Squire"
	greet_text = "You have served your knight for a few yils now. You can hold your own in a fight and keep their armor sound, but the accolade is still ahead of you."
	rockhill_advclasses = list(
		/datum/rockhill_advclass/kj_squire,
		/datum/rockhill_advclass/kj_squire_bidower,
		/datum/rockhill_advclass/kj_squire_hobelar,
		)

/datum/rogue_migrant_role/otavan_envoy
	name = "Émissaire"
	greet_text = "You are an Otavan Emissary, traveling with a small retinue and a Psydonite preacher to represent your homeland. What exactly you have been sent here to speak about- only you know."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/otavan_envoy,
		)

/datum/rogue_migrant_role/otavan_guard
	name = "Otavan Arbalétrier"
	greet_text = "With sharp eyes and a strong body, you are one of the many famous Heavy Crossbowmen that fill the ranks of the Otavan Principality. Keep the Emmisary safe, with sword and bolts."
	allowed_sexes = list(MALE, FEMALE)
	rockhill_advclasses = list(
		/datum/rockhill_advclass/otavan_guard,
		)

/datum/rogue_migrant_role/otavan_knight
	name = "Gendarme"
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/ooze")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/otavan_knight,
		)

/datum/rogue_migrant_role/otavan_preacher
	name = "Psydonite Preacher"
	greet_text = "A loyal member of the Psydonite Inquisition, you have mingled with politics long enough to become an active volunteer in assisting diplomatic missions and providing His sermon to wherever the Émissaire goes. Aid him, and make sure that he does not ignore His gospel."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/otavan_preacher,
		)

/datum/rogue_migrant_role/otavan_scribe
	name = "Otavan Scribe"
	greet_text = "Coin, quill, and words, these have defined your life since you were a mere youngling. Now? You are the renowned Scribe to this diplomatic mission's Emissary. Take notes, ask questions, and give funds when asked."
	allowed_sexes = list(MALE, FEMALE)
	rockhill_advclasses = list(
		/datum/rockhill_advclass/otavan_scribe,
		)

/datum/rogue_migrant_role/pilgrim
	name = "Pilgrim"
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

/datum/rogue_migrant_role/runaway_prisoner
	name = "Escaped Prisoner"
	grant_lit_torch = TRUE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/runaway_prisoner_commoner,
		/datum/rockhill_advclass/runaway_prisoner_mage,
		/datum/rockhill_advclass/runaway_prisoner_noble,
		)

/datum/rogue_migrant_role/slaver_master
	name = "Zybantynian Master"
	greet_text = "The leader of the Zybantynian slave troop. You have came to the mainlands from the western deserts of Zybantine in the hopes of gathering wealth through the training of and trade of unfortunate laborers. The practice can be called despicable by some, but it is without a doubt efficient in filling your pockets before you return to the deserts of the Zybantines"
	allowed_sexes = list(MALE, FEMALE)
	rockhill_advclasses = list(
		/datum/rockhill_advclass/slaver/master,
		)

/datum/rogue_migrant_role/slaver_slavemerc
	name = "Zybantynian Mercenary"
	greet_text = "A hired arm for the Zybantine Slave troop. You have come from the deserts of Zybantine and are hired under contract by the Zybantynian Master."
	allowed_sexes = list(MALE, FEMALE)
	rockhill_advclasses = list(
		/datum/rockhill_advclass/slaver/mercenary/blade,
		/datum/rockhill_advclass/slaver/mercenary/crossbow,
		/datum/rockhill_advclass/slaver/mercenary/whip,
		)

/datum/rogue_migrant_role/slaver_slavez
	name = "Slave"
	greet_text = "An unlucky slave, captured from their home, moved to the Zybantines and trained for slave labor and obediency, for long enough to where you can only faintly remember who you were before... You are now being transported from the deserts to harsher lands to be sold."
	allowed_sexes = list(MALE, FEMALE)
	grant_lit_torch = TRUE
	rogue_wanderer_examine = FALSE
	rockhill_advclasses = list(
		/datum/rockhill_advclass/slaver/slave/arcyne,
		/datum/rockhill_advclass/slaver/slave/battle,
		/datum/rockhill_advclass/slaver/slave/craftsman,
		/datum/rockhill_advclass/slaver/slave/service,
		)

/datum/rogue_migrant_role/zybantine_advisor
	name = "Advisor"
	greet_text = "You are the Emir's advisor and loyal protector."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/zybantine_advisor,
		)

/datum/rogue_migrant_role/zybantine_amirah
	name = "Amirah"
	allowed_sexes = list(FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/zybantine_amirah,
		)

/datum/rogue_migrant_role/zybantine_emir
	name = "Emir"
	greet_text = "You are an envoy from the zybantine Empire, traveling with bodyguards and your personal advisor to represent your homeland. What exactly you have been sent here to speak about- only you know."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/zybantine_emir,
		)

/datum/rogue_migrant_role/zybantine_janissary
	name = "Janissary Bodyguard"
	greet_text = "You are a dilligent soldier in employ of the Emir for protection and to assure that their mission goes as planned."
	allowed_sexes = list(MALE, FEMALE)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rockhill_advclasses = list(
		/datum/rockhill_advclass/zybantine_janissary,
		)
