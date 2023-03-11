/datum/action/cooldown/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "This spell fires a disk with cosmig energies at a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'sound/magic/cosmig_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 25 SECONDS

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "You prepare to cast your star blast!"
	deactive_msg = "You stop swirling cosmig energies from the palm of your hand... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball

/obj/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	speed = 1
	range = 100
	knockdown = 4 SECONDS
	pixel_speed_multiplier = 0.2
	/// Creates a field to stop people with a star mark.
	var/obj/effect/cosmig_field/cosmig_field
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmig_explosion

/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/star_mark)

/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmig_energy.ogg', 50, FALSE)
	new explosion_effect(get_turf(src))
	cosmig_field = new(get_turf(src))
	return ..()
