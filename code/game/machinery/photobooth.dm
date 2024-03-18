/obj/machinery/photobooth
	name = "photobooth"
	desc = "A machine with some drapes and a camera, used to update security record photos. Requires proper clearance to use."
	icon = 'icons/obj/machines/pda.dmi'
	icon_state = "pdapainter"
	base_icon_state = "pdapainter"
	density = TRUE
	can_buckle = TRUE
	buckle_prevents_pull = TRUE
	req_one_access = list(ACCESS_SECURITY, ACCESS_HOP)

/obj/machinery/photobooth/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	var/mob/living/person_inside = locate() in buckled_mobs
	if(!person_inside)
		return SECONDARY_ATTACK_CALL_NORMAL
	GLOB.manifest.change_pictures(person_inside.name, person_inside)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
