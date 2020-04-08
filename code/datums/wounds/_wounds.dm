/datum/wound
	//Flags
	var/visibility_flags = 0

	//Fluff
	var/form = "injury"
	var/name = "ouchie"
	var/desc = ""
	var/treat_text = ""
	var/examine_desc = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	var/stage_prob = 4

	var/severity = WOUND_SEVERITY_MODERATE
	var/damtype = BRUTE

	//Other
	//var/list/viable_mobtypes = list(mob/living/carbon) //typepaths of viable mobs
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //which body parts we can affect
	var/mob/living/carbon/victim = null
	var/obj/item/bodypart/limb = null

	var/interaction_efficiency_penalty = 1
	var/damage_mulitplier_penalty = 1

	var/process_dead = FALSE //if this ticks while the host is dead

/datum/wound/Destroy()
	. = ..()
	remove_wound()
	qdel(src)

//add this disease if the host does not already have too many
///datum/wound/proc/apply_wound(mob/living/carbon/C, zone)
/datum/wound/proc/apply_wound(obj/item/bodypart/L)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones))
		return
	victim = L.owner
	//apply_woundif(!C.get_bodypart(zone) || )
		//return FALSE

	limb = L
	LAZYADD(victim.all_wounds, src)
	LAZYADD(limb.wounds, src)
	testing("Applying wound [name] to [victim] in [limb.name]")
	limb.update_wound()

//Return a string for admin logging uses, should describe the disease in detail

/datum/wound/proc/remove_wound()
	testing("Removing wound [name] from [victim] in [limb.name]")
	if(victim)
		LAZYREMOVE(victim.all_wounds, src)		//remove the datum from the list
		victim = null
	if(limb)
		limb.update_wound()
		LAZYREMOVE(limb.wounds, src)		//remove the datum from the list
		limb = null

//mob/living/carbon/proc/generate_wound()

/datum/wound/burn
	damtype = BURN

/datum/wound/brute
	damtype = BRUTE


/datum/wound/brute/dislocation
	name = "Joint Dislocation"
	desc = "Victim's bone is jammed out of place, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation may suffice."
	examine_desc = "awkwardly jammed out of place"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 0.5

/datum/wound/brute/hairline_fracture
	name = "Hairline Fracture"
	desc = "Victim's bone has suffered a crack in the foundation, causing serious pain and reduced functionality."
	treat_text = "Recommended light surgical application of bone gel, though splinting will prevent worsening situation."
	examine_desc = "grotesquely swollen"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 0.25
