/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 5 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = /obj/item/clothing/head/helmet/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = /obj/item/storage/belt/fannypack
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 2 SECONDS
	category = CAT_CONTAINERS

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/scienceglasses
	name = "Science Glasses"
	result = /obj/item/clothing/glasses/sunglasses/chemical
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/scienceglassesremoval
	name = "Chemical Scanner removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/chemical = 1)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = /obj/item/clothing/suit/costume/ghost_sheet
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardboots
	name = "Lizard Skin Boots"
	result = /obj/effect/spawner/random/clothing/lizardboots
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1, /obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/prisonsuit
	name = "Prisoner Uniform (Suit)"
	result = /obj/item/clothing/under/rank/prisoner
	reqs = list(/obj/item/stack/sheet/cloth = 3, /obj/item/stack/license_plates = 1)
	time = 2 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/prisonskirt
	name = "Prisoner Uniform (Skirt)"
	result = /obj/item/clothing/under/rank/prisoner/skirt
	reqs = list(/obj/item/stack/sheet/cloth = 3, /obj/item/stack/license_plates = 1)
	time = 2 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/prisonshoes
	name = "Orange Prison Shoes"
	result = /obj/item/clothing/shoes/sneakers/orange
	reqs = list(/obj/item/stack/sheet/cloth = 2, /obj/item/stack/license_plates = 1)
	time = 1 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/tv_helmet
	name = "Television Helmet"
	result = /obj/item/clothing/head/costume/tv_head
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_CROWBAR)
	reqs = list(/obj/item/wallframe/status_display = 1)
	time = 2 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardhat
	name = "Lizard Cloche Hat"
	result = /obj/item/clothing/head/costume/lizard
	time = 1 SECONDS
	reqs = list(/obj/item/organ/external/tail/lizard = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardhat_alternate
	name = "Lizard Cloche Hat"
	result = /obj/item/clothing/head/costume/lizard
	time = 1 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/kittyears
	name = "Kitty Ears"
	result = /obj/item/clothing/head/costume/kitty/genuine
	time = 1 SECONDS
	reqs = list(
		/obj/item/organ/external/tail/cat = 1,
		/obj/item/organ/internal/ears/cat = 1,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bonearmor
	name = "Bone Armor"
	result = /obj/item/clothing/suit/armor/bone
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_CLOTHING

/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = /obj/item/clothing/accessory/talisman
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/sinew = 1,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = /obj/item/clothing/accessory/skullcodpiece
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 1,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/skilt
	name = "Sinew Kilt"
	result = /obj/item/clothing/accessory/skilt
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 2,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = /obj/item/clothing/gloves/bracer
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/sinew = 1,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/skullhelm
	name = "Skull Helmet"
	result = /obj/item/clothing/head/helmet/skull
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_CLOTHING

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = /obj/item/clothing/suit/hooded/cloak/goliath
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 2,
	) //it takes 4 goliaths to make 1 cloak if the plates are skinned
	category = CAT_CLOTHING

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = /obj/item/clothing/suit/hooded/cloak/drake
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/ashdrake = 5,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/godslayer
	name = "Godslayer Armour"
	result = /obj/item/clothing/suit/hooded/cloak/godslayer
	time = 6 SECONDS
	reqs = list(
		/obj/item/ice_energy_crystal = 1,
		/obj/item/wendigo_skull = 1,
		/obj/item/clockwork_alloy = 1,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/mummy
	name = "Mummification Bandages (Mask)"
	result = /obj/item/clothing/mask/mummy
	time = 1 SECONDS
	tool_paths = list(/obj/item/nullrod/egyptian)
	reqs = list(/obj/item/stack/sheet/cloth = 2)
	category = CAT_CLOTHING

/datum/crafting_recipe/mummy/body
	name = "Mummification Bandages (Body)"
	result = /obj/item/clothing/under/costume/mummy
	reqs = list(/obj/item/stack/sheet/cloth = 5)

/datum/crafting_recipe/chaplain_hood
	name = "Follower Hoodie"
	result = /obj/item/clothing/suit/hooded/chaplain_hoodie
	time = 1 SECONDS
	tool_paths = list(
		/obj/item/clothing/suit/hooded/chaplain_hoodie,
		/obj/item/storage/book/bible,
	)
	reqs = list(/obj/item/stack/sheet/cloth = 4)
	category = CAT_CLOTHING

/datum/crafting_recipe/flower_garland
	name = "Flower Garland"
	result = /obj/item/clothing/head/costume/garland
	time = 1 SECONDS
	reqs = list(
		/obj/item/food/grown/poppy = 4,
		/obj/item/food/grown/harebell = 4,
		/obj/item/food/grown/rose = 4,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/pillow_suit
	name = "pillow suit"
	result = /obj/item/clothing/suit/pillow_suit
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sticky_tape = 10,
		/obj/item/pillow = 5,
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/pillow_hood
	name = "pillow hood"
	result = /obj/item/clothing/head/pillow_hood
	tool_behaviors = list(TOOL_WIRECUTTER, TOOL_KNIFE)
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sticky_tape = 5,
		/obj/item/pillow = 1,
	)
	category = CAT_CLOTHING
