/obj/effect/powerup
	name = "power-up"
	icon = 'icons/effects/effects.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/respawning = FALSE
	var/respawn_time
	var/lifetime
	var/pickup_message
	var/pickup_sound
	COOLDOWN_DECLARE(respawn_cooldown)

/obj/effect/powerup/Initialize()
	..()
	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/powerup/Crossed(atom/movable/AM)
	. = ..()
	trigger(AM)

/obj/effect/powerup/Bump(atom/A)
	trigger(A)

/obj/effect/powerup/Bumped(atom/movable/AM)
	trigger(AM)

/obj/effect/powerup/proc/trigger(mob/living/M)
	if(respawning)
		if(!COOLDOWN_FINISHED(src, respawn_cooldown))
			return FALSE
		COOLDOWN_START(src, respawn_cooldown, respawn_time)
		alpha = 100
		addtimer(VARSET_CALLBACK(src, alpha, initial(alpha)), respawn_time)
	else
		qdel(src)
	if(pickup_message)
		to_chat(M, "<span class='notice'>[pickup_message]</span>")
	if(pickup_sound)
		playsound(get_turf(M), pickup_sound, 50, TRUE, -1)
	return TRUE

/obj/effect/powerup/health
	name = "health pickup"
	desc = "Blessing from the havens."
	icon = 'icons/obj/storage.dmi'
	icon_state = "medicalpack"
	respawning = TRUE
	respawn_time = 30 SECONDS
	pickup_message = "Health restored!"
	pickup_sound = 'sound/magic/staff_healing.ogg'
	var/heal_amount = 50
	var/full_heal = FALSE

/obj/effect/powerup/health/trigger(mob/living/M)
	. = ..()
	if(!.)
		return
	if(full_heal)
		M.fully_heal()
	else if(heal_amount)
		M.heal_ordered_damage(heal_amount, list(BRUTE, BURN))

/obj/effect/powerup/health/full
	name = "mega health pickup"
	desc = "Now this is what I'm talking about."
	icon_state = "duffel-med"
	full_heal = TRUE

/obj/effect/powerup/ammo
	name = "ammo pickup"
	desc = "You like revenge, right? Everybody likes revenge! Well, \
		let's go get some!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "ammobox"
	respawning = TRUE
	respawn_time = 30 SECONDS
	pickup_message = "Ammunition reloaded!"
	pickup_sound = 'sound/weapons/gun/shotgun/rack.ogg'

/obj/effect/powerup/ammo/trigger(mob/living/M)
	. = ..()
	if(!.)
		return
	var/gear_list = M.GetAllContents()
	for(var/obj/item/gun/magic/wand in gear_list)
		wand.charges = wand.max_charges
		wand.recharge_newshot()
		wand.update_icon()
	for(var/obj/item/gun/energy/energygun in gear_list)
		if(energygun.cell)
			var/obj/item/stock_parts/cell/battery = energygun.cell
			battery.charge = battery.maxcharge
			energygun.update_icon()
	for(var/obj/item/gun/ballistic/realgun in gear_list)
		if(realgun.mag_type)
			qdel(realgun.magazine)
			realgun.magazine = new realgun.mag_type(realgun)
			realgun.chamber_round()
			realgun.update_icon()

/obj/effect/powerup/ammo/ctf
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"
	respawning = FALSE
	lifetime = 30 SECONDS

/obj/effect/powerup/speed
	name = "Lightning Orb"
	desc = "You feel faster just looking at it."
	icon_state = "electricity2"
	pickup_sound = 'sound/magic/lightningshock.ogg'

/obj/effect/powerup/speed/trigger(mob/living/M)
	. = ..()
	if(!.)
		return
	M.apply_status_effect(STATUS_EFFECT_LIGHTNINGORB)

/obj/effect/powerup/mayhem
	name = "Orb of Mayhem"
	desc = "You feel angry just looking at it."
	icon_state = "impact_laser"

/obj/effect/powerup/mayhem/trigger(mob/living/M)
	. = ..()
	if(!.)
		return
	M.apply_status_effect(STATUS_EFFECT_MAYHEM)
