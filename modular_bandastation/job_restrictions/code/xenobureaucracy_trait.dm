/datum/station_trait/xenobureaucracy_error
	name = "Ксеноглавы"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_processes = FALSE
	weight = 0
	cost = STATION_TRAIT_COST_MINIMAL
	show_in_report = TRUE
	report_message = "Вследствии изменений в кадровой политике НаноТрейзен - ограничения по биологическому виду для командного состава были аннулированы."
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	sign_up_button = TRUE // only because with this flag our trait will be added to lobby_station_traits (which is sucks)
	public_in_lobby = TRUE
	trait_to_give = STATION_TRAIT_XENOBUREAUCRACY_ERROR
