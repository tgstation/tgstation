/**
 * # Raw Anomaly Cores
 *
 * The current precursor to anomaly cores, these are manufactured into 'finished' anomaly cores for use in research, items, and more.
 *
 * The current amounts created is stored in `SSresearch.created_anomaly_types[ANOMALY_CORE_TYPE_DEFINE] = amount`.
 * The hard limits are in `code/__DEFINES/anomalies.dm`.
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
	anomaly_type = /obj/item/assembly/signaler/anomaly/bluespace
	icon_state = "rawcore_bluespace"

/obj/item/raw_anomaly_core/vortex
	name = "raw vortex core"
	desc = "The raw core of a vortex anomaly. Feels heavy to the touch."
	anomaly_type = /obj/item/assembly/signaler/anomaly/vortex
	icon_state = "rawcore_vortex"

/obj/item/raw_anomaly_core/grav
	name = "raw gravity core"
	desc = "The raw core of a gravity anomaly. The air seems attracted to it."
	anomaly_type = /obj/item/assembly/signaler/anomaly/grav
	icon_state = "rawcore_grav"

/obj/item/raw_anomaly_core/pyro
	desc = "The raw core of a pyro anomaly. It is warm to the touch."
	name = "raw pyro core"
	anomaly_type = /obj/item/assembly/signaler/anomaly/pyro
	icon_state = "rawcore_pyro"

/obj/item/raw_anomaly_core/flux
	name = "raw flux core"
	desc = "The raw core of a flux anomaly, faintly crackling with energy."
	anomaly_type = /obj/item/assembly/signaler/anomaly/flux
	icon_state = "rawcore_flux"

/obj/item/raw_anomaly_core/hallucination
	name = "raw hallucination core"
	desc = "The raw core of a hallucination anomaly, makes your head spin."
	anomaly_type = /obj/item/assembly/signaler/anomaly/hallucination
	icon_state = "rawcore_hallucination"

/obj/item/raw_anomaly_core/random
	name = "random raw core"
	desc = "You should not see this!"
	icon_state = "rawcore_bluespace"

/obj/item/raw_anomaly_core/bioscrambler
	name = "raw bioscrambler core"
	desc = "The raw core of a bioscrambler anomaly, it squirms."
	anomaly_type = /obj/item/assembly/signaler/anomaly/bioscrambler
	icon_state = "rawcore_bioscrambler"

/obj/item/raw_anomaly_core/random/Initialize(mapload)
	. = ..()
	var/path = pick(subtypesof(/obj/item/raw_anomaly_core))
	new path(loc)
	return INITIALIZE_HINT_QDEL

/**
 * Created the resulting core after being "made" into it.
 *
 * Arguments:
 * * newloc - Where the new core will be created
 * * del_self - should we qdel(src)
 * * count_towards_limit - should we increment the amount of created cores on SSresearch
 */
/obj/item/raw_anomaly_core/proc/create_core(newloc, del_self = FALSE, count_towards_limit = FALSE)
	. = new anomaly_type(newloc)
	if(count_towards_limit)
		var/existing = SSresearch.created_anomaly_types[anomaly_type] || 0
		SSresearch.created_anomaly_types[anomaly_type] = existing + 1
	if(del_self)
		qdel(src)
