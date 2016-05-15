/**
 * Screamer
 *
 * Used for debugging saycode since Poly NEVER FUCKING TALKS WHEN YOU WANT HIM TO.
 *
 * @author N3X15
 */
/obj/item/debug/screamer
	name = "screaming candle"
	desc = "It's a candle.  A candle that screams."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = W_CLASS_TINY

	var/on=1
	var/lang_id=LANGUAGE_GALACTIC_COMMON
	var/list/things_to_say=list("FUCK","SHIT","PISS","BALLS","DICK","CUNT","ASS","PISS")

/obj/item/debug/screamer/New(var/_loc)
	..(_loc)
	update_icon()

/obj/item/debug/screamer/update_icon()
	if(on)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)
	icon_state = "candle1[on ? "_lit" : ""]"


/obj/item/debug/screamer/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(!on && W.is_hot())
		visible_message("<span class='notice'>[user] lights [src] with [W].</span>")
		say("[user] TURNS ME ON WITH THEIR [W]")
		on=1
		update_icon()


/obj/item/debug/screamer/say(var/message)
	..(message, speaking=all_languages[lang_id])

/obj/item/debug/screamer/process()
	if(!on)
		return
	say(pick(things_to_say))

/obj/item/debug/screamer/attack_hand(var/mob/user)
	if(on)
		visible_message("<span class='notice'>[user] extinguishes [src].</span>")
		on=0
		update_icon()
		say("[user] TURNS ME OFF")
