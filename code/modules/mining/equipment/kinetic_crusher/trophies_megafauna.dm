/*!
 * Contains crusher trophies you can obtain from megafauna
 */

//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	trophy_id = TROPHY_MINER_EYE
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	user.apply_status_effect(/datum/status_effect/blooddrunk)

//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/tail_spike
	trophy_id = TROPHY_TAIL_SPIKE
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> damage to nearby creatures and push them back"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	for(var/mob/living/living_target in oview(2, user))
		if(user.faction_check_atom(living_target) || living_target.stat == DEAD)
			continue
		playsound(living_target, 'sound/effects/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(living_target.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), living_target, user), 1) //no free backstabs, we push AFTER module stuff is done
		living_target.adjustFireLoss(bonus_value, forced = TRUE)

/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	trophy_id = TROPHY_DEMON_CLAWS
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_value * 0.2]</b> more damage and heal you for <b>[bonus_value * 0.1]</b>, with <b>5X</b> effect on mark detonation"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()
	if(.)
		pkc.force += bonus_value * 0.2
		pkc.detonation_damage += bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=(20 + bonus_value * 0.2))

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()
	if(.)
		pkc.force -= bonus_value * 0.2
		pkc.detonation_damage -= bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=20)

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	trophy_id = TROPHY_BLASTER_TUBES
	var/deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage but move slower"

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.speed = 2
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	trophy_id = TROPHY_VORTEX
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a homing hierophant chaser"

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/chaser = new(get_turf(user), user, target, 3, TRUE)
		chaser.monster_damage_boost = FALSE // Weaker cuz no cooldown
		chaser.damage = 20
		log_combat(user, target, "fired a chaser at", src)

// Demonic frost miner
/obj/item/crusher_trophy/ice_block_talisman
	name = "ice block talisman"
	desc = "A glowing trinket that a demonic miner had on him, it seems he couldn't utilize it for whatever reason."
	icon_state = "ice_trap_talisman"
	trophy_id = TROPHY_ICE_BLOCK
	denied_type = /obj/item/crusher_trophy/ice_block_talisman

/obj/item/crusher_trophy/ice_block_talisman/effect_desc()
	return "mark detonation to freeze a creature in a block of ice for a period, preventing them from moving"

/obj/item/crusher_trophy/ice_block_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	target.apply_status_effect(/datum/status_effect/ice_block_talisman)

// Wendigo
/obj/item/crusher_trophy/wendigo_horn
	name = "wendigo horn"
	desc = "A gnarled horn ripped from the skull of a wendigo. Suitable as a trophy for a kinetic crusher."
	icon_state = "wendigo_horn"
	denied_type = /obj/item/crusher_trophy/wendigo_horn

/obj/item/crusher_trophy/wendigo_horn/effect_desc()
	return "melee hits inflict twice as much damage"

/obj/item/crusher_trophy/wendigo_horn/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.AddComponent(/datum/component/two_handed, force_wielded=40)

/obj/item/crusher_trophy/wendigo_horn/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.AddComponent(/datum/component/two_handed, force_wielded=20)

// Goliath Broodmother
/obj/item/crusher_trophy/broodmother_tongue
	name = "broodmother tongue"
	desc = "The tongue of a broodmother. If attached a certain way, makes for a suitable crusher trophy.  It also feels very spongey, I wonder what would happen if you squeezed it?..."
	icon = 'icons/obj/mining_zones/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 10
	trophy_id = TROPHY_BROOD_TONGUE
	/// Time at which the item becomes usable again
	var/use_time

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a patch of goliath tentacles at the target's location"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(prob(bonus_value) && target.stat != DEAD)
		new /obj/effect/goliath_tentacle/broodmother/patch(get_turf(target), user)

/obj/item/crusher_trophy/broodmother_tongue/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(use_time > world.time)
		to_chat(living_user, "<b>The tongue looks dried out. You'll need to wait longer to use it again.</b>")
		return
	else if(HAS_TRAIT(living_user, TRAIT_LAVA_IMMUNE))
		to_chat(living_user, "<b>You stare at the tongue. You don't think this is any use to you.</b>")
		return
	ADD_TRAIT(living_user, TRAIT_LAVA_IMMUNE, type)
	to_chat(living_user, "<b>You squeeze the tongue, and some transluscent liquid shoots out all over you.</b>")
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_LAVA_IMMUNE, type), 10 SECONDS)
	use_time = world.time + 60 SECONDS

// Legionnaire
/obj/item/crusher_trophy/legionnaire_spine
	name = "legionnaire spine"
	desc = "The spine of a legionnaire. With some creativity, you could use it as a crusher trophy. Alternatively, shaking it might do something as well."
	icon = 'icons/obj/mining_zones/elite_trophies.dmi'
	icon_state = "legionnaire_spine"
	denied_type = /obj/item/crusher_trophy/legionnaire_spine
	bonus_value = 20
	trophy_id = TROPHY_LEGIONNAIRE_SPINE
	/// Time at which the item becomes usable again
	var/next_use_time

/obj/item/crusher_trophy/legionnaire_spine/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a loyal legion skull"

/obj/item/crusher_trophy/legionnaire_spine/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(!prob(bonus_value) || target.stat == DEAD)
		return
	var/mob/living/basic/legion_brood/minion = new (user.loc)
	minion.assign_creator(user)
	minion.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = target

/obj/item/crusher_trophy/legionnaire_spine/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/LivingUser = user
	if(next_use_time > world.time)
		LivingUser.visible_message(span_warning("[LivingUser] shakes the [src], but nothing happens..."))
		to_chat(LivingUser, "<b>You need to wait longer to use this again.</b>")
		return
	LivingUser.visible_message(span_boldwarning("[LivingUser] shakes the [src] and summons a legion skull!"))

	var/mob/living/basic/legion_brood/minion = new (LivingUser.loc)
	minion.assign_creator(LivingUser)
	next_use_time = world.time + 4 SECONDS

//The Thing
/obj/item/crusher_trophy/flesh_glob
	name = "glob of shifting flesh"
	desc = "A glob of shifting flesh. Sealed shut permanently. Suitable as a trophy for a kinetic crusher."
	icon_state = "glob"
	denied_type = /obj/item/crusher_trophy/flesh_glob
	bonus_value = 20
	/// the order in which we heal damage
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY, TOX)

/obj/item/crusher_trophy/flesh_glob/effect_desc()
	return "melee hits heal you for <b>[bonus_value * 0.2]</b>, and for <b>[bonus_value * 0.5]</b> on mark detonation"

/obj/item/crusher_trophy/flesh_glob/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.2, damage_heal_order)

/obj/item/crusher_trophy/flesh_glob/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	user.heal_ordered_damage(bonus_value * 0.5, damage_heal_order)
