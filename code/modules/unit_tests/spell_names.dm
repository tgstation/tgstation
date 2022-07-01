/**
 * Validates that all spells have a different name.
 *
 * Spell names are used for debugging in some places
 * as well as an option for admins giving out spells,
 * so every spell should have a distinct name.
 *
 * If you're making a subtype with only one or two big changes,
 * consider adding an adjective to the name.
 *
 * "Lesser Fireball" for a subtype of Fireball with a shorter cooldown.
 * "Deadly Magic Missile" for a subtype of Magic Missile that does damage, etc.
 */
/datum/unit_test/spell_names

/datum/unit_test/spell_names/Run()

	var/list/types_to_test = typesof(/datum/action/cooldown/spell)

	var/list/existing_names = list()
	for(var/datum/action/cooldown/spell/spell_type as anything in types_to_test)
		var/spell_name = initial(spell_type.name)
		if(spell_name == "Spell")
			continue

		if(spell_name in existing_names)
			Fail("Spell: [spell_name] ([spell_type]) had a name identical to another spell. \
				This can cause confusion for admins giving out spells, and while debugging. \
				Consider giving the name an adjective if it's a subtype. (\"Greater\", \"Lesser\", \"Deadly\".)")
			continue

		existing_names += spell_name
