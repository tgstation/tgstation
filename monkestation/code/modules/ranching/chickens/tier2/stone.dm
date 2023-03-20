#define MINIMUM_BREAK_FORCE 10
/mob/living/simple_animal/chicken/stone
	icon_suffix = "stone"

	breed_name = "Stone"
	egg_type = /obj/item/food/egg/stone
	mutation_list = list(/datum/mutation/ranching/chicken/cockatrice)

	book_desc = "These chickens are capable of replicating materials the eggs have been plated with. The downside, you need to break the eggs to get the materials. This will make chickens very sad and make some become hostile."
/obj/item/food/egg/stone
	name = "Rocky Egg"
	icon_state = "stone"

	layer_hen_type = /mob/living/simple_animal/chicken/stone

/obj/item/food/egg/stone/attackby(obj/item/attacked_item, mob/user, params)
	. = ..()
	if(istype(attacked_item, /obj/item/stack/ore))
		visible_message("<span class='notice'>The [attacked_item] starts to melt into the [src]!</span>")
		production_type = attacked_item
		qdel(attacked_item)
	if(attacked_item.force > MINIMUM_BREAK_FORCE && production_type)
		visible_message("<span class='notice'>[src] is cracked open revealing [production_type.name] inside!</span>")

		new production_type.type(src.loc, 1)
		for(var/mob/living/simple_animal/chicken/viewer_chicken in view(3, src))
			visible_message("<span class='notice'>[viewer_chicken] becomes upset from seeing an egg broken near them!</span>")
			viewer_chicken.happiness -= 10
		qdel(src)
#undef MINIMUM_BREAK_FORCE
