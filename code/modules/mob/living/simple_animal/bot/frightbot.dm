/obj/item/weapon/frightbot_chasis
	desc = "A chasis for a new frightbot."
	name = "frightbot chasis"
	icon = 'icons/obj/aibots_new.dmi'
	icon_state = "frightbot_chasis"
	force = 3.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0

/obj/item/weapon/frightbot_chasis/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/device/radio))
		user << "<span class='notice'>You complete the Frightbot! KEEEEEEEEEEE!!!</span>"
		user.drop_item()
		qdel(W)
		var/turf/T = get_turf(src)
		new/mob/living/simple_animal/bot/frightbot(T)
		user.unEquip(src, 1)
		qdel(src)

/mob/living/simple_animal/bot/frightbot
	name = "frightbot"
	desc = "You'll poop your pants from his scary stories!"
	icon = 'icons/obj/aibots_new.dmi'
	icon_state = "frightbot"
	// layer = 5.0
	density = 0
	anchored = 0
	health = 25
	var/cooldown = 0
	var/list/frights = list("told a pants-wettingly scary story", "told a story so scary you want to cover your ears",\
							"told a story so incredibly scary that your teeth won't stop chattering", "told a bloodcurdling story",\
							"told a scary story with some deeply touching moments mixed in", "started telling a spine-chilling story",\
							"is making horrible chalkboard-scratching sounds while trying to tell scary stories",\
							"told a story so scary you couldn't help but laugh", "accidentaly told a cute, funny story",\
							"told a story so scary you'll never go to bathroom at night again", "told a story so scary it made your eyes start to tear up")

/mob/living/simple_animal/bot/frightbot/explode()
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/T = get_turf(src)
	if(prob(50))
		new /obj/item/device/radio(T)

	var/datum/effect_system/spark_spread/s = new
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	..() //qdels us and removes us from processing objects

/mob/living/simple_animal/bot/frightbot/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		user << "<span class='warning'>The frightbot will now tell stories so spooky that people will be affected by them physically!</span>"

/mob/living/simple_animal/bot/frightbot/New()
	..()
	icon_state = "frightbot[on]"

/mob/living/simple_animal/bot/frightbot/turn_on()
	..()
	icon_state = "frightbot[on]"

/mob/living/simple_animal/bot/frightbot/turn_off()
	..()
	icon_state = "frightbot[on]"

/mob/living/simple_animal/bot/frightbot/handle_automated_action()
	if (!..())
		return

	if(cooldown < world.time && prob(20))
		cooldown = world.time + 200
		playsound(loc, 'sound/machines/fright.ogg', 50, 1)
		if(emagged && prob(70))
			cooldown = world.time + 300 //Longer cooldown
			var/list/effects = list("stutter", "puke", "scream", "fart", "flip", "mute", "panic")
			var/choice = pick(effects)
			switch(choice)
				if("stutter")
					visible_message("<span class='danger'><b>[src]</b> told such a terrifying story that you won't stop stuttering!</span>")
					for(var/mob/living/M in viewers(src))
						M.stuttering = 5
				if("puke")
					visible_message("<span class='danger'><b>[src]</b> told such a gruesome and disgusting story that you can't help but puke!</span>")
					for(var/mob/living/carbon/human/M in viewers(src))
						M.Stun(5)
						M.emote("vomit")
				if("scream")
					visible_message("<span class='danger'><b>[src]</b> told a startling story with a jumpscare at the end!</span>")
					for(var/mob/living/M in viewers(src))
						M.emote("scream")
				if("fart")
					visible_message("<span class='danger'><b>[src]</b> told such an odd story that you can't help but pass gas!</span>")
					for(var/mob/living/M in viewers(src))
						M.emote("fart")
				if("flip")
					visible_message("<span class='danger'><b>[src]</b> told a story so scary that you reflexibly flip!</span>")
					for(var/mob/living/M in viewers(src))
						M.emote("flip")
				if("mute")
					visible_message("<span class='danger'><b>[src]</b> told such an abstract and otherworldy story that you find yourself having no mouth!</span>")
					for(var/mob/living/carbon/M in viewers(src))
						M.silent += 3
				if("panic")
					visible_message("<span class='danger'><b>[src]</b> told you that you only have 1 hour left to live!</span>")
					for(var/mob/living/carbon/M in viewers(src))
						M.visible_message("<span class='danger'>[M] stumbles around in a panic.</span>", \
														"<span class='userdanger'>You have a panic attack!</span>")
						M.confused += rand(6,8)
						M.jitteriness += rand(6,8)
			flick("frightbot_fright", src)
			return
		flick("frightbot_speak", src)
		visible_message("<span class='danger'><b>[src]</b> [pick(frights)]!</span>")