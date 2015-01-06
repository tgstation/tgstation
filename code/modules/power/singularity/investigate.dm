/area/engineering/engine/poweralert(var/state, var/source)
	if (state != poweralm)
		investigation_log(I_SINGULO,"has a power alarm!")
	..()