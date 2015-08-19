
/obj/mecha/working/hoverpod
	name = "hover pod"
	icon_state = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."
	wreckage = /obj/structure/mecha_wreckage/hoverpod
	stepsound = 'sound/machines/hiss.ogg'
	step_in = 2

/obj/mecha/working/hoverpod/Process_Spacemove(var/movement_dir = 0)
	return 1

//these three procs overriden to play different sounds
/obj/mecha/working/hoverpod/mechturn(direction)
	dir = direction
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1


/obj/structure/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"

