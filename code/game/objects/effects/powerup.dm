/obj/effect/powerup
	name = "power-up"
	icon = 'icons/effects/effects.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	/// How long in deciseconds it will take for the powerup to respawn, if no value it won't respawn
	var/respawn_time
	/// How long the powerup stays on the ground, if no value it will stay forever
	var/lifetime
	/// Message given when powerup is picked up
	var/pickup_message
	/// Sound played when powerup is picked up
	var/pickup_sound
	/// Cooldown for the powerup to respawn after it's been used
	COOLDOWN_DECLARE(respawn_cooldown)

/obj/effect/powerup/Initialize()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/powerup/Crossed(atom/movable/movable_atom)
	. = ..()
	trigger(movable_atom)

/obj/effect/powerup/Bump(atom/bumped_atom)
	trigger(bumped_atom)

/obj/effect/powerup/Bumped(atom/movable/movable_atom)
	trigger(movable_atom)

/// Triggers the effect of the powerup on the target, returns FALSE if the target is not /mob/living, is dead or the cooldown hasn't finished, returns TRUE otherwise
/obj/effect/powerup/proc/trigger(mob/living/target)
	if(!istype(target) || target.stat == DEAD)
		return FALSE
	if(respawn_time)
		if(!COOLDOWN_FINISHED(src, respawn_cooldown))
			return FALSE
		COOLDOWN_START(src, respawn_cooldown, respawn_time)
		alpha = 100
		addtimer(VARSET_CALLBACK(src, alpha, initial(alpha)), respawn_time)
	else
		qdel(src)
	if(pickup_message)
		to_chat(target, "<span class='notice'>[pickup_message]</span>")
	if(pickup_sound)
		playsound(get_turf(target), pickup_sound, 50, TRUE, -1)
	return TRUE

/obj/effect/powerup/health
	name = "health pickup"
	desc = "Blessing from the havens."
	icon = 'icons/obj/storage.dmi'
	icon_state = "medicalpack"
	respawn_time = 30 SECONDS
	pickup_message = "Health restored!"
	pickup_sound = 'sound/magic/staff_healing.ogg'
	/// How much the pickup heals when picked up
	var/heal_amount = 50
	/// Does this pickup fully heal when picked up
	var/full_heal = FALSE
	/// If full heal, does this do an admin level heal?
	var/admin_heal = FALSE

/obj/effect/powerup/health/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	if(full_heal)
		target.fully_heal(admin_heal)
	else if(heal_amount)
		target.heal_ordered_damage(heal_amount, list(BRUTE, BURN))

/obj/effect/powerup/health/full
	name = "mega health pickup"
	desc = "Now this is what I'm talking about."
	icon_state = "duffel-med"
	full_heal = TRUE

/obj/effect/powerup/ammo
	name = "ammo pickup"
	desc = "You like revenge, right? Everybody likes revenge! Well, let's go get some!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "ammobox"
	respawn_time = 30 SECONDS
	pickup_message = "Ammunition reloaded!"
	pickup_sound = 'sound/weapons/gun/shotgun/rack.ogg'

/obj/effect/powerup/ammo/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun in target.GetAllContents())
		if(!isgun(gun) && !istype(gun, /obj/item/flamethrower))
			continue
		SEND_SIGNAL(gun, COMSIG_ITEM_RECHARGED)

/obj/effect/powerup/ammo/ctf
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"
	respawn_time = FALSE
	lifetime = 30 SECONDS

/obj/effect/powerup/speed
	name = "Lightning Orb"
	desc = "You feel faster just looking at it."
	icon_state = "electricity2"
	pickup_sound = 'sound/magic/lightningshock.ogg'

/obj/effect/powerup/speed/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	target.apply_status_effect(STATUS_EFFECT_LIGHTNINGORB)

/obj/effect/powerup/mayhem
	name = "Orb of Mayhem"
	desc = "You feel angry just looking at it."
	icon_state = "impact_laser"

/obj/effect/powerup/mayhem/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	target.apply_status_effect(STATUS_EFFECT_MAYHEM)
