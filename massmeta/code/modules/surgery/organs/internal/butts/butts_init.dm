//Initialize all butts spawn proc(if it can be) here.

//clown butt
/datum/job/clown/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/obj/item/organ/internal/butt/butt = spawned.get_organ_slot(ORGAN_SLOT_BUTT)
	if(butt)
		butt.Remove(spawned, 1)
		QDEL_NULL(butt)
		butt = new/obj/item/organ/internal/butt/clown
		butt.Insert(spawned)

//heal butt
/mob/living/carbon/regenerate_organs(regenerate_existing = FALSE)
	. = ..()
	var/obj/item/organ/internal/butt/butt = get_organ_slot(ORGAN_SLOT_BUTT)
	if(!butt)
		butt = new()
		butt.Insert(src)
		butt.set_organ_damage(0)

//Butt quirks
/datum/quirk/stable_ass
	name = "Stable Rear"
	desc = "Your rear is far more robust than average, falling off less often than usual."
	value = 2
	icon = FA_ICON_FACE_SAD_CRY
	medical_record_text = "Subject have strong ass."
	//All effects are handled directly in butts.dm

/datum/quirk/loud_ass
	name = "Loud Ass"
	desc = "For some ungodly reason, your ass is twice as loud as normal."
	value = 2
	icon = FA_ICON_VOLUME_HIGH
	medical_record_text = "Subject ass is very loud."
	//All effects are handled directly in butts.dm

/datum/quirk/unstable_ass
	name = "Unstable Rear"
	desc = "For reasons unknown, your posterior is unstable and will fall off more often."
	value = -1
	icon = FA_ICON_BOMB
	medical_record_text = "Subject have weak ass."
	//All effects are handled directly in butts.dm
