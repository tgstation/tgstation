/client/proc/manipulate_organs(mob/living/carbon/carbon_victim in world)
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

			var/obj/item/organ/organ_to_grant = tgui_input_list(usr, "Select organ type", "Organ Manipulation", organs)
			if(isnull(organ_to_grant))
				return
			if(isnull(organs[organ_to_grant]))
				return
			organ_to_grant = organs[organ_to_grant]
			organ_to_grant = new organ_to_grant
			if(!organ_to_grant.Insert(carbon_victim))
				to_chat(usr, span_notice("[carbon_victim] is unable to carry this organ!"))
				qdel(organ_to_grant)
				return
			log_admin("[key_name(usr)] has added organ [organ_to_grant.type] to [key_name(carbon_victim)]")
			message_admins("[key_name_admin(usr)] has added organ [organ_to_grant.type] to [ADMIN_LOOKUPFLW(carbon_victim)]")

		if("add implant")
			for(var/path in subtypesof(/obj/item/implant))
				var/dat = replacetext("[path]", "/obj/item/implant/", ":")
				organs[dat] = path

			var/obj/item/implant/implant_to_grant = tgui_input_list(usr, "Select implant type", "Organ Manipulation", organs)
			if(isnull(implant_to_grant))
				return
			if(isnull(organs[implant_to_grant]))
				return
			implant_to_grant = organs[implant_to_grant]
			implant_to_grant = new implant_to_grant
			if(!implant_to_grant.implant(carbon_victim))
				to_chat(usr, span_notice("[carbon_victim] is unable to hold this implant!"))
				qdel(implant_to_grant)
				return
			log_admin("[key_name(usr)] has added implant [implant_to_grant.type] to [key_name(carbon_victim)]")
			message_admins("[key_name_admin(usr)] has added implant [implant_to_grant.type] to [ADMIN_LOOKUPFLW(carbon_victim)]")

		if("drop organ/implant", "remove organ/implant")
			for(var/obj/item/organ/user_organs as anything in carbon_victim.organs)
				organs["[user_organs.name] ([user_organs.type])"] = user_organs

			for(var/obj/item/implant/user_implants as anything in carbon_victim.implants)
				organs["[user_implants.name] ([user_implants.type])"] = user_implants

			var/obj/item/organ_to_modify = tgui_input_list(usr, "Select organ/implant", "Organ Manipulation", organs)
			if(isnull(organ_to_modify))
				return
			if(isnull(organs[organ_to_modify]))
				return
			organ_to_modify = organs[organ_to_modify]

			log_admin("[key_name(usr)] has removed [organ_to_modify.type] from [key_name(carbon_victim)]")
			message_admins("[key_name_admin(usr)] has removed [organ_to_modify.type] from [ADMIN_LOOKUPFLW(carbon_victim)]")

			var/obj/item/organ/organ_holder
			var/obj/item/implant/implant_holder

			if(isorgan(organ_to_modify))
				organ_holder = organ_to_modify
				organ_holder.Remove(carbon_victim)
			else
				implant_holder = organ_to_modify
				implant_holder.removed(carbon_victim)

			organ_to_modify.forceMove(get_turf(carbon_victim))

			if(operation == "remove organ/implant")
				qdel(organ_to_modify)
			else if(implant_holder) // Put the implant in case.
				var/obj/item/implantcase/case = new(get_turf(carbon_victim))
				case.imp = implant_holder
				implant_holder.forceMove(case)
				case.update_appearance()
