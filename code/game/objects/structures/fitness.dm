/obj/structure/punching_bag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/obj/fitness.dmi'
	icon_state = "punchingbag"
	anchored = 1
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/obj/structure/punching_bag/attack_hand(mob/user as mob)
	flick("[icon_state]2", src)
	playsound(loc, pick(hit_sounds), 25, 1, -1)

/obj/structure/punching_bag/wizard
	icon_state = "punchingbagwizard"
	desc = "It has a picture of a weird wizard on it."

/obj/structure/punching_bag/syndie
	icon_state = "punchingbagsyndie"
	desc = "It has a picture of a mean ol' syndicate on it."

/obj/structure/punching_bag/captain
	icon_state = "punchingbagcaptain"
	desc = "It has a picture of a dumb looking station captain on it."

/obj/structure/punching_bag/clown
	name = "clown bop bag"
	desc = "A bop bag in the shape of a goofy clown."
	icon_state = "bopbag"

/obj/structure/punching_bag/clown/attack_hand(mob/user as mob)
	..()
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)

/obj/structure/stacklifter
	name = "weight machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = 1
	anchored = 1

/obj/structure/stacklifter/attack_hand(mob/user as mob)
	if(in_use)
		to_chat(user, "<span class='notice'>It's already in use - wait a bit.</span>")
		return
	else
		in_use = 1
		icon_state = "fitnesslifter2"
		user.change_dir(SOUTH)
		user.Stun(4)
		user.forceMove(loc)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		for(var/lifts = 1 to 6)
			if (user.loc != loc)
				break
			sleep(3)
			animate(user, pixel_y = pixel_y - 2, time = 3)
			sleep(3)
			animate(user, pixel_y = pixel_y - 4, time = 3)
			sleep(3)
			playsound(user, 'sound/effects/spring.ogg', 60, 1)

		playsound(user, 'sound/machines/click.ogg', 60, 1)
		in_use = 0
		animate(user, pixel_y = pixel_y, time = 3)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnesslifter"
		to_chat(user, "<span class='notice'>[finishmessage]</span>")

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnessweight"
	density = 1
	anchored = 1

/obj/structure/weightlifter/attack_hand(mob/user as mob)
	if(in_use)
		to_chat(user, "<span class='notice'>It's already in use - wait a bit.</span>")
		return
	else
		in_use = 1
		icon_state = "fitnessweight-c"
		user.change_dir(SOUTH)
		user.Stun(4)
		user.forceMove(loc)
		var/image/W = image('icons/obj/fitness.dmi',"fitnessweight-w")
		W.layer = MOB_LAYER + 0.1
		overlays += W
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		user.pixel_y = 5
		for(var/reps = 1 to 6)
			if (user.loc != loc)
				break

			for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
				sleep(3)
				animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

			playsound(user, 'sound/effects/spring.ogg', 60, 1)

		sleep(3)
		animate(user, pixel_y = pixel_y + 2, time = 3)
		sleep(3)
		playsound(user, 'sound/machines/click.ogg', 60, 1)
		in_use = 0
		animate(user, pixel_y = pixel_y, time = 3)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnessweight"
		overlays -= W
		to_chat(user, "<span class='notice'>[finishmessage]</span>")