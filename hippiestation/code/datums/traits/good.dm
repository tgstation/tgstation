/* Hippie good traits */
/datum/trait/iron_butt
	name = "Iron Butt"
	desc = "Your butt is stronger than other butts, it will be half as likely to come off when farting."
	value = 1
	gain_text = "<span class='notice'>Your butt feels STRONGER.</span>"
	lose_text = "<span class='notice'>Your butt feels weaker.</span>"

/datum/trait/iron_butt/add()
	var/mob/living/carbon/human/H = trait_holder
	H.lose_butt = 6

/datum/trait/iron_butt/remove()
	var/mob/living/carbon/human/H = trait_holder
	H.lose_butt = initial(H.lose_butt)

/datum/trait/volatile_butt
	name = "Volatile Butt"
	desc = "Your butt is volatile and far more likley to blow catastrophically when farting as hard as you can."
	value = 2
	gain_text = "<span class='notice'>Your butt feels volatile and upredictable!</span>"
	lose_text = "<span class='notice'>Your butt feels stable.</span>"

/datum/trait/volatile_butt/add()
	var/mob/living/carbon/human/H = trait_holder
	H.super_fart = 64
	H.super_nova_fart = 18
	H.fart_fly = 18

/datum/trait/volatile_butt/remove()
	var/mob/living/carbon/human/H = trait_holder
	H.super_fart = initial(H.super_fart)
	H.super_nova_fart = initial(H.super_nova_fart)
	H.fart_fly = initial(H.fart_fly)