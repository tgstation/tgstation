/obj/effect/spawner/lootdrop
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = 0		//if the same item can be spawned twice
	var/loot = ""			//a list of possible items to spawn- a string of paths

/obj/effect/spawner/lootdrop/initialize()
	var/list/things = params2list(loot)

	if(things && things.len)
		for(var/i = lootcount, i > 0, i--)
			if(!things.len)
				return

			var/loot_spawn = pick(things)
			var/loot_path = text2path(loot_spawn)

			if(!loot_path || !lootdoubles)
				things.Remove(loot_spawn)
				continue

			new loot_path(get_turf(src))
	qdel(src)
