/obj/effect/proc_holder/spell/aimed/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "furious_steel0"
	action_background_icon_state = "bg_ecult"
	base_icon_state = "furious_steel"
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	charge_max = 30 SECONDS
	range = 20
	projectile_amount = 3
	projectiles_per_fire = 1
	projectile_type = /obj/projectile/floating_blade
	sound = 'sound/weapons/guillotine.ogg'
	active_msg = "You summon forth three blades of furious silver."
	deactive_msg = "You conceal the blades of furious silver."
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/obj/effect/proc_holder/spell/aimed/furious_steel/Destroy()
	QDEL_NULL(blade_effect)
	return ..()

/obj/effect/proc_holder/spell/aimed/furious_steel/on_activation(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	// Aimed spells snowflake and activate without checking cast_check, very cool
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(living_user)
	if(our_heretic && !our_heretic.ascended && !HAS_TRAIT(living_user, TRAIT_ALLOW_HERETIC_CASTING))
		user.balloon_alert(living_user, "you need a focus!")
		return
	// Delete existing
	if(blade_effect)
		QDEL_NULL(blade_effect)

	. = ..()
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, 3, 25, 0.66 SECONDS)
	RegisterSignal(blade_effect, COMSIG_PARENT_QDELETING, .proc/on_status_effect_deleted)

/obj/effect/proc_holder/spell/aimed/furious_steel/cast_check(skipcharge = 0,mob/user = usr)
	. = ..()
	if(!.)
		// We shouldn't cast for some reason, likely due to losing our focus - delete the blades
		QDEL_NULL(blade_effect)

/obj/effect/proc_holder/spell/aimed/furious_steel/on_deactivation(mob/user)
	. = ..()
	QDEL_NULL(blade_effect)

/obj/effect/proc_holder/spell/aimed/furious_steel/InterceptClickOn(mob/living/caller, params, atom/target)
	if(get_dist(caller, target) <= 1) // Let the caster prioritize melee attacks over blade casts
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/aimed/furious_steel/cast(list/targets, mob/living/user)
	if(isnull(blade_effect) || !length(blade_effect.blades))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/aimed/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)

/obj/effect/proc_holder/spell/aimed/furious_steel/fire_projectile(mob/living/user, atom/target)
	. = ..()
	qdel(blade_effect.blades[1])

/obj/effect/proc_holder/spell/aimed/furious_steel/proc/on_status_effect_deleted(datum/source)
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

	return ..()
