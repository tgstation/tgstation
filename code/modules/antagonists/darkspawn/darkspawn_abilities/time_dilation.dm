//Greatly speeds up reflexes and recovery, at a massive Psi cost.
/datum/action/innate/darkspawn/time_dilation
	name = "Time Dilation"
	id = "time_dilation"
	desc = "Greatly increases reaction times and action speed, and provides immunity to slowdown. This lasts for 1 minute. Costs 75 Psi."
	button_icon_state = "time_dilation"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 75
	lucidity_price = 3

/datum/action/innate/darkspawn/time_dilation/IsAvailable()
	if(..())
		var/mob/living/L = owner
		return !L.has_status_effect(STATUS_EFFECT_TIME_DILATION)

/datum/action/innate/darkspawn/time_dilation/Activate()
	var/mob/living/L = owner
	L.apply_status_effect(STATUS_EFFECT_TIME_DILATION)
	L.visible_message("<span class='warning'>[L] howls as their body moves at wild speeds!</span>", \
	"<span class='velvet'><b>ckppw ck bwop</b><br>Your sigils howl out light as your body moves at incredible speed!</span>")
	playsound(L, 'sound/creatures/darkspawn_howl.ogg', 50, TRUE)
	return TRUE
