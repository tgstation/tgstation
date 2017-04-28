//Pool noodles

/obj/item/toy/poolnoodle
	icon = 'hippiestation/icons/obj/toy.dmi'
	icon_state = "noodle"
	name = "Pool noodle"
	desc = "A strange, bulky, bendable toy that can annoy people."
	force = 0
	color = "#000000"
	w_class = 2.0
	throwforce = 1
	throw_speed = 10 //weeee
	hitsound = 'sound/weapons/tap.ogg'
	attack_verb = list("flogged", "poked", "jabbed", "slapped", "annoyed")

/obj/item/toy/poolnoodle/attack(target as mob, mob/living/user as mob)
	..()
	if(prob(80))
		user.emote("spin")
	if(prob(5))
		user.emote("spin")

/obj/item/toy/poolnoodle/red

/obj/item/toy/poolnoodle/blue

/obj/item/toy/poolnoodle/yellow

/obj/item/toy/poolnoodle/red/Initialize()
	..()
	color = "#ff4c4c"

/obj/item/toy/poolnoodle/blue/Initialize()
	..()
	color = "#3232ff"

/obj/item/toy/poolnoodle/yellow/Initialize()
	..()
	color = "#ffff66"