datum/mind
	var/key
	var/mob/living/current
	var/mob/living/original

	var/memory

	var/assigned_role
	var/special_role

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	proc/transfer_to(mob/new_character)
		if(current)
			current.mind = null

		new_character.mind = src
		current = new_character

		new_character.key = key

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		var/out = "<B>[current.real_name]</B><br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
		out += "Special role: "


		var/srole
		var/cantoggle = 1

		var/datum/game_mode/current_mode = ticker.mode
		switch (current_mode.config_tag)
			if ("revolution")
				if (src in current_mode:head_revolutionaries)
					srole = "Head Revolutionary"
					out += "<font color=red>Head Revolutionary</font> "
					cantoggle = 0
				else if(src in current_mode:revolutionaries)
					srole = "Revolutionary"
					out += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <font color=red>Revolutionary</font> "
				else
					out += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <a href='?src=\ref[src];traitorize=rev'>Revolutionary</a> "

			if ("cult")
				if (src in current_mode:cult)
					srole = "Cultist"
					out += "<font color=red>Cultist</font>"
					cantoggle = 0

			if ("wizard")
				if (current_mode:wizard && src == current_mode:wizard)
					srole = "Wizard"
					out += "<font color=red>Wizard</font>"
					cantoggle = 0
				else
					out = "<a href='?src=\ref[src];traitorize=wizard'>Wizard</a> "

			if ("changeling")
				if (src in current_mode:changelings)
					srole = "Changeling"
					out += "<font color=red>Changeling</font>"
					cantoggle = 0
				else
					out = "<a href='?src=\ref[src];traitorize=changeling'>Changeling</a> "

			if ("malfunction")
				if (src in current_mode:malf_ai)
					srole = "Malfunction"
					out += "<font color=red>Malfunction</font>"
					cantoggle = 0

			if ("nuclear")
				if(src in current_mode:syndicates)
					srole = "Syndicate"
					out = "<font color=red>Syndicate</font>"
					cantoggle = current_mode:syndicates.len > 1
				else
					out += "<a href='?src=\ref[src];traitorize=syndicate'>Syndicate</a> "

		if (cantoggle)
			if(src in current_mode.traitors)
				if (special_role == "Fake Wizard")
					out += "<a href='?src=\ref[src];traitorize=traitor'>Traitor</a> "
					out += "<font color=red>Fake Wizard</font> "
					srole = "Fake Wizard"
				else
					out += "<b>Traitor</b> "
					out += "<a href='?src=\ref[src];traitorize=fakewizard'>Fake Wizard</a> "
					srole = "Traitor"
			else
				out += "<a href='?src=\ref[src];traitorize=traitor'>Traitor</a> "
				out += "<a href='?src=\ref[src];traitorize=fakewizard'>Fake Wizard</a> "

			if (srole)
				out += "<a href='?src=\ref[src];traitorize=civilian'>Civilian</a> "
			else
				out += "<font color=red>Civilian</font> "

		out += "<br>"

		out += "Memory:<hr>"
		out += memory
		out += "<hr><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
		out += "Objectives:<br>"
		if (objectives.len == 0)
			out += "EMPTY<br>"
		else
			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a><br>"
				obj_count++
		out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

		out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

		usr << browse(out, "window=edit_memory[src]")

	Topic(href, href_list)

		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
			if (!new_role) return
			assigned_role = new_role

		else if (href_list["memory_edit"])
			var/new_memo = input("Write new memory", "Memory", memory) as message
			if (!new_memo) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective = null
			var/objective_pos = null
			var/def_value = null

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				if (istype(objective, /datum/objective/assassinate))
					def_value = "assassinate"
				else if (istype(objective, /datum/objective/hijack))
					def_value = "hijack"
				else if (istype(objective, /datum/objective/escape))
					def_value = "escape"
				else if (istype(objective, /datum/objective/survive))
					def_value = "survive"
				else if (istype(objective, /datum/objective/steal))
					def_value = "steal"
				else if (istype(objective, /datum/objective/nuclear))
					def_value = "nuclear"
				else if (istype(objective, /datum/objective/absorb))
					def_value = "absorb"
				else if (istype(objective, /datum/objective))
					def_value = "custom"
				// TODO: cult objectives
				//else if (istype(objective, /datum/objective/eldergod))
				//	def_value = "eldergod"
				//else if (istype(objective, /datum/objective/survivecult))
				//	def_value = "survivecult"
				//else if (istype(objective, /datum/objective/sacrifice))
				//	def_value = "sacrifice"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "hijack", "escape", "survive", "steal", "nuclear", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate")
					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					if (istype(objective, /datum/objective/assassinate) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					if (new_target == "Free objective")
						new_objective = new /datum/objective/assassinate
						new_objective.owner = src
						new_objective:target = null
						new_objective.explanation_text = "Free objective"
					else
						new_objective = new /datum/objective/assassinate
						new_objective.owner = src
						new_objective:target = new_target:mind
						new_objective.explanation_text = "Assassinate [new_target:real_name], the [new_target:mind:assigned_role]."

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("steal")
					if (!istype(objective, /datum/objective/steal))
						new_objective = new /datum/objective/steal
						new_objective.owner = src
					else
						new_objective = objective
					var/datum/objective/steal/steal = new_objective
					if (!steal.select_target())
						return

				if ("nuclear")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("absorb")
					var/def_num = null
					if (istype(objective, /datum/objective/absorb))
						def_num = objective:num_to_eat

					var/num_to_eat = input("Number to eat:", "Objective", def_num) as num|null
					if (isnull(num_to_eat))
						return
					new_objective = new /datum/objective/absorb
					new_objective.owner = src
					new_objective:num_to_eat = num_to_eat
					new_objective.explanation_text = "Absorb [num_to_eat] compatible genomes."

				if ("custom")
					var/expl = input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl

			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if (!objective) return

			objectives -= objective

		else if (href_list["traitorize"])
			// clear old memory
			clear_memory(href_list["traitorize"] == "civilian" ? 0 : 1)

			var/datum/game_mode/current_mode = ticker.mode
			switch (href_list["traitorize"])
				if ("headrev")
					current_mode:equip_revolutionary(current)
					//find first headrev
					for(var/datum/mind/rev_mind in current_mode:head_revolutionaries)
						// copy objectives
						for (var/datum/objective/assassinate/obj in rev_mind.objectives)
							var/datum/objective/assassinate/rev_obj = new
							rev_obj = src
							rev_obj.target = obj.target
							rev_obj.explanation_text = obj.explanation_text
							objectives += rev_obj
						break
					current_mode:update_rev_icons_added(src)
					current_mode:head_revolutionaries += src

					var/obj_count = 1
					current << "\blue You are a member of the revolutionaries' leadership!"
					for(var/datum/objective/objective in objectives)
						current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
						obj_count++

				if ("rev")
					current_mode:add_revolutionary(src)

				if ("wizard")
					if (alert("Old wizard would be unwizarded. Are you sure?", , "Yes", "No") != "Yes") return
					if (current_mode:wizard)
						current_mode:wizard.clear_memory(0)
					current_mode:wizard = src
					current_mode:equip_wizard(current)
					current << "<B>\red You are the Space Wizard!</B>"
					current.loc = pick(wizardstart)

				if ("fakewizard")
					current_mode.traitors += src
					current_mode.equip_wizard(current)
					current << "<B>\red You are the Space Wizard!</B>"
					current.loc = pick(wizardstart)
					special_role = "Fake Wizard"

				if ("changeling")
					if (alert("Old changeling would lose their memory. Are you sure?", , "Yes", "No") != "Yes") return
					if (changeling)
						changeling.clear_memory()
						current_mode:changelings -= changeling
					current_mode:grant_changeling_powers(current)
					changeling = src
					current_mode:changelings += src

					changeling.current << "<B>\red You are a changeling!</B>"

				if ("syndicate")
					var/obj/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
					current.loc = get_turf(synd_spawn)
					current_mode:equip_syndicate(current)
					current_mode:syndicates += src

				if ("traitor")
					current_mode.equip_traitor(current)
					current_mode.traitors += src
					current << "<B>You are the traitor.</B>"
					special_role = "traitor"

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "\blue Your current objectives:"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		edit_memory()

	proc/clear_memory(var/silent = 1)
		var/datum/game_mode/current_mode = ticker.mode

		// remove traitor uplinks
		var/list/L = current.get_contents()
		for (var/t in L)
			if (istype(t, /obj/item/device/pda))
				if (t:uplink) del(t:uplink)
				t:uplink = null
			else if (istype(t, /obj/item/device/radio))
				if (t:traitorradio) del(t:traitorradio)
				t:traitorradio = null
				t:traitor_frequency = 0.0
			else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
				if (t:origradio)
					var/obj/item/device/radio/R = t:origradio
					R.loc = current.loc
					R.traitorradio = null
					R.traitor_frequency = 0.0
				del(t)

		// remove wizards spells
		//If there are more special powers that need removal, they can be procced into here./N
		current.spellremove(current)

		// clear memory
		memory = ""
		special_role = null

		// remove from traitors list
		if (src in current_mode.traitors)
			current_mode.traitors -= src
			if (!silent)
				if (special_role == "Fake Wizard")
					src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT>"
				else
					src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT>"

		// clear gamemode specific values
		switch (current_mode.config_tag)
			if ("revolution")
				if (src in current_mode:head_revolutionaries)
					current_mode:head_revolutionaries -= src
					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT>"
					current_mode:update_rev_icons_removed(src)

				else if(src in current_mode:revolutionaries)
					if (silent)
						current_mode:revolutionaries -= src
						current_mode:update_rev_icons_removed(src)
					else
						current_mode:remove_revolutionary(src)


			if ("cult")
				if (src in current_mode:cult)
					current_mode:cult -= src
					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a cultist!</B></FONT>"

			if ("wizard")
				if (src == current_mode:wizard)
					current_mode:wizard = null
					//current_mode.wizards -= src

					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT>"

			if ("changeling")
				if (src in current_mode:changelings)
					current_mode:changelings -= src
					//remove verbs
					current.remove_changeling_powers()
					//remove changeling info
					current.changeling_level = 0
					current.absorbed_dna = null

					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a changeling!</B></FONT>"

			if ("malfunction")
				if (src in current_mode:malf_ai)
					current_mode:malf_ai -= src
					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a malfunction!</B></FONT>"

			if ("nuclear")
				if (src in current_mode:syndicates)
					current_mode:syndicates -= src
					if (!silent)
						src.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a syndicate!</B></FONT>"


