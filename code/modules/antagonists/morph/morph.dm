
///ambush on someone interacting with you (most objects and items, mobs, whathaveyou)
#define AMBUSH_INTERACT (1>>0)
///ambush on someone walking over you (vents)
#define AMBUSH_WALKED_OVER (1>>1)

///the time the morph needs to sit still for the ambush to activate!
#define TIME_TO_AMBUSH 5 SECONDS

/mob/living/simple_animal/hostile/morph
	name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"
	attack_sound = 'sound/effects/blobattack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	speed = 2
	combat_mode = TRUE
	AIStatus = AI_OFF
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	butcher_results = list(/obj/item/food/meat/slab = 2)

	///reference to the addtimer for ambushes
	var/ambush_timer
	///after an ambush is ready, these are the possible ambushes that will be added to ambush flags
	var/ambush_flags_possible = NONE
	///currently active ambushes that trigger in response to certain interactions with the mob
	var/ambush_flags = NONE
	///the current disguise the morph is. obviously, null if it has none.
	var/atom/movable/disguise_form = null
	///things the morph should REALLY not be turning into.
	var/static/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/obj/singularity,
		/obj/energy_ball,
		/obj/narsie,
		/mob/living/simple_animal/hostile/morph,
		/obj/effect
	))
	///things the morph can floor attack from.
	var/static/list/floor_ambush_typecache = typecacheof(list(
		/obj/machinery/atmospherics/components/unary/vent_scrubber,
		/obj/machinery/atmospherics/components/unary/vent_pump,
	))

/mob/living/simple_animal/hostile/morph/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/check_floor_ambush,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/mob/living/simple_animal/hostile/morph/proc/check_floor_ambush(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!(ambush_flags & AMBUSH_WALKED_OVER) || !isliving(crosser))
		return
	//ambushed living mob
	if(!iscarbon(crosser))
		var/mob/living/ambushed_living = crosser
		visible_message("<span class='userdanger'>[src] leaps upwards and eviscerates [ambushed_living]!</span>", \
						"<span class='userdanger'>You ambush [ambushed_living], eviscerating [ambushed_living.p_them()]!</span>")
		ambushed_living.adjustBruteLoss(70)
		playsound(src, 'sound/creatures/morph_ambush.ogg')
		return
	//ambushed carbon mob
	var/mob/living/carbon/ambushed_carbon = crosser
	var/obj/item/bodypart/l_leg/left = ambushed_carbon.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/r_leg/right = ambushed_carbon.get_bodypart(BODY_ZONE_R_LEG)
	if(left || right)
		//weird logic so basically it's picking a random leg unless you only have one, which it will pick that
		var/obj/item/bodypart/chosen_leg = left && right ? pick(left, right) : left || right
		visible_message("<span class='userdanger'>[src] leaps upwards and eviscerates [ambushed_carbon]'s [chosen_leg]!</span>", \
						"<span class='userdanger'>You ambush [ambushed_carbon], eviscerating their [chosen_leg]!</span>")
		chosen_leg.dismember(BRUTE)
	else
		visible_message("<span class='userdanger'>[src] leaps upwards and eviscerates [ambushed_carbon]!</span>", \
						"<span class='userdanger'>You ambush [ambushed_carbon], eviscerating [ambushed_carbon.p_them()]!</span>")
	playsound(src, 'sound/creatures/morph_ambush.ogg')
	ambushed_carbon.adjustBruteLoss(70)

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!(ambush_flags & AMBUSH_INTERACT))
		return
	//ambushed living mob
	if(!iscarbon(user))
		var/mob/living/ambushed_living = user
		visible_message("<span class='userdanger'>[src] lunges forwards at [ambushed_living] and eviscerates [ambushed_living.p_them()]!</span>", \
						"<span class='userdanger'>You ambush [ambushed_living], eviscerating [ambushed_living.p_them()]!</span>")
		ambushed_living.adjustBruteLoss(70)
		playsound(src, 'sound/creatures/morph_ambush.ogg')
		return
	//ambushed carbon mob
	var/mob/living/carbon/ambushed_carbon = user
	var/which_hand = BODY_ZONE_L_ARM
	if(!(ambushed_carbon.active_hand_index % 2))
		which_hand = BODY_ZONE_R_ARM
	var/obj/item/bodypart/chopchop = ambushed_carbon.get_bodypart(which_hand)
	visible_message("<span class='userdanger'>[src] lunges forwards and eviscerates [ambushed_carbon]'s [chopchop]!</span>", \
					"<span class='userdanger'>You ambush [ambushed_carbon], eviscerating their [chopchop]!</span>")
	chopchop.dismember(BRUTE)
	playsound(src, 'sound/creatures/morph_ambush.ogg')
	ambushed_carbon.adjustBruteLoss(70)

/mob/living/simple_animal/hostile/morph/Moved()
	. = ..()
	if(!disguise_form)
		return
	///ruin the old ambush
	if(ambush_flags != NONE)
		to_chat(src, "<span class='warning'>Moving has broken your ambush!</span>")
		ambush_flags = NONE
	else if(ambush_timer)
		deltimer(ambush_timer)
	///attempt a new one
	if(ambush_flags_possible)
		to_chat(src, "<span class='notice'>Your next ambush will be set up in [DisplayTimeText(TIME_TO_AMBUSH)]</span>")
		ambush_timer = addtimer(CALLBACK(src, .proc/ambush_ready), TIME_TO_AMBUSH)

/mob/living/simple_animal/hostile/morph/proc/ambush_ready()
	ambush_flags = ambush_flags_possible
	var/ways_to_ambush = ""
	if(ambush_flags & AMBUSH_INTERACT)
		ways_to_ambush += " You will dismember the hand of and deal great damage to the next victim that touches you."
	if(ambush_flags & AMBUSH_WALKED_OVER)
		ways_to_ambush += " You will dismember the leg of and deal great damage to the next victim that steps on you."
	to_chat(src, "<span class='notice'>You are ready to ambush again![ways_to_ambush]</span>")

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(disguise_form)
		. = disguise_form.examine(user)
		if(get_dist(user,src)<=3)
			. += "<span class='warning'>It doesn't look quite right...</span>"
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/med_hud_set_health()
	if(disguise_form && !isliving(disguise_form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguise_form
	..()

/mob/living/simple_animal/hostile/morph/med_hud_set_status()
	if(disguise_form && !isliving(disguise_form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguise_form
	..()

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()


/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/disguise_target) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(disguise_target, blacklist_typecache) && (isobj(disguise_target) || ismob(disguise_target))

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/eat_target)
	if(disguise_form)
		to_chat(src, "<span class='warning'>You cannot eat anything while you are disguised!</span>")
		return FALSE
	if(eat_target && eat_target.loc != src)
		visible_message("<span class='warning'>[src] swallows [eat_target] whole!</span>")
		eat_target.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/clicked_on)
	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You need to be conscious to transform!</span>")
		return ..()
	if(clicked_on == src)
		restore()
		return
	if(istype(clicked_on) && allowed(clicked_on))
		assume(clicked_on)

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	disguise_form = target

	visible_message("<span class='warning'>[src] suddenly twists and changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You twist your body and assume the disguise_form of [target].</span>")
	appearance = target.appearance
	copy_overlays(target)
	alpha = max(alpha, 150) //fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x
	density = target.density

	set_varspeed(0)

	melee_damage_lower += 15
	melee_damage_upper += 15

	med_hud_set_health()
	med_hud_set_status() //we're an object honest

	//here we handle ambush tips for whatever you turned into.
	if(isobj(target) || isliving(target))
		ambush_flags_possible |= AMBUSH_INTERACT
	if(is_type_in_typecache(target, floor_ambush_typecache))
		ambush_flags_possible |= AMBUSH_WALKED_OVER
	if(ambush_flags_possible)
		to_chat(src, "<span class='notice'>This form can ambush! Wait [DisplayTimeText(TIME_TO_AMBUSH)] without moving to prepare an ambush.</span>")
		ambush_timer = addtimer(CALLBACK(src, .proc/ambush_ready), TIME_TO_AMBUSH)

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!disguise_form)
		to_chat(src, "<span class='warning'>You're already in your normal disguise_form!</span>")
		return
	disguise_form = null
	alpha = initial(alpha)
	color = initial(color)
	desc = initial(desc)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	animate_movement = SLIDE_STEPS
	maptext = null

	visible_message("<span class='warning'>[src] suddenly collapses in on itself, dissolving into a pile of green flesh!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	set_varspeed(initial(speed))

	med_hud_set_health()
	med_hud_set_status() //we are not an object

	//remove ambush stuff
	if(ambush_timer)
		deltimer(ambush_timer)
	ambush_flags_possible = NONE
	ambush_flags = NONE


/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(disguise_form)
		visible_message("<span class='warning'>[src] twists and dissolves into a pile of green flesh!</span>", \
						"<span class='userdanger'>Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--</span>")
		restore()
	barf_contents()
	..()

/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/hostile/morph/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(disguise_form)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget(atom/attacked_target)
	if(disguise_form)
		to_chat(src, "<span class='warning'>Attacking has revealed yourself!</span>")
		restore()
	if(isliving(attacked_target)) //Eat Corpses to regen health
		var/mob/living/yummy_mob = attacked_target
		if(yummy_mob.stat == DEAD)
			if(do_after(src, 3 SECONDS, target = yummy_mob))
				if(eat(yummy_mob))
					adjustHealth(-50)
			return
	else if(isitem(attacked_target)) //Eat items just to be annoying
		var/obj/item/yummy_object = attacked_target
		if(!yummy_object.anchored)
			if(do_after(src, 2 SECONDS, target = yummy_object))
				eat(yummy_object)
			return
	else if(istype(attacked_target, /obj/effect/decal/cleanable/blood)) //slurp up blood to clean the crime scene
		playsound(src, 'sound/items/drink.ogg', 50, TRUE)
		to_chat(src, "<span class='notice'>You slurp up [attacked_target].</span>")
		qdel(attacked_target)
	return ..()
