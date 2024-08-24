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

/obj/item/storage/box/clonearmy
	name = "Syndicate clone army kit"
	desc = "A box containing everything you need to make a clone army. The disk inside cunningly disguised as a DNA data disk is used to give all clones a directive they must follow."
	icon_state = "syndiebox"

/obj/item/storage/box/clonearmy/PopulateContents()
	var/static/items_inside = list(
		/obj/item/disk/clonearmy = 1,
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/glass = 4,
		/obj/item/stack/cable_coil = 1,
		/obj/item/circuitboard/machine/clonepod/experimental = 1,
		/obj/item/circuitboard/machine/clonescanner = 1,
		/obj/item/circuitboard/computer/cloning = 1,
		/obj/item/stock_parts/manipulator/femto = 2, // The syndicate is so cool they gave you tier four parts. RIP my joke about tier 2 parts.
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver/nuke = 1,
		/obj/item/multitool = 1, // For those who want space between the cloning console and pod.
		/obj/item/language_manual/codespeak_manual/unlimited = 1,
		/obj/item/implanter/radio/syndicate = 1, // So you can communicate with your clones, instead of having random evil clones roaming the halls with no direction.
		/obj/item/paper/clone_guide = 1,)
	generate_items_inside(items_inside, src)

/obj/item/paper/clone_guide
	name = "Clone Army User Manual" // Start and end shamelessly copied from contractor guide. I am not a good writer. This is also ugly.
	default_raw_text = {"Welcome agent, thank you for purchasing the clone army kit.<br>\
			<ul>\
			<li>The "DNA data disk" inside is actually a sophisticated device that can be used to hijack an experimental cloner, giving the clones a directive they must follow.</li>\
			<li>In order to use this disk, use it in your hand, and input your desired directive, before hitting the cloner with the disk. You can input and upload a new objective to replace the old one if you ever feel like it, the disk is infinitely reusable.</li>\
			<li>The clones will be given basic access, including syndicate, maintenance, genetics, and mineral storage. They will also be given an implanted syndicate radio and automatically taught codespeak. Syndicate turrets and the like will recognize the clones as a member of the syndicate.</li>\
			<li>Be wary, the clones will have obviously evil red eyes, which will alert anyone who sees them with no eye covering that something is wrong with them. Also, don't try to use this on newer cloning models, Nanotrasen fixed the vulnerability that lets the disk work in their newer models.</li>\
			<li>When hacked, a cloner will begin to operate slower, and anyone who examines it closely will be able to see that the cloner is malfunctioning.</li>\
			<li>A tip, any activated mutations in the person being scanned, will be present in the clones produced, allowing you to give the clones some intrinsic powers. Make sure to use activators, not mutators.</li>\
			</ul>
			Good luck agent. You can burn this document."}

/obj/item/storage/box/syndie_kit/shotgun_revolver
	desc = "A box containing a value bundled shotgun revolver and some shotgun shells. Comes with two quickload cartridges of slugs"

/obj/item/storage/box/syndie_kit/shotgun_revolver/PopulateContents()
	new /obj/item/gun/ballistic/revolver/shotgun_revolver(src)
	new /obj/item/ammo_box/advanced/s12gauge(src)
	new /obj/item/ammo_box/advanced/s12gauge(src)


/obj/item/storage/box/syndie_kit/surplus_smg_bundle
	desc = "A box containing a surplus space soviet Plastikov and two magazines. Perfect for henchmen."

/obj/item/storage/box/syndie_kit/surplus_smg_bundle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/plastikov(src)
	new /obj/item/ammo_box/magazine/plastikov9mm(src)
	new /obj/item/ammo_box/magazine/plastikov9mm(src)

#undef KIT_ITEM_CATEGORY_SUPPORT
#undef KIT_ITEM_CATEGORY_WEAPONS
#undef KIT_ITEM_CATEGORY_MISC
