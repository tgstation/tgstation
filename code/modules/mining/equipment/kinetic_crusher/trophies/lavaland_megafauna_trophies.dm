//Lavaland megafauna trophies go here.


/**
 * Blood-drunk miner
 * Detonating a mark applies a blood-drunk status effect to the user, absorbing stun effects and
 * reducing ALL incoming damage by 90% for 1 second.
 */
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	denied_types = list(/obj/item/crusher_trophy/miner_eye)

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/blooddrunk)

/**
 * Ash drake
 * Detonating a mark causes any enemies near the user in a 2-tile radius to take fire damage
 * and be pushed away a tile, including the initial mark victim.
 * Any mobs regardless of faction are affected.
 */
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_types = list(/obj/item/crusher_trophy/tail_spike)
	///How much damage does the effect do to an affected mob
	var/blast_damage = 5

/obj/item/crusher_trophy/tail_spike/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_SPELL, blast_damage)

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[blast_damage]</b> damage to nearby creatures and push them back"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/victim in oview(2, user))
		if(victim.stat == DEAD || victim.faction_check_mob(user))
			continue
		playsound(victim, 'sound/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(get_turf(victim))
		addtimer(CALLBACK(src, PROC_REF(pushback), victim, user), 1) //no free backstabs, we push AFTER module stuff is done
		log_combat(user, target, "repelled with a trophy ", src, "crusher damage")
		victim.adjustFireLoss(blast_damage, forced = TRUE)
		SEND_SIGNAL(src, COMSIG_CRUSHER_SPELL_HIT, victim, user, blast_damage)

///Pushes the victim away from the user a single tile
/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

/**
 * Bubblegum
 * Increases melee damage of the crusher and causes crusher melee attacks to heal the user.
 * Detonating a mark quadruples the healing effect.
 */
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_types = list(/obj/item/crusher_trophy/demon_claws)
	///How much extra damage does the trophy grant to the crusher; also affects the healing received on hit
	var/bonus_damage = 10
	///Damage healing order to pass into heal_ordered_damage()
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_damage * 0.2]</b> more damage and heal you for <b>[bonus_damage * 0.1]</b> health, with <b>4X</b> effect on mark detonation"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	target_crusher.force += bonus_damage * 0.2
	target_crusher.detonation_damage += bonus_damage * 0.8
	var/new_wielded_force = 20 + bonus_damage * 0.2
	AddComponent(/datum/component/two_handed, force_unwielded = 0, force_wielded = new_wielded_force)

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(!.)
		return
	target_crusher.force -= bonus_damage * 0.2
	target_crusher.detonation_damage -= bonus_damage * 0.8
	AddComponent(/datum/component/two_handed, force_unwielded = 0, force_wielded = 20)

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_damage * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_damage * 0.4, damage_heal_order)

/**
 * Colossus
 * Detonating a mark causes the next destabilizer shot to deal damage but move slower.
 * The bonus lasts for a single shot and resets after 30 seconds.
 */
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_types = list(/obj/item/crusher_trophy/blaster_tubes)
	///Whether the next destabilizer shot should deal damage or not
	var/deadly_shot = FALSE
	///How much damage does the boosted projectile deal
	var/projectile_damage = 15

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[projectile_damage]</b> damage but move slower"

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(!deadly_shot)
		return
	marker.name = "deadly [marker.name]"
	marker.icon_state = "chronobolt"
	marker.damage = projectile_damage
	marker.speed = 2
	marker.AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_PROJECTILE, projectile_damage)
	deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

///Resets the crusher's mark shot to default, removing the special effects
/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

/**
 * Hierophant
 * Detonating a mark causes a hierophant chaser to appear under the user, dealing damage to the victim and mining terrain.
 */
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	denied_types = list(/obj/item/crusher_trophy/vortex_talisman)
	///Determines the speed of the chaser we produce, in deciseconds; on par with the speed of a chaser the Hierophant boss would spawn when undamaged
	var/crusher_chaser_speed = 3

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a <b>homing hierophant chaser</b>"

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	new /obj/effect/temp_visual/hierophant/chaser/crusher(get_turf(user), user, target, crusher_chaser_speed, TRUE)
	log_combat(user, target, "fired a hierophant chaser at", src)

/obj/effect/temp_visual/hierophant/chaser/crusher
	damage = 20 //the chaser sets damage after the blast's new() and thus the crusher ticker element may get confused
	monster_damage_boost = FALSE
	created_blast = /obj/effect/temp_visual/hierophant/blast/damaging/crusher

/obj/effect/temp_visual/hierophant/blast/damaging/crusher
	damage = 20
	trophy_spawned = TRUE

/obj/effect/temp_visual/hierophant/blast/damaging/crusher/Initialize(mapload, new_caster, friendly_fire)
	. = ..()
	AddComponent(/datum/component/crusher_damage_ticker, APPLY_WITH_SPELL, damage)
