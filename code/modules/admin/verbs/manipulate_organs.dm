/client/proc/manipulate_organs(mob/living/carbon/C in world)
	set name = "Manipulate Organs"
	set category = "Debug"
	var/operation = input("Select organ operation.", "Organ Manipulation", "cancel") in list("add organ", "add implant", "drop organ/implant", "remove organ/implant", "cancel")

	var/list/organs = list()
	switch(operation)
		if("add organ")
			for(var/path in typesof(/obj/item/organ/internal) - /obj/item/organ/internal)
				var/dat = replacetext("[path]", "/obj/item/organ/internal/", ":")
				organs[dat] = path

			var/obj/item/organ/internal/organ = input("Select organ type:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			organ = new organ
			organ.Insert(C)

		if("add implant")
			for(var/path in typesof(/obj/item/weapon/implant) - /obj/item/weapon/implant)
				var/dat = replacetext("[path]", "/obj/item/weapon/implant/", ":")
				organs[dat] = path

			var/obj/item/weapon/implant/organ = input("Select implant type:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			organ = new organ
			organ.implant(C)

		if("drop organ/implant", "remove organ/implant")
			for(var/obj/item/organ/internal/I in C.internal_organs)
				organs["[I.name] ([I.type])"] = I

			for(var/obj/item/weapon/implant/I in C)
				organs["[I.name] ([I.type])"] = I

			var/obj/item/organ = input("Select organ/implant:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			if(!organ) return
			var/obj/item/organ/internal/O
			var/obj/item/weapon/implant/I

			if(isorgan(organ))
				O = organ
				O.Remove(C)
			else
				I = organ
				I.removed(C)

			organ.loc = get_turf(C)

			if(operation == "remove organ/implant")
				qdel(organ)
			else if(I) // Put the implant in case.
				var/obj/item/weapon/implantcase/case = new(get_turf(C))
				case.imp = I
				I.loc = case
				case.update_icon()