/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "There ain't a skull in the league that can withstand a swatter."
	icon = 'icons/obj/weapons/bat.dmi'
	icon_state = "baseball_bat"
	inhand_icon_state = "baseball_bat"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 12
	wound_bonus = -10
	throwforce = 12
	demolition_mod = 1.25
	attack_verb_continuous = list("beats", "smacks")
	attack_verb_simple = list("beat", "smack")
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 3.5)
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_HUGE
	/// Are we able to do a homerun?
	var/homerun_able = FALSE
	/// Are we ready to do a homerun?
	var/homerun_ready = FALSE
	/// Can we launch mobs thrown at us away?
	var/mob_thrower = FALSE
	/// List of all thrown datums we sent.
	var/list/thrown_datums = list()

/obj/item/melee/baseball_bat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneecapping)
	// No subtypes
	if(type != /obj/item/melee/baseball_bat)
		return
	if(prob(check_holidays(APRIL_FOOLS) ? 50 : 1))
		make_silly()

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		return ..()
	if(homerun_ready)
		to_chat(user, span_warning("You're already ready to do a home run!"))
		return ..()
	to_chat(user, span_warning("You begin gathering strength..."))
	playsound(get_turf(src), 'sound/effects/magic/lightning_chargeup.ogg', 65, TRUE)
	if(do_after(user, 9 SECONDS, target = src))
		to_chat(user, span_userdanger("You gather power! Time for a home run!"))
		homerun_ready = TRUE
	return ..()

/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user)
	// we obtain the relative direction from the bat itself to the target
	var/relative_direction = get_cardinal_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(homerun_ready)
		user.visible_message(span_userdanger("It's a home run!"))
		if(!QDELETED(target))
			target.throw_at(throw_target, rand(8,10), 14, user)
		SSexplosions.medturf += throw_target
		playsound(get_turf(src), 'sound/items/weapons/homerun.ogg', 100, TRUE)
		homerun_ready = FALSE
		return
	else if(!QDELETED(target) && !target.anchored)
		var/whack_speed = (prob(60) ? 1 : 4)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user, gentle = TRUE) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)

/obj/item/melee/baseball_bat/Destroy(force)
	for(var/target in thrown_datums)
		var/datum/thrownthing/throw_datum = thrown_datums[target]
		throw_datum.callback.Invoke()
	thrown_datums.Cut()
	return ..()

/obj/item/melee/baseball_bat/pre_attack(atom/movable/target, mob/living/user, list/modifiers, list/attack_modifiers)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return ..()
	for(var/atom/movable/atom as anything in target_turf)
		if(!try_launch(atom, user))
			continue
		return TRUE
	return ..()

/obj/item/melee/baseball_bat/proc/try_launch(atom/movable/target, mob/living/user)
	if(!target.throwing || (ismob(target) && !mob_thrower))
		return FALSE
	var/datum/thrownthing/throw_datum = target.throwing
	var/datum_throw_speed = throw_datum.speed
	var/angle = 0
	var/target_to_user = get_dir(target, user)
	if(target.dir & turn(target_to_user, 90))
		angle = 270
	if(target.dir & turn(target_to_user, 270))
		angle = 90
	if(target.dir & REVERSE_DIR(target_to_user))
		angle = 180
	if(target.dir & target_to_user)
		angle = 360
	var/turf/return_to_sender = get_ranged_target_turf_direct(user, throw_datum.starting_turf, max(3, round(target.throw_range * 1.5, 1)), offset = angle + (rand(-1, 1) * 10))
	throw_datum.finalize(hit = FALSE)
	target.mouse_opacity = MOUSE_OPACITY_TRANSPARENT //dont mess with our ball
	target.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) //make them super light
	animate(target, 0.5 SECONDS, color = null, flags = ANIMATION_PARALLEL)
	user.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3)
	animate(user, 0.5 SECONDS, color = null, flags = ANIMATION_PARALLEL)
	playsound(src, 'sound/items/baseballhit.ogg', 100, TRUE)
	user.do_attack_animation(target, used_item = src)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, type)
	addtimer(CALLBACK(src, PROC_REF(launch_back), target, user, return_to_sender, datum_throw_speed), 0.5 SECONDS)
	return TRUE

/obj/item/melee/baseball_bat/proc/launch_back(atom/movable/target, mob/living/user, turf/target_turf, datum_throw_speed)
	playsound(target, 'sound/effects/magic/tail_swing.ogg', 50, TRUE)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, type)
	target.mouse_opacity = initial(target.mouse_opacity)
	target.add_filter("baseball_launch", 3, motion_blur_filter(1, 3))
	target.throwforce *= 2
	target.throw_at(target_turf, get_dist(target, target_turf), datum_throw_speed + 1, user, callback = CALLBACK(src, PROC_REF(on_hit), target))
	thrown_datums[target] = target.throwing

/obj/item/melee/baseball_bat/proc/make_silly()
	name = "cricket bat"
	icon_state = "baseball_bat_brit"
	inhand_icon_state = "baseball_bat_brit"
	desc = pick("You've got red on you.", "You gotta know what a crumpet is to understand cricket.")

/obj/item/melee/baseball_bat/proc/on_hit(atom/movable/target)
	target.remove_filter("baseball_launch")
	target.throwforce *= 0.5
	thrown_datums -= target

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	icon_state = "baseball_bat_home"
	inhand_icon_state = "baseball_bat_home"
	homerun_able = TRUE
	mob_thrower = TRUE

/obj/item/melee/baseball_bat/ablative
	name = "metal baseball bat"
	desc = "This bat is made of highly reflective, highly armored material."
	icon_state = "baseball_bat_metal"
	inhand_icon_state = "baseball_bat_metal"
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 3.5)
	resistance_flags = NONE
	force = 20
	throwforce = 20
	mob_thrower = TRUE
	block_sound = 'sound/items/weapons/effects/batreflect.ogg'

/obj/item/melee/baseball_bat/ablative/IsReflect()//some day this will reflect thrown items instead of lasers
	return TRUE

// In case you ever want to spawn it via map/admin console
/obj/item/melee/baseball_bat/british/Initialize(mapload)
	. = ..()
	make_silly()
