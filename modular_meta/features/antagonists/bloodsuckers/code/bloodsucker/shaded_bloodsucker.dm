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
		var/datum/antagonist/shaded_bloodsucker/shaded_datum = shades.mind.add_antag_datum(/datum/antagonist/shaded_bloodsucker)
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = victim.mind.has_antag_datum(/datum/antagonist/bloodsucker)
		if(bloodsuckerdatum)
			shaded_datum.objectives = bloodsuckerdatum.objectives

/obj/item/soulstone/bloodsucker/on_poll_concluded(mob/living/master, mob/living/victim, mob/dead/observer/ghost)
	. = ..()
	if(!.)
		victim.dust()
