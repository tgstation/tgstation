/obj/item/analyzer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag || can_see(user, target, ranged_scan_distance))
		var/turf/target_turf = get_turf(target)
		for(var/obj/effect/anomaly/anomaly in target_turf)
			if(anomaly.scan_anomaly(user, src))
				return AFTERATTACK_PROCESSED_ITEM
	return ..()
