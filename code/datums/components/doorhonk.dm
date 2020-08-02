/datum/component/doorhonk

	var/honkSound = 'sound/items/bikehorn.ogg'
	var/volume = 30
	var/honkLeft
	var/infinite = FALSE

/datum/component/doorhonk/Initialize(volume_override = 30, infinite_honking = FALSE)
	if(!istype(parent, /obj/machinery/door/airlock)) //This component only works for doors.
		return COMPONENT_INCOMPATIBLE

	honkLeft = (rand(15,20)) //This component works for an amount of honk between 15 and 20

	volume = volume_override || volume //If a volume_override is specified, use its value, otherwise default to volume = 30

	if(infinite_honking)
		infinite = TRUE

	RegisterSignal(parent, list(COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE), .proc/play_sound)

/datum/component/doorhonk/proc/play_sound()
	playsound(parent, honkSound, volume, TRUE)
	if(infinite)
		return
	honkLeft --
	if(honkLeft <= 0)
		qdel(src)
