///a malkavian bloodsucker that has entered final death. does nothing, other than signify they suck
/datum/antagonist/shaded_bloodsucker
	name = "\improper Shaded Bloodsucker"
	antagpanel_category = "Bloodsucker"
	show_in_roundend = FALSE
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "bloodsucker"

/obj/item/soulstone/bloodsucker
	theme = THEME_WIZARD
	required_role = /datum/antagonist/vassal //vassals can free their master

/obj/item/soulstone/bloodsucker/init_shade(mob/living/carbon/human/victim, mob/user, message_user = FALSE, mob/shade_controller)
	. = ..()
	for(var/mob/shades in contents)
		shades.mind.add_antag_datum(/datum/antagonist/shaded_bloodsucker)

/obj/item/soulstone/bloodsucker/capture_soul(mob/living/carbon/victim, mob/user, forced = FALSE, datum/antagonist/bloodsucker/bloodsuckerdatum)
	. = ..()
	for(var/mob/shades in contents)
		var/datum/antagonist/shaded_bloodsucker/shaded_datum = shades.mind.has_antag_datum(/datum/antagonist/shaded_bloodsucker)
		shaded_datum.objectives = bloodsuckerdatum.objectives

/*
/obj/item/soulstone/bloodsucker/get_ghost_to_replace_shade(mob/living/carbon/victim, mob/user)
	var/mob/dead/observer/chosen_ghost = victim.get_ghost(FALSE, TRUE)
	if(QDELETED(chosen_ghost?.client))
		victim.dust()
		return FALSE
	victim.unequip_everything()
	init_shade(victim, user, shade_controller = chosen_ghost)
	return TRUE
*/
