/obj/item/skillchip/job/command_bodyguard
	name = "6U4RD skillchip"
	desc = "A biochip which teaches you a fisticuffs fighting technique, allowing the user to subdue enemies with only their fists... yet lose their ability to use guns."
	skill_name = "Lawful Evil Boxing"
	skill_description = "A long-taught method of fighting, designed to protect others and subdue enemies, at the cost of parting ways with the brutish guns and lasers"
	skill_icon = "face-smile"
	activate_message = span_notice("You can visualize what it takes to subdue a target with your fists.")
	deactivate_message = span_notice("You forget a past martial arts, your fists lose their elegance.")
	/// The CQC given by the skillchip.
	var/datum/martial_art/boxing/evil/command_bodyguard/style

/obj/item/skillchip/job/command_bodyguard/Initialize(mapload)
	. = ..()
	style = new

/obj/item/skillchip/job/command_bodyguard/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	style.teach(user)

/obj/item/skillchip/job/command_bodyguard/on_deactivate(mob/living/carbon/user, silent = FALSE)
	style.unlearn(user)
	return ..()

/// Command bodyguard's martial arts (evil boxing)
/datum/martial_art/boxing/evil/command_bodyguard
	name = "Lawful Evil Boxing"
	boxing_traits = list(TRAIT_BOXING_READY, TRAIT_NOGUNS)
