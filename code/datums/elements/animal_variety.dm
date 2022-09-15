/**
 * # animal variety element!
 *
 * bespoke element that picks an suffix to append onto the icon state from a list given on creation, among some pixel shifting stuff
 * basically you will see VARIETY in a batch of simplemobs.
 */
/datum/element/animal_variety
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	/// prefix for the icon state, this will always stay the same
	var/icon_prefix
	/// chosen sprite suffix, in element args it picks from a list on what this will be
	var/chosen_sprite_suffix
	/// boolean on whether the element should also mess with the pixel_x and pixel_y
	var/modify_pixels

/datum/element/animal_variety/Attach(datum/target, icon_prefix, chosen_sprite_suffix, modify_pixels = FALSE)
	. = ..()
	if(!isanimal(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/simple_animal/animal = target
	src.icon_prefix = icon_prefix
	src.chosen_sprite_suffix = chosen_sprite_suffix
	src.modify_pixels = modify_pixels
	animal.icon_state = "[icon_prefix]_[chosen_sprite_suffix]"
	animal.icon_living = "[icon_prefix]_[chosen_sprite_suffix]"
	animal.icon_dead = "[icon_prefix]_[chosen_sprite_suffix]_dead"
	if(modify_pixels)
		animal.pixel_x = animal.base_pixel_x + rand(-6, 6)
		animal.pixel_y = animal.base_pixel_y + rand(0, 10)

/datum/element/animal_variety/Detach(datum/target)
	var/mob/living/simple_animal/animal = target
	animal.icon_state = initial(animal.icon_state)
	animal.icon_living = initial(animal.icon_living)
	animal.icon_dead = initial(animal.icon_living)
	animal.pixel_x = animal.base_pixel_x
	animal.pixel_y = animal.base_pixel_y
	. = ..()
