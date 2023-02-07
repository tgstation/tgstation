/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel"
	sound = 'sound/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "You summon forth three blades of furious silver."
	deactive_msg = "You conceal the blades of furious silver."
	cast_range = 20
	projectile_type = /obj/projectile/floating_blade
	projectile_amount = 3

	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/datum/action/cooldown/spell/pointed/projectile/furious_steel/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return

	if(IS_HERETIC(owner))
		RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))

/datum/action/cooldown/spell/pointed/projectile/furious_steel/Remove(mob/remove_from)
	UnregisterSignal(remove_from, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	return ..()

/// Signal proc for [SIGNAL_REMOVETRAIT], via [TRAIT_ALLOW_HERETIC_CASTING], to remove the effect when we lose the focus trait
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_focus_lost(mob/source)
	SIGNAL_HANDLER

	unset_click_ability(source, refund_cooldown = TRUE)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/caller, params, atom/click_target)
	// Let the caster prioritize using items like guns over blade casts
	if(caller.get_active_held_item())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(caller, click_target) <= 1)
		return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return
	// Delete existing
	if(blade_effect)
		stack_trace("[type] had an existing blade effect in on_activation. This might be an exploit, and should be investigated.")
		UnregisterSignal(blade_effect, COMSIG_PARENT_QDELETING)
		QDEL_NULL(blade_effect)

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, projectile_amount, 25, 0.66 SECONDS)
	RegisterSignal(blade_effect, COMSIG_PARENT_QDELETING, PROC_REF(on_status_effect_deleted))

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	QDEL_NULL(blade_effect)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	if(isnull(blade_effect) || !length(blade_effect.blades))
		unset_click_ability(owner, refund_cooldown = TRUE)
		return SPELL_CANCEL_CAST

	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/fire_projectile(mob/living/user, atom/target)
	. = ..()
	qdel(blade_effect.blades[1])

/datum/action/cooldown/spell/pointed/projectile/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)

/// If our blade status effect is deleted, clear our refs and deactivate
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	on_deactivation()

/obj/projectile/floating_blade
	name = "blade"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	speed = 2
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS

/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("knife", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))

/obj/projectile/floating_blade/prehit_pierce(atom/hit)
	if(isliving(hit) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = hit
		if(caster == victim)
			return PROJECTILE_PIERCE_PHASE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return PROJECTILE_PIERCE_PHASE

		if(victim.can_block_magic(MAGIC_RESISTANCE))
			visible_message(span_warning("[src] drops to the ground and melts on contact [victim]!"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

	return ..()
