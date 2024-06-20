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

/obj/item/storage/box/syndicate/bundle_a/PopulateContents()
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
			new /obj/item/clothing/glasses/thermal/xray(src) // ~8 tc?
			new /obj/item/storage/briefcase/launchpad(src) //6 tc
			new /obj/item/binoculars(src) // 2 tc?
			new /obj/item/encryptionkey/syndicate(src) // 2 tc
			new /obj/item/storage/box/syndie_kit/space(src) //4 tc
			new /obj/item/grenade/frag(src) // ~2 tc each?
			new /obj/item/grenade/frag(src)
			new /obj/item/flashlight/emp(src) // 4 tc

		if(KIT_BLOODY_SPAI)
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc
			new /obj/item/clothing/under/chameleon(src) // 2 tc since it's not the full set
			new /obj/item/clothing/mask/chameleon(src) // Goes with above
			new /obj/item/clothing/shoes/chameleon/noslip(src) // 2 tc
			new /obj/item/computer_disk/syndicate/camera_app(src) // 1 tc
			new /obj/item/multitool/ai_detect(src) // 1 tc
			new /obj/item/encryptionkey/syndicate(src) // 2 tc
			new /obj/item/reagent_containers/syringe/mulligan(src) // 4 tc
			new /obj/item/switchblade(src) //basically 1 tc as it can be bought from BM kits
			new /obj/item/storage/fancy/cigarettes/cigpack_syndicate (src) // 2 tc this shit heals
			new /obj/item/flashlight/emp(src) // 2 tc
			new /obj/item/chameleon(src) // 7 tc
			new /obj/item/implanter/storage(src) // 6 tc

		if(KIT_STEALTHY)
			new /obj/item/gun/energy/recharge/ebow(src) // 10 tc
			new /obj/item/pen/sleepy(src) // 4 tc
			new /obj/item/healthanalyzer/rad_laser(src) // 3 tc
			new /obj/item/chameleon(src) // 7 tc
			new /obj/item/soap/syndie(src) // 1 tc
			new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
			new /obj/item/flashlight/emp(src) // 2 tc
			new /obj/item/jammer(src) // 5 tc

		if(KIT_GUN)
			new /obj/item/gun/ballistic/revolver/syndicate(src) // 13 tc
			new /obj/item/ammo_box/a357(src) // 4tc
			new /obj/item/ammo_box/a357(src)
			new /obj/item/storage/belt/holster/chameleon(src) // 1 tc
			new /obj/item/card/emag/doorjack(src) // 3 tc replaced the emag with the doorjack
			new /obj/item/grenade/c4(src) // 1 tc
			new /obj/item/clothing/gloves/latex/nitrile(src) // ~1 tc for whole outfit
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/clothing/under/suit/black_really(src)
			new /obj/item/clothing/neck/tie/red/hitman(src)

		if(KIT_SCREWED)
			new /obj/item/sbeacondrop/bomb(src) // 11 tc
			new /obj/item/grenade/syndieminibomb(src) // 6 tc
			new /obj/item/sbeacondrop/powersink(src) // 11 tc
			var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
			new spess_suit(src) // Above allows me to get the helmet from a variable on the object
			var/obj/item/clothing/head/helmet/space/syndicate/spess_helmet = GLOB.syndicate_space_suits_to_helmets[spess_suit]
			new spess_helmet(src) // 4 TC for the space gear
			new /obj/item/encryptionkey/syndicate(src) // 2 tc

		if(KIT_MURDER)
			new /obj/item/melee/energy/sword/saber(src) // 8 tc
			new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
			new /obj/item/card/emag/doorjack(src) // 3 tc
			new /obj/item/clothing/shoes/chameleon/noslip(src) // 2 tc
			new /obj/item/encryptionkey/syndicate(src) // 2 tc
			new /obj/item/grenade/syndieminibomb(src) // 6 tc

		if(KIT_IMPLANTS)
			new /obj/item/implanter/freedom(src) // 5 tc
			new /obj/item/implanter/uplink/precharged(src) // 10 tc is inside this thing
			new /obj/item/implanter/emp(src) // 1 tc
			new /obj/item/implanter/explosive(src) // 2 tc
			new /obj/item/implanter/storage(src) // 8 tc

		if(KIT_HACKER) //L-L--LOOK AT YOU, HACKER
			new /obj/item/ai_module/syndicate(src) // 4 tc
			new /obj/item/card/emag(src) // 4 tc
			new /obj/item/card/emag/doorjack(src) // 3 tc
			new /obj/item/encryptionkey/binary(src) // 5 tc
			new /obj/item/ai_module/toy_ai(src) // ~6 tc
			new /obj/item/multitool/ai_detect(src) // 1 tc
			new /obj/item/storage/toolbox/syndicate(src) // 1 tc
			new /obj/item/computer_disk/syndicate/camera_app(src) // 1 tc
			new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc

		if(KIT_LORD_SINGULOTH) //currently disabled, i might return with another anti-engine kit
			new /obj/item/sbeacondrop(src) // 10 tc
			var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
			new spess_suit(src) // Above allows me to get the helmet from a variable on the object
			var/obj/item/clothing/head/helmet/space/syndicate/spess_helmet = GLOB.syndicate_space_suits_to_helmets[spess_suit]
			new spess_helmet(src) // 4 TC for the space gear
			new /obj/item/card/emag(src) // 4 tc
			new /obj/item/storage/toolbox/syndicate(src) // 1 tc
			new /obj/item/card/id/advanced/mining(src)
			new /obj/item/stack/spacecash/c10000(src) // this is technically 10 tc but not really
			if(prob(70))
				new /obj/item/toy/spinningtoy(src) //lol
			else
				new /obj/item/toy/spinningtoy/dark_matter(src) //edgy lol

		if(KIT_SABOTAGE)
			new /obj/item/storage/backpack/duffelbag/syndie/sabotage(src) // 5 tc for 3 c4 and 2 x4
			new /obj/item/computer_disk/syndicate/camera_app(src) // 1 tc
			new /obj/item/sbeacondrop/powersink(src) // 11 tc
			new /obj/item/computer_disk/virus/detomatix(src) // 6 tc
			new /obj/item/storage/toolbox/syndicate(src) // 1 tc
			new /obj/item/pizzabox/bomb(src) // 6 tc
			new /obj/item/storage/box/syndie_kit/emp(src) // 2 tc

		if(KIT_SNIPER) //This shit is unique so can't really balance it around tc, also no silencer because getting killed without ANY indicator on what killed you sucks
			new /obj/item/gun/ballistic/rifle/sniper_rifle(src) // 12 tc
			new /obj/item/ammo_box/magazine/sniper_rounds/penetrator(src) // 5 tc
			new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
			new /obj/item/clothing/gloves/latex/nitrile(src) // ~ 1 tc for outfit
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/clothing/under/suit/black_really(src)
			new /obj/item/clothing/neck/tie/red/hitman(src)

		if(KIT_NUKEOPS_METAGAME)
			new /obj/item/mod/control/pre_equipped/nuclear/unrestricted(src) // 8 tc
			new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src) // 8 tc
			new /obj/item/implanter/explosive(src) // 2 tc
			new /obj/item/ammo_box/magazine/m12g(src) // 2 tc
			new /obj/item/ammo_box/magazine/m12g(src) // 2 tc
			new /obj/item/grenade/c4 (src) // 1 tc
			new /obj/item/grenade/c4 (src) // 1 tc
			new /obj/item/card/emag(src) // 4 tc
			new /obj/item/card/emag/doorjack(src) // 3 tc

		if(KIT_REVOLUTIONARY)
			new /obj/item/healthanalyzer/rad_laser(src) // 3 TC
			new /obj/item/assembly/flash/hypnotic(src) // 7 TC
			new /obj/item/storage/pill_bottle/lsd(src) // ~1 TC
			new /obj/item/pen/sleepy(src) // 4 TC
			new /obj/item/gun/ballistic/revolver/nagant(src) // 13 TC comparable to 357. revolvers
			new /obj/item/megaphone(src)
			new /obj/item/bedsheet/rev(src)
			new /obj/item/clothing/suit/armor/vest/russian_coat(src)
			new /obj/item/clothing/head/helmet/rus_ushanka(src)
			new /obj/item/storage/box/syndie_kit/poster_box(src)

/obj/item/storage/box/syndicate/bundle_b/PopulateContents()
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
			new /obj/item/gun/ballistic/automatic/pistol(src) // 7 tc
			new /obj/item/suppressor(src) // 3 tc
			new /obj/item/ammo_box/magazine/m9mm(src) // 1 tc
			new /obj/item/ammo_box/magazine/m9mm(src)
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc
			new /obj/item/clothing/under/chameleon(src) // 1 tc
			new /obj/item/reagent_containers/hypospray/medipen/stimulants(src) // 5 tc
			new /obj/item/reagent_containers/cup/rag(src)
			new /obj/item/implanter/freedom(src) // 5 tc
			new /obj/item/flashlight/emp(src) // 2 tc
			new /obj/item/grenade/c4/x4(src) // 1ish tc
			new /obj/item/reagent_containers/pill/cyanide(src)
			new /obj/item/toy/cards/deck/syndicate(src) // 1 tc, for poker

		if(KIT_NINJA)
			new /obj/item/katana(src) // Unique , hard to tell how much tc this is worth. 8 tc?
			new /obj/item/reagent_containers/hypospray/medipen/stimulants(src) // 5 tc
			for(var/i in 1 to 6)
				new /obj/item/throwing_star(src) // 1 tc
			new /obj/item/storage/belt/chameleon(src) // worth some fraction of a tc
			new /obj/item/chameleon(src) // 7 tc
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc
			new /obj/item/card/emag/doorjack(src) // 3 tc
			new /obj/item/book/granter/action/spell/smoke(src) // ninja smoke bomb. 1 tc
			new /obj/item/clothing/shoes/bhop(src) // mining item, lets you jump at people, at least 2 tc

		if(KIT_DARK_LORD)
			new /obj/item/dualsaber/red(src) // 16 tc
			new /obj/item/dnainjector/telemut/darkbundle(src) // ~ 4 tc for tk
			new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc
			new /obj/item/clothing/shoes/chameleon/noslip(src) //2 tc ,because slipping while being a dark lord sucks
			new /obj/item/book/granter/action/spell/summonitem(src) // ~2 tc
			new /obj/item/book/granter/action/spell/lightningbolt(src) // 4 tc

		if(KIT_WHITE_WHALE_HOLY_GRAIL) //Unique items that don't appear anywhere else
			new /obj/item/gun/ballistic/rifle/boltaction/harpoon(src)
			new /obj/item/storage/bag/harpoon_quiver(src)
			new /obj/item/clothing/suit/hooded/carp_costume/spaceproof(src)
			new /obj/item/clothing/mask/gas/carp(src)
			new /obj/item/grenade/spawnergrenade/spesscarp(src)
			new /obj/item/toy/plush/carpplushie/dehy_carp(src) // 1 tc, for use as a personal mount

		if(KIT_MAD_SCIENTIST)
			new /obj/item/clothing/suit/toggle/labcoat/mad(src) // 0 tc
			new /obj/item/clothing/shoes/jackboots(src) // 0 tc
			new /obj/item/megaphone(src) // 0 tc
			new /obj/item/grenade/clusterbuster/random(src) // 10 tc?
			new /obj/item/grenade/clusterbuster/random(src) // 10 tc?
			new /obj/item/grenade/chem_grenade/bioterrorfoam(src) // 5 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/storage/toolbox/syndicate(src) // 1 tc
			new /obj/item/pen/edagger(src) // 2 tc
			new /obj/item/gun/energy/wormhole_projector/core_inserted(src) // 5 tc easily

		if(KIT_BEES)
			new /obj/item/paper/fluff/bee_objectives(src) // 0 tc (motivation)
			new /obj/item/clothing/suit/hooded/bee_costume(src) // 0 tc
			new /obj/item/clothing/mask/animal/small/bee(src) // 0 tc
			new /obj/item/storage/belt/fannypack/yellow(src) // 0 tc
			new /obj/item/grenade/spawnergrenade/buzzkill(src) // these are the random super bees this is definitely all of the tc budget for this one
			new /obj/item/grenade/spawnergrenade/buzzkill(src) // 10 tc per grenade
			new /obj/item/reagent_containers/cup/bottle/beesease(src) // 10 tc?
			new /obj/item/melee/beesword(src) //priceless

		if(KIT_MR_FREEZE)
			new /obj/item/clothing/glasses/cold(src)
			new /obj/item/clothing/gloves/color/black(src)
			new /obj/item/clothing/mask/chameleon(src)
			new /obj/item/clothing/suit/hooded/wintercoat(src)
			new /obj/item/clothing/shoes/winterboots(src)
			new /obj/item/grenade/gluon(src) // whole belt is 22 and gluon is weight 4 so lets just go with like 7 total
			new /obj/item/grenade/gluon(src)
			new /obj/item/grenade/gluon(src)
			new /obj/item/grenade/gluon(src)
			new /obj/item/dnainjector/geladikinesis(src) // both abilities are probably 3 tc total
			new /obj/item/dnainjector/cryokinesis(src)
			new /obj/item/gun/energy/temperature/freeze(src) // ~6 tc
			new /obj/item/gun/energy/laser/thermal/cryo(src) // ~6 tc
			new /obj/item/melee/energy/sword/saber/blue(src) //see see it fits the theme bc its blue and ice is blue, 8 tc

		if(KIT_TRAITOR_2006) //A kit so old, it's probably older than you. //This bundle is filled with the entire uplink contents traitors had access to in 2006, from OpenSS13. Notably the esword was not a choice but existed in code.
			new /obj/item/storage/toolbox/emergency/old/ancientbundle(src) //Items fit neatly into a classic toolbox just to remind you what the theme is.

		if(KIT_DEAD_MONEY)
			for(var/i in 1 to 4)
				new /obj/item/clothing/neck/collar_bomb(src) // These let you remotely kill people with a signaler, though you have to get them first.
			new /obj/item/storage/box/syndie_kit/signaler(src)
			new /obj/item/mod/control/pre_equipped/responsory/inquisitory/syndie(src) // basically a snowflake yet better elite modsuit, so like, 8 + 5 tc.
			new /obj/item/card/id/advanced/chameleon(src) // 2 tc
			new /obj/item/clothing/mask/chameleon(src)
			new /obj/item/melee/baton/telescopic/contractor_baton(src) // 7 tc
			new /obj/item/jammer(src) // 5 tc
			new /obj/item/pinpointer/crew(src) //priceless

		if(KIT_SAM_FISHER)
			new /obj/item/clothing/under/syndicate/combat(src)
			new /obj/item/clothing/suit/armor/vest/marine/pmc(src) //The armor kit is comparable to the infiltrator, 6 TC
			new /obj/item/clothing/head/helmet/marine/pmc(src)
			new /obj/item/clothing/mask/gas/sechailer(src)
			new /obj/item/clothing/glasses/night(src) // 3~ TC
			new /obj/item/clothing/gloves/krav_maga/combatglovesplus(src) //5TC
			new /obj/item/clothing/shoes/jackboots(src)
			new /obj/item/storage/belt/military/assault/fisher(src) //items in this belt easily costs 18 TC

		if(KIT_PROP_HUNT)
			new /obj/item/chameleon(src) // 7 TC
			new /obj/item/card/emag/doorjack(src) // 3 TC
			new /obj/item/storage/box/syndie_kit/imp_stealth(src) //8 TC
			new /obj/item/gun/ballistic/automatic/pistol(src) // 7 TC
			new /obj/item/clothing/glasses/thermal(src) // 4 TC

/obj/item/storage/toolbox/emergency/old/ancientbundle/ //So the subtype works

/obj/item/storage/toolbox/emergency/old/ancientbundle/PopulateContents()
	new /obj/item/card/emag(src) // 4 tc
	new /obj/item/card/emag/doorjack(src) //emag used to do both. 3 tc
	new /obj/item/pen/sleepy(src) // 4 tc
	new /obj/item/reagent_containers/pill/cyanide(src)
	new /obj/item/chameleon(src) //its not the original cloaking device, but it will do. 8 tc
	new /obj/item/gun/ballistic/revolver(src) // 13 tc old one stays in the old box
	new /obj/item/implanter/freedom(src) // 5 tc
	new /obj/item/stack/telecrystal(src) //The failsafe/self destruct isn't an item we can physically include in the kit, but 1 TC is technically enough to buy the equivalent.

/obj/item/storage/belt/military/assault/fisher

/obj/item/storage/belt/military/assault/fisher/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine/fisher(src) // 11 TC: 7 (pistol) + 3 (suppressor) + lightbreaker (1 TC, black market meme/util item)
	new /obj/item/ammo_box/magazine/m10mm(src) // 1 TC
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/card/emag/doorjack(src) // 3 TC
	new /obj/item/knife/combat(src) //comparable to the e-dagger, 2 TC

/obj/item/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndie_kit/rebarxbowsyndie
	name = "Boxed Rebar Crossbow"
	desc = "A scoped weapon with low armor penetration, but devestating against flesh. Features instruction manual for making specialty ammo."

/obj/item/storage/box/syndie_kit/rebarxbowsyndie/PopulateContents()
	new /obj/item/book/granter/crafting_recipe/dusting/rebarxbowsyndie_ammo(src)
	new /obj/item/gun/ballistic/rifle/rebarxbow/syndie(src)

/obj/item/storage/box/syndie_kit/origami_bundle
	name = "origami kit"
	desc = "A box full of a number of rather masterfully engineered paper planes and a manual on \"The Art of Origami\"."

/obj/item/storage/box/syndie_kit/origami_bundle/PopulateContents()
	new /obj/item/book/granter/action/origami(src)
	for(var/i in 1 to 5)
		new /obj/item/paper(src)

/obj/item/storage/box/syndie_kit/imp_freedom
	name = "freedom implant box"

/obj/item/storage/box/syndie_kit/imp_freedom/PopulateContents()
	new /obj/item/implanter/freedom(src)

/obj/item/storage/box/syndie_kit/imp_microbomb
	name = "microbomb implant box"

/obj/item/storage/box/syndie_kit/imp_microbomb/PopulateContents()
	new /obj/item/implanter/explosive(src)

/obj/item/storage/box/syndie_kit/imp_macrobomb
	name = "macrobomb implant box"

/obj/item/storage/box/syndie_kit/imp_macrobomb/PopulateContents()
	new /obj/item/implanter/explosive_macro(src)

/obj/item/storage/box/syndie_kit/imp_deniability
	name = "tactical deniability implant box"

/obj/item/storage/box/syndie_kit/imp_deniability/PopulateContents()
	new /obj/item/implanter/tactical_deniability(src)

/obj/item/storage/box/syndie_kit/imp_uplink
	name = "uplink implant box"

/obj/item/storage/box/syndie_kit/imp_uplink/PopulateContents()
	new /obj/item/implanter/uplink(src)

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe box"

/obj/item/storage/box/syndie_kit/bioterror/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe/bioterror(src)

/obj/item/storage/box/syndie_kit/clownpins
	name = "ultra hilarious firing pin box"

/obj/item/storage/box/syndie_kit/clownpins/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/firing_pin/clown/ultra(src)

/obj/item/storage/box/syndie_kit/imp_storage
	name = "storage implant box"

/obj/item/storage/box/syndie_kit/imp_storage/PopulateContents()
	new /obj/item/implanter/storage(src)

/obj/item/storage/box/syndie_kit/imp_stealth
	name = "stealth implant box"

/obj/item/storage/box/syndie_kit/imp_stealth/PopulateContents()
	new /obj/item/implanter/stealth(src)

/obj/item/storage/box/syndie_kit/imp_radio
	name = "syndicate radio implant box"

/obj/item/storage/box/syndie_kit/imp_radio/PopulateContents()
	new /obj/item/implanter/radio/syndicate(src)

/obj/item/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"

/obj/item/storage/box/syndie_kit/space/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.set_holdable(list(/obj/item/clothing/suit/space/syndicate, /obj/item/clothing/head/helmet/space/syndicate))

/obj/item/storage/box/syndie_kit/space/PopulateContents()
	var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
	new spess_suit(src) // Above allows me to get the helmet from a variable on the object
	var/obj/item/clothing/head/helmet/space/syndicate/spess_helmet = GLOB.syndicate_space_suits_to_helmets[spess_suit]
	new spess_helmet(src) // 4 TC for the space gear

/obj/item/storage/box/syndie_kit/emp
	name = "EMP kit"

/obj/item/storage/box/syndie_kit/emp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp(src)

/obj/item/storage/box/syndie_kit/smoke
	name = "smoke kit"

/obj/item/storage/box/syndie_kit/smoke/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/smokebomb(src)

/obj/item/storage/box/syndie_kit/mail_counterfeit
	name = "mail counterfeit kit"
	desc = "A box full of mail counterfeit devices. Nothing stops the mail."

/obj/item/storage/box/syndie_kit/mail_counterfeit/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/storage/mail_counterfeit_device(src)

/obj/item/storage/box/syndie_kit/chemical
	name = "chemical kit"

/obj/item/storage/box/syndie_kit/chemical/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 14

/obj/item/storage/box/syndie_kit/chemical/PopulateContents()
	new /obj/item/reagent_containers/cup/bottle/polonium(src)
	new /obj/item/reagent_containers/cup/bottle/venom(src)
	new /obj/item/reagent_containers/cup/bottle/fentanyl(src)
	new /obj/item/reagent_containers/cup/bottle/formaldehyde(src)
	new /obj/item/reagent_containers/cup/bottle/spewium(src)
	new /obj/item/reagent_containers/cup/bottle/cyanide(src)
	new /obj/item/reagent_containers/cup/bottle/histamine(src)
	new /obj/item/reagent_containers/cup/bottle/initropidril(src)
	new /obj/item/reagent_containers/cup/bottle/pancuronium(src)
	new /obj/item/reagent_containers/cup/bottle/sodium_thiopental(src)
	new /obj/item/reagent_containers/cup/bottle/coniine(src)
	new /obj/item/reagent_containers/cup/bottle/curare(src)
	new /obj/item/reagent_containers/cup/bottle/amanitin(src)
	new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syndie_kit/nuke
	name = "nuke core extraction kit"
	desc = "A box containing the equipment and instructions for extracting the plutonium cores of most Nanotrasen nuclear explosives."

/obj/item/storage/box/syndie_kit/nuke/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	name = "supermatter sliver extraction kit"
	desc = "A box containing the equipment and instructions for extracting a sliver of supermatter."

/obj/item/storage/box/syndie_kit/supermatter/PopulateContents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/hemostat/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/tuberculosisgrenade
	name = "virus grenade kit"

/obj/item/storage/box/syndie_kit/tuberculosisgrenade/PopulateContents()
	new /obj/item/grenade/chem_grenade/tuberculosis(src)
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/tuberculosiscure(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/cup/bottle/tuberculosiscure(src)

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/PopulateContents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/storage/belt/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/modular_computer/pda/chameleon(src)
	new /obj/item/gun/energy/laser/chameleon(src)
	new /obj/item/chameleon_scanner(src)

//5*(2*4) = 5*8 = 45, 45 damage if you hit one person with all 5 stars.
//Not counting the damage it will do while embedded (2*4 = 8, at 15% chance)
/obj/item/storage/box/syndie_kit/throwing_weapons/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/throwing_star(src)
	for(var/i in 1 to 2)
		new /obj/item/paperplane/syndicate(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/throwing_weapons/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 9 // 5 + 2 + 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 18 // 5*2 + 2*1 + 3*2
	atom_storage.set_holdable(list(
		/obj/item/restraints/legcuffs/bola/tactical,
		/obj/item/paperplane/syndicate,
		/obj/item/throwing_star,
	))

/obj/item/storage/box/syndie_kit/cutouts/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/rainbow(src)

/obj/item/storage/box/syndie_kit/romerol/PopulateContents()
	new /obj/item/reagent_containers/cup/bottle/romerol(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/dropper(src)

/obj/item/storage/box/syndie_kit/ez_clean/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/grenade/chem_grenade/ez_clean(src)

/obj/item/storage/box/hug/reverse_revolver/PopulateContents()
	new /obj/item/gun/ballistic/revolver/reverse(src)

/obj/item/storage/box/syndie_kit/mimery/PopulateContents()
	new /obj/item/book/granter/action/spell/mime/mimery_blockade(src)
	new /obj/item/book/granter/action/spell/mime/mimery_guns(src)

/obj/item/storage/box/syndie_kit/combat_baking/PopulateContents()
	new /obj/item/food/baguette/combat(src)
	for(var/i in 1 to 2)
		new /obj/item/food/croissant/throwing(src)
	new /obj/item/book/granter/crafting_recipe/combat_baking(src)

/obj/item/storage/box/syndie_kit/centcom_costume/PopulateContents()
	new /obj/item/clothing/under/rank/centcom/officer(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/radio/headset/headset_cent/empty(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/modular_computer/pda/heads(src)
	new /obj/item/clipboard(src)

/obj/item/storage/box/syndie_kit/chameleon/broken/PopulateContents()
	new /obj/item/clothing/under/chameleon/broken(src)
	new /obj/item/clothing/suit/chameleon/broken(src)
	new /obj/item/clothing/gloves/chameleon/broken(src)
	new /obj/item/clothing/shoes/chameleon/noslip/broken(src)
	new /obj/item/clothing/glasses/chameleon/broken(src)
	new /obj/item/clothing/head/chameleon/broken(src)
	new /obj/item/clothing/mask/chameleon/broken(src)
	new /obj/item/clothing/neck/chameleon/broken(src)
	new /obj/item/storage/backpack/chameleon/broken(src)
	new /obj/item/storage/belt/chameleon/broken(src)
	new /obj/item/radio/headset/chameleon/broken(src)
	new /obj/item/stamp/chameleon/broken(src)
	new /obj/item/modular_computer/pda/chameleon/broken(src)
	// No chameleon laser, they can't randomise for //REASONS//

/obj/item/storage/box/syndie_kit/bee_grenades
	name = "buzzkill grenade box"
	desc = "A sleek, sturdy box with a buzzing noise coming from the inside. Uh oh."

/obj/item/storage/box/syndie_kit/bee_grenades/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/spawnergrenade/buzzkill(src)

/obj/item/storage/box/syndie_kit/manhack_grenades/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/spawnergrenade/manhacks(src)

/obj/item/storage/box/syndie_kit/sleepytime/PopulateContents()
	new /obj/item/clothing/under/syndicate/bloodred/sleepytime(src)
	new /obj/item/reagent_containers/cup/glass/mug/coco(src)
	new /obj/item/toy/plush/carpplushie(src)
	new /obj/item/bedsheet/syndie(src)

/obj/item/storage/box/syndie_kit/demoman/PopulateContents()
	new /obj/item/gun/grenadelauncher(src)
	new /obj/item/storage/belt/grenade/full(src)
	if(prob(1))
		new /obj/item/clothing/head/hats/hos/shako(src)

/obj/item/storage/box/syndie_kit/core_gear
	name = "core equipment box"
	desc = "Contains all the necessary gear for success for any nuclear operative unsure of what is needed for success in the field. Everything here WILL help you."

/obj/item/storage/box/syndie_kit/core_gear/PopulateContents()
	new /obj/item/implanter/freedom (src)
	new /obj/item/card/emag/doorjack (src)
	new /obj/item/reagent_containers/hypospray/medipen/stimulants (src)
	new /obj/item/grenade/c4 (src)
	new /obj/item/mod/module/energy_shield(src)

/// Surplus Ammo Box

/obj/item/storage/box/syndie_kit/sniper_surplus
	name = "surplus .50 BMG magazine box"
	desc = "A shoddy box full of surplus .50 BMG magazines. Not as strong, but good enough to keep lead in the air."

/obj/item/storage/box/syndie_kit/sniper_surplus/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_box/magazine/sniper_rounds/surplus(src)

///Subtype for the sabotage bundle. Contains three C4, two X4 and 6 signalers
/obj/item/storage/backpack/duffelbag/syndie/sabotage

/obj/item/storage/backpack/duffelbag/syndie/sabotage/PopulateContents()
	new /obj/item/grenade/c4(src)
	new /obj/item/grenade/c4(src)
	new /obj/item/grenade/c4(src)
	new /obj/item/grenade/c4/x4(src)
	new /obj/item/grenade/c4/x4(src)
	new /obj/item/storage/box/syndie_kit/signaler(src)

/obj/item/storage/box/syndie_kit/signaler
	name = "signaler box"
	desc = "Contains everything an agent would need to remotely detonate their bombs."

/obj/item/storage/box/syndie_kit/signaler/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/assembly/signaler(src)

/obj/item/storage/box/syndie_kit/imp_deathrattle
	name = "deathrattle implant box"
	desc = "Contains eight linked deathrattle implants."

/obj/item/storage/box/syndie_kit/imp_deathrattle/PopulateContents()
	new /obj/item/implanter(src)

	var/datum/deathrattle_group/group = new

	var/implants = list()
	for(var/j in 1 to 8)
		var/obj/item/implantcase/deathrattle/case = new (src)
		implants += case.imp

	for(var/i in implants)
		group.register(i)
	desc += " The implants are registered to the \"[group.name]\" group."

/obj/item/storage/box/syndie_kit/stickers
	name = "sticker kit"

/obj/item/storage/box/syndie_kit/stickers/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 8

/obj/item/storage/box/syndie_kit/stickers/PopulateContents()
	var/list/types = subtypesof(/obj/item/sticker/syndicate)

	for(var/i in 1 to atom_storage.max_slots)
		var/type = pick(types)
		new type(src)

/obj/item/storage/box/syndie_kit/pinata
	name = "weapons grade pinata kit"
	desc = "Contains a weapons grade pinata and 2 belts for carrying its contents."

/obj/item/storage/box/syndie_kit/pinata/PopulateContents()
	new /obj/item/pinata/syndie(src)
	new /obj/item/storage/belt/grenade(src)
	new /obj/item/storage/belt/military/snack(src)

/obj/item/storage/box/syndie_kit/induction_kit
	name = "syndicate induction kit"
	desc = "Contains all you need for introducing your newest comrade to the Syndicate and all its worker's benefits."

/obj/item/storage/box/syndie_kit/induction_kit/PopulateContents()
	// Basic weaponry, so they have something to use.
	new /obj/item/gun/ballistic/automatic/pistol/clandestine(src) // 6 TC, but free for nukies
	new /obj/item/ammo_box/magazine/m10mm/hp(src) // 3 TC, a reward for the teamwork involved
	new /obj/item/ammo_box/magazine/m10mm/ap(src) // 3 TC, a reward for the teamwork involved
	new /obj/item/pen/edagger(src) // 2 TC
	// The necessary equipment to help secure that disky.
	new /obj/item/radio/headset/syndicate/alt(src) // 5 TC / Free for nukies
	new /obj/item/modular_computer/pda/nukeops(src) // ?? TC / Free for nukies
	new /obj/item/card/id/advanced/chameleon(src) // 2 TC / Free for nukies
	var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
	new spess_suit(src) // Above allows me to get the helmet from a variable on the object
	var/obj/item/clothing/head/helmet/space/syndicate/spess_helmet = GLOB.syndicate_space_suits_to_helmets[spess_suit]
	new spess_helmet(src) // 4 TC for the space gear
	new /obj/item/tank/jetpack/oxygen/harness(src) // They kinda need this to fly to the cruiser.
	// Tacticool gear
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/book/manual/nuclear(src) // Very important
	// The most important part of the kit, the implant that gives them the syndicate faction.
	new /obj/item/implanter/induction_implant(src)
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

	/// Number of posters this box contains when spawning.
	var/poster_count = 3

/obj/item/storage/box/syndie_kit/poster_box/PopulateContents()
	for(var/i in 1 to poster_count)
		new /obj/item/poster/traitor(src)

/obj/item/storage/box/syndie_kit/cowboy
	name = "western outlaw pack"
	desc = "Contains everything you'll need to be the rootin' tootin' cowboy you always wanted. Either play the Lone Ranger or go in with your posse of outlaws."

/obj/item/storage/box/syndie_kit/cowboy/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/shoes/cowboy/black/syndicate= 1,
		/obj/item/clothing/head/cowboy/black/syndicate = 1,
		/obj/item/storage/belt/holster/nukie/cowboy/full = 1,
		/obj/item/clothing/under/costume/dutch/syndicate = 1,
		/obj/item/lighter/skull = 1,
		/obj/item/sbeacondrop/horse = 1,
		/obj/item/food/grown/apple = 1,
	), src)

/obj/item/storage/box/syndicate/contract_kit
	name = "Contract Kit"
	desc = "Supplied to Syndicate contractors."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndicate/contract_kit/PopulateContents()
	new /obj/item/modular_computer/pda/syndicate_contract_uplink(src)
	new /obj/item/storage/box/syndicate/contractor_loadout(src)
	new /obj/item/melee/baton/telescopic/contractor_baton(src)
	// Paper guide is always last.
	new /obj/item/paper/contractor_guide(src)

/obj/item/storage/box/syndicate/contractor_loadout
	name = "Standard Loadout"
	desc = "Supplied to Syndicate contractors, providing their specialised space suit and chameleon uniform."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndicate/contractor_loadout/PopulateContents()
	new /obj/item/mod/control/pre_equipped/infiltrator(src)
	new /obj/item/clothing/head/helmet/space/syndicate/contract(src)
	new /obj/item/clothing/suit/space/syndicate/contract(src)
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/card/id/advanced/chameleon(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)
	new /obj/item/storage/toolbox/syndicate(src)
	new /obj/item/jammer(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter(src)

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
