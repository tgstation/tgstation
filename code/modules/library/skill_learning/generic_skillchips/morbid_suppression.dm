/obj/item/skillchip/morbid_suppression
	name = "S0C-14L suppression chip"
	desc = "Similar to a skillchip, but operating with the reverse logic. Once installed into the brain, the chip acts as a \
		neural regulator, suppressing any desires or thought patterns deemed to be 'anti-social'. Some consider this a clear \
		sign of indoctrination. But for others, this proves to be the only means to obtaining a relatively normal and stable \
		life amongst the stars. Doesn't seem to suppress felinid feralization syndrome, much to the chagrin of medical professionals \
		everywhere."
	skill_name = "Mental Stability"
	skill_description = "Helps you to keep yourself under control."
	skill_icon = FA_ICON_USER_DOCTOR
	activate_message = span_notice("You feel fine. Everything is fine. The chip is working. You can have a normal day at work now.")
	deactivate_message = span_warning("You feel your mind become vulnerable to it's deepest desires...")
	removable = FALSE
	no_deactivation = TRUE
	cooldown = 1 SECONDS
	// If the chip actually removed the trait on activation, we will readd it on extraction. If you were never morbid, nothing changes.
	var/removed_trait = FALSE

/obj/item/skillchip/morbid_suppression/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && user.mind)
		REMOVE_TRAIT(user.mind, TRAIT_MORBID, type)
		removed_trait = TRUE

/obj/item/skillchip/morbid_suppression/on_deactivate(mob/living/carbon/user, silent = FALSE)
	. = ..()

	if(user.mind && removed_trait)
		ADD_TRAIT(user.mind, TRAIT_MORBID, JOB_TRAIT)
		to_chat(span_hypnophrase("The stillness of death. I must understand it again. I yearn observe it. I must learn the secrets kept within pallid flesh..."))
		removed_trait = FALSE

/obj/item/skillchip/morbid_suppression/coroner
	// This version starts true so that it will always give the trait on removal.
	removed_trait = TRUE


