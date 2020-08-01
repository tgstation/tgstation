///How much extra impact speed we inflict on objects hitting flying mobs (see [/datum/mutation/human/fastballer/proc/annihilate_bird])
#define FLYING_IMPACT_PENALTY	4


///RJS makes it so you can throw objects really fast and hard if you throw on harm intent, but if you fail to complete a short windup, your throw will go wild!
/datum/mutation/human/fastballer
	name = "Randy Johnson Syndrome"
	desc = "The genetic mutation behind one of the most dominant pitchers in 20th, 21st, and 22nd century baseball, this grants a powerful boost to throwing power provided a full wind-up is completed."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You start wondering if Nanotrasen has a company baseball team.</span>"
	text_lose_indication = "<span class='warning'>You feel your minor league prospects withering away...</span>"
	instability = 10
	///How long it takes to fully wind-up a pitch. If the thrower is interrupted less than 40% into this, they balk and just don't throw
	var/windup_time = 2 SECONDS
	///How much stamina a successful pitch costs
	var/stamina_cost = 15
	///How much stamina a wild pitch (interrupted more than 40% into do_after) costs
	var/stamina_cost_wild = 25
	///How much extra speed + range you get
	var/power_bonus = 2

/datum/mutation/human/fastballer/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_THROW, .proc/check_pitch)

/datum/mutation/human/fastballer/on_losing(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_THROW)

///We're trying to throw, check if we're on harm intent with an item and not trying to throw a person
/datum/mutation/human/fastballer/proc/check_pitch(datum/source, atom/target)
	if(QDELETED(target))
		CRASH("check_pitch called with invalid target ([target])")
	if(!isturf(owner.loc) || owner.a_intent != INTENT_HARM || istype(target, /obj/screen))
		return

	var/obj/item/held_item = owner.get_active_held_item()
	if(!held_item || (isliving(owner.pulling) && owner.grab_state >= GRAB_AGGRESSIVE))
		return

	. = COMPONENT_MOB_NO_THROW
	INVOKE_ASYNC(src, .proc/windup, target, held_item)

///Handle the do_after for the wind-up
/datum/mutation/human/fastballer/proc/windup(atom/target, obj/item/thrown_thing)
	owner.throw_mode_off()
	owner.visible_message("<span class='danger'>[owner] begins winding up to pitch [thrown_thing] at [target].</span>", "<span class='warning'>You begin winding up to pitch [thrown_thing] at [target]...</span>", vision_distance = COMBAT_MESSAGE_RANGE)
	var/start_windup = world.time

	if(do_after(owner, windup_time))
		pitch(target, thrown_thing)
		return

	if(world.time > start_windup + (0.4 * windup_time))
		pitch(target, thrown_thing, TRUE)
		return

	owner.visible_message("<span class='danger'>[owner] balks and decides not to throw [thrown_thing].</span>", "<span class='danger'>You balk and decide not to throw [thrown_thing].</span>", vision_distance = COMBAT_MESSAGE_RANGE)

///We've pitched the object, print the info and listen into the object to see if it hits a special target. If we went wild, pick the new poor target
/datum/mutation/human/fastballer/proc/pitch(atom/target, obj/item/thrown_thing, wild=FALSE)
	if(wild)
		var/wild_radius = get_dist(owner, target) * 0.5 // further we are from them, the further off it can go
		var/list/possible_new_targets = shuffle(range(target, wild_radius))
		possible_new_targets -= owner
		possible_new_targets -= target
		// try to pick a mob target cause that's funnier
		target = (locate(/mob/living) in possible_new_targets) || (pick(possible_new_targets))

	if(!thrown_thing.on_thrown(owner, target))
		return

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_IMPACT_ZONE, .proc/annihilate_bird)
	RegisterSignal(thrown_thing, COMSIG_MOVABLE_POST_THROW, .proc/get_throw_datum)

	owner.adjustStaminaLoss(wild ? stamina_cost_wild : stamina_cost)
	var/power_throw = owner.get_throwspeed_mods(thrown_thing) + power_bonus
	owner.visible_message("<span class='danger'>[owner] [wild ? "wildly " : ""]pitches [thrown_thing] really hard!</span>", \
					"<span class='danger'>You [wild ? "wildly " : ""]pitch [thrown_thing] really hard!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
	owner.log_message("has [wild ? "wildly " : ""]pitched [thrown_thing]", LOG_ATTACK)
	owner.newtonian_move(get_dir(target, owner))
	thrown_thing.safe_throw_at(target, thrown_thing.throw_range + power_bonus, thrown_thing.throw_speed + power_throw, owner, null, null, null, owner.move_force)

///In honor of the time Randy Johnson exploded a bird with a fastball, deal a bunch of extra impact speed (and thus damage) on flying targets
/datum/mutation/human/fastballer/proc/annihilate_bird(obj/item/thrown_thing, mob/living/victim, hit_zone, datum/thrownthing/throwingdatum)
	UnregisterSignal(thrown_thing, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_MOVABLE_POST_THROW))
	UnregisterSignal(throwingdatum, COMSIG_PARENT_QDELETING)
	if(!(victim.movement_type & FLYING))
		return

	throwingdatum.speed += FLYING_IMPACT_PENALTY
	victim.visible_message("<span class='danger'>[victim] is absolutely smashed by the impact of [thrown_thing]!</span>", "<span class='userdanger'>You're absolutely smashed by the impact of [thrown_thing]!</span>")
	if(istype(victim, /mob/living/simple_animal/parrot/poly))
		var/mob/living/simple_animal/parrot/poly/poly_go_boom = victim
		poly_go_boom.say("SQWAK!!")
		poly_go_boom.ex_act(EXPLODE_HEAVY)
		owner.client?.give_award(/datum/award/achievement/misc/beanball, owner)

///So we can listen for the throwing datum being deleted in case our throw doesn't hit anything, so we can still stop listening for the impact
/datum/mutation/human/fastballer/proc/get_throw_datum(obj/item/thrown_thing, datum/thrownthing/throwingdatum, spin)
	if(!thrown_thing || !throwingdatum)
		return
	throwingdatum.can_hit_nondense_mobs = TRUE
	RegisterSignal(throwingdatum, COMSIG_PARENT_QDELETING, .proc/bail_signal)

///In case our throw hits nothing or something goes wrong, we can still stop listening for hit signals
/datum/mutation/human/fastballer/proc/bail_signal(datum/thrownthing/throwingdatum)
	UnregisterSignal(throwingdatum, COMSIG_PARENT_QDELETING)
	var/obj/item/thrown_thing = throwingdatum.thrownthing
	if(thrown_thing)
		UnregisterSignal(thrown_thing, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_MOVABLE_POST_THROW))

#undef FLYING_IMPACT_PENALTY
