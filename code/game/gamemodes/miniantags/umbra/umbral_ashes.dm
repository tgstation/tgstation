#define UMBRA_ASHES_REFORM_TIME 600 //In deciseconds, how long ashes take to reform

/obj/item/umbral_ashes
	name = "umbral ashes"
	desc = "A shimmering pile of blue ashes with a glowing purple core."
	icon = 'icons/obj/magic.dmi'
	icon_state = "umbral_ashes"
	w_class = 2
	gender = PLURAL
	origin_tech = "materials=6;bluespace=4;biotech=6" //Good origin tech if you think you have enough time to get them to research
	var/umbra_key //The key of the umbra that these ashes came from
	var/umbra_vitae //The vitae of the umbra that these ashes came from

/obj/item/umbral_ashes/New()
	..()
	addtimer(src, "reform", UMBRA_ASHES_REFORM_TIME)

/obj/item/umbral_ashes/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] scatters [src]!</span>", "<span class='notice'>You scatter [src], which tremble and fade away.</span>")
	user.drop_item()
	qdel(src)
	return 1

/obj/item/umbral_ashes/proc/reform()
	if(!src)
		return
	visible_message("<span class='warning'>[src] hover into the air and reform!</span>")
	flick("umbral_ashes_reforming", src)
	animate(src, alpha = 0, time = 12)
	sleep(12)
	var/mob/living/simple_animal/umbra/U = new(get_turf(src))
	U.key = umbra_key
	if(!U.client)
		U.key = null
		var/image/I = image('icons/mob/mob.dmi', "umbra")
		notify_ghosts("An umbra has reformed in [get_area(U)]. Interact with it to take control of it.", 'sound/effects/ghost2.ogg', alert_overlay = I, source = U, action = NOTIFY_ATTACK)
	else
		U << "<span class='umbra_emphasis'>Back... you're back. You can't remember what you were supposed to be doing here. Now... where were we?</span>"
	if(umbra_vitae)
		U.vitae = umbra_vitae
	U.alpha = 0
	animate(U, alpha = initial(U.alpha), time = 10) //To give a fade-in effect for the newly-spawned
	qdel(src)
	return 1
