/mob/living/basic/chicken/dream
	icon_suffix = "dreaming"

	breed_name = "Dream"
	egg_type = /obj/item/food/egg/dream
	mutation_list = list()

	book_desc = "A mystical chicken born from the dreams of death will only appear when a Black Selkie dies of old age."

/mob/living/basic/chicken/dream/old_age_death()
	return

/obj/item/food/egg/dream
	name = "Dream Egg"
	icon_state = "dream"

	layer_hen_type = /mob/living/basic/chicken/dream

/obj/item/food/egg/dream/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	eater.apply_status_effect(DREAM_STATE)

/datum/status_effect/ranching/dream_state
	id = "dream_state"
	duration = 60 SECONDS
	var/is_sleeping = FALSE

/datum/status_effect/ranching/dream_state/on_apply()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.visible_message("<span class='notice'>[owner] goes into a deep sleep!</span>")
		carbon_owner.fakedeath("dream_state") //play dead
		carbon_owner.update_stat()
		is_sleeping = TRUE
	return ..()

/datum/status_effect/ranching/dream_state/on_remove()
	if(is_sleeping)
		owner.visible_message("<span class='notice'>[owner] awakes from their deep sleep!</span>")
		owner.cure_fakedeath("dream_state")
		owner.adjustBruteLoss(-100)
		owner.adjustFireLoss(-100)
		owner.adjustToxLoss(-100)
		owner.adjustCloneLoss(-100)
