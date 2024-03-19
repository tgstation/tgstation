#define KIT_ITEM_CATEGORY_SUPPORT "support"
#define KIT_ITEM_CATEGORY_WEAPONS "weapons"
#define KIT_ITEM_CATEGORY_MISC "misc"
/obj/item/storage/box/syndie_kit/imp_hard_spear
	name = "hardlight spear implant box"

/obj/item/storage/box/syndie_kit/imp_hard_spear/PopulateContents()
	new /obj/item/implanter/hard_spear(src)

/obj/item/storage/box/syndie_kit/imp_hard_spear/max
	name = "commanding hardlight spear implant box"

/obj/item/storage/box/syndie_kit/imp_hard_spear/max/PopulateContents()
	new /obj/item/implanter/hard_spear/max(src)

/obj/item/storage/box/syndimaid
	name = "Syndicate maid outfit"
	desc = "A box containing a 'tactical' and 'practical' maid outfit."
	icon_state = "syndiebox"

/obj/item/storage/box/syndimaid/PopulateContents()
	var/static/items_inside = list(
		/obj/item/clothing/head/maidheadband/syndicate = 1,
		/obj/item/clothing/under/syndicate/skirt/maid = 1,
		/obj/item/clothing/gloves/combat/maid = 1,
		/obj/item/clothing/accessory/maidapron/syndicate = 1,
		/obj/item/clothing/shoes/heels/syndicate = 1,)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/syndibunny
	name = "Syndicate bunny assassin outfit"
	desc = "A box containing a high tech specialized syndicate... bunny suit?"
	icon_state = "syndiebox"

/obj/item/storage/box/syndibunny/PopulateContents()
	var/static/items_inside = list(
		/obj/item/clothing/head/playbunnyears/syndicate = 1,
		/obj/item/clothing/under/syndicate/syndibunny = 1,
		/obj/item/clothing/suit/jacket/tailcoat/syndicate = 1,
		/obj/item/clothing/neck/tie/bunnytie/syndicate = 1,
		/obj/item/clothing/shoes/heels/syndicate = 1,)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/syndie_kit/contractor_loadout
	name = "Standard Loadout"
	desc = "Supplied to Syndicate contractors, providing their specialised MODsuit and chameleon uniform."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndie_kit/contractor_loadout/PopulateContents()
	new /obj/item/mod/control/pre_equipped/contractor(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/card/id/advanced/chameleon(src)
	new /obj/item/lighter(src)
	new /obj/item/jammer(src)

/obj/item/storage/box/syndie_kit/contract_kit/PopulateContents()
	new /obj/item/storage/box/syndie_kit/contractor_loadout(src)
	new /obj/item/melee/baton/telescopic/contractor_baton(src)

	// You get one item from each sub list
	var/static/list/item_list = list(
		KIT_ITEM_CATEGORY_SUPPORT = list(
			/obj/item/pen/sleepy,
			/obj/item/storage/medkit/tactical,
			/obj/item/pen/sleepy,
			/obj/item/gun/syringe/syndicate,
			/obj/item/storage/backpack/duffelbag/syndie/x4,
			/obj/item/clothing/shoes/chameleon/noslip,
			/obj/item/clothing/glasses/thermal/syndi,
			/obj/item/storage/box/syndie_kit/imp_freedom,
			/obj/item/reagent_containers/hypospray/medipen/stimulants,
			/obj/item/card/emag/doorjack,
		),

		KIT_ITEM_CATEGORY_WEAPONS = list(
			/obj/item/melee/powerfist, //over value but its never used
			/obj/item/storage/box/syndie_kit/origami_bundle,
			/obj/item/clothing/gloves/krav_maga/combatglovesplus,
			/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot,
			/obj/item/storage/box/syndie_kit/throwing_weapons,
			/obj/item/storage/box/syndie_kit/chemical, //technically over value but it cant be used on its own
			/obj/item/autosurgeon/syndicate/anti_stun, //way over value but you dont get a real weapon, might have to remove this one
		),

		KIT_ITEM_CATEGORY_MISC = list(
			/obj/item/syndie_glue,
			/obj/item/slimepotion/slime/sentience/nuclear,
			/obj/item/storage/box/syndie_kit/imp_uplink,
			/obj/item/grenade/clusterbuster/soap,
			/obj/item/flashlight/emp,
			/obj/item/encryptionkey/syndicate,
			/obj/item/multitool/ai_detect,
			/obj/item/storage/toolbox/syndicate,
			/obj/item/card/emag,
			/obj/item/ai_module/syndicate,
		)
	)

	var/list/items_to_give = list()
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_SUPPORT])] = 1
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_WEAPONS])] = 1
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_MISC])] = 1
	generate_items_inside(items_to_give, src)

	// Paper guide
	new /obj/item/paper/contractor_guide(src)
	new /obj/item/pinpointer/area_pinpointer(src)

/obj/item/storage/box/syndie_kit/contract_kit/midround/PopulateContents()
	// You get one item from each sub list
	var/static/list/item_list = list(
		KIT_ITEM_CATEGORY_SUPPORT = list(
			/obj/item/pen/sleepy,
			/obj/item/storage/medkit/tactical,
			/obj/item/pen/sleepy,
			/obj/item/gun/syringe/syndicate,
			/obj/item/storage/backpack/duffelbag/syndie/x4,
			/obj/item/clothing/shoes/chameleon/noslip,
			/obj/item/clothing/glasses/thermal/syndi,
			/obj/item/storage/box/syndie_kit/imp_freedom,
			/obj/item/reagent_containers/hypospray/medipen/stimulants,
			/obj/item/card/emag/doorjack,
		),

		KIT_ITEM_CATEGORY_WEAPONS = list(
			/obj/item/melee/powerfist, //over value but its never used
			/obj/item/storage/box/syndie_kit/origami_bundle,
			/obj/item/clothing/gloves/krav_maga/combatglovesplus,
			/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot,
			/obj/item/storage/box/syndie_kit/throwing_weapons,
			/obj/item/storage/box/syndie_kit/chemical, //technically over value but it cant be used on its own
			/obj/item/autosurgeon/syndicate/anti_stun, //way over value but you dont get a real weapon, might have to remove this one
		),

		KIT_ITEM_CATEGORY_MISC = list(
			/obj/item/syndie_glue,
			/obj/item/slimepotion/slime/sentience/nuclear,
			/obj/item/storage/box/syndie_kit/imp_uplink,
			/obj/item/grenade/clusterbuster/soap,
			/obj/item/flashlight/emp,
			/obj/item/encryptionkey/syndicate,
			/obj/item/multitool/ai_detect,
			/obj/item/storage/toolbox/syndicate,
			/obj/item/card/emag,
			/obj/item/ai_module/syndicate,
		)
	)

	var/list/items_to_give = list()
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_SUPPORT])] = 1
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_WEAPONS])] = 1
	items_to_give[pick(item_list[KIT_ITEM_CATEGORY_MISC])] = 1
	generate_items_inside(items_to_give, src)

	// Paper guide
	new /obj/item/paper/contractor_guide/midround(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter(src)
	new /obj/item/jammer(src)

#undef KIT_ITEM_CATEGORY_SUPPORT
#undef KIT_ITEM_CATEGORY_WEAPONS
#undef KIT_ITEM_CATEGORY_MISC
