/datum/martial_art/psychotic_brawl
	name = "Psychotic Brawl"
	deflection_chance = 0
	no_guns = FALSE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/psychotic_brawl_help

/datum/martial_art/psychotic_brawl/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(prob (50))
		D.visible_message("<span class='danger'>[A] flails their arms trying to grab [D]!</span>", \
			"<span class='userdanger'>[A] flails their arms trying to grab you!</span>")
		return 1
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.drop_all_held_items()
			D.stop_pulling()
			add_logs(A, D, "grabbed", addition="aggressively")
			D.visible_message("<span class='danger'>[A] grabs [D] violently!</span>", \
				  "<span class='userdanger'>[A] grabs you violently!</span>")
			A.grab_state = GRAB_AGGRESSIVE //Instant aggressive grab
			return 1

/datum/martial_art/psychotic_brawl/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verbmiss = pick("flails", "spasms", "dances", "convulses", "claps")
	var/atk_verbstrong = pick("slams", "immolates", "crushes", "cracks", "pounds")
	var/atk_verbholyfuck = pick("grabs your chest and rips it open!", "slams the palm of their fist into your head, sending your brain flying!", "chops your arm clean off!", "chops your leg clean off!")
	switch(rand(1,10))
		if(1 to 5) //miss!
			D.visible_message("<span class='danger'>[A] [atk_verbmiss] at [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verbmiss] at you!</span>")
			playsound(get_turf(D), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			add_logs(A, D, "(Psychotic Brawl MISS)[atk_verbmiss] at")
			return 1
		if(6 to 9) //hit)
			D.visible_message("<span class='danger'>[A] [atk_verbstrong] [D]!</span>", \
				  "<span class='userdanger'>[A] [atk_verbstrong] you!</span>")
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
			add_logs(A, D, "(Psychotic Brawl HIT)[atk_verbstrong]")
			return 1
		if(10)
			D.visible_message("<span class='danger'>[A] destroys [D]!</span>", \
				  "<span class='userdanger'>[A] grabs your chest and rips it open!</span>")
			playsound(get_turf(D), 'sound/effects/explosion3.ogg', 25, 1, -1)
			add_logs(A, D, "(Psychotic Brawl CRIT)[atk_verbholyfuck]")
			D.gib()
			return 1

/obj/item/breakscroll
	name = "mysterious scroll"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/breakscroll/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/message = "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
	directed toward you. However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>"
	to_chat(user, message)
	var/datum/martial_art/psychotic_brawl/theSleeping = new(null)
	theSleeping.teach(user)
	qdel(src)
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(user.drop_location())

/mob/living/carbon/human/proc/psychotic_brawl_help()
	set name = "Wrack Brain"
	set desc = "Why can't I PUNCH CORRECTLY ANYMORE"
	set category = "Psychotic Break"

	to_chat(usr, "<b><i>You try to remember how to fight...</i></b>")

	to_chat(usr, "Every time you even <b>think</b> of fighting, your fists lose control as if they have a mind of their own.")
	to_chat(usr, "<span class='notice'>Sometimes, they just flail around like dumb noodles, and you look like a big idiot.")
	to_chat(usr, "<span class='notice'>And others, they will land a crushing blow, toppling your foe completely. You can't explain it!")