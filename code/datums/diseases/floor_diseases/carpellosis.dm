#define GNASHING_RANGE 7

/// Caused by dirty food. Makes you growl at people and bite them spontaneously.
/datum/disease/carpellosis
	name = "Carpellosis"
	desc = "You have an angry space carp inside."
	form = "Parasite"
	agent = "Carp Ella"
	cure_text = "Chlorine"
	cures = list(/datum/reagent/chlorine)
	viable_mobtypes = list(/mob/living/carbon/human)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	severity = DISEASE_SEVERITY_MEDIUM
	required_organ = ORGAN_SLOT_STOMACH
	max_stages = 5
	/// The chance of Carp Ella to spawn on cure
	var/ella_spawn_chance = 10
	/// Whether the max stage was achieved in disease lifecycle
	var/max_stage_reached = FALSE
	/// Carp ability gained on max stage
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/rift_ability
	/// Whether the host has carp ability
	var/ability_granted = FALSE

/datum/disease/carpellosis/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return


	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS && affected_mob.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL))
				to_chat(affected_mob, span_warning("You want to wag your tail..."))
				affected_mob.emote("wag")
		if(3)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("You suddenly feel like swimming in space..."))
			else if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				affected_mob.visible_message("gnashes.", visible_message_flags = EMOTE_MESSAGE)
		if(4)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				gnash_someone()
			else if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				affected_mob.visible_message("gnashes.", visible_message_flags = EMOTE_MESSAGE)
		if(5)
			max_stage_reached = TRUE
			grant_ability()
			if(SPT_PROB(2, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				gnash_someone()
			else if(SPT_PROB(2, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				affected_mob.visible_message("gnashes.", visible_message_flags = EMOTE_MESSAGE)

/datum/disease/carpellosis/Destroy()
	if(ability_granted)
		QDEL_NULL(rift_ability)
	return ..()

/datum/disease/carpellosis/cure(add_resistance = TRUE)
	if(ability_granted)
		rift_ability.Remove(affected_mob)
	if(max_stage_reached && prob(ella_spawn_chance))
		to_chat(affected_mob, span_warning("Something comes out of you!"))
		new /mob/living/basic/carp/ella(affected_mob.loc)
	return ..()

/datum/disease/carpellosis/proc/grant_ability()
	if(ability_granted)
		return
	rift_ability = new(src)
	rift_ability.Grant(affected_mob)
	rift_ability.HideFrom(affected_mob)
	ability_granted = TRUE

/datum/disease/carpellosis/proc/find_nearby_human()
	var/list/surroundings = orange(GNASHING_RANGE, affected_mob)
	for(var/mob/human as anything in typecache_filter_list(surroundings, typecacheof(/mob/living/carbon/human)))
		if(human.stat != DEAD && !(HAS_TRAIT(human, TRAIT_FAKEDEATH)))
			return human

/datum/disease/carpellosis/proc/gnash_someone()
	var/mob/living/carbon/human/target = find_nearby_human()
	if(isnull(target) || !affected_mob.get_bodypart(BODY_ZONE_HEAD)) // Need mouth to gnash
		to_chat(affected_mob, span_warning("You want to gnash at someone..."))
		return
	to_chat(affected_mob, span_warning("[target.name] makes you angry for some reason..."))
	if(ability_granted && !affected_mob.Adjacent(target))
		rift_ability.Trigger(target = target)
	affected_mob.face_atom(target)
	if(affected_mob.Adjacent(target))
		affected_mob.set_combat_mode(TRUE)
		target.attack_paw(affected_mob)
	else
		affected_mob.visible_message("gnashes at [target.name].", visible_message_flags = EMOTE_MESSAGE)

#undef GNASHING_RANGE
