/datum/antagonist/ert/deathsquad/leader
	outfit = /datum/outfit/centcom/death_commando/officer // Now death squad have a leader

/datum/ert/deathsquad/New()
	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in SSmachines.get_machines_by_type(/obj/machinery/nuclearbomb/selfdestruct)
	mission = "Запустите механизм самоуничтожения на [station_name()], коды активации: [nuke.r_code]"
