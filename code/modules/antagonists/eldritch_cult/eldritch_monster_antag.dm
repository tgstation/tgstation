///Tracking reasons
/datum/antagonist/heretic_monster
	name = "Eldritch Horror"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_type = ANTAG_HUD_HERETIC
	antag_hud_name = "heretic_beast"
	var/datum/antagonist/master

/datum/antagonist/heretic_monster/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic_monster/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You became an Eldritch Horror!</span>")

/datum/antagonist/heretic_monster/on_removal()
	if(master)
		to_chat(master, "<span class='boldannounce'>Your master is no longer [master.owner.current.real_name]</span>")
		master = null
	return ..()

/datum/antagonist/heretic_monster/proc/set_owner(datum/antagonist/_master)
	master = _master
	var/datum/objective/master_obj = new
	master_obj.owner = src
	master_obj.explanation_text = "Assist your master in any way you can!"
	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, "<span class='boldannounce'>Your master is [master.owner.current.real_name]</span>")
	return

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	remove_antag_hud(antag_hud_type, owner.current)
