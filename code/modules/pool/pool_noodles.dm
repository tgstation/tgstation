//Pool noodles

/obj/item/toy/poolnoodle
	icon = 'icons/obj/toy.dmi'
	icon_state = "noodle"
	name = "pool noodle"
	desc = "A strange, bulky, bendable toy that can annoy people."
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1
	throw_speed = 10 //weeee
	hitsound = 'sound/weapons/tap.ogg'
	attack_verb_simple = list("flogged", "poked", "jabbed", "slapped", "annoyed")
	attack_verb_continuous = list("flogs", "pokes", "jabs", "slaps", "annoys")
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

/obj/item/toy/poolnoodle/attack(target as mob, mob/living/user as mob)
	..()
	if(prob(80))
		user.emote("spin")
	if(prob(5))
		user.emote("spin")

/obj/item/toy/poolnoodle/red
	inhand_icon_state = "noodlered"
	color = "#ff4c4c"

/obj/item/toy/poolnoodle/blue
	inhand_icon_state = "noodleblue"
	color = "#3232ff"

/obj/item/toy/poolnoodle/yellow
	inhand_icon_state = "noodleyellow"
	color = "#ffff66"
