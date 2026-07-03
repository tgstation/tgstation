#define BRAIN_DAMAGE_MIN 1

/// Inflicts crippling brain damage on the target
/datum/smite/brain_damage
	name = "Brain damage"
	var/amount = BRAIN_DAMAGE_MIN // BANDASTATION EDIT: Configurable smite

// BANDASTATION EDIT START: Configurable smite
/datum/smite/brain_damage/configure(client/user)
	var/amount_choice = tgui_input_number(user,
		"Сколько урона наносим мозгу?",
		"Количество урона?",
		min_value = BRAIN_DAMAGE_MIN,
		max_value = BRAIN_DAMAGE_DEATH)
	if(!amount_choice)
		return FALSE

	amount = amount_choice
	return TRUE
// BANDASTATION EDIT END: Configurable smite

/datum/smite/brain_damage/effect(client/user, mob/living/target)
	. = ..()
	target.adjust_organ_loss(ORGAN_SLOT_BRAIN, amount, BRAIN_DAMAGE_DEATH) // BANDASTATION EDIT: Configurable smite

#undef BRAIN_DAMAGE_MIN
