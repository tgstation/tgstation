/// Status effect gained by basilisks when they touch something hot
/datum/status_effect/basilisk_overheat
	id = "basilisk_overheat"
	duration = 3 MINUTES
	alert_type = null
	/// Things which will chill us out if we get hit by them
	var/static/list/chilling_reagents = list(
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/firefighting_foam,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/consumable/ice,
		/datum/reagent/water,
	)

/datum/status_effect/basilisk_overheat/on_apply()
	. = ..()
	if (!. || !istype(owner, /mob/living/basic/mining/basilisk) || owner.stat != CONSCIOUS)
		return FALSE
	var/mob/living/basic/mining/basilisk/hot_stuff = owner
	hot_stuff.visible_message(span_warning("[hot_stuff] is getting fired up!"))
	hot_stuff.fully_heal()
	hot_stuff.icon_living = "basilisk_alert"
	hot_stuff.icon_state = "basilisk_alert"
	hot_stuff.update_appearance(UPDATE_ICON_STATE)
	hot_stuff.add_movespeed_modifier(/datum/movespeed_modifier/basilisk_overheat)
	hot_stuff.set_projectile_type(/obj/projectile/basilisk_hot)

	RegisterSignal(hot_stuff, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(hot_stuff, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_splashed))
	RegisterSignal(hot_stuff, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_shot))

/datum/status_effect/basilisk_overheat/on_remove()
	. = ..()
	var/mob/living/basic/mining/basilisk/hot_stuff = owner
	hot_stuff.icon_living = "basilisk"
	hot_stuff.icon_state = "basilisk"
	hot_stuff.set_projectile_type(/obj/projectile/temp/watcher)

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
/datum/status_effect/basilisk_overheat/proc/on_splashed(atom/source, list/reagents, datum/reagents/source_reagents, methods, show_message)
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
	icon_state = "chronobolt"
	damage = 40
	damage_type = BRUTE
