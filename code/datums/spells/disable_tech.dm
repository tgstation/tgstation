/obj/spell/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range and doesn't require wizard garb."
	recharge = 400
	clothes_req = 0
	invocation = "NEC CANTIO"
	invocation_type = "whisper"
	range = 7

/obj/spell/disable_tech/Click()
	..()

	if(!cast_check())
		return

	invocation()

	empulse(src, (range-2), range)
	return