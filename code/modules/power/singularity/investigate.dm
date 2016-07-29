<<<<<<< HEAD
/area/engine/engineering/poweralert(state, source)
	if (state != poweralm)
		investigate_log("has a power alarm!","singulo")
=======
/area/engineering/engine/poweralert(var/state, var/source)
	if (state != poweralm)
		investigation_log(I_SINGULO,"has a power alarm!")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()