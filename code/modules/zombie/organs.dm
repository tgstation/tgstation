/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/living_transformation_time = 3 SECONDS
	var/converts_living = FALSE

	var/revive_time_min = 45 SECONDS
	var/revive_time_max = 70 SECONDS
	var/timer_id

	var/datum/weakref/ghost_poll

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
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/on_mob_remove(mob/living/carbon/new_owner, special = FALSE, movement_flags)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(timer_id)
		deltimer(timer_id)
	QDEL_NULL(ghost_poll)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, span_warning("Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness."))

/obj/item/organ/zombie_infection/process(seconds_per_tick)
	if(!owner)
		return
	if(!(src in owner.organs))
		Remove(owner)
	if(!(owner.mob_biotypes & MOB_ORGANIC) || HAS_TRAIT(owner, TRAIT_UNHUSKABLE)) // does not process in inorganic things
		return
	if (causes_damage && !owner.has_status_effect(/datum/status_effect/zombie) && owner.stat != DEAD)
		owner.adjust_tox_loss(0.5 * seconds_per_tick)
		if (SPT_PROB(5, seconds_per_tick))
			to_chat(owner, span_danger("You feel sick..."))
	if(timer_id || HAS_TRAIT(owner, TRAIT_SUICIDED) || !owner.get_organ_by_type(/obj/item/organ/brain))
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!owner.has_status_effect(/datum/status_effect/zombie))
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

	// mindless zombies are nerfed a bit to encourage infecting real players instead of random morgue bodies
	target.apply_status_effect(isnull(target.mind) ? /datum/status_effect/zombie/mindless : /datum/status_effect/zombie)

	var/stand_up = IS_UNCONSCIOUS(target)

	//Fully heal the zombie's damage the first time they rise
	if(!target.heal_and_revive(0, span_danger("[target] suddenly convulses, as [target.p_they()][stand_up ? " stagger to [target.p_their()] feet and" : ""] gain a ravenous hunger in [target.p_their()] eyes!")))
		return

	zombie_welcome(target)
	if(target.mind || target.client)
		if(stand_up)
			target.get_up()
		return

	ghost_poll = WEAKREF(target.AddComponent( \
		/datum/component/ghost_direct_control, \
		ban_type = NONE, \
		poll_ignore_key = POLL_IGNORE_RECOVERED_CREW, \
		poll_question = "Do you want to be a [span_green("[isnull(target.mind) ? "mindless zombie" : "zombie"]")]?", \
		role_name = "zombie", \
		extra_control_checks = CALLBACK(src, PROC_REF(check_ghost_control_eligibility)), \
		after_assumed_control = CALLBACK(src, PROC_REF(after_ghost_control)), \
		joinable_mobs_title = "Zombies", \
	))
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_TOMBSTONE] = TRUE

/obj/item/organ/zombie_infection/proc/check_ghost_control_eligibility(mob/candidate)
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	if(!owner.has_status_effect(/datum/status_effect/zombie) || owner.stat == DEAD)
		return FALSE
	return TRUE

/obj/item/organ/zombie_infection/proc/after_ghost_control(mob/candidate)
	owner.Knockdown(living_transformation_time)
	zombie_welcome(owner)
	ghost_poll = null

/obj/item/organ/zombie_infection/proc/zombie_welcome(mob/living/carbon/new_zombie)
	if(new_zombie.client)
		to_chat(new_zombie, span_alien("You HUNGER!"))
		to_chat(new_zombie, span_alertalien("You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence."))
		playsound(new_zombie, 'sound/effects/hallucinations/far_noise.ogg', 50, 1)

	new_zombie.do_jitter_animation(living_transformation_time)
	new_zombie.Stun(living_transformation_time)

/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE
