/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	anchored = TRUE // Stops persistent lootdrop spawns from being shoved into lockers
	var/lootcount = 1 //how many items will be spawned
	var/lootdoubles = TRUE //if the same item can be spawned twice
	var/list/loot //a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	/// Whether the spawner should immediately spawn loot and cleanup on Initialize()
	var/spawn_on_init = TRUE

/obj/effect/spawner/lootdrop/Initialize(mapload)
	. = ..()

	if(spawn_on_init)
		spawn_loot()
		return INITIALIZE_HINT_QDEL

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/lootdrop/proc/spawn_loot(lootcount_override)
	var/lootcount = isnull(lootcount_override) ? src.lootcount : lootcount_override

	if(loot?.len)
		var/loot_spawned = 0
		while((lootcount-loot_spawned) && loot.len)
			var/lootspawn = pickweight(loot)
			while(islist(lootspawn))
				lootspawn = pickweight(lootspawn)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			if(lootspawn)
				var/atom/movable/spawned_loot = new lootspawn(loc)
				if (!fan_out_items)
					if (pixel_x != 0)
						spawned_loot.pixel_x = pixel_x
					if (pixel_y != 0)
						spawned_loot.pixel_y = pixel_y
				else
					if (loot_spawned)
						spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
			loot_spawned++

//finds the probabilities of items spawning from a loot spawner's loot pool
/obj/item/loot_table_maker
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawner_to_test = /obj/effect/spawner/lootdrop/maintenance //what lootdrop spawner to use the loot pool of
	var/loot_count = 180 //180 is about how much maint loot spawns per map as of 11/14/2019
	//result outputs
	var/list/spawned_table //list of all items "spawned" and how many
	var/list/stat_table //list of all items "spawned" and their occurrance probability

/obj/item/loot_table_maker/Initialize()
	. = ..()
	make_table()

/obj/item/loot_table_maker/attack_self(mob/user)
	to_chat(user, "Loot pool re-rolled.")
	make_table()

/obj/item/loot_table_maker/proc/make_table()
	spawned_table = list()
	stat_table = list()
	var/obj/effect/spawner/lootdrop/spawner_to_table = new spawner_to_test
	var/lootpool = spawner_to_table.loot
	qdel(spawner_to_table)
	for(var/i in 1 to loot_count)
		var/loot_spawn = pick_loot(lootpool)
		if(!(loot_spawn in spawned_table))
			spawned_table[loot_spawn] = 1
		else
			spawned_table[loot_spawn] += 1
	stat_table += spawned_table
	for(var/item in stat_table)
		stat_table[item] /= loot_count

/obj/item/loot_table_maker/proc/pick_loot(lootpool) //selects path from loot table and returns it
	var/lootspawn = pickweight(lootpool)
	while(islist(lootspawn))
		lootspawn = pickweight(lootspawn)
	return lootspawn
