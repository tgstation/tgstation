datum/mind
	var/key
	var/mob/living/current
	var/mob/living/original

	var/memory
	//TODO: store original name --rastaf0

	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not
	var/rev_cooldown = 0

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
		if(!ticker || !ticker.mode)
			alert("Not before round-start!", "Alert")
			return

		var/out = "<B>[current.real_name]</B><br>"
		out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
		out += "Factions and special roles:<br>"

		var/list/sections = list(
			"revolution",
			"cult",
			"wizard",
			"changeling",
			"nuclear",
			"traitor", // "traitorchan",
			"monkey",
			"malfunction",
		)
		var/text = ""

		if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey))
			/** REVOLUTION ***/
			text = "revolution"
			if (ticker.mode.config_tag=="revolution")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
/*			if (assigned_role in command_positions)
				text += "<b>HEAD</b>|officer|employee|headrev|rev"
			else if (assigned_role in list("Security Officer", "Detective", "Warden"))
				text += "head|<b>OFFICER</b>|employee|headre|rev"*/
			if (src in ticker.mode.head_revolutionaries)
				text = "<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
				text += "<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"

				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (flash)
					if(!flash.broken)
						text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>."
					else
						text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>|<a href='?src=\ref[src];revolution=repairflash'>repair</a>."
				else
					text += "."

				text += " <a href='?src=\ref[src];revolution=reequip'>Reequip</a> (gives traitor uplink)."
				if (objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];revolution=autoobjectives'>Set to kill all heads</a>."
			else if (src in ticker.mode.revolutionaries)
				text += "<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
			else
				text += "<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
			sections["revolution"] = text

			/** CULT ***/
			text = "cult"
			if (ticker.mode.config_tag=="cult")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
/*			if (assigned_role in command_positions)
				text += "<b>HEAD</b>|officer|employee|cultist"
			else if (assigned_role in list("Security Officer", "Detective", "Warden"))
				text += "head|<b>OFFICER</b>|employee|cultist"*/
			if (src in ticker.mode.cult)
				text += "<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>"
				text += "<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."
/*
				if (objectives.len==0)
					text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
			else
				text += "<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
			sections["cult"] = text

			/** WIZARD ***/
			text = "wizard"
			if (ticker.mode.config_tag=="wizard")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (src in ticker.mode.wizards)
				text += "<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>"
				text += "<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."
				if (objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
			else
				text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"
			sections["wizard"] = text

			/** CHANGELING ***/
			text = "changeling"
			if (ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (src in ticker.mode.changelings)
				text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
				if (objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
				if (current.changeling && (current.changeling.absorbed_dna.len>0 && current.real_name != current.changeling.absorbed_dna[1]))
					text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
			else
				text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = ticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."
			sections["changeling"] = text

			/** NUCLEAR ***/
			text = "nuclear"
			if (ticker.mode.config_tag=="nuclear")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (src in ticker.mode.syndicates)
				text += "<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>"
				text += "<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in world)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
			else
				text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"
			sections["nuclear"] = text

		/** TRAITOR ***/
		text = "traitor"
		if (ticker.mode.config_tag=="traitor" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in ticker.mode.traitors)
			text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>loyal</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
		else
			text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>LOYAL</b>"
		sections["traitor"] = text

		/** MONKEY ***/
		if (istype(current, /mob/living/carbon))
			text = "monkey"
			if (ticker.mode.config_tag=="monkey")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (istype(current, /mob/living/carbon/human))
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
			else if (istype(current, /mob/living/carbon/monkey))
				var/found = 0
				for(var/datum/disease/D in current.viruses)
					if(istype(D, /datum/disease/jungle_fever)) found = 1

				if(found)
					text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
				else
					text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

			else
				text += "healthy|infected|human|<b>OTHER</b>"
			sections["monkey"] = text


		/** SILICON ***/

		if (istype(current, /mob/living/silicon))
			text = "silicon"
			if (ticker.mode.config_tag=="malfunction")
				text = uppertext(text)
			text = "<i><b>[text]</b></i>: "
			if (istype(current, /mob/living/silicon/ai))
				if (src in ticker.mode.malf_ai)
					text += "<b>MALF</b>|<a href='?src=\ref[src];silicon=unmalf'>not malf</a>"
				else
					text += "<a href='?src=\ref[src];silicon=malf'>malf</a>|<b>NOT MALF</b>"
			var/mob/living/silicon/robot/robot = current
			if (istype(robot) && robot.emagged)
				text += "<br>Cyborg: Is emagged! <a href='?src=\ref[src];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth]"
			var/mob/living/silicon/ai/ai = current
			if (istype(ai) && ai.connected_robots.len)
				var/n_e_robots = 0
				for (var/mob/living/silicon/robot/R in ai.connected_robots)
					if (R.emagged)
						n_e_robots++
				text += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=\ref[src];silicon=unemagcyborgs'>Unemag</a>"
			sections["malfunction"] = text

		if (ticker.mode.config_tag == "traitorchan")
			if (sections["traitor"])
				out += sections["traitor"]+"<br>"
			if (sections["changeling"])
				out += sections["changeling"]+"<br>"
			sections -= "traitor"
			sections -= "changeling"
		else
			if (sections[ticker.mode.config_tag])
				out += sections[ticker.mode.config_tag]+"<br>"
			sections -= ticker.mode.config_tag
		for (var/i in sections)
			if (sections[i])
				out += sections[i]+"<br>"


		if (((src in ticker.mode.head_revolutionaries) || \
			(src in ticker.mode.traitors)              || \
			(src in ticker.mode.syndicates))           && \
			istype(current,/mob/living/carbon/human)      )

			text = "Uplink: <a href='?src=\ref[src];common=uplink'>give</a>"
			var/obj/item/device/uplink/radio/suplink = find_syndicate_uplink()
			var/obj/item/device/uplink/iuplink = find_integrated_uplink()
			var/crystals
			if (suplink)
				crystals = suplink.uses
			else if (iuplink)
				crystals = iuplink.uses
			if (suplink || iuplink)
				text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
				if (usr.client.holder.level >= 3)
					text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
				else
					text += ", [crystals] crystals"
			text += "." //hiel grammar
			out += text

		out += "<br>"

		out += "<b>Memory:</b><br>"
		out += memory
		out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
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
			role_alt_title = null

		else if (href_list["memory_edit"])
			var/new_memo = input("Write new memory", "Memory", memory) as null|message
			if (isnull(new_memo)) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective
			var/objective_pos
			var/def_value

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				//Text strings are easy to manipulate. Revised for simplicity.
				var/temp_obj_type = "[objective.type]"//Convert path into a text string.
				def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
				if(!def_value)//If it's a custom objective, it will be an empty string.
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate","decapitate", "debrain", "protection", "frame", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate","protection", "frame", "debrain","decapitate")
					//To determine what to name the objective in explanation text.
//					var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
//					var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
//					var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && possible_target.current && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protection, /datum/objective/frame, /datum/objective/debrain, /datum/objective/decapitate)
					if (objective&&(objective.type in objective_list) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					var/objective_path = text2path("/datum/objective/[new_obj_type]")
					if (new_target == "Free objective")
						new_objective = new objective_path(null,"MODE",null)
						new_objective.owner = src
					else
						new_objective = new objective_path(null,"MODE",new_target:mind)
						new_objective.owner = src

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("nuclear")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("steal")
					var/list/possibilities = GenerateTheft(assigned_role,src)
					var/list/temp_poss = possibilities[1]
					var/list/choices = list()
					for(var/datum/objective/steal/steal in temp_poss)
						choices["[steal.steal_target]"] = steal
					var/new_target = input("Select target:", "Objective target") as null|anything in choices
					if (!new_target) return
					new_objective = choices[new_target]
					new_objective.owner = src

				if("download","capture","absorb")
					var/def_num
					if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
						def_num = objective:target_amount

					var/target_number = input("Input target number:", "Objective", def_num) as num|null
					if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
						return

					switch(new_obj_type)
						if("download")
							new_objective = new /datum/objective/download
							new_objective.explanation_text = "Download [target_number] research levels."
						if("capture")
							new_objective = new /datum/objective/capture
							new_objective.explanation_text = "Accumulate [target_number] capture points."
						if("absorb")
							new_objective = new /datum/objective/absorb
							new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					new_objective.owner = src
					new_objective:target_amount = target_number

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

		else if (href_list["revolution"])
			switch(href_list["revolution"])
				if("clear")
					if(src in ticker.mode.revolutionaries)
						ticker.mode.revolutionaries -= src
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT>"
						ticker.mode.update_rev_icons_removed(src)
						special_role = null
					if(src in ticker.mode.head_revolutionaries)
						ticker.mode.head_revolutionaries -= src
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT>"
						ticker.mode.update_rev_icons_removed(src)
						special_role = null

				if("rev")
					if(src in ticker.mode.head_revolutionaries)
						ticker.mode.head_revolutionaries -= src
						ticker.mode.update_rev_icons_removed(src)
						current << "\red <FONT size = 3><B>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</B></FONT>"
					else if(!(src in ticker.mode.revolutionaries))
						current << "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT>"
					else
						return
					ticker.mode.revolutionaries += src
					ticker.mode.update_rev_icons_added(src)
					special_role = "Revolutionary"

				if("headrev")
					if(src in ticker.mode.revolutionaries)
						ticker.mode.revolutionaries -= src
						ticker.mode.update_rev_icons_removed(src)
						current << "\red <FONT size = 3><B>You have proved your devotion to revoltion! Yea are a head revolutionary now!</B></FONT>"
					else if(!(src in ticker.mode.head_revolutionaries))
						current << "\blue You are a member of the revolutionaries' leadership now!"
					else
						return
					if (ticker.mode.head_revolutionaries.len>0)
						// copy targets
						var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
						if (valid_head)
							for (var/datum/objective/mutiny/O in valid_head.objectives)
								var/datum/objective/mutiny/rev_obj = new
								rev_obj.owner = src
								rev_obj.target = O.target
								rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
								objectives += rev_obj
							ticker.mode.greet_revolutionary(src,0)
					ticker.mode.head_revolutionaries += src
					ticker.mode.update_rev_icons_added(src)
					special_role = "Head Revolutionary"

				if("autoobjectives")
					ticker.mode.forge_revolutionary_objectives(src)
					ticker.mode.greet_revolutionary(src,0)
					usr << "\blue The objectives for revolution have been generated and shown to [key]"

				if("flash")
					if (!ticker.mode.equip_revolutionary(current))
						usr << "\red Spawning flash failed!"

				if("takeflash")
					var/list/L = current.get_contents()
					var/obj/item/device/flash/flash = locate() in L
					if (!flash)
						usr << "\red Deleting flash failed!"
					del(flash)

				if("repairflash")
					var/list/L = current.get_contents()
					var/obj/item/device/flash/flash = locate() in L
					if (!flash)
						usr << "\red Repairing flash failed!"
					else
						flash.broken = 0

				if("reequip")
					var/list/L = current.get_contents()
					var/obj/item/device/flash/flash = locate() in L
					del(flash)
					take_uplink()
					var/fail = 0
					fail |= !ticker.mode.equip_traitor(current, 1)
					fail |= !ticker.mode.equip_revolutionary(current)
					if (fail)
						usr << "\red Reequipping revolutionary goes wrong!"

		else if (href_list["cult"])
			switch(href_list["cult"])
				if("clear")
					if(src in ticker.mode.cult)
						ticker.mode.cult -= src
						ticker.mode.update_cult_icons_removed(src)
						special_role = null
						var/datum/game_mode/cult/cult = ticker.mode
						if (istype(cult))
							cult.memoize_cult_objectives(src)
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a cultist!</B></FONT>"
						memory = ""
				if("cultist")
					if(!(src in ticker.mode.cult))
						ticker.mode.cult += src
						ticker.mode.update_cult_icons_added(src)
						special_role = "Cultist"
						current << "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>"
						current << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
						var/datum/game_mode/cult/cult = ticker.mode
						if (istype(cult))
							cult.memoize_cult_objectives(src)
				if("tome")
					var/mob/living/carbon/human/H = current
					if (istype(H))
						var/obj/item/weapon/tome/T = new(H)

						var/list/slots = list (
							"backpack" = H.slot_in_backpack,
							"left pocket" = H.slot_l_store,
							"right pocket" = H.slot_r_store,
							"left hand" = H.slot_l_hand,
							"right hand" = H.slot_r_hand,
						)
						var/where = H.equip_in_one_of_slots(T, slots)
						if (!where)
							usr << "\red Spawning tome failed!"
						else
							H << "A tome, a message from your new master, appears in your [where]."

				if("amulet")
					if (!ticker.mode.equip_cultist(current))
						usr << "\red Spawning amulet failed!"

		else if (href_list["wizard"])
			switch(href_list["wizard"])
				if("clear")
					if(src in ticker.mode.wizards)
						ticker.mode.wizards -= src
						special_role = null
						current.spellremove(current, config.feature_object_spell_system? "object":"verb")
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT>"
				if("wizard")
					if(!(src in ticker.mode.wizards))
						ticker.mode.wizards += src
						special_role = "Wizard"
						//ticker.mode.learn_basic_spells(current)
						current << "<B>\red You are the Space Wizard!</B>"
				if("lair")
					current.loc = pick(wizardstart)
				if("dressup")
					ticker.mode.equip_wizard(current)
				if("name")
					ticker.mode.name_wizard(current)
				if("autoobjectives")
					ticker.mode.forge_wizard_objectives(src)
					usr << "\blue The objectives for wizard [key] have been generated. You can edit them and anounce manually."

		else if (href_list["changeling"])
			switch(href_list["changeling"])
				if("clear")
					if(src in ticker.mode.changelings)
						ticker.mode.changelings -= src
						special_role = null
						current.remove_changeling_powers()
						if(current.changeling)
							del(current.changeling)
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a changeling!</B></FONT>"
				if("changeling")
					if(!(src in ticker.mode.changelings))
						ticker.mode.changelings += src
						ticker.mode.grant_changeling_powers(current)
						special_role = "Changeling"
						current << "<B>\red You are a changeling!</B>"
				if("autoobjectives")
					ticker.mode.forge_changeling_objectives(src)
					usr << "\blue The objectives for changeling [key] have been generated. You can edit them and anounce manually."

				if("initialdna")
					if (!usr.changeling || !usr.changeling.absorbed_dna[1])
						usr << "\red Resetting DNA failed!"
					else
						usr.dna = usr.changeling.absorbed_dna[usr.changeling.absorbed_dna[1]]
						usr.real_name = usr.changeling.absorbed_dna[1]
						updateappearance(usr, usr.dna.uni_identity)
						domutcheck(usr, null)

		else if (href_list["nuclear"])
			switch(href_list["nuclear"])
				if("clear")
					if(src in ticker.mode.syndicates)
						ticker.mode.syndicates -= src
						ticker.mode.update_synd_icons_removed(src)
						special_role = null
						for (var/datum/objective/nuclear/O in objectives)
							objectives-=O
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a syndicate operative!</B></FONT>"
				if("nuclear")
					if(!(src in ticker.mode.syndicates))
						ticker.mode.syndicates += src
						ticker.mode.update_synd_icons_added(src)
						if (ticker.mode.syndicates.len==1)
							ticker.mode.prepare_syndicate_leader(src)
						else
							current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
						special_role = "Syndicate"
						current << "\blue You are a [syndicate_name()] agent!"
						ticker.mode.forge_syndicate_objectives(src)
						ticker.mode.greet_syndicate(src)
				if("lair")
					current.loc = get_turf(locate("landmark*Syndicate-Spawn"))
				if("dressup")
					var/mob/living/carbon/human/H = current
					del(H.belt)
					del(H.back)
					del(H.l_ear)
					del(H.r_ear)
					del(H.gloves)
					del(H.head)
					del(H.shoes)
					del(H.wear_id)
					del(H.wear_suit)
					del(H.w_uniform)

					if (!ticker.mode.equip_syndicate(current))
						usr << "\red Equipping a syndicate failed!"
				if("tellcode")
					var/code
					for (var/obj/machinery/nuclearbomb/bombue in world)
						if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
							code = bombue.r_code
							break
					if (code)
						store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
						current << "The nuclear authorization code is: <B>[code]</B>"
					else
						usr << "\red No valid nuke found!"

		else if (href_list["traitor"])
			switch(href_list["traitor"])
				if("clear")
					if(src in ticker.mode.traitors)
						ticker.mode.traitors -= src
						special_role = null
						current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT>"

				if("traitor")
					if(!(src in ticker.mode.traitors))
						ticker.mode.traitors += src
						special_role = "traitor"
						current << "<B>\red You are a traitor!</B>"

				if("autoobjectives")
					ticker.mode.forge_traitor_objectives(src)
					usr << "\blue The objectives for traitor [key] have been generated. You can edit them and anounce manually."

		else if (href_list["monkey"])
			var/mob/living/L = current
			if (L.monkeyizing)
				return
			switch(href_list["monkey"])
				if("healthy")
					if (usr.client.holder.level >= 3)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
							message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]", 1)
							src = null
							M = H.monkeyize()
							src = M.mind
							//world << "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!"
						else if (istype(M) && length(M.viruses))
							for(var/datum/disease/D in M.viruses)
								D.cure(0)
							sleep(0) //because deleting of virus is done through spawn(0)
				if("infected")
					if (usr.client.holder.level >= 3)
						var/mob/living/carbon/human/H = current
						var/mob/living/carbon/monkey/M = current
						if (istype(H))
							log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
							message_admins("\blue [key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]", 1)
							src = null
							M = H.monkeyize()
							src = M.mind
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
						else if (istype(M))
							current.contract_disease(new /datum/disease/jungle_fever,1,0)
				if("human")
					var/mob/living/carbon/monkey/M = current
					if (istype(M))
						for(var/datum/disease/D in M.viruses)
							if (istype(D,/datum/disease/jungle_fever))
								D.cure(0)
								sleep(0) //because deleting of virus is doing throught spawn(0)
						log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
						message_admins("\blue [key_name_admin(usr)] attempting to humanize [key_name_admin(current)]", 1)
						var/obj/item/weapon/dnainjector/m2h/m2h = new
						var/obj/item/weapon/implant/mobfinder = new(M) //hack because humanizing deletes mind --rastaf0
						src = null
						m2h.inject(M)
						src = mobfinder.loc:mind
						del(mobfinder)
						current.radiation -= 50

		else if (href_list["silicon"])
			switch(href_list["silicon"])
				if("unmalf")
					if(src in ticker.mode.malf_ai)
						ticker.mode.malf_ai -= src
						special_role = null

						current.verbs -= /mob/living/silicon/ai/proc/choose_modules
						current.verbs -= /datum/game_mode/malfunction/proc/takeover
						current.verbs -= /datum/game_mode/malfunction/proc/ai_win
						current.verbs -= /client/proc/fireproof_core
						current.verbs -= /client/proc/upgrade_turrets
						current.verbs -= /client/proc/disable_rcd
						current.verbs -= /client/proc/overload_machine
						current.verbs -= /client/proc/blackout
						current.verbs -= /client/proc/interhack
						current.verbs -= /client/proc/reactivate_camera

						current:laws = new /datum/ai_laws/nanotrasen
						del(current:malf_picker)
						current:show_laws()
						current.icon_state = "ai"

						current << "\red <FONT size = 3><B>You have been patched! You are no longer malfunctioning!</B></FONT>"

				if("malf")
					make_AI_Malf()

				if("unemag")
					var/mob/living/silicon/robot/R = current
					if (istype(R))
						R.emagged = 0
						if (R.activated(R.module.emag))
							R.module_active = null
						if(R.module_state_1 == R.module.emag)
							R.module_state_1 = null
							R.contents -= R.module.emag
						else if(R.module_state_2 == R.module.emag)
							R.module_state_2 = null
							R.contents -= R.module.emag
						else if(R.module_state_3 == R.module.emag)
							R.module_state_3 = null
							R.contents -= R.module.emag

				if("unemagcyborgs")
					if (istype(current, /mob/living/silicon/ai))
						var/mob/living/silicon/ai/ai = current
						for (var/mob/living/silicon/robot/R in ai.connected_robots)
							R.emagged = 0
							if (R.module)
								if (R.activated(R.module.emag))
									R.module_active = null
								if(R.module_state_1 == R.module.emag)
									R.module_state_1 = null
									R.contents -= R.module.emag
								else if(R.module_state_2 == R.module.emag)
									R.module_state_2 = null
									R.contents -= R.module.emag
								else if(R.module_state_3 == R.module.emag)
									R.module_state_3 = null
									R.contents -= R.module.emag

		else if (href_list["common"])
			switch(href_list["common"])
				if("undress")
					for(var/obj/item/W in current)
						current.drop_from_slot(W)
				if("takeuplink")
					take_uplink()
					memory = null//Remove any memory they may have had.
				if("crystals")
					if (usr.client.holder.level >= 3)
						var/obj/item/device/uplink/radio/suplink = find_syndicate_uplink()
						var/obj/item/device/uplink/iuplink = find_integrated_uplink()
						var/crystals
						if (suplink)
							crystals = suplink.uses
						else if (iuplink)
							crystals = iuplink.uses
						crystals = input("Amount of telecrystals for [key]","Sindicate uplink", crystals) as null|num
						if (!isnull(crystals))
							if (suplink)
								suplink.uses = crystals
							else if(iuplink)
								iuplink.uses = crystals
				if("uplink")
					if (!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
						usr << "\red Equipping a syndicate failed!"

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "\blue Your current objectives:"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		edit_memory()
/*
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
			else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/device/uplink/radio))
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

*/

	proc/find_syndicate_uplink()
		var/obj/item/device/uplink/radio/uplink = null
		var/list/L = current.get_contents()
		for (var/obj/item/device/radio/radio in L)
			uplink = radio.traitorradio
			if (uplink)
				return uplink
		uplink =  locate() in L
		return uplink

	proc/find_integrated_uplink()
		//world << "DEBUG: find_integrated_uplink()"
		var/obj/item/device/uplink/uplink = null
		var/list/L = current.get_contents()
		for (var/obj/item/device/pda/pda in L)
			uplink = pda.uplink
			if (uplink)
				return uplink
		return uplink

	proc/take_uplink() //assuming only one uplink because I am tired of all this uplink shit --rastaf0
		var/list/L = current.get_contents()
		var/obj/item/device/uplink/radio/suplink = null
		var/obj/item/device/uplink/pda/iuplink = null
		for (var/obj/item/device/radio/radio in L)
			suplink = radio.traitorradio
			if (suplink)
				break
		if (!suplink)
			suplink = locate() in L

		for (var/obj/item/device/pda/pda in L)
			iuplink = pda.uplink
			if (iuplink)
				break
		if (!iuplink)
			iuplink = locate() in L

		if (iuplink)
			iuplink.shutdown_uplink()
			del(iuplink)
		else if (suplink)
			suplink.shutdown_uplink()
			del(suplink)
		return

	proc/make_AI_Malf()
		if(!(src in ticker.mode.malf_ai))
			ticker.mode.malf_ai += src

			current.verbs += /mob/living/silicon/ai/proc/choose_modules
			current.verbs += /datum/game_mode/malfunction/proc/takeover
			current:malf_picker = new /datum/AI_Module/module_picker
			current:laws = new /datum/ai_laws/malfunction
			current:show_laws()
			current << "<b>System error.  Rampancy detected.  Emergancy shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>"
			special_role = "malfunction"
			current.icon_state = "ai-malf"

	proc/make_Tratior()
		if(!(src in ticker.mode.traitors))
			ticker.mode.traitors += src
			special_role = "traitor"
			ticker.mode.forge_traitor_objectives(src)
			ticker.mode.finalize_traitor(src)
			ticker.mode.greet_traitor(src)

	proc/make_Nuke()
		if(!(src in ticker.mode.syndicates))
			ticker.mode.syndicates += src
			ticker.mode.update_synd_icons_added(src)
			if (ticker.mode.syndicates.len==1)
				ticker.mode.prepare_syndicate_leader(src)
			else
				current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
			special_role = "Syndicate"
			assigned_role = "MODE"
			current << "\blue You are a [syndicate_name()] agent!"
			ticker.mode.forge_syndicate_objectives(src)
			ticker.mode.greet_syndicate(src)

			current.loc = get_turf(locate("landmark*Syndicate-Spawn"))

			var/mob/living/carbon/human/H = current
			del(H.belt)
			del(H.back)
			del(H.l_ear)
			del(H.r_ear)
			del(H.gloves)
			del(H.head)
			del(H.shoes)
			del(H.wear_id)
			del(H.wear_suit)
			del(H.w_uniform)

			ticker.mode.equip_syndicate(current)

	proc/make_Changling()
		if(!(src in ticker.mode.changelings))
			ticker.mode.changelings += src
			ticker.mode.grant_changeling_powers(current)
			special_role = "Changeling"
			ticker.mode.forge_changeling_objectives(src)
			ticker.mode.greet_changeling(src)

	proc/make_Wizard()
		if(!(src in ticker.mode.wizards))
			ticker.mode.wizards += src
			special_role = "Wizard"
			assigned_role = "MODE"
			//ticker.mode.learn_basic_spells(current)
			if(!wizardstart.len)
				current.loc = pick(latejoin)
				current << "HOT INSERTION, GO GO GO"
			else
				current.loc = pick(wizardstart)

			ticker.mode.equip_wizard(current)
			for(var/obj/item/weapon/spellbook/S in current.contents)
				S.op = 0
			ticker.mode.name_wizard(current)
			ticker.mode.forge_wizard_objectives(src)
			ticker.mode.greet_wizard(src)


	proc/make_Cultist()
		if(!(src in ticker.mode.cult))
			ticker.mode.cult += src
			ticker.mode.update_cult_icons_added(src)
			special_role = "Cultist"
			current << "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>"
			current << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			var/datum/game_mode/cult/cult = ticker.mode
			if (istype(cult))
				cult.memoize_cult_objectives(src)
			else
				var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
				current << "<B>Objective #1</B>: [explanation]"
				current.memory += "<B>Objective #1</B>: [explanation]<BR>"
				current << "The convert rune is join blood self"
				current.memory += "The convert rune is join blood self<BR>"

		var/mob/living/carbon/human/H = current
		if (istype(H))
			var/obj/item/weapon/tome/T = new(H)

			var/list/slots = list (
				"backpack" = H.slot_in_backpack,
				"left pocket" = H.slot_l_store,
				"right pocket" = H.slot_r_store,
				"left hand" = H.slot_l_hand,
				"right hand" = H.slot_r_hand,
			)
			var/where = H.equip_in_one_of_slots(T, slots)
			if (!where)
			else
				H << "A tome, a message from your new master, appears in your [where]."

		if (!ticker.mode.equip_cultist(current))
			H << "Spawning an amulet from your Master failed."

	proc/make_Rev()
		if (ticker.mode.head_revolutionaries.len>0)
			// copy targets
			var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
			if (valid_head)
				for (var/datum/objective/mutiny/O in valid_head.objectives)
					var/datum/objective/mutiny/rev_obj = new
					rev_obj.owner = src
					rev_obj.target = O.target
					rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
					objectives += rev_obj
				ticker.mode.greet_revolutionary(src,0)
		ticker.mode.head_revolutionaries += src
		ticker.mode.update_rev_icons_added(src)
		special_role = "Head Revolutionary"

		ticker.mode.forge_revolutionary_objectives(src)
		ticker.mode.greet_revolutionary(src,0)

		var/list/L = current.get_contents()
		var/obj/item/device/flash/flash = locate() in L
		del(flash)
		take_uplink()
		var/fail = 0
	//	fail |= !ticker.mode.equip_traitor(current, 1)
		fail |= !ticker.mode.equip_revolutionary(current)



