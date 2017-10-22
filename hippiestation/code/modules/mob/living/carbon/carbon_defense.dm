
/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(lying || user == src)
		if(surgeries.len)
			if(user.a_intent == "help")
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	..()