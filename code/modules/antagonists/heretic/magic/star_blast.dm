/datum/action/cooldown/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "This spell fires an unstoppable disk with cosmic energies at a target, spreading the star mark. \
			When recasted, you will be teleported to the disk, and cosmic fields will generate from the disk and from the caster, pulling nearby heathens into it."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'sound/effects/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 SECONDS // Cooldown is tied to teleportation, not firing

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "You prepare to cast your star blast!"
	deactive_msg = "You stop swirling cosmic energies from the palm of your hand... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball
	/// Weakref to the projectile we fire, so that we can recast our ability to teleport to its location
	var/datum/weakref/projectile_weakref
	/// Weakref to our summoner, only relevant if we are a stargazer. Prevents us from harming our master
	var/datum/weakref/summoner

/datum/action/cooldown/spell/pointed/projectile/star_blast/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	projectile_weakref = WEAKREF(to_fire)
	to_fire.AddElement(cosmic_trail_based_on_passive(user), /obj/effect/forcefield/cosmic_field/fast)

/datum/action/cooldown/spell/pointed/projectile/star_blast/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	var/obj/projectile/magic/star_ball/active_ball = projectile_weakref?.resolve()
	if(!active_ball)
		return ..()

	// Means we have a ball active so we'll put a border indicating you can re-cast it
	current_button.cut_overlay(current_button.button_overlay)
	current_button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = "bg_spell_border_active_green")
	current_button.add_overlay(current_button.button_overlay)

/datum/action/cooldown/spell/pointed/projectile/star_blast/set_click_ability(mob/on_who)
	var/obj/projectile/magic/star_ball/active_ball = projectile_weakref?.resolve()
	if(!active_ball)
		build_all_button_icons(UPDATE_OVERLAYS)
		return ..()

	pull_victims()
	do_teleport(owner, active_ball)
	pull_victims() // Yes, this is intentional, we want to pull mobs from the place we were, and the place we've teleported to
	QDEL_NULL(active_ball)
	build_all_button_icons(UPDATE_OVERLAYS)
	// Cooldown of the ability itself is only 1 second after shooting, it's 25 seconds after we teleport to our ball
	StartCooldown(25 SECONDS)

/datum/action/cooldown/spell/pointed/projectile/star_blast/proc/pull_victims()
	new /obj/effect/temp_visual/circle_wave/star_blast(get_turf(owner))
	for(var/turf/spawn_turf in range(1, get_turf(owner)))
		if(spawn_turf.density)
			continue
		create_cosmic_field(spawn_turf, owner, /obj/effect/forcefield/cosmic_field/star_blast)
	for(var/mob/living/nearby_mob in view(2, owner))
		if(nearby_mob == owner || nearby_mob == summoner?.resolve())
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue
		for(var/i in 1 to 3)
			nearby_mob.forceMove(get_step_towards(nearby_mob, owner))
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)

/datum/action/cooldown/spell/pointed/projectile/star_blast/after_cast(atom/cast_on)
	. = ..()
	unset_click_ability(owner) // Unselect because we will re-select it to teleport

/obj/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 0
	speed = 0.2
	range = 25
	knockdown = 4 SECONDS
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSBLOB | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSDOORS | PASSVEHICLE | PASSITEM | PASSWINDOW
	projectile_piercing = PASSMOB | PASSVEHICLE
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3

/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob || cast_on.buckled == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)

/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
	return ..()
