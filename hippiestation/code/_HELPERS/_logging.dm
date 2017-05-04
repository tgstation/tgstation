/proc/log_mentor(text)
		GLOB.mentorlog.Add(text)
		GLOB.diary << "\[[time_stamp()]]MENTOR: [text]"