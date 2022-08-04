/obj/item/organ/internal/alien
	icon_state = "xgibmid2"
	visual = FALSE
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/acid = 10)

/obj/item/organ/internal/alien/plasmavessel
	name = "plasma vessel"
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_XENO_PLASMAVESSEL
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/plasma = 10)
	actions_types = list(
		/datum/action/cooldown/alien/make_structure/plant_weeds,
		/datum/action/cooldown/alien/transfer,
	)

	/// The current amount of stored plasma.
	var/stored_plasma = 100
	/// The maximum plasma this organ can store.
	var/max_plasma = 250
	/// The rate this organ regenerates its owners health at per damage type per second.
	var/heal_rate = 2.5
	/// The rate this organ regenerates plasma at per second.
	var/plasma_rate = 5

/obj/item/organ/internal/alien/plasmavessel/large
	name = "large plasma vessel"
	icon_state = "plasma_large"
	w_class = WEIGHT_CLASS_BULKY
	stored_plasma = 200
	max_plasma = 500
	plasma_rate = 7.5

/obj/item/organ/internal/alien/plasmavessel/large/queen
	plasma_rate = 10

/obj/item/organ/internal/alien/plasmavessel/small
	name = "small plasma vessel"
	icon_state = "plasma_small"
	w_class = WEIGHT_CLASS_SMALL
	stored_plasma = 100
	max_plasma = 150
	plasma_rate = 2.5

/obj/item/organ/internal/alien/plasmavessel/small/tiny
	name = "tiny plasma vessel"
	icon_state = "plasma_tiny"
	w_class = WEIGHT_CLASS_TINY
	max_plasma = 100
	actions_types = list(/datum/action/cooldown/alien/transfer)

/obj/item/organ/internal/alien/plasmavessel/on_life(delta_time, times_fired)
	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			owner.adjustPlasma(plasma_rate * delta_time)
		else
			var/heal_amt = heal_rate
			if(!isalien(owner))
				heal_amt *= 0.2
			owner.adjustPlasma(0.5 * plasma_rate * delta_time)
			owner.adjustBruteLoss(-heal_amt * delta_time)
			owner.adjustFireLoss(-heal_amt * delta_time)
			owner.adjustOxyLoss(-heal_amt * delta_time)
			owner.adjustCloneLoss(-heal_amt * delta_time)
	else
		owner.adjustPlasma(0.1 * plasma_rate * delta_time)

/obj/item/organ/internal/alien/plasmavessel/Insert(mob/living/carbon/organ_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	if(isalien(organ_owner))
		var/mob/living/carbon/alien/target_alien = organ_owner
		target_alien.updatePlasmaDisplay()

/obj/item/organ/internal/alien/plasmavessel/Remove(mob/living/carbon/organ_owner, special = FALSE)
	..()
	if(isalien(organ_owner))
		var/mob/living/carbon/alien/organ_owner_alien = organ_owner
		organ_owner_alien.updatePlasmaDisplay()

#define QUEEN_DEATH_DEBUFF_DURATION 2400

/obj/item/organ/internal/alien/hivenode
	name = "hive node"
	icon_state = "hivenode"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_XENO_HIVENODE
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/cooldown/alien/whisper)
	/// Indicates if the queen died recently, aliens are heavily weakened while this is active.
	var/recent_queen_death = FALSE

/obj/item/organ/internal/alien/hivenode/Insert(mob/living/carbon/organ_owner, special = FALSE, drop_if_replaced = TRUE)
	..()
	organ_owner.faction |= ROLE_ALIEN
	ADD_TRAIT(organ_owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)

/obj/item/organ/internal/alien/hivenode/Remove(mob/living/carbon/organ_owner, special = FALSE)
	organ_owner.faction -= ROLE_ALIEN
	REMOVE_TRAIT(organ_owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
	..()

//When the alien queen dies, all aliens suffer a penalty as punishment for failing to protect her.
/obj/item/organ/internal/alien/hivenode/proc/queen_death()
	if(!owner|| owner.stat == DEAD)
		return
	if(isalien(owner)) //Different effects for aliens than humans
		to_chat(owner, span_userdanger("Your Queen has been struck down!"))
		to_chat(owner, span_danger("You are struck with overwhelming agony! You feel confused, and your connection to the hivemind is severed."))
		owner.emote("roar")
		owner.Stun(200) //Actually just slows them down a bit.

	else if(ishuman(owner)) //Humans, being more fragile, are more overwhelmed by the mental backlash.
		to_chat(owner, span_danger("You feel a splitting pain in your head, and are struck with a wave of nausea. You cannot hear the hivemind anymore!"))
		owner.emote("scream")
		owner.Paralyze(100)

	owner.adjust_timed_status_effect(1 MINUTES, /datum/status_effect/jitter)
	owner.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/confusion)
	owner.adjust_timed_status_effect(1 MINUTES, /datum/status_effect/speech/stutter)

	recent_queen_death = TRUE
	owner.throw_alert(ALERT_XENO_NOQUEEN, /atom/movable/screen/alert/alien_vulnerable)
	addtimer(CALLBACK(src, .proc/clear_queen_death), QUEEN_DEATH_DEBUFF_DURATION)


/obj/item/organ/internal/alien/hivenode/proc/clear_queen_death()
	if(QDELETED(src)) //In case the node is deleted
		return
	recent_queen_death = FALSE
	if(!owner) //In case the xeno is butchered or subjected to surgery after death.
		return
	to_chat(owner, span_noticealien("The pain of the queen's death is easing. You begin to hear the hivemind again."))
	owner.clear_alert(ALERT_XENO_NOQUEEN)

#undef QUEEN_DEATH_DEBUFF_DURATION

/obj/item/organ/internal/alien/resinspinner
	name = "resin spinner"
	icon_state = "spinner-x"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_RESINSPINNER
	actions_types = list(/datum/action/cooldown/alien/make_structure/resin)


/obj/item/organ/internal/alien/acid
	name = "acid gland"
	icon_state = "acid"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_ACIDGLAND
	actions_types = list(/datum/action/cooldown/alien/acid/corrosion)


/obj/item/organ/internal/alien/neurotoxin
	name = "neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(/datum/action/cooldown/alien/acid/neurotoxin)


/obj/item/organ/internal/alien/eggsac
	name = "egg sac"
	icon_state = "eggsac"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_XENO_EGGSAC
	w_class = WEIGHT_CLASS_BULKY
	actions_types = list(/datum/action/cooldown/alien/make_structure/lay_egg)

/// The stomach that lets aliens eat people/things
/obj/item/organ/internal/stomach/alien
	name = "alien stomach"
	icon_state = "stomach-x"
	w_class = WEIGHT_CLASS_BULKY
	actions_types = list(/datum/action/cooldown/alien/regurgitate)
	var/list/atom/movable/stomach_contents = list()

/obj/item/organ/internal/stomach/alien/Destroy()
	QDEL_LIST(stomach_contents)
	return ..()

/obj/item/organ/internal/stomach/alien/on_life(delta_time, times_fired)
	. = ..()
	if(!owner || SSmobs.times_fired % 3 != 0)
		return
	// Digest the stuff in our stomach, just a bit
	var/static/list/digestable_cache = typecacheof(list(/mob/living, /obj/item/food, /obj/item/reagent_containers))
	for(var/atom/movable/thing as anything in stomach_contents)
		if(!digestable_cache[thing.type])
			continue
		thing.reagents.trans_to(src, 4)

		if(isliving(thing))
			var/mob/living/lad = thing
			lad.adjustBruteLoss(6)
		else if(!thing.reagents.total_volume) // Mobs can't get dusted like this, too important
			qdel(thing)

/obj/item/organ/internal/stomach/alien/proc/consume_thing(atom/movable/thing)
	RegisterSignal(thing, COMSIG_MOVABLE_MOVED, .proc/content_moved)
	if(isliving(thing))
		RegisterSignal(thing, COMSIG_LIVING_DEATH, .proc/content_died)
	stomach_contents += thing
	thing.forceMove(owner || src) // We assert that if we have no owner, we will not be nullspaced

/obj/item/organ/internal/stomach/alien/proc/content_died(atom/movable/source)
	SIGNAL_HANDLER
	qdel(source)

/obj/item/organ/internal/stomach/alien/proc/content_moved(atom/movable/source)
	SIGNAL_HANDLER
	if(source.loc == src || source.loc == owner) // not in us? out da list then
		return
	stomach_contents -= source
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))

/obj/item/organ/internal/stomach/alien/Insert(mob/living/carbon/stomach_owner, special = FALSE, drop_if_replaced = TRUE)
	RegisterSignal(stomach_owner, COMSIG_ATOM_RELAYMOVE, .proc/something_moved)
	return ..()

/obj/item/organ/internal/stomach/alien/Remove(mob/living/carbon/stomach_owner, special = FALSE)
	UnregisterSignal(stomach_owner, COMSIG_ATOM_RELAYMOVE)
	return ..()

/obj/item/organ/internal/stomach/alien/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(loc == null && owner)
		for(var/atom/movable/thing as anything in contents)
			thing.forceMove(owner)
	else if(loc != null)
		for(var/atom/movable/thing as anything in contents)
			thing.forceMove(src)

/obj/item/organ/internal/stomach/alien/proc/something_moved(mob/living/source, mob/living/user, direction)
	SIGNAL_HANDLER
	relaymove(user, direction)
	return COMSIG_BLOCK_RELAYMOVE

/obj/item/organ/internal/stomach/alien/relaymove(mob/living/user, direction)
	if(!(user in src.stomach_contents))
		return
	if(!prob(40))
		return
	var/atom/play_from = owner || src
	var/stomach_text = owner ? "\the [owner]'s stomach" : "\the [src]"
	if(prob(25))
		play_from.audible_message(span_warning("You hear something rumbling inside [stomach_text]..."), \
			span_warning("You hear something rumbling."), 4,\
			self_message = span_userdanger("Something is rumbling inside your stomach!"))

	if(user.client)
		user.client.move_delay = world.time + 1.5 SECONDS

	var/attack_name = ""
	var/attack_verb = ""
	var/impact = 0
	var/obj/item/pokie = user.get_active_held_item()
	if(pokie)
		var/dmg = pokie.force || 0
		var/list/attack_verbs = pokie.attack_verb_continuous
		impact = rand(round(dmg / 4), dmg)
		attack_name = pokie.name
		attack_verb = length(attack_verbs) ? "[pick(attack_verbs)]" : "attacks"

	if(!impact)
		return

	applyOrganDamage(impact)

	var/damage_ratio = damage / max(maxHealth, 1)
	if(owner)
		var/obj/item/bodypart/part = owner.get_bodypart(BODY_ZONE_CHEST)
		// Brute damage to the mob is less then to the organ, so there's a higher chance of the explosion happening before xeno death
		part.receive_damage(impact / 2)
		// We choose the option that's best for the check
		var/part_dam_ratio = part.brute_dam / max(part.max_damage, 1)
		if(damage_ratio < part_dam_ratio)
			damage_ratio = part_dam_ratio

	play_from.visible_message(span_danger("[user] [attack_verb] [stomach_text] wall with the [attack_name]!"), \
			span_userdanger("[user] [attack_verb] your stomach wall with the [attack_name]!"))

	// At 100% damage, the stomach burts
	// Otherwise, we give them a -50% -> 50% chance scaling with damage dealt
	if(!prob((damage_ratio * 100) - 50) && damage_ratio != 1)
		playsound(play_from, 'sound/creatures/alien_organ_cut.ogg', 100, 1)
		// We try and line up the "jump" here with the sound of the hit
		var/oldx = play_from.pixel_x
		var/oldy = play_from.pixel_y
		animate(play_from, pixel_x = oldx, pixel_y = oldx, 0.1 SECONDS)
		var/newx = oldx + at_least(rand(-8, 8), 2)
		var/newy = oldy + at_least(rand(-8, 8), 2)
		// Here's a bit before the hit
		animate(pixel_x = newx, pixel_y = newx, 0.15 SECONDS, easing = SINE_EASING | EASE_IN)
		newx += at_least(rand(-4, 4), 1)
		newy += at_least(rand(-4, 4), 1)
		// Here's a bit after the hit, we've got maybe 2 ticks to add a bit more juice
		animate(pixel_x = newy, pixel_y = newx, 0.1 SECONDS)
		// Now we're gonna walk back to rest in maybe 3 ticks?
		animate(pixel_x = oldx, pixel_y = oldx, 0.5 SECONDS)

		shake_camera(user, 0.1 SECONDS, 0.5)
		if(owner)
			shake_camera(owner, 0.3 SECONDS, 1.5)
		return
	// Failure condition
	if(isalienhumanoid(user))
		play_from.visible_message(span_danger("[user] blows a hole in [stomach_text] and escapes!"), \
			span_userdanger("As your hive's food bursts out of your stomach, one thought fills your mind. \"Oh, so this is how the other side feels\""))
	else // Just to be safe ya know?
		play_from.visible_message(span_danger("[user] blows a hole in [stomach_text] and escapes!"), \
			span_userdanger("[user] escapes from your [stomach_text]. Hell, that hurts."))

	playsound(get_turf(play_from), 'sound/creatures/alien_explode.ogg', 100, extrarange = 4)
	eject_stomach(border_diamond_range_turfs(play_from, 6), 5, 1.5, 1, 8)
	shake_camera(user, 1 SECONDS, 3)
	if(owner)
		shake_camera(owner, 2, 5)
		owner.gib()
	qdel(src)

/obj/item/organ/internal/stomach/alien/proc/eject_stomach(list/turf/targets, spit_range, content_speed, particle_delay, particle_count=4)
	var/atom/spit_as = owner || src
	/// Throw out the stuff in our stomach
	for(var/atom/movable/thing as anything in stomach_contents)
		thing.forceMove(spit_as.drop_location())
		if(length(targets))
			thing.throw_at(pick(targets), spit_range, content_speed, thrower = spit_as, spin = TRUE)

	for(var/a in 1 to particle_count)
		if(!length(targets))
			break
		var/obj/effect/particle_effect/water/extinguisher/stomach_acid/acid = new (get_turf(spit_as))
		var/turf/my_target = pick_n_take(targets)
		var/datum/reagents/acid_reagents = new /datum/reagents(5)
		acid.reagents = acid_reagents
		acid_reagents.my_atom = acid
		acid_reagents.add_reagent(/datum/reagent/toxin/acid, 30)
		acid.move_at(my_target, particle_delay, spit_range)
