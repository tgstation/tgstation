/datum/action/cooldown/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that summons copies of you. \
			If any copies are attacked, they cause brain damage, sanity damage, and will briefly stun everyone nearby."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MIND
	invocation = "R'S 'E!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/action/cooldown/spell/aoe/moon_ringleader/cast(mob/living/caster)
	new moon_effect(get_turf(caster))
	caster.faction |= "ringleader([REF(caster)])"
	return ..()

/datum/action/cooldown/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(issilicon(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/datum/action/cooldown/spell/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	var/mob/living/simple_animal/hostile/illusion/fake_clone = new(pick(RANGE_TURFS(2, victim)))
	fake_clone.faction = caster.faction.Copy()
	fake_clone.Copy_Parent(caster, 30 SECONDS, caster.health, 1, 0, "shove_mode")
	fake_clone.GiveTarget(victim)
	fake_clone.AddElement(/datum/element/relay_attackers)
	RegisterSignal(fake_clone, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/// Used by Ringleaders Rise, illusions created by this spell will explode when they are interacted with
/datum/action/cooldown/spell/aoe/moon_ringleader/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	if(isliving(attacker))
		var/mob/living/living_attacker = attacker
		if(IS_HERETIC_OR_MONSTER(living_attacker)) // Heretics cant smack these guys to trigger their effects
			return
	playsound(victim, 'sound/items/party_horn.ogg', 30)
	new /obj/effect/decal/cleanable/confetti(get_turf(victim))

	for(var/mob/living/mob in range(3, victim))
		if(IS_HERETIC_OR_MONSTER(mob))
			continue
		if(mob.can_block_magic(antimagic_flags))
			continue

		//If our moon heretic has their level 3 passive, we channel the amulet effect
		var/mob/living/simple_animal/hostile/illusion/fake_clone = victim
		var/mob/living/living_owner = fake_clone.parent_mob_ref.resolve()
		if(!living_owner)
			continue
		var/datum/status_effect/heretic_passive/moon/our_passive = living_owner.has_status_effect(/datum/status_effect/heretic_passive/moon)
		// We channel the amulet before the "spell effects" so that people don't get converted after 1 clone goes off
		our_passive.amulet?.channel_amulet(living_owner, mob)

		mob.AdjustStun(1 SECONDS)
		mob.AdjustKnockdown(1 SECONDS)
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 150)
		mob.mob_mood?.adjust_sanity(-50)

	qdel(victim)

/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
