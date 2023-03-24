/datum/action/cooldown/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "This spell fires a disk with cosmic energies at a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 25 SECONDS

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "You prepare to cast your star blast!"
	deactive_msg = "You stop swirling cosmic energies from the palm of your hand... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball

/obj/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	speed = 1
	range = 100
	knockdown = 4 SECONDS
	pixel_speed_multiplier = 0.2
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion

/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target) && !istype(target, /mob/living/basic/star_gazer))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/star_mark)

/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	new /obj/effect/forcefield/cosmic_field(get_turf(src))
	return ..()
