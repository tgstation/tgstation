/datum/blobstrain/reagent // Blobs that mess with reagents, all "legacy" ones // what do you mean "legacy" you never added an alternative
	var/datum/reagent/reagent

/datum/blobstrain/reagent/New(mob/eye/blob/new_overmind)
	. = ..()
	reagent = new reagent()


/datum/blobstrain/reagent/attack_living(mob/living/L)
	var/mob_protection = L.getarmor(null, BIO) * 0.01
	reagent.expose_mob(L, VAPOR, BLOB_REAGENTATK_VOL, TRUE, mob_protection, overmind)
	send_message(L)

/datum/blobstrain/reagent/blobbernaut_attack(mob/living/blobbernaut, atom/victim)
	..()
	if(!isliving(victim))
		return

	var/mob/living/living_victim = victim
	var/mob_protection = living_victim.getarmor(null, BIO) * 0.01
	reagent.expose_mob(living_victim, VAPOR, BLOBMOB_BLOBBERNAUT_REAGENTATK_VOL+blobbernaut_reagentatk_bonus, FALSE, mob_protection, overmind)//this will do between 10 and 20 damage(reduced by mob protection), depending on chemical, plus 4 from base brute damage.

/datum/blobstrain/reagent/on_sporedeath(mob/living/dead_minion, death_cloud_size)
	do_chem_smoke(range = death_cloud_size, holder = dead_minion, location = get_turf(dead_minion), reagent_type = reagent.type, reagent_volume = BLOBMOB_CLOUD_REAGENT_VOLUME, smoke_type = /datum/effect_system/fluid_spread/smoke/chem/medium)
	playsound(dead_minion, 'sound/mobs/non-humanoids/blobmob/blob_spore_burst.ogg', vol = 100, vary = TRUE)

// These can only be applied by blobs. They are what (reagent) blobs are made out of.
/datum/reagent/blob
	name = "Unknown"
	description = ""
	color = COLOR_WHITE
	taste_description = "bad code and slime"
	chemical_flags = NONE


/datum/reagent/blob/New()
	..()

	if(name == "Unknown")
		description = "shouldn't exist and you should adminhelp immediately."
	else if(description == "")
		description = "[name] is the reagent created by that type of blob."

/// Used by blob reagents to calculate the reaction volume they should use when exposing mobs.
/datum/reagent/blob/proc/return_mob_expose_reac_volume(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	if(exposed_mob.stat == DEAD || HAS_TRAIT(exposed_mob, TRAIT_BLOB_ALLY))
		return 0 //the dead, and blob mobs, don't cause reactions
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/// Exists to earmark the new overmind arg used by blob reagents.
/datum/reagent/blob/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	return ..()
