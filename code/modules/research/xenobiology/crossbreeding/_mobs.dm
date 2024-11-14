/*
Slimecrossing Mobs
	Mobs and effects added by the slimecrossing system.
	Collected here for clarity.
*/

/// Slime transformation power - from Burning Black
/datum/action/cooldown/spell/shapeshift/slime_form
	name = "Slime Transformation"
	desc = "Transform from a human to a slime, or back again!"
	button_icon_state = "transformslime"
	cooldown_time = 0 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	convert_damage_type = TOX
	possible_shapes = list(/mob/living/basic/slime/transformed_slime)

	/// If TRUE, we self-delete (remove ourselves) the next time we turn back into a human
	var/remove_on_restore = FALSE

/datum/action/cooldown/spell/shapeshift/slime_form/do_unshapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return

	if(remove_on_restore)
		qdel(src)

/// Transformed slime - from Burning Black
/mob/living/basic/slime/transformed_slime

// Just in case.
/mob/living/basic/slime/transformed_slime/reproduce()
	to_chat(src, span_warning("I can't reproduce...")) // Mood
	return

//Slime corgi - Chilling Pink
/mob/living/basic/pet/dog/corgi/puppy/slime
	name = "\improper slime corgi puppy"
	real_name = "slime corgi puppy"
	desc = "An unbearably cute pink slime corgi puppy."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	can_be_shaved = FALSE
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("blorbles", "bubbles", "borks")

/mob/living/basic/pet/dog/corgi/puppy/slime/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list())
	speech.emote_hear = string_list(list("bubbles!", "splorts.", "splops!"))
	speech.emote_see = string_list(list("gets goop everywhere.", "flops.", "jiggles!"))
