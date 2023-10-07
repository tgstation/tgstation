/datum/antagonist/slasher
	name = "\improper Slasher"
	show_in_antagpanel = TRUE
	roundend_category = "slashers"
	antagpanel_category = "Slasher"
	job_rank = ROLE_SLASHER
	antag_hud_name = "slasher"
	show_name_in_check_antagonists = TRUE
	hud_icon = 'monkestation/icons/mob/slasher.dmi'

	var/obj/item/slasher_machette/linked_machette

/datum/antagonist/slasher/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	ADD_TRAIT(current_mob, TRAIT_BATON_RESISTANCE, "slasher")

	///abilities galore
	var/datum/action/cooldown/slasher/summon_machette/machete = new
	machete.Grant(current_mob)
	var/datum/action/cooldown/slasher/blood_walk/blood_walk = new
	blood_walk.Grant(current_mob)
	var/datum/action/cooldown/slasher/incorporealize/incorporealize = new
	incorporealize.Grant(current_mob)
	var/datum/action/cooldown/slasher/soul_steal/soul_steal = new
	soul_steal.Grant(current_mob)
