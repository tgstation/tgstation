/proc/log_mentor(text)
		GLOB.mentorlog.Add(text)
		GLOB.world_game_log << "\[[time_stamp()]]MENTOR: [text]"