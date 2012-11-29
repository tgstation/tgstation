/proc/Christmas_Game_Start()
	for(var/obj/structure/flora/tree/pine/xmas_tree in world)
		if(xmas_tree.z != 1)	continue
		for(var/turf/simulated/floor/T in orange(1,xmas_tree))
			for(var/i=1,i<=rand(1,5),i++)
				new /obj/item/weapon/a_gift(T)
	for(var/mob/living/simple_animal/corgi/Ian/Ian in mob_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))