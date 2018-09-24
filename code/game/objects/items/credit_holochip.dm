/obj/item/holochip
	name = "credit holochip"
	desc = "A hard-light chip encoded with an amount of credits. It is a modern replacement for physical money that can be directly converted to virtual currency and viceversa. Keep away from magnets."
	icon = 'icons/obj/economy.dmi'
	icon_state = "holochip"
	throwforce = 0
	force = 0
	w_class = WEIGHT_CLASS_TINY
	var/credits = 0
	
/obj/item/holochip/Initialize(mapload, amount)
	. = ..()
	credits = amount

/obj/item/holochip/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It's loaded with [credits] credit[( credits > 1 ) ? "s" : ""]</span>")
	
/obj/item/holochip/proc/spend(amount, pay_anyway = FALSE)
	if(credits >= amount)
		credits -= amount
		if(credits == 0)
			qdel(src)
		return amount
	else if(pay_anyway)
		qdel(src)
		return credits
	else
		return 0

/obj/item/holochip/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/wipe_chance = 60 / severity
	if(prob(wipe_chance))
		visible_message("<span class='warning'>[src] fizzles and disappears!</span>")
		qdel(src) //rip cash