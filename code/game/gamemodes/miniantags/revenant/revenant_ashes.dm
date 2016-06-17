#define UMBRA_ASHES_REFORM_TIME 600 //In deciseconds, how long ashes take to reform

/obj/item/revenantl_ashes
	name = "revenantl ashes"
	desc = "A shimmering pile of blue ashes with a glowing purple core."
	icon = 'icons/obj/magic.dmi'
	icon_state = "revenantl_ashes"
	w_class = 2
	gender = PLURAL
	origin_tech = "materials=6;bluespace=4;biotech=6" //Good origin tech if you think you have enough time to get them to research
	var/revenant_key //The key of the revenant that these ashes came from
	var/revenant_vitae //The vitae of the revenant that these ashes came from

/obj/item/revenantl_ashes/New()
	..()
	addtimer(src, "reform", UMBRA_ASHES_REFORM_TIME)

/obj/item/revenantl_ashes/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] scatters [src]!</span>", "<span class='notice'>You scatter [src], which tremble and fade away.</span>")
	user.drop_item()
	qdel(src)
	return 1

/obj/item/revenantl_ashes/proc/reform()
	if(!src)
		return
	visible_message("<span class='warning'>[src] hover into the air and reform!</span>")
	flick("revenantl_ashes_reforming", src)
	animate(src, alpha = 0, time = 12)
	sleep(12)
	var/mob/living/simple_animal/revenant/U = new(get_turf(src))
	U.key = revenant_key
	if(!U.client)
		U.key = null
		var/image/alert_overlay = image('icons/mob/mob.dmi', "revenant")
		notify_ghosts("An revenant has re-formed in [get_area(U)]. Interact with it to take control of it.", null, source = U, alert_overlay = alert_overlay)
	else
		U << "<span class='revenant_emphasis'>Back... you're back. You can't remember what you were supposed to be doing here. Now... where were we?</span>"
	if(revenant_vitae)
		U.vitae = revenant_vitae
	U.alpha = 0
	animate(U, alpha = initial(U.alpha), time = 10) //To give a fade-in effect for the newly-spawned
	qdel(src)
	return 1
