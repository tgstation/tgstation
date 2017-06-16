/client/proc/manipulate_organs(mob/living/carbon/C in world)
	set name = "Manipulate Organs"
	set category = "Debug"
	var/operation = input("Select organ operation.", "Organ Manipulation", "cancel") in list("add organ", "add implant", "drop organ/implant", "remove organ/implant", "cancel")

	var/list/organs = list()
	switch(operation)
		if("add organ")
			for(var/path in subtypesof(/obj/item/organ))
				var/dat = replacetext("[path]", "/obj/item/organ/", ":")
				organs[dat] = path

			var/obj/item/organ/organ = input("Select organ type:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			organ = new organ
			organ.Insert(C)

		if("add implant")
			for(var/path in subtypesof(/obj/item/weapon/implant))
				var/dat = replacetext("[path]", "/obj/item/weapon/implant/", ":")
				organs[dat] = path

			var/obj/item/weapon/implant/organ = input("Select implant type:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			organ = new organ
			organ.implant(C)

		if("drop organ/implant", "remove organ/implant")
			for(var/X in C.internal_organs)
				var/obj/item/organ/I = X
				organs["[I.name] ([I.type])"] = I

			for(var/X in C.implants)
				var/obj/item/weapon/implant/I = X
				organs["[I.name] ([I.type])"] = I

			var/obj/item/organ = input("Select organ/implant:", "Organ Manipulation", null) in organs
			organ = organs[organ]
			if(!organ) return
			var/obj/item/organ/O
			var/obj/item/weapon/implant/I

			if(isorgan(organ))
				O = organ
				O.Remove(C)
			else
				I = organ
				I.removed(C)

			organ.forceMove(get_turf(C))

			if(operation == "remove organ/implant")
				qdel(organ)
			else if(I) // Put the implant in case.
				var/obj/item/weapon/implantcase/case = new(get_turf(C))
				case.imp = I
				I.loc = case
				case.update_icon()
