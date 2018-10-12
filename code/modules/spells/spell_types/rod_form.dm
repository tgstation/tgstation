/obj/effect/proc_holder/spell/targeted/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 250
	cooldown_min = 100
	range = -1
	include_user = TRUE
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"

/obj/effect/proc_holder/spell/targeted/rod_form/cast(list/targets,mob/user = usr)
	for(var/mob/living/M in targets)
		var/turf/start = get_turf(M)
		var/obj/effect/immovablerod/wizard/W = new(start, get_ranged_target_turf(start, M.dir, (15 + spell_level * 3)))
		W.wizard = M
		W.max_distance += spell_level * 3 //You travel farther when you upgrade the spell
		W.damage_bonus += spell_level * 20 //You do more damage when you upgrade the spell
		W.start_turf = start
		M.forceMove(W)
		M.notransform = TRUE
		M.status_flags |= GODMODE

//Wizard Version of the Immovable Rod

/obj/effect/immovablerod/wizard
	var/max_distance = 13
	var/damage_bonus = 0
	var/mob/living/wizard
	var/turf/start_turf
	notify = FALSE

/obj/effect/immovablerod/wizard/Move()
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		qdel(src)
	..()

/obj/effect/immovablerod/wizard/Destroy()
	if(wizard)
		wizard.status_flags &= ~GODMODE
		wizard.notransform = FALSE
		wizard.forceMove(get_turf(src))
	return ..()

/obj/effect/immovablerod/wizard/penetrate(mob/living/L)
	if(L.anti_magic_check())
		L.visible_message("<span class='danger'>[src] hits [L], but it bounces back, then vanishes!</span>" , "<span class='userdanger'>[src] hits you... but it bounces back, then vanishes!</span>" , "<span class ='danger'>You hear a weak, sad, CLANG.</span>")
		qdel(src)
		return
	L.visible_message("<span class='danger'>[L] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
	L.adjustBruteLoss(70 + damage_bonus)

/obj/effect/proc_holder/spell/targeted/rod_form/stab_form
	name = "Blade Rush"
	desc = "Rush forward, slashing any non-Syndicate in your path. Each target struck will heal you and reduce the cooldown of your next Blade Rush.."
	clothes_req = FALSE
	charge_max = 200
	include_user = TRUE
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "separate"
	invocation = "HIYA!"
	invocation_type = "shout"

/obj/effect/proc_holder/spell/targeted/rod_form/stab_form/cast(list/targets,mob/living/user = usr)
	user.SpinAnimation(5, 3)
	user.spin(10,2)
	user.alpha = 100
	user.density = 0
	var/Step = user.dir
	for(var/I in 1 to 5)
		var/turf/Current = get_turf(user)
		var/turf/Next = get_step(Current, Step)
		if(!(Next.CanAtmosPass(Current)))
			break
		user.forceMove(Next)
		playsound(user, 'sound/weapons/fwoosh.wav', 75, 0)
		for(var/mob/living/M in Next)
			if(!(ROLE_SYNDICATE in M.faction) && M.stat!= DEAD)
				M.attack_animal(user)
				user.health = min(user.maxHealth, user.health+25)
				charge_counter = min(charge_max, charge_counter+50)
		sleep(2)
	user.density = 1
	user.alpha = 255