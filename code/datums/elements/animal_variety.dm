/**
 * # Animal variety element!
 *
 * Element that picks an suffix to append onto the icon state from a list given on creation,
 * among some pixel shifting stuff. Basically you will see VARIETY in a batch of animals.
 */
/datum/element/animal_variety

/datum/element/animal_variety/Attach(datum/target, icon_prefix, chosen_sprite_suffix, modify_pixels = FALSE)
	. = ..()
	if(isanimal(target))
		var/mob/living/simple_animal/animal = target
		animal.icon_state = "[icon_prefix]_[chosen_sprite_suffix]"
		animal.icon_living = "[icon_prefix]_[chosen_sprite_suffix]"
		animal.icon_dead = "[icon_prefix]_[chosen_sprite_suffix]_dead"
		if(modify_pixels)
			animal.pixel_x = animal.base_pixel_x + rand(-6, 6)
			animal.pixel_y = animal.base_pixel_y + rand(0, 10)
		return

	if(isbasicmob(target))
		var/mob/living/basic/animal = target
		animal.icon_state = "[icon_prefix]_[chosen_sprite_suffix]"
		animal.icon_living = "[icon_prefix]_[chosen_sprite_suffix]"
		animal.icon_dead = "[icon_prefix]_[chosen_sprite_suffix]_dead"
		if(modify_pixels) // Yeah I know I didn't actually need to copy and paste this part but basicmob's entire existence is copypaste
			animal.pixel_x = animal.base_pixel_x + rand(-6, 6)
			animal.pixel_y = animal.base_pixel_y + rand(0, 10)
		return

	return ELEMENT_INCOMPATIBLE

/datum/element/animal_variety/Detach(datum/target)
	if(isanimal(target))
		var/mob/living/simple_animal/animal = target
		animal.icon_state = initial(animal.icon_state)
		animal.icon_living = initial(animal.icon_living)
		animal.icon_dead = initial(animal.icon_living)
		animal.pixel_x = animal.base_pixel_x
		animal.pixel_y = animal.base_pixel_y

	if(isbasicmob(target))
		var/mob/living/basic/animal = target
		animal.icon_state = initial(animal.icon_state)
		animal.icon_living = initial(animal.icon_living)
		animal.icon_dead = initial(animal.icon_living)
		animal.pixel_x = animal.base_pixel_x
		animal.pixel_y = animal.base_pixel_y

	return ..()
