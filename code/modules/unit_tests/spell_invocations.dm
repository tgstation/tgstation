/**
 * Validates that all spells have a correct
 * invocation type and invocation setup.
 */
/datum/unit_test/spell_invocations

/datum/unit_test/spell_invocations/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell)

	for(var/datum/action/cooldown/spell/spell_type as anything in types_to_test)
		var/spell_name = initial(spell_type.name)
		var/invoke_type = initial(spell_type.invocation_type)
		switch(invoke_type)
			if(INVOCATION_EMOTE)
				if(isnull(initial(spell_type.invocation_self_message)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set a self message.")
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set an invocation message.")

			if(INVOCATION_SHOUT, INVOCATION_WHISPER)
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set a speaking invocation type but did not set an invocation message.")

			// INVOCATION_NONE:
			// It doesn't matter what they have set for invocation text. So not it's skipped.
