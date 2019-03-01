//The human next consumes dropped food to create human babies. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/human_nest
	name = "human nest"
	desc = "A bunch of grass and leaves to provide infants comfort."
	icon = 'icons/mob/nest.dmi'
	icon_state = "human_nest"

	move_resist=INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	max_integrity = 100 //adam and eve, or adam and steve.


	var/faction = list("humans")
	var/nutrient_counter = 200

/obj/structure/lavaland/human_nest/crafted
	nutrient_counter = 0

/obj/structure/lavaland/human_nest/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/human_nest/deconstruct(disassembled)
	return ..()

/obj/structure/lavaland/human_nest/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/human_nest/proc/consume()
	for(var/obj/item/reagent_containers/food/F in view(src,1)) //Only for food right next to/on same tile
		visible_message("<span class='warning'>[F] was added to [src], feeding the tribe's young.</span>")
		var/nutriment = F.reagents.get_reagent_amount("nutriment")
		var/vitamin = F.reagents.get_reagent_amount("vitamin")
		nutrient_counter += nutriment+vitamin
		obj_integrity = min(obj_integrity + max_integrity*0.05,max_integrity)
		del(F)

/obj/structure/lavaland/human_nest/proc/spawn_mob()
	if(nutrient_counter >= 50)
		new /obj/effect/mob_spawn/human/tribal(get_step(loc, pick(GLOB.alldirs)))
		visible_message("<span class='danger'>One of the young is ready to grow up!</span>")
		nutrient_counter -= 50