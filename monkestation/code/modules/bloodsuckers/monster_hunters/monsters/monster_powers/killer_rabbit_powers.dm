/**
 * Create bunny ability
 * On cast, makes a new rabbit.
 */
/datum/action/cooldown/spell/rabbit_spawn
	name = "Create Offspring"
	button_icon_state = "killer_rabbit"
	desc = "Give birth to a bunch of cute bunnies eager to suicide bomb the nearest enemy!"
	cooldown_time = 3 SECONDS
	button_icon = 'monkestation/icons/bloodsuckers/rabbit.dmi'
	button_icon_state = "killer_rabbit"
	spell_requirements = NONE


/datum/action/cooldown/spell/rabbit_spawn/cast(atom/cast_on)
	. = ..()
	StartCooldown(360 SECONDS, 360 SECONDS)
	for(var/i in 1 to 3)
		var/mob/living/basic/killer_rabbit/rabbit = new(owner.drop_location())
		rabbit.faction = owner.faction.Copy()
	StartCooldown()

/**
 * Rabbit hole creation ability
 * Makes a hole where you use it on.
 */
/datum/action/cooldown/spell/pointed/red_rabbit_hole
	name = "Create Rabbit Hole"
	button_icon_state = "hole_effect_button"
	cooldown_time = 3 SECONDS
	desc = "Trip down enemies through the rabbit holes!"
	button_icon = 'monkestation/icons/bloodsuckers/rabbit.dmi'
	button_icon_state = "hole_effect_button"
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/red_rabbit_hole/is_valid_target(atom/target_atom)
	if(!isfloorturf(target_atom))
		to_chat(owner, span_warning("Holes can only be opened up on floors!"))
		return
	StartCooldown(360 SECONDS, 360 SECONDS)
	new /obj/effect/rabbit_hole/first(target_atom)
	StartCooldown()

/**
 * Charge ability
 */
/datum/action/cooldown/mob_cooldown/charge/rabbit
	destroy_objects = FALSE
	charge_past = 5
	cooldown_time = 3 SECONDS

/**
 * Shotgun blast ability
 */
/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/red_rabbit
	cooldown_time = 3 SECONDS
	projectile_type = /obj/projectile/red_rabbit

/obj/projectile/red_rabbit
	name = "Red Queen"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "locator"
	damage = 20
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	plane = GAME_PLANE
