/datum/action/cooldown/spell/florida_regeneration
	name = "Lesser Narcotimancy"
	desc = "Instantly releases a large amount of random drugs into your blood. May or may not be helpful."
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	var/list/drug_types = list(	/datum/reagent/drug/space_drugs, /datum/reagent/drug/kronkaine,
								/datum/reagent/drug/krokodil, /datum/reagent/drug/methamphetamine,
								/datum/reagent/drug/bath_salts, /datum/reagent/drug/happiness,
								/datum/reagent/colorful_reagent, /datum/reagent/medicine/adminordrazine/quantum_heal,
								/datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/omnizine,
								/datum/reagent/medicine/pen_acid, /datum/reagent/medicine/sal_acid,
								/datum/reagent/medicine/mannitol, /datum/reagent/medicine/mutadone,
								/datum/reagent/drug/maint/tar, /datum/reagent/drug/maint/sludge,
								/datum/reagent/medicine/c2/libital, /datum/reagent/medicine/c2/probital,
								/datum/reagent/medicine/c2/lenturi,/datum/reagent/medicine/c2/aiuri,)
	button_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	button_icon_state = "lesser_narcomancy"

/datum/action/cooldown/spell/florida_regeneration/cast(mob/living/carbon/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		return
	var/mob/living/carbon/human/H = cast_on
	cast_on.visible_message("<span class='warning'>[cast_on] blinks rapidly and shivers violently!</span>", "<span class='notice'>You summon up hidden reserves of drugs stored within your body.</span>")
	H.reagents.add_reagent(pick(drug_types), 9)

/datum/action/cooldown/spell/florida_cuff_break
	name = "Break These Cuffs"
	desc = "You CAN break those cuffs!"
	cooldown_time = 2 MINUTES
	spell_requirements = NONE
	button_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	button_icon_state = "break_cuffs"


/datum/action/cooldown/spell/florida_cuff_break/cast(mob/living/carbon/cast_on)
	. = ..()
	var/obj/O = cast_on.get_item_by_slot(ITEM_SLOT_HANDCUFFED)

	if(!ishuman(cast_on))
		return
	var/mob/living/carbon/human/H = cast_on

	if(!HAS_TRAIT(H, TRAIT_RESTRAINED))
		to_chat(cast_on, "<span class='warning'>You strain your muscles to break your handcuffs, but realize you aren't wearing any!</span>")
		return 0

	if(O && H.handcuffed == O)
		if(!istype(O))
			return 0
		cast_on.visible_message("<span class='warning'>[cast_on] shatters their handcuffs in a rage!</span>", "<span class='notice'>You break your handcuffs!</span>")
		playsound(H, 'sound/effects/bang.ogg', 50)
		qdel(O)

/datum/action/cooldown/spell/florida_doorbuster
	name = "Sovereign Citizen"
	desc = "Use the power of Florida to push your way through"
	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	button_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	button_icon_state = "sovereign_citizen"


/datum/action/cooldown/spell/florida_doorbuster/cast(mob/living/carbon/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		return
	var/mob/living/carbon/human/floridan = cast_on
	playsound(floridan, 'sound/voice/human/wilhelm_scream.ogg', 50, TRUE)
	floridan.visible_message(span_warning("[floridan] howls in rage as he begins to charge!"), span_notice("You feel the strength of Florida wash over you, push through those doors!"))
	floridan.move_force = MOVE_FORCE_OVERPOWERING
	addtimer(CALLBACK(src, PROC_REF(end_florida_doorbuster)),5 SECONDS)

/datum/action/cooldown/spell/florida_doorbuster/proc/end_florida_doorbuster()
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/floridan = usr
	floridan.move_force = MOVE_FORCE_NORMAL
	floridan.visible_message(span_warning("[floridan] seems to be calmer."), span_warning("You feel weaker as the strength of Florida leaves you."))
