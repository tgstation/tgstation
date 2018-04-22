/obj/item/pod_attachment

	proc/GetAdditionalMenuData()
		return ""

	proc/OpenMenu(var/mob/user)
		if(!has_menu)
			return 0

		if(!attached_to)
			return 0

		if(!user.canUseTopic(attached_to))
			return 0

		var/dat

		if(length(GetAvailableKeybinds()) > 0)
			dat += "Bound to Key: <a href='?src=\ref[src];action=changekeybind'>"
			if(keybind)
				dat += KeybindToText(keybind)
			else
				dat += "Unbound"
			dat += "</a><br>"

		if(active & P_ATTACHMENT_INACTIVE || active & P_ATTACHMENT_ACTIVE)
			dat += "Active: <a href='?src=\ref[src];action=toggle_active'>Turn [active & P_ATTACHMENT_ACTIVE ? "off" : "on"]</a>"
			dat += "<br>"

		if(power_usage)
			dat += "Power Usage: [power_usage] / "
			if(power_usage_condition & P_ATTACHMENT_USAGE_ONTICK)
				dat += "Tick"
			else
				dat += "Usage"

		var/additional_data = GetAdditionalMenuData()
		if(additional_data && (length(additional_data) > 0))
			if(length(dat) > 0)
				dat += "<hr>"
			dat += additional_data
			dat += "<br>"

		var/datum/browser/popup = new(user, "p_attachment_menu", name, 400, 280)
		popup.set_content(dat)
		popup.open()

	Topic(href, href_list)
		if(!attached_to)
			return 0

		if(!usr.canUseTopic(attached_to))
			return 0

		if(!href_list["action"])
			return 0

		switch(href_list["action"])
			if("changekeybind")
				var/list/available_keybinds = GetAvailableKeybinds()
				for(var/kb in available_keybinds)
					available_keybinds[available_keybinds.Find(kb)] = KeybindToText(kb)

				var/selected_keybind = input("Which key to you want to bind to?", "Input") in available_keybinds
				if(!selected_keybind)
					return 0

				keybind = TextToKeybind(selected_keybind)
				to_chat(usr,"<span class='info'>The [src] is now used with [lowertext(selected_keybind)].</span>")

			if("toggle_active")
				ToggleActive(usr)

		OpenMenu(usr)