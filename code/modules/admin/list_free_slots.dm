/datum/admins/proc/list_free_slots()
	if(!check_rights())
		return
	var/dat = "<html><head><title>List Free Slots</title></head><body>"
	var/count = 0

	if(job_master)
		for(var/datum/job/job in job_master.occupations)
			count++
			var/J_title = html_encode(job.title)
			var/J_totPos = html_encode(job.total_positions)
			dat += "[J_title]: [J_totPos]<br>"

	dat += "</body>"
	var/winheight = 100 + (count * 20)
	winheight = min(winheight, 690)
	usr << browse(dat, "window=players;size=316x[winheight]")

