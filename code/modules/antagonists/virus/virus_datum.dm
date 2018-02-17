/datum/antagonist/virus
	name = "Virus"
	roundend_category = "viruses"
	antagpanel_category = "Virus"

/datum/antagonist/virus/roundend_report()
	. = ..()

/datum/antagonist/virus/greet()

/*
/datum/antagonist/virus/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [new_owner.current] into [name].")
	log_admin("[key_name(admin)] made [new_owner.current] into [name].")
	new_owner.add_antag_datum(src)
*/
/datum/antagonist/virus/on_gain()
	var/mob/camera/virus/V
	if(!istype(owner.current, /mob/camera/virus))
		V = new /mob/camera/virus()
		owner.transfer_to(V, TRUE)
	else
		V = owner.current

	var/mob/living/carbon/C = pick(GLOB.carbon_list)
	V.force_infect(C)

	var/datum/objective/virus_infect/O = new/datum/objective/virus_infect()
	O.owner = owner
	objectives += O
	owner.objectives += O
	. = ..()

/datum/antagonist/virus/apply_innate_effects(mob/living/mob_override)


/datum/antagonist/virus/antag_listing_status()
	. = ..()


/datum/objective/virus_infect
	explanation_text = "Infect as many people as possible"

/datum/objective/virus_infect/check_completion()
	return TRUE