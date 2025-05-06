// defines are for pussies
/obj/item/storage/box/syndicate

/obj/item/storage/box/syndicate/bundle/recon // i believe defining subtypes like this is required

/obj/item/storage/box/syndicate/bundle/recon/PopulateContents()
	new /obj/item/clothing/glasses/thermal/xray(src) // ~8 tc?
	new /obj/item/storage/briefcase/launchpad(src) //6 tc
	new /obj/item/binoculars(src) // 2 tc?
	new /obj/item/encryptionkey/syndicate(src) // 2 tc
	new /obj/item/storage/box/syndie_kit/space(src) //4 tc
	new /obj/item/grenade/frag(src) // ~2 tc each?
	new /obj/item/grenade/frag(src)
	new /obj/item/flashlight/emp(src) // 4 tc

/obj/item/storage/box/syndicate/bundle/spytf2

/obj/item/storage/box/syndicate/bundle/spytf2/PopulateContents()
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

/obj/item/storage/box/syndicate/bundle/stealthy

/obj/item/storage/box/syndicate/bundle/stealthy/PopulateContents()
	new /obj/item/gun/energy/recharge/ebow(src) // 10 tc
	new /obj/item/pen/sleepy(src) // 4 tc
	new /obj/item/healthanalyzer/rad_laser(src) // 3 tc
	new /obj/item/chameleon(src) // 7 tc
	new /obj/item/soap/syndie(src) // 1 tc
	new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
	new /obj/item/flashlight/emp(src) // 2 tc
	new /obj/item/jammer(src) // 5 tc

/obj/item/storage/box/syndicate/bundle/fucked

/obj/item/storage/box/syndicate/bundle/fucked/PopulateContents()
	new /obj/item/sbeacondrop/bomb(src) // 11 tc
	new /obj/item/grenade/syndieminibomb(src) // 6 tc
	new /obj/item/sbeacondrop/powersink(src) // 11 tc
	var/obj/item/clothing/suit/space/syndicate/spess_suit = pick(GLOB.syndicate_space_suits_to_helmets)
	new spess_suit(src) // Above allows me to get the helmet from a variable on the object
	var/obj/item/clothing/head/helmet/space/syndicate/spess_helmet = GLOB.syndicate_space_suits_to_helmets[spess_suit]
	new spess_helmet(src) // 4 TC for the space gear
	new /obj/item/encryptionkey/syndicate(src) // 2 tc

/obj/item/storage/box/syndicate/bundle/sabotage

/obj/item/storage/box/syndicate/bundle/sabotage/PopulateContents()
	new /obj/item/storage/backpack/duffelbag/syndie/sabotage(src) // 5 tc for 3 c4 and 2 x4
	new /obj/item/computer_disk/syndicate/camera_app(src) // 1 tc
	new /obj/item/sbeacondrop/powersink(src) // 11 tc
	new /obj/item/computer_disk/virus/detomatix(src) // 6 tc
	new /obj/item/storage/toolbox/syndicate(src) // 1 tc
	new /obj/item/pizzabox/bomb(src) // 6 tc
	new /obj/item/storage/box/syndie_kit/emp(src) // 2 tc

/obj/item/storage/box/syndicate/bundle/payday

/obj/item/storage/box/syndicate/bundle/payday/PopulateContents()
	new /obj/item/gun/ballistic/revolver(src) // 13 tc
	new /obj/item/ammo_box/a357(src) // 4tc
	new /obj/item/ammo_box/a357(src)
	new /obj/item/storage/belt/holster/chameleon(src) // 1 tc
	new /obj/item/card/emag/doorjack(src) // 3 tc replaced the emag with the doorjack
	new /obj/item/grenade/c4(src) // 1 tc
	new /obj/item/clothing/gloves/latex/nitrile(src) // ~1 tc for whole outfit
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/clothing/under/suit/black_really(src)
	new /obj/item/clothing/neck/tie/red/hitman(src)

/obj/item/storage/box/syndicate/bundle/killer

/obj/item/storage/box/syndicate/bundle/killer/PopulateContents()
	new /obj/item/melee/energy/sword/saber(src) // 8 tc
	new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
	new /obj/item/card/emag/doorjack(src) // 3 tc
	new /obj/item/clothing/shoes/chameleon/noslip(src) // 2 tc
	new /obj/item/encryptionkey/syndicate(src) // 2 tc
	new /obj/item/grenade/syndieminibomb(src) // 6 tc

/obj/item/storage/box/syndicate/bundle/implants

/obj/item/storage/box/syndicate/bundle/implants/PopulateContents()
	new /obj/item/implanter/freedom(src) // 5 tc
	new /obj/item/implanter/uplink/precharged(src) // 10 tc is inside this thing
	new /obj/item/implanter/emp(src) // 1 tc
	new /obj/item/implanter/explosive(src) // 2 tc
	new /obj/item/implanter/storage(src) // 8 tc

/obj/item/storage/box/syndicate/bundle/hacker

/obj/item/storage/box/syndicate/bundle/hacker/PopulateContents()
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

/obj/item/storage/box/syndicate/bundle/sniper

/obj/item/storage/box/syndicate/bundle/sniper/PopulateContents()
	new /obj/item/gun/ballistic/rifle/sniper_rifle(src) // 12 tc
	new /obj/item/ammo_box/magazine/sniper_rounds/penetrator(src) // 5 tc
	new /obj/item/clothing/glasses/thermal/syndi(src) // 4 tc
	new /obj/item/clothing/gloves/latex/nitrile(src) // ~ 1 tc for outfit
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/clothing/under/suit/black_really(src)
	new /obj/item/clothing/neck/tie/red/hitman(src)

/obj/item/storage/box/syndicate/bundle/ops

/obj/item/storage/box/syndicate/bundle/ops/PopulateContents()
	new /obj/item/mod/control/pre_equipped/nuclear/unrestricted(src) // 8 tc
	new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src) // 8 tc
	new /obj/item/implanter/explosive(src) // 2 tc
	new /obj/item/ammo_box/magazine/m12g(src) // 2 tc
	new /obj/item/ammo_box/magazine/m12g(src) // 2 tc
	new /obj/item/grenade/c4 (src) // 1 tc
	new /obj/item/grenade/c4 (src) // 1 tc
	new /obj/item/card/emag(src) // 4 tc
	new /obj/item/card/emag/doorjack(src) // 3 tc

/obj/item/storage/box/syndicate/bundle/rev

/obj/item/storage/box/syndicate/bundle/rev/PopulateContents()
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

/obj/item/storage/box/syndicate/bundle/bond

/obj/item/storage/box/syndicate/bundle/bond/PopulateContents()
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
	new /obj/item/reagent_containers/applicator/pill/cyanide(src)
	new /obj/item/toy/cards/deck/syndicate(src) // 1 tc, for poker

/obj/item/storage/box/syndicate/bundle/ninja

/obj/item/storage/box/syndicate/bundle/ninja/PopulateContents()
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

/obj/item/storage/box/syndicate/bundle/sith

/obj/item/storage/box/syndicate/bundle/sith/PopulateContents()
	new /obj/item/dualsaber/red(src) // 16 tc
	new /obj/item/dnainjector/telemut/darkbundle(src) // ~ 4 tc for tk
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/card/id/advanced/chameleon(src) // 2 tc
	new /obj/item/clothing/shoes/chameleon/noslip(src) //2 tc ,because slipping while being a dark lord sucks
	new /obj/item/book/granter/action/spell/summonitem(src) // ~2 tc
	new /obj/item/book/granter/action/spell/lightningbolt(src) // 4 tc

/obj/item/storage/box/syndicate/bundle/ahab

/obj/item/storage/box/syndicate/bundle/ahab/PopulateContents()
	new /obj/item/gun/ballistic/rifle/boltaction/harpoon(src)
	new /obj/item/storage/bag/harpoon_quiver(src)
	new /obj/item/clothing/suit/hooded/carp_costume/spaceproof(src)
	new /obj/item/clothing/mask/gas/carp(src)
	new /obj/item/grenade/spawnergrenade/spesscarp(src)
	new /obj/item/toy/plush/carpplushie/dehy_carp(src) // 1 tc, for use as a personal mount

/obj/item/storage/box/syndicate/bundle/scientist

/obj/item/storage/box/syndicate/bundle/scientist/PopulateContents()
	new /obj/item/clothing/suit/toggle/labcoat/mad(src) // 0 tc
	new /obj/item/clothing/shoes/jackboots(src) // 0 tc
	new /obj/item/megaphone(src) // 0 tc
	new /obj/item/grenade/clusterbuster/random(src) // 10 tc?
	new /obj/item/grenade/clusterbuster/random(src) // 10 tc?
	new /obj/item/grenade/chem_grenade/bioterrorfoam(src) // 5 tc
	for(var/i in 1 to 5)
		new /obj/item/assembly/signaler(src) // 0 tc
	new /obj/item/storage/toolbox/syndicate(src) // 1 tc
	new /obj/item/pen/edagger(src) // 2 tc
	new /obj/item/gun/energy/wormhole_projector/core_inserted(src) // 5 tc easily

/obj/item/storage/box/syndicate/bundle/bees

/obj/item/storage/box/syndicate/bundle/bees/PopulateContents()
	new /obj/item/paper/fluff/bee_objectives(src) // 0 tc (motivation)
	new /obj/item/clothing/suit/hooded/bee_costume(src) // 0 tc
	new /obj/item/clothing/mask/animal/small/bee(src) // 0 tc
	new /obj/item/storage/belt/fannypack/yellow(src) // 0 tc
	new /obj/item/grenade/spawnergrenade/buzzkill(src) // these are the random super bees this is definitely all of the tc budget for this one
	new /obj/item/grenade/spawnergrenade/buzzkill(src) // 10 tc per grenade
	new /obj/item/reagent_containers/cup/bottle/beesease(src) // 10 tc?
	new /obj/item/melee/beesword(src) //priceless

/obj/item/storage/box/syndicate/bundle/freeze

/obj/item/storage/box/syndicate/bundle/freeze/PopulateContents()
	new /obj/item/clothing/glasses/cold(src)
	new /obj/item/clothing/gloves/color/black/security/blu(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/suit/hooded/wintercoat(src)
	new /obj/item/clothing/shoes/winterboots(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/gluon(src) // whole belt is 22 and gluon is weight 4 so lets just go with like 7 total
	new /obj/item/dnainjector/geladikinesis(src) // both abilities are probably 3 tc total
	new /obj/item/dnainjector/cryokinesis(src)
	new /obj/item/gun/energy/temperature/freeze(src) // ~6 tc
	new /obj/item/gun/energy/laser/thermal/cryo(src) // ~6 tc
	new /obj/item/melee/energy/sword/saber/blue(src) //see see it fits the theme bc its blue and ice is blue, 8 tc

/obj/item/storage/box/syndicate/bundle/deadmoney

/obj/item/storage/box/syndicate/bundle/deadmoney/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/clothing/neck/collar_bomb(src) // These let you remotely kill people with a signaler, though you have to get them first.
	new /obj/item/storage/box/syndie_kit/signaler(src)
	new /obj/item/mod/control/pre_equipped/responsory/inquisitory/syndie(src) // basically a snowflake yet better elite modsuit, so like, 8 + 5 tc.
	new /obj/item/card/id/advanced/chameleon(src) // 2 tc
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/melee/baton/telescopic/contractor_baton(src) // 7 tc
	new /obj/item/jammer(src) // 5 tc
	new /obj/item/pinpointer/crew(src) //priceless

/obj/item/storage/box/syndicate/bundle/samfisher

/obj/item/storage/box/syndicate/bundle/samfisher/PopulateContents()
	new /obj/item/clothing/under/syndicate/combat(src)
	new /obj/item/clothing/suit/armor/vest/marine/pmc(src) //The armor kit is comparable to the infiltrator, 6 TC
	new /obj/item/clothing/head/helmet/marine/pmc(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/night/colorless(src) // 3~ TC
	new /obj/item/clothing/gloves/krav_maga/combatglovesplus(src) //5TC
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/storage/belt/military/assault/fisher(src) //items in this belt easily costs 18 TC

/obj/item/storage/box/syndicate/bundle/prophunt

/obj/item/storage/box/syndicate/bundle/prophunt/PopulateContents()
	new /obj/item/chameleon(src) // 7 TC
	new /obj/item/card/emag/doorjack(src) // 3 TC
	new /obj/item/storage/box/syndie_kit/imp_stealth(src) //8 TC
	new /obj/item/gun/ballistic/automatic/pistol(src) // 7 TC
	new /obj/item/clothing/glasses/thermal(src) // 4 TC

/obj/item/storage/belt/military/assault/fisher

/obj/item/storage/belt/military/assault/fisher/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/clandestine/fisher(src) // 11 TC: 7 (pistol) + 3 (suppressor) + lightbreaker (1 TC, black market meme/util item)
	new /obj/item/ammo_box/magazine/m10mm(src) // 1 TC
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/card/emag/doorjack(src) // 3 TC
	new /obj/item/knife/combat(src) //comparable to the e-dagger, 2 TC
