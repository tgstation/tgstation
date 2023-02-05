/client/proc/manipulate_organs(mob/living/carbon/C in world)
	set name = "Manipulate Organs"
	set category = "Debug"
	var/operation = tgui_input_list(usr, "Select organ operation", "Organ Manipulation", list("add organ", "add implant", "drop organ/implant", "remove organ/implant"))
	if (isnull(operation))
		return

	var/list/organs = list()
	switch(operation)
		if("add organ")
			for(var/path in subtypesof(/obj/item/organ))
				var/dat = replacetext("[path]", "/obj/item/organ/", ":")
				organs[dat] = path

			var/obj/item/organ/organ = tgui_input_list(usr, "Select organ type", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			organ = new organ
			organ.Insert(C)
			log_admin("[key_name(usr)] has added organ [organ.type] to [key_name(C)]")
			message_admins("[key_name_admin(usr)] has added organ [organ.type] to [ADMIN_LOOKUPFLW(C)]")

		if("add implant")
			for(var/path in subtypesof(/obj/item/implant))
				var/dat = replacetext("[path]", "/obj/item/implant/", ":")
				organs[dat] = path

			var/obj/item/implant/organ = tgui_input_list(usr, "Select implant type", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			organ = new organ
			organ.implant(C)
			log_admin("[key_name(usr)] has added implant [organ.type] to [key_name(C)]")
			message_admins("[key_name_admin(usr)] has added implant [organ.type] to [ADMIN_LOOKUPFLW(C)]")

		if("drop organ/implant", "remove organ/implant")
			for(var/obj/item/organ/user_organs as anything in C.internal_organs)
				organs["[user_organs.name] ([user_organs.type])"] = user_organs

			for(var/obj/item/implant/user_implants as anything in C.implants)
				organs["[user_implants.name] ([user_implants.type])"] = user_implants

			var/obj/item/organ = tgui_input_list(usr, "Select organ/implant", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			var/obj/item/organ/O
			var/obj/item/implant/I

			log_admin("[key_name(usr)] has removed [organ.type] from [key_name(C)]")
			message_admins("[key_name_admin(usr)] has removed [organ.type] from [ADMIN_LOOKUPFLW(C)]")

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
				var/obj/item/implantcase/case = new(get_turf(C))
				case.imp = I
				I.forceMove(case)
				case.update_appearance()
