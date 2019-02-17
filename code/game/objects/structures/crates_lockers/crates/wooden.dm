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
	switch (pickweight(list("worldwar" = 3, "tommy" = 2, "gang" = 1, "rushn" = 2, "detective" = 1, "wiz_charge" = 2, "wiz_summon_forcewall" = 2, "wiz_blind" = 1, "wiz_sacredflame" = 1, "wiz_barnyard" = 1, "wiz_knock_smoke" = 1, "wiz_door" = 2, "wiz_fireball" = 1, "wiz_suit" = 2, "cutlass" = 2, "katana" = 1, "pharaoh" = 2, "knight" = 1, "bo" = 2, "hook" = 1, "spiders" = 2, "tiki" = 1)))
		if("worldwar")
			new /obj/item/clothing/suit/armor/vest/old(src)
			new /obj/item/gun/ballistic/rifle/boltaction(src)
			new /obj/item/grenade/syndieminibomb/concussion(src)
			new /obj/item/clothing/head/helmet/old(src)

		if("tommy")
			new /obj/item/gun/ballistic/automatic/tommygun/no_mag(src)
			new /obj/item/ammo_box/magazine/tommygunm45/empty(src)
			for(var/i = 0, i < 4, ++i)
				new /obj/item/ammo_casing/c45(src)
			new /obj/item/clothing/head/fedora(src)

		if("gang")
			new /obj/item/gun/ballistic/automatic/mini_uzi(src)

		if("rushn")
			new /obj/item/gun/ballistic/automatic/pistol/APS(src)
			new /obj/item/switchblade(src)
			new /obj/item/clothing/head/ushanka(src)

		if("detective")
			new /obj/item/gun/ballistic/revolver/detective(src)
			new /obj/item/melee/classic_baton(src)
			new /obj/item/restraints/handcuffs(src)

		if("wiz_charge")
			new /obj/item/gun/energy/laser/retro/old(src)
			new /obj/item/book/granter/spell/charge(src)

		if("wiz_summon_forcewall")
			new /obj/item/book/granter/spell/summonitem(src)
			new /obj/item/book/granter/spell/forcewall(src)

		if("wiz_blind")
			new /obj/item/book/granter/spell/blind(src)

		if("wiz_barnyard")
			new /obj/item/book/granter/spell/barnyard(src)
			new /obj/item/clothing/mask/horsehead(src)

		if("wiz_sacredflame")
			new /obj/item/book/granter/spell/sacredflame(src)
			new /obj/item/extinguisher(src)

		if("wiz_knock_smoke")
			new /obj/item/book/granter/spell/knock(src)
			new /obj/item/book/granter/spell/smoke(src)

		if("wiz_door")
			new /obj/item/gun/magic/wand/door(src)

		if("wiz_fireball")
			new /obj/item/gun/magic/wand/fireball(src)

		if ("wiz_suit") 
			new /obj/item/clothing/suit/space/hardsuit/wizard(src)
			new /obj/item/tank/jetpack/oxygen(src)
			new /obj/item/clothing/mask/gas/syndicate(src)

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
			new /obj/item/clothing/mask/gas/space_ninja(src)

		if("pharaoh")
			new /obj/item/clothing/head/pharaoh(src)
			new /obj/item/nullrod/egyptian(src)
			new /obj/item/soulstone/anybody/chaplain(src)
			new /obj/structure/constructshell(src)

		if("knight")
			new /obj/item/clothing/head/helmet/knight/red(src)
			new /obj/item/clothing/suit/armor/riot/knight/red(src)
			new /obj/item/shield/riot/roman(src)
			new /obj/item/claymore/weak(src)

		if("bo")
			new /obj/item/twohanded/bostaff(src)
			new /obj/item/clothing/suit/holidaypriest(src)
			new /obj/item/storage/book/bible(src)
			new /obj/item/implanter/krav_maga(src)

		if("hook")
			new /obj/item/gun/magic/hook(src)

		if("spiders")
			new /obj/structure/spider/eggcluster(src)
			for(var/i = 0, i < 12, ++i)
				new /obj/structure/spider/spiderling(src)

		if("tiki")
			new /obj/item/clothing/mask/gas/tiki_mask(src)
			new /obj/item/clothing/head/helmet/skull(src)
			new /obj/item/twohanded/fireaxe/boneaxe(src)
			new /datum/bounty/item/mining/bone_axe(src)
			for(var/i = 0, i < 4, ++i)
				new /obj/item/twohanded/bonespear(src)
			new /obj/item/slimepotion/slime/sentience(src)

