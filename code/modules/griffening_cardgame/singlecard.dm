/obj/item/griffening_single
	name = "A single Griffening Card"
	desc = "If you see this, tell ma44."
	var/card_type
	var/rarity = COMMON
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand1"
	w_class = WEIGHT_CLASS_TINY
	var/LVL = 0
	var/ATK = 0
	var/DEF = 0
	var/facedown = FALSE //Used for non hologram games of setting a card
	var/lastflipper = null //What's the last ckey of the person that flipped this? examining snowflake
	pixel_x = -5
	var/lastname = null //Hides stuff when its facedown
	var/lastdesc
	var/lastLVL
	var/lastATK
	var/lastDEF

/obj/item/griffening_single/Initialize()
	. = ..()

/obj/item/griffening_single/attack_hand(mob/user)
	user.visible_message("<span class='notice'>[user.name] picks up a card named [src.name].</span>")
	user.put_in_hands(src)
	..()

/obj/item/griffening_single/examine(mob/user)
	if(facedown && lastflipper == user.ckey)
		to_chat(user, "[lastATK] ATK| [lastDEF] DEF| [lastLVL] LVL| [lastdesc]") //The current vars are hidden and null, so it shows you the true ones
	else
		if(facedown && !lastflipper == user.ckey)
			to_chat(user, "A facedown card that doesn't belong to you.")
		else
			to_chat(user, "[ATK] ATK| [DEF] DEF| [LVL] LVL| [desc]")
	
/obj/item/griffening_single/interact(mob/user)
	if(facedown)
		to_chat(user, "You flip this card up, showing anyone what it is.")
		icon_state = "nanotrasen_hand1"
		facedown = FALSE
		lastflipper = null
		name = lastname
		desc = lastdesc
		LVL = lastLVL
		ATK = lastATK
		DEF = lastDEF
	else
		to_chat(user, "You flip this card down, now only you can see what it is.")
		icon_state = "singlecard_down_nanotrasen"
		facedown = TRUE
		lastflipper = user.ckey
		lastname = name
		lastdesc = desc
		lastLVL = LVL
		lastATK = ATK
		lastDEF = DEF
		name = "Facedown card"
		desc = "A facedown card, your not sure what it is."
		LVL = "?"
		ATK = "?"
		DEF = "?"
