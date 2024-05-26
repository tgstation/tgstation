/obj/item/skillchip/job/warden
	name = "JUST1C3 skillchip"
	desc = "This biochip radiates justice, which fills you with confidence, with this wedged in your brain you be able to enforce justice."
	skill_name = "Krav Maga"
	skill_description = "A specialised form of self defence, developed by skilled wardens that will make the brig their playground."
	skill_icon = "handcuffs"
	activate_message = "<span class='notice'>You can visualize how to defend your brig with martial arts.</span>"
	deactivate_message = "<span class='notice'>You forget how to control your muscles to execute kicks, slams and restraints while in a Security environment.</span>"
	/// The Warden Krav Maga given by the skillchip.
	var/datum/martial_art/krav_maga/warden/style

/obj/item/skillchip/job/warden/Initialize(mapload)
	. = ..()
	style = new
	style.refresh_valid_areas()

/obj/item/skillchip/job/warden/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	style.teach(user, make_temporary = TRUE)

/obj/item/skillchip/job/warden/on_deactivate(mob/living/carbon/user, silent = FALSE)
	style.fully_remove(user)
	return ..()
