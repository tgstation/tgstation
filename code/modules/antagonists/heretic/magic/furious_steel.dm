/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel"
	sound = 'sound/items/weapons/guillotine.ogg'

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

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
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

/datum/action/cooldown/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/clicker, params, atom/target)
	// Let the caster prioritize using items like guns over blade casts
	if(clicker.get_active_held_item())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(clicker, target) <= 1)
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
		UnregisterSignal(blade_effect, COMSIG_QDELETING)
		UnregisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED)
		QDEL_NULL(blade_effect)

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, projectile_amount, 25, 0.66 SECONDS, projectile_effect)
	RegisterSignal(blade_effect, COMSIG_QDELETING, PROC_REF(on_status_effect_deleted))
	RegisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED, PROC_REF(on_status_effect_triggered))

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(blade_effect)
		UnregisterSignal(blade_effect, COMSIG_QDELETING)
		UnregisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED)
		QDEL_NULL(blade_effect)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	if(isnull(blade_effect) || !current_amount)
		unset_click_ability(owner, refund_cooldown = FALSE)
		return SPELL_CANCEL_CAST

	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN // all CD handling will be done by the status effect being deleted

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
	var/blades_remaining = current_amount
	// Which scales the cooldown according to projectiles remaining
	unset_click_ability(owner, refund_cooldown = FALSE)
	// Snowflake because it does not handle cooldown if we used every projectile
	if(blades_remaining <= 0)
		StartCooldown()

/// Reduce our projectile amount when our blade status effect is triggered
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_triggered(datum/status_effect/protective_blades/source, atom/target)
	SIGNAL_HANDLER

	current_amount--

/obj/projectile/floating_blade
	name = "blade"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	speed = 0.5
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS
	/// Color applied as an outline filter on init
	var/outline_color = "#f8f8ff"

/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = outline_color, "size" = 1))

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

/obj/projectile/floating_blade/haunted
	name = "ritual blade"
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	damage = 35
	wound_bonus = 25
	outline_color = "#D7CBCA"

/datum/action/cooldown/spell/pointed/projectile/furious_steel/solo
	name = "Lesser Furious Steel"
	cooldown_time = 20 SECONDS
	projectile_amount = 1
	active_msg = "You summon forth a blade of furious silver."
	deactive_msg = "You conceal the blade of furious silver."

/datum/action/cooldown/spell/pointed/projectile/furious_steel/haunted
	name = "Cursed Steel"
	desc = "Summon two cursed blades which orbit you. \
		While orbiting you, these blades will protect you from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	background_icon_state = "bg_heretic" // kept intentionally
	overlay_icon_state = "bg_cult_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cursed_steel"
	sound = 'sound/items/weapons/guillotine.ogg'

	cooldown_time = 40 SECONDS
	invocation = "IA!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "You summon forth two cursed blades."
	deactive_msg = "You conceal the cursed blades."
	projectile_amount = 2
	projectile_type = /obj/projectile/floating_blade/haunted
	projectile_effect = /obj/effect/floating_blade/haunted
