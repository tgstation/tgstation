#define UPGRADE_COOLDOWN	60
#define UPGRADE_KILL_TIMER	100

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0

	layer = 21
	item_state = "nothing"
	w_class = 5


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	assailant = user
	affecting = victim

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	hud.name = "reinforce grab"
	hud.master = src

	affecting.grabbed_by += src


/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	return ..()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/get_mob_if_throwable()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand


/obj/item/weapon/grab/process()
	if(!confirm())
		return 0

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if(state == GRAB_AGGRESSIVE)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/X in affecting.grabbed_by)
				var/obj/item/weapon/grab/G = X
				if(G == src) continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			hud.icon_state = "reinforce"
		else
			hud.icon_state = "!reinforce"
	else
		if(!affecting.buckled)
			affecting.loc = assailant.loc

	var/breathing_tube = affecting.getorganslot("breathing_tube")

	if(state >= GRAB_NECK)
		affecting.Stun(2)	//It will hamper your voice, being choked and all.
		if(isliving(affecting) && !breathing_tube)
			var/mob/living/L = affecting
			L.adjustOxyLoss(0.5)

	if(state >= GRAB_KILL)
		affecting.Weaken(5)	//Should keep you down unless you get help.
		if(!breathing_tube)
			affecting.losebreath = min(affecting.losebreath + 2, 3)

/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='danger'>[assailant] grabs [affecting] aggressively!</span>")
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
	else
		if(state < GRAB_NECK)
			if(isslime(affecting))
				assailant << "<span class='danger'>You squeeze [affecting], but nothing interesting happens!</span>"
				return

			assailant.visible_message("<span class='danger'>[assailant] moves \his grip to [affecting]'s neck!</span>")
			state = GRAB_NECK
			icon_state = "grabbed+1"
			if(!affecting.buckled)
				affecting.loc = assailant.loc
			add_logs(assailant, affecting, "neck-grabbed")
			hud.icon_state = "disarm/kill"
			hud.name = "disarm/kill"
		else
			if(state < GRAB_UPGRADING)
				assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
				hud.icon_state = "disarm/kill1"
				state = GRAB_UPGRADING
				if(do_after(assailant, UPGRADE_KILL_TIMER, target = affecting))
					if(state == GRAB_KILL)
						return
					if(!affecting)
						qdel(src)
						return
					if(!assailant.canmove || assailant.lying)
						qdel(src)
						return
					state = GRAB_KILL
					assailant.visible_message("<span class='danger'>[assailant] tightens \his grip on [affecting]'s neck!</span>")
					add_logs(assailant, affecting, "strangled")

					assailant.changeNext_move(CLICK_CD_TKSTRANGLE)
					if(!affecting.getorganslot("breathing_tube"))
						affecting.losebreath += 1
				else
					if(assailant)
						assailant.visible_message("<span class='danger'>[assailant] is unable to tighten \his grip on [affecting]'s neck!</span>")
						hud.icon_state = "disarm/kill"
						state = GRAB_NECK


//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && (user.disabilities & FAT) && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting, 60)) return
			else
				if(!do_mob(user, affecting, 130)) return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>")
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			qdel(src)

	add_logs(user, affecting, "attempted to put", src, "into [M]")

/obj/item/weapon/grab/dropped()
	..()
	qdel(src)

#undef UPGRADE_COOLDOWN
#undef UPGRADE_KILL_TIMER
