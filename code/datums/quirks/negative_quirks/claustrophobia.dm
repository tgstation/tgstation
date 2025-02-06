/datum/quirk/claustrophobia
	name = "Claustrophobia"
	desc = "You are terrified of small spaces and certain jolly figures. If you are placed inside any container, locker, or machinery, a panic attack sets in and you struggle to breathe."
	icon = FA_ICON_BOX_OPEN
	value = -4
	medical_record_text = "Patient demonstrates a fear of tight spaces."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/syringe/convermol) // to help breathing
	maximum_process_stat = SOFT_CRIT
	no_process_traits = list(TRAIT_MIND_TEMPORARILY_GONE, TRAIT_FEARLESS, TRAIT_KNOCKEDOUT)

/datum/quirk/claustrophobia/remove()
	quirk_holder.clear_mood_event("claustrophobia")

/datum/quirk/claustrophobia/process(seconds_per_tick)
	var/nick_spotted = FALSE

	for(var/mob/living/carbon/human/possible_claus in view(5, quirk_holder))
		if(evaluate_jolly_levels(possible_claus))
			nick_spotted = TRUE
			break

	if(!nick_spotted && isturf(quirk_holder.loc))
		quirk_holder.clear_mood_event("claustrophobia")
		return

	quirk_holder.add_mood_event("claustrophobia", /datum/mood_event/claustrophobia)
	quirk_holder.losebreath += 0.25 // miss a breath one in four times
	if(SPT_PROB(25, seconds_per_tick))
		if(nick_spotted)
			to_chat(quirk_holder, span_warning("Santa Claus is here! I gotta get out of here!"))
		else
			to_chat(quirk_holder, span_warning("You feel trapped!  Must escape... can't breathe..."))

///investigates whether possible_saint_nick possesses a high level of christmas cheer
/datum/quirk/claustrophobia/proc/evaluate_jolly_levels(mob/living/carbon/human/possible_saint_nick)
	if(!istype(possible_saint_nick))
		return FALSE

	if(istype(possible_saint_nick.back, /obj/item/storage/backpack/santabag))
		return TRUE

	if(istype(possible_saint_nick.head, /obj/item/clothing/head/costume/santa) || istype(possible_saint_nick.head,  /obj/item/clothing/head/helmet/space/santahat))
		return TRUE

	if(istype(possible_saint_nick.wear_suit, /obj/item/clothing/suit/space/santa))
		return TRUE

	return FALSE
