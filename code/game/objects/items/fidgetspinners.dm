/obj/item/weapon/fidgetspinner
	name = "fidget spinner"
	desc = "An ancient toy capable of spinning indefinitely. Its blades are thick and dull."
	icon = 'icons/obj/toy.dmi'
	icon_state = "fidget"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	attack_verb = list("slapped", "tapped", "papped")
	var/force_spinning = 3
	var/throwforce_spinning = 5
	var/spinning = FALSE
	
/obj/item/weapon/fidgetspinner/proc/handle_spin(mob/user)
	update_icon()
	if(spinning) //LET IT RIP
		force = force_spinning
		throwforce = throwforce_spinning
		if(user) //Juuuuuuuuuuuuuuuuuuuust in case
			if(iscarbon(user) && user.disabilities)
				var/mob/living/carbon/C = user
				C.adjustBrainLoss(-1)
	else
		force = initial(force)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/tap.ogg', 50, 1)
		if(user) //Explosions made this godawful creation runtime
			user.visible_message("[src] stops spinning...", "<span class='warning'>Oh no! [src] stopped spinning!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				if(C.getBrainLoss()<=30)
					C.adjustBrainLoss(3)
				else
					C.adjustBrainLoss(1)
	
/obj/item/weapon/fidgetspinner/proc/stop_spin(mob/user)
	if(spinning)
		spinning = FALSE
		handle_spin(user)
	else
		return
		
/obj/item/weapon/fidgetspinner/proc/hand_stop_spin(mob/living/user)
	user.visible_message("[user] puts one of [user.p_their()] fingers in front of [src]'s blades...", "<span class='notice'>You put one of your fingers in front of [src]'s blades...</span>")
	handle_spin(user)
		
/obj/item/weapon/fidgetspinner/attack(mob/M, mob/user, def_zone)
	. = ..()
	if(spinning)
		stop_spin(user)

/obj/item/weapon/fidgetspinner/throw_impact(atom/target)
	. = ..()
	if(spinning)
		stop_spin(thrownby)
		
/obj/item/weapon/fidgetspinner/attackby(obj/item/I, mob/user, params)
	if(spinning)
		user.visible_message("[user] sticks [I] in front of [src]'s blades...", "<span class='notice'>You stick [I] in front of [src]'s blades...</span>")
		stop_spin(user)
	else
		return
	
/obj/item/weapon/fidgetspinner/update_icon()
	icon_state = "[initial(icon_state)]_[spinning]"
	
/obj/item/weapon/fidgetspinner/Initialize()
	. = ..()
	update_icon()
	
/obj/item/weapon/fidgetspinner/attack_self(mob/living/user)
	if(!user.IsAdvancedToolUser() || !ishuman(user))
		to_chat(user, "<span class='warning'>This contraption is much too foolish for your interests.</span>")
		return
	spinning = !spinning
	if(spinning)
		user.visible_message("[user] starts spinning [user.p_their()] [src]...", "<span class='notice'>You start spinning [src]...</span>")
		handle_spin(user)
	else
		hand_stop_spin(user)
			
/obj/item/weapon/fidgetspinner/syndicatespinner
	name = "syndi-spinner"
	desc = "It's a Donk Co. branded Syndi-Spinner. Instead of having thick, dull blades like fidget spinners typically do, this one has thin, sharp blades. Despite the slightly smaller profile, it looks easier to trip over."
	icon_state = "syndifidget"
	force = 3
	throwforce = 5
	force_spinning = 5
	throwforce_spinning = 20
	attack_verb = list("slashed", "stabbed", "bashed")
	
/obj/item/weapon/fidgetspinner/syndicatespinner/hand_stop_spin(mob/living/user)
	user.visible_message("<span class='danger'>[user] cuts [user.p_them()]self on [src]'s blades!</span>", "<span class='warning'>You cut yourself on [src]'s blades!</span>")
	var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? "r_hand" : "l_hand"
	user.apply_damage(force_spinning, BRUTE, hitzone)
	handle_spin(user)
	
/obj/item/weapon/fidgetspinner/syndicatespinner/handle_spin(mob/user)
	. = ..()
	if(spinning)
		embed_chance = 50
	else
		embed_chance = initial(embed_chance)
		
/obj/item/weapon/fidgetspinner/syndicatespinner/Crossed(AM as mob|obj)
	if(spinning && isturf(src.loc))
		if(isliving(AM))
			var/mob/living/L = AM
			var/hitzone = "chest"
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(!C.lying)
					hitzone = pick("l_leg", "r_leg")
			if(L.movement_type & FLYING)
				return
			else
				L.apply_damage(throwforce,BRUTE,hitzone)
				L.Stun(6)
				L.Weaken(6)
				L.visible_message("<span class='danger'>[L] trips over the [src].</span>", "<span class='userdanger'>You trip over the [src]!</span>")
				stop_spin(L)
				