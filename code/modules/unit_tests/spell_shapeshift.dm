/**
 * Validates that all shapeshift type spells
 * have a valid possible_shapes setup.
 */
/datum/unit_test/shapeshift_spell_validity

/datum/unit_test/shapeshift_spell_validity/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell/shapeshift)

	for(var/spell_type in types_to_test)
		var/datum/action/cooldown/spell/shapeshift/shift = new spell_type()
		if(!LAZYLEN(shift.possible_shapes))
			Fail("Shapeshift spell: [shift] ([spell_type]) did not have any possible shapeshift options.")

		for(var/shift_type in shift.possible_shapes)
			if(!ispath(shift_type, /mob/living))
				Fail("Shapeshift spell: [shift] had an invalid / non-living shift type ([shift_type]) in their possible shapes list.")

		qdel(shift)
