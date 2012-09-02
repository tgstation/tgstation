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
			var/lootspawn = text2path(pick(things))
			if(!lootdoubles)
				things.Remove(lootspawn)

			new lootspawn(get_turf(src))
	del(src)