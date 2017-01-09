//Dark bead: Formed by the Devour Will ability. See umbrage_abilities.dm for more details.
/obj/item/weapon/umbrage_dark_bead
	name = "dark bead"
	desc = "A glowing black orb. It's fading fast."
	icon_state = "umbrage_dark_bead"
	flags = NODROP
	w_class = 5
	var/eating = 0 //If we're devouring someone's will
	var/datum/action/innate/umbrage/devour_will/linked_ability //The ability that keeps data for us

/obj/item/weapon/umbrage_dark_bead/New()
	..()
	animate(src, alpha = 30, time = 10)
	spawn(10)
		if(!eating)
			loc << "<span class='warning'>You were too slow! [src] faded away.</span>"
			qdel(src)

/obj/item/weapon/umbrage_dark_bead/attack(mob/living/carbon/L, mob/living/user)
	if(!is_umbrage(user.mind) || eating || L == user) //no eating urself ;)))))))
		return
	var/datum/umbrage/U = linked_ability.get_umbrage()
	if(!L.health)
		user << "<span class='warning'>[L] is too weak to drain.</span>"
		return
	for(var/V in linked_ability.victims)
		var/mob/living/M = V
		if(M == L)
			user << "<span class='warning'>[L] must be given time to recover from their last draining.</span>"
			return
	eating = 1
	user.visible_message("<span class='warning'>[user] grasps [L] leans in close...</span>", "<span class='velvet_bold'>cera qo...</span><br>\
	<span class='danger'>You begin siphoning [L]'s mental energy...</span>")
	playsound(L, 'sound/magic/devour_will.ogg', 100, 0) //T A S T Y   S O U L S
	if(!do_mob(user, L, 30))
		user.Weaken(3)
		L.Weaken(3)
		qdel(src)
		return
	user.visible_message("<span class='warning'>[user] sucks something out of [L]'s body!</span>", "<span class='velvet_bold'>...aranupdejc</span><br>\
	<span class='boldannounce'>You have devoured [L]'s will. Your psi has been fully restored.</span><br>\
	<span class='warning'>[L] is now severely weakened and will take some time to recover.</span>")
	playsound(L, 'sound/magic/devour_will_victim.ogg', 50, 0)
	U.psi = U.max_psi
	playsound(L, "bodyfall", 50, 1)
	L << "<span class='userdanger'>You suddenly feel... empty. Vulnerable. You slip into unconsciousness...</span>"
	L << sound('sound/magic/devour_will_end.ogg', volume = 75)
	linked_ability.victims += L
	L.Paralyse(30)
	L.silent += 40
	L.stuttering += 40
	L.confused += 40
	L.reagents.add_reagent("zombiepowder", 2) //Brief window of vulnerability to veiling
	qdel(src)
	spawn(10) //debug
		if(linked_ability && L)
			linked_ability.victims -= L
			user << "<span class='notice'>[L] has recovered from their draining and is vulnerable to Devour Will again.</span>"
	return 1
