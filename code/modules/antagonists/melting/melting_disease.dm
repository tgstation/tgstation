
/datum/disease/transformation/melting
	name = "Melting Disease"
	cure_text = "Killing the abnormality spreading the disease. Freezing will stop progression and symptoms."
	cures = list()
	cure_chance = 5
	spread_flags = DISEASE_SPREAD_AIRBORNE
	agent = "Melting Microorganisms"
	desc = "This disease breaks down and converts the body to slime, giving the sensation of \"burning\"."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list()
	stage2	= list("You feel hot.", "You feel weak.")
	stage3	= list("<span class='danger'>Something is burning inside of you!</span>", "Your skin feels off.")
	stage4	= list("<span class='danger'>You're burning apart in your own skin!</span>", "<span class='danger'>You feel yourself breaking down...</span>", "<span class='danger'>Your skin is dripping.</span>")
	stage5	= list("<span class='userdanger'>IT BURNS!</span>")
	new_form = /mob/living/simple_animal/hostile/melted
	infectable_biotypes = list(MOB_ORGANIC)
	process_dead = TRUE
	var/mob/living/simple_animal/hostile/melted/creator
	var/obj/item/slime_mask/mask
	var/attemped_add_mask = FALSE

	//bantype = "Melting" antag ban! duh! //remember to put this in

/datum/disease/transformation/melting/New(mob_source)
	. = ..()
	creator = mob_source
	var/list/splitname = splittext(creator.name," ")
	agent = "[splitname[1]] Microorganisms"

/datum/disease/transformation/melting/stage_act()
	var/obj/item/organ/heart/slime/slimeheart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(istype(slimeheart))
		return //champions are not affected by the disease, it doesn't even progress
	if(affected_mob.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		return //same effect as a champion, no progression or symptoms
	..()
	switch(stage)
		if(2)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a burning pain in your chest.</span>")
				affected_mob.adjustToxLoss(2)
		if(3)
			if(affected_mob.stat == DEAD)
				do_disease_transformation(affected_mob)
			if(attemped_add_mask)
				attemped_add_mask = TRUE
				mask = new(get_turf(affected_mob))
				affected_mob.equip_to_slot_if_possible(mask, SLOT_WEAR_MASK, qdel_on_fail = TRUE)

			if(prob(6))
				to_chat(affected_mob, "<span class='danger'>You feel a burning pain in your chest.</span>")
				affected_mob.adjustToxLoss(2)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>Bits of you fall to the ground.</span>")
				var/turf/T = get_turf(affected_mob)
				T.add_vomit_floor(src, VOMIT_TOXIC, creator.slimebody_color)
				affected_mob.adjustCloneLoss(5)
		if(4)
			if(affected_mob.stat == UNCONSCIOUS)
				do_disease_transformation(affected_mob)
			affected_mob.slurring += 2
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Bits of you fall to the ground.</span>")
				var/turf/T = get_turf(affected_mob)
				T.add_vomit_floor(src, VOMIT_TOXIC, creator.slimebody_color)
				affected_mob.adjustCloneLoss(5)
		if(5)
			do_disease_transformation(affected_mob)

/datum/disease/transformation/melting/do_disease_transformation(mob/living/affected_mob)
	var/mob/living/carbon/human/affected_human = affected_mob
	if(!istype(affected_human))
		return
	var/obj/item/organ/brain/brain = affected_human.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return
	brain.Remove(affected_human, special = TRUE)
	var/mob/living/simple_animal/hostile/melted/new_slime = ..()
	if(!new_slime)
		return
	new_slime.creator = creator
	brain.forceMove(new_slime)

/datum/disease/transformation/melting/cure()
	QDEL_NULL(mask)
	..()

/obj/item/slime_mask
	name = "slime mask"
