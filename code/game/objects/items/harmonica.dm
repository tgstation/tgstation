/obj/item/device/harmonica
	name = "harmonica"
	desc = "Much blues. so amaze. wow."
	icon = 'icons/obj/musician.dmi'
	icon_state = "harmonica"
	item_state = "harmonica"
	force = 5
	m_amt = 500
	var/harmonica_channel
	var/spam_flag = 0
	var/cooldown = 70

/obj/item/device/harmonica/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || M != user)
		return ..()

	if(user.zone_sel.selecting == "mouth")
		play(user)


/obj/item/device/harmonica/New()
	harmonica_channel = rand(1000, 1024)

/obj/item/device/harmonica/proc/play(mob/living/carbon/user as mob)
	if(spam_flag) return

	spam_flag = 1

	var/melody = file("sound/harmonica/fharp[rand(1,8)].ogg")

	var/turf/source = get_turf(src)
	for(var/mob/M in hearers(15, source))
		M.playsound_local(source, melody, 50, 1, falloff = 5,/* channel = harmonica_channel*/)
		M << pick("[user] plays a bluesy tune with his harmonica!", "[user] plays a warm tune with his harmonica!", \
		"[user] plays a delightful tune with his harmonica!", "[user] plays a chilling tune with his harmonica!", "[user] plays a upbeat tune with his harmonica!")//Thanks Goonstation.

	spawn(cooldown)
		spam_flag = 0

	return

/obj/item/device/harmonica/dropped(mob/user)

	var/sound/melody = sound()
	melody.channel = harmonica_channel
	hearers(20, get_turf(src)) << melody

	spam_flag = 0

	return ..()