/datum/martial_art/dropkick
	name = "Dropkicking"
	id = MARTIALART_DROPKICK
	var/datum/action/dropkick/dropkick = new/datum/action/dropkick()

/datum/martial_art/dropkick/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class = 'danger'>You have lost the ability to fight normally, but have gained the powers of DROPKICK! Mouse over the button to see how it works.</span>")
		dropkick.Grant(H)

/datum/action/dropkick
	name = "Dropkick - Extremely lethal if it hits, but it disables you for a moment and hitting objects can hurt a lot."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	//button_icon_state =

/obj/item/clothing/shoes/dropkicking
	name = "dropkicking boots"
	desc = "Metal boots meant for kicking the shit out of your foes!"
	icon_state = "dropkickboots"
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF

/obj/item/clothing/gloves/dropkicking/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_SHOES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/dropkicking/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_SHOES) == src)
		style.remove(H)