/**
  * # Raw Anomaly Cores
  *
  * The current precursor to anomaly cores, these are manufactured into 'finished' anomaly cores for use in research, items, and more.
  *
  * The current amounts created is stored in SSresearch.created_anomaly_types[ANOMALY_CORE_TYPE_DEFINE] = amount
  * The hard limits are in code/__DEFINES/anomalies.dm
  */
/obj/item/raw_anomaly_core
	name = "raw anomaly core"
	desc = "You shouldn't be seeing this. Someone screwed up."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "broken_state"

	/// Anomaly type
	var/anomaly_type

/obj/item/raw_anomaly_core/bluespace
	name = "raw bluespace core"
	desc = "The raw core of a bluespace anomaly, glowing and full of potential."
	anomaly_type = ANOMALY_TYPE_BLUESPACE
	icon_state = "rawcore_bluespace"

/obj/item/raw_anomaly_core/vortex
	name = "raw vortex core"
	desc = "The raw core of a vortex anomaly. Feels heavy to the touch."
	anomaly_type = ANOMALY_TYPE_VORTEX
	icon_state = "rawcore_vortex"

/obj/item/raw_anomaly_core/gravity
	name = "raw gravity core"
	desc = "The raw core of a gravity anomaly. The air seems attracted to it."
	anomaly_type = ANOMALY_TYPE_GRAVITATIONAL
	icon_state = "rawcore_gravity"

/obj/item/raw_anomaly_core/pyro
	desc = "The raw core of a pyro anomaly. It is warm to the touch."
	name = "raw pyro core"
	anomaly_type = ANOMALY_TYPE_PYRO
	icon_state = "rawcore_pyro"

/obj/item/raw_anomaly_core/flux
	name = "raw flux core"
	desc = "The raw core of a flux anomaly, faintly crackling with energy."
	anomaly_type = ANOMALY_TYPE_FLUX
	icon_state = "rawcore_flux"

/**
  * Created the resulting core after being "made" into it.
  *
  * Arguments:
  * * newloc - Where the new core will be created
  * * del_self - should we qdel(src)
  * * count_towards_limit - should we increment the amount of created cores on SSresearch
  */
/obj/item/raw_anomaly_core/proc/create_core(newloc, del_self = FALSE, count_towards_limit = FALSE)
	var/path
	switch(anomaly_type)
		if(ANOMALY_TYPE_BLUESPACE)
			path = /obj/item/assembly/signaler/anomaly/bluespace
		if(ANOMALY_TYPE_PYRO)
			path = /obj/item/assembly/signaler/anomaly/pyro
		if(ANOMALY_TYPE_FLUX)
			path = /obj/item/assembly/signaler/anomaly/flux
		if(ANOMALY_TYPE_GRAVITATIONAL)
			path = /obj/item/assembly/signaler/anomaly/grav
		if(ANOMALY_TYPE_VORTEX)
			path = /obj/item/assembly/signaler/anomaly/vortex
	. = new path(newloc)
	if(count_towards_limit)
		var/existing = SSresearch.created_anomaly_types[anomaly_type] || 0
		SSresearch.created_anomaly_types[anomaly_type] = existing + 1
	if(del_self)
		qdel(src)
