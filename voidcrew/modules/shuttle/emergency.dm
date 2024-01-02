/obj/docking_port/mobile/emergency/request(obj/docking_port/stationary/S, area/signal_origin, reason, red_alert, set_coefficient=null)

/datum/controller/subsystem/shuttle/requestEvac(mob/user, call_reason)
	to_chat(user, span_alert("Calling the emergency shuttle is currently impossible, please try again later."))
