#define KIT_RECON "recon"
#define KIT_BLOODY_SPAI "bloodyspai"
#define KIT_STEALTHY "stealth"
#define KIT_SCREWED "screwed"
#define KIT_SABOTAGE "sabotage"
#define KIT_GUN "guns"
#define KIT_MURDER "murder"
#define KIT_IMPLANTS "implant"
#define KIT_HACKER "hacker"
#define KIT_SNIPER "sniper"
#define KIT_NUKEOPS_METAGAME "metaops"
#define KIT_LORD_SINGULOTH "lordsingulo"
#define KIT_REVOLUTIONARY "revolutionary"

#define KIT_JAMES_BOND "bond"
#define KIT_NINJA "ninja"
#define KIT_DARK_LORD "darklord"
#define KIT_WHITE_WHALE_HOLY_GRAIL "white_whale_holy_grail"
#define KIT_MAD_SCIENTIST "mad_scientist"
#define KIT_BEES "bee"
#define KIT_MR_FREEZE "mr_freeze"
#define KIT_TRAITOR_2006 "ancient"
#define KIT_DEAD_MONEY "dead_money"
#define KIT_SAM_FISHER "sam_fisher"
#define KIT_PROP_HUNT "prop_hunt"

/// last audited december 2022
/obj/item/storage/box/syndicate
	storage_type = /datum/storage/box/syndicate

/obj/item/storage/box/syndicate/bundle_a/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	switch (pick_weight(list(
		KIT_RECON = 2,
		KIT_BLOODY_SPAI = 3,
		KIT_STEALTHY = 2,
		KIT_SCREWED = 2,
		KIT_SABOTAGE = 3,
		KIT_GUN = 2,
		KIT_MURDER = 2,
		KIT_IMPLANTS = 1,
		KIT_HACKER = 3,
		KIT_SNIPER = 1,
		KIT_NUKEOPS_METAGAME = 1,
		KIT_REVOLUTIONARY = 2
		)))
		if(KIT_RECON)
			return list(
				/obj/item/clothing/glasses/thermal/xray, // ~8 tc?
				/obj/item/storage/briefcase/launchpad, //6 tc
				/obj/item/binoculars, // 2 tc?
				/obj/item/encryptionkey/syndicate, // 2 tc
				/obj/item/storage/box/syndie_kit/space, //4 tc
				/obj/item/grenade/frag, // ~2 tc each?
				/obj/item/grenade/frag,
				/obj/item/flashlight/emp, // 4 tc
			)

		if(KIT_BLOODY_SPAI)
			return list(
				/obj/item/card/id/advanced/chameleon, // 2 tc
				/obj/item/clothing/under/chameleon, // 2 tc since it's not the full set
				/obj/item/clothing/mask/chameleon, // Goes with above
				/obj/item/clothing/shoes/chameleon/noslip, // 2 tc
				/obj/item/computer_disk/syndicate/camera_app, // 1 tc
				/obj/item/multitool/ai_detect, // 1 tc
				/obj/item/encryptionkey/syndicate, // 2 tc
				/obj/item/reagent_containers/syringe/mulligan, // 4 tc
				/obj/item/switchblade, //basically 1 tc as it can be bought from BM kits
				/obj/item/storage/fancy/cigarettes/cigpack_syndicate , // 2 tc this shit heals
				/obj/item/flashlight/emp, // 2 tc
				/obj/item/chameleon, // 7 tc
				/obj/item/implanter/storage, // 6 tc
			)

		if(KIT_STEALTHY)
			return list(
				/obj/item/gun/energy/recharge/ebow, // 10 tc
				/obj/item/pen/sleepy, // 4 tc
				/obj/item/healthanalyzer/rad_laser, // 3 tc
				/obj/item/chameleon, // 7 tc
				/obj/item/soap/syndie, // 1 tc
				/obj/item/clothing/glasses/thermal/syndi, // 4 tc
				/obj/item/flashlight/emp, // 2 tc
				/obj/item/jammer, // 5 tc
			)

		if(KIT_GUN)
			return list(
				/obj/item/gun/ballistic/revolver, // 13 tc
				/obj/item/ammo_box/a357, // 4tc
				/obj/item/ammo_box/a357,
				/obj/item/storage/belt/holster/chameleon, // 1 tc
				/obj/item/card/emag/doorjack, // 3 tc replaced the emag with the doorjack
				/obj/item/grenade/c4, // 1 tc
				/obj/item/clothing/gloves/latex/nitrile, // ~1 tc for whole outfit
				/obj/item/clothing/mask/gas/clown_hat,
				/obj/item/clothing/under/suit/black_really,
				/obj/item/clothing/neck/tie/red/hitman,
			)

		if(KIT_SCREWED)
			var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)

			return list(
				/obj/item/sbeacondrop/bomb, // 11 tc
				/obj/item/grenade/syndieminibomb, // 6 tc
				/obj/item/sbeacondrop/powersink, // 11 tc
				spess_suit, // Above allows me to get the helmet from a variable on the object
				GLOB.syndicate_space_suits_to_helmets[spess_suit], // 4 TC for the space gear
				/obj/item/encryptionkey/syndicate, // 2 tc
			)

		if(KIT_MURDER)
			return list(
				/obj/item/melee/energy/sword/saber, // 8 tc
				/obj/item/clothing/glasses/thermal/syndi, // 4 tc
				/obj/item/card/emag/doorjack, // 3 tc
				/obj/item/clothing/shoes/chameleon/noslip, // 2 tc
				/obj/item/encryptionkey/syndicate, // 2 tc
				/obj/item/grenade/syndieminibomb, // 6 tc
			)

		if(KIT_IMPLANTS)
			return list(
				/obj/item/implanter/freedom, // 5 tc
				/obj/item/implanter/uplink/precharged, // 10 tc is inside this thing
				/obj/item/implanter/emp, // 1 tc
				/obj/item/implanter/explosive, // 2 tc
				/obj/item/implanter/storage, // 8 tc
			)

		if(KIT_HACKER) //L-L--LOOK AT YOU, HACKER
			return list(
				/obj/item/ai_module/syndicate, // 4 tc
				/obj/item/card/emag, // 4 tc
				/obj/item/card/emag/doorjack, // 3 tc
				/obj/item/encryptionkey/binary, // 5 tc
				/obj/item/ai_module/toy_ai, // ~6 tc
				/obj/item/multitool/ai_detect, // 1 tc
				/obj/item/storage/toolbox/syndicate, // 1 tc
				/obj/item/computer_disk/syndicate/camera_app, // 1 tc
				/obj/item/clothing/glasses/thermal/syndi, // 4 tc
				/obj/item/card/id/advanced/chameleon, // 2 tc
			)

		if(KIT_LORD_SINGULOTH) //currently disabled, i might return with another anti-engine kit
			var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)

			. = list(
				/obj/item/sbeacondrop, // 10 tc
				spess_suit, // Above allows me to get the helmet from a variable on the object
				GLOB.syndicate_space_suits_to_helmets[spess_suit], // 4 TC for the space gear
				/obj/item/card/emag, // 4 tc
				/obj/item/storage/toolbox/syndicate, // 1 tc
				/obj/item/card/id/advanced/mining,
				/obj/item/stack/spacecash/c10000, // this is technically 10 tc but not really
			)

			if(prob(70))
				. += /obj/item/toy/spinningtoy //lol
			else
				. += /obj/item/toy/spinningtoy/dark_matter //edgy lol

		if(KIT_SABOTAGE)
			return list(
				/obj/item/storage/backpack/duffelbag/syndie/sabotage, // 5 tc for 3 c4 and 2 x4
				/obj/item/computer_disk/syndicate/camera_app, // 1 tc
				/obj/item/sbeacondrop/powersink, // 11 tc
				/obj/item/computer_disk/virus/detomatix, // 6 tc
				/obj/item/storage/toolbox/syndicate, // 1 tc
				/obj/item/pizzabox/bomb, // 6 tc
				/obj/item/storage/box/syndie_kit/emp, // 2 tc
			)

		if(KIT_SNIPER) //This shit is unique so can't really balance it around tc, also no silencer because getting killed without ANY indicator on what killed you sucks
			return list(
				/obj/item/gun/ballistic/rifle/sniper_rifle, // 12 tc
				/obj/item/ammo_box/magazine/sniper_rounds/penetrator, // 5 tc
				/obj/item/clothing/glasses/thermal/syndi, // 4 tc
				/obj/item/clothing/gloves/latex/nitrile, // ~ 1 tc for outfit
				/obj/item/clothing/mask/gas/clown_hat,
				/obj/item/clothing/under/suit/black_really,
				/obj/item/clothing/neck/tie/red/hitman,
			)

		if(KIT_NUKEOPS_METAGAME)
			return list(
				/obj/item/mod/control/pre_equipped/nuclear/unrestricted, // 8 tc
				/obj/item/gun/ballistic/shotgun/bulldog/unrestricted, // 8 tc
				/obj/item/implanter/explosive, // 2 tc
				/obj/item/ammo_box/magazine/m12g, // 2 tc
				/obj/item/ammo_box/magazine/m12g, // 2 tc
				/obj/item/grenade/c4 , // 1 tc
				/obj/item/grenade/c4 , // 1 tc
				/obj/item/card/emag, // 4 tc
				/obj/item/card/emag/doorjack, // 3 tc
			)

		if(KIT_REVOLUTIONARY)
			return list(
				/obj/item/healthanalyzer/rad_laser, // 3 TC
				/obj/item/assembly/flash/hypnotic, // 7 TC
				/obj/item/storage/pill_bottle/lsd, // ~1 TC
				/obj/item/pen/sleepy, // 4 TC
				/obj/item/gun/ballistic/revolver/nagant, // 13 TC comparable to 357. revolvers
				/obj/item/megaphone,
				/obj/item/bedsheet/rev,
				/obj/item/clothing/suit/armor/vest/russian_coat,
				/obj/item/clothing/head/helmet/rus_ushanka,
				/obj/item/storage/box/syndie_kit/poster_box,
			)

/obj/item/storage/box/syndicate/bundle_b/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	switch (pick_weight(list(
		KIT_JAMES_BOND = 2,
		KIT_NINJA = 1,
		KIT_DARK_LORD = 1,
		KIT_WHITE_WHALE_HOLY_GRAIL = 2,
		KIT_MAD_SCIENTIST = 2,
		KIT_BEES = 1,
		KIT_MR_FREEZE = 2,
		KIT_DEAD_MONEY = 2,
		KIT_TRAITOR_2006 = 1,
		KIT_SAM_FISHER = 1,
		KIT_PROP_HUNT = 1
		)))
		if(KIT_JAMES_BOND)
			return list(
				/obj/item/gun/ballistic/automatic/pistol, // 7 tc
				/obj/item/suppressor, // 3 tc
				/obj/item/ammo_box/magazine/m9mm, // 1 tc
				/obj/item/ammo_box/magazine/m9mm,
				/obj/item/card/id/advanced/chameleon, // 2 tc
				/obj/item/clothing/under/chameleon, // 1 tc
				/obj/item/reagent_containers/hypospray/medipen/stimulants, // 5 tc
				/obj/item/reagent_containers/cup/rag,
				/obj/item/implanter/freedom, // 5 tc
				/obj/item/flashlight/emp, // 2 tc
				/obj/item/grenade/c4/x4, // 1ish tc
				/obj/item/reagent_containers/applicator/pill/cyanide,
				/obj/item/toy/cards/deck/syndicate, // 1 tc, for poker
			)

		if(KIT_NINJA)
			. = list(
				/obj/item/katana, // Unique , hard to tell how much tc this is worth. 8 tc?
				/obj/item/reagent_containers/hypospray/medipen/stimulants, // 5 tc
				/obj/item/storage/belt/chameleon, // worth some fraction of a tc
				/obj/item/chameleon, // 7 tc
				/obj/item/card/id/advanced/chameleon, // 2 tc
				/obj/item/card/emag/doorjack, // 3 tc
				/obj/item/book/granter/action/spell/smoke, // ninja smoke bomb. 1 tc
				/obj/item/clothing/shoes/bhop, // mining item, lets you jump at people, at least 2 tc
			)

			for(var/i in 1 to 6)
				. += /obj/item/throwing_star // 1 tc

		if(KIT_DARK_LORD)
			return list(
				/obj/item/dualsaber/red, // 16 tc
				/obj/item/dnainjector/telemut/darkbundle, // ~ 4 tc for tk
				/obj/item/clothing/suit/hooded/chaplain_hoodie,
				/obj/item/card/id/advanced/chameleon, // 2 tc
				/obj/item/clothing/shoes/chameleon/noslip, //2 tc ,because slipping while being a dark lord sucks
				/obj/item/book/granter/action/spell/summonitem, // ~2 tc
				/obj/item/book/granter/action/spell/lightningbolt, // 4 tc
			)

		if(KIT_WHITE_WHALE_HOLY_GRAIL) //Unique items that don't appear anywhere else
			return list(
				/obj/item/gun/ballistic/rifle/boltaction/harpoon,
				/obj/item/storage/bag/harpoon_quiver,
				/obj/item/clothing/suit/hooded/carp_costume/spaceproof,
				/obj/item/clothing/mask/gas/carp,
				/obj/item/grenade/spawnergrenade/spesscarp,
				/obj/item/toy/plush/carpplushie/dehy_carp, // 1 tc, for use as a personal mount
			)

		if(KIT_MAD_SCIENTIST)
			for(var/_ in 1 to 2)
				new /obj/item/grenade/clusterbuster/random(src) // 10 tc?

			. = list(
				/obj/item/clothing/suit/toggle/labcoat/mad, // 0 tc
				/obj/item/clothing/shoes/jackboots, // 0 tc
				/obj/item/megaphone, // 0 tc
				/obj/item/grenade/chem_grenade/bioterrorfoam, // 5 tc
				/obj/item/assembly/signaler, // 0 tc
				/obj/item/assembly/signaler, // 0 tc
				/obj/item/assembly/signaler, // 0 tc
				/obj/item/assembly/signaler, // 0 tc
				/obj/item/storage/toolbox/syndicate, // 1 tc
				/obj/item/pen/edagger, // 2 tc
				/obj/item/gun/energy/wormhole_projector/core_inserted, // 5 tc easily
			)

			for(var/obj/item/grenade/insert as anything in src)
				insert.moveToNullspace()
				. += insert

		if(KIT_BEES)
			return list(
				/obj/item/paper/fluff/bee_objectives, // 0 tc (motivation)
				/obj/item/clothing/suit/hooded/bee_costume, // 0 tc
				/obj/item/clothing/mask/animal/small/bee, // 0 tc
				/obj/item/storage/belt/fannypack/yellow, // 0 tc
				/obj/item/grenade/spawnergrenade/buzzkill, // these are the random super bees this is definitely all of the tc budget for this one
				/obj/item/grenade/spawnergrenade/buzzkill, // 10 tc per grenade
				/obj/item/reagent_containers/cup/bottle/beesease, // 10 tc?
				/obj/item/melee/beesword, //priceless
			)

		if(KIT_MR_FREEZE)
			return list(
				/obj/item/clothing/glasses/cold,
				/obj/item/clothing/gloves/color/black/security/blu,
				/obj/item/clothing/mask/chameleon,
				/obj/item/clothing/suit/hooded/wintercoat,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/grenade/gluon, // whole belt is 22 and gluon is weight 4 so lets just go with like 7 total
				/obj/item/grenade/gluon,
				/obj/item/grenade/gluon,
				/obj/item/grenade/gluon,
				/obj/item/dnainjector/geladikinesis, // both abilities are probably 3 tc total
				/obj/item/dnainjector/cryokinesis,
				/obj/item/gun/energy/temperature/freeze, // ~6 tc
				/obj/item/gun/energy/laser/thermal/cryo, // ~6 tc
				/obj/item/melee/energy/sword/saber/blue, //see see it
			)

		if(KIT_TRAITOR_2006) //A kit so old, it's probably older than you. //This bundle is filled with the entire uplink contents traitors had access to in 2006, from OpenSS13. Notably the esword was not a choice but existed in code.
			return /obj/item/storage/toolbox/emergency/old/ancientbundle //Items fit neatly into a classic toolbox just to remind you what the theme is.

		if(KIT_DEAD_MONEY)
			. = list(
				/obj/item/storage/box/syndie_kit/signaler,
				/obj/item/mod/control/pre_equipped/responsory/inquisitory/syndie, // basically a snowflake yet better elite modsuit, so like, 8 + 5 tc.
				/obj/item/card/id/advanced/chameleon, // 2 tc
				/obj/item/clothing/mask/chameleon,
				/obj/item/melee/baton/telescopic/contractor_baton, // 7 tc
				/obj/item/jammer, // 5 tc
				/obj/item/pinpointer/crew, //priceless
			)

			for(var/i in 1 to 4)
				. += /obj/item/clothing/neck/collar_bomb // These let you remotely kill people with a signaler, though you have to get them first.

		if(KIT_SAM_FISHER)
			return list(
				/obj/item/clothing/under/syndicate/combat,
				/obj/item/clothing/suit/armor/vest/marine/pmc, //The armor kit is comparable to the infiltrator, 6 TC
				/obj/item/clothing/head/helmet/marine/pmc,
				/obj/item/clothing/mask/gas/sechailer,
				/obj/item/clothing/glasses/night/colorless, // 3~ TC
				/obj/item/clothing/gloves/krav_maga/combatglovesplus, //5TC
				/obj/item/clothing/shoes/jackboots,
				/obj/item/storage/belt/military/assault/fisher, //items in this belt easily costs 18 TC
			)

		if(KIT_PROP_HUNT)
			return list(
				/obj/item/chameleon, // 7 TC
				/obj/item/card/emag/doorjack, // 3 TC
				/obj/item/storage/box/syndie_kit/imp_stealth, //8 TC
				/obj/item/gun/ballistic/automatic/pistol, // 7 TC
				/obj/item/clothing/glasses/thermal, // 4 TC
			)

/obj/item/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "syndiebox"
	illustration = "writing_syndie"
	storage_type = /datum/storage/box/syndie_kit

/obj/item/storage/box/syndie_kit/rebarxbowsyndie
	name = "Boxed Rebar Crossbow"
	desc = "A scoped weapon with low armor penetration, but devastating against flesh. Features instruction manual for making specialty ammo."
	storage_type = /datum/storage/box/syndie_kit/rebarxbowsyndie

/obj/item/storage/box/syndie_kit/rebarxbowsyndie/PopulateContents()
	return list(
		/obj/item/book/granter/crafting_recipe/dusting/rebarxbowsyndie_ammo,
		/obj/item/gun/ballistic/rifle/rebarxbow/syndie,
		/obj/item/storage/bag/rebar_quiver/syndicate,
	)

/obj/item/paper/syndicate_forensics_spoofer
	name = "Forensics Spoofer Guide"
	default_raw_text = {"
		<b>Forensics Spoofer Info:</b><br>
		The spoofer has two modes: <b>SCAN</b> which scans for fingerprints and fibers, and <b>APPLY</b> which applies the currently chosen fingerprint/fiber to your target.<br>
		The spoofer can only store 5 fingerprints and 5 fibers, and may not store or report fibers/prints already stored. Additionally, it taps into the stations network to associate scanned fingerprints with names.<br>
		The spoofer will make the same sounds and sights as a forensics scanner, when <b>silent mode</b> is <b>off</b>.<br>
		"}

/obj/item/storage/box/syndie_kit/forensics_spoofer
	name = "forensics spoofing kit"

/obj/item/storage/box/syndie_kit/forensics_spoofer/PopulateContents()
	return list(
		/obj/item/forensics_spoofer,
		/obj/item/paper/syndicate_forensics_spoofer,
	)

/obj/item/storage/box/syndie_kit/origami_bundle
	name = "origami kit"
	desc = "A box full of a number of rather masterfully engineered paper planes and a manual on \"The Art of Origami\"."

/obj/item/storage/box/syndie_kit/origami_bundle/PopulateContents()
	. = list(/obj/item/book/granter/action/origami)
	for(var/i in 1 to 5)
		. += /obj/item/paper

/obj/item/storage/box/syndie_kit/imp_freedom
	name = "freedom implant box"

/obj/item/storage/box/syndie_kit/imp_freedom/PopulateContents()
	return /obj/item/implanter/freedom

/obj/item/storage/box/syndie_kit/imp_microbomb
	name = "microbomb implant box"

/obj/item/storage/box/syndie_kit/imp_microbomb/PopulateContents()
	return /obj/item/implanter/explosive

/obj/item/storage/box/syndie_kit/imp_macrobomb
	name = "macrobomb implant box"

/obj/item/storage/box/syndie_kit/imp_macrobomb/PopulateContents()
	return /obj/item/implanter/explosive_macro

/obj/item/storage/box/syndie_kit/imp_deniability
	name = "tactical deniability implant box"

/obj/item/storage/box/syndie_kit/imp_deniability/PopulateContents()
	return /obj/item/implanter/tactical_deniability

/obj/item/storage/box/syndie_kit/imp_uplink
	name = "uplink implant box"

/obj/item/storage/box/syndie_kit/imp_uplink/PopulateContents()
	return /obj/item/implanter/uplink

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

/obj/item/storage/box/syndie_kit/bioterror/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/syringe/bioterror

/obj/item/storage/box/syndie_kit/clownpins
	name = "ultra hilarious firing pin box"

/obj/item/storage/box/syndie_kit/clownpins/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/firing_pin/clown/ultra

/obj/item/storage/box/syndie_kit/imp_storage
	name = "storage implant box"

/obj/item/storage/box/syndie_kit/imp_storage/PopulateContents()
	return /obj/item/implanter/storage

/obj/item/storage/box/syndie_kit/imp_stealth
	name = "stealth implant box"

/obj/item/storage/box/syndie_kit/imp_stealth/PopulateContents()
	return /obj/item/implanter/stealth

/obj/item/storage/box/syndie_kit/imp_radio
	name = "syndicate radio implant box"

/obj/item/storage/box/syndie_kit/imp_radio/PopulateContents()
	return /obj/item/implanter/radio/syndicate

/obj/item/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"
	storage_type = /datum/storage/box/syndie_kit/space

/obj/item/storage/box/syndie_kit/space/PopulateContents()
	var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)

	return list(
		spess_suit, // Above allows me to get the helmet from a variable on the object
		GLOB.syndicate_space_suits_to_helmets[spess_suit], // 4 TC for the space gear
	)

/obj/item/storage/box/syndie_kit/emp
	name = "EMP kit"

/obj/item/storage/box/syndie_kit/emp/PopulateContents()
	. = list()

	for(var/i in 1 to 5)
		. += /obj/item/grenade/empgrenade
	. += /obj/item/implanter/emp

/obj/item/storage/box/syndie_kit/smoke
	name = "smoke kit"

/obj/item/storage/box/syndie_kit/smoke/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/grenade/smokebomb

/obj/item/storage/box/syndie_kit/mail_counterfeit
	name = "mail counterfeit kit"
	desc = "A GLA Postal Service branded box. It's emblazoned with the motto: *Nothing stops the mail*."
	storage_type = /datum/storage/box/syndie_kit/mail_counterfeit

/obj/item/storage/box/syndie_kit/mail_counterfeit/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/storage/mail_counterfeit_device

/obj/item/storage/box/syndie_kit/chemical
	name = "chemical kit"
	storage_type = /datum/storage/box/syndie_kit/chemical

/obj/item/storage/box/syndie_kit/chemical/PopulateContents()
	return list(
		/obj/item/reagent_containers/cup/bottle/polonium,
		/obj/item/reagent_containers/cup/bottle/venom,
		/obj/item/reagent_containers/cup/bottle/fentanyl,
		/obj/item/reagent_containers/cup/bottle/formaldehyde,
		/obj/item/reagent_containers/cup/bottle/spewium,
		/obj/item/reagent_containers/cup/bottle/syndol,
		/obj/item/reagent_containers/cup/bottle/cyanide,
		/obj/item/reagent_containers/cup/bottle/histamine,
		/obj/item/reagent_containers/cup/bottle/initropidril,
		/obj/item/reagent_containers/cup/bottle/pancuronium,
		/obj/item/reagent_containers/cup/bottle/sodium_thiopental,
		/obj/item/reagent_containers/cup/bottle/coniine,
		/obj/item/reagent_containers/cup/bottle/curare,
		/obj/item/reagent_containers/cup/bottle/amanitin,
		/obj/item/reagent_containers/syringe,
	)

/obj/item/storage/box/syndie_kit/nuke
	name = "nuke core extraction kit"
	desc = "A box containing the equipment and instructions for extracting the plutonium cores of most Nanotrasen nuclear explosives."

/obj/item/storage/box/syndie_kit/nuke/PopulateContents()
	return list(
		/obj/item/screwdriver/nuke,
		/obj/item/nuke_core_container,
		/obj/item/paper/guides/antag/nuke_instructions,
	)
/obj/item/storage/box/syndie_kit/supermatter
	name = "supermatter sliver extraction kit"
	desc = "A box containing the equipment and instructions for extracting a sliver of supermatter."

/obj/item/storage/box/syndie_kit/supermatter/PopulateContents()
	return list(
		/obj/item/scalpel/supermatter,
		/obj/item/hemostat/supermatter,
		/obj/item/nuke_core_container/supermatter,
		/obj/item/paper/guides/antag/supermatter_sliver,
	)

/obj/item/storage/box/syndie_kit/tuberculosisgrenade
	name = "virus grenade kit"
	storage_type = /datum/storage/box/syndie_kit/tuberculosisgrenade

/obj/item/storage/box/syndie_kit/tuberculosisgrenade/PopulateContents()
	. = list(/obj/item/grenade/chem_grenade/tuberculosis)

	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/hypospray/medipen/tuberculosiscure
	. += /obj/item/reagent_containers/syringe
	. += /obj/item/reagent_containers/cup/bottle/tuberculosiscure

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"
	storage_type = /datum/storage/box/syndie_kit/chaemelon

/obj/item/storage/box/syndie_kit/chameleon/PopulateContents()
	return list(
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/suit/chameleon,
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/head/chameleon,
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/neck/chameleon,
		/obj/item/storage/backpack/chameleon,
		/obj/item/storage/belt/chameleon,
		/obj/item/radio/headset/chameleon,
		/obj/item/stamp/chameleon,
		/obj/item/modular_computer/pda/chameleon,
		/obj/item/gun/energy/laser/chameleon,
		/obj/item/chameleon_scanner,
	)

/obj/item/storage/box/syndie_kit/throwing_weapons
	storage_type = /datum/storage/box/syndie_kit/weapons

//5*(2*4) = 5*8 = 45, 45 damage if you hit one person with all 5 stars.
//Not counting the damage it will do while embedded (2*4 = 8, at 15% chance)
/obj/item/storage/box/syndie_kit/throwing_weapons/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/throwing_star = 5,
		/obj/item/paperplane/syndicate = 2,
		/obj/item/restraints/legcuffs/bola/tactical = 2,
	))

/obj/item/storage/box/syndie_kit/cutouts
	storage_type = /datum/storage/box/syndie_kit/cutouts

/obj/item/storage/box/syndie_kit/cutouts/PopulateContents()
	. = list()

	for(var/i in 1 to 3)
		. += /obj/item/cardboard_cutout/adaptive
	. += /obj/item/toy/crayon/rainbow

/obj/item/storage/box/syndie_kit/romerol/PopulateContents()
	return list(
		/obj/item/reagent_containers/cup/bottle/romerol,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
	)

/obj/item/storage/box/syndie_kit/ez_clean/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/grenade/chem_grenade/ez_clean

/obj/item/storage/box/syndie_kit/mulligan/PopulateContents()
	return list(
		/obj/item/reagent_containers/syringe/mulligan,
		/obj/item/fake_identity_kit
	)

/obj/item/storage/box/hug/reverse_revolver/PopulateContents(datum/storage_config/config)
	config.compute_max_item_weight = TRUE
	config.compute_max_total_weight = TRUE

	return /obj/item/gun/ballistic/revolver/reverse

/obj/item/storage/box/syndie_kit/mimery/PopulateContents()
	return list(
		/obj/item/book/granter/action/spell/mime/mimery_blockade,
		/obj/item/book/granter/action/spell/mime/mimery_guns,
	)

/obj/item/storage/box/syndie_kit/moltobeso/PopulateContents()
	return list(
		/obj/item/reagent_containers/cup/bottle/moltobeso,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
	)

/obj/item/storage/box/syndie_kit/combat_baking/PopulateContents()
	. = list(/obj/item/food/baguette/combat,)

	for(var/i in 1 to 2)
		. += /obj/item/food/croissant/throwing
	. += /obj/item/book/granter/crafting_recipe/combat_baking

/obj/item/storage/box/syndie_kit/centcom_costume
	storage_type = /datum/storage/box/syndie_kit/centcom_costume

/obj/item/storage/box/syndie_kit/centcom_costume/PopulateContents()
	return list(
		/obj/item/clothing/under/rank/centcom/officer,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/clothing/gloves/color/black,
		/obj/item/radio/headset/headset_cent/empty,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/storage/backpack/satchel,
		/obj/item/modular_computer/pda/heads,
		/obj/item/clipboard,
	)

/obj/item/storage/box/syndie_kit/chameleon/broken/PopulateContents()
	return list(
		/obj/item/clothing/under/chameleon/broken,
		/obj/item/clothing/suit/chameleon/broken,
		/obj/item/clothing/gloves/chameleon/broken,
		/obj/item/clothing/shoes/chameleon/noslip/broken,
		/obj/item/clothing/glasses/chameleon/broken,
		/obj/item/clothing/head/chameleon/broken,
		/obj/item/clothing/mask/chameleon/broken,
		/obj/item/clothing/neck/chameleon/broken,
		/obj/item/storage/backpack/chameleon/broken,
		/obj/item/storage/belt/chameleon/broken,
		/obj/item/radio/headset/chameleon/broken,
		/obj/item/stamp/chameleon/broken,
		/obj/item/modular_computer/pda/chameleon/broken,
	)
	// No chameleon laser, they can't randomise for //REASONS//

/obj/item/storage/box/syndie_kit/bee_grenades
	name = "buzzkill grenade box"
	desc = "A sleek, sturdy box with a buzzing noise coming from the inside. Uh oh."

/obj/item/storage/box/syndie_kit/bee_grenades/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/grenade/spawnergrenade/buzzkill

/obj/item/storage/box/syndie_kit/manhack_grenades/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/grenade/spawnergrenade/manhacks

/obj/item/storage/box/syndie_kit/sleepytime/PopulateContents()
	return list(
		/obj/item/clothing/under/syndicate/bloodred/sleepytime,
		/obj/item/reagent_containers/cup/glass/mug/coco,
		/obj/item/toy/plush/carpplushie,
		/obj/item/bedsheet/syndie,
	)

/obj/item/storage/box/syndie_kit/demoman
	storage_type = /datum/storage/box/syndie_kit/demoman

/obj/item/storage/box/syndie_kit/demoman/PopulateContents(datum/storage_config/config)

	. = list(
		/obj/item/gun/grenadelauncher,
		/obj/item/storage/belt/grenade/full,
	)

	if(prob(1))
		. += /obj/item/clothing/head/hats/hos/shako

/obj/item/storage/box/syndie_kit/core_gear
	name = "core equipment box"
	desc = "Contains all the necessary gear for success for any nuclear operative unsure of what is needed for success in the field. Everything here WILL help you."

/obj/item/storage/box/syndie_kit/core_gear/PopulateContents()
	return list(
		/obj/item/implanter/freedom ,
		/obj/item/card/emag/doorjack ,
		/obj/item/reagent_containers/hypospray/medipen/stimulants ,
		/obj/item/grenade/c4 ,
		/obj/item/mod/module/energy_shield,
	)

/// Surplus Ammo Box

/obj/item/storage/box/syndie_kit/sniper_surplus
	name = "surplus .50 BMG magazine box"
	desc = "A shoddy box full of surplus .50 BMG magazines. Not as strong, but good enough to keep lead in the air."

/obj/item/storage/box/syndie_kit/sniper_surplus/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_box/magazine/sniper_rounds/surplus

/obj/item/storage/box/syndie_kit/shotgun_surplus
	name = "\improper Donk Co. 'Donk Spike' flechette 12g Bulldog magazine box"
	desc = "A shoddy box full of Donk Co. 'Donk Spike' flechette 12g. It is debatable whether or not these are actually \
		better or worse than standard flechette. Donk Co. did genuinely believe in this product being the future of military \
		ammunition production. The only reason it didn't see wider adoption was a lack of faith in the product. Do you \
		believe in Donk? Time to put that to the test."

/obj/item/storage/box/syndie_kit/shotgun_surplus/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/ammo_box/magazine/m12g/donk

///Subtype for the sabotage bundle. Contains three C4, two X4 and 6 signalers
/obj/item/storage/backpack/duffelbag/syndie/sabotage/PopulateContents()
	return list(
		/obj/item/grenade/c4,
		/obj/item/grenade/c4,
		/obj/item/grenade/c4,
		/obj/item/grenade/c4/x4,
		/obj/item/grenade/c4/x4,
		/obj/item/storage/box/syndie_kit/signaler,
	)

/obj/item/storage/box/syndie_kit/signaler
	name = "signaler box"
	desc = "Contains everything an agent would need to remotely detonate their bombs."

/obj/item/storage/box/syndie_kit/signaler/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/assembly/signaler

/obj/item/storage/box/syndie_kit/imp_deathrattle
	name = "deathrattle implant box"
	desc = "Contains eight linked deathrattle implants."
	storage_type = /datum/storage/box/syndie_kit/imp_deathrattle

/obj/item/storage/box/syndie_kit/imp_deathrattle/PopulateContents()
	. = list(/obj/item/implanter)

	var/datum/deathrattle_group/group = new

	var/implants = list()
	for(var/j in 1 to 8)
		var/obj/item/implantcase/deathrattle/case = new (null)
		implants += case.imp
		. += case

	for(var/i in implants)
		group.register(i)
	desc += " The implants are registered to the \"[group.name]\" group."

/obj/item/storage/box/stickers/syndie_kit/PopulateContents()
	var/static/list/types = subtypesof(/obj/item/sticker/syndicate)

	. = list()
	for(var/i in 1 to 7)
		. += pick(types)

/obj/item/storage/box/syndie_kit/pinata
	name = "weapons grade pinata kit"
	desc = "Contains a weapons grade pinata and 2 belts for carrying its contents."
	storage_type = /datum/storage/box/syndie_kit/pinata

/obj/item/storage/box/syndie_kit/pinata/PopulateContents()
	return list(
		/obj/item/pinata/syndie,
		/obj/item/storage/belt/grenade,
		/obj/item/storage/belt/military/snack,
	)

/obj/item/storage/box/syndie_kit/induction_kit
	name = "syndicate induction kit"
	desc = "Contains all you need for introducing your newest comrade to the Syndicate and all its worker's benefits."
	storage_type = /datum/storage/box/syndie_kit/induction_kit

/obj/item/storage/box/syndie_kit/induction_kit/PopulateContents(datum/storage_config/config)
	config.compute_max_item_count = TRUE
	config.compute_max_total_weight = TRUE

	var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
	return list(
		// Basic weaponry, so they have something to use.
		/obj/item/gun/ballistic/automatic/pistol/clandestine, // 6 TC, but free for nukies
		/obj/item/ammo_box/magazine/m10mm/hp, // 3 TC, a reward for the teamwork involved
		/obj/item/ammo_box/magazine/m10mm/ap, // 3 TC, a reward for the teamwork involved

		// The necessary equipment to help secure that disky.
		/obj/item/radio/headset/syndicate/alt, // 5 TC / Free for nukies
		/obj/item/modular_computer/pda/nukeops, // ?? TC / Free for nukies
		/obj/item/card/id/advanced/chameleon, // 2 TC / Free for nukies
		spess_suit, // 4 TC for the space gear
		GLOB.syndicate_space_suits_to_helmets[spess_suit],
		/obj/item/tank/jetpack/oxygen/harness, // They kinda need this to fly to the cruiser.

		// Tacticool gear
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/gloves/fingerless,
		/obj/item/book/manual/nuclear, // Very important

		// The most important part of the kit, the implant that gives them the syndicate faction.
		/obj/item/implanter/induction_implant,
	)

	// All in all, 6+3+3+2+5+2+4 = ~25 TC of 'miscellaneous' items.
	// This is a lot of value for 10 TC, but you have to keep in mind that you NEED someone to get this stuff station-side.
	// Pretty much all of it is a bad deal for reinforcements or yourself as they already have similar or good-enough alternatives.

/obj/item/implanter/induction_implant
	name = "implanter (nuclear operative)"
	desc = "A sterile automatic implant injector. You can see a tiny, somehow legible sticker on the side: 'NOT A BRAINWASH DEVICE'"
	imp_type = /obj/item/implant/nuclear_operative

/obj/item/implant/nuclear_operative
	name = "nuclear operative implant"
	desc = "Registers you as a member of a Syndicate nuclear operative team."
	implant_color = "r"

/obj/item/implant/nuclear_operative/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Suspicious Implant<BR> \
		<b>Life:</b> UNKNOWN <BR> \
		<b>Implant Details:</b> <BR> \
		<b>Function:</b> Strange implant that seems to resist any attempts at scanning it."

/obj/item/implant/nuclear_operative/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!. || !ishuman(target) || !(target.mind))
		return FALSE
	var/mob/living/carbon/human/human_target = target

	if(IS_NUKE_OP(human_target)) // this wont proc due to ..() but i guess its good as a just-in-case?
		if(human_target == user)
			to_chat(user, span_userdanger("You're already a nuclear operative, dumbass! The implant disintegrates within you! You feel sick..."))
			human_target.Stun(10 SECONDS)
			human_target.reagents.add_reagent(/datum/reagent/toxin, 10)
			return FALSE
		else
			to_chat(user, span_notice("You finish implanting [human_target], but you don't really notice a difference. Huh."))
			to_chat(human_target, span_userdanger("Nothing seems to really happen, but you start to feel a little ill.."))
			human_target.reagents.add_reagent(/datum/reagent/toxin, 2)
			return FALSE

	/// If all the antag datums are 'fake' or none exist, disallow induction! No self-antagging.
	var/faker
	for(var/datum/antagonist/antag_datum as anything in human_target.mind.antag_datums)
		if((antag_datum.antag_flags & FLAG_FAKE_ANTAG))
			faker = TRUE

	if(faker || isnull(human_target.mind.antag_datums)) // GTFO. Technically not foolproof but making a heartbreaker or a paradox clone a nuke op sounds hilarious
		to_chat(human_target, span_notice("Huh? Nothing happened? But you're starting to feel a little ill..."))
		human_target.reagents.add_reagent(/datum/reagent/toxin, 15)
		return FALSE

	var/datum/antagonist/nukeop/nuke_datum = new()
	nuke_datum.send_to_spawnpoint = FALSE
	nuke_datum.nukeop_outfit = null
	human_target.mind?.add_antag_datum(nuke_datum)
	human_target.faction |= ROLE_SYNDICATE
	to_chat(human_target, span_warning("You are now a nuclear operative. Your main objective, if you were an antagonist and willing, is presumably to assist the nuclear operative team and secure the disk."))
	to_chat(human_target, span_userdanger("This implant does NOT, in any way, brainwash you. If you were a normal crew member beforehand, forcibly implanted or otherwise, you are still one and cannot assist the nuclear operatives."))
	return TRUE

/obj/item/implant/nuclear_operative/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!. || !isliving(target))
		return FALSE
	var/mob/living/living_target = target
	living_target.mind.remove_antag_datum(/datum/antagonist/nukeop)
	living_target.faction -= ROLE_SYNDICATE
	to_chat(target, span_notice("You feel a little less nuclear."))
	to_chat(target, span_userdanger("You're no longer identified as a nuclear operative! You are free to follow any valid goals you wish, even continuing to secure the disk. Just make sure neither any turrets nor operatives kill you on sight."))
	return TRUE

/obj/item/storage/box/syndie_kit/poster_box
	name = "syndicate poster pack"
	desc = "Contains a variety of demotivational posters to ensure minimum productivity for the crew of any Nanotrasen station."

/obj/item/storage/box/syndie_kit/poster_box/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/poster/traitor

/obj/item/storage/box/syndie_kit/cowboy
	name = "western outlaw pack"
	desc = "Contains everything you'll need to be the rootin' tootin' cowboy you always wanted. Either play the Lone Ranger or go in with your posse of outlaws."
	storage_type = /datum/storage/box/syndie_kit/cowboy

/obj/item/storage/box/syndie_kit/cowboy/PopulateContents()
	//Can spawn with snakes which runtime in null space so we do this
	var/obj/item/clothing/shoes/cowboy/black/syndicate/shoes = new(src)
	shoes.moveToNullspace()

	return list(
		shoes,
		/obj/item/clothing/head/cowboy/black/syndicate,
		/obj/item/storage/belt/holster/nukie/cowboy/full,
		/obj/item/clothing/under/costume/dutch/syndicate,
		/obj/item/lighter/skull,
		/obj/item/sbeacondrop/horse,
		/obj/item/food/grown/apple,
	)

/obj/item/storage/box/syndicate/contract_kit
	name = "Contract Kit"
	desc = "Supplied to Syndicate contractors."
	icon_state = "syndiebox"
	illustration = "writing_syndie"
	storage_type = /datum/storage/box/syndicate/contract_kit

/obj/item/storage/box/syndicate/contract_kit/PopulateContents()
	return list(
		/obj/item/modular_computer/pda/syndicate_contract_uplink,
		/obj/item/storage/box/syndicate/contractor_loadout,
		/obj/item/melee/baton/telescopic/contractor_baton,
		// Paper guide is always last.
		/obj/item/paper/contractor_guide,
	)

/obj/item/storage/box/syndicate/contractor_loadout
	name = "Standard Loadout"
	desc = "Supplied to Syndicate contractors, providing their specialised space suit and chameleon uniform."
	icon_state = "syndiebox"
	illustration = "writing_syndie"
	storage_type = /datum/storage/box/syndicate/contractor_loadout

/obj/item/storage/box/syndicate/contractor_loadout/PopulateContents()

	return list(
		/obj/item/mod/control/pre_equipped/infiltrator,
		/obj/item/clothing/head/helmet/space/syndicate/contract,
		/obj/item/clothing/suit/space/syndicate/contract,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/mask/chameleon,
		/obj/item/card/id/advanced/chameleon,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/jammer,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/lighter,
	)

#undef KIT_RECON
#undef KIT_BLOODY_SPAI
#undef KIT_STEALTHY
#undef KIT_SCREWED
#undef KIT_SABOTAGE
#undef KIT_GUN
#undef KIT_MURDER
#undef KIT_IMPLANTS
#undef KIT_HACKER
#undef KIT_SNIPER
#undef KIT_NUKEOPS_METAGAME
#undef KIT_LORD_SINGULOTH
#undef KIT_REVOLUTIONARY

#undef KIT_JAMES_BOND
#undef KIT_NINJA
#undef KIT_DARK_LORD
#undef KIT_WHITE_WHALE_HOLY_GRAIL
#undef KIT_MAD_SCIENTIST
#undef KIT_BEES
#undef KIT_MR_FREEZE
#undef KIT_TRAITOR_2006
#undef KIT_DEAD_MONEY
#undef KIT_SAM_FISHER
#undef KIT_PROP_HUNT
