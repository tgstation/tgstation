/mob/living/basic/netherworld/creature
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 50
	maxHealth = 50
	melee_damage_lower = 20
	melee_damage_upper = 30
	speed = 2
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	gold_core_spawnable = HOSTILE_SPAWN
	var/is_phased = FALSE

/mob/living/basic/netherworld/creature/Initialize(mapload)
	. = ..()
	var/datum/action/innate/creature/teleport/teleport = new(src)
	teleport.Grant(src)

/mob/living/basic/netherworld/creature/health_full_behaviour()
	melee_damage_lower = 20
	melee_damage_upper = 30
	set_varspeed(2)

/mob/living/basic/netherworld/creature/health_high_behaviour()
	melee_damage_lower = 25
	melee_damage_upper = 40
	set_varspeed(1.5)

/mob/living/basic/netherworld/creature/health_medium_behaviour()
	melee_damage_lower = 30
	melee_damage_upper = 50
	set_varspeed(1)

/mob/living/basic/netherworld/creature/health_low_behaviour()
	melee_damage_lower = 35
	melee_damage_upper = 60
	set_varspeed(0.5)

/mob/living/basic/netherworld/creature/proc/can_be_seen(turf/location)
	// Check for darkness
	if(location?.lighting_object)
		if(location.get_lumcount()<0.1) // No one can see us in the darkness, right?
			return null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(location)
		check_list += location

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/mob_target in oview(src, 7)) // They probably cannot see us if we cannot see them... can they?
			if(mob_target.client && !mob_target.is_blind() && !mob_target.has_unlimited_silicon_privilege)
				return mob_target
		for(var/obj/vehicle/sealed/mecha/M in oview(src, 7))
			for(var/mob/mechamob_target as anything in M.occupants)
				if(mechamob_target.client && !mechamob_target.is_blind())
					return mechamob_target
	return null

/datum/action/innate/creature
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"

/datum/action/innate/creature/teleport
	name = "Teleport"
	desc = "Teleport to wherever you want, as long as you aren't seen."

/datum/action/innate/creature/teleport/Activate()
	var/mob/living/basic/netherworld/creature/owner_mob = owner
	var/obj/effect/dummy/phased_mob/holder = null
	if(owner_mob.stat == DEAD)
		return
	var/turf/owner_turf = get_turf(owner_mob)
	if (owner_mob.can_be_seen(owner_turf) || !do_after(owner_mob, 60, target = owner_turf))
		to_chat(owner_mob, span_warning("You can't phase in or out while being observed and you must stay still!"))
		return
	if (get_dist(owner_mob, owner_turf) != 0 || owner_mob.can_be_seen(owner_turf))
		to_chat(owner_mob, span_warning("Action cancelled, as you moved while reappearing or someone is now viewing your location."))
		return
	if(owner_mob.is_phased)
		holder = owner_mob.loc
		holder.eject_jaunter()
		holder = null
		owner_mob.is_phased = FALSE
		playsound(get_turf(owner_mob), 'sound/effects/podwoosh.ogg', 50, TRUE, -1)
	else
		playsound(get_turf(owner_mob), 'sound/effects/podwoosh.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(owner_turf, owner_mob)
		owner_mob.is_phased = TRUE
