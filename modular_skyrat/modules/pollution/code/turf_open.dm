/turf/open/PolluteTurf(pollution_type, amount, cap)
	if(!pollution)
		pollution = new(src)
	if(cap && pollution.total_amount >= cap)
		return
	pollution.AddPollutant(pollution_type, amount)

/turf/open/PolluteListTurf(list/pollutions, cap)
	if(!pollution)
		pollution = new(src)
	if(cap && pollution.total_amount >= cap)
		return
	pollution.AddPollutantList(pollutions)

/turf/proc/PolluteTurf(pollution_type, amount, cap)
	return

/turf/proc/PolluteListTurf(list/pollutions, cap)
	return
