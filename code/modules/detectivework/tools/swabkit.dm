

/obj/item/forensics/swabkit
	name = "swab and vial"
	desc = "A swab, for collecting saliva and DNA, and a vial to store it in"
	icon_state = "swab"
	var/stype = BLOOD_SWAB
	var/scontents = "nothing"

/obj/item/forensics/swabkit/Initialize(mapload, typ, content)
	. = ..()
	if (typ && content) //We're creating a used swab
		src.icon_state = "swab_used"
		src.stype = typ
		src.scontents = content

	qdel(location)
	qdel(typ)
	qdel(content)
	return

/obj/item/forensics/swabkit/afterattack(atom/A, mob/user, params)
	if(user.zone_selected == "mouth" && ishuman(A)) //we're getting saliva from the mouth
		var/mob/living/carbon/human/H = A
		to_chat(user, "<span class='notice'>We swab [A]'s mouth for saliva, and seal the swab in the vial.</span>")
		new /obj/item/forensics/swabkit(get_turf(src), DNA_SWAB, md5(H.dna.uni_identity))
		qdel(src)
		return
	else if(!ishuman(A))
		var/list/blood = list()
		if(A.reagents && A.reagents.reagent_list.len) //turn back here if you hate shitty unreadable code
			for(var/datum/reagent/R in A.reagents.reagent_list)
				reagents[R.name] = R.volume
				// Get blood data from the blood reagent.
				if(istype(R, /datum/reagent/blood))
					if(R.data["blood_DNA"] && R.data["blood_type"])
						var/blood_DNA = R.data["blood_DNA"]
						var/blood_type = R.data["blood_type"]
						blood[blood_DNA] = blood_type
		else
			to_chat(user, "<span class='notice'>We couldn't find anything on the [A].</span>")

		if (blood.len)
			to_chat(user, "<span class='notice'>We seal the blood we found on the [A]/</span>")
			new /obj/item/forensics/swabkit(get_turf(user), BLOOD_SWAB, blood)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>We found no blood on the \[A]./</span>")

		return

