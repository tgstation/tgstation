///base class for withdrawal, handles when you become addicted and what the effects of that are
/datum/withdrawal
	///Name of this addiction
	var/name = "cringe code withdrawal"
	///Lower threshold, when you stop being addicted
	var/addiction_loss_threshold = 400
	///Higher threshold, when you start being addicted
	var/addiction_gain_threshold = 600


/datum/withdrawal/proc/on_gain_addiction_points(/datum/mind/victim_mind)
	new_addiction_point_amount = victim_mind.addiction_points[src.type]
	if(victim_mind.with)
