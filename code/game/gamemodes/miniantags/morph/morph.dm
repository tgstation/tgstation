#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 2
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	environment_smash = 1
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	idle_vision_range = 1 // Only attack when target is close
	wander = 0
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 2)

	var/morphed = 0
	var/atom/movable/form = null
	var/morph_time = 0

	var/playstyle_string = "<b><font size=3 color='red'>You are a morph,</font> an abomination of science created primarily with changeling cells. \
							You may take the form of anything nearby by shift-clicking it. This process will alert any nearby \
							observers, and can only be performed once every five seconds. While morphed, you move faster, but do \
							less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you. \
							You can attack any item or dead creature to consume it - creatures will fully restore your health. \
							Finally, you can restore yourself to your original form while morphed by shift-clicking yourself.</b>"

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		form.examine(user) // Refactor examine to return desc so it's static? Not sure if worth it
		if(get_dist(user,src)<=3)
			user << "<span class='warning'>It doesn't look quite right...</span>"
	else
		..()
	return

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	if(istype(A,/obj/screen))
		return 0
	if(istype(A,/obj/singularity))
		return 0
	if(istype(A,/mob/living/simple_animal/hostile/morph))
		return 0
	return 1

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] swallows [A] whole!</span>")
		A.loc = src
		return 1
	return 0

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed(A))
			assume(A)
	else
		src << "<span class='warning'>Your chameleon skin is still repairing itself!</span>"
		..()

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	morphed = 1
	form = target

	visible_message("<span class='warning'>[src] suddenly twists and changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You twist your body and assume the form of [target].</span>")
	appearance = target.appearance
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)

	//Morphed is weaker
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = 0

	morph_time = world.time + MORPH_COOLDOWN
	return

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = 0
	form = null
	alpha = initial(alpha)

	//anim(loc,src,'icons/mob/mob.dmi',,"morph",,src.dir)

	visible_message("<span class='warning'>[src] suddenly collapses in on itself, dissolving into a pile of green flesh!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	overlays.Cut()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)

	morph_time = world.time + MORPH_COOLDOWN

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message("<span class='warning'>[src] twists and dissolves into a pile of green flesh!</span>", \
						"<span class='userdanger'>Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--</span>")
		restore()
	if(gibbed)
		for(var/atom/movable/AM in src)
			AM.loc = loc
			if(prob(90))
				step(AM, pick(alldirs))
	..(gibbed)

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/morph/AIShouldSleep(var/list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/movable/A in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(morphed)
		return 0
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
	else if(istype(target,/obj/item)) // Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src,20, target = I))
				eat(I)
			return
	target.attack_animal(src)

//Spawn Event

/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/morph
	weight = 0 //Admin only
	max_occurrences = 1

/datum/round_event/morph
	var/key_of_morph

/datum/round_event/morph/proc/get_morph(end_if_fail = 0)
	key_of_morph = null
	if(!key_of_morph)
		var/list/candidates = get_candidates(ROLE_ALIEN)
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_morph()
		var/client/C = pick(candidates)
		key_of_morph = C.key
	if(!key_of_morph)
		if(end_if_fail)
			return 0
		return find_morph()
	var/datum/mind/player_mind = new /datum/mind(key_of_morph)
	player_mind.active = 1
	if(!xeno_spawn)
		return find_morph()
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Morph"
	player_mind.special_role = "Morph"
	ticker.mode.traitors |= player_mind
	S << S.playstyle_string
	S << 'sound/magic/Mutate.ogg'
	message_admins("[key_of_morph] has been made into morph by an event.")
	log_game("[key_of_morph] was spawned as a morph by an event.")
	return 1

/datum/round_event/morph/start()
	get_morph()


/datum/round_event/morph/proc/find_morph()
	message_admins("Attempted to spawn a morph but there was no players available. Will try again momentarily.")
	spawn(50)
		if(get_morph(1))
			message_admins("Situation has been resolved, [key_of_morph] has been spawned as a morph.")
			log_game("[key_of_morph] was spawned as a morph by an event.")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming a morph. Shutting down.")
	return kill()
