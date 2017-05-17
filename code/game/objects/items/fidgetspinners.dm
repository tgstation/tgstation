/obj/item/weapon/fidgetspinner
	name = "fidget spinner"
	desc = "An ancient toy capable of spinning indefinitely. Its blades are thick and dull."
	icon = 'icons/obj/toy.dmi'
	icon_state = "fidget"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 3
	var/force_spinning = 3
	var/throwforce_spinning = 5
	throw_speed = 3
	throw_range = 5
	attack_verb = list("slapped", "tapped", "papped")
	var/spinning = 0
	var/syndispinner = 0
	
/obj/item/weapon/fidgetspinner/proc/handle_spin(mob/user)
	if(spinning) //LET IT RIP
		force = force_spinning
		throwforce = throwforce_spinning
		if(syndispinner)
			embed_chance = 50
	else
		force = initial(force)
		throwforce = initial(throwforce)
		embed_chance = initial(embed_chance)
		user.visible_message("[src] stops spinning...", "<span class='warning'>Oh no! [src] stopped spinning!</span>")
	update_icon()
	
/obj/item/weapon/fidgetspinner/proc/stop_spin(mob/user)
	if(spinning)
		spinning = !spinning
		handle_spin(user)
	else
		return
		
/obj/item/weapon/fidgetspinner/attack(mob/M, mob/user, def_zone)
	..()
	if(spinning)
		stop_spin(user)

/obj/item/weapon/fidgetspinner/throw_impact(atom/target)
	..()
	if(spinning)
		stop_spin(thrownby)
		
/obj/item/weapon/fidgetspinner/attackby(obj/item/I, mob/user, params)
	..()
	if(spinning)
		user.visible_message("[user] sticks [I] in front of [src]'s blades...", "<span class='notice'>You stick [I] in front of [src]'s blades...</span>")
		stop_spin(user)
	else
		return
	
/obj/item/weapon/fidgetspinner/update_icon()
	if(spinning)
		icon_state = "[initial(icon_state)]_spin"
	else
		icon_state = "[initial(icon_state)]"
	
/obj/item/weapon/fidgetspinner/attack_self(mob/living/user)
	spinning = !spinning
	if(spinning)
		user.visible_message("[user] starts spinning [user.p_their()] [src]...", "<span class='notice'>You start spinning [src]...</span>")
		handle_spin(user)
	else
		if(!syndispinner)
			user.visible_message("[user] puts one of [user.p_their()] fingers in front of [src]'s blades...", "<span class='notice'>You put one of your fingers in front of [src]'s blades...</span>")
			handle_spin(user)
		else
			user.visible_message("<span class='danger'>[user] cuts [user.p_them()]self on [src]'s blades!</span>", "<span class='warning'>You cut yourself on [src]'s blades!</span>")
			var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? "r_hand" : "l_hand"
			user.apply_damage(force_spinning, BRUTE, hitzone)
			handle_spin(user)
			
/obj/item/weapon/fidgetspinner/syndicatespinner
	desc = "It's a Donk Co. branded Syndi-Spinner. Instead of having thick, dull blades like fidget spinners typically do, this one has thin, sharp blades."
	syndispinner = 1
	icon_state = "syndifidget"
	force = 3
	throwforce = 5
	force_spinning = 5
	throwforce_spinning = 20
	attack_verb = list("slashed", "stabbed", "bashed")