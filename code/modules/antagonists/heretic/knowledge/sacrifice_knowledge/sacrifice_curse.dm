/// A curse given to people to disencourage them from retaliating against someone who sacrificed them
/datum/status_effect/heretic_curse
	id = "heretic_curse"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE // In case several different people sacrifice you, unlucky
	/// Who cursed us?
	var/mob/living/the_curser
	/// Don't experience bad things too often
	COOLDOWN_DECLARE(consequence_cooldown)

/datum/status_effect/heretic_curse/on_creation(mob/living/new_owner, mob/living/the_curser)
	src.the_curser = the_curser
	return ..()

/datum/status_effect/heretic_curse/Destroy()
	the_curser = null
	return ..()

/datum/status_effect/heretic_curse/on_apply()
	if (isnull(the_curser) || !iscarbon(owner))
		return FALSE

	the_curser.AddElement(/datum/element/relay_attackers)
	RegisterSignal(the_curser, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_curser_attacked))
	RegisterSignal(the_curser, COMSIG_QDELETING, PROC_REF(on_curser_destroyed))

	owner.AddElement(/datum/element/relay_attackers)
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_owner_attacked))

	return TRUE

/datum/status_effect/heretic_curse/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED)
	UnregisterSignal(the_curser, COMSIG_ATOM_WAS_ATTACKED)
	the_curser = null


/// If the heretic that cursed us is destroyed this thing is useless now
/datum/status_effect/heretic_curse/proc/on_curser_destroyed()
	SIGNAL_HANDLER
	qdel(src)

/// If we attack the guy who cursed us, that's no good
/datum/status_effect/heretic_curse/proc/on_curser_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if (attacker != owner || !HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return
	log_combat(owner, the_curser, "attacked", addition = "and lost some organs because they had previously been sacrificed by them.")
	experience_the_consequences()

/// If we are attacked by the guy who cursed us, that's also no good
/datum/status_effect/heretic_curse/proc/on_owner_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if (attacker != the_curser || !HAS_TRAIT(attacker, TRAIT_ALLOW_HERETIC_CASTING))
		return
	log_combat(the_curser, owner, "attacked", addition = "and as they had previously sacrificed them, removed some of their organs.")
	experience_the_consequences()

/// Experience something you may not enjoy which may also significantly shorten your lifespan
/datum/status_effect/heretic_curse/proc/experience_the_consequences()
	if (!COOLDOWN_FINISHED(src, consequence_cooldown) || owner.stat != CONSCIOUS)
		return

	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/bodypart/chest/organ_storage = owner.get_bodypart(BODY_ZONE_CHEST)
	if (isnull(organ_storage))
		carbon_owner.gib() // IDK how you don't have a chest but you're not getting away that easily
		return

	var/list/removable_organs = list()
	for(var/obj/item/organ/internal/bodypart_organ in organ_storage.contents)
		if(bodypart_organ.organ_flags & ORGAN_UNREMOVABLE)
			continue
		removable_organs += bodypart_organ

	if (!length(removable_organs))
		return // This one is a little more possible but they're probably already in pretty bad shape by this point

	var/obj/item/organ/internal/removing_organ = pick(removable_organs)

	if (carbon_owner.vomit(vomit_flags = VOMIT_CATEGORY_BLOOD))
		carbon_owner.visible_message(span_boldwarning("[carbon_owner] vomits out [carbon_owner.p_their()] [removing_organ]"))
	else
		carbon_owner.visible_message(span_boldwarning("[carbon_owner]'s [removing_organ] rips itself out of `[carbon_owner.p_their()] chest!"))

	removing_organ.Remove(carbon_owner)

	var/turf/land_turf = get_step(carbon_owner, carbon_owner.dir)
	if (land_turf.is_blocked_turf(exclude_mobs = TRUE))
		land_turf = carbon_owner.drop_location()

	removing_organ.forceMove(land_turf)
	COOLDOWN_START(src, consequence_cooldown, 10 SECONDS)
