//Formed by the Devour Will ability.
/obj/item/dark_bead
	name = "dark bead"
	desc = "A glowing black orb. It's fading fast."
	icon_state = "dark_bead"
	item_state = "disintegrate"
	flags_1 = NODROP_1
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	w_class = 5
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2
	var/eating = FALSE //If we're devouring someone's will
	var/datum/action/innate/darkspawn/devour_will/linked_ability //The ability that keeps data for us

/obj/item/dark_bead/Initialize()
	. = ..()
	animate(src, alpha = 30, time = 30)
	QDEL_IN(src, 30)

/obj/item/dark_bead/Destroy(force)
	if(isliving(loc) && !eating && !force)
		to_chat(loc, "<span class='warning'>You were too slow! [src] faded away...</span>")
	if(!eating || force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/dark_bead/attack(mob/living/carbon/L, mob/living/user)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(!darkspawn || eating || L == user) //no eating urself ;)))))))
		return
	linked_ability = darkspawn.has_ability("devour_will")
	if(!linked_ability) //how did you even get this?
		qdel(src)
		return
	if(!L.health || L.stat)
		to_chat(user, "<span class='warning'>[L] is too weak to drain.</span>")
		return
	if(linked_ability.victims[L.real_name])
		to_chat(user, "<span class='warning'>[L] must be given time to recover from their last draining.</span>")
		return
	if(!L.mind || isdarkspawn(L))
		to_chat(user, "<span class='warning'>You cannot drain allies or the mindless.</span>")
		return
	eating = TRUE
	if(user.loc != L)
		user.visible_message("<span class='warning'>[user] grabs [L] and leans in close...</span>", "<span class='velvet bold'>cera qo...</span><br>\
		<span class='danger'>You begin siphoning [L]'s mental energy...</span>")
		to_chat(L, "<span class='userdanger'><i>AAAAAAAAAAAAAA-</i></span>")
		L.Stun(30)
		playsound(L, 'sound/magic/devour_will.ogg', 65, FALSE) //T A S T Y   S O U L S
		if(!do_mob(user, L, 30))
			user.Knockdown(30)
			to_chat(L, "<span class='boldwarning'>All right. You're all right.</span>")
			L.Knockdown(30)
			qdel(src, force = TRUE)
			return
	else
		L.visible_message("<span class='userdanger italics'>[L] suddenly howls and clutches as their face as violet light screams from their eyes!</span>", \
		"<span class='userdanger italics'>AAAAAAAAAAAAAAA-</span>", ignore_mob = user)
		to_chat(user, "<span class='velvet'><b>cera qo...</b><br>You begin siphoning [L]'s will...</span>")
		L.Stun(50)
		playsound(L, 'sound/magic/devour_will_long.ogg', 65, FALSE)
		if(!do_mob(user, L, 50))
			user.Knockdown(50)
			to_chat(L, "<span class='boldwarning'>All right. You're all right.</span>")
			L.Knockdown(50)
			qdel(src, force = TRUE)
			return
	user.visible_message("<span class='warning'>[user] gently lowers [L] to the ground...</span>", "<span class='velvet'><b>...aranupdejc</b><br>\
	You devour [L]'s will. Your Psi has been fully restored.\n\
	Additionally, you have gained one lucidity. Use it to purchase and upgrade abilities.<br>\
	<span class='warning'>[L] is now severely weakened and will take some time to recover.</span>")
	playsound(L, 'sound/magic/devour_will_victim.ogg', 50, FALSE)
	darkspawn.psi = darkspawn.psi_cap
	darkspawn.lucidity++
	darkspawn.lucidity_drained++
	darkspawn.update_psi_hud()
	linked_ability.victims[L] = TRUE
	to_chat(L, "<span class='userdanger'>You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber...</span>")
	L.playsound_local(L, 'sound/magic/devour_will_end.ogg', 75, FALSE)
	L.Unconscious(300)
	L.stuttering += 40
	L.reagents.add_reagent("zombiepowder", 2) //Brief window of fake death
	addtimer(CALLBACK(linked_ability, /datum/action/innate/darkspawn/devour_will/.proc/make_eligible, L), 300)
	qdel(src, force = TRUE)
	return TRUE
