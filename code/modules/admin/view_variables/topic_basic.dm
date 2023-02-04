//Not using datum.vv_do_topic for very basic/low level debug things, incase the datum's vv_do_topic is runtiming/whatnot.
/client/proc/vv_do_basic(datum/target, href_list)
	var/target_var = GET_VV_VAR_TARGET
	if(check_rights(R_VAREDIT))
		if(target_var)
			if(href_list[VV_HK_BASIC_EDIT])
				if(!modify_variables(target, target_var, 1))
					return
				switch(target_var)
					if("name")
						vv_update_display(target, "name", "[target]")
					if("dir")
						var/atom/A = target
						if(istype(A))
							vv_update_display(target, "dir", dir2text(A.dir) || A.dir)
					if("ckey")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "ckey", L.ckey || "No ckey")
					if("real_name")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "real_name", L.real_name || "No real name")

			if(href_list[VV_HK_BASIC_CHANGE])
				modify_variables(target, target_var, 0)
			if(href_list[VV_HK_BASIC_MASSEDIT])
				cmd_mass_modify_object_variables(target, target_var)
	if(check_rights(R_ADMIN, FALSE))
		if(href_list[VV_HK_EXPOSE])
			var/value = vv_get_value(VV_CLIENT)
			if (value["class"] != VV_CLIENT)
				return
			var/client/C = value["value"]
			if (!C)
				return
			if(!target)
				to_chat(usr, span_warning("The object you tried to expose to [C] no longer exists (nulled or hard-deled)"), confidential = TRUE)
				return
			message_admins("[key_name_admin(usr)] Showed [key_name_admin(C)] a <a href='?_src_=vars;datumrefresh=[REF(target)]'>VV window</a>")
			log_admin("Admin [key_name(usr)] Showed [key_name(C)] a VV window of a [target]")
			to_chat(C, "[holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window", confidential = TRUE)
			SSadmin_verbs.dynamic_invoke_admin_verb(C, /mob/admin_module_holder/debug/view_variables, target)
	if(check_rights(R_DEBUG))
		if(href_list[VV_HK_DELETE])
			usr.client.holder.admin_delete(target)
			if (isturf(target)) // show the turf that took its place
				SSadmin_verbs.dynamic_invoke_admin_verb(usr.client, /mob/admin_module_holder/debug/view_variables, target)
				return

	if(href_list[VV_HK_MARK])
		usr.client.mark_datum(target)
	if(href_list[VV_HK_TAG])
		usr.client.tag_datum(target)
	if(href_list[VV_HK_ADDCOMPONENT])
		if(!check_rights(NONE))
			return
		var/list/names = list()
		var/list/componentsubtypes = sort_list(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/result = tgui_input_list(usr, "Choose a component/element to add", "Add Component", names)
		if(isnull(result))
			return
		if(!usr || result == "---Components---" || result == "---Elements---")
			return
		if(QDELETED(src))
			to_chat(usr, "That thing doesn't exist anymore!", confidential = TRUE)
			return
		var/list/lst = get_callproc_args()
		if(!lst)
			return
		var/datumname = "error"
		lst.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(lst)
		else
			datumname = "element"
			target._AddElement(lst)
		log_admin("[key_name(usr)] has added [result] [datumname] to [key_name(target)].")
		message_admins(span_notice("[key_name_admin(usr)] has added [result] [datumname] to [key_name_admin(target)]."))
	if(href_list[VV_HK_REMOVECOMPONENT] || href_list[VV_HK_MASS_REMOVECOMPONENT])
		if(!check_rights(NONE))
			return
		var/mass_remove = href_list[VV_HK_MASS_REMOVECOMPONENT]
		var/list/components = list()
		var/all_components_on_target = LAZYACCESS(target.datum_components, /datum/component)
		if(islist(all_components_on_target))
			for(var/datum/component/component in LAZYACCESS(target.datum_components, /datum/component))
				components += component.type
		else if(all_components_on_target)
			var/datum/component/component = all_components_on_target
			components += component.type
		var/list/names = list()
		names += "---Components---"
		if(length(components))
			names += sort_list(components, GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Elements---"
		// We have to list every element here because there is no way to know what element is on this object without doing some sort of hack.
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/path = tgui_input_list(usr, "Choose a component/element to remove. All elements listed here may not be on the datum.", "Remove element", names)
		if(isnull(path))
			return
		if(!usr || path == "---Components---" || path == "---Elements---")
			return
		if(QDELETED(src))
			to_chat(usr, "That thing doesn't exist anymore!")
			return
		var/list/targets_to_remove_from = list(target)
		if(mass_remove)
			var/method = vv_subtype_prompt(target.type)
			targets_to_remove_from = get_all_of_type(target.type, method)

			if(alert(usr, "Are you sure you want to mass-delete [path] on [target.type]?", "Mass Remove Confirmation", "Yes", "No") == "No")
				return

		for(var/datum/target_to_remove_from as anything in targets_to_remove_from)
			if(ispath(path, /datum/element))
				var/list/lst = get_callproc_args()
				if(!lst)
					lst = list()
				lst.Insert(1, path)
				target._RemoveElement(lst)
			else
				var/list/components_actual = target_to_remove_from.GetComponents(path)
				for(var/to_delete in components_actual)
					qdel(to_delete)

		message_admins(span_notice("[key_name_admin(usr)] has [mass_remove? "mass" : ""] removed [path] component from [mass_remove? target.type : key_name_admin(target)]."))
	if(href_list[VV_HK_MODIFY_GREYSCALE])
		if(!check_rights(NONE))
			return
		var/datum/greyscale_modify_menu/menu = new(target, usr, SSgreyscale.configurations)
		menu.Unlock()
		menu.ui_interact(usr)
	if(href_list[VV_HK_CALLPROC])
		usr.client.admin_context_wrapper_context_callproc(target)
