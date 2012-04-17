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