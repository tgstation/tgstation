//Oceanic Tendrils, which spawn lavaland monsters and DONT break into a chasm when killed (chasms cause puddles, so we cant have dat)
/obj/structure/spawner/lavaland/ocean
	name = "oceanic tendril"
	desc = "A vile tendril of corruption, originating deep under the sea. Terrible monsters are pouring out of it."

	deconstruct_override = TRUE

/obj/structure/spawner/lavaland/ocean/deconstruct(disassembled)
	new /obj/effect/collapse/ocean(loc)
	return ..()


/obj/effect/collapse/ocean
	name = "collapsing oceanic tendril"
	desc = "Get your loot and get clear, else you will be sleeping with the fishes!"

	// a var used in terraformation, i could just type the turf into it but that would look ugly due to its lenght
	var/transformation_turf = /turf/open/floor/plating/ocean/dark/rock/warm/fissure

/obj/effect/collapse/ocean/collapse()
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message(span_boldannounce("The tendril falls inward, the ground around it filling with magma!"))
	for(var/turf/T in RANGE_TURFS(2,src))
		if(!T.density)
			T.TerraformTurf(transformation_turf, transformation_turf, flags = CHANGETURF_INHERIT_AIR)
	qdel(src)


/obj/structure/spawner/lavaland/ocean/goliath
	mob_types = list(/mob/living/basic/mining/goliath)

/obj/structure/spawner/lavaland/ocean/legion
	mob_types = list(/mob/living/basic/mining/legion)

/obj/structure/spawner/lavaland/ocean/fish
	max_mobs = 6
	mob_types = list(
		/mob/living/basic/aquatic/fish/cod,
		/mob/living/basic/aquatic/fish/gupper,
	)

/obj/structure/spawner/lavaland/ocean/icewatcher
	mob_types = list(/mob/living/basic/mining/watcher/icewing)
