
// Vent crawling whitelisted items, whoo
/mob/living
	var/canEnterVentWith = "/obj/item/weapon/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/device/radio/borg=0&/obj/machinery/camera=0"

/mob/living/carbon/Login()
	..()
	update_hud()
	return

/mob/living/carbon/Bump(var/atom/movable/AM, yes)
	if(now_pushing || !yes)
		return
	..()
	if(istype(AM, /mob/living/carbon) && prob(10))
		src.spread_disease_to(AM, "Contact")


/mob/living/carbon/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	. = ..()

	if(.)
		if(nutrition && stat != DEAD)
			nutrition -= HUNGER_FACTOR / 10

			if(m_intent == "run")
				nutrition -= HUNGER_FACTOR / 10

		if((M_FAT in mutations) && m_intent == "run" && bodytemperature <= 360)
			bodytemperature += 2

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ("chest")
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						if(temp.take_damage(d, 0))
							H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("<span class='danger'>[M] bursts out of [src]!</span>"), 2)
	. = ..()

/mob/living/carbon/proc/share_contact_diseases(var/mob/M)
	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)
	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	if (hasorgans(M))
		var/datum/organ/external/temp = M:organs_by_name["r_hand"]
		if (M.hand)
			temp = M:organs_by_name["l_hand"]
		if(temp && !temp.is_usable())
			M << "<span class='warning'>You can't use your [temp.display_name]</span>"
			return
	share_contact_diseases(M)
	return


/mob/living/carbon/attack_paw(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	share_contact_diseases(M)
	return

/mob/living/carbon/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		damage = 0

	if(take_overall_damage(0, damage, "[source]") == 0) // godmode
		return 0

	//src.burn_skin(shock_damage)
	//src.adjustFireLoss(shock_damage) //burn_skin will do this for us
	//src.updatehealth()

	visible_message( \
		"<span class='warning'>[src] was shocked by the [source]!</span>", \
		"<span class='danger'>You feel a powerful shock course through your body!</span>", \
		"<span class='warning'>You hear a heavy electrical crack.</span>" \
	)

	//if(src.stunned < shock_damage)	src.stunned = shock_damage

	Stun(10) // this should work for now, more is really silly and makes you lay there forever

	//if(src.weakened < 20*siemens_coeff)	src.weakened = 20*siemens_coeff

	Weaken(10)

	var/datum/effect/effect/system/spark_spread/SparkSpread = new
	SparkSpread.set_up(5, 1, loc)
	SparkSpread.start()

	return damage

/mob/living/carbon/proc/swap_hand()
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_active"
			hud_used.r_hand_hud_object.icon_state = "hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
				)

			for(var/datum/organ/external/org in H.organs)
				var/status = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "bleeding"
				if(brutedamage > 40)
					status = "mangled"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"
				if(org.status & ORGAN_DESTROYED)
					status = "MISSING!"
				if(org.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"<span class='notice'></span>":"<span class='danger'></span>",org.display_name,status),1)
			if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else if(lying) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			src.sleeping = max(0,src.sleeping-5)
			if(src.sleeping == 0)
				src.resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
				"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>", \
				)
		// BEGIN HUGCODE - N3X
		else
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] gives [src] a [pick("hug","warm embrace")].</span>", \
				"<span class='notice'>You hug [src].</span>", \
				)
			reagents.add_reagent("paracetamol", 1)

			share_contact_diseases(M)


/mob/living/carbon/proc/eyecheck()
	return 0

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/proc/handle_ventcrawl(var/atom/clicked_on) // -- TLE -- Merged by Carn
	diary << "[src] is ventcrawling."
	if(!stat)
		if(!lying)

/*
			if(clicked_on)
				world << "We start with [clicked_on], and [clicked_on.type]"
*/
			var/obj/machinery/atmospherics/unary/vent_found

			if(clicked_on && Adjacent(clicked_on))
				vent_found = clicked_on
				if(!istype(vent_found) || !vent_found.can_crawl_through())
					vent_found = null


			if(!vent_found)
				for(var/obj/machinery/atmospherics/machine in range(1,src))
					if(is_type_in_list(machine, ventcrawl_machinery))
						vent_found = machine

					if(!vent_found.can_crawl_through())
						vent_found = null

					if(vent_found)
						break

			if(vent_found)
				if(vent_found.network && (vent_found.network.normal_members.len || vent_found.network.line_members.len))

					src << "You begin climbing into the ventilation system..."
					if(!do_after(src, 45,,0))
						return

					if(!client)
						return

					if(contents.len && !isrobot(src))
						for(var/obj/item/carried_item in contents)//If the ventcrawler got on objects.
							if(!(isInTypes(carried_item, canEnterVentWith)))
								src << "<SPAN CLASS='warning'>You can't be carrying items or have items equipped when vent crawling!</SPAN>"
								return

					visible_message("<B>[src] scrambles into the ventilation ducts!</B>", "You climb into the ventilation system.")

					loc = vent_found
					add_ventcrawl(vent_found)

				else
					src << "This vent is not connected to anything."

			else
				src << "You must be standing on or beside an air vent to enter it."

		else
			src << "You can't vent crawl while you're stunned!"

	else
		src << "You must be conscious to do this!"
	return

/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/unary/starting_machine)
	for(var/datum/pipeline/pipeline in starting_machine.network.line_members)
		for(var/atom/A in (pipeline.members || pipeline.edges))
			var/image/new_image = image(A, A.loc, dir = A.dir)
			pipes_shown += new_image
			client.images += new_image

/mob/living/proc/remove_ventcrawl()
	for(var/image/current_image in pipes_shown)
		client.images -= current_image

	pipes_shown.len = 0

	if(client)
		client.eye = src

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
			H.gloves.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves(0)
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	if(gcDestroyed) return
	src.in_throw_mode = 1
	src.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(var/atom/target,var/atom/movable/what=null)
	return

/mob/living/carbon/throw_item(var/atom/target,var/atom/movable/what=null)
	src.throw_mode_off()
	if(usr.stat || !target)
		return

	if(!istype(loc,/turf))
		src << "<span class='warning'>You can't do that now!</span>"
		return

	if(target.type == /obj/screen) return

	var/atom/movable/item = src.get_active_hand()
	if(what)
		item=what

	if(!item) return

	if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw() //throw the person instead of the grab
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")

				log_attack("<font color='red'>[usr.name] ([usr.ckey]) Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				if(!iscarbon(usr))
					M.LAssailant = null
				else
					M.LAssailant = usr
				del(G)
	if(!item) return //Grab processing has a chance of returning null

	//item.layer = initial(item.layer)
	u_equip(item)
	update_icons()

//	if (istype(usr, /mob/living/carbon/monkey)) //Check if a monkey is throwing. Modify/remove this line as required.
	var/turf/T=get_turf(loc)
	if(istype(item, /obj/item))
		item.loc = T
		if(src.client)
			src.client.screen -= item
		if(istype(item, /obj/item))
			item:dropped(src) // let it know it's been dropped

	//actually throw it!
	if (item)
		item.layer = initial(item.layer)
		src.visible_message("<span class='warning'>[src] has thrown [item].</span>")

		if((istype(src.loc, /turf/space)) || (src.areaMaster.has_gravity == 0))
			var/mob/space_obj=src
			// If we're being held, make the guy holding us move.
			if(istype(loc,/obj/item/weapon/holder))
				var/obj/item/weapon/holder/Ho=loc
				// Who holds the holder?
				if(ismob(Ho.loc))
					space_obj=Ho.loc
			space_obj.inertia_dir = get_dir(target, src)
			step(space_obj, inertia_dir)


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/


		var/throw_mult=1
		if(istype(src,/mob/living/carbon/human))
			var/mob/living/carbon/human/H=src
			throw_mult = H.species.throw_mult
			if(M_HULK in H.mutations || M_STRONG in H.mutations)
				throw_mult+=0.5
		item.throw_at(target, item.throw_range*throw_mult, item.throw_speed*throw_mult)

/*mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)*/

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/u_equip(obj/item/W as obj)
	if(!W)	return 0

	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()

	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else
	 ..()

	return
/*
/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob\ref[src];size=325x500"))
	onclose(user, "mob\ref[src]")
	return
*/


/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"

	var/dat = {"
	<B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>		[(l_hand && !( src.l_hand.abstract ))		? l_hand	: "<font color=grey>Empty</font>"]</A><BR>
	<B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>		[(r_hand && !( src.r_hand.abstract ))		? r_hand	: "<font color=grey>Empty</font>"]</A><BR>
	"}

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=back'> [(back && !(src.back.abstract)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/weapon/tank))
		dat += "<BR>[TAB]&#8627;<A href='?src=\ref[src];item=internal'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "<BR>"


	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=mask'>		[(wear_mask && !(src.wear_mask.abstract))	? wear_mask	: "<font color=grey>Empty</font>"]</A>"


	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=handcuff'>Remove</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()





//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		usr << "<span class='warning'>You are already sleeping</span>"
		return
	if(alert(src,"Are you sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 150 //Long nap of 5 minutes. Those are MC TICKS. Don't get fooled

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	do_release_control(0)

/mob/living/carbon/proc/do_release_control(var/rptext=1)
	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		if(rptext)
			src << "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>"
			B.host_brain << "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>"
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	verbs -= /mob/living/carbon/proc/release_control
	verbs -= /mob/living/carbon/proc/punish_host
	verbs -= /mob/living/carbon/proc/spawn_larvae

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		src << "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>"
		B.host_brain << "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>"

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/living/carbon/proc/spawn_larvae()
	set category = "Alien"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		src << "<span class='warning'>You strain, trying to push out your young...</span>"
		var/mob/dead/observer/O = B.request_player()
		if(!O)
			// No spaceghoasts.
			src << "<span class='warning'>Your young are not ready yet.</span>"
		else
			src << "<span class='danger'>Your host twitches and quivers as you rapidly excrete several larvae from your sluglike body.</span>"
			visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
			B.chemicals -= 100

			B.numChildren++

			new /obj/effect/decal/cleanable/vomit(get_turf(src))
			playsound(loc, 'sound/effects/splat.ogg', 50, 1)

			var/mob/living/simple_animal/borer/nB = new (get_turf(src),by_gamemode=1) // We've already chosen.
			nB.transfer_personality(O.client)

	else
		src << "You do not have enough chemicals stored to reproduce."
		return

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))


/mob/living/carbon/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return (health < config.health_threshold_crit) && stat != 2
