/obj/item/skillchip/chameleon
	name = "Chameleon skillchip"
	desc = "A highly advanced Syndicate skillchip that does nothing on its own. It is loaded with the data of every skillchip."
	skill_name = "Imitate Skillchip"
	skill_description = "Reacts to the user's thoughts, selecting a skill from a wide database of choices."
	skill_icon = "microchip"
	removable = FALSE
	/// Action for the skillchip selection.
	var/datum/action/item_action/chameleon/change/skillchip/chameleon_action

/obj/item/skillchip/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/skillchip/chameleon/on_apply(mob/living/carbon/user, silent = TRUE)
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/skillchip
	chameleon_action.chameleon_name = "Skillchip"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/skillchip/chameleon, /obj/item/skillchip), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

	chameleon_action.Grant(user);

/obj/item/skillchip/chameleon/on_removal(mob/living/carbon/user, silent = TRUE)
	chameleon_action.Remove(user)
	QDEL_NULL(chameleon_action)

/datum/action/item_action/chameleon/change/skillchip
	/// Skillchip this this chameleon action is imitating.
	var/obj/item/skillchip/skillchip_mimic

/datum/action/item_action/chameleon/change/skillchip/initialize_disguises()
	. = ..()

	if(button)
		button.name = "Change [chameleon_name] Function"

/datum/action/item_action/chameleon/change/skillchip/update_item(obj/item/skillchip/picked_item)
	if(istype(picked_item))
		target.name = initial(picked_item.skill_name)
		target.desc = initial(picked_item.skill_description)
		target.icon_state = initial(picked_item.skill_icon)

/datum/action/item_action/chameleon/change/skillchip/update_look(mob/user, obj/item/skillchip/picked_item)
	// Swap out the fake skillchips.
	if(skillchip_mimic && istype(skillchip_mimic))
		skillchip_mimic.on_removal(user, silent = FALSE)
		QDEL_NULL(skillchip_mimic)

	skillchip_mimic = new picked_item()
	if(istype(skillchip_mimic))
		skillchip_mimic.on_apply(user, silent = FALSE)

	..()

/datum/action/item_action/chameleon/change/skillchip/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/pda/agent_pda = target
	if(istype(agent_pda) && istype(job_datum))
		agent_pda.ownjob = job_datum.title
