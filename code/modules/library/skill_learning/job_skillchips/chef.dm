/obj/item/skillchip/job/chef
	name = "B0RK-X3 skillchip" // bork bork bork
	desc = "This biochip faintly smells of garlic, which is odd for something that is normally wedged inside a user's brain. Consult a dietician before use."
	skill_name = "Close Quarters Cooking"
	skill_description = "A specialised form of self defence, developed by skilled sous-chef de cuisines. No man fights harder than a chef to defend his kitchen."
	skill_icon = "utensils"
	activate_message = span_notice("You can visualize how to defend your kitchen with martial arts.")
	deactivate_message = span_notice("You forget how to control your muscles to execute kicks, slams and restraints while in a kitchen environment.")
	/// The Chef CQC given by the skillchip.
	var/datum/martial_art/cqc/under_siege/style

/obj/item/skillchip/job/chef/Initialize(mapload)
	. = ..()
	style = new
	style.refresh_valid_areas()

/obj/item/skillchip/job/chef/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	style.teach(user, make_temporary = TRUE)

/obj/item/skillchip/job/chef/on_deactivate(mob/living/carbon/user, silent = FALSE)
	style.fully_remove(user)
	return ..()
