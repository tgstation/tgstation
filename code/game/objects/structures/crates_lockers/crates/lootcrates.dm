/obj/structure/closet/crate/loot
	desc = "A loot crate."
	name = "loot crate"
	icon_state = "weaponcrate"
	loot_table_armor = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/simple_animal/hostile/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)
	loot_table_basic = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/simple_animal/hostile/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)
	loot_table_rare = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/simple_animal/hostile/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)
	loot_table_legendary = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/simple_animal/hostile/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)
	loot_table_heal = list(/obj/effect/spawner/lootdrop/garbage_spawner = 30,
					/mob/living/simple_animal/hostile/cockroach = 25,
					/obj/effect/decal/cleanable/garbage = 20,
					/obj/effect/decal/cleanable/vomit/old = 15,
					/obj/effect/spawner/lootdrop/cigbutt = 10)


/obj/structure/closet/crate/loot/PopulateContents
	. = ..()
	var/spawned_item

	//Check for an armour spawn
	if(prob(10))
		spawned_item = pickweight(loot_table_armor)
		new spawned_item

	//Check for a heal spawn
	if(prob(20))
		spawned_item = pickweight(loot_table_heal)
		new spawned_item


///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/basic
	desc = "A basic loot crate."
	name = "basic loot crate"

/obj/structure/closet/crate/loot/basic/PopulateContents
	. = ..()

	var/list/loot_table = loot_table_basic + loot_table_rare + loot_table_legendary
	var/spawned_item

	spawned_item = pickweight(loot_table)
	new spawned_item


///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/rare
	desc = "A rare loot crate."
	name = "rare loot crate"

/obj/structure/closet/crate/loot/rare/PopulateContents
	. = ..()

	var/list/loot_table = loot_table_rare + loot_table_legendary
	var/spawned_item

	spawned_item = pickweight(loot_table)
	new spawned_item

///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/legendary
	desc = "A legendary loot crate."
	name = "legendary loot crate"

/obj/structure/closet/crate/loot/legendary/PopulateContents
	. = ..()

	var/list/loot_table = loot_table_legendary
	var/spawned_item

	spawned_item = pickweight(loot_table)
	new spawned_item

