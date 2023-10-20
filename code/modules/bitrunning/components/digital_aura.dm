/// Creates a digital effect around the target
/datum/element/digital_aura
	/// The effect around the target
	var/mutable_appearance/glitch_effect

/datum/element/digital_aura/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/thing = target

	var/base_icon = 'icons/effects/bitrunning.dmi'

	if(isliving(thing))
		var/mob/living/creature = thing
		switch(creature.mob_size)
			if(MOB_SIZE_LARGE)
				base_icon = 'icons/effects/bitrunning_48.dmi'
			if(MOB_SIZE_HUGE)
				base_icon = 'icons/effects/bitrunning_64.dmi'

	glitch_effect = mutable_appearance(base_icon, "glitch", MUTATIONS_LAYER, alpha = 170)

	thing.add_atom_colour(LIGHT_COLOR_BUBBLEGUM, FIXED_COLOUR_PRIORITY)
	thing.add_overlay(glitch_effect)
	thing.alpha = 210
	thing.set_light(2, l_color = LIGHT_COLOR_BUBBLEGUM, l_on = TRUE)
	thing.update_appearance()

/datum/element/digital_aura/Detach(datum/source)
	. = ..()
	var/atom/thing = source

	thing.remove_atom_colour(FIXED_COLOUR_PRIORITY, LIGHT_COLOR_BUBBLEGUM)
	thing.cut_overlay(glitch_effect)
	thing.alpha = 255
	thing.set_light_on(FALSE)
	thing.update_appearance()

