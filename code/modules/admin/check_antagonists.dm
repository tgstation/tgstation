/datum/admins/proc/check_antagonists()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"

		dat += {"Current Game Mode: <B>[ticker.mode.name]</B><BR>
			Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>
			<B>Emergency shuttle</B><BR>"}
		if (!emergency_shuttle.online)
			dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = emergency_shuttle.timeleft()
			switch(emergency_shuttle.location)
				if(0)

					dat += {"ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>
						<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"}
				if(1)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
		dat += "<a href='?src=\ref[src];delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		if(ticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.syndicates)
				var/mob/M = N.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
				else
					dat += "<tr><td><i>Nuclear Operative not found!</i></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			var/obj/item/weapon/disk/nuclear/N = locate()
			if(N)
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

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
			for(var/datum/mind/N in ticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in ticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"}
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

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Changeling not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.wizards.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Wizards</B></td><td></td><td></td></tr>"
			for(var/datum/mind/wizard in ticker.mode.wizards)
				var/mob/M = wizard.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Wizard not found!</i></td></tr>"
			dat += "</table>"

		/* REMOVED as requested
		if(ticker.mode.raiders.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Raiders</B></td><td></td><td></td></tr>"
			for(var/datum/mind/raider in ticker.mode.raiders)
				var/mob/M = raider.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
			dat += "</table>"
		*/

		/*
		if(ticker.mode.ninjas.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Ninjas</B></td><td></td><td></td></tr>"
			for(var/datum/mind/ninja in ticker.mode.ninjas)
				var/mob/M = ninja.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Ninja not found!</i></td></tr>"
			dat += "</table>"
		*/

		if(ticker.mode.cult.len)
			dat += "<br><table cellspacing=5><tr><td><B>Cultists</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.cult)
				var/mob/M = N.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A href='?src=\ref[src];cult_privatespeak=\ref[M]'>Nar-Speak</A></td></tr>"}
			dat += "</table>"

			var/living_crew = 0
			var/living_cultists = 0
			for(var/mob/living/L in player_list)
				if(L.stat != DEAD)
					if(L.mind in ticker.mode.cult)
						living_cultists++
					else
						if(istype(L, /mob/living/carbon))
							living_crew++

			dat += "<br>[living_cultists] living cultists. (use <a href='?src=\ref[src];cult_mindspeak=\ref[src]'>Voice of Nar-Sie</a>)"
			dat += "<br>[living_crew] living non-cultists."
			dat += "<br>"

			var/datum/game_mode/cult/cult_round = find_active_mode("cult")
			if(cult_round)
				dat += "<br><B>Cult Objectives:</B>"

				for(var/obj_count=1, obj_count <= cult_round.objectives.len, obj_count++)
					var/explanation
					switch(cult_round.objectives[obj_count])
						if("convert")
							explanation = "Reach a total of [cult_round.convert_target] cultists.[(obj_count < cult_round.objectives.len) ? "<font color='green'><B>Success!</B></font>" : "(currently [cult_round.cult.len] cultists)"]"
						if("bloodspill")
							explanation = "Cover [cult_round.spilltarget] tiles in blood.[(obj_count < cult_round.objectives.len) ? "<font color='green'><B>Success!</B></font>" : "(currently [cult_round.bloody_floors.len] bloody floors)"]"
						if("sacrifice")
							explanation = "Sacrifice [cult_round.sacrifice_target.name], the [cult_round.sacrifice_target.assigned_role].[(obj_count < cult_round.objectives.len) ? "<font color='green'><B>Success!</B></font>" : ""]"
						if("eldergod")
							explanation = "Summon Nar-Sie.[(obj_count < cult_round.objectives.len) ? "<font color='green'><B>Success!</B></font>" : ""]"
						if("harvest")
							explanation = "Bring [cult_round.harvest_target] humans directly to Nar-Sie.[cult_round.bonus ? "<font color='green'><B>Success!</B></font>" : "(currently [cult_round.harvested] sacrifices)"]"
						if("hijack")
							explanation = "Don't let any non-cultist escape on the Shuttle alive.[cult_round.bonus ? "<font color='green'><B>Success!</B></font>" : ""]"
						if("massacre")
							explanation = "Massacre the crew until there are less than [cult_round.massacre_target] people left on the station.[cult_round.bonus ? "<font color='green'><B>Success!</B></font>" : ""]"

					dat += "<br><B>Objective #[obj_count]</B>: [explanation]"

				if(!cult_round.narsie_condition_cleared)
					dat += "<br><a href='?src=\ref[src];cult_nextobj=\ref[src]'>complete objective (debug)</a>"

		/*if(istype(ticker.mode, /datum/game_mode/anti_revolution) && ticker.mode:heads.len)	//comment out anti-revolution
			dat += "<br><table cellspacing=5><tr><td><B>Corrupt Heads</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode:heads)
				var/mob/M = N.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
			dat += "</table>"
*/

		if(ticker.mode.vampires.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Vampires</B></td><td></td><td></td></tr>"
			for(var/datum/mind/vampire in ticker.mode.vampires)
				var/mob/M = vampire.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Vampire not found!</i></td></tr>"

		if(ticker.mode.enthralled.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Thralls</B></td><td></td><td></td></tr>"
			for(var/datum/mind/Mind in ticker.mode.enthralled)
				var/mob/M = Mind.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Enthralled not found!</i></td></tr>"

		if(ticker.mode.traitors.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/traitor in ticker.mode.traitors)
				var/mob/M = traitor.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
				else
					dat += "<tr><td><i>Traitor not found!</i></td></tr>"
			dat += "</table>"

		if(istype(ticker.mode, /datum/game_mode/blob))
			var/datum/game_mode/blob/mode = ticker.mode

			dat += {"<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>
				<tr><td><i>Progress: [blobs.len]/[mode.blobwincount]</i></td></tr>"}
			for(var/datum/mind/blob in mode.infected_crew)
				var/mob/M = blob.current
				if(M)

					dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
				else
					dat += "<tr><td><i>Blob not found!</i></td></tr>"
			dat += "</table>"
		else if(locate(/mob/camera/blob) in mob_list)
			dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			for(var/mob/M in mob_list)
				if(istype(M, /mob/camera/blob))

					dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
			dat += "</table>"
		if(ticker.mode.raiders.len)
			dat += "<br><table cellspacing=5><tr><td><B>Raiders</B></td><td></td><td></td></tr>"
			for(var/datum/mind/vox in ticker.mode.raiders)
				var/mob/M = vox.current
				if(M)
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
				else
					dat += "<tr><td><i>Vox Raider not found!</i></td></tr>"
			dat += "</table>"
		if(istype(ticker.mode, /datum/game_mode/heist))
			var/datum/game_mode/heist/mode_ticker = ticker.mode
			var/objective_count = 1
			dat += "<br><B>Raider Objectives:</B>"
			for(var/datum/objective/objective in mode_ticker.raid_objectives)
				dat += "<BR><B>Objective #[objective_count++]</B>: [objective.explanation_text]</td></tr>"

		if(ticker.mode.ert.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>ERT</B></td><td></td><td></td></tr>"
			for(var/datum/mind/ert in ticker.mode.ert)
				var/mob/M = ert.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"}

				else
					dat += "<tr><td><i>Emergency Responder not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.deathsquad.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Deathsquad</B></td><td></td><td></td></tr>"
			for(var/datum/mind/deathsquad in ticker.mode.deathsquad)
				var/mob/M = deathsquad.current
				if(M)

					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"}

				else
					dat += "<tr><td><i>Death Commando not found!</i></td></tr>"
			dat += "</table>"

		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=440x500")
	else
		alert("The game hasn't started yet!")
