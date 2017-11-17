//Invisible when armed. Non-servants walking over this will get spikes through the feet, immobilizing them until they're freed.
/obj/structure/destructible/clockwork/trap/brass_skewer
	name = "brass skewer"
	desc = "A massive brass spike, cleverly concealed in the floor. You think you could prevent setting it off if you moved slowly."
	clockwork_desc = "A barbaric but undeniably effective weapon: a spear through the chest. It immobilizes anyone unlucky enough to step on it and keeps them in place until they get help.."
	icon_state = "brass_skewer"
	break_message = "<span class='warning'>The skewer snaps in two!</span>"
	max_integrity = 40
	density = FALSE
	can_buckle = TRUE
	buckle_prevents_pull = TRUE
	buckle_lying = FALSE

/obj/structure/destructible/clockwork/trap/brass_skewer/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/clockwork/trap/brass_skewer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(buckled_mobs && buckled_mobs.len)
		var/mob/living/L = buckled_mobs[1]
		L.Knockdown(100)
		L.visible_message("<span class='warning'>[L] convulses in pain as the skewer shatters while still in their body!</span>")
		L.adjustBruteLoss(15)
	return ..()

/obj/structure/destructible/clockwork/trap/brass_skewer/process()
	if(density)
		if(buckled_mobs.len)
			var/mob/living/spitroast = buckled_mobs[1]
			spitroast.Knockdown(10)
			spitroast.adjustBruteLoss(0.1)

/obj/structure/destructible/clockwork/trap/brass_skewer/activate()
	if(density)
		return
	var/mob/living/carbon/squirrel = locate() in get_turf(src)
	if(squirrel)
		squirrel.visible_message("<span class='boldwarning'>A massive brass spike erupts from the ground, impaling [squirrel] through the legs!</span>", \
		"<span class='userdanger'>A massive brass spike rams through your legs, hoisting you into the air!</span>")
		squirrel.emote("scream")
		playsound(squirrel, 'sound/effects/splat.ogg', 50, TRUE)
		playsound(squirrel, 'sound/misc/desceration-03.ogg', 50, TRUE)
		squirrel.apply_damage(10, BRUTE, "l_leg")
		squirrel.apply_damage(10, BRUTE, "r_leg")
		squirrel.pixel_y = -5
		var/matrix/M = matrix()
		M.Turn(180)
		squirrel.transform = M
		buckle_mob(squirrel, TRUE)
	else
		visible_message("<span class='danger'>A massive brass spike erupts from the ground!</span>")
	playsound(src, 'sound/machines/clockcult/brass_skewer.ogg', 75, FALSE)
	icon_state = "[initial(icon_state)]_extended"
	density = TRUE //Skewers are one-use only
	desc = "A massive brass spike protruding from the ground like a snapped bone. It makes you sick to look at."

/obj/structure/destructible/clockwork/trap/brass_skewer/user_buckle_mob()
	return

/obj/structure/destructible/clockwork/trap/brass_skewer/user_unbuckle_mob(mob/living/skewee, mob/living/user)
	if(user == skewee)
		to_chat(user, "<span class='boldwarning'>You can't free yourself from [src]! You need some help...</span>")
		return
	user.visible_message("<span class='danger'>You start tenderly lifting [user] off of [src]...</span>", \
	"<span class='danger'>You start tenderly lifting [user] off of [src]...</span>")
	if(!do_after(user, 60, target = skewee))
		skewee.visible_message("<span class='warning'>[skewee] painfully slides back down [src].</span>")
		skewee.emote("moan")
		return
	skewee.visible_message("<span class='danger'>[skewee] comes free of [src] with a squelching pop!</span>", \
	"<span class='boldannounce'>You come free of [src]!</span>")
	skewee.Knockdown(30)
	playsound(skewee, 'sound/misc/desceration-03.ogg', 50, TRUE)
	unbuckle_mob(skewee)
