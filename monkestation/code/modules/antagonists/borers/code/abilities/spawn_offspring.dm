/// How much health do we take from the borer if its producing eggs without a host?
#define OUT_OF_HOST_EGG_COST 50

//we need a way to produce offspring
/datum/action/cooldown/borer/produce_offspring
	name = "Produce Offspring"
	cooldown_time = 1 MINUTES
	button_icon_state = "reproduce"
	chemical_cost = 100
	needs_living_host = TRUE
	ability_explanation = "\
	Forces your host to produce a borer egg inside of their stomach, then vomit it up\n\
	Be carefull as the egg is fragile and can be broken very easily by any human, along with being extremelly noticable\n\
	"

/datum/action/cooldown/borer/produce_offspring/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(cortical_owner.neutered == TRUE)
		owner.balloon_alert(owner, "You cannot reproduce!")
		return
	if(!(cortical_owner.upgrade_flags & BORER_ALONE_PRODUCTION) && !cortical_owner.inside_human())
		owner.balloon_alert(owner, "host required")
		return
	cortical_owner.chemical_storage -= chemical_cost
	if((cortical_owner.upgrade_flags & BORER_ALONE_PRODUCTION) && !cortical_owner.inside_human())
		no_host_egg()
		StartCooldown()
		return
	produce_egg()
	var/obj/item/organ/internal/brain/victim_brain = cortical_owner.human_host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(victim_brain)
		cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25 * cortical_owner.host_harm_multiplier)
		var/eggroll = rand(1,100)
		if(eggroll <= 75)
			switch(eggroll)
				if(1 to 34)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
					owner.balloon_alert(owner, "Cerebrum damaged!")
				if(35 to 60)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "Cerebellum damaged!")
				if(61 to 71)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "Brainstem damaged!")
				if(72 to 75)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
					owner.balloon_alert(owner, "Brainstem severelly damaged!")
	to_chat(cortical_owner.human_host, span_warning("Your brain begins to hurt..."))
	var/turf/borer_turf = get_turf(cortical_owner)
	new /obj/effect/decal/cleanable/vomit(borer_turf)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(cortical_owner)] gave birth at [loc_name(borer_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	owner.balloon_alert(owner, "egg laid")
	StartCooldown()

/datum/action/cooldown/borer/produce_offspring/proc/no_host_egg()
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	cortical_owner.health = max(cortical_owner.health, 1, cortical_owner.health -= OUT_OF_HOST_EGG_COST)
	produce_egg()
	var/turf/borer_turf = get_turf(cortical_owner)
	new/obj/effect/decal/cleanable/blood/splatter(borer_turf)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(cortical_owner)] gave birth alone at [loc_name(borer_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	owner.balloon_alert(owner, "egg laid")

/datum/action/cooldown/borer/produce_offspring/proc/produce_egg()
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	var/obj/effect/mob_spawn/ghost_role/borer_egg/spawned_egg = new(cortical_owner.drop_location())
	spawned_egg.generation = (cortical_owner.generation + 1)
	cortical_owner.children_produced++
	if(cortical_owner.children_produced == GLOB.objective_egg_egg_number)
		GLOB.successful_egg_number += 1

#undef OUT_OF_HOST_EGG_COST

/datum/action/cooldown/borer/empowered_offspring
	name = "Produce Empowered Offspring"
	cooldown_time = 1 MINUTES
	button_icon_state = "reproduce"
	chemical_cost = 150
	requires_host = TRUE
	needs_dead_host = TRUE
	ability_explanation = "\
	Implants an egg onto a dead host, the egg will take 3 minutes to hatch and will die if the host gets revived\n\
	If the egg hatches, a massivelly stronger than normal borer will be created. Surpassing all others.\n\
	"

/datum/action/cooldown/borer/empowered_offspring/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(cortical_owner.neutered == TRUE)
		owner.balloon_alert(owner, "You cannot reproduce!")
		return

	cortical_owner.chemical_storage -= chemical_cost
	var/turf/borer_turf = get_turf(cortical_owner)
	var/obj/item/bodypart/chest/chest = cortical_owner.human_host.get_bodypart(BODY_ZONE_CHEST)
	if((!chest || IS_ORGANIC_LIMB(chest)) && !cortical_owner.human_host.get_organ_by_type(/obj/item/organ/internal/empowered_borer_egg))
		var/obj/item/organ/internal/empowered_borer_egg/spawned_egg = new(cortical_owner.human_host)
		spawned_egg.generation = (cortical_owner.generation + 1)

	cortical_owner.children_produced += 1
	if(cortical_owner.children_produced == GLOB.objective_egg_egg_number)
		GLOB.successful_egg_number += 1

	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(cortical_owner)] gave birth to an empowered borer at [loc_name(borer_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.balloon_alert(owner, "egg laid")
	StartCooldown()
