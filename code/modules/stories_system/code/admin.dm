/client/proc/view_stories()
	set name = "View Stories"
	set category = "Admin.Game"
	if(holder)
		var/list/dat = list("<html>")
		dat += SSstories.get_stories_info()
		dat += "</html>"
		usr << browse(dat.Join(), "window=roundstatus;size=500x500")
		log_admin("[key_name(usr)] viewed all active stories..")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "View Stories")
