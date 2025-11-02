/datum/antagonist/blood_worm
	name = "\improper Blood Worm"
	roundend_category = "blood worms"
	antagpanel_category = ANTAG_GROUP_BLOODY
	pref_flag = ROLE_BLOOD_WORM
	antag_hud_name = "blood_worm"
	antag_moodlet = /datum/mood_event/blood_worm
	show_to_ghosts = TRUE

/datum/antagonist/blood_worm/greet()
	. = ..()

	to_chat(owner, span_bold("A species of space-faring leech, massive in size and ferocious in hunting.\n\
							Your origins are unknown to most, but to some, you are among their greatest creations.\n\
							A failed Syndicate bioweapons project, snuffed out by benefactors after a \"lack of results\", and yet.\n\
							Here you find yourself. On a NanoTrasen space station. What a fitting habitat for you, isn't it?"))
	to_chat(owner, span_bolddanger("KILL, CONSUME, MULTIPLY, CONQUER."))

	owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner), 'sound/effects/magic/exit_blood.ogg', vol = 80, vary = FALSE)

/datum/antagonist/blood_worm/on_gain()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/blood_worm))
	return ..()

/datum/antagonist/blood_worm/apply_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	add_team_hud(target)

	if (!istype(target, /mob/living/basic/blood_worm))
		target.faction |= FACTION_BLOOD_WORM

/datum/antagonist/blood_worm/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current

	if (!istype(target, /mob/living/basic/blood_worm))
		target.faction -= FACTION_BLOOD_WORM

/datum/antagonist/blood_worm/admin_add(datum/mind/new_owner, mob/admin)
	if (!new_owner.current)
		return

	if (!istype(new_owner.current, /mob/living/basic/blood_worm))
		var/old_mob = new_owner.current

		var/mob/living/basic/blood_worm/hatchling/new_worm = new(get_turf(new_owner.current))
		new_owner.transfer_to(new_worm, force_key_move = TRUE)

		qdel(old_mob)

	return ..()

/datum/antagonist/blood_worm/get_preview_icon()
	var/icon/icon = icon('icons/mob/nonhuman-player/blood_worm.dmi', "juvenile")

	icon.Crop(1, 1, 32, 28)
	icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon
