/// Screwyhud, makes the user's health bar hud wonky
/datum/hallucination/screwy_hud
	/// The type of hud we give to the hallucinator
	var/screwy_hud_type = SCREWYHUD_NONE

/datum/hallucination/screwy_hud/start()
	hallucinator.AddElement(/datum/element/screwy_hud, screwy_hud_type)
	QDEL_IN(src, rand(10 SECONDS, 25 SECONDS))
	return TRUE

/datum/hallucination/screwy_hud/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.RemoveElement(/datum/element/screwy_hud, screwy_hud_type)
	return ..()

/datum/hallucination/screwy_hud/crit
	screwy_hud_type = SCREWYHUD_CRIT

/datum/hallucination/screwy_hud/dead
	screwy_hud_type = SCREWYHUD_DEAD

/datum/hallucination/screwy_hud/healthy
	screwy_hud_type = SCREWYHUD_HEALTHY
