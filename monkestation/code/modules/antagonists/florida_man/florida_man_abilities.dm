/obj/effect/proc_holder/spell/targeted/florida_regeneration
	name = "Lesser Narcotimancy"
	desc = "Instantly releases a large amount of random drugs into your blood. May or may not be helpful."
	charge_counter = 0
	charge_max = 30 SECONDS
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	charge_type = "recharge"
	var/list/drug_types = list(	/datum/reagent/drug/space_drugs, /datum/reagent/drug/crank,
								/datum/reagent/drug/krokodil, /datum/reagent/drug/methamphetamine,
								/datum/reagent/drug/bath_salts, /datum/reagent/drug/happiness,
								/datum/reagent/colorful_reagent, /datum/reagent/medicine/adminordrazine/quantum_heal,
								/datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/omnizine,
								/datum/reagent/medicine/pen_acid, /datum/reagent/medicine/sal_acid,
								/datum/reagent/medicine/mannitol, /datum/reagent/medicine/mutadone,
								/datum/reagent/medicine/amphetamine, /datum/reagent/medicine/pumpup,
								/datum/reagent/medicine/bicaridine, /datum/reagent/medicine/dexalin,
								/datum/reagent/medicine/kelotane, /datum/reagent/medicine/tricordrazine)
	action_background_icon_state = "bg_default"
	action_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	action_icon_state = "lesser_narcomancy"

/obj/effect/proc_holder/spell/targeted/florida_regeneration/cast(list/targets, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='warning'>[user] blinks rapidly and shivers violently!</span>", "<span class='notice'>You summon up hidden reserves of drugs stored within your body.</span>")
	H.reagents.add_reagent(pick(drug_types), 9)

/obj/effect/proc_holder/spell/targeted/florida_cuff_break
	name = "Break These Cuffs"
	desc = "You CAN break those cuffs!"
	charge_counter = 0
	charge_max = 2 MINUTES
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	charge_type = "recharge"
	action_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	action_icon_state = "break_cuffs"
	action_background_icon_state = "bg_default"


/obj/effect/proc_holder/spell/targeted/florida_cuff_break/cast(list/targets, mob/user)
	var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(!HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You strain your muscles to break your handcuffs, but realize you aren't wearing any!</span>")
		return 0

	if(O && H.handcuffed == O)
		if(!istype(O))
			return 0
		user.visible_message("<span class='warning'>[user] shatters their handcuffs in a rage!</span>", "<span class='notice'>You break your handcuffs!</span>")
		playsound(H, 'sound/effects/bang.ogg', 50)
		qdel(O)

/obj/effect/proc_holder/spell/targeted/florida_doorbuster
	name = "Sovereign Citizen"
	desc = "Use the power of Florida to push your way through"
	charge_counter = 0
	charge_max = 1 MINUTES
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	charge_type = "recharge"
	action_icon = 'monkestation/icons/mob/actions/florida_man.dmi'
	action_icon_state = "sovereign_citizen"
	action_background_icon_state = "bg_default"


/obj/effect/proc_holder/spell/targeted/florida_doorbuster/cast(list/targets, mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/floridan = user
	playsound(floridan, 'sound/voice/human/wilhelm_scream.ogg', 50, TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
	floridan.visible_message("<span class='warning'>[floridan] howls in rage as he begins to charge!</span>", "<span class='notice'>You feel the strength of Florida wash over you, push through those doors!</span>")
	floridan.move_force = MOVE_FORCE_OVERPOWERING
	addtimer(CALLBACK(src, .proc/end_florida_doorbuster),5 SECONDS)

/obj/effect/proc_holder/spell/targeted/florida_doorbuster/proc/end_florida_doorbuster()
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/floridan = usr
	floridan.move_force = MOVE_FORCE_NORMAL
	floridan.visible_message("<span class='warning'>[floridan] seems to be calmer.</span>", "<span class='warning'>You feel weaker as the strength of Florida leaves you.</span>")
