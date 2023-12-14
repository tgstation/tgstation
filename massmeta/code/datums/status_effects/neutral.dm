/datum/status_effect/tagalong //applied to darkspawns while they accompany someone //yogs start: darkspawn
	id = "tagalong"
	duration = 3000
	tick_interval = 1 //as fast as possible
	alert_type = /atom/movable/screen/alert/status_effect/tagalong
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
		"<span class='userdanger'>You feel a sense of freezing cold pass through you!</span>")
		to_chat(owner, "<span class='velvet'>You break away from [shadowing].</span>")
	playsound(owner, 'massmeta/sounds/magic/devour_will_form.ogg', 50, TRUE)
	owner.setDir(SOUTH)

/datum/status_effect/tagalong/process()
	if(!shadowing)
		owner.forceMove(cached_location)
		qdel(src)
		return
	cached_location = get_turf(shadowing)
	if(cached_location.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		owner.forceMove(cached_location)
		shadowing.visible_message("<span class='warning'>[owner] suddenly appears from the dark!</span>")
		to_chat(owner, "<span class='warning'>You are forced out of [shadowing]'s shadow!</span>")
		owner.Knockdown(30)
		qdel(src)
	var/obj/item/I = owner.get_active_held_item()
	if(I)
		to_chat(owner, "<span class='userdanger'>Equipping an item forces you out!</span>")
		if(istype(I, /obj/item/dark_bead))
			to_chat(owner, "<span class='userdanger'>[I] crackles with feedback, briefly disorienting you!</span>")
			owner.Stun(5) //short delay so they can't click as soon as they're out
		qdel(src)

/atom/movable/screen/alert/status_effect/agalong
	name = "Tagalong"
	desc = "You are accompanying TARGET_NAME. Use the Tagalong ability to break away at any time."
	icon_state = "shadow_mend"

/atom/movable/screen/alert/status_effect/tagalong/MouseEntered()
	var/datum/status_effect/tagalong/tagalong = attached_effect
	desc = replacetext(desc, "TARGET_NAME", tagalong.shadowing.real_name)
	..()
	desc = initial(desc) //yogs end
