//prop hunt

/datum/guardian_abilities/shapeshift
	id = "shapeshift"
	name = "Chameleon Skin"
	value = 4
	var/obj/item/remembered = null
	var/obj/item/host = null

/datum/guardian_abilities/shapeshift/recall_act()
	..()
	QDEL_NULL(host)

/datum/guardian_abilities/shapeshift/handle_stats()
	. = ..()
	guardian.has_mode = TRUE
	guardian.range += 3
	guardian.melee_damage_lower += 3
	guardian.melee_damage_upper += 3

/datum/guardian_abilities/shapeshift/alt_ability_act(obj/item/A)
	if(!istype(A))
		return
	if(guardian.loc == user)
		to_chat(guardian,"<span class='danger'><B>You must be manifested to remember an item!</span></B>")
		return
	remembered = A.type
	to_chat(guardian,"<span class='danger'><B>You remember \the [remembered.name]!</span></B>")

/datum/guardian_abilities/shapeshift/handle_mode()
	if(!toggle)
		if(remembered)
			host = new remembered(get_turf(guardian))
			guardian.forceMove(host)
			guardian.visible_message("<span class='danger'>[guardian] twists into the shape of [host.name]!</span>")
			playsound(guardian.loc, 'sound/weapons/draw_bow.ogg', 50, 1, 1)
			remembered = null
		else
			to_chat(guardian,"<span class='danger'><B>You don't have a remembered item!</span></B>")
			return
		toggle = TRUE
	else
		guardian.forceMove(get_turf(guardian))
		QDEL_NULL(host)
		to_chat(guardian,"<span class='danger'><B>You twist back into your original form.</span></B>")
		toggle = FALSE

