/datum/action/cooldown/spell/pointed/projectile/sdql
	name = "Aimed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	projectile_type = /obj/projectile

/datum/action/cooldown/spell/pointed/projectile/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_PROJECTILE_HIT,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)

/datum/action/cooldown/spell/aoe/sdql
	name = "AoE SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/datum/action/cooldown/spell/aoe/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_AOE_ON_CAST,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)

/datum/action/cooldown/spell/cone/sdql
	name = "Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/datum/action/cooldown/spell/cone/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_CONE_ON_CAST,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)

/datum/action/cooldown/spell/cone/staggered/sdql
	name = "Staggered Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/datum/action/cooldown/spell/cone/staggered/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_CONE_ON_LAYER_EFFECT,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)


/datum/action/cooldown/spell/pointed/sdql
	name = "Pointed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/datum/action/cooldown/spell/pointed/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_CAST,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)


/// Dummy self spell !!for sdql spells only!!
/// All spells are, by default, self spells so this is only for readability
/// Don't use this for subtypes of other spells!
/// Just subtype off of spell/ for your self cast spell!
/datum/action/cooldown/spell/self

/datum/action/cooldown/spell/self/sdql
	name = "Self SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/datum/action/cooldown/spell/self/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_CAST,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)

/datum/action/cooldown/spell/touch/sdql
	name = "Touch SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	/// Vars to edit on the created hand.
	var/list/hand_var_overrides = list()

/datum/action/cooldown/spell/touch/sdql/New(Target, giver)
	. = ..()
	var/static/list/executor_signals = list(
		COMSIG_SPELL_TOUCH_HAND_HIT,
	)

	AddComponent(/datum/component/sdql_spell_executor, giver, executor_signals)

/datum/action/cooldown/spell/touch/sdql/create_hand(mob/living/carbon/cast_on)
	. = ..()
	if(!attached_hand)
		return

	for(var/var_to_edit in hand_var_overrides)
		if(attached_hand.vars[var_to_edit])
			attached_hand.vv_edit_var(var_to_edit, hand_var_overrides[var_to_edit])

	cast_on.update_inv_hands()
