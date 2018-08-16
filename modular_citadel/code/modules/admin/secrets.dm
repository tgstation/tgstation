/datum/admins/proc/CitadelMentorLogSecret()
	var/dat = "<B>Mentor Log<HR></B>"
	for(var/l in GLOB.mentorlog)
		dat += "<li>[l]</li>"

	if(!GLOB.mentorlog.len)
		dat += "No mentors have done anything this round!"
	usr << browse(dat, "window=mentor_log")