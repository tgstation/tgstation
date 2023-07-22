/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	///Generic bonus to X var; if the trophy has a bonus effect, this is how much that effect is
	var/bonus_value = 10
	///Trophies that conflict with this trophy; either upgrades or something that messes up the interactions
	var/denied_type = /obj/item/crusher_trophy

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Causes [effect_desc()] when attached to a kinetic crusher.")

///Returns a string describing the special effect to add into the trophy/crusher's description
/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"

/obj/item/crusher_trophy/attackby(obj/item/attack_item, mob/living/user)
	if(istype(attack_item, /obj/item/kinetic_crusher))
		add_to(attack_item, user)
	return ..()

///Applies the trophy to the crusher, as well as applying any special properties
/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/trophy as anything in crusher.trophies)
		if(istype(trophy, denied_type) || istype(src, trophy.denied_type))
			to_chat(user, span_warning("You can't seem to attach [src] to [crusher]. Maybe remove a few trophies?"))
			return FALSE
	if(!user.transferItemToLoc(src, crusher))
		return
	crusher.trophies += src
	crusher.balloon_alert(user, "trophy attached")
	return TRUE

///Removes the trophy from the crusher, as well as removing any special properties granted by that trophy
/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	forceMove(get_turf(crusher))
	return TRUE

///Special effect to execute upon hitting an enemy in melee with the crusher
/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user)
	return

///Special effect to execute upon firing the destabilizer projectile
/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	return

///Special effect to execute upon applying a destabilizer mark on an enemy
/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark)
	return

///Special effect to execute upon detonating a destabilizer mark attached to an enemy
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user)
	return

/**
 * Goliath
 * Detonating a mark causes extra damage to the victim based on how much health the user is missing.
 */
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	///How much of user's missing health is converted into bonus damage, %
	var/missing_health_ratio = 0.1

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> more damage for every <b>[missing_health_ratio * 100]</b> health you are missing"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.maxHealth - user.health
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage

/**
 * Watcher
 * Detonating a mark causes the victim's next ranged attack/special attack to cool down slower.
 */
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value * 0.1]</b> second\s"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/victim = target //this is fun, doesn't apply to basic mobs. need to look into that
		if(victim.ranged) //briefly delay ranged attacks
			if(victim.ranged_cooldown >= world.time)
				victim.ranged_cooldown += bonus_value
			else
				victim.ranged_cooldown = bonus_value + world.time

/**
 * Watcher - icewing variant
 * Detonating a mark causes the victim's next ranged attack/special attack to cool down even slower.
 */
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8

/**
 * Watcher - magmawing variant
 * Detonating a mark causes the next destabilizer shot to deal damage.
 * The bonus lasts for a single shot and resets after 30 seconds.
 */
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		deadly_shot = FALSE

/**
 * Legion - the carbon-sized one
 * Causes the crusher's destabilizer shot to recharge faster.
 */
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.charge_time += bonus_value

/**
 * Lobstrosity
 * Detonating a mark causes the victim to stagger for 1 second, which slows down movement
 * and more than doubles the cooldown for the victim's ranged attack (if it's a simple hostile mob).
 */
/obj/item/crusher_trophy/lobster_claw
	name = "lobster claw"
	icon_state = "lobster_claw"
	desc = "A lobster claw."
	denied_type = /obj/item/crusher_trophy/lobster_claw
	bonus_value = 1

/obj/item/crusher_trophy/lobster_claw/effect_desc()
	return "mark detonation to briefly stagger the target for [bonus_value] seconds"

/obj/item/crusher_trophy/lobster_claw/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/stagger, bonus_value SECONDS)

/**
 * Brimdemon
 * Detonating a mark causes a loud = funny sound and a comedic message to appear on the victim.
 */
/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse."
	denied_type = /obj/item/crusher_trophy/brimdemon_fang
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation creates visual and audiosensory effects on the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(mob/living/target, mob/living/user)
	target.balloon_alert_to_viewers("[pick(comic_phrases)]!")
	playsound(target, 'sound/lavaland/brimdemon_crush.ogg', 100)

/**
 * Polar bear
 * Detonating a mark while the user's health is at half or less causes the crusher to attack one more time.
 */
/obj/item/crusher_trophy/bear_paw
	name = "polar bear paw"
	desc = "It's a polar bear paw."
	icon_state = "bear_paw"
	denied_type = /obj/item/crusher_trophy/bear_paw

/obj/item/crusher_trophy/bear_paw/effect_desc()
	return "mark detonation to attack twice if you are below half your life"

/obj/item/crusher_trophy/bear_paw/on_mark_detonation(mob/living/target, mob/living/user)
	if(user.health / user.maxHealth > 0.5)
		return
	var/obj/item/I = user.get_active_held_item()
	if(!I)
		return
	I.melee_attack_chain(user, target, null)

/**
 * Wolf
 * Detonating a mark causes the user to move twice as fast for 1 second.
 */
/obj/item/crusher_trophy/wolf_ear
	name = "wolf ear"
	desc = "It's a wolf ear."
	icon_state = "wolf_ear"
	denied_type = /obj/item/crusher_trophy/wolf_ear

/obj/item/crusher_trophy/wolf_ear/effect_desc()
	return "mark detonation to gain a <b>2X</b> speed boost temporarily"

/obj/item/crusher_trophy/wolf_ear/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/speed_boost, 1 SECONDS)

// Bosses, minibosses and the other tough grunts

/**
 * Blood-drunk miner
 * Detonating a mark applies a blood-drunk status effect to the user, absorbing stun effects and
 * reducing ALL incoming damage by 90% for 1 second.
 */
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/blooddrunk)

/**
 * Ash drake
 * Detonating a mark causes any enemies near the user in a 2-tile radius to take fire damage
 * and be pushed away a tile, including the initial mark victim.
 */
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> damage to nearby creatures and push them back"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/victim in oview(2, user))
		if(victim.stat == DEAD)
			continue
		playsound(victim, 'sound/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(get_turf(victim))
		addtimer(CALLBACK(src, PROC_REF(pushback), victim, user), 1) //no free backstabs, we push AFTER module stuff is done
		victim.adjustFireLoss(bonus_value, forced = TRUE)

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
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	///Damage healing order to pass into heal_ordered_damage()
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_value * 0.2]</b> more damage and heal you for <b>[bonus_value * 0.1]</b>, with <b>4X</b> effect on mark detonation"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.force += bonus_value * 0.2
		target_crusher.detonation_damage += bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=(20 + bonus_value * 0.2))

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/target_crusher, mob/living/user)
	. = ..()
	if(.)
		target_crusher.force -= bonus_value * 0.2
		target_crusher.detonation_damage -= bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=20)

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

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
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	///Whether the next destabilizer shot should deal damage or not
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
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

/**
 * Hierophant
 * Detonating a mark causes a hierophant chaser to appear under the user, dealing damage to the victim and mining terrain.
 * The chaser won't hurt the user but *will* damage user's faction members (read: other miners).
 */
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a homing hierophant chaser"

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/chaser = new(get_turf(user), user, target, 3, TRUE)
		chaser.monster_damage_boost = FALSE // Weaker cuz no cooldown
		chaser.damage = 20
		log_combat(user, target, "fired a hierophant chaser at", src)

/**
 * Goliath broodmother
 * Detonating a mark has a 10% chance to create a tentacle patch under the victim, stunning and dealing damage.
 * Does not affect the user.
 * The item itself can also be used in-hand to grant the user lava immunity for 10 seconds.
 */
/obj/item/crusher_trophy/broodmother_tongue
	name = "broodmother tongue"
	desc = "The tongue of a broodmother. If attached a certain way, makes for a suitable crusher trophy.  It also feels very spongey, I wonder what would happen if you squeezed it?..."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 10
	/// Time at which the item becomes usable again
	var/use_time

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a patch of goliath tentacles at the target's location"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	if(prob(bonus_value) && target.stat != DEAD)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(get_turf(target), user)

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

/**
 * Legionnaire
 * Detonating a mark has a chance to spawn a user-allied legion skull, attacking the victim.
 */
/obj/item/crusher_trophy/legionnaire_spine
	name = "legionnaire spine"
	desc = "The spine of a legionnaire. With some creativity, you could use it as a crusher trophy. Alternatively, shaking it might do something as well."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "legionnaire_spine"
	denied_type = /obj/item/crusher_trophy/legionnaire_spine
	bonus_value = 20
	/// Time at which the item becomes usable again
	var/next_use_time

/obj/item/crusher_trophy/legionnaire_spine/effect_desc()
	return "mark detonation to have a <b>[bonus_value]%</b> chance to summon a loyal legion skull"

/obj/item/crusher_trophy/legionnaire_spine/on_mark_detonation(mob/living/target, mob/living/user)
	if(!prob(bonus_value) || target.stat == DEAD)
		return
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion(user.loc)
	A.GiveTarget(target)
	A.friends += user
	A.faction = user.faction.Copy()

/obj/item/crusher_trophy/legionnaire_spine/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/LivingUser = user
	if(next_use_time > world.time)
		LivingUser.visible_message(span_warning("[LivingUser] shakes the [src], but nothing happens..."))
		to_chat(LivingUser, "<b>You need to wait longer to use this again.</b>")
		return
	LivingUser.visible_message(span_boldwarning("[LivingUser] shakes the [src] and summons a legion skull!"))
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/LegionSkull = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion(LivingUser.loc)
	LegionSkull.friends += LivingUser
	LegionSkull.faction = LivingUser.faction.Copy()
	next_use_time = world.time + 4 SECONDS

/**
 * Demonic frost miner
 * Detonating a mark causes the victim to be encased in an ice block, preventing movement for 4 seconds.
 */
/obj/item/crusher_trophy/ice_block_talisman
	name = "ice block talisman"
	desc = "A glowing trinket that a demonic miner had on him, it seems he couldn't utilize it for whatever reason."
	icon_state = "ice_trap_talisman"
	denied_type = /obj/item/crusher_trophy/ice_block_talisman

/obj/item/crusher_trophy/ice_block_talisman/effect_desc()
	return "mark detonation to freeze a creature in a block of ice for a period, preventing them from moving"

/obj/item/crusher_trophy/ice_block_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/ice_block_talisman)

/datum/status_effect/ice_block_talisman
	id = "ice_block_talisman"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/ice_block_talisman
	///Stored icon overlay for the hit mob, removed when effect is removed
	var/icon/cube

/datum/status_effect/ice_block_talisman/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/atom/movable/screen/alert/status_effect/ice_block_talisman
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move!"
	icon_state = "frozen"

/datum/status_effect/ice_block_talisman/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(owner_moved))
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	var/icon/size_check = icon(owner.icon, owner.icon_state)
	cube.Scale(size_check.Width(), size_check.Height())
	owner.add_overlay(cube)
	return ..()

///Blocks movement from the status effect owner
/datum/status_effect/ice_block_talisman/proc/owner_moved()
	SIGNAL_HANDLER
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/ice_block_talisman/be_replaced()
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	return ..()

/datum/status_effect/ice_block_talisman/on_remove()
	if(!owner.stat)
		to_chat(owner, span_notice("The cube melts!"))
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)

/**
 * Wendigo
 * Doubles melee damage of the crusher when wielded.
 */
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
