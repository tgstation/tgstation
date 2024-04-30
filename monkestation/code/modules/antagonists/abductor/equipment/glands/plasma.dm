/obj/item/organ/internal/heart/gland/plasma/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	var/obj/item/organ/internal/lungs/lungs = organ_owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(istype(lungs) && !QDELING(lungs))
		lungs.safe_plasma_max = 0

/obj/item/organ/internal/heart/gland/plasma/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	var/obj/item/organ/internal/lungs/lungs = organ_owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(istype(lungs) && !QDELING(lungs))
		lungs.safe_plasma_max = initial(lungs.safe_plasma_max)

/obj/item/organ/internal/heart/gland/plasma/activate()
	owner.balloon_alert(owner, "you feel bloated")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), owner, span_userdanger("A massive stomachache overcomes you.")), 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(vomit_plasma)), 20 SECONDS)

/obj/item/organ/internal/heart/gland/plasma/vomit_plasma()
	if(QDELETED(owner))
		return
	owner.balloon_alert_to_viewers("vomits a cloud of plasma!")
	var/turf/open/owner_turf = get_turf(owner)
	if(istype(owner_turf) && !QDELING(owner_turf))
		owner_turf.atmos_spawn_air("plasma=50;TEMP=[T20C]")
	owner.vomit(vomit_type = VOMIT_PURPLE, harm = FALSE)
