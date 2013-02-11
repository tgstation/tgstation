//WORK IN PROGRESS

/mob/living/carbon
	var/list/surgeries = list()
	var/list/internal_organs = list()

/mob/living/carbon/New()
	..()
	internal_organs += new /obj/item/organ/appendix
	internal_organs += new /obj/item/organ/heart

/mob/living/carbon/human/attackby(obj/item/I, mob/user)
	if(lying)	//if they're prone
		if(istype(I, /obj/item/weapon/bedsheet))
			var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in (typesof(/datum/surgery) - /datum/surgery)
			var/datum/surgery/procedure = new P
			if(procedure)
				surgeries += procedure
			return

		else if(surgeries.len)
			var/success = 0
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					success = 1
			if(success)
				return

	..()