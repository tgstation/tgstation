/// Screwyhud, makes the user's health bar hud wonky
/datum/hallucination/screwy_hud
	abstract_hallucination_parent = /datum/hallucination/screwy_hud
	random_hallucination_weight = 4

	/// The type of hud we give to the hallucinator
	var/screwy_hud_type = SCREWYHUD_NONE

/datum/hallucination/screwy_hud/start()
	hallucinator.apply_status_effect(screwy_hud_type, type)
	QDEL_IN(src, rand(10 SECONDS, 25 SECONDS))
	return TRUE

/datum/hallucination/screwy_hud/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.remove_status_effect(screwy_hud_type, type)
	return ..()

/datum/hallucination/screwy_hud/crit
	screwy_hud_type = /datum/status_effect/grouped/screwy_hud/fake_crit

/datum/hallucination/screwy_hud/dead
	screwy_hud_type = /datum/status_effect/grouped/screwy_hud/fake_dead

/datum/hallucination/screwy_hud/healthy
	screwy_hud_type = /datum/status_effect/grouped/screwy_hud/fake_healthy
