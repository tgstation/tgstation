/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/item/key/security/suicide_act(mob/living/carbon/user)
	if(!user.emote("spin")) //In the off chance that someone attempts this suicide while under the effects of mime's bane they deserve the silliness.
		user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] ear and starts [user.p_their()] motor! It looks like [user.p_theyre()] trying to commit suicide... But [user.p_they()] sputters and stalls out! </span>")
		playsound(src, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
		return SHAME
	user.visible_message("<span class='suicide'>[user] is putting \the [src] in [user.p_their()] ear and starts [user.p_their()] motor! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.say("Vroom vroom!!", forced="secway key suicide") //Not doing a shamestate here, because even if they fail to speak they're spinning.
	addtimer(CALLBACK(user, /mob/living/.proc/gib), 20)
	return MANUAL_SUICIDE

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/key/lasso
	name = "bone lasso"
	desc = "Perfect for taming all kinds of supernatural beasts! (Warning: only perfect for taming one kind of supernatural beast.)"
	force = 12
	icon_state = "lasso"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/whip.ogg'
	slot_flags = ITEM_SLOT_BELT
