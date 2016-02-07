//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability, or protects your vision from flashes."
	helptext = "Grants us thermal vision or flash protection. We will become a lot more vulnerable to flash-based devices while thermal vision is active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	var/active = 0 //Whether or not vision is enhanced

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.getorgan(/obj/item/organ/internal/cyberimp/eyes/thermals/ling))
		user << "<span class='notice'>Our eyes are protected from flashes.</span>"
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/shield/ling()
		O.Insert(user)

	else
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling()
		O.Insert(user)

	return 1


/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user)
	var/obj/item/organ/internal/cyberimp/eyes/O = user.getorganslot("eye_ling")
	if(O)
		O.Remove(user)
		qdel(O)


/obj/item/organ/internal/cyberimp/eyes/shield/ling
	name = "protective membranes"
	desc = "These variable transparency organic membranes will protect you from welders and flashes and heal your eye damage."
	icon_state = "ling_eyeshield"
	eye_color = null
	implant_overlay = null
	origin_tech = "biotech=4"
	slot = "eye_ling"
	status = ORGAN_ORGANIC

/obj/item/organ/internal/cyberimp/eyes/shield/ling/on_life()
	..()
	if(owner.eye_blind>1 || (owner.eye_blind && owner.stat !=UNCONSCIOUS) || owner.eye_damage || owner.eye_blurry || (owner.disabilities & NEARSIGHT))
		owner.reagents.add_reagent("oculine", 1)

/obj/item/organ/internal/cyberimp/eyes/shield/ling/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("oculine", 15)
	return S


/obj/item/organ/internal/cyberimp/eyes/thermals/ling
	name = "heat receptors"
	desc = "These heat receptors dramatically increases eyes light sensing ability."
	icon_state = "ling_thermal"
	eye_color = null
	implant_overlay = null
	origin_tech = "biotech=5;magnets=5"
	slot = "eye_ling"
	status = ORGAN_ORGANIC
	aug_message = "You feel a minute twitch in our eyes, and darkness creeps away."

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/emp_act(severity)
	return

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/Insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 1

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 0
	..()