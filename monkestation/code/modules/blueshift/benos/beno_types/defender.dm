

/mob/living/carbon/alien/adult/nova/defender
	name = "alien defender"
	desc = "A heavy looking alien with a wrecking ball-like tail that'd probably hurt to get hit by."
	caste = "defender"
	maxHealth = 300
	health = 300
	icon_state = "aliendefender"
	melee_damage_lower = 25
	melee_damage_upper = 30
	next_evolution = /mob/living/carbon/alien/adult/nova/warrior

/mob/living/carbon/alien/adult/nova/defender/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep,
		/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_heavy)

/mob/living/carbon/alien/adult/nova/defender/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel/small
	..()

/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep
	name = "Crushing Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail, likely breaking some bones in the process."

	cooldown_time = 60 SECONDS

	aoe_radius = 1

	button_icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	button_icon_state = "crush_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/defender

	/// The sound that the tail sweep will make upon hitting something
	var/impact_sound = 'sound/effects/clang.ogg'
	/// How long mobs hit by the tailsweep should be knocked down for
	var/knockdown_time = 4 SECONDS
	/// How much damage tail sweep impacts should do to a mob
	var/impact_damage = 30
	/// What wound bonus should the tai sweep impact have
	var/impact_wound_bonus = 20
	/// What type of sharpness should this tail sweep have
	var/impact_sharpness = FALSE
	/// What type of damage should the tail sweep do
	var/impact_damage_type = BRUTE

/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/alien/adult/nova/owner_alien = owner
	if(!istype(owner_alien) || owner_alien.unable_to_use_abilities)
		return FALSE

/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(!isliving(victim))
		return

	if(isalien(victim))
		return

	var/turf/throwtarget = get_edge_target_turf(caster, get_dir(caster, get_step_away(victim, caster)))
	var/dist_from_caster = get_dist(victim, caster)
	var/mob/living/victim_living = victim

	if(dist_from_caster <= 0)
		victim_living.Knockdown(knockdown_time)
		if(sparkle_path)
			new sparkle_path(get_turf(victim_living), get_dir(caster, victim_living))

	else
		victim_living.Knockdown(knockdown_time * 2) //They are on the same turf as us, or... somewhere else, I'm not sure how but they are getting smacked down

	victim_living.apply_damage(impact_damage, impact_damage_type, BODY_ZONE_CHEST, wound_bonus = impact_wound_bonus, sharpness = impact_sharpness)
	shake_camera(victim_living, 4, 3)
	playsound(victim_living, impact_sound, 100, TRUE, 8, 0.9)
	to_chat(victim_living, span_userdanger("[caster]'s tail slams into you, throwing you back!"))

	victim_living.safe_throw_at(throwtarget, ((clamp((max_throw - (clamp(dist_from_caster - 2, 0, dist_from_caster))), 3, max_throw))), 1, caster, force = repulse_force)

/obj/effect/temp_visual/dir_setting/tailsweep/defender
	icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	icon_state = "crush_tail_anim"

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender
	name = "Charge Attack"
	desc = "Allows you to charge at a position, trampling anything in your path."
	cooldown_time = 15 SECONDS
	charge_delay = 0.3 SECONDS
	charge_distance = 5
	destroy_objects = FALSE
	charge_damage = 50
	button_icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	button_icon_state = "defender_charge"
	unset_after_click = TRUE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender/do_charge_indicator(atom/charger, atom/charge_target)
	. = ..()
	playsound(charger, 'monkestation/code/modules/blueshift/sounds/alien_roar1.ogg', 100, TRUE, 8, 0.9)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender/Activate(atom/target_atom)
	. = ..()
	return TRUE
