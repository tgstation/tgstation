/datum/universal_state/christmas
 	name = "Christmas"
 	desc = "Unknown"

 	decay_rate = 0 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

 	var/space_overlay1 = null
 	var/space_overlay2 = null

/datum/universal_state/christmas/OnTurfChange(var/turf/T)
	if(istype(T,/turf/simulated/floor))
		new /obj/structure/snow(T)
	if(istype(T,/turf/space) && !istype(T,/turf/space/transit))
		var/turf/space/spess=T
		spess.overlays += space_overlay1
		spess.overlays += space_overlay2

// Apply changes when entering state
/datum/universal_state/christmas/OnEnter()
	space_overlay1 = image(icon='icons/turf/snowfx.dmi',icon_state="snowlayer1")
	space_overlay2 = image(icon='icons/turf/snowfx.dmi',icon_state="snowlayer2")

	to_chat(world, "<span class='sinister' style='font-size:22pt'>You feel a sudden chill in the air...</span>")

	// Yes, this will lag.  No, there's nothing I can do about it.
	for(var/turf/T in turfs)
		OnTurfChange(T)

/client/proc/smissmas()
	set category = "Fun"
	set name = "Execute Smissmas"
	if(!holder)
		return
	var/confirm = alert(src, "Are you sure? This will tamper with the universal state of all things!", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return
	SetUniversalState(/datum/universal_state/christmas)