/obj/item/forensics/dustkit
	name = "fingerprint powder and brush"
	desc = "A brush, with powder, for finding fingerprints."
	icon_state = "dust"

/obj/item/forensics/dustkit/afterattack(atom/A, mob/user, params)
	var/list/prints = list()
	var/list/uprints = list()

	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(!H.gloves)
			if (do_after(user, 10, A))
				new /obj/item/forensics/printcard(get_turf(user), md5(H.dna.uni_identity))
				to_chat(user, "<span class='notice'>We get a copy of [H]'s fingerprints.</span>")
			else
				to_chat(user, "<span class='warning'>You were interrupted!</span>")
			return FALSE
		else
			to_chat(user, "<span class='notice'>We were unable to get a copy of [H]'s fingerprints..</span>")
			return FALSE

	else if(!ismob(A))
		if(LAZYLEN(A.fingerprints))
			prints = A.fingerprints.Copy()
		else
			to_chat(user, "<span class='notice'>We were unable to find any fingerprints on the [A].</span>")
			return FALSE

		if(do_after(user, 5*prints.len, A))
			for(var/print in prints)
				if( !uprints[print] )
					new /obj/item/forensics/printcard(get_turf(src), print)
					uprints[print] = TRUE

			to_chat(user, "<span class='notice'>We put all the fingerprints we find onto cards.</span>")
		else
			to_chat(user, "<span class='warning'>You were interrupted!</span>")
		return FALSE



/obj/item/forensics/printcard
	name = "fingerprint card"
	desc = "Used to hold a set of fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	var/phold = "none"

/obj/item/forensics/printcard/New(location, print)
	..()
	if (print)
		src.phold = print
		src.icon_state = "fingerprint1"