/obj/effect/spawner/lootdrop
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = 0		//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/spawner/lootdrop/initialize()
	if(loot && loot.len)
		for(var/i = lootcount, i > 0, i--)
			if(!loot.len) return
			var/lootspawn = pick(loot)
			if(!lootdoubles)
				loot.Remove(lootspawn)

			new lootspawn(get_turf(src))
	del(src)