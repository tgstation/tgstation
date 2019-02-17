/obj/structure/closet/crate/wooden
	name = "wooden crate"
	desc = "Works just as well as a metal one."
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 6
	icon_state = "wooden"

/obj/structure/closet/crate/wooden/toy
	name = "toy box"
	desc = "It has the words \"Clown + Mime\" written underneath of it with marker."

/obj/structure/closet/crate/wooden/toy/PopulateContents()
	. = ..()
	new	/obj/item/megaphone/clown(src)
	new	/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter(src)
	new /obj/item/pneumatic_cannon/pie(src)
	new /obj/item/reagent_containers/food/snacks/pie/cream(src)
	new /obj/item/storage/crayons(src)

/obj/structure/closet/crate/wooden/artifact/PopulateContents()
	. = ..()
	switch (pickweight(list("worldwar" = 3, "tommy" = 2, "gang" = 1, "rushn" = 2, "detective" = 1, "wiz_charge" = 2, "wiz_summon_knock" = 2, "wiz_blind" = 1, "wiz_forcewall_sacredflame" = 2, "wiz_smoke_door" = 2, "wiz_fireball" = 1, "wiz_suit" = 2, "cutlass" = 2, "katana" = 2, "pharaoh" = 2, "roman" = 1, "knight" = 2, "bo" = 2, "hook" = 2, "spiders" = 2, "tiki" = 1)))
		if("worldwar")
			new /obj/item/clothing/suit/armor/vest/old(src)
			new /obj/item/gun/ballistic/rifle/boltaction(src)
			new /obj/item/ammo_box/a762(src)
			new /obj/item/grenade/syndieminibomb/concussion(src)
			new /obj/item/clothing/head/helmet/old(src)

		if("tommy")
			new /obj/item/gun/ballistic/automatic/tommygun/no_mag(src)
			new /obj/item/ammo_box/magazine/tommygunm45/empty(src)
			for(var/i = 0, i < 12, ++i)
				new /obj/item/ammo_casing/c45(src)
			new /obj/item/clothing/head/fedora(src)
			new /obj/item/clothing/under/rank/det(src)

		if("gang")
			new /obj/item/gun/ballistic/automatic/mini_uzi(src)
			new /obj/item/toy/crayon/spraycan(src)
			new /obj/item/clothing/mask/bandana/black(src)

		if("rushn")
			new /obj/item/gun/ballistic/automatic/pistol/APS(src)
			new /obj/item/switchblade(src)
			new /obj/item/clothing/head/ushanka(src)
			new /obj/item/clothing/under/rank/security/navyblue/russian(src)
			new /obj/item/reagent_containers/food/drinks/bottle/vodka(src)

		if("detective")
			new /obj/item/gun/ballistic/revolver/detective(src)
			new /obj/item/melee/classic_baton(src)
			new /obj/item/restraints/handcuffs(src)
			new /obj/item/clothing/under/lawyer/blacksuit(src)
			new /obj/item/evidencebag/random(src)

		if("wiz_charge")
			new /obj/item/gun/energy/laser/retro/old(src)
			new /obj/item/book/granter/spell/charge(src)

		if("wiz_summon_knock")
			new /obj/item/book/granter/spell/summonitem(src)
			new /obj/item/book/granter/spell/knock(src)

		if("wiz_blind")
			new /obj/item/book/granter/spell/blind(src)
			new /obj/item/clothing/glasses/blindfold(src)

		if("wiz_forcewall_sacredflame")
			new /obj/item/book/granter/spell/forcewall(src)
			new /obj/item/book/granter/spell/sacredflame(src)
			new /obj/item/extinguisher(src)

		if("wiz_smoke_door")
			new /obj/item/book/granter/spell/smoke(src)
			new /obj/item/gun/magic/wand/door(src)

		if("wiz_fireball")
			new /obj/item/gun/magic/wand/fireball(src)

		if ("wiz_suit") 
			new /obj/item/clothing/suit/space/hardsuit/wizard(src)
			new /obj/item/tank/jetpack/oxygen/harness(src)
			new /obj/item/clothing/mask/gas/syndicate(src)
			new /obj/item/gun/magic/wand(src) // Wand of nothing

		if("cutlass")
			new /obj/item/melee/transforming/energy/sword/pirate(src)
			new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
			new /obj/item/twohanded/binoculars(src)
			new /obj/item/coin/gold(src)
			new /obj/item/coin/gold(src)
			new /obj/item/coin/gold(src)

		if("katana")
			new /obj/item/katana(src)
			new /obj/item/throwing_star(src)
			new /obj/item/throwing_star(src)
			new /obj/item/clothing/mask/gas/space_ninja(src)
			new /obj/item/clothing/suit/armor/vest/leather(src)

		if("pharaoh")
			new /obj/item/clothing/head/pharaoh(src)
			new /obj/item/nullrod/egyptian(src)
			new /obj/item/soulstone/anybody/chaplain(src)
			new /obj/item/stack/medical/gauze(src)
			new /obj/item/reagent_containers/glass/bottle/pharaoh(src)
			new /obj/item/reagent_containers/food/condiment/saltshaker(src)

		if("roman")
			new /obj/item/clothing/head/helmet/roman(src)
			new /obj/item/clothing/under/roman(src)
			new /obj/item/clothing/shoes/roman(src)
			new /obj/item/shield/riot/roman(src)
			new /obj/item/twohanded/spear(src)
			new /obj/item/necromantic_stone/one(src)
			new /obj/item/reagent_containers/food/snacks/grown/grapes/green(src)

		if("knight")
			new /obj/item/clothing/head/crown/fancy(src)
			new /obj/item/clothing/head/helmet/knight/red(src)
			new /obj/item/clothing/suit/armor/riot/knight/red(src)
			new /obj/item/claymore(src)

		if("bo")
			new /obj/item/twohanded/bostaff(src)
			new /obj/item/clothing/suit/holidaypriest(src)
			new /obj/item/book/granter/martial/krav_maga(src)
			new /obj/item/storage/book/bible(src)

		if("hook")
			new /obj/item/gun/magic/hook(src)

		if("spiders")
			new /obj/structure/spider/eggcluster(src)
			for(var/i = 0, i < 16, ++i)
				new /obj/structure/spider/spiderling(src)

		if("tiki")
			new /obj/item/clothing/mask/gas/tiki_mask(src)
			new /obj/item/twohanded/fireaxe/boneaxe(src)
			new /obj/item/twohanded/bonespear(src)
			new /obj/item/clothing/head/helmet/skull(src)
			new /obj/item/slimepotion/slime/sentience/nuclear(src)
			new /obj/item/slimepotion/slime/sentience/nuclear(src)


