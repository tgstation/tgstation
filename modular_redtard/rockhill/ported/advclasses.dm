/datum/outfit/job/roguetown/rockhill_class/arbalist
	name = "Arbalist"
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	cloak = /obj/item/clothing/cloak/psydontabard/alt
	head = /obj/item/clothing/head/roguetown/headband/bloodied
	mask = /obj/item/clothing/mask/rogue/sack/psy
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/stakebelt
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/arbalest
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/silver/stake/preblessed/psy
	r_pocket = /obj/item/quiver/heavybolts
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/grapplinghook = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/ammo_casing/caseless/rogue/heavy_bolt/tempest = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/arbalist
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/arbalist
	name = "Arbalist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/arbalist
	desc = "They'd pulled you from the line. To be a Confessor was your fate. Now? You're one of the Inquisitor's sharpest, of eye and steady hand alike. Armed with your beloved sauterelle, you'll drive back the dark. One stake at a time."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/arbalist
	rockhill_traits = list(
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/artificer
	name = "Tinkerer"
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

/datum/attribute_holder/sheet/job/rockhill_class/artificer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/blacksmithing = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/ceramics = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 30,
		/datum/attribute/skill/craft/masonry = 20,
		/datum/attribute/skill/craft/smelting = 30,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/artificer
	name = "Tinkerer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/artificer
	desc = "One of the brilliant minds that survived the disaster that befell Heartfelt. Perhaps you weren't able to prevent what happened in your homeland, but with your knowledge and skill, perhaps you can shape what happens from now on in your life as you venture towards a new beginning."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/artificer
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)
	maximum_slots = 5
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/barbersurgeon
	name = "Barber Surgeon"
	jobtype = /datum/job/roguetown/pilgrim
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

/datum/attribute_holder/sheet/job/rockhill_class/barbersurgeon
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 50,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 10,
		)

/datum/rockhill_advclass/barbersurgeon
	name = "Barber Surgeon"
	outfit = /datum/outfit/job/roguetown/rockhill_class/barbersurgeon
	desc = "Wielding crude tools and accumulated knowledge, you are something of a 'freelance physician' even if the local apothecary declined your application, and over the yils have probably cut into more people than the average knight."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/barbersurgeon
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_NOSTINK,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/baron/landed_knight
	name = "Landed Knight"
	jobtype = /datum/job/roguetown/baron
	uniform = /obj/item/clothing/under/roguetown/trou/formal
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/lordcloak/baronycloak
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/roguekey/manor
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	r_hand = /obj/item/rogueweapon/sword/sabre/dec
	backpack_contents = list(
		/obj/item/roguekey/baron = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/storage/keyring/baronretainer = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/baron/landed_knight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/baron/landed_knight
	name = "Landed Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/baron/landed_knight
	desc = "Rewarded with land for your noble service you have changed from wielding the sword to wielding the pen."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/baron/landed_knight
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		)

/datum/outfit/job/roguetown/rockhill_class/baron/shrewd_nobleman
	name = "Shrewd Nobleman"
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

/datum/attribute_holder/sheet/job/rockhill_class/baron/shrewd_nobleman
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		)

/datum/rockhill_advclass/baron/shrewd_nobleman
	name = "Shrewd Nobleman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/baron/shrewd_nobleman
	desc = "A noble in the most traditional sense, you use your wit and status to achieve your goals."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/baron/shrewd_nobleman
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		)

/datum/outfit/job/roguetown/rockhill_class/baron_retainer/duelist
	name = "Retired Duelist"
	jobtype = /datum/job/roguetown/baron_retainer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	shoes = /obj/item/clothing/shoes/roguetown/boots/maille
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/sword/noble
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/rondel
	r_pocket = /obj/item/rogueweapon/scabbard/sheath/noble
	backpack_contents = list(
		/obj/item/roguekey/baron = 1,
		/obj/item/storage/keyring/baronretainer = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/duelist
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/baron_retainer/duelist
	name = "Retired Duelist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/baron_retainer/duelist
	desc = "You flicked, you feinted, you pirouetted and striked - a mastery of the blade at a sword's edge. But the age of firearms came, and a crippling musket round to the knee ended your career. The Baron offered you a place in his service - perhaps, in due time, you can relive your glory daes."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/duelist
	rockhill_traits = list(
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_COMBAT_AWARE,
		TRAIT_INTELLECTUAL,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/baron_retainer/greyleaf
	name = "Greyleaf"
	jobtype = /datum/job/roguetown/baron_retainer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/wardencloak
	head = /obj/item/clothing/head/roguetown/helmet/sallet/warden/bear
	mask = /obj/item/clothing/head/roguetown/roguehood/warden
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/warden_machete
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/roguekey/baron = 1,
		/obj/item/storage/keyring/baronretainer = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/greyleaf
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 4,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/labor/butchering = 40,
		/datum/attribute/skill/labor/lumberjacking = 30,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/baron_retainer/greyleaf
	name = "Greyleaf"
	outfit = /datum/outfit/job/roguetown/rockhill_class/baron_retainer/greyleaf
	desc = "Honorably discharged from the warden corps, you have found new purpose in protecting the baron from the shadows and advising him on matters of Lowtown as someone who has shed blood to protect it."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/greyleaf
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_WOODWALKER,
		TRAIT_PERFECT_TRACKER,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/baron_retainer/henchman
	name = "Henchman"
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

/datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/henchman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/baron_retainer/henchman
	name = "Henchman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/baron_retainer/henchman
	desc = "A brute to back up the baron whenever needed, actions speak louder than words and you are the embodiment of this saying."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/baron_retainer/henchman
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/blacksmith
	name = "Blacksmith"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	cloak = /obj/item/clothing/cloak/apron/blacksmith
	mouth = /obj/item/rogueweapon/huntingknife
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/scabbard/sheath
	l_pocket = /obj/item/rogueweapon/tongs
	r_pocket = /obj/item/rogueweapon/hammer/iron
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/rogueore/coal = 4,
		/obj/item/rogueore/iron = 5,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/armor_brush = 1,
		/obj/item/polishing_cream = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/blacksmith
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 40,
		/datum/attribute/skill/craft/blacksmithing = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 20,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/weaponsmithing = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/blacksmith
	name = "Blacksmith"
	outfit = /datum/outfit/job/roguetown/rockhill_class/blacksmith
	desc = "A skilled blacksmith, able to forge capable weapons for warriors in the bog, only after building a forge for themselves of course"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/blacksmith
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/builder
	name = "Architect"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/apron/waist/bar
	head = /obj/item/clothing/head/roguetown/hatblu
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter
	l_pocket = /obj/item/rogueweapon/pick
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/rogueweapon/handsaw = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/handsaw = 1,
		/obj/item/dye_brush = 1,
		/obj/item/roguekey/crafterguild = 1,
		/obj/item/rogueweapon/blowrod = 1,
		/obj/item/clothing/mask/rogue/spectacles/golden = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/builder
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 40,
		/datum/attribute/skill/craft/ceramics = 40,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/engineering = 30,
		/datum/attribute/skill/craft/masonry = 40,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/lumberjacking = 30,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/builder
	name = "Architect"
	outfit = /datum/outfit/job/roguetown/rockhill_class/builder
	desc = "You are a skilled carpenter and mason working closely with the guild, you are able to manipulate wood and stone to suit your needs, building forts and stores, carpenting floors, putting up crosses and repairing broken doors. You can do it all with enough logs or rocks."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/builder
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_MASTER_CARPENTER,
		TRAIT_MASTER_MASON,
		TRAIT_LEGENDARY_MINER,
		)
	maximum_slots = 20
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/cheesemaker
	name = "Cheesemaker"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
	suit = /obj/item/clothing/suit/roguetown/armor/workervest
	cloak = /obj/item/clothing/cloak/apron
	head = /obj/item/clothing/head/roguetown/cookhat
	mouth = /obj/item/rogueweapon/huntingknife
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/flint
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_hand = /obj/item/flashlight/flare/torch
	backpack_contents = list(
		/obj/item/reagent_containers/powder/salt = 3,
		/obj/item/reagent_containers/food/snacks/rogue/cheddar = 2,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/reagent_containers/food/snacks/grown/wheat = 6,
		/obj/item/natural/cloth = 2,
		/obj/item/book/rogue/yeoldecookingmanual = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/cheesemaker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		)

/datum/rockhill_advclass/cheesemaker
	name = "Cheesemaker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cheesemaker
	desc = "Cheese cheese cheese! You have not just cheese itself, but the crucial beast from whence it comes As very skilled cook you come with some ingredients to make food and feed the masses. Take good care of your precious bovine companion, and she will reward you in kind."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cheesemaker
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 3
	rogue_horse = /mob/living/simple_animal/hostile/retaliate/rogue/cow

/datum/outfit/job/roguetown/rockhill_class/churchling
	name = "Churchling"
	jobtype = /datum/job/roguetown/churchling
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/shirt/robe
	neck = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather/rope
	l_pocket = /obj/item/storage/keyring/churchie

/datum/attribute_holder/sheet/job/rockhill_class/churchling
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		)

/datum/rockhill_advclass/churchling
	name = "Churchling"
	outfit = /datum/outfit/job/roguetown/rockhill_class/churchling
	desc = "Your family were zealots. They scolded you with a studded belt and prayed like sinners every waking hour of the day they weren't toiling in the fields. You escaped them by becoming a churchling--and a guaranteed education isn't so bad."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/churchling
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/churchling/neophyte
	name = "Neophyte"
	jobtype = /datum/job/roguetown/churchling
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	cloak = /obj/item/clothing/cloak/templar/astrata
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/churchie
	r_pocket = /obj/item/rogueweapon/sword/long
	r_hand = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/wood = 1,
		/obj/item/needle = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/churchling/neophyte
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/churchling/neophyte
	name = "Neophyte"
	outfit = /datum/outfit/job/roguetown/rockhill_class/churchling/neophyte
	desc = "You are a Templar-in-training, a prospective holy warrior of the Church with much to learn, and much more to prove. You've been given some hand-me-downs from the Church's armory, and the barest blessings of your chosen Divine."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/churchling/neophyte
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		)
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/abyssor, /datum/patron/divine/dendor, /datum/patron/divine/necra, /datum/patron/divine/malum, /datum/patron/divine/eora, /datum/patron/divine/ravox, /datum/patron/divine/xylix, /datum/patron/divine/pestra)

/datum/outfit/job/roguetown/rockhill_class/cleric
	name = "Monk"
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

/datum/attribute_holder/sheet/job/rockhill_class/cleric
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/cleric
	name = "Monk"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cleric
	desc = "You are a wandering acolyte, versed in both miracles and martial arts. You forego the hauberk that paladins wear in favor of humbling your foes through bloodless strikes. Your satchel hangs heavy, too, with ample provisions for the pilgrimage you're upon."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cleric
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/cleric/cantor
	name = "Cantor"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/templar/psydon
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/clothing/neck/roguetown/psicross
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/cleric/cantor
	raw_attribute_list = list(
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/cleric/cantor
	name = "Cantor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cleric/cantor
	desc = "You were a bard once - but you've found a new calling. Your eyes have been opened to the divine, now you wander from city to city singing songs and telling tales of your patron's greatness."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cleric/cantor
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_EMPATH,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/cleric/missionary
	name = "Missionary"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/woodstaff
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/cleric/missionary
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/cleric/missionary
	name = "Missionary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cleric/missionary
	desc = "You are a devout worshipper of the divine with a strong connection to your patron god. You've spent years studying scriptures and serving your deity - now you wander into foreign lands, spreading the word of your faith. Preachers focus on homesteading while Shepards preach through example and protecting their would-be flock."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cleric/missionary
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/cleric/paladin
	name = "Paladin"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/helmet/heavy/psydonbarbute
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	r_hand = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/metal = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/cleric/paladin
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/cleric/paladin
	name = "Paladin"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cleric/paladin
	desc = "You are a holy knight, clad in maille and armed with steel. Where others of the clergy may have spent their free time studying scriptures, you devoted yourself towards fighting Psydonia's evils - a longsword in one hand, and a clenched psycross in the other."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cleric/paladin
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/cleric/stigmata
	name = "Stigmata"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/storage/belt/rogue/pouch/medicine = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/cleric/stigmata
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 5,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/cleric/stigmata
	name = "Stigmata"
	outfit = /datum/outfit/job/roguetown/rockhill_class/cleric/stigmata
	desc = "PSYDON weeps. You are a devout cleric of the Allfather whom takes the suffering of others upon themselves. You have eschewn violence. You will suffer. You will endure."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/cleric/stigmata
	rockhill_traits = list(
		TRAIT_PACIFISM,
		TRAIT_EMPATH,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_STEELHEARTED,
		TRAIT_SELF_AWARE,
		TRAIT_LUX_FREAK,
		TRAIT_RITUALIST,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/confessor
	name = "Confessor"
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/confessor
	cloak = /obj/item/storage/backpack/rogue/satchel/beltpack
	head = /obj/item/clothing/head/roguetown/roguehood/psydon/confessor
	mask = /obj/item/clothing/mask/rogue/facemask/steel/confessor
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow
	l_pocket = /obj/item/quiver/bolts
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	l_hand = /obj/item/rogueweapon/huntingknife/idagger/silver/psydagger
	r_hand = /obj/item/rogueweapon/scabbard/sheath
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/clothing/head/inqarticles/blackbag = 1,
		/obj/item/inqarticles/garrote = 1,
		/obj/item/grapplinghook = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/confessor
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 50,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/stealing = 50,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/confessor
	name = "Confessor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/confessor
	desc = "Psydonite hunters, unmatched in the fields of subterfuge and investigation. There is no suspect too powerful to investigate, no room too guarded to infiltrate, and no weakness too hidden to exploit."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/confessor
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_BLACKBAGGER,
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		TRAIT_PURITAN_ADVENTURER,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/councillor
	name = "Councillor"
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

/datum/attribute_holder/sheet/job/rockhill_class/councillor
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/councillor
	name = "Councillor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/councillor
	desc = "You may have inherited this position, bought your way into it, or were appointed to it by merit--perish the thought! Whatever the case though, you work as an assistant and agent of the crown in matters of state. Whether this be aiding the steward, the sheriff, or the crown itself, or simply enjoying the free food of the keep, your duties vary day by day. You may be the lowest rung of the ladder, but that rung still towers over everyone else in town."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/councillor
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES_SHITTY,
		)

/datum/outfit/job/roguetown/rockhill_class/councillor/huntmaster
	name = "Huntmaster"
	jobtype = /datum/job/roguetown/councillor
	uniform = /obj/item/clothing/under/roguetown/trou/beltpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/heavyhood
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/roguekey/manor
	r_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/hunting_map/white_stag = 1,
		/obj/item/hunting_map/boars = 1,
		/obj/item/storage/keyring = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/councillor/huntmaster
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/hunting = 50,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/councillor/huntmaster
	name = "Huntmaster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/councillor/huntmaster
	desc = "You organize hunts for the crown. You know the woods, the quarry, and how to keep a hunting party alive."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/councillor/huntmaster
	rockhill_traits = list(
		TRAIT_MASTERFUL_HUNTER,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_NOBLE,
		TRAIT_SEEPRICES_SHITTY,
		)

/datum/outfit/job/roguetown/rockhill_class/crusader_Captain
	name = "Crusader Captain"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/platelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/fluted
	cloak = /obj/item/clothing/cloak/cape/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/crusader
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_hand = /obj/item/rogueweapon/sword/long/kriegmesser/silver
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/crusader_Captain
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 50,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/crusader_Captain
	name = "Crusader Captain"
	outfit = /datum/outfit/job/roguetown/rockhill_class/crusader_Captain
	desc = "Crusader Leader of the true faith, you came from Grenzelhoft on the orders of the holy see. FIND Psydon's holy chalice- and pillage your way into riches, for the glory of astrata!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/crusader_Captain
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_BREADY,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_subclass_languages = list("/datum/language/grenzelhoftian", "/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/crusader_cleric
	name = "Crusader Cleric"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/cloak/tabard/crusader/astrata
	cloak = /obj/item/clothing/cloak/cape/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/crusader
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/storage/belt/rogue/surgery_bag/full
	r_hand = /obj/item/rogueweapon/sword
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 3,
		/obj/item/needle/pestra = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/crusader_cleric
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 50,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/crusader_cleric
	name = "Crusader Cleric"
	outfit = /datum/outfit/job/roguetown/rockhill_class/crusader_cleric
	desc = "Crusader of the true faith, you came from Grenzelhoft on the orders of the holy see. FIND Psydon's holy chalice- and pillage your way into riches, for the glory of astrata!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/crusader_cleric
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/crusader_footman
	name = "Crusader Footman"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted
	cloak = /obj/item/clothing/cloak/cape/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/crusader
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/spear/boar
	r_hand = /obj/item/rogueweapon/sword/short
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/crusader_footman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/crusader_footman
	name = "Crusader Footman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/crusader_footman
	desc = "Heavily armored Crusader of the true faith, you came from Grenzelhoft on the orders of the holy see. FIND Psydon's holy chalice- and pillage your way into riches, for the glory of astrata!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/crusader_footman
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/crusader_marksman
	name = "Crusader Marksman"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/cloak/tabard/crusader/astrata
	cloak = /obj/item/clothing/cloak/cape/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/crusader
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/quiver/bolts
	l_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	r_hand = /obj/item/rogueweapon/sword/short
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/crusader_marksman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/crusader_marksman
	name = "Crusader Marksman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/crusader_marksman
	desc = "Crusader of the true faith, you came from Grenzelhoft on the orders of the holy see. FIND Psydon's holy chalice- and pillage your way into riches, for the glory of astrata!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/crusader_marksman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/crusader_paladin
	name = "Crusader Paladin"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/armor/plate/fluted
	cloak = /obj/item/clothing/cloak/cape/crusader
	head = /obj/item/clothing/head/roguetown/helmet/heavy/crusader
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_hand = /obj/item/rogueweapon/sword/decorated
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/crusader_paladin
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/crusader_paladin
	name = "Crusader Paladin"
	outfit = /datum/outfit/job/roguetown/rockhill_class/crusader_paladin
	desc = "Crusader of the true faith, you came from Grenzelhoft on the orders of the holy see. FIND Psydon's holy chalice- and pillage your way into riches, for the glory of astrata!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/crusader_paladin
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_subclass_languages = list("/datum/language/grenzelhoftian", "/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/czwarteki/heir
	name = "Czwarteki Heir"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate
	head = /obj/item/clothing/head/roguetown/nyle/consortcrown
	neck = /obj/item/clothing/neck/roguetown/bevor
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	l_hand = /obj/item/rogueweapon/sword/sabre/dec
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/czwarteki/heir
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/czwarteki/heir
	name = "Czwarteki Heir"
	outfit = /datum/outfit/job/roguetown/rockhill_class/czwarteki/heir
	desc = "You are the Czwarteki Lords Heir. Or perhaps one of many. Brought with you by your Parent to march forth on this venture. And to gain experience in the realms beyond your home."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/czwarteki/heir
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/czwarteki/hussar
	name = "Czwarteki Hussar"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/platelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/hussar
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	head = /obj/item/clothing/head/roguetown/helmet/sallet/hussarhelm
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	l_hand = /obj/item/rogueweapon/sword/sabre
	r_hand = /obj/item/rogueweapon/spear/lance
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/czwarteki/hussar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		)

/datum/rockhill_advclass/czwarteki/hussar
	name = "Czwarteki Hussar"
	outfit = /datum/outfit/job/roguetown/rockhill_class/czwarteki/hussar
	desc = "You are a Hussar of Czwarteki, under the oath of your lord. You have raised your Retainers to come with you to cross the lands."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/czwarteki/hussar
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/czwarteki/lord
	name = "Czwarteki Lord"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/platelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	suit = /obj/item/clothing/suit/roguetown/armor/plate/hussar
	cloak = /obj/item/clothing/cloak/lepoardcloak
	head = /obj/item/clothing/head/roguetown/helmet/sallet/hussarhelm
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/rogueweapon/scabbard/sheath/noble
	l_hand = /obj/item/rogueweapon/sword/long/marlin
	r_hand = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/czwarteki/lord
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/czwarteki/lord
	name = "Czwarteki Lord"
	outfit = /datum/outfit/job/roguetown/rockhill_class/czwarteki/lord
	desc = "You are one of many Lords within the Czwarteki Commonwealth, be it to have come for Diplomacy, War, or simple passing through to assist in old alliances. You are to lead your Retinue and bring honor to the Commonwealth."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/czwarteki/lord
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/czwarteki/retainer
	name = "Czwarteki Retainer"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/sabre
	r_hand = /obj/item/rogueweapon/spear
	backpack_contents = list(
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/czwarteki/retainer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/weaponsmithing = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/czwarteki/retainer
	name = "Czwarteki Retainer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/czwarteki/retainer
	desc = "You are a Retainer of your Hussar. Called forth into action. You know well how to ride. And tend to your Hussars needs."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/czwarteki/retainer
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/czwarteki/servant
	name = "Czwarteki Servant"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/formal/shorts
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	r_pocket = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 2,
		/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette = 2,
		/obj/item/reagent_containers/food/snacks/rogue/crackerscooked = 2,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/reagent_containers/glass/cup/silver = 2,
		/obj/item/reagent_containers/glass/bottle/rogue/beer/avarrice = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer/avarmead = 1,
		/obj/item/soap/bath = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/cooking/pan = 1,
		/obj/item/needle = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/czwarteki/servant
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/czwarteki/servant
	name = "Czwarteki Servant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/czwarteki/servant
	desc = "You are Servants of your Lord. Taken along upon the Journey through these lands with the Retinue. Your only goals are but to ensure your Lord and his Heir's well being upon the trip."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/czwarteki/servant
	rockhill_traits = list(
		TRAIT_SLEUTH,
		TRAIT_KEENEARS,
		TRAIT_CICERONE,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/disciple
	name = "Disciple"
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	suit = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/disciple
	cloak = /obj/item/clothing/cloak/psydontabard/alt
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	wrists = /obj/item/clothing/wrists/roguetown/bracers/psythorns
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/disciple
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/disciple
	name = "Disciple"
	outfit = /datum/outfit/job/roguetown/rockhill_class/disciple
	desc = "Psydonite monks, practiced in both martiality and scripture. Spilling blood on sacred grounds is considered 'sinful' to the clergymen, though no qualms are spared towards knocking someone's lights out."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/disciple
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_CICERONE,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/drunkard
	name = "Gambler"
	jobtype = /datum/job/roguetown/villager
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flint
	r_pocket = /obj/item/clothing/mask/cigarette/rollie/cannabis
	backpack_contents = list(
		/obj/item/storage/pill_bottle/dice = 1,
		/obj/item/storage/pill_bottle/dice/farkle = 1,
		/obj/item/reagent_containers/glass/cup = 1,
		/obj/item/toy/cards/deck = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/wine = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/drunkard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/drunkard
	name = "Gambler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/drunkard
	desc = "You are a gambler. Everyone in your life has given up on you, and the stress of losing it all over and over has taken its toll on your body. All you have left to your name are some cards, dice and whatever is in this bottle. At least you're still in Baotha's good graces, whether you reciprocate such feelings or not..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/drunkard
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_CRACKHEAD,
		)
	maximum_slots = 20

/datum/outfit/job/roguetown/rockhill_class/fisher
	name = "Fisher"
	jobtype = /datum/job/roguetown/pilgrim

/datum/attribute_holder/sheet/job/rockhill_class/fisher
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/fisher
	name = "Fisher"
	outfit = /datum/outfit/job/roguetown/rockhill_class/fisher
	desc = "You are a fisherman, with your bag of bait and your fishing rod, you are one of few who can reliably get a stable source of meat around here"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/fisher
	rockhill_traits = list(
		TRAIT_CAUTIOUS_FISHER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/foreigner
	name = "Eastern Warrior"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
	suit = /obj/item/clothing/suit/roguetown/armor/basiceast/mentorsuit
	head = /obj/item/clothing/head/roguetown/mentorhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/spear/naginata
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/foreigner
	name = "Eastern Warrior"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner
	desc = "A warrior hailing from the distant land of Kazengun, far across the eastern sea."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_NOPAINSTUN,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/ooze")
	rogue_subclass_languages = list("/datum/language/kazengunese")

/datum/outfit/job/roguetown/rockhill_class/foreigner/aavnik
	name = "Aavnik Nitkov"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/steppe
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	head = /obj/item/clothing/head/roguetown/papakha
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot/steppesman
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/quiver/arrows
	r_pocket = /obj/item/quiver/javelin/iron
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/steppesman
	backpack_contents = list(
		/obj/item/tent_kit/ger = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/scabbard/sheath/aavnik = 1,
		/obj/item/rogueweapon/whip/nagaika = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/aavnik
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/foreigner/aavnik
	name = "Aavnik Nitkov"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/aavnik
	desc = "A niktov. The slang for one who's done much, against both common good and their fellow man. You're a brigand, of some sort. Perhaps not known, or violent in the same nature as all the others. Yet, all the same, you're outcast from the people you'd once called your own. What could you have done for them to toss you aside? Where had you failed?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/aavnik
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/foreigner/bluthund
	name = "Grenzelhoft Bluthund"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/greatsword/grenz
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/bluthund
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/foreigner/bluthund
	name = "Grenzelhoft Bluthund"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/bluthund
	desc = "Grenzelhoftian mercenaries are one of a kind. In a world of cheats, blaggards and broken oaths? They stand firm. A guild of individuals who, once under contract, will follow it to the letter. For some reason, whether glory or madness, you'd gone against that. Branded an outcast - a 'bluthund'. You yet retain your equipment, for they could not strip that of you. Unlike your titles."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/bluthund
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/foreigner/bronzeclad
	name = "Thespian-Errant"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/skirt/red
	suit = /obj/item/clothing/suit/roguetown/armor/plate/bronze/light
	head = /obj/item/clothing/head/roguetown/headband/red
	mask = /obj/item/clothing/mask/rogue/facemask/bronze
	wrists = /obj/item/clothing/wrists/roguetown/bracers/bronze
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/bronze
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/quiver/javelin/bronze
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/long/broadsword/bronze
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/combat/bronze = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/bronzeclad
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/bronzeclad
	name = "Thespian-Errant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/bronzeclad
	desc = "Gladiators from the arenas of Zybant and Etrusca, reenactors from the curtain-dazzled courts of Otava and Grenzelhoft, and shieldbearers from the outermost reaches of Psydonia itself; all are unified in their subconscious pursuit of entertaining something greater than themselves. You are a skilled combatant from beyond Ferentia, who - for one reason or another - is intimately familiar with fighting in ancient equipment."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/bronzeclad
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 3
	rogue_subclass_languages = list("/datum/language/etruscan")

/datum/outfit/job/roguetown/rockhill_class/foreigner/drow
	name = "Crocs de l'araignée Débroussaillage"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shadowpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/shadowrobe
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/shadowvest
	cloak = /obj/item/clothing/cloak/shadowcloak
	head = /obj/item/clothing/neck/roguetown/chaincoif/full/black
	mask = /obj/item/clothing/mask/rogue/shepherd/shadowmask/delf
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/fingerless/shadowgloves/elflock
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	r_pocket = /obj/item/quiver/bolts/
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow/stalker/lesser
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/dirk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/drow
	raw_attribute_list = list(
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/drow
	name = "Crocs de l'araignée Débroussaillage"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/drow
	desc = "The Crocs de l'araignée, translated literally to mean \"Spider's Teeth\", is a renowned collective of blades, whips, and riders for hire often employed in the vast drow undercity complexes and occasionally the surface above. You are at the bottom of this proud sorority of sadists. Prior to full-membership, aspiriants like yourself must prove themselves before their undercity's guild matriarch. While formally called Auxiliaire, the pejorative Débroussaillage, translated as \"Weed Trimmings\", is the far more common title given how few succeed - let alone survive - the grueling recruitment period."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/drow
	rockhill_traits = list(
		TRAIT_DARKVISION,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/human/halfelf")
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/foreigner/dunewell
	name = "Dunewell Nomad"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/splintlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/nomad
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/nomad
	cloak = /obj/item/clothing/cloak/cape/nomad
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/nomad
	mask = /obj/item/clothing/mask/rogue/ragmask/nomad
	neck = /obj/item/clothing/neck/roguetown/coif/padded/nomad
	gloves = /obj/item/clothing/gloves/roguetown/bandages
	wrists = /obj/item/clothing/wrists/roguetown/splintarms/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/rogueweapon/scabbard/gwstrap
	backr = /obj/item/rogueweapon/shield/iron/nomad
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/reagent_containers/glass/bottle/waterskin
	r_hand = /obj/item/rogueweapon/spear/nomad
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/dunewell
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/foreigner/dunewell
	name = "Dunewell Nomad"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/dunewell
	desc = "Dunewell, deep in the Zybantine deserts, is a place of madness. A region of faith and heresy alike. For yils, many have fought over the riches and ruins of the old Psydonian holdout. Those who come from it are typically nomads of either party. Missionary and killer, one in the same. To have ventured as far as Ferentia, you've either escaped the cycle, or intend to repeat it."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/dunewell
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		"Token of Home" = /obj/item/clothing/neck/roguetown/psicross,
		)

/datum/outfit/job/roguetown/rockhill_class/foreigner/fencerguy
	name = "Foreign Fencer"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	neck = /obj/item/clothing/neck/roguetown/fencerguard/generic
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/long/fencerguy
	r_hand = /obj/item/rogueweapon/huntingknife/combat
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/fencerguy
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 30,
		)

/datum/rockhill_advclass/foreigner/fencerguy
	name = "Foreign Fencer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/fencerguy
	desc = "You're an itinerant weapons expert that was trained in a Grenzelhoftian fencing school, carrying with you your weapon, your skillset, your pride... And not much else, frankly."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/fencerguy
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_FENCERDEXTERITY,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/foreigner/gronn
	name = "Gronnic Itinerant"
	jobtype = /datum/job/roguetown/adventurer
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
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/gronn
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/gronn
	name = "Gronnic Itinerant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/gronn
	desc = "Whether separated from your clan, or otherwise cast aside? You've found your way to Ferentia. Bound by blood oaths, violence and any other matter of mania that follows your people, how will you possibly adapt? Perhaps, if another chief were to find you..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/gronn
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/gronnic")

/datum/outfit/job/roguetown/rockhill_class/foreigner/nostromo
	name = "Etruscan Nostromo"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	cloak = /obj/item/clothing/cloak/half/rider/red
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/buckler
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_hand = /obj/item/rogueweapon/sword/rapier/vaquero
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/nostromo
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/foreigner/nostromo
	name = "Etruscan Nostromo"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/nostromo
	desc = "Nostromo, a word torn from the common Etruscan tongue, butchered by Imperial. The meaning it had is long since lost to the common man. You're neither swashbuckler nor romantic. For you are no hero. To be branded 'Nostromo', is to lose your lot. To be known as one who prattles, rather than using their sword. Perhaps you were a great captain? A joyous sailor, in better yils? It hardly matters, now. Forge a new name."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/nostromo
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_GOODLOVER,
		TRAIT_INTELLECTUAL,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/etruscan")

/datum/outfit/job/roguetown/rockhill_class/foreigner/refugee
	name = "Naledi Refugee"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/skirt/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant/civilian
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/black
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/footwraps/padded
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/spear/assegai
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/refugee
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/refugee
	name = "Naledi Refugee"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/refugee
	desc = "An asylum-seeker or descendant thereof from the war-torn ruins of Naledi. The Fall of Naledi robbed you of your future, though fragments  of Naledi remain in what little training you carry."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/refugee
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_NALEDI,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/foreigner/repentant
	name = "Otavan Repentant"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/mask/rogue/facemask/ancient/mad_touched
	gloves = /obj/item/clothing/gloves/roguetown/chain/psydon
	wrists = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/rogueweapon/whip
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/repentant
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/repentant
	name = "Otavan Repentant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/repentant
	desc = "An exile from the Holy See of Otava, accused of heresy and cast out of your homeland as penance. Some consider yours a fate worse than death; the metal alloy mask seared onto your face serving as a permanent reminder of your sins. You are a living example of what becomes of those who stand in defiance of the Otavan inquisition."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/repentant
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/foreigner/shepherd
	name = "Szöréndnížine Shepherd"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/shepherd
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter/shepherd
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/shepherd
	head = /obj/item/clothing/head/roguetown/chaperon/greyscale/shepherd
	mask = /obj/item/clothing/head/roguetown/paddedcap
	neck = /obj/item/clothing/neck/roguetown/psicross/reform
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft/freifechter
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/rogueweapon/stoneaxe/battle/steppesman/chupa
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/navaja/freifechter
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/shepherd
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		)

/datum/rockhill_advclass/foreigner/shepherd
	name = "Szöréndnížine Shepherd"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/shepherd
	desc = "You're a simple shepherd hailing from Aavnr's Free City of Czwarteka, taking a pilgrimage or having fled for one reason or another. You can easily fend for yourself in the wilderness, and with enough practice, fend for yourself in combat against even armoured opponents with your traditional axe."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/shepherd
	rockhill_traits = list(
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/foreigner/slaver
	name = "Zybantine Slaver"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/purple
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	cloak = /obj/item/clothing/cloak/cape/purple
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/purple
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal/purple
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/heater
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/sword/long/shotel
	backpack_contents = list(
		/obj/item/rope/chain = 2,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/slaver
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/foreigner/slaver
	name = "Zybantine Slaver"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/slaver
	desc = "In parts of Psydonia, the practice of slavery is still a common sight. You hail from the Zybantine Empire, where the market of flesh is ancient and unbroken, and your coin is earned in the trade of living souls."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/slaver
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/foreigner/underdweller
	name = "Underdweller"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	head = /obj/item/clothing/head/roguetown/helmet/kettle/minershelm
	mask = /obj/item/clothing/mask/rogue/ragmask
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/shield/wood
	l_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/pick
	r_pocket = /obj/item/storage/detpack
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/underdweller
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/craft/smelting = 20,
		/datum/attribute/skill/labor/mining = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/foreigner/underdweller
	name = "Underdweller"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/underdweller
	desc = "A member of the Underdwellers, you've taken many of the deadliest contracts known to man in literal underground circles. Drow or Dwarf, you've put your differences aside for coin and adventure."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/underdweller
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_WEBWALK,
		TRAIT_EXPLOSIVE_SUPPLY,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_LEGENDARY_MINER,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dwarf/mountain", "/datum/species/dwarf/gnome", "/datum/species/elf/dark", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/anthromorphsmall", "/datum/species/moth")
	rogue_subclass_languages = list("/datum/language/kazengunese")

/datum/outfit/job/roguetown/rockhill_class/foreigner/yoruku
	name = "Eastern Assassin"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
	cloak = /obj/item/clothing/cloak/thief_cloak/yoruku
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/yoruku
	mask = /obj/item/clothing/mask/rogue/facemask/yoruku_oni
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/kazengun
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sheath/kazengun
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/kazengun
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/bomb/smoke = 3,
		)

/datum/attribute_holder/sheet/job/rockhill_class/foreigner/yoruku
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/foreigner/yoruku
	name = "Eastern Assassin"
	outfit = /datum/outfit/job/roguetown/rockhill_class/foreigner/yoruku
	desc = "The Yoruku are Kazengun agents trained in assassination, sabotage, and irregular combat. You are armed with daggers or a short sword, perfect for combat in the tight confines of castles and back alleys."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/foreigner/yoruku
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DODGEEXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/ooze")
	rogue_subclass_languages = list("/datum/language/kazengunese")

/datum/outfit/job/roguetown/rockhill_class/grenzel_envoy
	name = "Envoy"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/stabard/surcoat/bailiff
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	l_hand = /obj/item/rogueweapon/sword/long
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/paper/scroll/writ_of_esteem/grenzel = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/grenzel_envoy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/grenzel_envoy
	name = "Envoy"
	outfit = /datum/outfit/job/roguetown/rockhill_class/grenzel_envoy
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/grenzel_envoy
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/grenzel_guard
	name = "Leibwächter"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/plate/blacksteel_halfplate
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/greatsword/grenz
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/grenzel_guard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/grenzel_guard
	name = "Leibwächter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/grenzel_guard
	desc = "You are a dilligent soldier in employ of the Envoy for protection and to assure that their mission goes as planned."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/grenzel_guard
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/grenzel_priest
	name = "Envoy Priest"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	cloak = /obj/item/clothing/cloak/chasuble
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/grenzel_priest
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 60,
		)

/datum/rockhill_advclass/grenzel_priest
	name = "Envoy Priest"
	outfit = /datum/outfit/job/roguetown/rockhill_class/grenzel_priest
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/grenzel_priest
	rockhill_traits = list(
		TRAIT_CHOSEN,
		TRAIT_RITUALIST,
		TRAIT_SOUL_EXAMINE,
		TRAIT_GRAVEROBBER,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_MEDICINE_EXPERT,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/guard
	name = "EA Hasir-ian Guard"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/splintlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/wood
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_hand = /obj/item/rogueweapon/sword/falchion

/datum/attribute_holder/sheet/job/rockhill_class/guard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/guard
	name = "EA Hasir-ian Guard"
	outfit = /datum/outfit/job/roguetown/rockhill_class/guard
	desc = "You're a caravan guard, used to dealing with your average thief and the occasional bandit raid. EA-Hasir is a reliable employer, and you're guarding a rather high value merchant Keep them alive, and you may get paid enough to take a much needed break."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/guard
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_BREADY,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/guildsman/artificer
	name = "Artificer"
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

/datum/attribute_holder/sheet/job/rockhill_class/guildsman/artificer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/armorsmithing = 20,
		/datum/attribute/skill/craft/blacksmithing = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/ceramics = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 50,
		/datum/attribute/skill/craft/masonry = 20,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/weaponsmithing = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/guildsman/artificer
	name = "Artificer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/guildsman/artificer
	desc = "You are an Artificer, oft known by the longer name of Artificer-Enchanter. You have basic training in the arts of smithing, and can substitute for a blacksmith's work if needed. But your true calling is the creation and enchantment of magical items, alongside feats of engineering, creating mechanical and magical wonders whose art of creation has been passed down from a certain elven Artificer..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/guildsman/artificer
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/guildsman/blacksmith
	name = "Guild Blacksmith"
	jobtype = /datum/job/roguetown/guildsman
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	cloak = /obj/item/clothing/cloak/apron/blacksmith
	head = /obj/item/clothing/head/roguetown/hatblu
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/roguekey/crafterguild
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/tongs = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/mini_flagpole/blacksmith = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/guildsman/blacksmith
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 50,
		/datum/attribute/skill/craft/blacksmithing = 50,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/engineering = 20,
		/datum/attribute/skill/craft/smelting = 50,
		/datum/attribute/skill/craft/weaponsmithing = 50,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/guildsman/blacksmith
	name = "Guild Blacksmith"
	outfit = /datum/outfit/job/roguetown/rockhill_class/guildsman/blacksmith
	desc = "You've studied for many yils under quite a number of master smiths. Whether it's cookware or tools of war, you're unmatched at the art of bending metal to your will."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/guildsman/blacksmith
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/guildsman/engineer
	name = "Guild Engineer"
	jobtype = /datum/job/roguetown/guildsman
	uniform = /obj/item/clothing/under/roguetown/trou/artipants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/artificer
	suit = /obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket
	cloak = /obj/item/clothing/cloak/apron/waist/brown
	head = /obj/item/clothing/head/roguetown/articap
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/pick/steel
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/rogueweapon/handsaw = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/recipe_book/engineering = 1,
		/obj/item/recipe_book/ceramics = 1,
		/obj/item/recipe_book/builder = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/contraption/linker = 1,
		/obj/item/mini_flagpole/artificer = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/mini_flagpole/blacksmith = 1,
		/obj/item/rogueweapon/blowrod = 1,
		/obj/item/dye_brush = 1,
		/obj/item/roguekey/crafterguild = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/flint = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/guildsman/engineer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/firearms = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/armorsmithing = 30,
		/datum/attribute/skill/craft/blacksmithing = 30,
		/datum/attribute/skill/craft/carpentry = 40,
		/datum/attribute/skill/craft/ceramics = 40,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/engineering = 50,
		/datum/attribute/skill/craft/masonry = 40,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/weaponsmithing = 30,
		/datum/attribute/skill/labor/lumberjacking = 30,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/guildsman/engineer
	name = "Guild Engineer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/guildsman/engineer
	desc = "You are an engineer, Once trained under architects and artificers you now have the experience to surpass them both. Your calling is the works of artificing and architecture, be it smithing, constructing or the arcane machinery you do it all, your experience demands respect."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/guildsman/engineer
	rockhill_traits = list(
		TRAIT_MASTER_CARPENTER,
		TRAIT_MASTER_MASON,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_FUSILIER,
		TRAIT_LEGENDARY_MINER,
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/hand/advisor
	name = "Advisor"
	jobtype = /datum/job/roguetown/hand
	uniform = /obj/item/clothing/under/roguetown/tights/black
	head = /obj/item/clothing/head/roguetown/chaperon/noble/hand
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/dtace
	r_pocket = /obj/item/rogueweapon/scabbard/sheath/courtphysician/hand
	r_hand = /obj/item/rogueweapon/sword/rapier/hand
	backpack_contents = list(
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/keyring/lord = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/hand/advisor
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/arcyne = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/staves = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/hand/advisor
	name = "Advisor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/hand/advisor
	desc = " You have played researcher and confidant to the Noble-Family for so long that you are a vault of knowledge, something you exploit with potent conviction. Let no man ever forget the knowledge you wield. You've read more books than any blademaster or spymaster could ever claim to."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/hand/advisor
	rockhill_traits = list(
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_ARCYNE,
		TRAIT_NOBLE,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_PERCEPTION = 1, ROGUE_STAT_INTELLIGENCE = 1, ROGUE_STAT_STRENGTH = -1, ROGUE_STAT_SPEED = -1),
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/hand/blademaster
	name = "Blademaster"
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

/datum/attribute_holder/sheet/job/rockhill_class/hand/blademaster
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = 2,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 10,
		)

/datum/rockhill_advclass/hand/blademaster
	name = "Blademaster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/hand/blademaster
	desc = "You have played blademaster and strategist to the Noble-Family for so long that you are a master tactician, something you exploit with potent conviction. Let no man ever forget whose ear you whisper into. You've killed more men with swords than any spymaster could ever claim to."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/hand/blademaster
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/hand/spymaster
	name = "Spymaster"
	jobtype = /datum/job/roguetown/hand
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/short
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/dtace = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/storage/keyring/hand = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/hand/spymaster
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/lockpicking = 50,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/stealing = 50,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/hand/spymaster
	name = "Spymaster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/hand/spymaster
	desc = " You have played spymaster and confidant to the Noble-Family for so long that you are a vault of intrigue, something you exploit with potent conviction. Let no man ever forget whose ear you whisper into. You've killed more men with those lips than any blademaster could ever claim to."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/hand/spymaster
	rockhill_traits = list(
		TRAIT_KEENEARS,
		TRAIT_DODGEEXPERT,
		TRAIT_PERFECT_TRACKER,
		TRAIT_NOBLE,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/advisor
	name = "Advisor of Heartfelt"
	jobtype = /datum/job/roguetown/heartfelt/hand
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/advisor
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/arcyne = 30,
		/datum/attribute/skill/combat/staves = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/heartfelt/hand/advisor
	name = "Advisor of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/advisor
	desc = "You are the Advisor of Heartfelt, trusted for your measured counsel and keen insight into matters of state. Bound once more to serve in the wake of ruin, you climb towards these lands."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/advisor
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_INTELLECTUAL,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_HEARTFELT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NOBLE,
		)
	rogue_stashed_items = list(
		"Heartfelt Caparison" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/marshal
	name = "Marshal of Heartfelt"
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

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/marshal
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/heartfelt/hand/marshal
	name = "Marshal of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/marshal
	desc = "Renowned for your command of war, you laid down your blade in peaceful years, but peace died with Heartfelt. Pressed once more into service by tragedy, you climb towards these lands."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/marshal
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_HEARTFELT,
		TRAIT_STEELHEARTED,
		)
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/steward
	name = "Steward of Heartfelt"
	jobtype = /datum/job/roguetown/heartfelt/hand
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	neck = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/sword/sabre/dec
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/steward
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/heartfelt/hand/steward
	name = "Steward of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/hand/steward
	desc = "You are the Steward of Heartfelt, once the quiet architect behind the barony's order—keeper of ledgers, harvests, and the lifeblood that sustained your people. Pressed once more into service by tragedy, you climb towards these lands."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/hand/steward
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_HEARTFELT,
		)
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/knight
	name = "Knight of Heartfelt"
	jobtype = /datum/job/roguetown/rockhill_migrant
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

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/knight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/heartfelt/knight
	name = "Knight of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/knight
	desc = "You are a Knight of Heartfelt, once part of a brotherhood in service to your Lord. Now, alone and committed to safeguarding what remains of your court, you ride to these lands, resolved to ensure their safe arrival."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/knight
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/archmage
	name = "Archmagos of Heartfelt"
	jobtype = /datum/job/roguetown/heartfelt/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/cloak/black_cloak
	cloak = /obj/item/clothing/cloak/heartfelt
	neck = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/magebag/associate
	r_pocket = /obj/item/rogueweapon/huntingknife
	l_hand = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/woodstaff/implement/grand
	backpack_contents = list(
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/rogueweapon/spellbook/grand = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/strongmanapot = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/archmage
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heartfelt/lord/archmage
	name = "Archmagos of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/archmage
	desc = "You are the Archmagos of Heartfelt, ruler of a once-prosperous acryne-barony now in ruin. Guided by visions of the great beyond, you journey to the Reach, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/archmage
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_INTELLECTUAL,
		TRAIT_HEARTFELT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_HEAVYARMOR,
		)
	maximum_slots = 1
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/chief
	name = "Chief of Heartfelt"
	jobtype = /datum/job/roguetown/heartfelt/lord
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	cloak = /obj/item/clothing/cloak/darkcloak/minotaur/red
	head = /obj/item/clothing/head/roguetown/helmet/sallet/beastskull
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/faulds
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/rogueweapon/huntingknife
	r_hand = /obj/item/rogueweapon/greataxe/steel/doublehead
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/chief
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = -2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heartfelt/lord/chief
	name = "Chief of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/chief
	desc = "You are the Chieftain of Heartfelt, ruler of a once-prosperous barony now in ruin. Guided by your Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/chief
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_STRONGBITE,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/lord
	name = "Lord of Heartfelt"
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

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/lord
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heartfelt/lord/lord
	name = "Lord of Heartfelt"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/lord/lord
	desc = "You are the Lord of Heartfelt, ruler of a once-prosperous barony now in ruin. Guided by your Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/lord/lord
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_social_rank = 5
	rogue_stashed_items = list(
		"Caparison (Heartfelt)" = /obj/item/caparison/heartfelt,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/armorer
	name = "Heartfeltian Armorer"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	cloak = /obj/item/clothing/cloak/apron/blacksmith
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	mouth = /obj/item/rogueweapon/huntingknife
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/rogueweapon/tongs
	r_pocket = /obj/item/rogueweapon/hammer/iron
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/rogueore/coal = 2,
		/obj/item/rogueore/iron = 4,
		/obj/item/rogueore/silver = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/armorer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/craft/armorsmithing = 50,
		/datum/attribute/skill/craft/blacksmithing = 50,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 20,
		/datum/attribute/skill/craft/masonry = 20,
		/datum/attribute/skill/craft/smelting = 50,
		/datum/attribute/skill/craft/weaponsmithing = 50,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/heartfelt/retinue/armorer
	name = "Heartfeltian Armorer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/armorer
	desc = "You are the Heartfeltian's Armorer destined for greatness, but fate intervened with the barony's downfall, With your home in ruins, you look to these lands, hoping to find new purpose or refuge amidst the chaos."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/armorer
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"Blacksteel and Steel Stash" = /obj/item/storage/roguebag/heartfelt/armorer,
		)

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/courtier
	name = "Heartfeltian Courtier"
	jobtype = /datum/job/roguetown/rockhill_migrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/dress/silkydress/random
	cloak = /obj/item/clothing/cloak/heartfelt
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish
	backpack_contents = list(
		/obj/item/lockpickring/mundane = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/elfred = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer/kgunsake = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/courtier
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/heartfelt/retinue/courtier
	name = "Heartfeltian Courtier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/courtier
	desc = "You are a Courtier of Heartfelt, once a respected noblewoman now struggling to survive in a desolate landscape. With your home in ruins, you look to these lands, hoping to find new purpose or refuge amidst the chaos."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/courtier
	rockhill_traits = list(
		TRAIT_SEEPRICES,
		TRAIT_NOBLE,
		TRAIT_NUTCRACKER,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_allowed_sexes = list(FEMALE)
	rogue_social_rank = 5

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/housearb
	name = "Heartfeltian Missilite"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/black
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/quiver/bolts
	l_hand = /obj/item/rogueweapon/sword
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/housearb
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 50,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/slings = 50,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/heartfelt/retinue/housearb
	name = "Heartfeltian Missilite"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/housearb
	desc = "You are a Missilite for the Lord of Heartfelt, a ranged combatant of the once-prosperous barony now in ruin. Guided by the Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/housearb
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HEARTFELT,
		)
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/houseguard
	name = "Heartfeltian House Guard"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/black
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/mace/warhammer
	l_hand = /obj/item/rogueweapon/sword
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/houseguard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/tracking = 10,
		)

/datum/rockhill_advclass/heartfelt/retinue/houseguard
	name = "Heartfeltian House Guard"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/houseguard
	desc = "You are a House Guard for the Lord of Heartfelt, a valiant defender of the once-prosperous barony now in ruin. Guided by the Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/houseguard
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 4
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/jester
	name = "Heartfeltian Jester"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights
	suit = /obj/item/clothing/suit/roguetown/shirt/jester
	head = /obj/item/clothing/head/roguetown/jester
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/jester
	belt = /obj/item/storage/belt/rogue/leather
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich

/datum/rockhill_advclass/heartfelt/retinue/jester
	name = "Heartfeltian Jester"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/jester
	desc = "You are the Jester of Heartfelt, a bringer of laughter in brighter days, now left to wander through the ashes of a fallen home. Though grief weighs heavy beneath your painted smile, you turn your steps toward these lands—hoping your wit, charm, and cunning may yet carve out a place for joy amidst the ruin."
	rockhill_traits = list(
		TRAIT_ZJUMP,
		TRAIT_LEAPER,
		TRAIT_NUTCRACKER,
		TRAIT_NOFALLDAMAGE1,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/magos
	name = "Heartfelt Magos"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/black
	cloak = /obj/item/clothing/cloak/black_cloak
	neck = /obj/item/clothing/neck/roguetown/talkstone
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/magebag/starter
	r_hand = /obj/item/rogueweapon/woodstaff/implement/greater
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/rogueweapon/spellbook/greater = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne = 1,
		/obj/item/scrying = 1,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/magos
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/arcyne = 40,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/staves = 40,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 60,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/heartfelt/retinue/magos
	name = "Heartfelt Magos"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/magos
	desc = "You are the Magos of Heartfelt, renowned for your arcane knowledge. However, with the increase in banditry, necromancy, deadite risings, and increasing sea raider raids, there are rumors abound that Heartfelt is not what it used to be. Travellers often warn of Heartfelt having fallen already, and words of secretive cultists isn't unheard of."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/magos
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_INTELLECTUAL,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/physician
	name = "Heartfeltian Physician"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/physician
	head = /obj/item/clothing/head/roguetown/physician
	neck = /obj/item/clothing/neck/roguetown/psicross/pestra
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	r_pocket = /obj/item/rogueweapon/huntingknife
	r_hand = /obj/item/rogueweapon/woodstaff/quarterstaff/steel
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/bedroll = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/physician
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 50,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/medicine = 60,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/heartfelt/retinue/physician
	name = "Heartfeltian Physician"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/physician
	desc = "You are the Physician of Heartfelt, once celebrated for your steady hands and healing wisdom, yet powerless to save your barony from its grim fate. Haunted by those you could not protect, you ascend toward these lands, seeking redemption, renewed purpose, and perhaps a cure for the wounds the world has inflicted."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/physician
	rockhill_traits = list(
		TRAIT_HEARTFELT,
		TRAIT_NOSTINK,
		TRAIT_EMPATH,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/prior
	name = "Heartfeltian Prior"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	cloak = /obj/item/clothing/cloak/chasuble
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/prior
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/magic/holy = 50,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 60,
		)

/datum/rockhill_advclass/heartfelt/retinue/prior
	name = "Heartfeltian Prior"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/prior
	desc = "The Prior of Heartfelt, you were destined for ascension within the Church, but fate intervened with the barony's downfall, delaying it indefinitely. Still guided by the blessings of Astrata, you journey to these lands, determined to offer what aid and solace you can."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/prior
	rockhill_traits = list(
		TRAIT_HEARTFELT,
		TRAIT_CHOSEN,
		TRAIT_RITUALIST,
		TRAIT_SOUL_EXAMINE,
		TRAIT_GRAVEROBBER,
		TRAIT_RESONANCE,
		TRAIT_VOTARY,
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/servant
	name = "Heartfeltian Servant"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/workervest
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/cooking/pan
	r_pocket = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 2,
		/obj/item/reagent_containers/food/snacks/rogue/handpie/fish = 2,
		/obj/item/reagent_containers/food/snacks/rogue/handpie/meat = 2,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/reagent_containers/glass/cup/silver = 2,
		/obj/item/reagent_containers/glass/bottle/rogue/wine = 1,
		/obj/item/soap/bath = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/servant
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/ceramics = 20,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/heartfelt/retinue/servant
	name = "Heartfeltian Servant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/servant
	desc = "You are Servant of Heartfelt, Serant of a once-prosperous barony now in ruin. Guided by the Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/servant
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		)
	maximum_slots = 4
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/squire
	name = "Heartfeltian Squire"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/heartfelt
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/polishing_cream = 1,
		/obj/item/armor_brush = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/squire
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/heartfelt/retinue/squire
	name = "Heartfeltian Squire"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heartfelt/retinue/squire
	desc = "You are a Squire for the Knights of Heartfelt, a trainee of the valiant defenders of the once-prosperous barony now in ruin. Guided by the Magos, you journey to these lands, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heartfelt/retinue/squire
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_STEELHEARTED,
		TRAIT_HEARTFELT,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/heir/aristocrat
	name = "Sheltered Aristocrat"
	jobtype = /datum/job/roguetown/prince
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/dress/royal/prince
	head = /obj/item/clothing/head/roguetown/circlet
	wrists = /obj/item/storage/keyring/heir
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife/scissors/steel
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/needle = 1,
		/obj/item/natural/bundle/fibers = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heir/aristocrat
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heir/aristocrat
	name = "Sheltered Aristocrat"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heir/aristocrat
	desc = "Life has been kind to you; you've an entire keep at your disposal, servants to wait on you, and a whole retinue of guards to guard you. You've nothing to prove; just live the good life and you'll be a lord someday, too. A lack of ambition translates into a lacking skillset beyond schooling, though, and your breaks from boredom consist of being a damsel or court gossip."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heir/aristocrat
	rockhill_traits = list(
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_GOODLOVER,
		TRAIT_SEWING_EXPERT,
		TRAIT_NOBLE,
		)

/datum/outfit/job/roguetown/rockhill_class/heir/bookworm
	name = "Introverted Bookworm"
	jobtype = /datum/job/roguetown/prince
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/armor/leather/newkeep/heir
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/royal/prince
	cloak = /obj/item/clothing/suit/roguetown/armor/longcoat
	head = /obj/item/clothing/head/roguetown/circlet
	mask = /obj/item/clothing/mask/rogue/spectacles
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/implement/greater/blacksteel
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	r_pocket = /obj/item/storage/keyring/heir
	backpack_contents = list(
		/obj/item/roguegem/amethyst = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/recipe_book/magic = 1,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heir/bookworm
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/magic/arcane = 10,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/heir/bookworm
	name = "Introverted Bookworm"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heir/bookworm
	desc = "Despite your standing, sociability is not your strong suit, and you have kept mostly to yourself and your books. This hardly makes you a favourite among the lords and ladies of the court, and an exit from your room is often met with amusement from nobility and servants alike. At least you're always welcome in the mage's tower."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heir/bookworm
	rockhill_traits = list(
		TRAIT_GOODWRITER,
		TRAIT_MAGEDEXTERITY,
		TRAIT_NOBLE,
		)

/datum/outfit/job/roguetown/rockhill_class/heir/daring
	name = "Daring Twit"
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

/datum/attribute_holder/sheet/job/rockhill_class/heir/daring
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heir/daring
	name = "Daring Twit"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heir/daring
	desc = "You're a somebody, someone important. It only makes sense you want to make a name for yourself, to gain your own glory so people see how great you really are beyond your bloodline. Plus, if you're beloved by the people for your exploits you'll be chosen! Probably. Shame you're as useful and talented as a squire, despite your delusions to the contrary."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heir/daring
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE,
		)

/datum/outfit/job/roguetown/rockhill_class/heir/inbred
	name = "Inbred wastrel"
	jobtype = /datum/job/roguetown/prince
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/armor/leather/newkeep/heir
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/royal/prince
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	wrists = /obj/item/storage/keyring/heir
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_pocket = /obj/item/rogueweapon/scabbard/sheath/noble
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/berrypoison = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/strongstampoison = 1,
		/obj/item/reagent_containers/glass/mortar = 1,
		/obj/item/pestle/rogue = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heir/inbred
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_FORTUNE = -2,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_PERCEPTION = -2,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = -2,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heir/inbred
	name = "Inbred wastrel"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heir/inbred
	desc = "Your bloodline ensures Psydon smiles upon you by divine right, the blessing of nobility... until you were born, anyway. You are a child forsaken, and even though your body boils as you go about your day, your spine creaks, and your drooling form needs to be waited on tirelessly you are still considered more important then the peasant that keeps the town fed and warm. Remind them of that fact when your lungs are particularly pus free."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heir/inbred
	rockhill_traits = list(
		TRAIT_CRITICAL_WEAKNESS,
		TRAIT_NORUN,
		TRAIT_GOODLOVER,
		TRAIT_NOBLE,
		)

/datum/outfit/job/roguetown/rockhill_class/heir/scamp
	name = "Nettlesome Scamp"
	jobtype = /datum/job/roguetown/prince
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
	shirt = /obj/item/clothing/suit/roguetown/armor/leather/newkeep/heir
	suit = /obj/item/clothing/suit/roguetown/armor/longcoat
	cloak = /obj/item/clothing/cloak/shadowcloak
	head = /obj/item/clothing/head/roguetown/circlet
	mask = /obj/item/clothing/head/roguetown/roguehood/black
	neck = /obj/item/storage/keyring/heir
	wrists = /obj/item/lockpickring/mundane
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/quiver/sling/iron
	r_pocket = /obj/item/gun/ballistic/revolver/grenadelauncher/sling
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/heir/scamp
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -3,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 4,
		ROGUE_STAT_STRENGTH = -3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/heir/scamp
	name = "Nettlesome Scamp"
	outfit = /datum/outfit/job/roguetown/rockhill_class/heir/scamp
	desc = "The stories told to you by your bedside of valiant rogues and thieves with hearts of gold saving the worlds. The misunderstood hero. The clammor of Knights, the dull books of the arcyne and the wise never interested you. So you donned the cloak, and with your plump figure learned the arts of stealth. Surely the populace will be forgiving of your antics."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/heir/scamp
	rockhill_traits = list(
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_NOBLE,
		)
	rogue_stat_ceilings = list(ROGUE_STAT_STRENGTH = 8, ROGUE_STAT_CONSTITUTION = 8, ROGUE_STAT_SPEED = 15)

/datum/outfit/job/roguetown/rockhill_class/homesteader
	name = "Commoner"
	jobtype = /datum/job/roguetown/pilgrim
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/rogueweapon/handsaw = 1,
		/obj/item/dye_brush = 1,
		/obj/item/reagent_containers/powder/salt = 1,
		/obj/item/reagent_containers/food/snacks/rogue/cheddar = 2,
		/obj/item/natural/cloth = 2,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/shovel/small = 1,
		/obj/item/rogueweapon/chisel = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/homesteader
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 10,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/homesteader
	name = "Commoner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/homesteader
	desc = "You are not bound to any guild or master's service. Where others specialize in a single craft, you have learned to adapt - taking whatever work comes your way. Whether you become a skilled artisan, a wilderness survivalist, or something else entirely, your path is yours to forge. What trade will you pursue today?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/homesteader
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 10

/datum/outfit/job/roguetown/rockhill_class/hunter
	name = "Bow-Hunter"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou/artipants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/quiver/arrows
	l_hand = /obj/item/rogueweapon/sword/short/messer/iron
	r_hand = /obj/item/storage/meatbag
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/bait = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/hunting_map/white_stag = 1,
		/obj/item/hunting_map/boars = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/hunter
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 40,
		/datum/attribute/skill/labor/fishing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/hunter
	name = "Bow-Hunter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/hunter
	desc = "You are a hunter. With your bow you hunt the fauna of the glade, skinning what you kill and cooking any meat left over. The job is dangerous but important in the circulation of clothing and light armor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/hunter
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_MASTERFUL_HUNTER,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/hunter/spear
	name = "Spear-Hunter"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	suit = /obj/item/clothing/suit/roguetown/armor/leather/hide
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/meatbag
	l_hand = /obj/item/rogueweapon/spear
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/bait = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/hunting_map/white_stag = 1,
		/obj/item/hunting_map/boars = 1,
		/obj/item/rogueweapon/stoneaxe/handaxe = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/hunter/spear
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 40,
		/datum/attribute/skill/labor/fishing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/hunter/spear
	name = "Spear-Hunter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/hunter/spear
	desc = "You are a hunter. With your bow you hunt the fauna of the glade, skinning what you kill and cooking any meat left over. The job is dangerous but important in the circulation of clothing and light armor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/hunter/spear
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_MASTERFUL_HUNTER,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/kj_chaplain
	name = "Sworn Missionary"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/woodstaff
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_chaplain
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/kj_chaplain
	name = "Sworn Missionary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_chaplain
	desc = "You've looked after your knight's soul for yils, and you preach wherever the road takes you. There's always someone along the way who needs to hear it. Preachers focus on homesteading while Shepards preach through example and protecting their would-be flock."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_chaplain
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_RITUALIST,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"The Verses and Acts of the Ten" = /obj/item/book/rogue/bibble,
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/kj_chaplain_stigmata
	name = "Sworn Stigmata"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/storage/belt/rogue/pouch/medicine = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_chaplain_stigmata
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 5,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_chaplain_stigmata
	name = "Sworn Stigmata"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_chaplain_stigmata
	desc = "PSYDON weeps. Your knight takes the blows meant for others, and you take their wounds in turn. You will not raise a hand in anger. You will suffer. You will endure."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_chaplain_stigmata
	rockhill_traits = list(
		TRAIT_PACIFISM,
		TRAIT_EMPATH,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_STEELHEARTED,
		TRAIT_SELF_AWARE,
		TRAIT_RITUALIST,
		TRAIT_LUX_FREAK,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 3
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/kj_follower/campwright
	name = "Campwright"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	cloak = /obj/item/clothing/cloak/apron/waist/bar
	head = /obj/item/clothing/head/roguetown/hatblu
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter
	l_pocket = /obj/item/rogueweapon/pick
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/rogueweapon/handsaw = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/dye_brush = 1,
		/obj/item/rogueweapon/blowrod = 1,
		/obj/item/bedroll = 3,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_follower/campwright
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 40,
		/datum/attribute/skill/craft/ceramics = 40,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/engineering = 30,
		/datum/attribute/skill/craft/masonry = 40,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/lumberjacking = 30,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_follower/campwright
	name = "Campwright"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_follower/campwright
	desc = "You set up camp wherever your knight stops for the night. With enough logs or stone, you can put up proper walls if they stay a while."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_follower/campwright
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_MASTER_CARPENTER,
		TRAIT_MASTER_MASON,
		TRAIT_LEGENDARY_MINER,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 1
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/kj_follower/chirurgeon
	name = "Chirurgeon"
	jobtype = /datum/job/roguetown/rockhill_migrant
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

/datum/attribute_holder/sheet/job/rockhill_class/kj_follower/chirurgeon
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 50,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 10,
		)

/datum/rockhill_advclass/kj_follower/chirurgeon
	name = "Chirurgeon"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_follower/chirurgeon
	desc = "For yils you've patched your knight up after every fight, pulling arrowheads, setting bones and stitching wounds. On quiet days you still cut their hair."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_follower/chirurgeon
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_NOSTINK,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 1
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/kj_follower/jongleur
	name = "Jongleur"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	backpack_contents = list(
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_follower/jongleur
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_follower/jongleur
	name = "Jongleur"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_follower/jongleur
	desc = "You sing of your knight's deeds in every tavern and hall you pass through, and you've done it for yils. The songs aren't always accurate, but they're always flattering."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_follower/jongleur
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_GOODLOVER,
		TRAIT_EMPATH,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 1
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/kj_follower/servitor
	name = "Servitor"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/workervest
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	r_pocket = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 2,
		/obj/item/reagent_containers/food/snacks/rogue/handpie/fish = 2,
		/obj/item/reagent_containers/food/snacks/rogue/handpie/meat = 2,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/reagent_containers/glass/cup/silver = 2,
		/obj/item/reagent_containers/glass/bottle/rogue/wine = 1,
		/obj/item/soap/bath = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/cooking/pan = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/folding_table_stored = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_follower/servitor
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/ceramics = 20,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/kj_follower/servitor
	name = "Servitor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_follower/servitor
	desc = "You cook your knight's meals, mend their clothes and carry whatever they can't be bothered to. They'd be lost on the road without you, even if they rarely say so."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_follower/servitor
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 1
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/kj_knight
	name = "Knight Banneret"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 3,
		/obj/item/needle = 1,
		/obj/item/recipe_book/survival = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_knight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/kj_knight
	name = "Knight Banneret"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_knight
	desc = "A veteran of many tourneys and more than a few true wars, you ride far from your house's lands with a squire you have been training for some yils. You know your chosen arm of war well."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_knight
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/kj_knight_outrider
	name = "Knight Outrider"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 3,
		/obj/item/needle = 1,
		/obj/item/recipe_book/survival = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_knight_outrider
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/kj_knight_outrider
	name = "Knight Outrider"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_knight_outrider
	desc = "You've spent most of your life in the saddle, scouting ahead and running down stragglers. You ride out ahead of your squire, strike from horseback and rely on speed rather than heavy armor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_knight_outrider
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/kj_squire
	name = "Squire-at-Arms"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/polishing_cream = 1,
		/obj/item/armor_brush = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		/obj/item/folding_table_stored = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_squire
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_squire
	name = "Squire-at-Arms"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_squire
	desc = "You fight on foot beside your knight with your shield raised, and you keep their armor in good repair. Serve them well long enough and you may be knighted yourself."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_squire
	rockhill_traits = list(
		TRAIT_SQUIRE_REPAIR,
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/kj_squire_bidower
	name = "Bidower"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/polishing_cream = 1,
		/obj/item/armor_brush = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		/obj/item/folding_table_stored = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_squire_bidower
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_squire_bidower
	name = "Bidower"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_squire_bidower
	desc = "You travel light and fight from the back with bow, crossbow or sling, thinning out the enemy before your knight charges in."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_squire_bidower
	rockhill_traits = list(
		TRAIT_SQUIRE_REPAIR,
		TRAIT_DODGEEXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/kj_squire_hobelar
	name = "Hobelar"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/polishing_cream = 1,
		/obj/item/armor_brush = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		/obj/item/folding_table_stored = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/kj_squire_hobelar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/kj_squire_hobelar
	name = "Hobelar"
	outfit = /datum/outfit/job/roguetown/rockhill_class/kj_squire_hobelar
	desc = "You fight from horseback with a polearm and look after your own mount once the day is done. You're a fair hand in the saddle, whether your knight rides or walks."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/kj_squire_hobelar
	rockhill_traits = list(
		TRAIT_SQUIRE_REPAIR,
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/knight/footknight
	name = "Foot Knight"
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
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	l_hand = /obj/item/rogueweapon/sword/long
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/knight/footknight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/knight/footknight
	name = "Foot Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/knight/footknight
	desc = "You are accustomed to traditional foot-soldiery, masterfully proficient in swords, flails, or maces. Your fortitude and mastery with the versatile combination of a shield and weapon makes you a fearsome opponent to take down!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/knight/footknight
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_GUARDSMAN,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/knight/heavy
	name = "Heavy Knight"
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

/datum/attribute_holder/sheet/job/rockhill_class/knight/heavy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/knight/heavy
	name = "Heavy Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/knight/heavy
	desc = "You've trained thoroughly and hit far harder than most - masterfully proficient in swords, axes, maces or polearms. People may fear the mounted knights, but they should truly fear those who come off their mount..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/knight/heavy
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_GUARDSMAN,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/knight/irregularknight
	name = "Royal Champion"
	jobtype = /datum/job/roguetown/knight
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	r_pocket = /obj/item/quiver/arrows
	r_hand = /obj/item/rogueweapon/sword/rapier
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/knight/irregularknight
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/knight/irregularknight
	name = "Royal Champion"
	outfit = /datum/outfit/job/roguetown/rockhill_class/knight/irregularknight
	desc = "Your skillset is abnormal for a knight. Your swift maneuvers and masterful technique impress both lords and ladies alike, and you have a preference for quicker, more elegant blades. While you are an effective fighting force in medium armor, your evasive skills will only truly shine if you don even lighter protection."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/knight/irregularknight
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_DODGEEXPERT,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_GUARDSMAN,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_stashed_items = list(
		"Caparison (Saiga)" = /obj/item/caparison,
		"Caparison (Fogbeast)" = /obj/item/caparison/fogbeast,
		)

/datum/outfit/job/roguetown/rockhill_class/knight/mountedknight
	name = "Mounted Knight"
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
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/quiver/bolts
	r_hand = /obj/item/rogueweapon/sword/long
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/knight/mountedknight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/knight/mountedknight
	name = "Mounted Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/knight/mountedknight
	desc = "You are the picture-perfect knight from a high tale, knowledgeable in riding steeds into battle. You specialize in weapons most useful on a saiga including swords, polearms, and bows."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/knight/mountedknight
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_EQUESTRIAN,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_GUARDSMAN,
		TRAIT_EXPERT_HUNTER,
		)
	rogue_stashed_items = list(
		"Caparison (Saiga)" = /obj/item/caparison,
		"Caparison (Fogbeast)" = /obj/item/caparison/fogbeast,
		)

/datum/outfit/job/roguetown/rockhill_class/lord/inbred
	name = "Inbred Lord"
	jobtype = /datum/job/roguetown/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/lordcloak
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/lord
	r_pocket = /obj/item/gun/ballistic/firearm/arquebus_pistol
	l_hand = /obj/item/rogueweapon/lordscepter
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/quiver/bullet/lead = 1,
		/obj/item/powderflask = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/lord/inbred
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_FORTUNE = 10,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_PERCEPTION = -2,
		ROGUE_STAT_STRENGTH = -2,
		ROGUE_STAT_WILLPOWER = -2,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/lord/inbred
	name = "Inbred Lord"
	outfit = /datum/outfit/job/roguetown/rockhill_class/lord/inbred
	desc = "Psydon and Astrata smiles upon you. For despite your inbred and weak body, and your family's conspiracies to remove you from succession, you have somehow become the Lord of the Realm. May your reign lasts a hundred years."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/lord/inbred
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_CRITICAL_WEAKNESS,
		TRAIT_DNR,
		TRAIT_NORUN,
		TRAIT_HEAVYARMOR,
		TRAIT_GOODLOVER,
		)

/datum/outfit/job/roguetown/rockhill_class/lord/merchant
	name = "Merchant Lord"
	jobtype = /datum/job/roguetown/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/lordcloak
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/lord
	r_pocket = /obj/item/gun/ballistic/firearm/arquebus_pistol
	l_hand = /obj/item/rogueweapon/lordscepter
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/quiver/bullet/lead = 1,
		/obj/item/powderflask = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/lord/merchant
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 5,
		ROGUE_STAT_PERCEPTION = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/firearms = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/lord/merchant
	name = "Merchant Lord"
	outfit = /datum/outfit/job/roguetown/rockhill_class/lord/merchant
	desc = "You were always talented with coins and trade. And your talents have brought you to the position of the Lord of the Realm. You could be a merchant who bought his way into nobility and power, or an exceptionally talented noble who were inclined to be good with coins. Fighting directly is not your forte But you have plenty of wealth, keen ears, and know a good deal from a bad one."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/lord/merchant
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_DNR,
		TRAIT_MEDIUMARMOR,
		)
	rogue_estate_income = 400

/datum/outfit/job/roguetown/rockhill_class/lord/warrior
	name = "Valiant Warrior"
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

/datum/attribute_holder/sheet/job/rockhill_class/lord/warrior
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/lord/warrior
	name = "Valiant Warrior"
	outfit = /datum/outfit/job/roguetown/rockhill_class/lord/warrior
	desc = "You're a noble warrior. You rose to your rank through your own strength and skill, whether by leading your men or by fighting alongside them. Or perhaps you are none of that, but simply a well-trained heir elevated to the position of Lord. You're trained in the usage of heavy armor, and knows swordsmanship well."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/lord/warrior
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_DNR,
		TRAIT_HEAVYARMOR,
		)

/datum/outfit/job/roguetown/rockhill_class/lord/wizard
	name = "Magocrat"
	jobtype = /datum/job/roguetown/lord
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/lordcloak
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/keyring/lord
	l_hand = /obj/item/rogueweapon/lordscepter
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/lord/wizard
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 5,
		ROGUE_STAT_INTELLIGENCE = 5,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 20,
		)

/datum/rockhill_advclass/lord/wizard
	name = "Magocrat"
	outfit = /datum/outfit/job/roguetown/rockhill_class/lord/wizard
	desc = "A good ruler is backed with force. You just happen to have a keen amount of mastery over the world's strongest forces: Magic. Of course, having to manage your realm has meant that you aren't as studied as the realm's greatest wizards- but your cunning sorcery is what has you sat upon the throne."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/lord/wizard
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_DNR,
		TRAIT_INTELLECTUAL,
		TRAIT_ARCYNE,
		)

/datum/outfit/job/roguetown/rockhill_class/mage
	name = "Sorcerer"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/mage
	head = /obj/item/clothing/head/roguetown/roguehood/mage
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/storage/magebag
	backpack_contents = list(
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mage
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/arcyne = 30,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/staves = 30,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mage
	name = "Sorcerer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mage
	desc = "You are a learned mage and a scholar, having spent your life studying the arcane and its ways."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mage
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MAGEDEXTERITY,
		TRAIT_OUTLANDER,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"skills" = list(/datum/attribute/skill/magic/arcane = 40),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/mage/spellblade
	name = "Spellblade"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	head = /obj/item/clothing/head/roguetown/bucklehat
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/wood
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/long
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/chalk = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mage/spellblade
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mage/spellblade
	name = "Spellblade"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mage/spellblade
	desc = "You are skilled in both the arcyne art and the art of the blade. But you are not a master of either nor could you channel your magick in armor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mage/spellblade
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_OUTLANDER,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"skills" = list(/datum/attribute/skill/magic/arcane = 40),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/mage/spellsinger
	name = "Spellsinger"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe
	head = /obj/item/clothing/head/roguetown/spellcasterhat
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/sabre
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/chalk = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mage/spellsinger
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mage/spellsinger
	name = "Spellsinger"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mage/spellsinger
	desc = "You belong to a school of bards renowned for their study of both the arcane and the arts."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mage/spellsinger
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_OUTLANDER,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"skills" = list(/datum/attribute/skill/magic/arcane = 40),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/mage/spellthief
	name = "Arcyne Trickster"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/chalk = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mage/spellthief
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/mage/spellthief
	name = "Arcyne Trickster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mage/spellthief
	desc = "You are an Arcyne Trickster, a thief and hooligan gifted in the arcyne arts."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mage/spellthief
	rockhill_traits = list(
		TRAIT_ARCYNE,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_age_mod = list(
		"age" = "Old",
		"skills" = list(/datum/attribute/skill/magic/arcane = 40),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/manorguard/cavalry
	name = "Cavalryman"
	jobtype = /datum/job/roguetown/manorguard
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light/retinue
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_hand = /obj/item/rogueweapon/halberd/bardiche
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/cavalry
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/manorguard/cavalry
	name = "Cavalryman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/cavalry
	desc = "You are a professional soldier of the realm, specializing in the steady beat of hoof falls. Lighter and more expendable then the knights, you charge with lance in hand."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/cavalry
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_EQUESTRIAN,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)
	rogue_stashed_items = list(
		"Caparison (Saiga)" = /obj/item/caparison,
		"Caparison (Fogbeast)" = /obj/item/caparison/fogbeast,
		)

/datum/outfit/job/roguetown/rockhill_class/manorguard/footsman
	name = "Footman"
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

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/footsman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/tracking = 10,
		)

/datum/rockhill_advclass/manorguard/footsman
	name = "Footman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/footsman
	desc = "You are a professional soldier of the realm, specializing in melee warfare. Stalwart and hardy, your body can both withstand and dish out powerful strikes.."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/footsman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/manorguard/gormless
	name = "Catchpole"
	jobtype = /datum/job/roguetown/manorguard
	uniform = /obj/item/clothing/under/roguetown/splintlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_hand = /obj/item/rogueweapon/mace/stunmace
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/gormless
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		)

/datum/rockhill_advclass/manorguard/gormless
	name = "Catchpole"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/gormless
	desc = "Not quite the professional. Not quite the soldier. More akin to a brute they've given a hammer, some leftover equipment and told to face the enemy. Yet, you've proven yourself more reliable than disposable. More than most can say."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/gormless
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/manorguard/retainer
	name = "Retainer"
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
	l_pocket = /obj/item/rogueweapon/sword/decorated
	r_pocket = /obj/item/rogueweapon/mace/warhammer
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/retainer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/tracking = 10,
		)

/datum/rockhill_advclass/manorguard/retainer
	name = "Retainer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/retainer
	desc = "You are an aging man-at-arms who has spent decades in faithful service. Though the vigor of youth has faded, discipline and experience remain."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/retainer
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)
	rogue_allowed_ages = list("Old")

/datum/outfit/job/roguetown/rockhill_class/manorguard/skirmisher
	name = "Skirmisher"
	jobtype = /datum/job/roguetown/manorguard
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light/retinue
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/combat/messer = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/skirmisher
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 50,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/slings = 50,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/manorguard/skirmisher
	name = "Skirmisher"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/skirmisher
	desc = "You are a professional soldier of the realm, specializing in ranged implements. You sport a keen eye, looking for your enemies weaknesses."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/skirmisher
	rockhill_traits = list(
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)

/datum/outfit/job/roguetown/rockhill_class/manorguard/standard_bearer
	name = "Standard Bearer"
	jobtype = /datum/job/roguetown/manorguard
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light/retinue
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_hand = /obj/item/rogueweapon/spear/keep_standard
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/manorguard/standard_bearer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/manorguard/standard_bearer
	name = "Standard Bearer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/manorguard/standard_bearer
	desc = "You're the sergeant's second, entrusted with the keep's standard when you sally out into battle. Your fellow soldiers know to rally around you, should you keep it safe."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/manorguard/standard_bearer
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_STANDARD_BEARER,
		TRAIT_GUARDSMAN,
		TRAIT_STEELHEARTED,
		)
	maximum_slots = 1

/datum/outfit/job/roguetown/rockhill_class/marshal/classic
	name = "Marshal"
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

/datum/attribute_holder/sheet/job/rockhill_class/marshal/classic
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/marshal/classic
	name = "Marshal"
	outfit = /datum/outfit/job/roguetown/rockhill_class/marshal/classic
	desc = "You've spent your daes in the courts and garrisons of the city. You've studied the law tome from back to front and enforce your word with the iron hand of justice, and the iron mace in your hands. More men have spent days rotting in the dungeon than that Knight Commander could ever have claimed, and every person in the realm respects your authority in matters of law and order."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/marshal/classic
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_PERFECT_TRACKER,
		)

/datum/outfit/job/roguetown/rockhill_class/marshal/kcommander
	name = "Knight Commander"
	jobtype = /datum/job/roguetown/marshal
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/retinue/coat
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/sword/long/oathkeeper
	l_pocket = /obj/item/storage/keyring/sheriff
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/marshal/kcommander
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/marshal/kcommander
	name = "Knight Commander"
	outfit = /datum/outfit/job/roguetown/rockhill_class/marshal/kcommander
	desc = "You spent your daes as a dutiful knight in the service of the crown. Earning your accolades through military tactics and victories, you're reknown for your warfaring. Now retired from your days afield, you enforce the same iron law you once practiced at war in your home. You run the garrison, knights and the town's laws with a military strictness, and no-one can claim you are weaker on crime than any of those weak Marshals."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/marshal/kcommander
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_PERFECT_TRACKER,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/atgervi
	name = "Ba'atur"
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

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/atgervi
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/atgervi
	name = "Ba'atur"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/atgervi
	desc = "You are a nöküd of the Gronn Highlands. Warrior-Traders whose exploits into the Zybantine Empire will be forever remembered by historians."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/atgervi
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/gronnic")

/datum/outfit/job/roguetown/rockhill_class/mercenary/atgervi/shaman
	name = "Zayran Shaman"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather/atgervi
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/atgervi
	head = /obj/item/clothing/head/roguetown/helmet/leather/shaman_hood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/plate/atgervi
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/atgervi
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/flashlight/flare/torch
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/stoneaxe/hurlbat = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/atgervi/shaman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/atgervi/shaman
	name = "Zayran Shaman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/atgervi/shaman
	desc = "You are a Zayran, a high-ranking shaman of the The Northern Empty. Savage combatants who commune with the Beast spirits called \"Tngri\" through ritualistic violence, rather than idle prayer."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/atgervi/shaman
	rockhill_traits = list(
		TRAIT_STRONGBITE,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_subclass_languages = list("/datum/language/gronnic")

/datum/outfit/job/roguetown/rockhill_class/mercenary/blackoak
	name = "Black Oak's Guardian"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hatanga
	suit = /obj/item/clothing/suit/roguetown/armor/plate/elven_plate
	cloak = /obj/item/clothing/cloak/forrestercloak
	head = /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/long/elf
	r_hand = /obj/item/rogueweapon/spear/naginata/elf
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/elvish = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/blackoak
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/mercenary/blackoak
	name = "Black Oak's Guardian"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/blackoak
	desc = "A shady guardian of the Black Oaks. Half mercenary band, half irregular militia fighting for control of their ancestral elven homeland of the Peaks. Thankfully, you are not here today to shed the blood of the Duke's men — unless someone pays you to..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/blackoak
	rockhill_traits = list(
		TRAIT_AZURENATIVE,
		TRAIT_OUTDOORSMAN,
		TRAIT_BLACKOAK,
		TRAIT_MEDIUMARMOR,
		TRAIT_WOODWALKER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/halfelf", "/datum/species/elf/wood", "/datum/species/elf/dark")

/datum/outfit/job/roguetown/rockhill_class/mercenary/blackoak/ranger
	name = "Black Oak's Ranger"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hatanga
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/elven
	cloak = /obj/item/clothing/cloak/forrestercloak
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/blackoak
	l_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/elvish = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/blackoak/ranger
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 50,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/blackoak/ranger
	name = "Black Oak's Ranger"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/blackoak/ranger
	desc = "A shady guardian of the Black Oaks. Half mercenary band, half irregular militia fighting for control of their ancestral elven homeland of the Peaks. Thankfully, you are not here today to shed the blood of the Duke's men — unless someone pays you to..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/blackoak/ranger
	rockhill_traits = list(
		TRAIT_AZURENATIVE,
		TRAIT_OUTDOORSMAN,
		TRAIT_BLACKOAK,
		TRAIT_DODGEEXPERT,
		TRAIT_WOODWALKER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/halfelf", "/datum/species/elf/wood", "/datum/species/elf/dark")

/datum/outfit/job/roguetown/rockhill_class/mercenary/condottiero
	name = "Condottiero Guildsman"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/helmet
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/iron
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/quiver/bolts
	l_hand = /obj/item/rogueweapon/sword/short
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/lockpick = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/condottiero
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/condottiero
	name = "Condottiero Guildsman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/condottiero
	desc = "Hailing from the Kingdom of Etrusca, Condottieri are soldiers of fortune oft found in the employ of powerful merchants. Without a war to fight back home, the Grand Duchy has become a much-needed source of contracts. Afterall, this land is rich in coin yet poor in manpower..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/condottiero
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/etruscan", "/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/mercenary/crocs
	name = "Crocs de l'araignée Cavalier"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shadowpants/maille
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/shadowrobe
	suit = /obj/item/clothing/suit/roguetown/armor/plate/fluted/shadowplate
	head = /obj/item/clothing/neck/roguetown/chaincoif/full/black
	mask = /obj/item/clothing/mask/rogue/facemask/shadowfacemask
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/plate/shadowgauntlets
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/tower/spidershield
	l_pocket = /obj/item/rope/chain
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/sabre/stalker
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/dirk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/crocs
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/mercenary/crocs
	name = "Crocs de l'araignée Cavalier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/crocs
	desc = "The Crocs de l'araignée, translated literally to mean \"Spider's Teeth\", is a renowned collective of blades, whips, and riders for hire often employed in the vast drow undercity complexes and occasionally the surface above. Infamous for their battlefrenzy, sadism, and mastery over arachnid cavalry, a member of the Spider's Teeth stands among some of the fiercest if cruelest warriors in Psydonia. Dark elves ultimately are only truly aligned to themselves and their own interests; this trait makes them surprisingly pragmatic and straightforward mercenaries, as a drow can be counted on to do any job so long as the price is right and it serves whatever higher ambition they might have."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/crocs
	rockhill_traits = list(
		TRAIT_DARKVISION,
		TRAIT_MEDIUMARMOR,
		TRAIT_EQUESTRIAN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/human/halfelf")

/datum/outfit/job/roguetown/rockhill_class/mercenary/crocsass
	name = "Crocs de l'araignée Assassin"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shadowpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/shadowrobe
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/shadowvest
	cloak = /obj/item/clothing/cloak/shadowcloak
	head = /obj/item/clothing/neck/roguetown/chaincoif/full/black
	mask = /obj/item/clothing/mask/rogue/shepherd/shadowmask/delf
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/fingerless/shadowgloves/elflock
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/sword/falx/stalker
	r_pocket = /obj/item/quiver/bolts/
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow/stalker
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/dirk = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/lockpick = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/crocsass
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/mercenary/crocsass
	name = "Crocs de l'araignée Assassin"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/crocsass
	desc = "The Crocs de l'araignée, translated literally to mean \"Spider's Teeth\", is a renowned collective of blades, whips, and riders for hire often employed in the vast drow undercity complexes and occasionally the surface above. Infamous for their battlefrenzy, sadism, and mastery over arachnid cavalry, a member of the Spider's Teeth stands among some of the fiercest if cruelest warriors in Psydonia. Dark elves ultimately are only truly aligned to themselves and their own interests; this trait makes them surprisingly pragmatic and straightforward mercenaries, as a drow can be counted on to do any job so long as the price is right and it serves whatever higher ambition they might have."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/crocsass
	rockhill_traits = list(
		TRAIT_DARKVISION,
		TRAIT_DODGEEXPERT,
		TRAIT_EQUESTRIAN,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/elf/dark", "/datum/species/human/halfelf")

/datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider
	name = "Desert Rider Janissary"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/sallet/zyb
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/tower/zyb
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/mace/steel
	l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kukri = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/desert_rider
	name = "Desert Rider Janissary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider
	desc = "The Janissaries are the Empire's elite infantry units, wielding mace and shield. We do not break."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider/almah
	name = "Desert Rider Almah"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather/pontifex/zyb
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/zyb
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/zyb
	mask = /obj/item/clothing/mask/rogue/facemask/copper
	neck = /obj/item/clothing/neck/roguetown/gorget/copper
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/copper
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kukri = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider/almah
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/desert_rider/almah
	name = "Desert Rider Almah"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider/almah
	desc = "Almah are those skilled in both magyck and swordsmanship, but excelling in nothing."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider/almah
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider/zeybek
	name = "Desert Rider Zeybek"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather/pontifex/zyb
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/zyb
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/zyb
	mask = /obj/item/clothing/mask/rogue/facemask/ancient
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/quiver/javelin/iron
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	r_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kukri = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider/zeybek
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/desert_rider/zeybek
	name = "Desert Rider Zeybek"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/desert_rider/zeybek
	desc = "Zybantine 'Blade Dancers' are famed and feared the world over. Their expertise in blades both long and short is well known."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/desert_rider/zeybek
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_DUALWIELDER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia
	name = "Sellknight"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/greatsword
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/ferentia
	name = "Sellknight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia
	desc = "Combat experience and skill doesn't pay for lodging, mammons do. A knight only in appearance, you took to the mercenary guild to sell your services as sword-toting muscle to the highest bidder."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/crossbowman
	name = "Light Crossbowman"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/crossbowman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/ferentia/crossbowman
	name = "Light Crossbowman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/crossbowman
	desc = "Once a member of a guard mayhaps - you received training in bludgeons and crossbows, serving as a ferentia yet numerous and effective ranged service to the mercenary guild."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/crossbowman
	rockhill_traits = list(
		TRAIT_KEENEARS,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/longbowman
	name = "Longbowman"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy
	head = /obj/item/clothing/head/roguetown/roguehood/reinforced
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
	r_pocket = /obj/item/quiver/arrows
	r_hand = /obj/item/rogueweapon/stoneaxe/woodcut/pick
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/longbowman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/slings = 40,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/ferentia/longbowman
	name = "Longbowman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/longbowman
	desc = "You've trained since you were young with a bow hunting game in the forest. You know the woods like you know the vitals of a wild saiga. In the mercenary guild, it's not hard to think of a brigand as a bipedal saiga."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/longbowman
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/sellblade
	name = "Sellblade"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	head = /obj/item/clothing/head/roguetown/roguehood/reinforced
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/rapier
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/sellblade
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/ferentia/sellblade
	name = "Sellblade"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/sellblade
	desc = "An expert with a blade and nimble on your feet, those of your ability are something of a rare sight in the mercenary guild. Nevertheless effective at accomplishing the dirty work of others as you merge with the shadows, striking fast and deadly."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/sellblade
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/sellspear
	name = "Sellspear"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword
	r_hand = /obj/item/rogueweapon/halberd
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/sellspear
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/ferentia/sellspear
	name = "Sellspear"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/sellspear
	desc = "Faceless and numerous, the mercenary guild is occupied by many of your ilk. Maille and polearms are as easily used by the unskilled as they are effective."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/sellspear
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/thug
	name = "Hired Thug"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	head = /obj/item/clothing/neck/roguetown/chaincoif/iron
	mask = /obj/item/clothing/mask/rogue/facemask
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	r_hand = /obj/item/rogueweapon/mace/steel
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/thug
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/ferentia/thug
	name = "Hired Thug"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/ferentia/thug
	desc = "The mercenary guild is teeming with corn-fed brutes looking to make mammons off the only thing they're good at - while simple-minded describes you best, you possess brute strength and a heavy club. Sometimes that's all you need to solve problems in lyfe."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/ferentia/thug
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_BIGGUY,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_DRUNK_HEALING,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/mercenary/forlorn
	name = "Forlorn Hope Mercenary"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	head = /obj/item/clothing/head/roguetown/helmet/heavy/volfplate
	neck = /obj/item/clothing/neck/roguetown/gorget/forlorncollar
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/forlorn
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/forlorn
	name = "Forlorn Hope Mercenary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/forlorn
	desc = "The Order of the Forlorn Hope, a holy order founded in the name of Noc and the banishment of the rot. Now it is riddled with the wounded, the veterans and the landless of the Vakran civil war. Take up the banner and fight again in the name of the Ten, or use the pretense of faith and zealotry to make ends meet by any means necessary."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/forlorn
	rockhill_traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/lupian", "/datum/species/anthromorph", "/datum/species/vulpkanin")
	rogue_min_pq = 2
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer
	name = "Freifechter Fencer"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer
	mask = /obj/item/clothing/mask/rogue/spectacles/duelist
	neck = /obj/item/clothing/neck/roguetown/psicross/reform
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/freifechter
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft/freifechter
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/navaja/freifechter
	l_hand = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/long/etruscan
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/mercenary/freelancer
	name = "Freifechter Fencer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer
	desc = "You are a graduate of the Czwarteki Freifechters - \"Freelancers\" - a prestigious fighting guild localized in the independent City-state of Szöréndnížina - the Capitol of Czwarteka, recognized as an encomium to Ravox by the Holy See. It was formed an odd thirty yils ago, but its visitors come from all over Western Grimoria. You have swung one weapon ten-thousand times, and not the other way around. This class is for experienced combatants who have a solid grasp on footwork and stamina management, master skills alone won't save your lyfe."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer
	rockhill_traits = list(
		TRAIT_BADTRAINER,
		TRAIT_INTELLECTUAL,
		TRAIT_LONGSWORDSMAN,
		TRAIT_FENCERDEXTERITY,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_subclass_languages = list("/datum/language/aavnic")
	rogue_stat_ceilings = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_SPEED = 12, ROGUE_STAT_CONSTITUTION = 12)

/datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer_lancer
	name = "Freifechter Lancer"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/freifechter
	mask = /obj/item/clothing/mask/rogue/spectacles/duelist
	neck = /obj/item/clothing/neck/roguetown/psicross/reform
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/freifechter
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft/freifechter
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/satchel/short
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/spear/boar/frei
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer_lancer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/mercenary/freelancer_lancer
	name = "Freifechter Lancer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer_lancer
	desc = "You are a graduate of the Czwarteki Freifechters - \"Freelancers\" - part of a prestigious fighting guild localized in the independent City-state of Szöréndnížina - the Capitol of Czwarteka. It was formed an odd thirty yils ago, but its visitors come from all over Western Grimoria. You have swung one weapon ten-thousand times, and not the other way around. A Lancer and his pike are inseparable, and the first line of offense. You can choose to display the banners of the Reformist Order or your own State."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer_lancer
	rockhill_traits = list(
		TRAIT_BADTRAINER,
		TRAIT_FENCERDEXTERITY,
		TRAIT_INTELLECTUAL,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_subclass_languages = list("/datum/language/aavnic")
	rogue_stat_ceilings = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_SPEED = 12, ROGUE_STAT_WILLPOWER = 14, ROGUE_STAT_CONSTITUTION = 12)

/datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer_sabrist
	name = "Freifechter Sabrist"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer
	mask = /obj/item/clothing/mask/rogue/spectacles/duelist
	neck = /obj/item/clothing/neck/roguetown/psicross/reform
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/freifechter
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft/freifechter
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/navaja/freifechter
	l_hand = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/sabre/freifechter
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer_sabrist
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/mercenary/freelancer_sabrist
	name = "Freifechter Sabrist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/freelancer_sabrist
	desc = "You are a graduate of the Czwarteki Freifechters - \"Freelancers\" - part of a prestigious fighting guild localized in the independent City-state of Szöréndnížina - the Capitol of Czwarteka. It was formed an odd thirty yils ago, but its visitors come from all over Western Grimoria. You have swung one weapon ten-thousand times, and not the other way around. Your faith is stalwart in the teachings of the Psydonic Reformation, and you've become a warrior poet of sorts - educating the peasantry in the ways of the New Word and angering the Orthodoxy in turn. You've left your cradle in search of riches to fund your people's armies. Sabrists are renowned for their dexterity and speed, but lack the adaptability of longswordmen."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/freelancer_sabrist
	rockhill_traits = list(
		TRAIT_BADTRAINER,
		TRAIT_INTELLECTUAL,
		TRAIT_FENCERDEXTERITY,
		TRAIT_SABRIST,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_patrons = list(/datum/patron/psydon)
	rogue_subclass_languages = list("/datum/language/aavnic")
	rogue_stat_ceilings = list(ROGUE_STAT_STRENGTH = 12, ROGUE_STAT_CONSTITUTION = 12, ROGUE_STAT_WILLPOWER = 12, ROGUE_STAT_SPEED = 12)

/datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft
	name = "Doppelsoldner"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/plate/blacksteel_half_plate
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/greatsword/grenz
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/grenzelhoft
	name = "Doppelsoldner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft
	desc = "You are a Doppelsöldner - \"Double-pay Mercenary\" - an experienced frontline swordsman trained by the Zenitstadt fencing guild."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/crossbowman
	name = "Armbrustschütze"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/steel
	r_pocket = /obj/item/quiver/bolts
	r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/crossbowman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/grenzelhoft/crossbowman
	name = "Armbrustschütze"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/crossbowman
	desc = "You're a proved marksman with a crossbow, and learned how to set up camp and defenses in the wild. The guild needs you."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/crossbowman
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/halberdier
	name = "Hellebardier"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/plate/blacksteel_half_plate
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/halberd
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/halberdier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/grenzelhoft/halberdier
	name = "Hellebardier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/halberdier
	desc = "You're an experienced soldier skilled in the use of polearms and axes. Your equals make up the bulk of the mercenary guild's forces."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/halberdier
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/mage
	name = "Gefechtsgelehrter"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/leather/cuirass
	cloak = /obj/item/clothing/cloak/stabard/grenzelmage
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/coif/padded
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather/battleskirt
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/implement/greater/gefechtsgelehrter
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/spellbook/greater = 1,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/mage
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/arcyne = 40,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/staves = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/grenzelhoft/mage
	name = "Gefechtsgelehrter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grenzelhoft/mage
	desc = "You are a Gefechtsgelehrter - \"Combat Scholar\" - An experienced Zauberer hailing from the prestigious Celestial Academy, your fellow alumni may have pursued summoning, enchantments or similar academical ventures. But you? You studied siegecraft. And you got damn good at it too."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grenzelhoft/mage
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_STEELHEARTED,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MAGEDEXTERITY,
		TRAIT_OUTLANDER,
		TRAIT_ARCYNE,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_PERCEPTION = 2, ROGUE_STAT_INTELLIGENCE = 2, ROGUE_STAT_SPEED = -1, ROGUE_STAT_STRENGTH = -1, ROGUE_STAT_CONSTITUTION = -2),
		"skills" = list(/datum/attribute/skill/magic/arcane = 50),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/gronnheavy
	name = "Khuyagtan"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/platelegs/iron/gronn
	suit = /obj/item/clothing/suit/roguetown/armor/plate/iron/gronn
	cloak = /obj/item/clothing/cloak/volfmantle
	head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/gronn
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron/gronn
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron/gronn
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/mace/maul
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/gronnheavy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = -3,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/mercenary/gronnheavy
	name = "Khuyagtan"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/gronnheavy
	desc = "Even within Northern Empty, few bear witness to the Horned Visages of the Khuyagtan; Ironclad warriors who stand against the undead armies that rise out of the 'Red Blizzard'. Those who do not have the blessing of the Zayran Shamans within the Northern Empty oft-seek the protection of the Khuyagtan, despite their steep costs."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/gronnheavy
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 2
	rogue_subclass_languages = list("/datum/language/gronnic")

/datum/outfit/job/roguetown/rockhill_class/mercenary/grudgebearer
	name = "Grudgebearer Smith"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/dwarven/smith
	cloak = /obj/item/clothing/cloak/forrestercloak/snow
	head = /obj/item/clothing/head/roguetown/helmet/heavy/dwarven/smith
	gloves = /obj/item/clothing/gloves/roguetown/plate/dwarven
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/dwarven
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch
	r_pocket = /obj/item/rogueweapon/mace
	r_hand = /obj/item/rogueweapon/mace/goden/steel
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/paper/scroll/grudge = 1,
		/obj/item/natural/feather = 1,
		/obj/item/rogueweapon/tongs = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grudgebearer
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 40,
		/datum/attribute/skill/craft/blacksmithing = 40,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/weaponsmithing = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/mercenary/grudgebearer
	name = "Grudgebearer Smith"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grudgebearer
	desc = "Bound by eternal grudges of eons past that have not been forgotten, the Grudgebearers are left to wander the surface, as every other clan has a grudge against you, and you against them. This putrid swampland of a Duchy has also wronged you and your people, you care little for it. Coins are a means to an end -- something you can mine and forge yourself. Trinkets -- made by true smiths, now that will carry respect among your clan. However, such artifacts might not buy you food, or a roof."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grudgebearer
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_TRAINED_SMITH,
		TRAIT_STEELHEARTED,
		TRAIT_SMITHING_EXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dwarf", "/datum/species/dwarf/mountain")

/datum/outfit/job/roguetown/rockhill_class/mercenary/grudgebearer/soldier
	name = "Grudgebearer Soldier"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/dwarven
	cloak = /obj/item/clothing/cloak/forrestercloak/snow
	head = /obj/item/clothing/head/roguetown/helmet/heavy/dwarven
	gloves = /obj/item/clothing/gloves/roguetown/plate/dwarven
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/dwarven
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/stoneaxe/battle
	l_pocket = /obj/item/flashlight/flare/torch
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/paper/scroll/grudge = 1,
		/obj/item/natural/feather = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/grudgebearer/soldier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 5,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 4,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 30,
		/datum/attribute/skill/craft/weaponsmithing = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/mercenary/grudgebearer/soldier
	name = "Grudgebearer Soldier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/grudgebearer/soldier
	desc = "Bound by eternal grudges of eons past that have not been forgotten, the Grudgebearers are left to wander the surface, as every other clan has a grudge against you, and you against them. This putrid swampland of a Duchy has also wronged you and your people, you care little for it. Coins are a means to an end -- something you can mine and forge yourself. Trinkets -- made by true smiths, now that will carry respect among your clan. However, such artifacts might not buy you food, or a roof."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/grudgebearer/soldier
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dwarf", "/datum/species/dwarf/mountain")

/datum/outfit/job/roguetown/rockhill_class/mercenary/newmoon
	name = "New Moon Spellblade"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/newmoon
	suit = /obj/item/clothing/suit/roguetown/armor/leather/newmoon_jacket
	head = /obj/item/clothing/head/roguetown/roguehood/reinforced/newmoon
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	wrists = /obj/item/clothing/neck/roguetown/psicross/noc
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/sabre/newmoon
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/lockpick = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/newmoon
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/mercenary/newmoon
	name = "New Moon Spellblade"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/newmoon
	desc = "The New Moon Spellblades of Zybantia are the remnants of a fallen Nocite monastery in an unknown region of Lalvestine, the last major stronghold of the Ten in the Zybantian Empire. Their monastic lyfestyle and devotion collapsed quickly under the weight of the Rot, and they were forced from a lyfe of devout solitude into that of a common sellsword; Noc�s blessings proving rather useful when slaying monsters and men alike. For whatever reason, you find yourself in the region, offering your skills to the highest bidder. Knowledge is power."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/newmoon
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_ARCYNE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/tabaxi", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/elf/wood", "/datum/species/tieberian")
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/mercenary/oathmarked
	name = "Oathmarked Sentinel"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/platelegs/oathmarked
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/oathmarked
	cloak = /obj/item/clothing/cloak/cape/oathmarked
	head = /obj/item/clothing/head/roguetown/helmet/heavy/oathmarked
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/plate/oathmarked
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/astrata/oathmarked
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/oathmarked
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_hand = /obj/item/rogueweapon/eaglebeak/oathmarked
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/book/rogue/secret/oathmarked = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/oathmarked
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = -3,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/oathmarked
	name = "Oathmarked Sentinel"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/oathmarked
	desc = "You're a sentinel of the Oathmarked. Trained in use of your order's unique polearms and plate wearing."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/oathmarked
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_SCALEARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dracon")
	rogue_social_rank = 4
	rogue_stashed_items = list(
		"Writ of Service" = /obj/item/merctoken,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/oathmarked/executor
	name = "Oathmarked Executor"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/platelegs/oathmarked
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/oathmarked
	cloak = /obj/item/clothing/cloak/cape/oathmarked
	head = /obj/item/clothing/head/roguetown/helmet/heavy/oathmarked
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	gloves = /obj/item/clothing/gloves/roguetown/plate/oathmarked
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/astrata/oathmarked
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/oathmarked
	belt = /obj/item/storage/belt/rogue/leather/steel
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_hand = /obj/item/rogueweapon/greatsword/grenz/oathmarked
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/book/rogue/secret/oathmarked = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/oathmarked/executor
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = -2,
		ROGUE_STAT_STRENGTH = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/mercenary/oathmarked/executor
	name = "Oathmarked Executor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/oathmarked/executor
	desc = "You're an executor of the Oathmarked. Trained in use of your order's unique swords and plate wearing."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/oathmarked/executor
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_SCALEARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dracon")
	rogue_social_rank = 4
	rogue_stashed_items = list(
		"Writ of Service" = /obj/item/merctoken,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/routier
	name = "Otavan Routiers"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	suit = /obj/item/clothing/suit/roguetown/armor/plate/otavan
	head = /obj/item/clothing/head/roguetown/helmet/otavan
	neck = /obj/item/clothing/neck/roguetown/fencerguard
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	l_hand = /obj/item/rogueweapon/sword/short/falchion
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/routier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 4,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/routier
	name = "Otavan Routiers"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/routier
	desc = "The Routiers are a formidable Otavan mercenary band, a brotherhood of knights from noble families serving lords who seek to profit in peacetime. The Otavan nobility at large and even some of the clergy eagerly awaits to hear about your feats, they expect you to ENDURE, to be the champion of their faith and represent the true values of nobility, will you?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/routier
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/ooze")
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/mercenary/rumaclan
	name = "Ruma Clan Gun-in"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/easttats
	suit = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	cloak = /obj/item/clothing/cloak/eastcloak1
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/sword/sabre/mulyeog/rumahench
	r_pocket = /obj/item/rogueweapon/scabbard/sword/kazengun/steel
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kazengun = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/rumaclan
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/mercenary/rumaclan
	name = "Ruma Clan Gun-in"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/rumaclan
	desc = "A swordfighter from a band of Kazengite foreigners. The Ruma Clan were outcasts from the Xinyi Dynasty, believed to be associated with the rebels at the time. The clan departed to avoid repercussion. It is no organized group of soldiers, but rather a loose collection of experienced fighters."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/rumaclan
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_HARDDISMEMBER,
		TRAIT_NOPAINSTUN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid")
	rogue_subclass_languages = list("/datum/language/kazengunese")

/datum/outfit/job/roguetown/rockhill_class/mercenary/rumaclan/sasu
	name = "Ruma Clan Sasu"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/easttats
	suit = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	cloak = /obj/item/clothing/cloak/eastcloak1
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kazengun = 1,
		/obj/item/rogueweapon/scabbard/sheath/kazengun = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/rumaclan/sasu
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 4,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/mercenary/rumaclan/sasu
	name = "Ruma Clan Sasu"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/rumaclan/sasu
	desc = "An archer from a band of Kazengite foreigners. The Ruma Clan were outcasts from the Xinyi Dynasty, believed to be associated with the rebels at the time. The clan departed to avoid repercussion. It is no organized group of soldiers, but rather a loose collection of experienced fighters."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/rumaclan/sasu
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_HARDDISMEMBER,
		TRAIT_NOPAINSTUN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/harpy", "/datum/species/construct/metal", "/datum/species/construct/metal/porcelain", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/arachnid")
	rogue_subclass_languages = list("/datum/language/kazengunese")

/datum/outfit/job/roguetown/rockhill_class/mercenary/steppesman
	name = "Liga Aavnik"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/chargah
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale/steppe
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	head = /obj/item/clothing/head/roguetown/helmet/sallet/shishak
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot/steppesman
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron/steppesman
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/sabre/steppesman
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/whip/nagaika = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/steppesman
	raw_attribute_list = list(
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/steppesman
	name = "Liga Aavnik"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/steppesman
	desc = "As part of your mandatory service to your Kozak's Hetmen, your yearly rotation brings you from service in the Motherland's Vanguard, to serve in the Liga Aavnik, the unified mercenary army of the Northern Steppe, with you; taking part in the Ferentine front. Bring gold, and glory to the homeland. Chest' cherez pobedu."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/steppesman
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/aavnic")

/datum/outfit/job/roguetown/rockhill_class/mercenary/vaquero
	name = "Vaquero"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/half/rider/red
	head = /obj/item/clothing/head/roguetown/bardhat
	mouth = /obj/item/alch/rosa
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	l_hand = /obj/item/rogueweapon/sword/rapier/vaquero
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying/vaquero
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/lockpick = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/vaquero
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/mercenary/vaquero
	name = "Vaquero"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/vaquero
	desc = "Originating in the vibrant Kingdom of Etrusca, a 'vaquero' had originally been a mere cattle-driver... Now, though, it has become a title for roaming swashbucklers. Whether they set out as a defender of the commonfolk or a pilferer of purses, the Vaquero is defined by the tale they carve across continents - and more frequently - by their story's violent end."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/vaquero
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_MEDIUMARMOR,
		TRAIT_EQUESTRIAN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/etruscan")

/datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar
	name = "Naledi Hierophant"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/hierophant
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant
	cloak = /obj/item/clothing/cloak/hierophant
	head = /obj/item/clothing/head/roguetown/roguehood/hierophant
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi
	wrists = /obj/item/clothing/neck/roguetown/psicross/naledi
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/flashlight/flare/torch
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_hand = /obj/item/rogueweapon/woodstaff/implement/grand/naledi
	backpack_contents = list(
		/obj/item/chalk = 1,
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/spellbook/greater = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/arcyne = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/staves = 40,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/warscholar
	name = "Naledi Hierophant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar
	desc = "You are a Naledi Hierophant, the most orthodox of all Naledian Magi to an outsider. You practice the art of Exomagic - channeling mana outward for both destructive and constructive purposes. Many of your kinds prioritize enhancing the potential of their teammates from behind, believing in the superiority and potent of the humen body. Some however, may take a more direct approach to the question of how to lay low Psydon's foes - incineration and annihilation."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NALEDI,
		TRAIT_MAGEDEXTERITY,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_PERCEPTION = 1, ROGUE_STAT_INTELLIGENCE = 1, ROGUE_STAT_SPEED = -1),
		"skills" = list(/datum/attribute/skill/magic/arcane = 50),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar/pontifex
	name = "Naledi Pontifex"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather/pontifex
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/pointfex
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/pontifex
	head = /obj/item/clothing/head/roguetown/roguehood/pontifex
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi
	gloves = /obj/item/clothing/gloves/roguetown/angle/pontifex
	wrists = /obj/item/clothing/neck/roguetown/psicross/naledi
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/flashlight/flare/torch
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/chalk = 1,
		/obj/item/roguekey/mercenary = 1,
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/spellbook/greater = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar/pontifex
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/arcyne = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/warscholar/pontifex
	name = "Naledi Pontifex"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar/pontifex
	desc = "A Naledi Pontifex, trained in the discipline of Automagic - enhancement of one's own body through Arcyne Magick. Your fists and your will are the one thing that cannot be deprived from you, handy tools when your homeland is rife with treacherous djinns and humens alike. Where your fists fall short, your wits prevail. Where your magyck falters, your fists answer. And when both are found wanting, the Naledian art of blade conjuration will lend you a Katar to cut demons and humens alike to ribbons."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar/pontifex
	rockhill_traits = list(
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_ARCYNE,
		TRAIT_NALEDI,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial", "/datum/language/thievescant")
	rogue_age_mod = list(
		"age" = "Old",
		"utility" = 6,
		)

/datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar/vizier
	name = "Naledi Vizier"
	jobtype = /datum/job/roguetown/mercenary
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/hierophant
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/pontifex
	cloak = /obj/item/clothing/cloak/hierophant
	head = /obj/item/clothing/head/roguetown/roguehood/hierophant
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi
	wrists = /obj/item/clothing/neck/roguetown/psicross/naledi
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/flashlight/flare/torch
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_hand = /obj/item/rogueweapon/woodstaff/implement/grand/naledi
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar/vizier
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/mercenary/warscholar/vizier
	name = "Naledi Vizier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/mercenary/warscholar/vizier
	desc = "You are a Naledi Vizier. Your research into miracles and holy incantations has lead you to esoteric magycks. Though psydonians have long struggled to channel their all-father's divinity, The Great City of Naledi came the closest with its Origin Magic."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/mercenary/warscholar/vizier
	rockhill_traits = list(
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NALEDI,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_MAGEDEXTERITY,
		TRAIT_ARCYNE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_PERCEPTION = 1, ROGUE_STAT_INTELLIGENCE = 1, ROGUE_STAT_SPEED = -1),
		"skills" = list(/datum/attribute/skill/magic/arcane = 50),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/merchantEA
	name = "EA Hasir-ian Merchant"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leathertights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	head = /obj/item/clothing/head/roguetown/chaperon/noble
	neck = /obj/item/clothing/neck/roguetown/horus
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/veryrich
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/merchantEA
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 20,
		)

/datum/rockhill_advclass/merchantEA
	name = "EA Hasir-ian Merchant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/merchantEA
	desc = "You were born into wealth, learning from before you could talk about the basics of mathematics. Counting coins is a simple pleasure for any person, but you've made it an art form. EA-Hasir has entrusted you with some of his highest quality gold products- Make him proud, Rob 'em all blind."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/merchantEA
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/miner
	name = "Miner"
	jobtype = /datum/job/roguetown/pilgrim
	head = /obj/item/clothing/head/roguetown/armingcap
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/rogueweapon/pick
	r_pocket = /obj/item/storage/hip/orestore/bronze
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/rogueweapon/hammer/wood = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/hip/orestore/bronze = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/miner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/labor/mining = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/miner
	name = "Miner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/miner
	desc = "Swing the pick. Heave. Swing. Heave. Deep underground where the days lose their meaning, the work is grueling, the tunnels cramped, and the stale air full of coal dust, yet tales abound of the lucky few who persevered, and found enough precious gems to set them for life."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/miner
	rockhill_traits = list(
		TRAIT_DARKVISION,
		TRAIT_SMITHING_EXPERT,
		TRAIT_LEGENDARY_MINER,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/minstrel
	name = "Minstrel"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white
	cloak = /obj/item/clothing/cloak/half
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/cloth
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger
	r_hand = /obj/item/rogue/instrument/accord
	backpack_contents = list(
		/obj/item/rogue/instrument/lute = 1,
		/obj/item/rogue/instrument/flute = 1,
		/obj/item/rogue/instrument/drum = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/minstrel
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/music = 50,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/minstrel
	name = "Minstrel"
	outfit = /datum/outfit/job/roguetown/rockhill_class/minstrel
	desc = "Unlike those so-called 'bards' who traipse around in fancy cloth and swordfight in the woods, you follow the calling of a true musician. You've simply... yet to find a receptive audience."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/minstrel
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/nightmaiden
	name = "Bath Attendant"
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

/datum/attribute_holder/sheet/job/rockhill_class/nightmaiden
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/music = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/nightmaiden
	name = "Bath Attendant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/nightmaiden
	desc = "A fresh initiate, most would decry the humble bath maid as a desperate fool tempting others into bedsheets for money--only sometimes, you say! You work underneath your betters in the communal bathhouse, keeping it and the guests in turn as tidy as they please. Wash laundry, tend mild wounds, and deftly wash your patrons with soap, for this is your craft."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/nightmaiden
	rockhill_traits = list(
		TRAIT_NUTCRACKER,
		TRAIT_CICERONE,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_BATHHOUSE_DANCER,
		)

/datum/outfit/job/roguetown/rockhill_class/nightmaiden/concubine
	name = "Concubine"
	jobtype = /datum/job/roguetown/nightmaiden
	uniform = /obj/item/clothing/under/roguetown/trou/leathertights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
	neck = /obj/item/clothing/neck/roguetown/collar/catbell
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/roguekey/nightmaiden
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/rope = 1,
		/obj/item/candle/eora = 1,
		/obj/item/rogueweapon/whip = 1,
		/obj/item/clothing/mask/rogue/blindfold = 1,
		/obj/item/mini_flagpole/bathhouse = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/nightmaiden/concubine
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/nightmaiden/concubine
	name = "Concubine"
	outfit = /datum/outfit/job/roguetown/rockhill_class/nightmaiden/concubine
	desc = "Unlike your fellow bath attendants who maintain a professional facade, you have abandoned all pretense. You are a prized possession of the nobility, adorned in exotic silks and gold. Your role is to provide companionship, entertainment, and pleasure. Working underneath the finespun courtesans, you're a step above the bath attendants in your craft."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/nightmaiden/concubine
	rockhill_traits = list(
		TRAIT_LIGHT_STEP,
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_BATHHOUSE_DANCER,
		)

/datum/outfit/job/roguetown/rockhill_class/nightmaiden/courtesan
	name = "Courtesan"
	jobtype = /datum/job/roguetown/nightmaiden
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	head = /obj/item/lockpick/goldpin
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/roguekey/nightmaiden
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/reagent_containers/powder/moondust = 2,
		/obj/item/reagent_containers/glass/bottle/rogue/wine = 1,
		/obj/item/toy/cards/deck = 1,
		/obj/item/mini_flagpole/bathhouse = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/nightmaiden/courtesan
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/nightmaiden/courtesan
	name = "Courtesan"
	outfit = /datum/outfit/job/roguetown/rockhill_class/nightmaiden/courtesan
	desc = "Overcoming mind games, deceit and competition, you came into your own as one of the bathhouse's most prized moneymakers and socialites. Dressed in lavish gifts left behind by your patrons, not just anyone can have you. Under the matron, you do most of the social heavylifting and provide entertainment of all forms - behind a heavy price tag. "
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/nightmaiden/courtesan
	rockhill_traits = list(
		TRAIT_KEENEARS,
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_BATHHOUSE_DANCER,
		)

/datum/outfit/job/roguetown/rockhill_class/noble
	name = "Aristocrat"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/red
	cloak = /obj/item/clothing/cloak/half/red
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/sword/sabre/dec
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	l_hand = /obj/item/rogueweapon/scabbard/sword/noble

/datum/attribute_holder/sheet/job/rockhill_class/noble
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/music = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/noble
	name = "Aristocrat"
	outfit = /datum/outfit/job/roguetown/rockhill_class/noble
	desc = "You are a traveling noble visiting foreign lands. With wealth, come the poor, ready to pilfer you of your hard earned (inherited) coin, so tread lightly unless you want to meet a grizzly end."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/noble
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_EXPERT_HUNTER,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 5

/datum/outfit/job/roguetown/rockhill_class/noble/knighte
	name = "Knight Errant"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine
	cloak = /obj/item/clothing/cloak/stabard
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/sword/long
	r_hand = /obj/item/rogueweapon/scabbard/sword/noble
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/noble/knighte
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/noble/knighte
	name = "Knight Errant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/noble/knighte
	desc = "You are a knight from a distant land, a scion of a noble house visiting these lands for one reason or another."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/noble/knighte
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 4
	rogue_stashed_items = list(
		"Caparison (Saiga)" = /obj/item/caparison,
		"Caparison (Fogbeast)" = /obj/item/caparison/fogbeast,
		)

/datum/outfit/job/roguetown/rockhill_class/noble/squire
	name = "Squire Errant"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/stabard
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/sword/noble
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/sword/iron
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/armor_brush = 1,
		/obj/item/polishing_cream = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/noble/squire
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/noble/squire
	name = "Squire Errant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/noble/squire
	desc = "You are a squire who has traveled far in search of a master to train you and a lord to knight you."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/noble/squire
	rockhill_traits = list(
		TRAIT_SQUIRE_REPAIR,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/nudist
	name = "Nudist"
	jobtype = /datum/job/roguetown/rockhill_migrant
	neck = /obj/item/clothing/neck/roguetown/psicross/dendor
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/rope
	l_pocket = /obj/item/rogueweapon/huntingknife/stoneknife

/datum/attribute_holder/sheet/job/rockhill_class/nudist
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/nudist
	name = "Nudist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/nudist
	desc = "They say that the most devout of Dendor forgo clothing in order to weather their body to the natural elements. You happen to be one of them!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/nudist
	rogue_allowed_patrons = list(/datum/patron/divine/dendor)

/datum/outfit/job/roguetown/rockhill_class/otavan_envoy
	name = "Émissaire"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/stabard/surcoat/bailiff
	head = /obj/item/clothing/head/roguetown/circlet
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	l_hand = /obj/item/rogueweapon/sword/sabre
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/paper/scroll/writ_of_esteem/otavan = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/otavan_envoy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/otavan_envoy
	name = "Émissaire"
	outfit = /datum/outfit/job/roguetown/rockhill_class/otavan_envoy
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/otavan_envoy
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_DODGEEXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/otavan_guard
	name = "Otavan Arbalétrier"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	cloak = /obj/item/clothing/cloak/stabard/surcoat
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/quiver/bolts
	l_hand = /obj/item/rogueweapon/sword
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/otavan_guard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/otavan_guard
	name = "Otavan Arbalétrier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/otavan_guard
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/otavan_guard
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/otavan_knight
	name = "Gendarme"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	suit = /obj/item/clothing/suit/roguetown/armor/plate/otavan
	head = /obj/item/clothing/head/roguetown/helmet/otavan
	neck = /obj/item/clothing/neck/roguetown/fencerguard
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	l_hand = /obj/item/rogueweapon/sword/short/falchion
	r_hand = /obj/item/rogueweapon/spear/otava
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/otavan_knight
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/otavan_knight
	name = "Gendarme"
	outfit = /datum/outfit/job/roguetown/rockhill_class/otavan_knight
	desc = "Whether through merit, blood or renown, you became a knight in service of the Otavan court. Now, tasked with escorting the Émissaire and protecting them at all cost, you ride into these lands."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/otavan_knight
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_NOBLE,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/otavan_preacher
	name = "Psydonite Preacher"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	cloak = /obj/item/clothing/cloak/psydontabard/alt
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	gloves = /obj/item/clothing/gloves/roguetown/bandages/weighted
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/book/rogue/bibble/psy
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/woodstaff/quarterstaff/psy
	backpack_contents = list(
		/obj/item/needle = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami = 1,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/redwine = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/otavan_preacher
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/otavan_preacher
	name = "Psydonite Preacher"
	outfit = /datum/outfit/job/roguetown/rockhill_class/otavan_preacher
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/otavan_preacher
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_STEELHEARTED,
		TRAIT_SILVER_BLESSED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/otavan_scribe
	name = "Otavan Scribe"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	suit = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	cloak = /obj/item/clothing/cloak/half
	mask = /obj/item/clothing/mask/rogue/spectacles
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	l_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/huntingknife/idagger
	backpack_contents = list(
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 4,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/otavan_scribe
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 60,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/otavan_scribe
	name = "Otavan Scribe"
	outfit = /datum/outfit/job/roguetown/rockhill_class/otavan_scribe
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/otavan_scribe
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_CICERONE,
		TRAIT_INTELLECTUAL,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/otavan")

/datum/outfit/job/roguetown/rockhill_class/peasant
	name = "Farmer"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/armor/workervest
	head = /obj/item/clothing/head/roguetown/armingcap
	mouth = /obj/item/rogueweapon/huntingknife
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/hoe
	l_pocket = /obj/item/rogueweapon/sickle
	r_pocket = /obj/item/flint
	backpack_contents = list(
		/obj/item/seeds/wheat = 3,
		/obj/item/seeds/apple = 3,
		/obj/item/ash = 3,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/peasant
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 40,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/medicine = 10,
		)

/datum/rockhill_advclass/peasant
	name = "Farmer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/peasant
	desc = "As a Peasant, you are a skilled farmer, able to grow a variety of crops Join the local Soilsmen at their farm, or make your own little orchard."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/peasant
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/potter
	name = "Potter"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	cloak = /obj/item/clothing/cloak/apron/blacksmith
	head = /obj/item/clothing/head/roguetown/hatblu
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/shovel
	l_pocket = /obj/item/rogueweapon/blowrod
	r_pocket = /obj/item/rogueweapon/tongs
	backpack_contents = list(
		/obj/item/natural/clay = 8,
		/obj/item/natural/clay/glassbatch = 2,
		/obj/item/rogueore/coal = 1,
		/obj/item/dye_brush = 1,
		/obj/item/storage/roguebag = 1,
		/obj/item/recipe_book/ceramics = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/potter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/ceramics = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/masonry = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/potter
	name = "Potter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/potter
	desc = "You are a skilled artisan in the manipulation of ceramics, and their fashioning into a multitude of different objects and valuables, including glass."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/potter
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/prisoner_blacksmith
	name = "Prisoner Blacksmith"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_blacksmith
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 50,
		/datum/attribute/skill/craft/blacksmithing = 50,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/weaponsmithing = 50,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/prisoner_blacksmith
	name = "Prisoner Blacksmith"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_blacksmith
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_blacksmith
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_butcher
	name = "Prisoner Butcher"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_butcher
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 10,
		/datum/attribute/skill/labor/butchering = 50,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		)

/datum/rockhill_advclass/prisoner_butcher
	name = "Prisoner Butcher"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_butcher
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_butcher

/datum/outfit/job/roguetown/rockhill_class/prisoner_carpenter
	name = "Prisoner Carpenter"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_carpenter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/engineering = 30,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/labor/lumberjacking = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/prisoner_carpenter
	name = "Prisoner Carpenter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_carpenter
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_carpenter

/datum/outfit/job/roguetown/rockhill_class/prisoner_cheesemaker
	name = "Prisoner Cheesemaker"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_cheesemaker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		)

/datum/rockhill_advclass/prisoner_cheesemaker
	name = "Prisoner Cheesemaker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_cheesemaker
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_cheesemaker

/datum/outfit/job/roguetown/rockhill_class/prisoner_drunkard
	name = "Prisoner Gambler"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_drunkard
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/prisoner_drunkard
	name = "Prisoner Gambler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_drunkard
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_drunkard

/datum/outfit/job/roguetown/rockhill_class/prisoner_farmer
	name = "Prisoner Farmer"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_farmer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 50,
		/datum/attribute/skill/labor/farming = 50,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		)

/datum/rockhill_advclass/prisoner_farmer
	name = "Prisoner Farmer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_farmer
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_farmer
	rockhill_traits = list(
		TRAIT_SEEDKNOW,
		TRAIT_NOSTINK,
		TRAIT_LONGSTRIDER,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_hunter
	name = "Prisoner Hunter"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_hunter
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/labor/fishing = 10,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/prisoner_hunter
	name = "Prisoner Hunter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_hunter
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_hunter
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_DODGEEXPERT,
		TRAIT_WOODSMAN,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_miner
	name = "Prisoner Miner"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_miner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/labor/mining = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/prisoner_miner
	name = "Prisoner Miner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_miner
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_miner
	rockhill_traits = list(
		TRAIT_DARKVISION,
		TRAIT_LEGENDARY_MINER,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_minstrel
	name = "Prisoner Minstrel"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_minstrel
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/prisoner_minstrel
	name = "Prisoner Minstrel"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_minstrel
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_minstrel
	rockhill_traits = list(
		TRAIT_KEENEARS,
		TRAIT_GOODLOVER,
		TRAIT_EMPATH,
		TRAIT_BEAUTIFUL,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_potter
	name = "Prisoner Potter"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_potter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/ceramics = 50,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/masonry = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/prisoner_potter
	name = "Prisoner Potter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_potter
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_potter

/datum/outfit/job/roguetown/rockhill_class/prisoner_seamstress
	name = "Prisoner Seamster"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_seamstress
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/prisoner_seamstress
	name = "Prisoner Seamster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_seamstress
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_seamstress

/datum/outfit/job/roguetown/rockhill_class/prisoner_thug
	name = "Prisoner Thug"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_thug
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/labor/mining = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/prisoner_thug
	name = "Prisoner Thug"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_thug
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_thug

/datum/outfit/job/roguetown/rockhill_class/prisoner_towndoctor
	name = "Prisoner Barber Surgeon"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_towndoctor
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 50,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 10,
		)

/datum/rockhill_advclass/prisoner_towndoctor
	name = "Prisoner Barber Surgeon"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_towndoctor
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_towndoctor
	rockhill_traits = list(
		TRAIT_EMPATH,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_witch
	name = "Prisoner Witch"
	jobtype = /datum/job/roguetown/prisonerr

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_witch
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/prisoner_witch
	name = "Prisoner Witch"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_witch
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_witch
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_DEATHSIGHT,
		TRAIT_WITCH,
		)

/datum/outfit/job/roguetown/rockhill_class/prisoner_woodcutter
	name = "Prisoner Woodcutter"
	jobtype = /datum/job/roguetown/prisonerr
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random

/datum/attribute_holder/sheet/job/rockhill_class/prisoner_woodcutter
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/music = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/prisoner_woodcutter
	name = "Prisoner Woodcutter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/prisoner_woodcutter
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/prisoner_woodcutter
	rockhill_traits = list(
		TRAIT_BANDITCAMP,
		)

/datum/outfit/job/roguetown/rockhill_class/psyaltrist
	name = "Psyaltrist"
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded/psyaltrist
	cloak = /obj/item/clothing/cloak/psyaltrist
	head = /obj/item/clothing/head/roguetown/helmet/leather/chapeau
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/rogue/instrument/accord
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/psydagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/psyaltrist
	raw_attribute_list = list(
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/music = 50,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/psyaltrist
	name = "Psyaltrist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/psyaltrist
	desc = "You spent some time with cathedral choirs and psyaltrists. Now you spend your days applying the musical arts to the practical on behalf of His most Holy of Inquisitions."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/psyaltrist
	rockhill_traits = list(
		TRAIT_EMPATH,
		TRAIT_DODGEEXPERT,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_social_rank = 2
	rogue_stashed_items = list(
		"Of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/psydoniantemplar
	name = "Adjudicator"
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

/datum/attribute_holder/sheet/job/rockhill_class/psydoniantemplar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/psydoniantemplar
	name = "Adjudicator"
	outfit = /datum/outfit/job/roguetown/rockhill_class/psydoniantemplar
	desc = "Psydonite knights, clad in fluted chainmaille and blessed with the capacity to invoke lesser miracles. In lieu of greater miracles and rituals, they compensate through martial discipline and blessed weaponry."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/psydoniantemplar
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_social_rank = 4
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/puritan/arbiter
	name = "Arbiter"
	jobtype = /datum/job/roguetown/puritan
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/arbiter
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/arbiter
	cloak = /obj/item/clothing/cloak/cape/inquisitor
	mask = /obj/item/clothing/mask/rogue/sack/psy/arbiter
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	belt = /obj/item/storage/belt/rogue/leather/arbiter
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/storage/keyring/puritan = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/psydagger = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		/obj/item/paper/inqslip/arrival/inq = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/puritan/arbiter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 50,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/puritan/arbiter
	name = "Arbiter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/puritan/arbiter
	desc = "Unlike Ordinators or Inspectors, Arbiters serve an entirely different purpose. Drawn from a flock of warrior-priests, they still fight to this day within rot-scoured lands. Uniquely attuned to the rot's touch. Armed with the purported \"miracles\" of the LYVING GOD, arcane lux manipulations of the orders of the Saints Pestra & Noc, the Arbiter seeks the unholy, the heretic, and the rotted."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/puritan/arbiter
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		TRAIT_SILVER_BLESSED,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_INQUISITION,
		TRAIT_PURITAN,
		TRAIT_OUTLANDER,
		TRAIT_NOBLE,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/puritan/inspector
	name = "Inspector"
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

/datum/attribute_holder/sheet/job/rockhill_class/puritan/inspector
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 50,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/puritan/inspector
	name = "Inspector"
	outfit = /datum/outfit/job/roguetown/rockhill_class/puritan/inspector
	desc = "Investigators and diplomats, oft-selected from Confessors who've shown their aptitude in a variety of skills. A precise strike is all that's needed to forward the Orthodoxy's missive; whether it's struck with a diplomat's charm or a rapier's tip, however, is up to you."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/puritan/inspector
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
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/puritan/ordinator
	name = "Ordinator"
	jobtype = /datum/job/roguetown/puritan
	uniform = /obj/item/clothing/under/roguetown/platelegs
	shirt = /obj/item/clothing/suit/roguetown/armor/leather/studded/cuirbouilli
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/fluted/ornate/ordinator
	cloak = /obj/item/clothing/cloak/ordinatorcape
	head = /obj/item/clothing/head/roguetown/helmet/heavy/ordinatorhelm
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psychains
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	belt = /obj/item/storage/belt/rogue/leather/steel/tasset
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/rich
	backpack_contents = list(
		/obj/item/storage/keyring/puritan = 1,
		/obj/item/paper/inqslip/arrival/inq = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/puritan/ordinator
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/puritan/ordinator
	name = "Ordinator"
	outfit = /datum/outfit/job/roguetown/rockhill_class/puritan/ordinator
	desc = "Adjudicator-Sergeants, hailing from the neighboring Psydonic Orders. Oft-mistaken for golems due to the lethargy imposed by their blessed plate armor, these holy knights have forsaken every other pursuit for a singular purpose: to break the inhumen against their knee."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/puritan/ordinator
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_HEAVYARMOR,
		TRAIT_SILVER_BLESSED,
		TRAIT_INQUISITION,
		TRAIT_PURITAN,
		TRAIT_OUTLANDER,
		TRAIT_NOBLE,
		)
	rogue_subclass_languages = list("/datum/language/otavan")
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/ranger
	name = "Sentinel"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/hide
	cloak = /obj/item/clothing/cloak/raincloak/green
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/quiver/arrows
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/bait = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/ranger
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/fishing = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/ranger
	name = "Sentinel"
	outfit = /datum/outfit/job/roguetown/rockhill_class/ranger
	desc = "You are a ranger well-versed in traversing untamed lands, with years of experience taking odd jobs as a pathfinder and bodyguard in areas of wilderness untraversable to common soldiery."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/ranger
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTDOORSMAN,
		TRAIT_EXPERT_HUNTER,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/ranger/bombadier
	name = "Bombardier"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/mageorange
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/bmbstrap/firebomb
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/ranger/bombadier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_STRENGTH = 2,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		)

/datum/rockhill_advclass/ranger/bombadier
	name = "Bombardier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/ranger/bombadier
	desc = "Bombs? You've got them. Plenty of them - and the skills to make more. You've spent years training under skilled alchemists and have found the perfect mix to create some chaos - now go blow something up!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/ranger/bombadier
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_EXPLOSIVE_SUPPLY,
		TRAIT_BOMBER_EXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/ranger/bwanderer
	name = "Biome Wanderer"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy
	cloak = /obj/item/clothing/cloak/raincloak/green
	head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/quiver/arrows
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/ranger/bwanderer
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/tanning = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/ranger/bwanderer
	name = "Biome Wanderer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/ranger/bwanderer
	desc = "The dangers of the wilds vary upon the plains they rest upon, You happen to be experienced in many."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/ranger/bwanderer
	rockhill_traits = list(
		TRAIT_OUTDOORSMAN,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/ranger/wayfarer
	name = "Wayfarer"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/ranger/wayfarer
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/ranger/wayfarer
	name = "Wayfarer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/ranger/wayfarer
	desc = "You've spent countless years homing many trades; man-hunting, picking locks, breaking into places you had no right being.. but you are no mere thief. You are trained to track men and recover stolen goods. And these lands are a prime paycheck.."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/ranger/wayfarer
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/rogue
	name = "Treasure Hunter"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	head = /obj/item/clothing/head/roguetown/fedora
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shovel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/sword/sabre
	r_hand = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/rogue
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/rogue
	name = "Treasure Hunter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rogue
	desc = "You are a treasure hunter trained in hunting for valuables. Discern what is treasure or not, your fortune could be hidden anywhere."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rogue
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_SEEPRICES,
		TRAIT_GRAVEROBBER,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/rogue/bard
	name = "Bard"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/half/red
	head = /obj/item/clothing/head/roguetown/bardhat
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	backpack_contents = list(
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/rogue/bard
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/rogue/bard
	name = "Bard"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rogue/bard
	desc = "You make your fortune in brothels, flop houses, and taverns – gaining fame for your songs and legends. If there is any truth to them, that is."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rogue/bard
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_GOODLOVER,
		TRAIT_EMPATH,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/rogue/swashbuckler
	name = "Swashbuckler"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/tights/sailor
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	head = /obj/item/clothing/head/roguetown/helmet/tricorn
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/hurdygurdy
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/sword/cutlass
	backpack_contents = list(
		/obj/item/bomb = 1,
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/parrying = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/rogue/swashbuckler
	raw_attribute_list = list(
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/music = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/rogue/swashbuckler
	name = "Swashbuckler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rogue/swashbuckler
	desc = "You are a daring rogue of the seas! Swashbucklers wield agile swordplay and acrobatic prowess - fighting dirty to outmaneuver foes with flair."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rogue/swashbuckler
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_NUTCRACKER,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/rogue/thief
	name = "Thief"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	l_pocket = /obj/item/quiver/Warrows
	r_pocket = /obj/item/rogueweapon/mace/cudgel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/rogue/thief
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/rogue/thief
	name = "Thief"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rogue/thief
	desc = "You are a scoundrel and a thief. A master in getting into places you shouldn't be and taking things that aren't rightfully yours."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rogue/thief
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/rookie/backline
	name = "Backline Recruit"
	jobtype = /datum/job/roguetown/rookie
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/hammer/iron = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/rookie/backline
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/rookie/backline
	name = "Backline Recruit"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rookie/backline
	desc = "Keep your distance, watch carefully, and stick 'em when they ain't lookin'"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rookie/backline
	rockhill_traits = list(
		TRAIT_SQUIRE_REPAIR,
		TRAIT_GUARDSMAN,
		)

/datum/outfit/job/roguetown/rockhill_class/rookie/frontline
	name = "Frontline Recruit"
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

/datum/attribute_holder/sheet/job/rockhill_class/rookie/frontline
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/rookie/frontline
	name = "Frontline Recruit"
	outfit = /datum/outfit/job/roguetown/rockhill_class/rookie/frontline
	desc = "The quickest way to learn is also the deadliest."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/rookie/frontline
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_GUARDSMAN,
		)

/datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_commoner
	name = "Runaway Prisoner (commoner)"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	neck = /obj/item/clothing/neck/roguetown/gorget/cursed_collar

/datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_commoner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 3,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/butchering = 50,
		/datum/attribute/skill/labor/farming = 50,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/runaway_prisoner_commoner
	name = "Runaway Prisoner (commoner)"
	outfit = /datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_commoner
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_commoner
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		)

/datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_mage
	name = "Runaway Prisoner (Mage)"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	neck = /obj/item/clothing/neck/roguetown/gorget/cursed_collar

/datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_mage
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 3,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/labor/fishing = 10,
		/datum/attribute/skill/labor/mining = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/runaway_prisoner_mage
	name = "Runaway Prisoner (Mage)"
	outfit = /datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_mage
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_mage
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_ALCHEMY_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_noble
	name = "Runaway Prisoner (Noble)"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	suit = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	neck = /obj/item/clothing/neck/roguetown/gorget/cursed_collar

/datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_noble
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_FORTUNE = 3,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/runaway_prisoner_noble
	name = "Runaway Prisoner (Noble)"
	outfit = /datum/outfit/job/roguetown/rockhill_class/runaway_prisoner_noble
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/runaway_prisoner_noble
	rockhill_traits = list(
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		)

/datum/outfit/job/roguetown/rockhill_class/scavenger/harvester
	name = "Harvester"
	jobtype = /datum/job/roguetown/pilgrim
	head = /obj/item/clothing/head/roguetown/strawhat
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/
	l_pocket = /obj/item/rogueweapon/sickle
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/seeds/wheat = 2,
		/obj/item/seeds/apple = 1,
		/obj/item/ash = 3,
		/obj/item/seeds/potato = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/scavenger/harvester
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/scavenger/harvester
	name = "Harvester"
	outfit = /datum/outfit/job/roguetown/rockhill_class/scavenger/harvester
	desc = "Perhaps terrible fate befell your last homestead, or circumstances conspired to drive you away. Either way, the soil of these lands are rich and fertile, so you hear. Let us hope you can build something to last the winter."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/scavenger/harvester
	rockhill_traits = list(
		TRAIT_SEEDKNOW,
		TRAIT_HOMESTEAD_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/scavenger/prospector
	name = "Prospector"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	cloak = /obj/item/clothing/cloak/apron/blacksmith
	mouth = /obj/item/rogueweapon/huntingknife/bronze
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/rogueweapon/tongs
	r_pocket = /obj/item/rogueweapon/hammer/copper
	r_hand = /obj/item/rogueweapon/pick/copper
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/rogueore/coal = 4,
		/obj/item/rogueore/iron = 5,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/blacksmithing = 1,
		/obj/item/armor_brush = 1,
		/obj/item/polishing_cream = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/scavenger/prospector
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 20,
		/datum/attribute/skill/craft/blacksmithing = 30,
		/datum/attribute/skill/craft/carpentry = 10,
		/datum/attribute/skill/craft/ceramics = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 20,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 30,
		/datum/attribute/skill/craft/weaponsmithing = 20,
		/datum/attribute/skill/labor/mining = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/scavenger/prospector
	name = "Prospector"
	outfit = /datum/outfit/job/roguetown/rockhill_class/scavenger/prospector
	desc = "Following the promise of rich veins and scrap metal, you come to these lands to mine and smith, peddling wares to fellow iterant bog-wanderers. Only after building a forge for yourself, of course"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/scavenger/prospector
	rockhill_traits = list(
		TRAIT_SMITHING_EXPERT,
		TRAIT_TRAINED_SMITH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_LEGENDARY_MINER,
		)

/datum/outfit/job/roguetown/rockhill_class/seamstress
	name = "Seamster"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white
	suit = /obj/item/clothing/suit/roguetown/armor/armordress
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/needle
	r_pocket = /obj/item/rogueweapon/huntingknife/scissors
	backpack_contents = list(
		/obj/item/natural/cloth = 2,
		/obj/item/natural/bundle/fibers/full = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/needle/thorn = 1,
		/obj/item/book/rogue/swatchbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/seamstress
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		)

/datum/rockhill_advclass/seamstress
	name = "Seamster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/seamstress
	desc = "You know your trade by the passage of a needle through cloth and leather alike. Mend and sew garments for the townsfolk - Coats, pants, hats, hoods, and so much more. So what if you overcharge? You're the reason everyone looks good in the first place."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/seamstress
	rockhill_traits = list(
		TRAIT_SEWING_EXPERT,
		TRAIT_DYES,
		)
	maximum_slots = 20
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/seneschal/chiefbutler
	name = "Chief Butler"
	jobtype = /datum/job/roguetown/butler
	uniform = /obj/item/clothing/under/roguetown/trou/formal
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	suit = /obj/item/clothing/armor/gambeson/tailcoat
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/suspenders/butler
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/storage/keyring/servant

/datum/attribute_holder/sheet/job/rockhill_class/seneschal/chiefbutler
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/seneschal/chiefbutler
	name = "Chief Butler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/seneschal/chiefbutler
	desc = "You are the ruling class of butler and your ability to clear your throat and murmur 'I say' is without peer. Your duties and talents as seneschal remain the same, though."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/seneschal/chiefbutler
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		)

/datum/outfit/job/roguetown/rockhill_class/seneschal/headmaid
	name = "Head Maid"
	jobtype = /datum/job/roguetown/butler
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/maid
	cloak = /obj/item/clothing/cloak/apron/maid
	head = /obj/item/clothing/head/roguetown/maidband
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/storage/keyring/servant

/datum/attribute_holder/sheet/job/rockhill_class/seneschal/headmaid
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/seneschal/headmaid
	name = "Head Maid"
	outfit = /datum/outfit/job/roguetown/rockhill_class/seneschal/headmaid
	desc = "Whether you were promoted from one or just like the frills, you stylize yourself as a head maid. Your duties and talents remain the same, though."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/seneschal/headmaid
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		)

/datum/outfit/job/roguetown/rockhill_class/seneschal/seneschal
	name = "Seneschal"
	jobtype = /datum/job/roguetown/butler
	uniform = /obj/item/clothing/under/roguetown/trou/formal
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	suit = /obj/item/clothing/armor/gambeson/tailcoat
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/suspenders/butler
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/storage/keyring/servant

/datum/attribute_holder/sheet/job/rockhill_class/seneschal/seneschal
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/seneschal/seneschal
	name = "Seneschal"
	outfit = /datum/outfit/job/roguetown/rockhill_class/seneschal/seneschal
	desc = "While still expected to fill in for the duties of the household servantry as needed, you have styled yourself as a figure beyond them."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/seneschal/seneschal
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		)

/datum/outfit/job/roguetown/rockhill_class/servant/butler
	name = "Butler"
	jobtype = /datum/job/roguetown/servant
	uniform = /obj/item/clothing/under/roguetown/trou/formal/shorts
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/black
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/suspenders/butler
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/storage/keyring/servant

/datum/attribute_holder/sheet/job/rockhill_class/servant/butler
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/servant/butler
	name = "Butler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/servant/butler
	desc = "An impeccable appearance is your core being. You still dig through the mud, though, you just do the laundry more."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/servant/butler
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		TRAIT_HOMESTEAD_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/servant/maid
	name = "Maid"
	jobtype = /datum/job/roguetown/servant
	suit = /obj/item/clothing/suit/roguetown/shirt/dress/maid
	cloak = /obj/item/clothing/cloak/apron/maid
	head = /obj/item/clothing/head/roguetown/maidband
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/sash
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/storage/keyring/servant

/datum/attribute_holder/sheet/job/rockhill_class/servant/maid
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/servant/maid
	name = "Maid"
	outfit = /datum/outfit/job/roguetown/rockhill_class/servant/maid
	desc = "Not one really mentions how hard it is to do yardwork in a dress and stockings, but at least you still look really good."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/servant/maid
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		TRAIT_HOMESTEAD_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/servant/servant
	name = "Servant"
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

/datum/attribute_holder/sheet/job/rockhill_class/servant/servant
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/servant/servant
	name = "Servant"
	outfit = /datum/outfit/job/roguetown/rockhill_class/servant/servant
	desc = "You are a humdrum servant, dressed the part; lowly and best out of sight. It's practical, however."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/servant/servant
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_KEENEARS,
		TRAIT_SLEUTH,
		TRAIT_ROYALSERVANT,
		TRAIT_ROYAL_SUBSIDY,
		TRAIT_HOMESTEAD_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/sfighter
	name = "Battlemaster"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/random
	suit = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/sword/long
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/sfighter
	name = "Battlemaster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter
	desc = "You are a seasoned weapon specialist, clad in maille, with years of experience in warfare and battle under your belt."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/sfighter/amazon
	name = "Amazon"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/bikini
	suit = /obj/item/clothing/suit/roguetown/armor/leather/bikini
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/clothing/gloves/roguetown/knuckles
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter/amazon
	raw_attribute_list = list(
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/sfighter/amazon
	name = "Amazon"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter/amazon
	desc = "Fierce warrior women from distant lands, Amazons choose their armor based on their preferred fighting style - from light and agile to heavily protected."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter/amazon
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DEATHBYSNUSNU,
		)
	rogue_social_rank = 1

/datum/outfit/job/roguetown/rockhill_class/sfighter/barbarian
	name = "Barbarian"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs/skirt/bronze
	head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
	gloves = /obj/item/clothing/gloves/roguetown/bandages
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/barbarian
	back = /obj/item/storage/backpack/rogue/satchel
	r_hand = /obj/item/rogueweapon/katar/bronze
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife/bronze = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter/barbarian
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/tanning = 10,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/sfighter/barbarian
	name = "Barbarian"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter/barbarian
	desc = "You are a brutal warrior, who has foregone armor in favor of pure strength. Crush your enemies, see them driven before you, and hear the lamentations of their women! Oh, and you can specialize in unarmed combat and wrestling."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter/barbarian
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_OUTLANDER,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/sfighter/duelist
	name = "Duelist"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	suit = /obj/item/clothing/armor/leather/jacket/leathercoat/duelcoat
	cloak = /obj/item/clothing/cloak/duelistcape
	head = /obj/item/clothing/head/roguetown/duelisthat
	mask = /obj/item/clothing/mask/rogue/duelmask
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/buckler
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	l_hand = /obj/item/rogueweapon/sword/rapier
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/parrying = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/clothing/ring/duelist = 2,
		/obj/item/clothing/mask/rogue/spectacles/duelist = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter/duelist
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/sfighter/duelist
	name = "Duelist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter/duelist
	desc = "You are an esteemed swordsman who foregoes armor in exchange for a more nimble fighting style."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter/duelist
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DODGEEXPERT,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/sfighter/ironclad
	name = "Ironclad"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	neck = /obj/item/clothing/neck/roguetown/bevor/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/battleskirt/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/sword/long/exe
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/repair_kit/metal/bad = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter/ironclad
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/sfighter/ironclad
	name = "Ironclad"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter/ironclad
	desc = "You are a warrior who puts their trust in durable armor. The best offense is a good defense."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter/ironclad
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_HEAVYARMOR,
		TRAIT_OUTLANDER,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/sfighter/mhunter
	name = "Exorcist"
	jobtype = /datum/job/roguetown/adventurer
	uniform = /obj/item/clothing/under/roguetown/tights/puritan
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	suit = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	cloak = /obj/item/clothing/cloak/cape/puritan
	head = /obj/item/clothing/head/roguetown/puritan/armored
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver/undivided
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/silver
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/metal = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sfighter/mhunter
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/sfighter/mhunter
	name = "Exorcist"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sfighter/mhunter
	desc = "You are a specialist who hunts terrible monsters; nitebeasts, vampyres, deadites and more. Your humenity might be limiting - but with silver weapons and steel maille, you may yet slight the odds in your favor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sfighter/mhunter
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_PURITAN_ADVENTURER,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_EXPERT_HUNTER,
		TRAIT_OUTLANDER,
		)
	maximum_slots = 5
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/slave/house_slave
	name = "House Slave"
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

/datum/attribute_holder/sheet/job/rockhill_class/slave/house_slave
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/craft/ceramics = 30,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/music = 30,
		)

/datum/rockhill_advclass/slave/house_slave
	name = "House Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slave/house_slave
	desc = "You are trained as a servant, Keep the Master's abode clean, prepare meals, serve them."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slave/house_slave
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_OWNED_SLAVE,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slave/labor_slave
	name = "Labor Slave"
	jobtype = /datum/job/roguetown/rockhillslave
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	head = /obj/item/clothing/head/roguetown/headband
	neck = /obj/item/clothing/neck/roguetown/collar/leather
	wrists = /obj/item/clothing/wrists/roguetown/allwrappings
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/hip/orestore/bronze
	backr = /obj/item/rogueweapon/pick
	l_pocket = /obj/item/storage/keyring/rockhillslaves
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/stoneaxe/handaxe = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slave/labor_slave
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/craft/blacksmithing = 30,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 30,
		/datum/attribute/skill/labor/lumberjacking = 40,
		/datum/attribute/skill/labor/mining = 40,
		)

/datum/rockhill_advclass/slave/labor_slave
	name = "Labor Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slave/labor_slave
	desc = "You are trained as a laborer, Toil for the Master's needs, serve them."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slave/labor_slave
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SMITHING_EXPERT,
		TRAIT_LEGENDARY_MINER,
		TRAIT_OWNED_SLAVE,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slave/slave_sentry
	name = "Slave Sentry"
	jobtype = /datum/job/roguetown/rockhillslave
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	head = /obj/item/clothing/head/roguetown/helmet/sallet/iron
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/keyring/rockhillslaves
	r_hand = /obj/item/rogueweapon/spear

/datum/attribute_holder/sheet/job/rockhill_class/slave/slave_sentry
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		)

/datum/rockhill_advclass/slave/slave_sentry
	name = "Slave Sentry"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slave/slave_sentry
	desc = "You are trained as a fighter, Protect your Master's interests, serve them."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slave/slave_sentry
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_OWNED_SLAVE,
		)
	maximum_slots = 2
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slaver/master
	name = "Zybantynian Master"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	cloak = /obj/item/clothing/cloak/cape/purple
	head = /obj/item/clothing/head/roguetown/helmet/sallet/zyb
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/purple
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal/purple
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/flashlight/flare/torch/lantern/copper
	r_pocket = /obj/item/rogueweapon/whip/antique
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew = 2,
		/obj/item/needle = 1,
		/obj/item/rope/chain = 2,
		/obj/item/flint = 1,
		/obj/item/clothing/neck/roguetown/cursed_collar = 2,
		/obj/item/clothing/gloves/roguetown/nomagic = 2,
		/obj/item/rogueweapon/surgery/cautery/branding/slave = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/master
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 50,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/slaver/master
	name = "Zybantynian Master"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/master
	desc = "The leader of the Zybantynian slave troop. You have came to the mainlands from the western deserts of Zybantine in the hopes of gathering wealth through the training of and trade of unfortunate laborers. The practice can be called despicable by some, but it is without a doubt efficient in filling your pockets before you return to the deserts of the Zybantines"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/master
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_PERFECT_TRACKER,
		TRAIT_SLEUTH,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_stashed_items = list(
		"Slavekeeping Supplies" = /obj/item/storage/roguebag/slaver/master,
		"Bedroll" = /obj/item/bedroll,
		"Fullpie (Meat)" = /obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat,
		)

/datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/blade
	name = "Zybantynian Blade Mercenary"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/sallet
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/purple
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal/purple
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/sword/sabre/shamshir
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern/copper = 1,
		/obj/item/needle = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/blade
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/slaver/mercenary/blade
	name = "Zybantynian Blade Mercenary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/blade
	desc = "A hired arm for the Zybantine Slave troop. You have come from the deserts of Zybantine and are hired under contract by the Zybantynian Master."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/blade
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_SLEUTH,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_stashed_items = list(
		"Spare Chain" = /obj/item/rope/chain,
		"Bedroll" = /obj/item/bedroll,
		"Handpie (Meat)" = /obj/item/reagent_containers/food/snacks/rogue/handpie/meat,
		)

/datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/crossbow
	name = "Zybantynian Light Crossbow Mercenary"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	head = /obj/item/clothing/head/roguetown/helmet/sallet
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/purple
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal/purple
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern/copper = 1,
		/obj/item/needle = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/crossbow
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/slaver/mercenary/crossbow
	name = "Zybantynian Light Crossbow Mercenary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/crossbow
	desc = "A hired arm for the Zybantine Slave troop. You have come from the deserts of Zybantine and are hired under contract by the Zybantynian Master."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/crossbow
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_SLEUTH,
		TRAIT_DODGEEXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_stashed_items = list(
		"Spare Chain" = /obj/item/rope/chain,
		"Bedroll" = /obj/item/bedroll,
		"Handpie (Meat)" = /obj/item/reagent_containers/food/snacks/rogue/handpie/meat,
		)

/datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/whip
	name = "Zybantynian Whip Mercenary"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/sallet
	mask = /obj/item/clothing/head/roguetown/roguehood/shalal/purple
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/shalal
	belt = /obj/item/storage/belt/rogue/leather/shalal/purple
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_pocket = /obj/item/rogueweapon/whip
	backpack_contents = list(
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/flashlight/flare/torch/lantern/copper = 1,
		/obj/item/needle = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/whip
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/slaver/mercenary/whip
	name = "Zybantynian Whip Mercenary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/mercenary/whip
	desc = "A hired arm for the Zybantine Slave troop. You have come from the deserts of Zybantine and are hired under contract by the Zybantynian Master."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/mercenary/whip
	rockhill_traits = list(
		TRAIT_XENOPHOBIC,
		TRAIT_SLEUTH,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")
	rogue_stashed_items = list(
		"Spare Chain" = /obj/item/rope/chain,
		"Bedroll" = /obj/item/bedroll,
		"Handpie (Meat)" = /obj/item/reagent_containers/food/snacks/rogue/handpie/meat,
		)

/datum/outfit/job/roguetown/rockhill_class/slaver/slave/arcyne
	name = "Arcyne Slave"
	jobtype = /datum/job/roguetown/rockhill_migrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	mask = /obj/item/clothing/mask/rogue/exoticsilkmask
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	gloves = /obj/item/clothing/gloves/roguetown/nomagic
	shoes = /obj/item/clothing/shoes/roguetown/anklets
	belt = /obj/item/storage/belt/rogue/leather/exoticsilkbelt
	back = /obj/item/storage/backpack/rogue/satchel/short
	backr = /obj/item/rogueweapon/woodstaff/implement/greater
	l_pocket = /obj/item/storage/belt/rogue/pouch
	r_pocket = /obj/item/storage/magebag/associate
	backpack_contents = list(
		/obj/item/soap/bath = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/arcyne
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/music = 20,
		/datum/attribute/skill/misc/stealing = 10,
		)

/datum/rockhill_advclass/slaver/slave/arcyne
	name = "Arcyne Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/slave/arcyne
	desc = "An unlucky slave, captured from their home, moved to the Zybantines and trained for slave labor and obediency, for long enough to where you can only faintly remember who you were before... You are now being transported from the deserts to harsher lands to be sold."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/arcyne
	rockhill_traits = list(
		TRAIT_GOODLOVER,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slaver/slave/battle
	name = "Battle Slave"
	jobtype = /datum/job/roguetown/rockhill_migrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	mask = /obj/item/clothing/mask/rogue/exoticsilkmask
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	shoes = /obj/item/clothing/shoes/roguetown/anklets
	belt = /obj/item/storage/belt/rogue/leather/exoticsilkbelt
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/storage/belt/rogue/pouch
	r_pocket = /obj/item/flint
	backpack_contents = list(
		/obj/item/soap/bath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/battle
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = -1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/music = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/stealing = 10,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/slaver/slave/battle
	name = "Battle Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/slave/battle
	desc = "An unlucky slave, captured from their home, moved to the Zybantines and trained for slave labor and obediency, for long enough to where you can only faintly remember who you were before... You are now being transported from the deserts to harsher lands to be sold."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/battle
	rockhill_traits = list(
		TRAIT_GOODLOVER,
		TRAIT_BREADY,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slaver/slave/craftsman
	name = "Craftsman Slave"
	jobtype = /datum/job/roguetown/rockhill_migrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	mask = /obj/item/clothing/mask/rogue/exoticsilkmask
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	shoes = /obj/item/clothing/shoes/roguetown/anklets
	belt = /obj/item/storage/belt/rogue/leather/exoticsilkbelt
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/storage/belt/rogue/pouch
	backpack_contents = list(
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/tongs = 1,
		/obj/item/flint = 1,
		/obj/item/soap/bath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/craftsman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/armorsmithing = 50,
		/datum/attribute/skill/craft/blacksmithing = 50,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/engineering = 30,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 50,
		/datum/attribute/skill/craft/weaponsmithing = 50,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/music = 20,
		/datum/attribute/skill/misc/stealing = 10,
		)

/datum/rockhill_advclass/slaver/slave/craftsman
	name = "Craftsman Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/slave/craftsman
	desc = "An unlucky slave, captured from their home, moved to the Zybantines and trained for slave labor and obediency, for long enough to where you can only faintly remember who you were before... You are now being transported from the deserts to harsher lands to be sold."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/craftsman
	rockhill_traits = list(
		TRAIT_GOODLOVER,
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/slaver/slave/service
	name = "Service Slave"
	jobtype = /datum/job/roguetown/rockhill_migrant
	shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	mask = /obj/item/clothing/mask/rogue/exoticsilkmask
	neck = /obj/item/clothing/neck/roguetown/cursed_collar
	shoes = /obj/item/clothing/shoes/roguetown/anklets
	belt = /obj/item/storage/belt/rogue/leather/exoticsilkbelt
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/storage/belt/rogue/pouch
	r_pocket = /obj/item/flint
	backpack_contents = list(
		/obj/item/soap/bath = 1,
		/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/service
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/tanning = 40,
		/datum/attribute/skill/labor/farming = 40,
		/datum/attribute/skill/labor/fishing = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/stealing = 10,
		)

/datum/rockhill_advclass/slaver/slave/service
	name = "Service Slave"
	outfit = /datum/outfit/job/roguetown/rockhill_class/slaver/slave/service
	desc = "An unlucky slave, captured from their home, moved to the Zybantines and trained for slave labor and obediency, for long enough to where you can only faintly remember who you were before... You are now being transported from the deserts to harsher lands to be sold."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/slaver/slave/service
	rockhill_traits = list(
		TRAIT_GOODLOVER,
		TRAIT_EMPATH,
		TRAIT_BEAUTIFUL,
		TRAIT_OUTLANDER,
		)
	rogue_subclass_languages = list("/datum/language/celestial")

/datum/outfit/job/roguetown/rockhill_class/sojourner
	name = "Sojourner"
	jobtype = /datum/job/roguetown/orthodoxist
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	cloak = /obj/item/clothing/cloak/psydontabard/alt
	head = /obj/item/clothing/head/roguetown/roguehood/sojourner
	mask = /obj/item/clothing/mask/rogue/lordmask/naledi/sojourner
	neck = /obj/item/clothing/neck/roguetown/psicross/g
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/naledi
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	back = /obj/item/storage/backpack/rogue/satchel/otavan
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/mid
	r_hand = /obj/item/rogueweapon/woodstaff/implement/greater/sojourner
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		/obj/item/roguegem/amethyst/naledi = 1,
		/obj/item/rogueweapon/spellbook = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/sojourner
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/sojourner
	name = "Sojourner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/sojourner
	desc = "Naledi scholars, bereft of their home, were sent around Grimoria searching for purpose. They'd found it in Otava, within the hallowed halls that honed their gifts and refined the knowledge they'd held. Attached to the Inquisitor, you've one purpose. Show them that the fall wasn't pointless."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/sojourner
	rockhill_traits = list(
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_NALEDI,
		TRAIT_MAGEDEXTERITY,
		TRAIT_OUTLANDER,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		)
	rogue_subclass_languages = list("/datum/language/otavan", "/datum/language/celestial")
	rogue_social_rank = 4
	rogue_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy,
		)

/datum/outfit/job/roguetown/rockhill_class/squire/footman
	name = "Footman Squire"
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
	l_pocket = /obj/item/storage/keyring/squire
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/iron
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/rogueweapon/hammer/copper = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/squire/footman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/squire/footman
	name = "Footman Squire"
	outfit = /datum/outfit/job/roguetown/rockhill_class/squire/footman
	desc = "Your training has been singularly focused on the intricacies of sword, a weapon whose versatility belies the difficulty of its use."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/squire/footman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/squire/lancer
	name = "Lancer Squire"
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

/datum/attribute_holder/sheet/job/rockhill_class/squire/lancer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/squire/lancer
	name = "Lancer Squire"
	outfit = /datum/outfit/job/roguetown/rockhill_class/squire/lancer
	desc = "A hopeful for the next generation of knightly mounted lancers and infantry pike specialists, your training with polearms sets you apart from other squires."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/squire/lancer
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/squire/skirmisher
	name = "Irregular Squire"
	jobtype = /datum/job/roguetown/squire
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/leather/armorhood/advanced
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/storage/keyring/squire
	r_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger = 1,
		/obj/item/storage/belt/rogue/pouch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
		/obj/item/rogueweapon/hammer/copper = 1,
		/obj/item/repair_kit/metal = 1,
		/obj/item/repair_kit = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/squire/skirmisher
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/slings = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/armorsmithing = 10,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/weaponsmithing = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/squire/skirmisher
	name = "Irregular Squire"
	outfit = /datum/outfit/job/roguetown/rockhill_class/squire/skirmisher
	desc = "As militaries become more flexible and tactics more moderne the importance of irregular troops has become more apparent, and hopefuls such as yourself have been trained into the future of elite skirmisher troops."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/squire/skirmisher
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/thug
	name = "Thug"
	jobtype = /datum/job/roguetown/villager
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	head = /obj/item/clothing/head/roguetown/helmet/bandana
	mask = /obj/item/clothing/mask/rogue/ragmask/red
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/cutlass
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/beer = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/thug
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/fishing = 30,
		/datum/attribute/skill/labor/lumberjacking = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 50,
		)

/datum/rockhill_advclass/thug
	name = "Thug"
	outfit = /datum/outfit/job/roguetown/rockhill_class/thug
	desc = "Maybe you've never been the smartest person in town, but you've gotten this far - whether by finding odd-jobs around town carting shit for the soilers, being the meathead that somebody needs to stand behind them and look scary, or simply shaking down the weak with the veiled-or-otherwise threat of a clobbering. You might've had some run-ins with the law for petty crimes here and there, but you're tolerated enough to have a home here."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/thug
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_DRUNK_HEALING,
		TRAIT_STEELHEARTED,
		)
	maximum_slots = 8
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/brewer
	name = "Brewer"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/red
	cloak = /obj/item/clothing/suit/roguetown/armor/longcoat
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/mace/cudgel
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/beer/gronnmead = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer/voddena = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/beer/blackgoat = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/elfred = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/elfblue = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/ingot/copper = 2,
		/obj/item/roguegear = 1,
		/obj/item/bottle_kit = 1,
		/obj/item/recipe_book/survival = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/brewer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/brewer
	name = "Brewer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/brewer
	desc = "You make your coin peddling imported alcohols from all over the world, though you're no stranger to the craft, and have experience brewing your own ale in a pinch. You have the equipments and know how on how to make your own distiller, too."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/brewer
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/cuisiner
	name = "Cuisiner"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	suit = /obj/item/clothing/suit/roguetown/armor/workervest
	head = /obj/item/clothing/head/roguetown/chef
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/cooking/pan
	backpack_contents = list(
		/obj/item/clothing/mask/cigarette/rollie/nicotine/cheroot = 5,
		/obj/item/reagent_containers/peppermill = 1,
		/obj/item/reagent_containers/food/snacks/rogue/cheddar/aged = 1,
		/obj/item/reagent_containers/food/snacks/butter = 1,
		/obj/item/kitchen/rollingpin = 1,
		/obj/item/flint = 1,
		/obj/item/rogueweapon/huntingknife/chefknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/recipe_book/survival = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/cuisiner
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/cuisiner
	name = "Cuisiner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/cuisiner
	desc = "Whether a disciple of a culinary school, a storied royal chef, or a mercenary cook for hire, your trade is plied at the counter, the cutting board, and the hearth."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/cuisiner
	rockhill_traits = list(
		TRAIT_GOODLOVER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/doomsayer
	name = "Doomsayer"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	cloak = /obj/item/clothing/cloak/half
	head = /obj/item/clothing/head/roguetown/roguehood/black
	mask = /obj/item/clothing/mask/rogue/skullmask
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut
	backpack_contents = list(
		/obj/item/clothing/neck/roguetown/psicross/silver = 3,
		/obj/item/clothing/neck/roguetown/psicross = 2,
		/obj/item/clothing/neck/roguetown/psicross/wood = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/doomsayer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/axes = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/labor/lumberjacking = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/doomsayer
	name = "Doomsayer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/doomsayer
	desc = "THE WORLD IS ENDING!!! At least, that's what you want your clients to believe. You'll offer them a safe place in the new world, of course - built by yours truly."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/doomsayer
	rockhill_traits = list(
		TRAIT_PSYCHOSIS,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/harlequin
	name = "Harlequin"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights
	suit = /obj/item/clothing/suit/roguetown/shirt/jester
	head = /obj/item/clothing/head/roguetown/jester
	mask = /obj/item/clothing/mask/rogue/xylixmask
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/jester
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogue/instrument/accord
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger
	backpack_contents = list(
		/obj/item/bomb/smoke = 3,
		/obj/item/storage/pill_bottle/dice = 1,
		/obj/item/toy/cards/deck = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/harlequin
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/music = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 40,
		)

/datum/rockhill_advclass/trader/harlequin
	name = "Harlequin"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/harlequin
	desc = "You are a travelling entertainer - a jester by trade. Where you go, chaos follows - and mischief is made."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/harlequin
	rockhill_traits = list(
		TRAIT_NUTCRACKER,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/jeweler
	name = "Jeweler"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
	cloak = /obj/item/clothing/cloak/raincloak/purple
	mask = /obj/item/clothing/mask/rogue/lordmask
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/clothing/ring/silver = 2,
		/obj/item/clothing/ring/gold = 1,
		/obj/item/rogueweapon/tongs = 1,
		/obj/item/rogueweapon/hammer/steel = 1,
		/obj/item/roguegem/yellow = 1,
		/obj/item/roguegem/green = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/chisel = 1,
		/obj/item/carvedgem/rose/rawrose = 1,
		/obj/item/roguegem/jade = 1,
		/obj/item/roguegem/onyxa = 1,
		/obj/item/roguegem/turq = 1,
		/obj/item/roguegem/coral = 1,
		/obj/item/roguegem/amber = 1,
		/obj/item/roguegem/opal = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/jeweler
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/blacksmithing = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/smelting = 30,
		/datum/attribute/skill/craft/weaponsmithing = 30,
		/datum/attribute/skill/labor/mining = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/jeweler
	name = "Jeweler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/jeweler
	desc = "You make your coin peddling exotic jewelry, gems, and shiny things."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/jeweler
	rockhill_traits = list(
		TRAIT_TRAINED_SMITH,
		TRAIT_SMITHING_EXPERT,
		TRAIT_LEGENDARY_MINER,
		)
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/trader/peddler
	name = "Peddler"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe
	head = /obj/item/clothing/head/roguetown/roguehood
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/storage/belt/rogue/surgery_bag/full
	backpack_contents = list(
		/obj/item/reagent_containers/powder/spice = 2,
		/obj/item/reagent_containers/powder/ozium = 1,
		/obj/item/reagent_containers/powder/moondust = 2,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/peddler
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/peddler
	name = "Peddler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/peddler
	desc = "You make your coin peddling in spices and performing back-alley 'medical' procedures. Hope your patient didn't need that kidney."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/peddler
	rockhill_traits = list(
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/trader/scholar
	name = "Traveling Scholar"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/robe/archivist
	head = /obj/item/clothing/head/roguetown/roguehood/black
	mask = /obj/item/clothing/mask/rogue/spectacles
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/paper/scroll = 3,
		/obj/item/natural/feather = 1,
		/obj/item/skillbook/unfinished = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/trader/scholar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 60,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/trader/scholar
	name = "Traveling Scholar"
	outfit = /datum/outfit/job/roguetown/rockhill_class/trader/scholar
	desc = "You are a scholar traveling the world in order to write a book about your ventures. Although not quite as dedicated to your studies as some, you trade in stories and tales of your travels."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/trader/scholar
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_GOODWRITER,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_SMITHING_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_subclass_languages = list("/datum/language/elvish", "/datum/language/dwarvish", "/datum/language/celestial", "/datum/language/hellspeak", "/datum/language/orcish", "/datum/language/grenzelhoftian", "/datum/language/otavan", "/datum/language/etruscan", "/datum/language/gronnic", "/datum/language/hammerholdian", "/datum/language/kazengunese", "/datum/language/draconic", "/datum/language/aavnic")
	rogue_social_rank = 3

/datum/outfit/job/roguetown/rockhill_class/vagabond_beggar
	name = "Beggar"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	head = /obj/item/clothing/head/roguetown/knitcap
	l_pocket = /obj/item/clothing/mask/cigarette/rollie/cannabis
	r_pocket = /obj/item/reagent_containers/powder/moondust
	l_hand = /obj/item/rogueweapon/mace/woodclub
	r_hand = /obj/item/rogueweapon/mace/woodclub

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_beggar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -3,
		ROGUE_STAT_INTELLIGENCE = -4,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = -3,
		/datum/attribute/skill/misc/stealing = 40,
		)

/datum/rockhill_advclass/vagabond_beggar
	name = "Beggar"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_beggar
	desc = "You are without coin and without worth. The pity of others is your bread, and their mercy is your butter. Having sat by waystones and watched many a traveller pass in the hopes for alms, you've nursed a surprising talent for thievery, and have even cajoled knowledge of lockpicking out of an especially sentimental rogue."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_beggar
	rockhill_traits = list(
		TRAIT_NOSTINK,
		TRAIT_NASTY_EATER,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/vagabond_busker
	name = "Busker"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	back = /obj/item/rogue/instrument/accord
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_busker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/music = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		)

/datum/rockhill_advclass/vagabond_busker
	name = "Busker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_busker
	desc = "You've lost pretty much everything - everything but your instrument and an adequate ability to play it. Maybe a jaunty tune will send a few zennies your way - whether through pitied gratitute, or by distracting long enough for you to swipe a coinpurse."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_busker
	rockhill_traits = list(
		TRAIT_EMPATH,
		)

/datum/outfit/job/roguetown/rockhill_class/vagabond_courier
	name = "Ambushed Courier"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_courier
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 40,
		)

/datum/rockhill_advclass/vagabond_courier
	name = "Ambushed Courier"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_courier
	desc = "Entrusted with a message of great import, your fortunes fell by the roadside at the behest of a group of Matthiosian scum. Bereft of mount and master, you now wander the realm for purpose and sustenance."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_courier
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/vagabond_deprived
	name = "Deprived"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/loincloth
	l_hand = /obj/item/rogueweapon/shield/wood
	r_hand = /obj/item/rogueweapon/mace/woodclub

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_deprived
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 3,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/misc/athletics = 20,
		)

/datum/rockhill_advclass/vagabond_deprived
	name = "Deprived"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_deprived
	desc = "You have nothing left but your trusty shield and club - war took away everything you had but will you manage to reclaim what was yours or succumb to the horrors of Psydonia."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_deprived

/datum/outfit/job/roguetown/rockhill_class/vagabond_excommunicated
	name = "Excommunicated"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogueweapon/woodstaff

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_excommunicated
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_WILLPOWER = -1,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/magic/holy = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 30,
		)

/datum/rockhill_advclass/vagabond_excommunicated
	name = "Excommunicated"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_excommunicated
	desc = "The Church has found you bereft of mercy, and you walk these lands with nothing but the tattered shreds of your faith."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_excommunicated

/datum/outfit/job/roguetown/rockhill_class/vagabond_goatherd
	name = "Lone Herder"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_goatherd
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/riding = 10,
		)

/datum/rockhill_advclass/vagabond_goatherd
	name = "Lone Herder"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_goatherd
	desc = "Having lost your idyllic pastoral existence, only a solitary member of your herd now remains as a reminder of what was. Is your sole charge a friend, or is it food? You decide."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_goatherd
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/vagabond_mage
	name = "Exiled Apprentice"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/half/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	back = /obj/item/storage/backpack/rogue/satchel
	l_hand = /obj/item/rogueweapon/spellbook
	r_hand = /obj/item/rogueweapon/woodstaff
	backpack_contents = list(
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_mage
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_WILLPOWER = -2,
		/datum/attribute/skill/combat/arcyne = 30,
		/datum/attribute/skill/combat/staves = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/vagabond_mage
	name = "Exiled Apprentice"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_mage
	desc = "Your master found you talentless, and cast you from their tower with nothing but your staff and dreams of what could've been."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_mage
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/vagabond_original
	name = "The Vagabond"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_original
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_WILLPOWER = -1,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 40,
		)

/datum/rockhill_advclass/vagabond_original
	name = "The Vagabond"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_original
	desc = "Fate's twists and turns lead many towards a wanderer's life. Find your fortunes in the shadows or in the pockets of another."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_original

/datum/outfit/job/roguetown/rockhill_class/vagabond_runner
	name = "Rumbled Runner"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_runner
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		)

/datum/rockhill_advclass/vagabond_runner
	name = "Rumbled Runner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_runner
	desc = "Ferrying messages in the dark is a dangerous profession at the best of times. You're lucky to have made it out of your last predicament alive, but all you have now is some rags and your trusty feet."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_runner
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/vagabond_scholar
	name = "Destitute Scholar"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/raincloak/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogue/instrument/flute

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_scholar
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_WILLPOWER = -1,
		/datum/attribute/skill/craft/alchemy = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		)

/datum/rockhill_advclass/vagabond_scholar
	name = "Destitute Scholar"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_scholar
	desc = "Knowledge is often both a boon and a curse. Whatever you know has left you with little to your name but your wits, and even then..."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_scholar
	rockhill_traits = list(
		TRAIT_INTELLECTUAL,
		TRAIT_CICERONE,
		TRAIT_SEEDKNOW,
		)
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/vagabond_unraveled
	name = "The Unraveled"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/loincloth
	cloak = /obj/item/clothing/cloak/half/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	r_hand = /obj/item/rogueweapon/woodstaff

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_unraveled
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = -2,
		ROGUE_STAT_INTELLIGENCE = -2,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 40,
		)

/datum/rockhill_advclass/vagabond_unraveled
	name = "The Unraveled"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_unraveled
	desc = "Once you sought to understand the mind's decay — now you live within it, a wandering physician bound to his own affliction."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_unraveled
	rockhill_traits = list(
		TRAIT_PSYCHOSIS,
		TRAIT_NOSTINK,
		)
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/vagabond_wanted
	name = "Wanted"
	jobtype = /datum/job/roguetown/orphan
	uniform = /obj/item/clothing/under/roguetown/tights/vagrant/l
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	cloak = /obj/item/clothing/cloak/half/brown
	gloves = /obj/item/clothing/gloves/roguetown/fingerless

/datum/attribute_holder/sheet/job/rockhill_class/vagabond_wanted
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		)

/datum/rockhill_advclass/vagabond_wanted
	name = "Wanted"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vagabond_wanted
	desc = "The long arm of the law reaches out for you - are you slippery enough to evade its grip this time, or is your head destined to end up in an Excidium's maw?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vagabond_wanted

/datum/outfit/job/roguetown/rockhill_class/vanguard/archer
	name = "Vanguard Archer"
	jobtype = /datum/job/roguetown/vanguard
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/shadowcloak/vanguard
	head = /obj/item/clothing/head/roguetown/helmet/skullcap
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_pocket = /obj/item/quiver/arrows
	backpack_contents = list(
		/obj/item/roguekey/walls = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/signal_horn = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/vanguard/archer
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/slings = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/vanguard/archer
	name = "Vanguard Archer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vanguard/archer
	desc = "You are well versed in the ways of handling a bow. You will stand in the back, and protect the front with arrows."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vanguard/archer
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_SURVIVAL_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/vanguard/footman
	name = "Vanguard Footman"
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

/datum/attribute_holder/sheet/job/rockhill_class/vanguard/footman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/vanguard/footman
	name = "Vanguard Footman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/vanguard/footman
	desc = "You are adequately briefed on the ways of wielding pointy sticks. You will stand in the front, and protect."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/vanguard/footman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_SURVIVAL_EXPERT,
		)

/datum/outfit/job/roguetown/rockhill_class/veteran/battlemaster
	name = "Veteran Battlemaster"
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

/datum/attribute_holder/sheet/job/rockhill_class/veteran/battlemaster
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 50,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/veteran/battlemaster
	name = "Veteran Battlemaster"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/battlemaster
	desc = "You have served under a hundred masters, some good, some bad. You were a general once. A marshal, a captain. To some a hero, others a monster. Something of the sorts. You made strategies, tactics, new innovations of war. A thousand new ways for one man to kill another. It still keeps you up at night."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/battlemaster
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)

/datum/outfit/job/roguetown/rockhill_class/veteran/calvaryman
	name = "Tarnished Knight"
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	suit = /obj/item/clothing/suit/roguetown/armor/plate/
	cloak = /obj/item/clothing/cloak/half/vet
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/veteran/calvaryman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 50,
		/datum/attribute/skill/combat/bows = 50,
		/datum/attribute/skill/combat/crossbows = 50,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 50,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/whipsflails = 50,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/veteran/calvaryman
	name = "Tarnished Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/calvaryman
	desc = "You were once a member of a knightly calvary regiment, a prestigious title. You were ontop of the world, the townspeople rejoiced when you rode through their streets. Now, all you can hear is the screams of your brothers-in-arms as they fell. You specialize in mounted warfare."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/calvaryman
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE,
		TRAIT_GOODTRAINER,
		TRAIT_EQUESTRIAN,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)
	rogue_stashed_items = list(
		"Caparison (Saiga)" = /obj/item/caparison,
		"Caparison (Fogbeast)" = /obj/item/caparison/fogbeast,
		)

/datum/outfit/job/roguetown/rockhill_class/veteran/footman
	name = "Retired Footman"
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half
	cloak = /obj/item/clothing/cloak/half/vet
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/storage/keyring/guardcastle
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/veteran/footman
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 50,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 50,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/veteran/footman
	name = "Retired Footman"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/footman
	desc = "You served on the fields of battle as no heroic knight steadfast in shining armor, but a mere mortal clad in whatever cheap armor coin could buy. You fought in formation as a member of a unit, and through discipline, have won numerous battles. Maybe one day you even served as the captain of your unit. You specialize in polearms and bows."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/footman
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)

/datum/outfit/job/roguetown/rockhill_class/veteran/merc
	name = "Retired Mercenary"
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft
	suit = /obj/item/clothing/suit/roguetown/armor/plate/blacksteel_half_plate
	cloak = /obj/item/clothing/cloak/half/vet
	head = /obj/item/clothing/head/roguetown/grenzelhofthat
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/sword/short
	r_pocket = /obj/item/storage/keyring/guardcastle
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/veteran/merc
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 50,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 50,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/veteran/merc
	name = "Retired Mercenary"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/merc
	desc = "You were a sell-sword, a warrior of coin. Your pockets were never light, you always had a warm place to stay and food in your belly, but you knew that every battle could be your last. You're the last of your unit, and you can't help but regret it. You specialize in swords and polearms, or axes and polearms."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/merc
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)
	rogue_subclass_languages = list("/datum/language/grenzelhoftian")

/datum/outfit/job/roguetown/rockhill_class/veteran/scout
	name = "Former Scout"
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded/warden
	cloak = /obj/item/clothing/cloak/wardencloak
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/antler
	mask = /obj/item/clothing/head/roguetown/roguehood/warden
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/greataxe/steel
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/veteran/scout
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 3,
		ROGUE_STAT_STRENGTH = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 60,
		/datum/attribute/skill/combat/bows = 60,
		/datum/attribute/skill/combat/crossbows = 60,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 60,
		/datum/attribute/skill/combat/swords = 50,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/tanning = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/veteran/scout
	name = "Former Scout"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/scout
	desc = "You and your unit maneuvered ahead of the main force, ever-watchful for traps and ambushes. You never thought of what would happen should you actually walk into one. You specialize in archery and axes."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/scout
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_WOODSMAN,
		TRAIT_OUTDOORSMAN,
		TRAIT_PERFECT_TRACKER,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)

/datum/outfit/job/roguetown/rockhill_class/veteran/spy
	name = "Ex-Spy"
	jobtype = /datum/job/roguetown/veteran
	uniform = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	suit = /obj/item/clothing/suit/roguetown/armor/leather/vest/white
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	back = /obj/item/storage/backpack/rogue/satchel/black
	l_pocket = /obj/item/rogueweapon/whip
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/silver/elvish = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/lockpickring/mundane = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/veteran/spy
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_STRENGTH = -1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 50,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 60,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 60,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 60,
		/datum/attribute/skill/misc/stealing = 50,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/veteran/spy
	name = "Ex-Spy"
	outfit = /datum/outfit/job/roguetown/rockhill_class/veteran/spy
	desc = "You didn't serve on the frontlines, you were an informant, a spy, an assassin. You wove your way through enemy courts, finding information, neutralizing loose ends. You lived old in a career that many die young. It's a miracle you stand here today. You specialize in knives, whips, and stealth."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/veteran/spy
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_CICERONE,
		TRAIT_SEEPRICES,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_STEELHEARTED,
		TRAIT_COMBAT_AWARE,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")

/datum/outfit/job/roguetown/rockhill_class/wapprentice/apprentice
	name = "Magician Apprentice"
	jobtype = /datum/job/roguetown/wapprentice
	uniform = /obj/item/clothing/under/roguetown/tights/random
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/gladiator
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/magebag/associate
	r_pocket = /obj/item/storage/keyring/mageapprentice
	backpack_contents = list(
		/obj/item/roguegem/amethyst = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/recipe_book/magic = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wapprentice/apprentice
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/wapprentice/apprentice
	name = "Magician Apprentice"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wapprentice/apprentice
	desc = "Your master once saw potential in you, although you are uncertain if they still do, given how rigorous and difficult your studies have been. The path to using magic is a treacherous and untamed one, and you are still decades away from calling yourself even a journeyman in the field. Listen and serve, and someday you will earn your hat."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wapprentice/apprentice
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MAGEDEXTERITY,
		)

/datum/outfit/job/roguetown/rockhill_class/wapprentice/associate
	name = "Magician's Associate"
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

/datum/attribute_holder/sheet/job/rockhill_class/wapprentice/associate
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		/datum/attribute/skill/combat/arcyne = 30,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/staves = 30,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/swimming = 10,
		)

/datum/rockhill_advclass/wapprentice/associate
	name = "Magician's Associate"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wapprentice/associate
	desc = "No one could truly master the entirety of the arcyne arts. But commanding the fundamentals is quite achievable. Deemed competent by your peers and mentor, you have become an Associate, paid a stipend to wield your power in the name of the Crown, or at least not against them. The Crown might want a bolt of lightning turned against their enemies - after all, what else is the arcyne good for but war and destruction? But as many mages know, wisdom and whimsy are the true calling of the Magos who has mastered the arts. The choice is yours."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wapprentice/associate
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MAGEDEXTERITY,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_INTELLIGENCE = 1, ROGUE_STAT_SPEED = -1),
		"skills" = list(/datum/attribute/skill/magic/arcane = 40),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/warden/forester
	name = "Forester"
	jobtype = /datum/job/roguetown/warden
	uniform = /obj/item/clothing/under/roguetown/chainlegs/iron
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded/warden/melee
	cloak = /obj/item/clothing/cloak/wardencloak
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/scabbard/gwstrap
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick
	r_hand = /obj/item/rogueweapon/spear
	backpack_contents = list(
		/obj/item/storage/keyring/guard = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/signal_horn = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/warden/forester
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/slings = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/warden/forester
	name = "Forester"
	outfit = /datum/outfit/job/roguetown/rockhill_class/warden/forester
	desc = "You are a forester, a woodsman who volunteered to become a part of the wardens. You have experience in the axe and the spear."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/warden/forester
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/warden/ranger
	name = "Ranger"
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

/datum/attribute_holder/sheet/job/rockhill_class/warden/ranger
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 20,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/slings = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/warden/ranger
	name = "Ranger"
	outfit = /datum/outfit/job/roguetown/rockhill_class/warden/ranger
	desc = "You are a ranger, a hunter who volunteered to become a part of the wardens. You have great experience using bows."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/warden/ranger
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_EXPERT_HUNTER,
		)

/datum/outfit/job/roguetown/rockhill_class/witch
	name = "Witch"
	jobtype = /datum/job/roguetown/pilgrim
	uniform = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/phys
	head = /obj/item/clothing/head/roguetown/witchhat
	mask = /obj/item/clothing/head/roguetown/roguehood/black
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/magebag/witch
	backpack_contents = list(
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/reagent_containers/glass/mortar = 1,
		/obj/item/pestle/rogue = 1,
		/obj/item/candle/yellow = 2,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/witch
	raw_attribute_list = list(
		ROGUE_STAT_FORTUNE = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 40,
		)

/datum/rockhill_advclass/witch
	name = "Witch"
	outfit = /datum/outfit/job/roguetown/rockhill_class/witch
	desc = "You are a witch, seen as wisefolk to some and a demon to many. Ostracized and sequestered for wrongthinks or outright heresy, your potions are what the commonfolk turn to when all else fails, and for this they tolerate you — at an arm's length. Take care not to end 'pon a pyre, for the church condemns your left handed arts."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/witch
	rockhill_traits = list(
		TRAIT_DEATHSIGHT,
		TRAIT_WITCH,
		TRAIT_ALCHEMY_EXPERT,
		)
	maximum_slots = 20
	rogue_age_mod = list(
		"age" = "Old",
		"stats" = list(ROGUE_STAT_FORTUNE = 1, ROGUE_STAT_INTELLIGENCE = 1, ROGUE_STAT_SPEED = -1),
		"minor" = 1,
		)

/datum/outfit/job/roguetown/rockhill_class/woodworker
	name = "Woodcutter"
	jobtype = /datum/job/roguetown/pilgrim
	head = /obj/item/clothing/head/roguetown/roguehood
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter
	l_pocket = /obj/item/rogueweapon/hammer/wood
	r_pocket = /obj/item/rogueweapon/handsaw
	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/woodworker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/carpentry = 40,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/craft/masonry = 10,
		/datum/attribute/skill/craft/sewing = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/labor/lumberjacking = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/woodworker
	name = "Woodcutter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/woodworker
	desc = "You are a woodworker, physically capable of falling any tree yet knowledgeable in the ways of bending wood to your will. With enough time, your only limit is your imagination."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/woodworker
	rockhill_traits = list(
		TRAIT_HOMESTEAD_EXPERT,
		)
	maximum_slots = 20
	rogue_social_rank = 2

/datum/outfit/job/roguetown/rockhill_class/wretch/ancientchampion
	name = "Ancient Champion"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/platelegs/zizo
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/zizo
	suit = /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
	cloak = /obj/item/clothing/cloak/half
	head = /obj/item/clothing/head/roguetown/helmet/heavy/zizo
	mask = /obj/item/flowercrown/rosa
	neck = /obj/item/clothing/neck/roguetown/bevor/zizo
	gloves = /obj/item/clothing/gloves/roguetown/plate/zizo
	wrists = /obj/item/clothing/wrists/roguetown/bracers/zizo
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/zizo
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/scabbard/gwstrap
	r_hand = /obj/item/rogueweapon/greatsword/avantyne
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/ancientchampion
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = -3,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 50,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 40,
		)

/datum/rockhill_advclass/wretch/ancientchampion
	name = "Ancient Champion"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/ancientchampion
	desc = "In life, you were a mortal warrior shedding blood for Her Majesty, a veteran of countless battles and razings. In death, you have been rewarded with a privilege to serve Her forever more. You awaken once again, wielding blade and arcyne, to complete Her Grandest Work."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/ancientchampion
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_OVERTHERETIC,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		TRAIT_ARCYNE,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")
	rogue_stashed_items = list(
		"Armor Plates" = /obj/item/repair_kit/metal,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/antipope
	name = "Heresiarch"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	head = /obj/item/clothing/head/roguetown/roguehood
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	backr = /obj/item/rogueweapon/woodstaff/quarterstaff
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/kris
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/ritechalk = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/antipope
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/magic/holy = 50,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 60,
		)

/datum/rockhill_advclass/wretch/antipope
	name = "Heresiarch"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/antipope
	desc = "They are pretentious. They are weak. They are complacent. And they are hopeless. But you. You will change this. A high-ranking official of the Holy Ecclesial, for your deeds you have been blessed by the Four Ascendants to bring upon change and be their God Hand. But this change will be resisted. Crush the dissent. Show them why it is better to rule in Gehenna than serve under the Firmament."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/antipope
	rockhill_traits = list(
		TRAIT_HERETIC_SEER,
		TRAIT_RITUALIST,
		TRAIT_GRAVEROBBER,
		TRAIT_RESONANCE,
		TRAIT_OVERTHERETIC,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/berserker
	name = "Berserker"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	head = /obj/item/clothing/head/roguetown/helmet/heavy/volfplate/berserker
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/hip/headhook
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/combat = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/berserker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/wretch/berserker
	name = "Berserker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/berserker
	desc = "You are a warrior feared for your brutality, dedicated to using your might for your own gain. Might equals right, and you are the reminder of such a saying."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/berserker
	rockhill_traits = list(
		TRAIT_STRONGBITE,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/blackoakwyrm
	name = "Black Oak Pariah"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hatanga
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/elven
	cloak = /obj/item/clothing/cloak/forrestercloak
	head = /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/light
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel/black
	backr = /obj/item/rogueweapon/shield/wood
	l_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel/elvish
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/long/elf
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/rogueweapon/spellbook = 1,
		/obj/item/chalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/blackoakwyrm
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 20,
		)

/datum/rockhill_advclass/wretch/blackoakwyrm
	name = "Black Oak Pariah"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/blackoakwyrm
	desc = "Carrying extreme beliefs not even befit of the Black Oaks, you have decided to secede yourself from the group and everyone else. This land was once great...and now, wave after wave of monsters and outsiders trample your home. Your people were the ones that settled these lands, and the foreign-backed Crown, deceitful and arrogant, has denied your people the rewards they deserve! Your extensive training in the Black Oaks has given you skill in both blades and magycks. A bounty from the crown follows you, as you had already done enough to be officially condemned by the group that was not committed to the cause due to the lure of coin."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/blackoakwyrm
	rockhill_traits = list(
		TRAIT_AZURENATIVE,
		TRAIT_OUTDOORSMAN,
		TRAIT_BLACKOAK,
		TRAIT_DODGEEXPERT,
		TRAIT_ARCYNE,
		TRAIT_WOODWALKER,
		TRAIT_EXPERT_HUNTER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/human/halfelf", "/datum/species/elf/wood", "/datum/species/elf/dark")
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		"Stashed Funds" = /obj/item/roguecoin/silver/pile/wretchpile,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/deserter
	name = "Disgraced Knight"
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

/datum/attribute_holder/sheet/job/rockhill_class/wretch/deserter
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 40,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/wretch/deserter
	name = "Disgraced Knight"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/deserter
	desc = "You were once a venerated and revered knight - now, a traitor who abandoned your liege. You lyve the lyfe of an outlaw, shunned and looked down upon by society."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/deserter
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
	maximum_slots = 2
	rogue_stashed_items = list(
		"Armor Plates" = /obj/item/repair_kit/metal,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/deserter/maa
	name = "Fighter"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine
	cloak = /obj/item/clothing/cloak/stabard/surcoat
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	l_pocket = /obj/item/rogueweapon/mace/cudgel
	r_pocket = /obj/item/rogueweapon/mace/warhammer
	backpack_contents = list(
		/obj/item/natural/cloth = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/deserter/maa
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 10,
		)

/datum/rockhill_advclass/wretch/deserter/maa
	name = "Fighter"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/deserter/maa
	desc = "It matters not what cause you swing your weapon for, in the end you fight the same way your ancestors and their ancestors did: clad in metal and intimately intertwined with gore and death."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/deserter/maa
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_stashed_items = list(
		"Armor Plates" = /obj/item/repair_kit/metal,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/herald_of_progress
	name = "Herald of Progress"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	cloak = /obj/item/clothing/cloak/raincloak/red
	head = /obj/item/clothing/head/roguetown/roguehood/red
	mask = /obj/item/clothing/mask/rogue/lordmask/zizite
	neck = /obj/item/clothing/neck/roguetown/chaincoif/
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/neck/roguetown/psicross/inhumen
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
	back = /obj/item/storage/backpack/rogue/satchel
	r_pocket = /obj/item/rogueweapon/huntingknife/idagger/steel
	r_hand = /obj/item/rogue/instrument/ztratocaster
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/lockpick = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/herald_of_progress
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 4,
		/datum/attribute/skill/combat/axes = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/music = 60,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/wretch/herald_of_progress
	name = "Herald of Progress"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/herald_of_progress
	desc = "Your melodies bring about melancholy visions of the future. Your soliloquies are punctuated by whispered truths of the past. Dread change, the promises of tomorrow come to fruition all the same. You are the herald of progress, a soothsayer of what is to be. The realm is a stage, and you are Her voice."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/herald_of_progress
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_OVERTHERETIC,
		TRAIT_ARCYNE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/heretic
	name = "Heretic"
	jobtype = /datum/job/roguetown/wretch
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/rogueweapon/shield/tower/metal
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/rogueweapon/scabbard/sword
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/ritechalk = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/wretch/heretic
	name = "Heretic"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/heretic
	desc = "You father your unholy cause through the most time-tested of ways: hard, heavy steel in both arms and armor."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_stashed_items = list(
		"Armor Plates" = /obj/item/repair_kit/metal,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/heretic/monk
	name = "Heretic Monk"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/monk
	head = /obj/item/clothing/head/roguetown/headband/monk
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/rogueweapon/handclaw/gronn

/datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic/monk
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_PERCEPTION = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 20,
		/datum/attribute/skill/craft/cooking = 20,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/labor/farming = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/wretch/heretic/monk
	name = "Heretic Monk"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/heretic/monk
	desc = "Strong in body and spirit, you spread the truth through violence and word in equal measures. You eschew burdening armor in favor of physical prowess."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic/monk
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_stashed_items = list(
		"Armor Plates" = /obj/item/repair_kit/metal,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/heretic/spy
	name = "Heretic Spy"
	jobtype = /datum/job/roguetown/wretch
	neck = /obj/item/clothing/neck/roguetown/gorget
	belt = /obj/item/storage/belt/rogue/leather
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/rapier

/datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic/spy
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/wretch/heretic/spy
	name = "Heretic Spy"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/heretic/spy
	desc = "Nimble of dagger and foot both, you are the shadowy herald of the cabal. They will not see you coming."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/heretic/spy
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_DODGEEXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/licker
	name = "Licker"
	jobtype = /datum/job/roguetown/wretch

/datum/attribute_holder/sheet/job/rockhill_class/wretch/licker
	raw_attribute_list = list(
		/datum/attribute/skill/magic/blood = 40,
		)

/datum/rockhill_advclass/wretch/licker
	name = "Licker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/licker
	desc = "You have recently been embraced as a vampire. You do not know whom your sire is, strange urges, unnatural strength, a thirst you can barely control. You were outed as a monster and are now on the run."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/licker
	rockhill_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_SILVER_WEAK,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/dullahan", "/datum/species/halforc", "/datum/species/goblinp", "/datum/species/harpy", "/datum/species/ooze", "/datum/species/elf/dark", "/datum/species/lizardfolk", "/datum/species/tabaxi", "/datum/species/akula", "/datum/species/anthromorph", "/datum/species/demihuman", "/datum/species/lamia", "/datum/species/arachnid", "/datum/species/anthromorphsmall", "/datum/species/kobold", "/datum/species/tieberian", "/datum/species/human/northern", "/datum/species/elf/wood", "/datum/species/human/halfelf", "/datum/species/dwarf/mountain", "/datum/species/aasimar", "/datum/species/lupian", "/datum/species/vulpkanin", "/datum/species/moth", "/datum/species/dracon", "/datum/species/dwarf/gnome")

/datum/outfit/job/roguetown/rockhill_class/wretch/lunacyembracer
	name = "Lunacy Embracer"
	jobtype = /datum/job/roguetown/wretch

/datum/attribute_holder/sheet/job/rockhill_class/wretch/lunacyembracer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -2,
		ROGUE_STAT_PERCEPTION = -2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_STRENGTH = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/unarmed = 50,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/craft/alchemy = 30,
		/datum/attribute/skill/craft/carpentry = 20,
		/datum/attribute/skill/craft/cooking = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/masonry = 30,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/labor/farming = 50,
		/datum/attribute/skill/labor/fishing = 30,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/wretch/lunacyembracer
	name = "Lunacy Embracer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/lunacyembracer
	desc = "You have rejected and terrorized civilization in the name of nature. You run wild under the moon, a terror to the townsfolk and a champion of Dendor's wild domain."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/lunacyembracer
	rockhill_traits = list(
		TRAIT_NUDIST,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_DODGEEXPERT,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_STRONGBITE,
		TRAIT_WOODWALKER,
		TRAIT_NASTY_EATER,
		TRAIT_CALTROPIMMUNE,
		TRAIT_LONGSTRIDER,
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN,
		TRAIT_WILDERNESSGUIDE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_disallowed_races = list("/datum/species/harpy")

/datum/outfit/job/roguetown/rockhill_class/wretch/mistwalker
	name = "Mistwalker"
	jobtype = /datum/job/roguetown/wretch
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/black
	head = /obj/item/clothing/head/roguetown/mentorhat
	mask = /obj/item/clothing/mask/rogue/facemask/steel/kazengun
	neck = /obj/item/clothing/neck/roguetown/gorget/steel/kazengun
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	wrists = /obj/item/clothing/wrists/roguetown/bracers/black
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	l_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_pocket = /obj/item/rogueweapon/scabbard/sword/kazengun/noparry
	r_hand = /obj/item/rogueweapon/sword/long/kriegmesser/ssangsudo
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/kazengun = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath/kazengun = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/mistwalker
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_FORTUNE = -2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 30,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/labor/butchering = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/swimming = 40,
		)

/datum/rockhill_advclass/wretch/mistwalker
	name = "Mistwalker"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/mistwalker
	desc = "Hailing from Kazengun you were once a sacred guardian, dedicating your lyfe to protecting your chosen shrine of the gods against brigands and fiends from beyond alike... now? Your sacred home has fallen, claimed by ruinous forces and you are banished to wander the realm. What will you find in your search for purpose?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/mistwalker
	rockhill_traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_JOURNEYS_END,
		TRAIT_OVERTHERETIC,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 2
	rogue_allowed_races = list("/datum/species/human/northern", "/datum/species/human/halfelf", "/datum/species/elf/dark", "/datum/species/elf/wood", "/datum/species/dwarf/mountain", "/datum/species/tieberian", "/datum/species/aasimar", "/datum/species/lizardfolk", "/datum/species/lupian", "/datum/species/tabaxi", "/datum/species/vulpkanin", "/datum/species/akula", "/datum/species/moth", "/datum/species/dracon", "/datum/species/anthromorph", "/datum/species/anthromorphsmall", "/datum/species/demihuman", "/datum/species/halforc", "/datum/species/kobold", "/datum/species/goblinp", "/datum/species/dullahan", "/datum/species/lamia", "/datum/species/dwarf/gnome", "/datum/species/harpy", "/datum/species/arachnid")
	rogue_allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora, /datum/patron/psydon, /datum/patron/inhumen/zizo, /datum/patron/inhumen/graggar, /datum/patron/inhumen/matthios, /datum/patron/inhumen/baotha)
	rogue_subclass_languages = list("/datum/language/kazengunese")
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)
	rogue_stat_ceilings = list(ROGUE_STAT_STRENGTH = 14, ROGUE_STAT_INTELLIGENCE = 14)

/datum/outfit/job/roguetown/rockhill_class/wretch/necromancer
	name = "Necromancer"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/necromancer
	head = /obj/item/clothing/head/roguetown/necromhood
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/implement/greater/ruby
	l_pocket = /obj/item/rogueweapon/huntingknife
	r_pocket = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	backpack_contents = list(
		/obj/item/rogueweapon/spellbook/greater = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/ritechalk = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/necromancer
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 50,
		)

/datum/rockhill_advclass/wretch/necromancer
	name = "Necromancer"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/necromancer
	desc = "You have been ostracized and hunted by society for your dark magics and perversion of life."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/necromancer
	rockhill_traits = list(
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_GRAVEROBBER,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_RITUALIST,
		TRAIT_OUTLANDER,
		TRAIT_MAGEDEXTERITY,
		TRAIT_ARCYNE,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/outlaw
	name = "Outlaw"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/rogueweapon/scabbard/sword
	r_pocket = /obj/item/quiver/bolts
	l_hand = /obj/item/rogueweapon/sword/rapier
	r_hand = /obj/item/rogueweapon/mace/cudgel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/roguebag = 1,
		/obj/item/ammo_casing/caseless/rogue/bolt/water = 3,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/outlaw
	raw_attribute_list = list(
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 3,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/lockpicking = 50,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/stealing = 50,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 30,
		)

/datum/rockhill_advclass/wretch/outlaw
	name = "Outlaw"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/outlaw
	desc = "You are the person folk fear at night - use your cunning and speed to strike fast and get out with your spoils before anyone notices."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/outlaw
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/outlaw/marauder
	name = "Marauder"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
	cloak = /obj/item/clothing/cloak/stabard/dungeon
	head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/iron
	r_hand = /obj/item/rogueweapon/mace/cudgel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/roguebag = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/outlaw/marauder
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = -1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/wretch/outlaw/marauder
	name = "Marauder"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/outlaw/marauder
	desc = "You are a brigand and a pillager - you prefer to get your coins with direct means from unfortunate victims."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/outlaw/marauder
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_subclass_languages = list("/datum/language/thievescant")
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/plaguebearer
	name = "Malpractitioner"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/shirt/robe/physician
	head = /obj/item/clothing/head/roguetown/physician
	mask = /obj/item/clothing/mask/rogue/physician
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/quiver/poisonarrows
	r_pocket = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_hand = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/poison = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/stampoison = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/strongpoison = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		/obj/item/natural/worms/leech/cheele = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/plaguebearer
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_PERCEPTION = 3,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 60,
		/datum/attribute/skill/craft/carpentry = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/craft/sewing = 30,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 60,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/wretch/plaguebearer
	name = "Malpractitioner"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/plaguebearer
	desc = "A disgraced physician forced into exile and years of hardship, you have turned to a private practice. Operating beyond the bounds of the law, you work with traitors, heretics, and common criminals as easily as your peers would treat a peasant or craftsman."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/plaguebearer
	rockhill_traits = list(
		TRAIT_CICERONE,
		TRAIT_NOSTINK,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/poacher
	name = "Poacher"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/raincloak/green
	head = /obj/item/clothing/head/roguetown/archercap
	mask = /obj/item/clothing/mask/rogue/wildguard
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/quiver/arrows
	r_pocket = /obj/item/rogueweapon/scabbard/sheath
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel
	backpack_contents = list(
		/obj/item/bait = 1,
		/obj/item/rogueweapon/huntingknife/combat/messer = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/poacher
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/axes = 30,
		/datum/attribute/skill/combat/bows = 40,
		/datum/attribute/skill/combat/crossbows = 40,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/maces = 30,
		/datum/attribute/skill/combat/slings = 40,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/hunting = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/wretch/poacher
	name = "Poacher"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/poacher
	desc = "You have rejected society and its laws, choosing life in the wilderness instead. Simple thieving highwayman or freedom fighter, you take from those who have and give to the have-nots. Fancy, how the latter includes yourself!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/poacher
	rockhill_traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_WOODSMAN,
		TRAIT_OUTDOORSMAN,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_EXPERT_HUNTER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/pyromaniac
	name = "Pyromaniac"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/splintlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	suit = /obj/item/clothing/suit/roguetown/armor/brigandine/light
	head = /obj/item/clothing/head/roguetown/helmet/heavy/sheriff
	mask = /obj/item/clothing/mask/rogue/facemask/
	neck = /obj/item/clothing/neck/roguetown/chaincoif/full
	gloves = /obj/item/clothing/gloves/roguetown/plate/iron
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	l_pocket = /obj/item/quiver/pyroarrows
	l_hand = /obj/item/bomb
	r_hand = /obj/item/bomb
	backpack_contents = list(
		/obj/item/bomb = 2,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/flint = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/pyromaniac
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 3,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/engineering = 10,
		/datum/attribute/skill/labor/farming = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/wretch/pyromaniac
	name = "Pyromaniac"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/pyromaniac
	desc = "A notorious arsonist with a penchant for fire, you wield your own personal vendetta against the chaotic forces within the realm. Bring mayhem and destruction with flame and misfortune! Just... try not to hit yourself with your explosives - you aren't fireproof, after all."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/pyromaniac
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/roguemage
	name = "Rogue Mage"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded
	cloak = /obj/item/clothing/suit/roguetown/shirt/robe/black
	head = /obj/item/clothing/head/roguetown/roguehood/black
	mask = /obj/item/clothing/mask/rogue/eyepatch
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/backpack
	l_pocket = /obj/item/storage/magebag
	r_pocket = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	backpack_contents = list(
		/obj/item/rogueweapon/spellbook/greater = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/chalk = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/roguemage
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 4,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/arcyne = 40,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/staves = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/wretch/roguemage
	name = "Rogue Mage"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/roguemage
	desc = "They reject your genius, they cast you out, they call you unethical. They do not understand the SACRIFICES you must make. But it does not matter anymore, your power eclipse any of those fools, save for the Court Magos themselves. Show them true magic. Why do I have an eyepatch?"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/roguemage
	rockhill_traits = list(
		TRAIT_ARCYNE,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		"Stashed Funds" = /obj/item/roguecoin/silver/pile/wretchpile,
		)
	rogue_age_mod = list(
		"age" = "Old",
		"skills" = list(/datum/attribute/skill/magic/arcane = 50),
		"minor" = 1,
		"utility" = 3,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/vigilante
	name = "Masked Lunatic"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	neck = /obj/item/clothing/neck/roguetown/chaincoif/
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
	back = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/vigilante
	raw_attribute_list = list(
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/crafting = 20,
		/datum/attribute/skill/craft/sewing = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/wretch/vigilante
	name = "Masked Lunatic"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/vigilante
	desc = "You were a disenfranchised pauper, sickened by the rampant corruption of the garrison - or perhaps, just a crazed vagrant in a costume? Whether those brutalized 'thieves' were justified in their acts is up to YOU to decide, not them! You specialize in utilizing your various gadgets and thrown projectiles to dote out JUSTICE, however you see it fit."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/vigilante
	rockhill_traits = list(
		TRAIT_PERFECT_TRACKER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/wretch/wretchedtoiler
	name = "Wretched Toiler"
	jobtype = /datum/job/roguetown/wretch
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	suit = /obj/item/clothing/suit/roguetown/armor/leather/studded
	cloak = /obj/item/clothing/suit/roguetown/shirt/robe/black
	head = /obj/item/clothing/head/roguetown/roguehood/black
	mask = /obj/item/clothing/mask/rogue/eyepatch
	neck = /obj/item/clothing/neck/roguetown/leather
	gloves = /obj/item/clothing/gloves/roguetown/angle
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/implement/greater/ruby
	l_pocket = /obj/item/storage/magebag/associate
	r_pocket = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	r_hand = /obj/item/scrying
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/recipe_book/magic = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/wretch/wretchedtoiler
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = -2,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_STRENGTH = -1,
		ROGUE_STAT_WILLPOWER = 1,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/craft/armorsmithing = 40,
		/datum/attribute/skill/craft/blacksmithing = 40,
		/datum/attribute/skill/craft/crafting = 40,
		/datum/attribute/skill/craft/engineering = 40,
		/datum/attribute/skill/craft/sewing = 40,
		/datum/attribute/skill/craft/smelting = 40,
		/datum/attribute/skill/craft/tanning = 40,
		/datum/attribute/skill/craft/weaponsmithing = 40,
		/datum/attribute/skill/magic/arcane = 40,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 40,
		)

/datum/rockhill_advclass/wretch/wretchedtoiler
	name = "Wretched Toiler"
	outfit = /datum/outfit/job/roguetown/rockhill_class/wretch/wretchedtoiler
	desc = "The wretched engine of evil churns ever onward - the gears pushed by wretched toilers such as yourself. And toil you shall - until the machinations of thine masters come to fruition."
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/wretch/wretchedtoiler
	rockhill_traits = list(
		TRAIT_RITUALIST,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_SMITHING_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_LEGENDARY_MINER,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLAW,
		TRAIT_HERESIARCH,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_ZURCH,
		)
	maximum_slots = 1
	rogue_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		)

/datum/outfit/job/roguetown/rockhill_class/zybantine_advisor
	name = "Advisor"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/leather/heavy
	cloak = /obj/item/clothing/cloak/raincloak/red
	head = /obj/item/clothing/head/roguetown/roguehood/shalal
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel/short
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	l_pocket = /obj/item/flashlight/flare/torch/lantern
	r_pocket = /obj/item/quiver/bolts
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/paper/scroll = 2,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/zybantine_advisor
	raw_attribute_list = list(
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 2,
		ROGUE_STAT_SPEED = 2,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/tracking = 50,
		)

/datum/rockhill_advclass/zybantine_advisor
	name = "Advisor"
	outfit = /datum/outfit/job/roguetown/rockhill_class/zybantine_advisor
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/zybantine_advisor
	rockhill_traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_DODGEEXPERT,
		TRAIT_PERFECT_TRACKER,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/zybantine_amirah
	name = "Amirah"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	suit = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	head = /obj/item/clothing/head/roguetown/nyle
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	back = /obj/item/storage/backpack/rogue/satchel/short
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 2,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/zybantine_amirah
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 3,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_WILLPOWER = 3,
		/datum/attribute/skill/combat/knives = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/music = 50,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/riding = 40,
		/datum/attribute/skill/misc/sneaking = 10,
		/datum/attribute/skill/misc/stealing = 10,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/zybantine_amirah
	name = "Amirah"
	outfit = /datum/outfit/job/roguetown/rockhill_class/zybantine_amirah
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/zybantine_amirah
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_SEEPRICES,
		TRAIT_NUTCRACKER,
		TRAIT_GOODLOVER,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/zybantine_emir
	name = "Emir"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/trou/leather/pontifex/zyb
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/half/rider/red
	head = /obj/item/clothing/head/roguetown/circlet
	mask = /obj/item/clothing/head/roguetown/roguehood/red
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	back = /obj/item/storage/backpack/rogue/satchel/short
	l_pocket = /obj/item/rogueweapon/scabbard/sword/royal
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/rogueweapon/scabbard/sheath/royal = 1,
		/obj/item/paper/scroll/writ_of_esteem/zybantine = 1,
		/obj/item/natural/feather = 1,
		/obj/item/paper/scroll = 2,
		/obj/item/storage/belt/rogue/pouch/coins/veryrich = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 2,
		)

/datum/attribute_holder/sheet/job/rockhill_class/zybantine_emir
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 1,
		ROGUE_STAT_INTELLIGENCE = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/maces = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/misc/swimming = 30,
		)

/datum/rockhill_advclass/zybantine_emir
	name = "Emir"
	outfit = /datum/outfit/job/roguetown/rockhill_class/zybantine_emir
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/zybantine_emir
	rockhill_traits = list(
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_OUTLANDER,
		)

/datum/outfit/job/roguetown/rockhill_class/zybantine_janissary
	name = "Janissary Bodyguard"
	jobtype = /datum/job/roguetown/rockhill_migrant
	uniform = /obj/item/clothing/under/roguetown/chainlegs
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/zyb
	suit = /obj/item/clothing/suit/roguetown/armor/plate/scale
	cloak = /obj/item/clothing/cloak/half/rider/red
	head = /obj/item/clothing/head/roguetown/helmet/sallet/zyb
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/shalal
	back = /obj/item/storage/backpack/rogue/satchel/short
	backr = /obj/item/rogueweapon/shield/tower/zyb
	l_pocket = /obj/item/rogueweapon/scabbard/sword/noble
	r_pocket = /obj/item/flashlight/flare/torch/lantern
	l_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
		/obj/item/rogueweapon/scabbard/sheath/noble = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 1,
		)

/datum/attribute_holder/sheet/job/rockhill_class/zybantine_janissary
	raw_attribute_list = list(
		ROGUE_STAT_CONSTITUTION = 2,
		ROGUE_STAT_PERCEPTION = 1,
		ROGUE_STAT_SPEED = 1,
		ROGUE_STAT_STRENGTH = 2,
		ROGUE_STAT_WILLPOWER = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/swimming = 20,
		)

/datum/rockhill_advclass/zybantine_janissary
	name = "Janissary Bodyguard"
	outfit = /datum/outfit/job/roguetown/rockhill_class/zybantine_janissary
	desc = "Choose me!"
	attribute_sheet = /datum/attribute_holder/sheet/job/rockhill_class/zybantine_janissary
	rockhill_traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_BREADY,
		TRAIT_LONGSTRIDER,
		TRAIT_OUTLANDER,
		)
