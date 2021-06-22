// Need some sprites for a generic item that looks like it does a thing?
// Use the old GANGTOOL SPRITES!
/obj/item/patient_spawner
	name = "patient spawner"
	desc = "Use this in hand to request the airdrop of some very sick patients!"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_TINY

/obj/item/patient_spawner/attack_self(mob/user)
	user.visible_message("<span class='warning'>[user] activates [src]! Looks like some patients are on route!</span>")
	do_sparks(5, FALSE, get_turf(src))

	// Add additional spawners to this list to get more patients.
	var/spawners = list(
		/obj/effect/mob_spawn/human/appendicitis_patient,
		/obj/effect/mob_spawn/human/hugged_patient,
		/obj/effect/mob_spawn/human/bone_hurting_juice_patient,
		/obj/effect/mob_spawn/human/decayed_patient,
	)

	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(3, 3)

	// Keep a reference to the empty turf, so we can spawn stuff on it
	var/turf/floor

	// Regretably, the away mission spawners spawn mobs on the turf they are on
	// So we need to make a little box, so we can get our bodies
	// to shove into drop pods.
	for(var/turf/reserved_turf in reservation.reserved_turfs)
		var/turf_type = /turf/open/floor/iron
		if(reserved_turf.x == reservation.bottom_left_coords[1] || reserved_turf.x == reservation.top_right_coords[1] || reserved_turf.y == reservation.bottom_left_coords[2] || reserved_turf.y == reservation.top_right_coords[2])
			turf_type = /turf/closed/wall/r_wall
		else
			floor = reserved_turf

		reserved_turf.ChangeTurf(turf_type)
		reserved_turf.AddElement(/datum/element/forced_gravity)

	var/list/mobs = list()

	for(var/spawner_type in spawners)
		// All the spawners should be initial=FALSE, roundstart=FALSE, otherwise
		// they might double create.
		var/obj/effect/mob_spawn/mob_spawn = new spawner_type(floor)
		mobs += mob_spawn.create()

	var/nearby = orange(3, get_turf(src))
	for(var/mob/living/spawned_mob in mobs)
		var/obj/structure/closet/supplypod/centcompod/pod = new
		spawned_mob.forceMove(pod)
		new /obj/effect/pod_landingzone(pick(nearby), pod)

	qdel(src)
	qdel(reservation)

/obj/effect/mob_spawn/human/appendicitis_patient
	name = "Appendicitis Patient"
	death = FALSE
	roundstart = FALSE
	instant = FALSE
	outfit = /datum/outfit/job/cook

/obj/effect/mob_spawn/human/appendicitis_patient/create()
	var/mob/living/mob = ..()
	var/datum/disease/appendicitis/disease = new

	// They have been sick for a while, each "firing" of stage 3 appendicitis
	// causes 15 appendix damage.
	mob.adjustToxLoss(5)
	mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 15)

	disease.stage = 3
	mob.ForceContractDisease(disease, make_copy=FALSE, del_on_fail=TRUE)
	// Only stage 2 marks the appendix as "inflamed", need to do so ourselves.
	var/obj/item/organ/appendix/appendix = mob.getorgan(/obj/item/organ/appendix)
	appendix.inflamed = TRUE

	return mob

/obj/effect/mob_spawn/human/hugged_patient
	name = "Infested Patient"
	death = FALSE
	roundstart = FALSE
	instant = FALSE
	outfit = /datum/outfit/centcom/death_commando/disarmed
	mask = /obj/item/clothing/mask/facehugger/impregnated

/obj/effect/mob_spawn/human/hugged_patient/create()
	var/mob/living/carbon/human/mob = ..()
	// BABY!
	new /obj/item/organ/body_egg/alien_embryo(mob)
	return mob

/obj/effect/mob_spawn/human/decayed_patient
	name = "Decayed Patient"
	death = TRUE // the default, but all these others are alive
	roundstart = FALSE
	instant = FALSE
	// We found them on the mining asteroid, that's how old they are.
	outfit = /datum/outfit/job/miner/equipped/hardsuit

/obj/effect/mob_spawn/human/decayed_patient/create()
	var/mob/living/carbon/human/mob = ..()
	for(var/obj/item/organ/organ as anything in mob.internal_organs)
		organ.applyOrganDamage(INFINITY)
	return mob

/obj/effect/mob_spawn/human/bone_hurting_juice_patient
	name = "Bone Hurting Juice Patient"
	death = FALSE
	roundstart = FALSE
	instant = FALSE
	outfit = /datum/outfit/wizardcorpse // no spellbook, that would be silly

/obj/effect/mob_spawn/human/bone_hurting_juice_patient/create()
	var/mob/living/carbon/human/mob = ..()

	// 40 bone hurting juice is below OD threshold, we just want them
	// to "oof" constantly.
	mob.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, 40)

	for(var/obj/item/bodypart/bodypart as anything in mob.bodyparts)
		var/datum/wound/blunt/critical/wound = new
		wound.apply_wound(bodypart)

	return mob
