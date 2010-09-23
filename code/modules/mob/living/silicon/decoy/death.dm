/mob/living/silicon/decoy/death(gibbed)
	src.stat = 2
	src.icon_state = "ai-crash"
	spawn(rand(10, 30))
		explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
			O.mode = 2
	return ..(gibbed)