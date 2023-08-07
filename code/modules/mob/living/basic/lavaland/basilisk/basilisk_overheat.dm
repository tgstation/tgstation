/// Status effect gained by basilisks when they touch something hot
/datum/status_effect/basilisk_overheat
	id = "basilisk_overheat"
	duration = 3 MINUTES
	/// What kind of beam do we fire when heated up?
	var/hot_projectiles = /obj/projectile/basilisk_hot
	/// Things which will chill us out if we get hit by them
	var/static/list/chilling_reagents = list(
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/firefighting_foam,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/consumable/ice,
		/datum/reagent/water,
	)

/datum/status_effect/basilisk_overheat/on_creation(mob/living/new_owner, ...)
	if (!istype(new_owner, /mob/living/basic/mining/basilisk))
		return FALSE // Behaviour here is too specific to be reused
	return ..()

/datum/status_effect/basilisk_overheat/on_apply()
	. = ..()
	var/mob/living/basic/mining/basilisk/hot_stuff = owner
	hot_stuff.visible_message(span_warning("[hot_stuff] is getting fired up!"))
	hot_stuff.fully_heal()
	hot_stuff.icon_living = "Basilisk_alert"
	hot_stuff.icon_state = "Basilisk_alert"
	hot_stuff.update_appearance(UPDATE_ICON_STATE)
	hot_stuff.add_movespeed_modifier(/datum/movespeed_modifier/basilisk_overheat)

	hot_stuff.RemoveElement(\
		/datum/element/ranged_attacks,\
		projectiletype = hot_stuff.default_projectile_type,\
		projectilesound = hot_stuff.default_projectile_sound,\
	)
	hot_stuff.AddElement(\
		/datum/element/ranged_attacks,\
		projectiletype = hot_projectiles,\
		projectilesound = hot_stuff.default_projectile_sound,\
	)

	RegisterSignal(hot_stuff, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(hot_stuff, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_splashed))
	RegisterSignal(hot_stuff, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_shot))

/datum/status_effect/basilisk_overheat/on_remove()
	. = ..()
	var/mob/living/basic/mining/basilisk/hot_stuff = owner
	hot_stuff.icon_living = "Basilisk"
	hot_stuff.icon_state = "Basilisk"

	hot_stuff.RemoveElement(\
		/datum/element/ranged_attacks,\
		projectiletype = hot_projectiles,\
		projectilesound = hot_stuff.default_projectile_sound,\
	)
	hot_stuff.AddElement(\
		/datum/element/ranged_attacks,\
		projectiletype = hot_stuff.default_projectile_type,\
		projectilesound = hot_stuff.default_projectile_sound,\
	)

	hot_stuff.update_appearance(UPDATE_ICON_STATE)
	hot_stuff.remove_movespeed_modifier(/datum/movespeed_modifier/basilisk_overheat)
	UnregisterSignal(hot_stuff, list(COMSIG_LIVING_DEATH, COMSIG_ATOM_EXPOSE_REAGENTS, COMSIG_ATOM_BULLET_ACT))

	if (hot_stuff.stat != CONSCIOUS)
		return
	hot_stuff.visible_message(span_notice("[hot_stuff] seems to have cooled down."))
	var/obj/effect/particle_effect/fluid/smoke/poof = new(get_turf(hot_stuff))
	poof.lifetime = 2 SECONDS

/// Cool down if we die
/datum/status_effect/basilisk_overheat/proc/on_death()
	SIGNAL_HANDLER
	qdel(src)

/// Cool down if splashed with water
/datum/status_effect/basilisk_overheat/proc/on_splashed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(!(methods & (TOUCH|VAPOR)))
		return
	for (var/datum/reagent in reagents)
		if (!is_type_in_list(reagent, chilling_reagents))
			continue
		qdel(src)
		return

/// Cool down if shot with a cryo beam
/datum/status_effect/basilisk_overheat/proc/on_shot(datum/source, obj/projectile/temp/cryo_shot)
	SIGNAL_HANDLER
	if (!istype(cryo_shot) || cryo_shot.temperature > 0)
		return
	qdel(src)

/// Projectile basilisks use when hot
/obj/projectile/basilisk_hot
	name = "energy blast"
	icon_state= "chronobolt"
	damage = 40
	damage_type = BRUTE
