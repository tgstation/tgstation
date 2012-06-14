/obj/admins/proc/player_panel_new()//The new one
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Name/Real Name</th><th>Type</th><th>Assigned Job</th><th>Info</th><th>Options</th><th>Traitor?</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = get_sorted_mobs()
	var/i = 1

	for(var/mob/M in mobs)
		if(M.ckey)
			var/color = "#e6e6e6"
			i++
			if(i%2 == 0)
				color = "#f2f2f2"
			var/real = (M.real_name == M.original_name ? "<b>[M.name]/[M.real_name]</b>" : "<b>[M.original_name] (as [M.name]/[M.real_name])</b>")
			var/turf/T = get_turf(M)
			var/client_key = (M.key? M.key : "No key")
			dat += "<tr align='center' bgcolor='[color]'><td>[real] <br>[M.client ? M.client : "No client ([client_key])"] at ([T.x], [T.y], [T.z])</td>" // Adds current name
			if(isobserver(M))
				dat += "<td>Ghost</td>"
			else if(isalien(M))
				dat += "<td>Alien</td>"
			else if(islarva(M))
				dat += "<td>Alien larva</td>"
			else if(istajaran(M))
				dat += "<td>Tajaran</td>"
			else if(ishuman(M))
				dat += "<td>[M.job]</td>"
			else if(ismetroid(M))
				dat += "<td>Metroid</td>"
			else if(ismonkey(M))
				dat += "<td>Monkey</td>"
			else if(isAI(M))
				dat += "<td>AI</td>"
			else if(ispAI(M))
				dat += "<td>pAI</td>"
			else if(isrobot(M))
				dat += "<td>Cyborg</td>"
			else if(isanimal(M))
				dat += "<td>Animal</td>"
			else if(iscorgi(M))
				dat += "<td>Corgi</td>"
			else if(istype(M,/mob/new_player))
				dat += "<td>New Player</td>"
			else
				dat += "<td>\red ERROR</td>\black"

			if(M.mind && M.mind.assigned_role && istype(M, /mob/living/carbon/human))	// Adds a column to Player Panel that shows their current job.
				var/mob/living/carbon/human/H = M

				if (H.wear_id)
					var/obj/item/weapon/card/id/id

					if(istype(H.wear_id, /obj/item/device/pda))
						var/obj/item/device/pda/PDA = H.wear_id
						if(!isnull(PDA.id))				// The PDA may contain no ID
							id = PDA.id					// The ID is contained inside the PDA

					else
						id = H.wear_id					// The ID was on the ID slot

					if(!id) 							// Happens when there's no ID in the PDA located on the wear_id slot
						dat += "<td>[M.mind.assigned_role] (No ID)</td>"

					else if(isnull(id.assignment))		// Preventing runtime errors blocking the player panel
						if(istype(id, /obj/item/weapon/card/id/syndicate))
							dat += "<td><font color=purple>Antagonist</font></td>"
						else
							usr << "<font color=red>ERROR:</font> Inform the coders that an [id.name] was checked for its assignment variable, and it was null."
							dat += "<td><font color=red>ERROR</font></td>"

					else
						if(M.mind.assigned_role == id.assignment)			// Polymorph
							dat += "<td>[M.mind.assigned_role]</td>"

						else
							dat += "<td>[M.mind.assigned_role] ([id.assignment])"

				else
					dat += "<td>[M.mind.assigned_role] (No ID)</td>"

			else
				dat += "<td>No Assigned Role</td>"

			var/muting = "Mute unavailable - no client"
			if(M.client)
				muting = {"<A href='?src=\ref[src];mute2=\ref[M]'>Mute: [(M.client.muted ? "Muted" : "Voiced")]</A> |
				<A href='?src=\ref[src];mute_complete=\ref[M]'>Complete mute: [(M.client.muted ? "Completely Muted" : "Voiced")]</A>
				"}

			dat += {"<td><A HREF='?src=\ref[src];player_info=[M.ckey]'>[player_has_info(M.ckey) ? "Info" : "N/A"] </A></td>
			<td><A href='?src=\ref[usr];priv_msg=\ref[M]'><b>PM</b></A> |
			<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A> |
			<A HREF='?src=\ref[src];adminplayervars=\ref[M]'>VV</A> |
			<A HREF='?src=\ref[src];traitor_panel_pp=\ref[M]'>TP</A> |
			<A HREF='?src=\ref[src];adminplayersubtlemessage=\ref[M]'>SM</A> |
			<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A></font>
			<br><font size="2">[muting]</font><br>
			<font size="2"><A href='?src=\ref[src];warn=\ref[M]'>Warn</A> | <A href='?src=\ref[src];boot2=\ref[M]'>Boot</A> | <A href='?src=\ref[src];newban=\ref[M]'>Ban</A> | <A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A></td>
			"}

			switch(is_special_character(M))
				if(0)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
				if(1)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red>Traitor?</font></A></td>"}
				if(2)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red><b>Traitor?</b></font></A></td>"}

	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=905x600")


/obj/admins/proc/mod_panel()//The new one
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Name/Real Name</th><th>IP/CID</th><th>Info</th><th>Options</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking <th>Type</th> <th>Assigned Job</th> <th>Traitor?</th>
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = get_sorted_mobs()
	var/i = 1

	for(var/mob/M in mobs)
		if(M.ckey)
			var/color = "#e6e6e6"
			i++
			if(i%2 == 0)
				color = "#f2f2f2"
			var/real = (M.real_name == M.original_name ? "<b>[M.name]/[M.real_name]</b>" : "<b>[M.original_name] (as [M.name]/[M.real_name])</b>")
			var/turf/T = get_turf(M)
			var/client_key = (M.key? M.key : "No key")
			dat += "<tr align='center' bgcolor='[color]'><td>[real] <br>[M.client ? M.client : "No client ([client_key])"] at ([T.x], [T.y], [T.z])</td>" // Adds current name
/*			if(isobserver(M))
				dat += "<td>Ghost</td>"
			else if(isalien(M))
				dat += "<td>Alien</td>"
			else if(islarva(M))
				dat += "<td>Alien larva</td>"
			else if(istajaran(M))
				dat += "<td>Tajaran</td>"
			else if(ishuman(M))
				dat += "<td>[M.job]</td>"
			else if(ismetroid(M))
				dat += "<td>Metroid</td>"
			else if(ismonkey(M))
				dat += "<td>Monkey</td>"
			else if(isAI(M))
				dat += "<td>AI</td>"
			else if(ispAI(M))
				dat += "<td>pAI</td>"
			else if(isrobot(M))
				dat += "<td>Cyborg</td>"
			else if(isanimal(M))
				dat += "<td>Animal</td>"
			else if(iscorgi(M))
				dat += "<td>Corgi</td>"
			else if(istype(M,/mob/new_player))
				dat += "<td>New Player</td>"
			else
				dat += "<td>\red ERROR</td>\black"

			if(M.mind && M.mind.assigned_role && istype(M, /mob/living/carbon/human))	// Adds a column to Player Panel that shows their current job.
				var/mob/living/carbon/human/H = M

				if (H.wear_id)
					var/obj/item/weapon/card/id/id

					if(istype(H.wear_id, /obj/item/device/pda))
						var/obj/item/device/pda/PDA = H.wear_id
						if(!isnull(PDA.id))				// The PDA may contain no ID
							id = PDA.id					// The ID is contained inside the PDA

					else
						id = H.wear_id					// The ID was on the ID slot

					if(!id) 							// Happens when there's no ID in the PDA located on the wear_id slot
						dat += "<td>[M.mind.assigned_role] (No ID)</td>"

					else if(isnull(id.assignment))		// Preventing runtime errors blocking the player panel
						if(istype(id, /obj/item/weapon/card/id/syndicate))
							dat += "<td><font color=purple>Antagonist</font></td>"
						else
							usr << "<font color=red>ERROR:</font> Inform the coders that an [id.name] was checked for its assignment variable, and it was null."
							dat += "<td><font color=red>ERROR</font></td>"

					else
						if(M.mind.assigned_role == id.assignment)			// Polymorph
							dat += "<td>[M.mind.assigned_role]</td>"

						else
							dat += "<td>[M.mind.assigned_role] ([id.assignment])"

				else
					dat += "<td>[M.mind.assigned_role] (No ID)</td>"

			else
				dat += "<td>No Assigned Role</td>"
*/
			dat += {"<td>IP: [M.client.address]<br>
			CID: [M.client.computer_id]</td>
			"}

			dat += {"<td><A HREF='?src=\ref[src];player_info=[M.ckey]'>[player_has_info(M.ckey) ? "Info" : "N/A"] </A></td>
			<td><A href='?src=\ref[usr];priv_msg=\ref[M]'><b>PM</b></A></td>
			"}

/*			switch(is_special_character(M))
				if(0)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
				if(1)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red>Traitor?</font></A></td>"}
				if(2)
					dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red><b>Traitor?</b></font></A></td>"}
*/
	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=600x600")

//The old one
/obj/admins/proc/player_panel_old()
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Name</th><th>Real Name</th><th>Assigned Job</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = get_sorted_mobs()

	for(var/mob/M in mobs)
		if(!M.ckey)	continue

		dat += "<tr><td>[M.name]</td>"
		if(isAI(M))
			dat += "<td>AI</td>"
		else if(isrobot(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(istype(M, /mob/living/silicon/pai))
			dat += "<td>pAI</td>"
		else if(istype(M, /mob/new_player))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else if(ismonkey(M))
			dat += "<td>Monkey</td>"
		else if(isalien(M))
			dat += "<td>Alien</td>"
		else
			dat += "<td>Unknown</td>"


		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.assigned_role)
				dat += "<td>[H.mind.assigned_role]</td>"
		else
			dat += "<td>NA</td>"


		dat += {"<td>[(M.client ? "[M.client]" : "No client")]</td>
		<td align=center><A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>X</A></td>
		<td align=center><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
		"}
		switch(is_special_character(M))
			if(0)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
			if(1)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red>Traitor?</font></A></td>"}
			if(2)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red><b>Traitor?</b></font></A></td>"}

	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=640x480")



/obj/admins/proc/check_antagonists()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
		dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
		dat += "<B>Emergency shuttle</B><BR>"
		if (!emergency_shuttle.online)
			dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = emergency_shuttle.timeleft()
			switch(emergency_shuttle.location)
				if(0)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
					dat += "<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"
				if(1)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"

		if(ticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.syndicates)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
				else
					dat += "<tr><td><i>Nuclear Operative not found!</i></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/weapon/disk/nuclear/N in world)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!istype(disk_loc, /turf))
					if(istype(disk_loc, /mob))
						var/mob/M = disk_loc
						dat += "carried by <a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> "
					if(istype(disk_loc, /obj))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		if(ticker.mode.head_revolutionaries.len || ticker.mode.revolutionaries.len)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.head_revolutionaries)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><i>Head Revolutionary not found!</i></td></tr>"
				else
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			for(var/datum/mind/N in ticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in ticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					var/turf/mob_loc = get_turf(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><i>Head not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.changelings.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Changelings</B></td><td></td><td></td></tr>"
			for(var/datum/mind/changeling in ticker.mode.changelings)
				var/mob/M = changeling.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					dat += "<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><i>Changeling not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.memes.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Memes</B></td><td></td><td></td></tr>"
			for(var/datum/mind/meme in ticker.mode.memes)
				// BUG: For some reason, the memes themselves aren't showing up, even though the list isn't empty
				// and the "Meme" header is displayed
				var/mob/living/parasite/meme/M = meme.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.key]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					dat += "<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"

					// need this check because the meme may be possessing someone right now
					if(istype(M))
						dat += "\t<td>Attuned: "
						for(var/mob/attuned in M.indoctrinated)
							if(attuned.key)
								dat += "[attuned.real_name]([attuned.key]) "
							else
								dat += "[attuned.real_name] "
				else
					dat += "<tr><td><i>Changeling not found!</i></td></tr>"
			dat += "</table>"


		if(ticker.mode.wizards.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Wizards</B></td><td></td><td></td></tr>"
			for(var/datum/mind/wizard in ticker.mode.wizards)
				var/mob/M = wizard.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					dat += "<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><i>Wizard not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.cult.len)
			dat += "<br><table cellspacing=5><tr><td><B>Cultists</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.cult)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			dat += "</table>"

		if(ticker.mode.traitors.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/traitor in ticker.mode.traitors)
				var/mob/M = traitor.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					dat += "<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><i>Traitor not found!</i></td></tr>"
			dat += "</table>"

		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=400x500")
	else
		alert("The game hasn't started yet!")
