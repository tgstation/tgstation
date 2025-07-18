/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 30
	var/converts_living = FALSE

	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id

/obj/item/organ/zombie_infection/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/feel_for_damage(self_aware)
	// keep stealthy for now, revisit later
	return ""

/obj/item/organ/zombie_infection/on_mob_insert(mob/living/carbon/new_owner, special = FALSE, movement_flags)
	. = ..()
	RegisterSignal(new_owner, COMSIG_LIVING_DEATH, PROC_REF(organ_owner_died))
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/on_mob_remove(mob/living/carbon/new_owner, special = FALSE, movement_flags)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(new_owner) && old_species && !special)
		// There isn't a clean way to change species during organ or bodypart removals. In lieau of a beter solution, this will do
		spawn(0)
			new_owner.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)
	UnregisterSignal(new_owner, COMSIG_LIVING_DEATH)

/obj/item/organ/zombie_infection/proc/organ_owner_died(mob/living/carbon/source, gibbed)
	SIGNAL_HANDLER
	if(iszombie(source))
		qdel(src) // Congrats you somehow died so hard you stopped being a zombie

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, span_warning("Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness."))

/obj/item/organ/zombie_infection/process(seconds_per_tick, times_fired)
	if(!owner)
		return
	if(!(src in owner.organs))
		Remove(owner)
	if(owner.mob_biotypes & MOB_MINERAL)//does not process in inorganic things
		return
	if (causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustToxLoss(0.5 * seconds_per_tick)
		if (SPT_PROB(5, seconds_per_tick))
			to_chat(owner, span_danger("You feel sick..."))
	if(timer_id || HAS_TRAIT(owner, TRAIT_SUICIDED) || !owner.get_organ_by_type(/obj/item/organ/brain))
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!iszombie(owner))
		to_chat(owner, span_cult_large("You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!"))
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, PROC_REF(zombify), owner), revive_time, flags)

/obj/item/organ/zombie_infection/proc/zombify(mob/living/carbon/target)
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		target.set_species(/datum/species/zombie/infectious)

	var/stand_up = (target.stat == DEAD) || (target.stat == UNCONSCIOUS)

	//Fully heal the zombie's damage the first time they rise
	if(!target.heal_and_revive(0, span_danger("[target] suddenly convulses, as [target.p_they()][stand_up ? " stagger to [target.p_their()] feet and" : ""] gain a ravenous hunger in [target.p_their()] eyes!")))
		return

	to_chat(target, span_alien("You HUNGER!"))
	to_chat(target, span_alertalien("You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence."))
	playsound(target, 'sound/effects/hallucinations/far_noise.ogg', 50, 1)
	target.do_jitter_animation(living_transformation_time)
	target.Stun(living_transformation_time)

/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE
