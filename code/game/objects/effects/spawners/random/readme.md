# Random Spawners

## About

Random spawners are an organized tool primarily for mapping to enhance replayability. The spawners can create objects, effects, and structures with different tweakable settings to get the desired outcome. You can make a spawner determine direction, rarity, number of items to spawn, pixel spacing between items, and even spread it over a large tile radius. This lets you control the atmosphere of a location. You could for instance spawn different piles of trash in maint or spawn decoration items for a room to give it more randomized flavor. The choice is yours!

_(note the audience of this README is directed towards mappers who lack knowledge of coding)_

## Variables

The following variables are defined in `code/game/objects/effects/spawners/random/random.dm` that control how a spawner works.

- `loot` - a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
- `loot_type_path` - this combines the subtypes AND type list with the loot list
- `loot_subtype_path` - this combines ONLY the subtypes (excludes the `loot_subtype_path`) with the loot list
- `spawn_loot_count` - how many items will be spawned
- `spawn_loot_double` - if the same item can be spawned twice from the loot list
- `spawn_loot_split` - whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
- `spawn_all_loot` - whether the spawner should spawn all the loot in the list (ignores `spawn_loot_count`)
- `spawn_loot_chance` - the chance for the spawner to create loot (ignores `spawn_loot_count`)
- `spawn_scatter_radius` - determines how big of a range (in tiles) we should scatter things in

These variables are set to the following default values for the base `random.dm` object that all objects inherit from:

```dm
	/// these three loot values are all empty
	var/list/loot
	var/loot_type_path
	var/loot_subtype_path

	var/spawn_loot_count = 1 // by default one item will be selected from the loot list
	var/spawn_loot_double = TRUE // by default duplicate items CAN be spawned from the loot list
	var/spawn_loot_split = FALSE // by default items will NOT spread out on the same tile
	var/spawn_all_loot = FALSE // by default the spawner will only spawn the number of items set in spawn_loot_count
	var/spawn_loot_chance = 100 // by default the spawner has a 100% chance to spawn the item(s)
	var/spawn_scatter_radius = 0 // by default the spawner will spawn the items ONLY on the tile it is on
```

However there are some categories that overwrite these default values so pay attention to the folder or category you group your spawner in. For instance the `obj/effect/spawner/random/techstorage` category overwrites the `spawn_all_loot` and the `spawn_loot_split` variables.

```dm
// Tech storage circuit board spawners
/obj/effect/spawner/random/techstorage
	name = "generic circuit board spawner"
	spawn_loot_split = TRUE
	spawn_all_loot = TRUE
```

This means any spawner you create under the techstorage will also have those variables set to that by default. This can be overridden quite easily just be resetting the variables back to the normal state like so:

```dm
/obj/effect/spawner/random/techstorage/data_disk
	name = "data disk spawner"
	spawn_all_loot = FALSE // now our loot won't all be spawned
	loot = list(
		/obj/item/disk/data = 49,
		/obj/item/disk/nuclear/fake/obvious = 1,
	)
```

## Template

All the random spawners follow the same template format to keep things consistent and unison.

```dm
/obj/effect/spawner/random/INSERT_SPAWNER_GROUP/INSERT_SPAWNER_NAME
	name = "INSERT_SPAWNER_NAME spawner"
	loot = list(
		/obj/item/PATH/INSERT_OBJ_1,
		/obj/item/PATH/INSERT_OBJ_2,
		/obj/item/PATH/INSERT_OBJ_3,
	)
```

All the capitalized code is the parts where you are supposed to swap out with your objects like so:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
	)
```

Find the path to different objects and add them to the list but try to be consistent with the types of the object and the spawner. For example a medical spawner shouldn't have a emag in the loot list. (use an antag spawner for that instead!)

## Probability

Be aware that the `loot` list uses a _weighted chance_ formula to determine probability. So if there are no numbers set in the `loot` list then each object defaults to 1 and has the same probability to be selected. For our above example for the `minor_healing` spawner each medical item has a 1/3 chance to be spawned. But if we rearranged the values to this:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/stack/medical/gauze = 1,
	)
```

Then now `suture` has a 50% chance of being spawned (2/4), `mesh` has a 25% chance of being spawned (1/4), and `gauze` also has a 25% chance of being spawned (1/4). If we add another item into the mix then we get the following:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/syringe = 1,
	)
```

Suture is 40% (2/5), Mesh is 20% (1/5), Gauze is 20% (1/5), and Syringe is 20% (1/5). A weighted list has the advantage of not needing to update every item in the list when adding a new item. If the list was based on a straight percent values, then each new item would require to manually go and edit ALL the items in the list. For big lists that would become very tedious. This is why we use weighted lists to determine probability!

## Style

Here are some simple guidelines that you should stick to when making a new spawner:

### If ALL the items have the same chance, we should not set a weighted value to the item

Do not put `/obj/item/ = 1` unless other items have different spawn chances

Good:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/syringe = 1,
	)
```

Also Good:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/syringe,
	)
```

Bad:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/syringe = 1,
	)
```

### Sort the list from highest probability to lowest

Sort from top to bottom. The rarest items for your spawner should be at the bottom of the list.

Good:

```dm
/obj/effect/spawner/random/contraband/armory
	name = "armory loot spawner"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
		/obj/item/grenade/clusterbuster/teargas = 2,
		/obj/item/grenade/clusterbuster = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle = 1,
		/obj/item/gun/ballistic/revolver/mateba = 1,
	)
```

Bad:

```dm
/obj/effect/spawner/random/contraband/armory
	name = "armory loot spawner"
	loot = list(
		/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/revolver/mateba = 1,
		/obj/item/grenade/clusterbuster/teargas = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle = 1,
		/obj/item/grenade/clusterbuster = 2,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
	)
```

### Always put the `loot` list at the bottom of your spawner

This is just to keep things organized.

Good:

```dm
/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	spawn_loot_double = FALSE
	loot = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)
```

Bad:

```dm
/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	loot = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)
	spawn_loot_double = FALSE
```

### Always put a comma at the last item in the `loot` list

This will make it easier for people to add items to your spawner later without getting frustrating code errors.

Good:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
	)
```

Bad:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze  // if someone adds an item to the list later it will cause an error
	)
```

### Keep the same tab formatting for the `loot` list (unless there is only one item)

Again, this is just good code organization. If there is only one item, then encase that item in `loot = list(item)`

Good:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
	)
```

Also Good:

```dm
/obj/effect/spawner/random/structure/crate_abandoned
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot_site"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)
```

Bad:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
	/obj/item/stack/medical/suture,
	/obj/item/stack/medical/mesh,
	/obj/item/stack/medical/gauze,
	)
```

Also Bad:

```dm
/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,)
```

### Try to keep the total combined weight of your `loot` list to sane values (Aim for 5, 10, 20, 50, or 100)

This makes the math probability easier for people to calculate. (this is recommended, but not always possible)

Good:

```dm
/obj/effect/spawner/random/trash/cigbutt
	name = "cigarette butt spawner"
	loot = list(
		/obj/item/cigbutt = 65,
		/obj/item/cigbutt/roach = 20,
		/obj/item/cigbutt/cigarbutt = 15,
	)
```

Also Good:

```dm
/obj/effect/spawner/random/trash/botanical_waste
	name = "botanical waste spawner"
	loot = list(
		/obj/item/grown/bananapeel = 6,
		/obj/item/grown/corncob = 3,
		/obj/item/food/grown/bungopit = 1,
	)
```

Bad:

```dm
/obj/effect/spawner/random/entertainment/money_large
	name = "large money spawner"
	loot = list(
		/obj/item/stack/spacecash/c1 = 521,
		/obj/item/stack/spacecash/c10 = 378,
		/obj/item/stack/spacecash/c20 = 212,
		/obj/item/stack/spacecash/c50 = 205,
		/obj/item/stack/spacecash/c100 = 71,
		/obj/item/stack/spacecash/c200 = 60,
		/obj/item/stack/spacecash/c500 = 57,
		/obj/item/stack/spacecash/c1000 = 41,
		/obj/item/stack/spacecash/c10000 = 12,
	)
```

### Do not put empty items in the loot list

Instead use the `spawn_loot_chance` var to control the chance for the spawner to spawn nothing.

Good:

```dm
/obj/effect/spawner/random/structure/crate_abandoned
	name = "locked crate spawner"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)
```

Bad:

```dm
/obj/effect/spawner/lootdrop/crate_spawner
	name = "lootcrate spawner"
	loot = list(
		"" = 80
		/obj/structure/closet/crate/secure/loot = 20,
	)
```

### Avoid making a spawner that is a duplicate

We don't want copy-cat spawners that are almost identical. Instead merge spawners together if possible.

Good:

```dm
/obj/effect/spawner/random/contraband/armory
	name = "armory loot spawner"
	icon_state = "pistol"
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
		/obj/item/grenade/clusterbuster/teargas = 2,
		/obj/item/grenade/clusterbuster = 2,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/revolver/mateba,
	)
```

Bad:

```dm
/obj/effect/spawner/lootdrop/armory_contraband
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/revolver/mateba
	)

/obj/effect/spawner/lootdrop/armory_contraband/metastation
	loot = list(
		/obj/item/gun/ballistic/automatic/pistol = 8,
		/obj/item/gun/ballistic/shotgun/automatic/combat = 5,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/revolver/mateba
	)

```
