
/datum/action/cooldown/spell/pointed/projectile/spell_cards
	name = "Spell Cards"
	desc = "Blazing hot rapid-fire homing cards. Send your foes to the shadow realm with their mystical power!"
	button_icon_state = "spellcard0"
	click_cd_override = 1

	school = SCHOOL_EVOCATION
	cooldown_time = 5 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS

	invocation = "Sigi'lu M'Fan 'Tasia!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	cast_range = 40
	projectile_type = /obj/projectile/magic/spellcard
	projectile_amount = 5
	projectiles_per_fire = 7

	/// A weakref to the mob we're currently targeting with the lockon component.
	var/datum/weakref/current_target_weakref
	/// The turn rate of the spell cards in flight. (They track onto locked on targets)
	var/projectile_turnrate = 10
	/// The homing spread of the spell cards in flight.
	var/projectile_pixel_homing_spread = 32
	/// The initial spread of the spell cards when fired.
	var/projectile_initial_spread_amount = 30
	/// The location spread of the spell cards when fired.
	var/projectile_location_spread_amount = 12
	/// A ref to our lockon component, which is created and destroyed on activation and deactivation.
	var/datum/component/lockon_aiming/lockon_component

/datum/action/cooldown/spell/pointed/projectile/spell_cards/Destroy()
	QDEL_NULL(lockon_component)
	return ..()

/datum/action/cooldown/spell/pointed/projectile/spell_cards/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	QDEL_NULL(lockon_component)
	lockon_component = owner.AddComponent( \
		/datum/component/lockon_aiming, \
		range = 5, \
		typecache = GLOB.typecache_living, \
		amount = 1, \
		when_locked = CALLBACK(src, PROC_REF(on_lockon_component)))

/datum/action/cooldown/spell/pointed/projectile/spell_cards/proc/on_lockon_component(list/locked_weakrefs)
	if(!length(locked_weakrefs))
		current_target_weakref = null
		return
	current_target_weakref = locked_weakrefs[1]
	var/atom/real_target = current_target_weakref.resolve()
	if(real_target)
		owner.face_atom(real_target)

/datum/action/cooldown/spell/pointed/projectile/spell_cards/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	QDEL_NULL(lockon_component)

/datum/action/cooldown/spell/pointed/projectile/spell_cards/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(current_target_weakref)
		var/atom/real_target = current_target_weakref?.resolve()
		if(real_target && get_dist(real_target, user) < 7)
			to_fire.homing_turn_speed = projectile_turnrate
			to_fire.homing_inaccuracy_min = projectile_pixel_homing_spread
			to_fire.homing_inaccuracy_max = projectile_pixel_homing_spread
			to_fire.set_homing_target(real_target)

	var/rand_spr = rand()
	var/total_angle = projectile_initial_spread_amount * 2
	var/adjusted_angle = total_angle - ((projectile_initial_spread_amount / projectiles_per_fire) * 0.5)
	var/one_fire_angle = adjusted_angle / projectiles_per_fire
	var/current_angle = iteration * one_fire_angle * rand_spr - (projectile_initial_spread_amount / 2)

	to_fire.pixel_x = rand(-projectile_location_spread_amount, projectile_location_spread_amount)
	to_fire.pixel_y = rand(-projectile_location_spread_amount, projectile_location_spread_amount)
	to_fire.preparePixelProjectile(target, user, null, current_angle)
