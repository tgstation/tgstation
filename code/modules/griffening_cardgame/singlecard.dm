/obj/item/griffening_single
	name = "A single Griffening Card"
	desc = "If you see this, tell ma44."
	var/card_type
	var/rarity = COMMON
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_up"
	w_class = WEIGHT_CLASS_TINY
	var/LVL = 0
	var/ATK = 0
	var/DEF = 0
	var/facedown = FALSE //Used for non hologram games of setting a card
	var/lastflipper = null //What's the last ckey of the person that flipped this? examining snowflake
	pixel_x = -5
	var/lastname = null //Hides stuff when its facedown
	var/lastdescription
	var/lastLVL
	var/lastATK
	var/lastDEF

/obj/item/griffening_single/examine(mob/user)
	if(facedown && lastflipper == user.ckey)
		to_chat(user, "[ATK] ATK| [DEF] DEF| [LVL] LVL| [desc]")
	else
		to_chat(user, "A facedown card.")

/obj/item/griffening_single/attack_hand(mob/user)
	user.put_in_hands(src)

/obj/item/griffening_single/interact(mob/user)
	if(facedown)
		to_chat(user, "You flip this card up, showing anyone what it is.")
		facedown = FALSE
		lastflipper = null
		name = lastname
		desc = lastdescription
		LVL = lastLVL
		ATK = lastATK
		DEF = lastDEF
	else
		to_chat(user, "You flip this card down, now only you can see what it is.")
		facedown = TRUE
		lastflipper = user.ckey
		lastname = name
		lastdescription = desc
		lastLVL = LVL
		lastATK = ATK
		lastDEF = DEF
		name = "Facedown card"
		desc = "A facedown card, your not sure what it is."
		LVL = "?"
		ATK = "?"
		DEF = "?"
