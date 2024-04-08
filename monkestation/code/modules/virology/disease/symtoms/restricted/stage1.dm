/datum/symptom/transformation
	name = "Human Transformation"
	desc = "Turns the target into a human."
	restricted = 1
	max_count = 10
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	max_chance = 10
	var/new_form = /mob/living/carbon/human
	var/bantype
	var/transformed_antag_datum //Do we add a specific antag datum once the transformation is complete?
	var/old_form

/datum/symptom/transformation/activate(mob/living/carbon/mob)
	old_form = mob.type
	do_disease_transformation(mob, new_form)

/*
/datum/symptom/transformation/deactivate(mob/living/carbon/mob)
	do_disease_transformation(mob, old_form)
	to_chat(mob, span_notice("You feel like yourself again!"))
*/

/datum/symptom/transformation/proc/do_disease_transformation(mob/living/affected_mob, form)
	if(!form)
		return
	if(affected_mob.stat != DEAD)
		if(QDELETED(affected_mob))
			return
		if(HAS_TRAIT_FROM(affected_mob, TRAIT_NO_TRANSFORM, REF(src)))
			return
		ADD_TRAIT(affected_mob, TRAIT_NO_TRANSFORM, REF(src))
		if(iscarbon(affected_mob))
			for(var/obj/item/W in affected_mob.get_equipped_items(include_pockets = TRUE))
				affected_mob.dropItemToGround(W)
			for(var/obj/item/I in affected_mob.held_items)
				affected_mob.dropItemToGround(I)
		var/mob/living/new_mob = new form(affected_mob.loc)
		if(istype(new_mob))
			if(bantype && is_banned_from(affected_mob.ckey, bantype))
				replace_banned_player(new_mob, affected_mob)
			new_mob.set_combat_mode(TRUE)
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.key = affected_mob.key
		if(transformed_antag_datum)
			new_mob.mind.add_antag_datum(transformed_antag_datum)
		new_mob.name = affected_mob.real_name
		new_mob.real_name = new_mob.name
		qdel(affected_mob)

/datum/symptom/transformation/proc/replace_banned_player(mob/living/new_mob, mob/living/affected_mob) // This can run well after the mob has been transferred, so need a handle on the new mob to kill it if needed.
	set waitfor = FALSE

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates_for_mob("Do you want to play as [affected_mob.real_name]?", check_jobban = bantype, role = bantype, poll_time = 5 SECONDS, target_mob = affected_mob, pic_source = affected_mob, role_name_text = "transformation victim")
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(affected_mob, span_userdanger("Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!"))
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(affected_mob)]) to replace a jobbanned player.")
		affected_mob.ghostize(FALSE)
		affected_mob.key = C.key
	else
		to_chat(new_mob, span_userdanger("Your mob has been claimed by death! Appeal your job ban if you want to avoid this in the future!"))
		new_mob.investigate_log("has been killed because there was no one to replace them as a job-banned player.", INVESTIGATE_DEATHS)
		new_mob.death()
		if (!QDELETED(new_mob))
			new_mob.ghostize(can_reenter_corpse = FALSE)
			new_mob.key = null

/datum/symptom/transformation/robot
	name = "Robotic Transformation"
	new_form = /mob/living/silicon/robot
	bantype = JOB_CYBORG

/datum/symptom/transformation/xeno
	name = "Xenomorph Transformation"
	new_form = /mob/living/carbon/alien/adult/hunter
	bantype = ROLE_ALIEN

/datum/symptom/transformation/slime
	name = "Advanced Mutation Transformation"
	new_form = /mob/living/basic/slime

/datum/symptom/transformation/corgi
	name = "The Barkening"
	new_form = /mob/living/basic/pet/dog/corgi

/datum/symptom/transformation/morph
	name = "Gluttony's Blessing"
	new_form = /mob/living/basic/morph
	transformed_antag_datum = /datum/antagonist/morph

/datum/symptom/transformation/gondola
	name = "Gondola Transformation"
	max_chance = 50
	new_form = /mob/living/simple_animal/pet/gondola

/datum/symptom/transformation/gondola/digital
	new_form = /mob/living/simple_animal/pet/gondola/virtual_domain

/datum/symptom/anxiety
	name = "Severe Anxiety"
	desc = "Causes the host to suffer from severe anxiety"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = TRUE
	max_multiplier = 4

/datum/symptom/anxiety/activate(mob/living/carbon/mob, datum/disease/advanced/disease)

	switch(round(multiplier, 1))
		if(2) //also changes say, see say.dm
			if(prob(2.5))
				to_chat(mob, span_notice("You feel anxious."))
		if(3)
			if(prob(5))
				to_chat(mob, span_notice("Your stomach flutters."))
			if(prob(2.5))
				to_chat(mob, span_notice("You feel panicky."))
			if(prob(1))
				to_chat(mob, span_danger("You're overtaken with panic!"))
				mob.adjust_confusion(rand(2 SECONDS, 3 SECONDS))
		if(4)
			if(prob(5))
				to_chat(mob, span_danger("You feel butterflies in your stomach."))
			if(prob(2.5))
				mob.visible_message(span_danger("[mob] stumbles around in a panic."), \
												span_userdanger("You have a panic attack!"))
				mob.adjust_confusion(rand(6 SECONDS, 8 SECONDS))
				mob.adjust_jitter(rand(12 SECONDS, 16 SECONDS))
			if(prob(1))
				mob.visible_message(span_danger("[mob] coughs up butterflies!"), \
													span_userdanger("You cough up butterflies!"))
				new /mob/living/basic/butterfly(mob.loc)
				new /mob/living/basic/butterfly(mob.loc)
