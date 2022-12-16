//Fire
/mob/living/simple_animal/hostile/guardian/fire
	combat_mode = FALSE
	melee_damage_lower = 7
	melee_damage_upper = 7
	attack_sound = 'sound/items/welder.ogg'
	attack_verb_continuous = "ignites"
	attack_verb_simple = "ignite"
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	range = 7
	playstyle_string = span_holoparasite("As a <b>chaos</b> type, you have only light damage resistance, but will ignite any enemy you bump into. In addition, your melee attacks will cause human targets to see everyone as you.")
	magic_fluff_string = span_holoparasite("..And draw the Wizard, bringer of endless chaos!")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Crowd control modules activated. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! OH GOD, EVERYTHING'S ON FIRE. Except you and the fish.")
	miner_fluff_string = span_holoparasite("You encounter... Plasma, the bringer of fire.")
	/// How many fire stacks we clear per second.
	var/extinguish_amount = 10
	/// How many fire stacks we give to people we bump into.
	var/fire_amount = 7
	/// Duration of our hallucination
	var/hallucination_duration = 20 SECONDS

/mob/living/simple_animal/hostile/guardian/fire/Initialize(mapload, theme)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/hostile/guardian/fire/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(summoner)
		summoner.extinguish_mob()
		summoner.adjust_fire_stacks(-extinguish_amount * delta_time)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	if(target == summoner)
		return
	var/mob/living/living_target = target
	living_target.cause_hallucination( \
		/datum/hallucination/delusion/custom, \
		"fire holoparasite ([key_name(src)], owned by [key_name(summoner)])", \
		duration = hallucination_duration, \
		affects_us = TRUE, \
		affects_others = TRUE, \
		skip_nearby = FALSE, \
		play_wabbajack = FALSE, \
		custom_icon_file = icon, \
		custom_icon_state = icon_state, \
	)

/mob/living/simple_animal/hostile/guardian/fire/proc/on_entered(datum/source, atom/movable/collided)
	SIGNAL_HANDLER
	collision_ignite(collided)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(atom/movable/collided)
	. = ..()
	collision_ignite(collided)

/mob/living/simple_animal/hostile/guardian/fire/Bump(atom/movable/collided)
	. = ..()
	collision_ignite(collided)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(atom/movable/collided)
	if(!isliving(collided))
		return
	var/mob/living/collided_mob = collided
	if(!hasmatchingsummoner(collided_mob) && collided_mob != summoner && collided_mob.fire_stacks < fire_amount)
		collided_mob.set_fire_stacks(fire_amount)
		collided_mob.ignite_mob()
