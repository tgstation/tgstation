/datum/martial_art/dropkick
	name = "Dropkicking"
	id = MARTIALART_DROPKICK
	var/obj/effect/proc_holder/spell/aimed/dropkick/dropkick
	var/dropkicking = FALSE

/datum/martial_art/dropkick/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class = 'danger'>You have lost the ability to fight normally, but have gained the powers of DROPKICK! Mouse over the button to see how it works.</span>")
		var/obj/effect/proc_holder/spell/aimed/dropkick/DK = new
		H.AddSpell(DK)
		dropkick = DK

/datum/martial_art/dropkick/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of [name]...</span>")
	if(dropkick)
		H.RemoveSpell(dropkick)


/obj/effect/proc_holder/spell/aimed/dropkick//bet the coders of the past never thought their aimed spells would be used like THIS
	name = "Dropkick"
	desc = "Extremely lethal if it hits, but it disables you for a moment and hitting objects can hurt a lot."
	charge_max = 0
	clothes_req = FALSE
	cooldown_min = 0
	active_icon_state = "lightning"
	base_icon_state = "lightning"
	active = FALSE
	active_msg = "You get ready to dropkick!"
	deactive_msg = "You decide not to dropkick."

/obj/effect/proc_holder/spell/aimed/dropkick/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T) || !(user.mobility_flags & MOBILITY_STAND))
		return FALSE
	user.set_resting(TRUE, TRUE)
	user.throw_at(target,4,5, spin = FALSE)
	return TRUE

/obj/item/clothing/shoes/dropkicking
	name = "dropkicking boots"
	desc = "Metal boots meant for dropping and kicking!"
	icon_state = "dropkickboots"
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF
	var/datum/martial_art/dropkick/style = new

/obj/item/clothing/shoes/dropkicking/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_SHOES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/shoes/dropkicking/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_SHOES) == src)
		style.remove(H)