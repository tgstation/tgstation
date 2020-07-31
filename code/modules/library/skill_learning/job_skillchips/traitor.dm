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
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/skillchip, /obj/item/skillchip/chameleon, /obj/item/skillchip/useless_adapter), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

	chameleon_action.Grant(user);

/obj/item/skillchip/chameleon/on_removal(mob/living/carbon/user, silent = TRUE)
	chameleon_action.Remove(user)
	QDEL_NULL(chameleon_action)
