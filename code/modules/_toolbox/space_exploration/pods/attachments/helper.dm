/obj/item/pod_attachment

	proc/GetHardpointDisplayName()
		switch(hardpoint_slot)
			if(P_HARDPOINT_ENGINE)
				return "engine compartment"
			if(P_HARDPOINT_SHIELD)
				return "shield matrix"
			if(P_HARDPOINT_PRIMARY_ATTACHMENT)
				return "primary module hardpoint"
			if(P_HARDPOINT_SECONDARY_ATTACHMENT)
				return "secondary module hardpoint"
			if(P_HARDPOINT_SENSOR)
				return "sensor bay"
			if(P_HARDPOINT_CARGO_HOLD)
				return "cargo hold"
			if(P_HARDPOINT_ARMOR)
				return "armor"

	proc/KeybindToText(var/keybind = 0)
		switch(keybind)
			if(P_ATTACHMENT_KEYBIND_SINGLE)
				return "Left Click"
			if(P_ATTACHMENT_KEYBIND_SHIFT)
				return "Shift Click"
			if(P_ATTACHMENT_KEYBIND_CTRL)
				return "Ctrl Click"
			if(P_ATTACHMENT_KEYBIND_ALT)
				return "Alt Click"
			if(P_ATTACHMENT_KEYBIND_MIDDLE)
				return "Middle Click"
			if(P_ATTACHMENT_KEYBIND_CTRLSHIFT)
				return "CtrlShift Click"

	proc/TextToKeybind(var/text)
		switch(text)
			if("Left Click")
				return P_ATTACHMENT_KEYBIND_SINGLE
			if("Shift Click")
				return P_ATTACHMENT_KEYBIND_SHIFT
			if("Ctrl Click")
				return P_ATTACHMENT_KEYBIND_CTRL
			if("Alt Click")
				return P_ATTACHMENT_KEYBIND_ALT
			if("Middle Click")
				return P_ATTACHMENT_KEYBIND_MIDDLE
			if("CtrlShift Click")
				return P_ATTACHMENT_KEYBIND_CTRLSHIFT

	proc/GetAvailableKeybinds()
		return list(P_ATTACHMENT_KEYBIND_SINGLE)

	proc/UsePower(var/amount = 0)
		if(attached_to)
			return attached_to.UsePower(amount)
		return 0

	proc/HasPower(var/amount = 0)
		if(attached_to)
			return attached_to.HasPower(amount)
		return 0

	proc/ToggleActive(var/mob/living/user, var/print = 1)
		if(active & P_ATTACHMENT_PASSIVE)
			return 0

		if(active & P_ATTACHMENT_ACTIVE)
			active = P_ATTACHMENT_INACTIVE
			if(print)
				attached_to.PrintSystemAlert("Powering \the [src] down.")
		else if(active & P_ATTACHMENT_INACTIVE)
			active = P_ATTACHMENT_ACTIVE
			if(print)
				attached_to.PrintSystemNotice("Powering \the [src] up.")

		if(attached_to)
			attached_to.update_icon()

		attached_to.pod_log.LogToggleAttachment(user ? user : 0, src)
