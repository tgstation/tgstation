///Component used on the arrival shuttle to automatically unbuckle people when they arrive on station
/datum/component/unbuckle_on_arrival

/datum/component/unbuckle_on_arrival/Initialize()
	RegisterSignal(src, COMSIG_NEW_PLAYER_ARRIVED_ON_STATION, PROC_REF(unbuckle_newcomer))

/datum/component/unbuckle_on_arrival/proc/unbuckle_newcomer()
	SIGNAL_HANDLER
	var/obj/structure/chair/seat = src
	seat.unbuckle_all_mobs()
