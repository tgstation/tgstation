/atom/movable/screen/fullscreen/soul_punishment
	icon_state = "soul_punishment"
	alpha = 60

/atom/movable/screen/fullscreen/nearby // made seperate from soul punishment because the intensity gets worse over time
	icon_state = "soul_punishment"
	alpha = 100

/mob/living
	/// A weak reference to the team monitor component contained within the monitor holder, used for certain antagoists so they can track
	var/datum/component/team_monitor/team_monitor
	///a reference to a stored /datum/component/tracking_beacon used by victims of antags
	var/datum/component/tracking_beacon/tracking_beacon
