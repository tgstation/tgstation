#define UMBRA_INVISIBILITY 50
#define UMBRA_VITAE_DRAIN_RATE 0.01 //How much vitae is drained per tick to sustain the umbra

/*

Umbras are spirits of the dead with enough anger or determination in their souls to not fully pass on. They exist somewhere between the realms of the living and the dead.

Unfortunately, this comes at a price: umbras require the vitae of souls to keep themselves alive. Their forms are difficult to maintain, and without vitae, they will fade away.
This vitae can be drained at will from any being's corpse, although humans typically net a richer pool to drink from - in particular, sapient humans are worth the most.
Some humans have a "perfect soul" - a new soul, not corrupted by lives' worth of being passed down. These humans yield huge amounts of vitae to the umbra lucky enough to find them.
Vitae is not only used as an umbra's health, but it's also used to fuel some of their unique abilities. These abilities can be used to influence the living realm in different ways.
As a final note, umbras require vitae to live. Although it drains very slowly, it does drain, and without vitae, the umbra will die.

Umbras are not without their weaknesses. Despite being invisible to the naked eye and completely incorporeal, certain things can restrict, weaken, or outright harm them.
Lines of salt on the ground will prevent an umbra's passage, making area encircled in it completely inaccessible to even the most determined umbra.
In addition, objects and artifacts of a holy nature can force an umbra to manifest or drain its vitae.

When an umbra dies, two things can occur. If the umbra died from passive vitae drain, it will be dead forever, with no way to bring it back.
However, if the umbra is slain forcibly and still has vitae, it leaves behind phantasmal ashes. These ashes will, after a minute or so, reform into another umbra and vanish.
If possible, the new umbra will be controlled by the same player as before. If not, another player will be chosen to control it.
Regardless of whether or not this is successful, the new umbra will have the same vitae as the old one.

*/

/mob/living/simple_animal/umbra
	name = "umbra"
	real_name = "umbra"
	desc = "A translucent cobalt-blue spirit floating several feet in the air."
	invisibility = UMBRA_INVISIBILITY
	icon = 'icons/mob/mob.dmi'
	icon_state = "umbra"
	icon_living = "umbra"
	health = 100
	maxHealth = 100
	healable = FALSE
	friendly = null
	speak_emote = list("murmurs")
	emote_hear = list("murmurs")
	incorporeal_move = TRUE
	stop_automated_movement = TRUE
	wander = FALSE
	see_in_dark = 8
	see_invisible = UMBRA_INVISIBILITY
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/vitae = 10 //The amount of vitae captured by the umbra
	var/vitae_cap = 100 //How much vitae a single umbra can hold
	var/breaking_apart = FALSE //If the umbra is currently dying

/mob/living/simple_animal/umbra/Life()
	..()
	adjust_vitae(-UMBRA_VITAE_DRAIN_RATE)
	if(!vitae)
		death()

/mob/living/simple_animal/umbra/death()
	if(breaking_apart)
		return
	..(1)
	breaking_apart = TRUE
	notransform = TRUE
	invisibility = FALSE
	visible_message("<span class='warning'>An [name] appears from nowhere and begins to disintegrate!</span>", \
	"<span class='userdanger'>You feel your will faltering, and your form begins to break apart!</span>")
	flick("umbra_disintegrate", src)
	sleep(12)
	if(vitae)
		visible_message("<span class='warning'>[src] breaks apart into a pile of ashes!</span>")
		var/obj/item/phantasmal_ashes/P = new(get_turf(src))
		P.umbra_key = key
		P.umbra_vitae = vitae
	else
		visible_message("<span class='warning'>[src] breaks apart and fades away!</span>")
	qdel(src)

/mob/living/simple_animal/umbra/say() //Umbras can't directly speak
	return

/mob/living/simple_animal/umbra/proc/adjust_vitae(amount)
	vitae = min(max(0, vitae + UMBRA_VITAE_DRAIN_RATE), vitae_cap)
	return vitae
