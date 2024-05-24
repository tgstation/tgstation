/mob/living/basic/chicken/dreamsicle
	icon_suffix = "dreamsicle"

	breed_name = "Dreamsicle"
	egg_type = /obj/item/food/egg/dreamsicle
	mutation_list = list()

	book_desc = "Unlike its parent the dreamsicle is able to survive in normal environments, it has also tamed the hyper nature of its parents. This is the perfect hybrid and consuming the egg will make you bounce of the walls leaving a trail of ice behind you."
/obj/item/food/egg/dreamsicle
	name = "Dreamsicle Egg"
	icon_state = "dreamsicle"

	layer_hen_type = /mob/living/basic/chicken/dreamsicle
	nearby_mob = /mob/living/basic/chicken/snowy

/obj/item/food/egg/dreamsicle/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	to_chat(eater, "<span class='warning'>You start to feel a dreamsicle high coming on.</span>")
	eater.apply_status_effect(SNOWY_EGG)
	eater.apply_status_effect(SUGAR_RUSH)
