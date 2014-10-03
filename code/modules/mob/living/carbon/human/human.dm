/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	voice_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "caucasian1_m_s"
	var/list/hud_list = list()



/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH



/mob/living/carbon/human/New()
	create_reagents(1000)
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down
	//initialise organs
	organs = newlist(/obj/item/organ/limb/chest, /obj/item/organ/limb/head, /obj/item/organ/limb/l_arm,
					 /obj/item/organ/limb/r_arm, /obj/item/organ/limb/r_leg, /obj/item/organ/limb/l_leg)
	for(var/obj/item/organ/limb/O in organs)
		O.owner = src
	internal_organs += new /obj/item/organ/appendix
	internal_organs += new /obj/item/organ/heart
	internal_organs += new /obj/item/organ/brain

	for(var/i=0;i<7;i++) // 2 for medHUDs and 5 for secHUDs
		hud_list += image('icons/mob/hud.dmi', src, "hudunknown")

	// for spawned humans; overwritten by other code
	create_dna(src)
	ready_dna(src)
	randomize_human(src)

	..()

/mob/living/carbon/human/Destroy()
	for(var/atom/movable/organelle in organs)
		qdel(organelle)
	return ..()

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM

//BubbleWrap - Should stop you pushing a restrained person out of the way

		if(istype(tmob, /mob/living/carbon/human))

			for(var/mob/M in range(tmob, 1))
				if( ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						src << "<span class='warning'>[tmob] is restrained, you cannot push past.</span>"
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						src << "<span class='warning'>[tmob] is restraining [M], you cannot push past.</span>"
					now_pushing = 0
					return

		//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		if((tmob.a_intent == "help" || tmob.restrained()) && (a_intent == "help" || src.restrained()) && tmob.canmove && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			var/turf/other_loc = tmob.loc

			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0

			for(var/mob/living/carbon/slime/slime in view(1,tmob))
				if(slime.Victim == tmob)
					slime.UpdateFeed()

			//cross any movable atoms on either turf
			for(var/atom/movable/M in other_loc)
				M.Crossed(src)
			for(var/atom/movable/M in oldloc)
				M.Crossed(tmob)

			return

		if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return

		tmob.LAssailant = src

	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return
	if (!now_pushing)
		now_pushing = 1

		if (!AM.anchored)
			if(pulling == AM)
				stop_pulling()
			var/t = get_dir(src, AM)
			AM.Move(get_step(AM, t))
		now_pushing = 0

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)
		if (istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_initialized)
			stat("Energy Charge", round(wear_suit:cell:charge/100))


/mob/living/carbon/human/ex_act(severity)
	..()

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				Paralyse(10)

	var/update = 0
	for(var/obj/item/organ/limb/temp in organs)
		switch(temp.name)
			if("head")
				update |= temp.take_damage(b_loss * 0.2, f_loss * 0.2)
			if("chest")
				update |= temp.take_damage(b_loss * 0.4, f_loss * 0.4)
			if("l_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05)
			if("r_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05)
			if("l_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05)
			if("r_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05)
	if(update)	update_damage_overlays(0)


/mob/living/carbon/human/blob_act()
	if(stat == 2)	return
	show_message("<span class='userdanger'> The blob attacks you!</span>")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(rand(20,30), BRUTE, affecting, run_armor_check(affecting, "melee"))
	return


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>", \
				"<span class='userdanger'>[M] [M.attacktext] [src]!</span>")
		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor)
		if(armor >= 2)	return


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else

			var/damage = rand(1, 3)
			visible_message("<span class='danger'>[L] bites [src]!</span>", \
					"<span class='userdanger'>[L] bites [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

			if(stat != DEAD)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/organ/limb/affecting = get_organ(ran_zone(L.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin")

		var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0
				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", \
						"<span class='userdanger'>The [M.name] has shocked [src]!</span>")

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return


/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75

/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/list/obscured = check_obscured_slots()

	//Hands slots
	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=\ref[src];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=\ref[src];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	//Back slot
	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(can_set_internals(back))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	//Head slot
	dat += "<tr><td><B>Head:</B></td><td><A href='?src=\ref[src];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	//Mask slot
	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	//Eyes slot
	if(slot_glasses in obscured)
		dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=\ref[src];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

	//Ears slot
	if(slot_ears in obscured)
		dat += "<tr><td><font color=grey><B>Ears:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Ears:</B></td><td><A href='?src=\ref[src];item=[slot_ears]'>[(ears && !(ears.flags&ABSTRACT))		? ears		: "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	//Suit group
	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=\ref[src];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(wear_suit)
		dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=\ref[src];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
		if(can_set_internals(s_store))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
	else
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

	//Shoes slot
	if(slot_shoes in obscured)
		dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=\ref[src];item=[slot_shoes]'>[(shoes && !(shoes.flags&ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

	//Gloves slot
	if(slot_gloves in obscured)
		dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=\ref[src];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

	//Jumpsuit slot
	if(slot_w_uniform in obscured)
		dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=\ref[src];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

	//Jumpsuit group
	if(w_uniform == null || (slot_w_uniform in obscured) || (dna && dna.species.nojumpsuit))
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
	else
		//Belt slot
		dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=\ref[src];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
		if(can_set_internals(belt))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"

		//Pockets slot
		dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=\ref[src];pockets=left'>[(l_store && !(l_store.flags&ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += "&nbsp;<A href='?src=\ref[src];pockets=right'>[(r_store && !(r_store.flags&ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
		if(can_set_internals(l_store))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_l_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		else if(can_set_internals(r_store))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_r_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"

		//ID slot
		dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=\ref[src];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"

	//Handcuffed
	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A></td></tr>"

	//Legcuffed
	if(legcuffed)
		dat += "<tr><td><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 510)
	popup.set_content(dat)
	popup.open()

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/safety = 0)
	if(!safety)
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			siemens_coeff = G.siemens_coefficient
	return ..(shock_damage,source,siemens_coeff)


/mob/living/carbon/human/Topic(href, href_list)
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				usr << "<span class='warning'>You can't reach that. Something is covering it.</span>"
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? src.r_store : src.l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			//visible_message("<span class='danger'>[usr] tries to empty [src]'s pockets.</span>", \
							"<span class='userdanger'>[usr] tries to empty [src]'s pockets.</span>") // Pickpocketing!
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>"
				usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>"
			else if(place_item && place_item.mob_can_equip(src, pocket_id, 1) && !(place_item.flags&ABSTRACT))
				usr << "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>"
			else
				return

			if(do_mob(usr, src, STRIP_DELAY))
				if(pocket_item)
					unEquip(pocket_item)
				else
					if(place_item)
						usr.unEquip(place_item)
						equip_to_slot_if_possible(place_item, pocket_id, 0, 1)

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up
				src << "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>"

		..()


	if(href_list["criminal"])
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
				if(usr.stat || usr == src) //|| !usr.canmove || usr.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
					return													  //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
				// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
				var/allowed_access = null
				var/obj/item/clothing/glasses/G = H.glasses
				if (!G.emagged)
					if(H.wear_id)
						var/list/access = H.wear_id.GetAccess()
						if(access_sec_doors in access)
							allowed_access = H.get_authentification_name()
				else
					allowed_access = "@%&ERROR_%$*"


				if(!allowed_access)
					H << "<span class='warning'>ERROR: Invalid Access</span>"
					return

				var/perpname = get_face_name(get_id_name(""))
				if(perpname)
					var/datum/data/record/R = find_record("name", perpname, data_core.security)
					if(R)
						if(href_list["status"])
							var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Discharged", "Cancel")
							if(R)
								if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal

										spawn()
										H.handle_regular_hud_updates()
								return

						if(href_list["view"])
							if(R)
								if(usr.stat || H.weakened || H.stunned || H.restrained() || !istype(H.glasses, /obj/item/clothing/glasses/hud/security) || !istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
									return
								usr << "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]"
								usr << "<b>Minor Crimes:</b>"
								for(var/datum/data/crime/c in R.fields["mi_crim"])
									usr << "<b>Crime:</b> [c.crimeName]"
									usr << "<b>Details:</b> [c.crimeDetails]"
									usr << "Added by [c.author] at [c.time]"
									usr << "----------"
								usr << "<b>Major Crimes:</b>"
								for(var/datum/data/crime/c in R.fields["ma_crim"])
									usr << "<b>Crime:</b> [c.crimeName]"
									usr << "<b>Details:</b> [c.crimeDetails]"
									usr << "Added by [c.author] at [c.time]"
									usr << "----------"
								usr << "<b>Notes:</b> [R.fields["notes"]]"
								return

						if(href_list["add_crime"])
							switch(alert("What crime would you like to add?","Security HUD","Minor Crime","Major Crime","Cancel"))
								if("Minor Crime")
									if(R)
										var/t1 = copytext(sanitize(input("Please input minor crime names:", "Security HUD", "", null)  as text),1,MAX_MESSAGE_LEN)
										var/t2 = copytext(sanitize(input("Please input minor crime details:", "Security HUD", "", null)  as message),1,MAX_MESSAGE_LEN)
										if(R)
											if (!t1 || !t2 || !allowed_access || H.stat || H.weakened || H.stunned || H.restrained() || !istype(H.glasses, /obj/item/clothing/glasses/hud/security) || !istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
												return
											var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
											data_core.addMinorCrime(R.fields["id"], crime)
											usr << "<span class='notice'>Successfully added a minor crime.</span>"
											return
								if("Major Crime")
									if(R)
										var/t1 = copytext(sanitize(input("Please input major crime names:", "Security HUD", "", null)  as text),1,MAX_MESSAGE_LEN)
										var/t2 = copytext(sanitize(input("Please input major crime details:", "Security HUD", "", null)  as message),1,MAX_MESSAGE_LEN)
										if(R)
											if (!t1 || !t2 || !allowed_access || H.stat || H.weakened || H.stunned || H.restrained() || !istype(H.glasses, /obj/item/clothing/glasses/hud/security) || !istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
												return
											var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
											data_core.addMajorCrime(R.fields["id"], crime)
											usr << "<span class='notice'>Successfully added a major crime.</span>"
											return
								else return

						if(href_list["view_comment"])
							if(R)
								if(H.stat || H.weakened || H.stunned || H.restrained() || !istype(H.glasses, /obj/item/clothing/glasses/hud/security) || !istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
									return
								usr << "<b>Comments/Log:</b>"
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									usr << R.fields[text("com_[]", counter)]
									usr << "----------"
									counter++
								return

						if(href_list["add_comment"])
							if(R)
								var/t1 = copytext(sanitize(input("Add Comment:", "Secure. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if(R)
									if (!t1 || !allowed_access || H.stat || H.weakened || H.stunned || H.restrained() || !istype(H.glasses, /obj/item/clothing/glasses/hud/security) || !istype(H.glasses, /obj/item/clothing/glasses/hud/security/sunglasses))
										return
									var/counter = 1
									while(R.fields[text("com_[]", counter)])
										counter++
									R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, worldtime2text(), time2text(world.realtime, "MMM DD"), year_integer+540, t1,)
									usr << "<span class='notice'>Successfully added comment.</span>"
									return
					usr << "<span class='warning'>Unable to locate a data core entry for this person.</span>"

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='notice'>[src] begins playing \his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone = 0

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_sel.selecting
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if(above_neck(target_zone))
		if(head && head.flags & THICKMATERIAL)
			. = 0
	else
		if(wear_suit && wear_suit.flags & THICKMATERIAL)
			. = 0
	if(!. && error_msg && user)
		// Might need re-wording.
		user << "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on their head" : "on their body"].</span>"

/mob/living/carbon/human/proc/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= slot_gloves
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= slot_w_uniform
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= slot_shoes

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= slot_wear_mask
		if(head.flags_inv & HIDEEYES)
			obscured |= slot_glasses
		if(head.flags_inv & HIDEEARS)
			obscured |= slot_ears

	if(obscured.len > 0)
		return obscured
	else
		return null

/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/redtag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/redtag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/bluetag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/bluetag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_idcard()
	if(judgebot.idcheck && !idcard && name=="Unknown")
		threatcount += 4

	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			if(judgebot.check_for_weapons(l_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(r_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(belt))
				threatcount += 2

	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Parolled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
		threatcount += 2

	//Check for nonhuman scum
	if(dna && dna.species.id && dna.species.id != "human")
		threatcount += 1

	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/weapon/card/id/syndicate))
		threatcount -= 5

	return threatcount


//Used for new human mobs created by cloning/goleming/podding
/mob/living/carbon/human/proc/set_cloned_appearance()
	if(gender == MALE)
		facial_hair_style = "Full Beard"
	else
		facial_hair_style = "Shaved"
	hair_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	underwear = "Nude"
	regenerate_icons()