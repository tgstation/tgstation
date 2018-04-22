/obj/pod/

	proc/OpenHUD(var/mob/living/L)
		var/dat

		var/mob/living/carbon/human/H
		if(istype(usr, /mob/living/carbon/human))
			H = L
		else
			return 0

		if(H.restrained() || H.lying || H.stat || H.AmountStun() || H.AmountKnockdown())
			return 0
		if(!(H in bounds(1)) && !(H in GetOccupants()))
			return 0
		if(!isturf(src.loc) && get(src.loc, H.type) != H)
			return 0

		if((toggles & P_TOGGLE_HUDLOCK) && L != pilot)
			to_chat(L,"<span class='warning'>The operator has forbidden outside menu access.</span>")
			return 0

		dat += "<div class='statusDisplay'>"
		dat += "<a href='?src=\ref[src];action=open_security_menu'>Open Security Menu</a>|"
		dat += "<a href='?src=\ref[src];action=toggle_sor'>Toggle Stop on Reverse ([toggles & P_TOGGLE_SOR ? "On" : "Off"])</a>|"
		dat += "<a href='?src=\ref[src];action=toggle_lights'>Toggle Lights ([toggles & P_TOGGLE_LIGHTS ? "On" : "Off"])</a><br>"
		dat += "<a href='?src=\ref[src];action=toggle_outside_hud_access'>Toggle Outside HUD Access ([toggles & P_TOGGLE_HUDLOCK ? "Forbidden" : "Allowed"])</a>|"
		dat += "<a href='?src=\ref[src];action=toggle_env_air'>Toggle Environment Air Usage ([toggles & P_TOGGLE_ENVAIR ? "On" : "Off"])</a>"
		dat += "</div>"

		dat += "<center><h2><font color='CornflowerBlue'>Stats:</font></h2></center>"
		dat += "<hr>"

		dat += "Integrity: [round((health / max_health) * 100)]%"

		dat += "<br>"

		if(power_source)
			dat += "<span class='info'>Charge: [power_source.charge]/[power_source.maxcharge] ([power_source.percent()]%)</span><br>"

		dat += "<center><h2><font color='CornflowerBlue'>Attachments:</font></h2></center>"
		dat += "<hr>"

		if(internal_canister)
			dat += "<span class='info'>Canister: <a href='?src=\ref[src];action=remove_canister;canister=\ref[internal_canister]'>[internal_canister.name]</a></span>"
		else
			dat += "<span class='warning'>No canister installed.</span>"

		dat += "<br>"

		if(power_source)
			dat += "<span class='info'>Power Source: <a href='?src=\ref[src];action=remove_battery;battery=\ref[power_source]'>[power_source.name]</a></span>"
		else
			dat += "<span class='warning'>No power source installed.</span>"

		dat += "<br>"

		var/list/replacement_words = list("Engine", "Shield", "Armor", "Primary Attachment", "Secondary Attachment", "Sensor", "Cargo Hold")
		for(var/hardpoint in hardpoints)
			dat += "<span class='info'>[replacement_words[hardpoints.Find(hardpoint)]]: "
			var/obj/item/pod_attachment/attachment = GetAttachmentOnHardpoint(hardpoint)
			if(attachment)
				dat += "<a href='?src=\ref[src];action=remove_attachment;attachment=\ref[attachment]'>[attachment.name]</a>"
				if(attachment.has_menu)
					dat += "|<a href='?src=\ref[src];action=openmenu;attachment=\ref[attachment]'>Menu</a>"
			else
				dat += "<i>Not installed.</i>"
			dat += "</span><br>"

		var/datum/browser/popup = new(L, "pod_hud", "Pod HUD v1", 640, 480)
		popup.set_content(dat)
		popup.open()

	Topic(href, href_list)
		var/mob/living/carbon/human/human
		if(istype(usr, /mob/living/carbon/human))
			human = usr
		else
			return 0

		if(human.restrained() || human.lying || human.stat || human.AmountStun() || human.AmountKnockdown())
			return 0
		if(!(human in bounds(1)) && !(human in GetOccupants()))
			return 0
		if(!isturf(src.loc) && get(src.loc, human.type) != human)
			return 0

		if(!href_list["action"])
			return 0

		switch(href_list["action"])
			if("remove_canister")
				if(usr in src)
					return 0

				var/obj/machinery/portable_atmospherics/canister/canister = locate(href_list["canister"])
				if(!canister)
					return 0
				if(canister != internal_canister)
					return 0

				if(!istype(usr.get_active_held_item(), /obj/item/wrench) && !istype(usr.get_inactive_held_item(), /obj/item/wrench))
					to_chat(usr,"<span class='warning'>You need to hold a wrench to detach the internal canister.</span>")
					return 0

				to_chat(usr,"<span class='info'>You start to detach the [internal_canister].</span>")
				if(do_after(usr, 20,target = src))
					to_chat(usr,"<span class='info'>You detach the [internal_canister].</span>")
					internal_canister.loc = get_turf(usr)
					internal_canister = 0

				OpenHUD(usr)

			if("remove_battery")
				if(usr in src)
					return 0

				var/obj/item/stock_parts/cell/battery = locate(href_list["battery"])

				if(!battery)
					return 0

				if(battery != power_source)
					return 0

				if(!istype(usr.get_active_held_item(), /obj/item/wrench) && !istype(usr.get_inactive_held_item(), /obj/item/wrench))
					to_chat(usr,"<span class='warning'>You need to hold a wrench to detach the power source.</span>")
					return 0

				to_chat(usr,"<span class='info'>You start to detach the [power_source].</span>")
				if(do_after(usr, 10,target = src))
					to_chat(usr,"<span class='info'>You detach the [power_source].</span>")
					power_source.loc = get_turf(usr)
					power_source = 0

			if("remove_attachment")
				if(usr in src)
					return 0

				var/obj/item/pod_attachment/attachment = locate(href_list["attachment"])
				if(!attachment)
					return 0

				if(!(usr in GetOccupants()))
					if(!istype(usr.get_active_held_item(), /obj/item/wrench) && !istype(usr.get_active_held_item(), /obj/item/wrench))
						to_chat(usr,"<span class='warning'>You need to hold a wrench to detach the [attachment].</span>")
						return 0

				attachment.StartDetach(src, usr)
				OpenHUD(usr)

			if("openmenu")
				var/obj/item/pod_attachment/attachment = locate(href_list["attachment"])
				attachment.OpenMenu(usr)

			if("toggle_sor")
				Toggle(P_TOGGLE_SOR)
				to_chat(usr,"<span class='info'>You toggle Stop on Reverse [toggles & P_TOGGLE_SOR ? "on" : "off"].</span>")
				pod_log.LogToggle(usr, P_TOGGLE_SOR)

			if("toggle_lights")
				Toggle(P_TOGGLE_LIGHTS)
				to_chat(usr,"<span class='info'>You toggle the lights [toggles & P_TOGGLE_LIGHTS ? "on" : "off"].</span>")
				pod_log.LogToggle(usr, P_TOGGLE_LIGHTS)

			if("toggle_outside_hud_access")
				Toggle(P_TOGGLE_HUDLOCK)
				to_chat(usr,"<span class='info'>Outside menu access is now [toggles & P_TOGGLE_HUDLOCK ? "forbidden" : "allowed"].</span>")
				pod_log.LogToggle(usr, P_TOGGLE_HUDLOCK)

			if("toggle_env_air")
				Toggle(P_TOGGLE_ENVAIR)
				to_chat(usr,"<span class='info'>[toggles & P_TOGGLE_ENVAIR ? "Now" : "No longer"] using air from the environment.</span>")
				pod_log.LogToggle(usr, P_TOGGLE_ENVAIR)

			if("open_security_menu")
				if(href_list["add_lock"])
					var/lock_type = input(usr, "Which lock type?", "Selection") in list("Code", "DNA", "Cancel")
					if(lock_type == "Code")
						var/code
						do
							code = input(usr, "Please enter a 4-6 digit code.", "Input") as num
						while(length(num2text(code)) > 6 || length(num2text(code)) < 4)
						if(code)
							locks += code
							to_chat(usr,"<span class='info'>You enter '[code]' as a lock.</span>")
							pod_log.LogSecurity(usr, P_LOCKTYPE_CODE, code)

					else if(lock_type == "DNA")
						if(ishuman(usr))
							var/mob/living/carbon/human/H = usr
							locks += H.dna.unique_enzymes
							to_chat(H,"<span class='info'>DNA added.</span>")
							pod_log.LogSecurity(H, P_LOCKTYPE_DNA, H.dna.unique_enzymes)

					return 1

				else if(href_list["remove_lock"])
					var/locks_index = text2num(href_list["lock"])
					if(locks_index)
						if(length(locks) >= locks_index && locks[locks_index])
							var/data = locks[locks_index]
							locks.Cut(locks_index, locks_index + 1)
							to_chat(usr,"<span class='info'>Removed lock.</span>")
							pod_log.LogSecurity(usr, GetLockType(data), data)
							return 1

				var/dat = "<a href='?src=\ref[src];action=open_security_menu;add_lock=1'>Add Lock</a><br>"
				dat += "Security Locks: "

				if(!length(locks))
					dat += "None."
				else
					dat += "<ol>"
					for(var/lock in locks)
						dat += "<li>"
						switch(GetLockType(lock))
							if(P_LOCKTYPE_CODE)
								dat += "Code: "
								dat += num2text(lock)
							if(P_LOCKTYPE_DNA)
								dat += "DNA: "
								dat += lock
						dat += " <a href='?src=\ref[src];action=open_security_menu;remove_lock=1;lock=[locks.Find(lock)]'>Remove</a>"
						dat += "</li>"
					dat += "</ol>"

				var/datum/browser/popup = new(usr, "pod_security_menu", "Pod Security Menu", 380, 240)
				popup.set_content(dat)
				popup.open()

			if("damage")
				if(!check_rights(R_ADMIN))
					return 0

				var/amount = input(usr, "How much?", "Input") as num
				if(!amount)
					return 0

				TakeDamage(amount, 1, 0)

				message_admins("[key_name_admin(usr)] has damaged the [src] (space pod) @{[x], [y], [z]} by [amount].")
				log_admin("[key_name(usr)] has damaged a space pod by [amount].")

			if("heal")
				if(!check_rights(R_ADMIN))
					return 0

				var/amount = input(usr, "How much?", "Input") as num
				if(!amount)
					return 0

				health = CLAMP(amount, 0, max_health)

				message_admins("[key_name_admin(usr)] has healed the [src] (space pod) @{[x], [y], [z]} by [amount].")
				log_admin("[key_name(usr)] has healed a space pod by [amount].")

			if("charge")
				if(!check_rights(R_ADMIN))
					return 0

				var/amount = input(usr, "How much?", "Input") as num
				if(!amount)
					return 0

				power_source.charge = CLAMP(amount, 0, power_source.maxcharge)

				message_admins("[key_name_admin(usr)] has charged the [src] (space pod) @{[x], [y], [z]} by [amount].")
				log_admin("[key_name(usr)] has charged a space pod by [amount].")

			if("remove_charge")
				if(!check_rights(R_ADMIN))
					return 0

				var/amount = input(usr, "How much?", "Input") as num
				if(!amount)
					return 0

				power_source.charge = CLAMP(-abs(amount), 0, power_source.maxcharge)

				message_admins("[key_name_admin(usr)] has removed charge from the [src] (space pod) @{[x], [y], [z]} by [amount].")
				log_admin("[key_name(usr)] has removed charge from a space pod by [amount].")

			if("remove_attachment")
				if(!check_rights(R_ADMIN))
					return 0

				var/obj/item/pod_attachment/attachment = locate(href_list["attachment"])
				if(!attachment)
					return 0

				attachment.OnDetach(src, usr)
				if(alert("Delete attachment?", "Confirmation", "Yes", "No") == "Yes")
					qdel(attachment)

				message_admins("[key_name_admin(usr)] has removed an attachment from the [src] (space pod) @{[x], [y], [z]} ([attachment.type])")
				log_admin("[key_name(usr)] has removed an attachment from a space pod ([attachment.type])")

		if(!(href_list["action"] in list("open_security_menu", "openmenu", "damage", "heal", "charge", "remove_charge", "remove_attachment")))
			OpenHUD(usr)
