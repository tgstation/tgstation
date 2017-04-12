//prop hunt

/datum/sutando_abilities/shapeshift
	id = "shapeshift"
	name = "Chameleon Skin"
	value = 4
	var/obj/item/remembered = null
	var/obj/item/host = null

/datum/sutando_abilities/shapeshift/recall_act()
	QDEL_NULL(host)

/datum/sutando_abilities/shapeshift/handle_stats()
	. = ..()
	stand.has_mode = TRUE
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/shapeshift/alt_ability_act(obj/item/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		to_chat(stand,"<span class='danger'><B>You must be manifested to remember an item!</span></B>")
		return
	remembered = A.type
	to_chat(stand,"<span class='danger'><B>You remember \the [remembered.name]!</span></B>")

/datum/sutando_abilities/shapeshift/handle_mode()
	if(!toggle)
		if(remembered)
			host = new remembered(get_turf(stand))
			stand.forceMove(host)
			stand.visible_message("<span class='danger'>[stand] twists into the shape of [host.name]!</span>")
			playsound(stand.loc, 'sound/weapons/draw_bow.ogg', 50, 1, 1)
			remembered = null
		else
			to_chat(stand,"<span class='danger'><B>You don't have a remembered item!</span></B>")
			return
		toggle = TRUE
	else
		stand.forceMove(get_turf(stand))
		QDEL_NULL(host)
		to_chat(stand,"<span class='danger'><B>You twist back into your original form.</span></B>")
		toggle = FALSE

