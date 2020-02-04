/datum/martial_art/north_star
	name = "The North Star"
	id = MARTIALART_NORTHSTAR
	streak = "AT"
	var/datum/action/set_war_cry/setwarcry = new/datum/action/set_war_cry()

/datum/martial_art/north_star/teach(mob/living/carbon/human/H, make_temporary=FALSE)
	if(..())
		to_chat(H, "<span class='userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class='danger'>You will now be able to punch and kick at ludicrous speeds!</span>")
		setwarcry.Grant(H)

/datum/martial_art/north_star/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class='userdanger'>You suddenly forget the arts of [name]...</span>")
	setwarcry.Remove(H)

/datum/martial_art/north_star/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.changeNext_move(CLICK_CD_RAPID)
	if(streak)
		A.say(streak, ignore_spam = TRUE, forced = "north star warcry")
	log_combat(A, D, "attacked (north star)")
	// species/proc/harm() should handle everything else

/datum/action/set_war_cry
	name = "War Cry - Change what you say aloud when you attack unarmed."
	icon_icon = 'icons/obj/clothing/gloves.dmi'
	button_icon_state = "rapid"

/datum/action/set_war_cry/Trigger()
	var/mob/living/carbon/human/H = owner
	var/input = stripped_input(H, "What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		H.mind.martial_art.streak = input // yes the streak holds the current warcry, i mean it's not doing anything else right?
		to_chat(H, "<span class='notice'>Your new warcry will be [input]</span>")

datum/martial_art/north_star/can_use(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_HULK))
		return FALSE
	return ..()

	// gloves

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	item_state = "rapid"
	transfer_prints = TRUE
	var/datum/martial_art/north_star/style = new

/obj/item/clothing/gloves/rapid/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H, TRUE)

/obj/item/clothing/gloves/rapid/dropped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)
