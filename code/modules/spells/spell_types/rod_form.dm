/obj/effect/proc_holder/spell/targeted/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path."
	clothes_req = 1
	human_req = 0
	charge_max = 250
	cooldown_min = 100
	range = -1
	include_user = 1
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"

/obj/effect/proc_holder/spell/targeted/rod_form/cast(list/targets,mob/user = usr)
	for(var/mob/living/M in targets)
		var/turf/start = get_turf(M)
		var/obj/effect/immovablerod/wizard/W = new(start, get_ranged_target_turf(M, M.dir, (15 + spell_level * 3)))
		W.wizard = M
		W.max_distance += spell_level * 3 //You travel farther when you upgrade the spell
		W.damage_bonus += spell_level * 20 //You do more damage when you upgrade the spell
		W.start_turf = start
		M.forceMove(W)
		M.notransform = 1
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
		wizard.notransform = 0
		wizard.forceMove(get_turf(src))
	return ..()

/obj/effect/immovablerod/wizard/penetrate(mob/living/L)
	L.visible_message("<span class='danger'>[L] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
	L.adjustBruteLoss(70 + damage_bonus)
