/obj/structure/spawner/cave
	name = "cave"
	desc = "You spot something glimmering from within. Maybe you can reach in and try to grab it?"
	icon = 'voidcrew/icons/obj/animal_spawner.dmi'
	icon_state = "cave_den"
	mob_types = list(/mob/living/simple_animal/hostile/bear/cave)
	max_mobs = 2
	max_integrity = 650
	spawn_time = 300
	faction = list(FACTION_WASTELAND)
	var/uses = 6
	var/bite_chance = 15
	var/success_chance = 80
	var/caveloot = list(
		/obj/item/stack/spacecash/c1000 = 10,
		/obj/item/stack/spacecash/c10000 = 1,
		/obj/item/research_notes/loot/big = 10,
		/obj/item/research_notes/loot/genius = 1,
		/obj/item/stack/ore/diamond = 10,
		/obj/item/stack/telecrystal/five = 1,
		/obj/item/gun/ballistic/bow = 10,
		///obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn = 10,
		///obj/item/gun/ballistic/automatic/zip_pistol = 10,
		///obj/item/gun/ballistic/rifle/boltaction/polymer = 9,
		///obj/item/gun/ballistic/shotgun/winchester = 5,
		/obj/item/gun/ballistic/revolver/nagant = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 2,
		///obj/item/gun/ballistic/automatic/aks74u = 1,
		///obj/item/gun/ballistic/shotgun/doublebarrel/hook = 1,
		/obj/item/pickaxe/diamond = 10,
		/obj/item/kinetic_crusher = 6,
		/obj/item/gun/energy/recharge/kinetic_accelerator = 5,
		/obj/item/binoculars = 10,
		/obj/item/grenade/frag/mega = 6,
		///obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 10,
		///obj/item/reagent_containers/food/snacks/breadslice/moldy = 10,
		/obj/item/instrument/guitar = 10,
		///obj/item/storage/fancy/cigarettes/derringer/gold = 3,
		/obj/item/spear/explosive = 10,
		///obj/item/ammo_casing/caseless/arrow/wood = 10,
		///obj/item/ammo_casing/caseless/arrow/bone = 6,
		/obj/item/survivalcapsule = 7,
		/obj/item/survivalcapsule/luxuryelite = 2,
		/obj/item/storage/box/stockparts/basic = 10,
		/obj/item/storage/box/stockparts/deluxe = 3,
		/obj/item/stock_parts/cell/high = 5,
		///obj/item/strange_crystal = 10,
		/obj/item/clothing/mask/cigarette/rollie/mindbreaker = 10,
		/obj/item/wrench/abductor = 2,
		/obj/item/clothing/glasses/meson = 10,
		/obj/item/clothing/suit/utility/radiation = 10,
		/obj/item/clothing/head/utility/radiation = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5,
		/obj/item/reagent_containers/hypospray/medipen/stimpack = 1,
		/obj/item/stack/medical/bruise_pack = 10,
		/obj/item/stack/medical/ointment = 10,
		/obj/item/storage/medkit/regular = 3,
		/obj/item/storage/bottles/sandblast = 5,
		/obj/item/reagent_containers/cup/bottle/romerol = 1,
		//obj/item/implanter/adrenalin = 3,
		/obj/item/implanter/stealth = 1,
		/obj/item/melee/greykingsword = 2
	)

/obj/structure/spawner/cave/Initialize()
	. = ..()
	uses = rand(1,uses)

/obj/structure/spawner/cave/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	if(uses == 0)
		to_chat(user, "<span class='warning'>There's nothing left to loot!</span>")
		return
	obj_flags |= IN_USE
	to_chat(user, "<span class='warning'>You start searching the [name] for anything useful...</span>")
	if(do_after(user, 40, target = src))
		if(prob(bite_chance))
			user.adjustBruteLoss(15)
			playsound(user.loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
			to_chat(user, "<span class='alert'>OW! Something bit you!</span>")
		else
			if(prob(85))
				to_chat(user, "<span class='alert'>You found something!</span>")
				var/picked_loot = pickweight(caveloot)
				new picked_loot(loc)
				uses -= 1
				if (uses == 0)
					to_chat(user, "<span class='warning'>You've emptied out the [name]!</span>")
					qdel(spawner_type)
			else
				to_chat(user, "<span class='warning'>You didn't find anything, maybe try looking again?")
	else
		to_chat(user, "<span class='warning'><b>Your search was interrupted!</b></span>")
	obj_flags &= ~IN_USE

/obj/structure/spawner/cave/beach
	name = "oak barrel"
	desc = "A musty barrel. Reach in and unlock its mold-covered mysteries!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	mob_types = list(/mob/living/simple_animal/hostile/pirate/melee/beach, /mob/living/simple_animal/hostile/pirate/ranged/beach)
	max_mobs = 2
	max_integrity = 250
	bite_chance = 0
	faction = list(FACTION_BEACH)
	caveloot = list(
		/obj/item/storage/bag/money/vault = 10,
		/obj/item/research_notes/loot/big = 8,
		/obj/item/research_notes/loot/genius = 4,
		/obj/item/grenade/clusterbuster/slime = 1,
		/obj/item/grenade/chem_grenade/teargas/moustache = 4,
		/obj/item/slimecross/burning/metal = 10,
		/obj/item/slimecross/burning/gold = 10,
		/obj/item/slimecross/burning/oil = 10,
		/obj/item/slimecross/burning/rainbow = 10,
		/obj/item/slimecross/regenerative/adamantine = 10,
		/obj/item/slimecross/regenerative/rainbow = 10,
		/obj/item/slimecross/stabilized/yellow = 10,
		/obj/item/slimecross/stabilized/purple = 10,
		/obj/item/slimecross/charged/darkblue = 10,
		/obj/item/slimecross/charged/pyrite = 10,
		/obj/item/slimecross/charged/red = 10,
		/obj/item/slimecross/chilling/yellow = 10,
		/obj/item/slimecross/chilling/gold = 10,
		/obj/item/slimecross/chilling/adamantine = 10,
		/obj/item/instrument/banjo = 10,
		/obj/item/gun/ballistic/automatic/mini_uzi = 10,
		/obj/item/gun/ballistic/automatic/pistol/deagle/gold = 10,
		/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted = 10,
		/obj/item/melee/energy/sword/pirate = 5,
		///obj/item/melee/transforming/energy/ctf/solgov = 2,

	)

