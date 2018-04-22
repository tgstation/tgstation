/client/proc/view_pod_logs()
	set name = "View Pod Logs"
	set category = "Special Verbs"

	var/dat = {"
				<script type='text/css'>

					td {
						border: 1px solid black;
						border-collapse: collapse;
						word-wrap: break-word;
					}

				</script>

				<table width=100% height=100% style='border: 1px solid black; border-collapse: collapse'>
					<tr>
						<th>Name</th>
						<th>Occupants</th>
						<th>Coordinates</th>
						<th>Actions</th>
					</tr>
				"}

	var/show_dbg = check_rights(R_ADMIN)

	dat += "<center>"

	for(var/datum/pod_log/log in pod_logs)
		var/actions = "<a href='?_src_=holder;view_pod_log=\ref[log]'>VL</a>"
		var/pod_destroyed = (log.holder ? 0 : 1)

		if(show_dbg && !pod_destroyed)
			actions += "|<a href='?_src_=holder;view_pod_debug=\ref[log.holder]'>DBG</a>"

		if(pod_destroyed)
			dat += "<tr><td>N/A</td><td>N/A</td><td>N/A</td><td>[actions]</td></tr>"
		else
			var/obj/pod/pod = log.holder
			var/list/occupants = pod.GetOccupants()
			dat += "<tr><td>[pod.name]</td><td>"
			for(var/mob/living/occupant in occupants)
				dat += "[key_name(occupant)] [pod.pilot ? ((occupant == pod.pilot) ? "Pilot" : "Passenger") : "Passenger"]"
				dat += "[(occupants.Find(occupant) != length(occupants)) ? "<br>" : ""]"
			dat += "</td>"
			dat += "<td>{[pod.x], [pod.y], [pod.z]}</td>"
			dat += "<td>[actions]</td></tr>"

	dat += "</center>"
	dat += "</table>"

	var/datum/browser/popup = new(usr, "p_view_logs", "Pod Logs", 650, 450)
	popup.set_content(dat)
	popup.open()

/obj/pod

	proc/OpenDebugMenu(var/mob/user)
		var/dat

		var/show_actions = check_rights(R_ADMIN)
		var/actions
		if(show_actions)
			actions = "<a href='?src=\ref[src];action=damage'>Damage</a>|<a href='?src=\ref[src];action=heal'>Heal</a>"

		dat += "<h2>Stats</h2><br>"
		dat += "Pod type: [type]<br>"
		dat += "Pod health: [health]/[max_health] ([HealthPercent()]%) [actions]<br>"

		if(power_source)
			actions = "<a href='?src=\ref[src];action=charge'>Charge</a>|<a href='?src=\ref[src];action=remove_charge'>Remove Charge</a>"
			dat += "Battery Type: [power_source.type]<br>"
			dat += "Charge: [power_source.charge]/[power_source.maxcharge] ([power_source.percent()]%) [actions]<br>"

		dat += "<br><h2>Occupants</h2><br>"

		if(length(GetOccupants()) > 0)
			for(var/mob/living/L in GetOccupants())
				dat += "[pilot ? ((L == pilot) ? "Pilot" : "Passenger") : "Passenger"]: [key_name_admin(L)]<br>"
		else
			dat += "Unoccupied."

		dat += "<br><h2>Attachments</h2><br>"

		for(var/obj/item/pod_attachment/attachment in GetAttachments())
			actions = "<a href='?src=\ref[src];action=remove_attachment;attachment=\ref[attachment]'>Remove</a>"
			dat += "([attachment.GetHardpointDisplayName()]) - [attachment.name] ([attachment.type]) [actions]<br>"

		var/obj/item/pod_attachment/cargo/cargo = GetAttachmentOnHardpoint(P_HARDPOINT_CARGO_HOLD)
		if(cargo)
			if(length(cargo.contents) > 0)
				dat += "<br>Cargo contents: <br>"
				for(var/atom/A in cargo)
					dat += "\t  >[A] - [A.type]<br>"
				dat += "<br>"

		var/datum/browser/popup = new(user, "p_debug_menu", "Pod Debug Menu", 480, 350)
		popup.set_content(dat)
		popup.open()
