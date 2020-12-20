//TIME TO REACH HEAVEN THROUGH VIOLENCE

/obj/effect/ebeam/chain
	name = "thick chain"
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "chain"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A chain, coming from the face of the body below."

/obj/effect/ebeam/chain/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(!isvineimmune(L))
			L.adjustBruteLoss(5)
			to_chat(L, "<span class='alert'>You wrap yourself in the chains, hurting yourself!</span>")

/mob/living/simple_animal/hostile/megafauna/samson
	name = "Samson"
	desc = "One of the end products of blood magic. It looks dangerous, but Valor's controlling it. It must be harmless. ...Right?"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	icon_state = "samson"
	icon_living = "samson"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	AIStatus = AI_OFF
	pixel_x = -32
	speak_emote = list("caws")
	maxHealth = 10000
	health = 10000
	melee_damage_lower = 30
	melee_damage_upper = 60
	pixel_y = 0
	movement_type = FLYING
	initial_language_holder = /datum/language_holder/spiritual
	stop_automated_movement = 1
	see_in_dark = 8
	ranged = TRUE
	dextrous = TRUE
	held_items = list(null, null)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	blood_volume = BLOOD_VOLUME_MAXIMUM
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	friendly_verb_continuous = "stares"
	friendly_verb_simple = "stare"
	response_help_continuous = "pats"
	response_help_simple = "pat"
	pass_flags = LETPASSTHROW
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_sound = 'sound/weapons/rapierhit.ogg'
	mouse_opacity = MOUSE_OPACITY_ICON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	faction = list("hostile","vines")
	/// A list of all the plant's chains
	var/list/chains = list()
	/// The maximum amount of chains a plant can have at one time
	var/max_chains = 4
	/// How far away a plant can attach a chain to something
	var/chain_grab_distance = 10
	/// Whether or not this plant is ghost possessable

/mob/living/simple_animal/hostile/megafauna/samson/Life()
	. = ..()
	pull_chains()

/mob/living/simple_animal/hostile/megafauna/samson/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			adjustHealth(-maxHealth * 0.1)

/mob/living/simple_animal/hostile/megafauna/samson/OpenFire(atom/the_target)
	for(var/datum/beam/B in chains)
		if(B.target == the_target)
			pull_chains()
			ranged_cooldown = world.time + (ranged_cooldown_time * 0.5)
			return
	if(get_dist(src,the_target) > chain_grab_distance || chains.len >= max_chains)
		return
	for(var/turf/T in getline(src,target))
		if (T.density)
			return
		for(var/obj/O in T)
			if(O.density)
				return

	var/datum/beam/newchain = Beam(the_target, "chain", time=INFINITY, maxdistance = chain_grab_distance, beam_type=/obj/effect/ebeam/chain)
	RegisterSignal(newchain, COMSIG_PARENT_QDELETING, .proc/remove_chain, newchain)
	chains += newchain
	if(isliving(the_target))
		var/mob/living/L = the_target
		L.Paralyze(20)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/megafauna/samson/Login()
	. = ..()
	to_chat(src, "<span class='boldwarning'>You're a monster now.</span>")

/**
  * Manages how the chains should affect the things they're attached to.
  *
  * Pulls all movable targets of the chains closer to the plant
  * If the target is on the same tile as the plant, destroy the chain
  * Removes any QDELETED chains from the chains list.
  */
/mob/living/simple_animal/hostile/megafauna/samson/proc/pull_chains()
	for(var/datum/beam/B in chains)
		if(istype(B.target, /atom/movable))
			var/atom/movable/AM = B.target
			if(!AM.anchored)
				step(AM,get_dir(AM,src))
		if(get_dist(src,B.target) == 0)
			B.End()

/**
  * Removes a chain from the list.
  *
  * Removes the chain from our list.
  * Called specifically when the chain is about to be destroyed, so we don't have any null references.
  * Arguments:
  * * datum/beam/chain - The chain to be removed from the list.
  */
/mob/living/simple_animal/hostile/megafauna/samson/proc/remove_chain(datum/beam/chain, force)
	chains -= chain

/obj/item/samson
	name = "Blood magic"
	desc = "Shlorp this down to learn a funny"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/samson/attack_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		return
	to_chat(H, "<span class='danger'>You can now use the ultimate blood magic. Be careful.</span>")
	var/obj/effect/proc_holder/spell/targeted/shapeshift/samson/P = new
	H.mind.AddSpell(P)
	playsound(H.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/obj/effect/proc_holder/spell/targeted/shapeshift/samson
	name = "Summon Samson"
	desc = "FUNNY BIRD."
	invocation_type = "none"
	convert_damage = FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/megafauna/samson