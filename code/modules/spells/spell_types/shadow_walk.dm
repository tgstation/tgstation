/obj/effect/proc_holder/spell/targeted/shadowwalk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	charge_max = 0
	clothes_req = 0
	phase_allowed = 1
	selection_type = "range"
	range = -1
	include_user = 1
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/targeted/shadowwalk/cast(list/targets,mob/living/user = usr)
	var/L = user.loc
	if(istype(user.loc, /obj/effect/dummy/shadow))
		var/obj/effect/dummy/shadow/S = L
		S.end_jaunt(FALSE)
		return
	else
		var/turf/T = get_turf(user)
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
			visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>")
			user.AdjustStun(-20, 0)
			user.AdjustKnockdown(-20, 0)
			var/obj/effect/dummy/shadow/S2 = new(get_turf(user.loc))
			user.forceMove(S2)
			S2.jaunter = user
		else
			to_chat(user, "<span class='warning'>It isn't dark enough here!</span>")

/obj/effect/dummy/shadow
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/shadow/relaymove(mob/user, direction)
	var/turf/newLoc = get_step(src,direction)
	if(isspaceturf(newLoc))
		to_chat(user, "<span class='warning'>It really would not be wise to go into space.</span>")
		return
	forceMove(newLoc)
	check_light_level()

/obj/effect/dummy/shadow/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.2) // jaunt ends
		end_jaunt(TRUE)
	else if (light_amount < 0.2 && (!QDELETED(jaunter))) //heal in the dark
		jaunter.heal_overall_damage(1,1)

/obj/effect/dummy/shadow/proc/end_jaunt(forced = FALSE)
	if(jaunter)
		if(forced)
			visible_message("<span class='boldwarning'>[jaunter] is revealed by the light!</span>")
		else
			visible_message("<span class='boldwarning'>[jaunter] emerges from the darkness!</span>")
		jaunter.forceMove(get_turf(src))
		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunter = null
	qdel(src)

/obj/effect/dummy/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/shadow/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)
	check_light_level()

/obj/effect/dummy/shadow/ex_act()
	return

/obj/effect/dummy/shadow/bullet_act()
	return

/obj/effect/dummy/shadow/singularity_act()
	return

