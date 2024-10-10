/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	var/fire_resist = T0C+100
	armor_type = /datum/armor/none
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	limb_integrity = 0 // disabled for most exo-suits
	allowed = list(
		// basic stuff
		/obj/item/tank,
		/obj/item/flashlight,
		/obj/item/modular_computer/pda,
		/obj/item/storage/bag,
		/obj/item/pen,
		/obj/item/stamp,
		/obj/item/paper,
		/obj/item/disk,
		/obj/item/radio,
		/obj/item/stack/spacecash,

		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/spray,
		/obj/item/lighter,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/cigarette,

		/obj/item/cane,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/toy,
		/obj/item/clothing/mask/facehugger/toy,
		/obj/item/pillow,

		// Command
		/obj/item/storage/lockbox/medal,
		/obj/item/tank/jetpack/oxygen/captain,

		// Botanist
		/obj/item/cultivator,
		/obj/item/geneshears,
		/obj/item/graft,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/secateurs,
		/obj/item/seeds,
		/obj/item/scythe,

		// Chaplain
		/obj/item/book/bible,
		/obj/item/nullrod,
		/obj/item/storage/fancy/candle_box,

		// Chef
		/obj/item/kitchen,

		// Engineering
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/construction/rtd,
		/obj/item/crowbar,
		/obj/item/multitool,
		/obj/item/geiger_counter,

		/obj/item/extinguisher,
		/obj/item/fireaxe/metal_h2_axe,

		// Cargo
		/obj/item/boxcutter,
		/obj/item/dest_tagger,
		/obj/item/universal_scanner,
		/obj/item/mail,
		/obj/item/delivery/small,

		// Miner
		/obj/item/melee/cleaving_saw,
		/obj/item/climbing_hook,
		/obj/item/grapple_gun,
		/obj/item/kinetic_crusher,
		/obj/item/mining_scanner,
		/obj/item/organ/internal/monster_core,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/shovel,
		/obj/item/shovel/serrated,
		/obj/item/trench_tool,

		//Weapons
		/obj/item/gun, // maybe too liberal? could nerf this later, dunno
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/knife,
		/obj/item/melee,
		/obj/item/spear,

		/obj/item/banner,
		/obj/item/claymore,

		/obj/item/shield/energy,

		// Medsci
		/obj/item/healthanalyzer,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgical_drapes,

		/obj/item/experi_scanner,

		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/grenade/chem_grenade,

		/obj/item/assembly/flash/handheld,
		/obj/item/gun/syringe,

		/obj/item/biopsy_tool,
		/obj/item/dnainjector,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/sequence_scanner,
		/obj/item/autopsy_scanner,

		// Sec
		/obj/item/detective_scanner,
		/obj/item/restraints/handcuffs,
		/obj/item/taperecorder,
		/obj/item/storage/belt/holster/,

		// Janni
		/obj/item/access_key,
		/obj/item/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/soap,

		// Wiz
		/obj/item/teleportation_scroll,
		/obj/item/highfrequencyblade/wizard,
		/obj/item/spellbook,

		// Cult/Heretic
		/obj/item/tome,
		/obj/item/melee/cultblade,
		/obj/item/melee/sickly_blade,

		// Ayyy
		/obj/item/abductor,

		// Clown, the greatest antag of them all
		/obj/item/megaphone/clown,
		/obj/item/soap,
		/obj/item/food/pie/cream,
		/obj/item/bikehorn,
		/obj/item/instrument,
		/obj/item/reagent_containers/cup/soda_cans/canned_laughter,
		/obj/item/toy/crayon,
		/obj/item/toy/crayon/spraycan,
		/obj/item/toy/crayon/spraycan/lubecan,
		/obj/item/grown/bananapeel,
		/obj/item/food/grown/banana
	)

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]")
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		. += mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood")

	var/mob/living/carbon/human/wearer = loc
	if(!ishuman(wearer) || !wearer.w_uniform)
		return
	var/obj/item/clothing/under/undershirt = wearer.w_uniform
	if(!istype(undershirt) || !LAZYLEN(undershirt.attached_accessories))
		return

	var/obj/item/clothing/accessory/displayed = undershirt.attached_accessories[1]
	if(displayed.above_suit)
		. += undershirt.accessory_overlay

/obj/item/clothing/suit/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_oversuit()
