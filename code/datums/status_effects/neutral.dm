//entirely neutral or internal status effects go here

/datum/status_effect/sigil_mark //allows the affected target to always trigger sigils while mindless
	id = "sigil_mark"
	duration = -1
	alert_type = null
	var/stat_allowed = DEAD //if owner's stat is below this, will remove itself

/datum/status_effect/sigil_mark/tick()
	if(owner.stat < stat_allowed)
		qdel(src)

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/datum/status_effect/tagalong //applied to darkspawns while they accompany someone
	id = "tagalong"
	duration = -1
	tick_interval = 1 //as fast as possible
	alert_type = /obj/screen/alert/status_effect/tagalong
	var/mob/living/shadowing
	var/turf/cached_location //we store this so if the mob is somehow gibbed we aren't put into nullspace

/datum/status_effect/tagalong/on_creation(mob/living/owner, mob/living/tag)
	. = ..()
	if(!.)
		return
	shadowing = tag

/datum/status_effect/tagalong/on_remove()
	if(owner.loc == shadowing)
		owner.forceMove(cached_location ? cached_location : get_turf(owner))
		shadowing.visible_message("<span class='warning'>[owner] breaks away from [shadowing]'s shadow!</span>", \
		"<span class='userdanger'>You feel a sense of freezing cold pass through you!</span>", ignore_mob = owner)
		to_chat(owner, "<span class='velvet'>You break away from [shadowing].</span>")
	playsound(owner, 'sound/magic/devour_will_form.ogg', 50, TRUE)
	owner.setDir(SOUTH)

/datum/status_effect/tagalong/process()
	if(!shadowing)
		owner.forceMove(cached_location)
		qdel(src)
		return
	cached_location = get_turf(shadowing)
	if(cached_location.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		owner.forceMove(cached_location)
		shadowing.visible_message("<span class='warning'>[owner] suddenly appears from the dark!</span>", ignore_mob = owner)
		to_chat(owner, "<span class='warning'>You are forced out of [shadowing]'s shadow!</span>")
		owner.Knockdown(30)
		qdel(src)
	var/obj/item/I = owner.get_active_held_item()
	if(I)
		to_chat(owner, "<span class='userdanger'>Equipping an item forces you out!</span>")
		if(istype(I, /obj/item/dark_bead))
			if(owner.ckey == "zaross")
				to_chat(owner, "<span class='userdanger'>Nice try, but no!</span>")
			else
				to_chat(owner, "<span class='userdanger'>[I] crackles with feedback, briefly disorienting you!</span>")
			owner.Stun(5) //short delay so they can't click as soon as they're out
		qdel(src)

/obj/screen/alert/status_effect/tagalong
	name = "Tagalong"
	desc = "You are accompanying TARGET_NAME. Use the Tagalong ability to break away at any time."
	icon_state = "shadow_mend"

/obj/screen/alert/status_effect/tagalong/MouseEntered()
	var/datum/status_effect/tagalong/tagalong = attached_effect
	desc = replacetext(desc, "TARGET_NAME", tagalong.shadowing.real_name)
	..()
	desc = initial(desc)
