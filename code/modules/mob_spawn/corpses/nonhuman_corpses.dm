
//full of weird and wacky mob spawns. this is probably the darkest corner of mob spawns even after cleanup so be ready for shitcode

///dead ai, blue screen and everything.
/obj/effect/mob_spawn/corpse/ai
	mob_type = /mob/living/silicon/ai/spawned

/obj/effect/mob_spawn/corpse/ai/create(mob/user, newname)
	var/ai_already_present = locate(/mob/living/silicon/ai) in loc
	if(ai_already_present)
		return
	. = ..()

/obj/effect/mob_spawn/corpse/ai/special(mob/living/silicon/ai/spawned/dead_ai)
	. = ..()
	dead_ai.name = src.name
	dead_ai.real_name = src.name

///dead slimes, with a var for whatever color you want.
/obj/effect/mob_spawn/corpse/slime
	mob_type = /mob/living/simple_animal/slime
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey baby slime" //sets the icon in the map editor
	///the color of the slime you're spawning.
	var/slime_species = "grey"

/obj/effect/mob_spawn/corpse/slime/special(mob/living/simple_animal/slime/spawned_slime)
	. = ..()
	spawned_slime.set_colour(slime_species)

///dead facehuggers, great for xeno ruins so you can have a cool ruin without spiraling the entire round into xenomorph hell. also, this is a terrible terrible artifact of time
/obj/effect/mob_spawn/corpse/facehugger
	//mostly for unit tests to not get alarmed (which by all means it should because this is a mess)
	mob_type = /obj/item/clothing/mask/facehugger

/obj/effect/mob_spawn/corpse/facehugger/create(mob/user)
	var/obj/item/clothing/mask/facehugger/spawned_facehugger = new mob_type(loc)
	spawned_facehugger.Die()
	qdel(src)

///dead goliath spawner
/obj/effect/mob_spawn/corpse/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_dead_helper"
