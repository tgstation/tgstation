/obj/structure/flora/ocean
	icon = 'modular_skyrat/modules/liquids/icons/obj/flora/ocean_flora.dmi'
	var/random_variants = 0

/obj/structure/flora/ocean/Initialize()
	. = ..()
	if(random_variants)
		icon_state = "[icon_state][rand(1,random_variants)]"

/obj/structure/flora/ocean/glowweed
	name = "glow weed"
	icon_state = "glowweed"
	desc = "A plant with glowing bulbs at the end of it."
	random_variants = 3
	light_color = LIGHT_COLOR_CYAN
	light_range = 1.5

/obj/structure/flora/ocean/seaweed
	name = "sea weed"
	icon_state = "seaweed"
	desc = "Just your regular seaweed."
	random_variants = 5

/obj/structure/flora/ocean/longseaweed
	name ="sea weed"
	icon_state = "longseaweed"
	desc = "Less so regular seaweed. This one is very long."
	random_variants = 4

/obj/structure/flora/ocean/coral
	name = "coral"
	icon_state = "coral"
	desc = "Beautiful coral."
	random_variants = 3
	density = TRUE

#define SCRAP_WELD_LOW 7
#define SCRAP_WELD_HIGH 12

#define SCRAP_METAL_YIELD_LOW 12
#define SCRAP_METAL_YIELD_HIGH 20

/obj/structure/flora/scrap
	name = "scrap metal"
	desc = "A huge chunk of metal, rusted and worn. Perhaps it can still be salvaged into something useful."
	icon = 'modular_skyrat/modules/liquids/icons/obj/flora/scrap.dmi'
	icon_state = "scrap"
	anchored = FALSE
	density = TRUE
	var/random_variants = 3
	var/welds_remaining = 0

/obj/structure/flora/scrap/Initialize()
	. = ..()
	welds_remaining = rand(SCRAP_WELD_LOW, SCRAP_WELD_HIGH)
	if(random_variants)
		icon_state = "[icon_state][rand(1,random_variants)]"

/obj/structure/flora/scrap/welder_act(mob/living/user, obj/item/I, first = TRUE)
	..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	if(first)
		to_chat(user, "<span class='notice'>You start slicing the [src]...</span>")
	if(I.use_tool(src, user, 2 SECONDS))
		welds_remaining--
		if(welds_remaining <= 0)
			to_chat(user, "<span class='notice'>You successfully salvage [src].</span>")
			new /obj/item/stack/sheet/iron(get_turf(src), rand(SCRAP_METAL_YIELD_LOW, SCRAP_METAL_YIELD_HIGH))
			qdel(src)
		else
			welder_act(user, I, FALSE)
	return TRUE

#undef SCRAP_WELD_LOW
#undef SCRAP_WELD_HIGH

#undef SCRAP_METAL_YIELD_LOW
#undef SCRAP_METAL_YIELD_HIGH

/obj/effect/spawner/liquids_spawner
	name = "Liquids Spawner"
	var/reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT*LIQUID_WAIST_LEVEL_HEIGHT)
	var/temp = T20C

/obj/effect/spawner/liquids_spawner/Initialize(mapload)
	..()
	if(!isturf(loc))
		return INITIALIZE_HINT_QDEL
	var/turf/T = loc
	T.add_liquid_list(reagent_list, FALSE, temp)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/liquids_spawner/acid_puddle
	reagent_list = list(/datum/reagent/toxin/acid = ONE_LIQUIDS_HEIGHT)

/obj/effect/spawner/liquids_spawner/acid_waist
	reagent_list = list(/datum/reagent/toxin/acid = ONE_LIQUIDS_HEIGHT*LIQUID_WAIST_LEVEL_HEIGHT)

/obj/effect/spawner/ocean_curio
	name = "Ocean Curio Spawner"
	var/default_1 = /obj/structure/flora/ocean/seaweed
	var/default_2 = /obj/structure/flora/ocean/longseaweed
	var/allowed_area_types = list(/area/ocean = TRUE, /area/ocean/generated = TRUE)

/obj/effect/spawner/ocean_curio/Initialize(mapload)
	..()

	//Way to not spawn stuff inside ruins etc.
	var/area/A = get_area(src)
	if(!allowed_area_types[A.type])
		return INITIALIZE_HINT_QDEL
	var/turf/T = get_turf(src)
	if(T.turf_flags & NO_RUINS)
		return INITIALIZE_HINT_QDEL

	var/to_spawn_path

	var/random = rand(1,80)
	switch(random)
		if(1 to 3)
			to_spawn_path = /obj/structure/flora/scrap
		if(4 to 6) //Ocean trash, I guess
			to_spawn_path = /obj/effect/spawner/random/maintenance
		else
			if(prob(50))
				to_spawn_path = default_1
			else
				to_spawn_path = default_2
	new to_spawn_path(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/ocean_curio/rock
	default_1 = /obj/structure/flora/rock
	default_2 = /obj/structure/flora/rock/pile
