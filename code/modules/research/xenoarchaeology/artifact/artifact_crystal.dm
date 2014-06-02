
/obj/structure/crystal
	name = "large crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "crystal"
	density = 1

/obj/structure/crystal/New()
	..()

	icon_state = pick("ano70","ano80")

	desc = pick(\
	"It shines faintly as it catches the light.",\
	"It appears to have a faint inner glow.",\
	"It seems to draw you inward as you look it at.",\
	"Something twinkles faintly as you look at it.",\
	"It's mesmerizing to behold.")

/obj/structure/crystal/Destroy()
	src.visible_message("\red<b>[src] shatters!</b>")
	if(prob(75))
		getFromPool(/obj/item/weapon/shard/plasma, loc)
	if(prob(50))
		getFromPool(/obj/item/weapon/shard/plasma, loc)
	if(prob(25))
		getFromPool(/obj/item/weapon/shard/plasma, loc)
	if(prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
	if(prob(50))
		getFromPool(/obj/item/weapon/shard, loc)
	if(prob(25))
		getFromPool(/obj/item/weapon/shard, loc)
	..()

//todo: laser_act
