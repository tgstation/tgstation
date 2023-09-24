/datum/action/cooldown/spell/pointed/projectile/moon_parade
	name = "Lunar parade"
	desc = "This unleashes the parade towards a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "L'N'R P'RAD"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "You prepare to make them join the parade!"
	deactive_msg = "You stop the music and halt tha parade... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/moon_parade


/obj/projectile/magic/moon_parade
	name = "Lunar parade"
	icon_state = "star_ball"
	damage = 0
	damage_type = BURN
	speed = 1
	range = 100
	ricochets_max = 40
	ricochet_chance = 500
	ricochet_incidence_leeway = 0
	pixel_speed_multiplier = 0.2
	projectile_piercing = PASSMOB|PASSVEHICLE


/obj/projectile/magic/moon_parade/Initialize(mapload)
	. = ..()

/obj/projectile/magic/moon_parade/on_hit(atom/hit, pierce_hit)
	. = ..()
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
			visible_message(span_warning("The parade hits [victim] and a sudden wave of clarity comes over you!"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

		//Leashes them to the source projectile with them being able to move maximum 1 tile away from it
		victim.AddComponent(/datum/component/leash, src, distance = 1)
		victim.apply_status_effect(/datum/status_effect/moon_parade_hypnosis)
		victim.balloon_alert(victim,"you feel unable to move away from the parade!")
		victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 80)
		victim.add_mood_event("Moon Insanity", /datum/mood_event/moon_insanity)
		victim.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by lunar parade")
	return PROJECTILE_PIERCE_PHASE

/obj/projectile/magic/moon_parade/Destroy(atom/mob/living/hit)
	if(hit.has_status_effect(/datum/status_effect/moon_parade_hypnosis))
		hit.remove_status_effect(/datum/status_effect/moon_parade_hypnosis)
	return ..()
