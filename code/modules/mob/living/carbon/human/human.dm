/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	voice_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "caucasian1_m_s"



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

	// for spawned humans; overwritten by other code
	ready_dna(src)
	randomize_human(src)

	make_blood()

	..()
	var/mob/M = src
	faction |= "\ref[M]"

/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_data_huds()

/mob/living/carbon/human/Destroy()
	for(var/atom/movable/organelle in organs)
		qdel(organelle)
	organs = list()
	return ..()

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
			var/datum/game_mode/malfunction/malf = ticker.mode
			if(malf.malf_mode_declared && (malf.apcs > 0))
				stat(null, "Time left: [max(malf.AI_win_timeleft/malf.apcs, 0)]")

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


	//NINJACODE
	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)) //Only display if actually a ninja.
		var/obj/item/clothing/suit/space/space_ninja/SN = wear_suit
		if(statpanel("SpiderOS"))
			stat("SpiderOS Status:","[SN.s_initialized ? "Initialized" : "Disabled"]")
			stat("Current Time:", "[worldtime2text()]")
			if(SN.s_initialized)
				//Suit gear
				stat("Energy Charge:", "[round(SN.cell.charge/100)]%")
				stat("Smoke Bombs:", "\Roman [SN.s_bombs]")
				//Ninja status
				if(dna)
					stat("Fingerprints:", "[md5(dna.uni_identity)]")
					stat("Unique Identity:", "[dna.unique_enzymes]")
				stat("Overall Status:", "[stat > 1 ? "dead" : "[health]% healthy"]")
				stat("Nutrition Status:", "[nutrition]")
				stat("Oxygen Loss:", "[getOxyLoss()]")
				stat("Toxin Levels:", "[getToxLoss()]")
				stat("Burn Severity:", "[getFireLoss()]")
				stat("Brute Trauma:", "[getBruteLoss()]")
				stat("Radiation Levels:","[radiation] rad")
				stat("Body Temperature:","[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")

				//Virsuses
				if(viruses.len)
					stat("Viruses:", null)
					for(var/datum/disease/D in viruses)
						stat("*", "[D.name], Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]")


/mob/living/carbon/human/ex_act(severity, ex_target)
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
			b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			if (prob(70))
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			if (prob(50))
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

	..()

/mob/living/carbon/human/blob_act()
	if(stat == DEAD)	return
	show_message("<span class='userdanger'> The blob attacks you!</span>")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))
	return

/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=\ref[src];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=\ref[src];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/weapon/tank))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=\ref[src];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_glasses in obscured)
		dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=\ref[src];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_ears in obscured)
		dat += "<tr><td><font color=grey><B>Ears:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Ears:</B></td><td><A href='?src=\ref[src];item=[slot_ears]'>[(ears && !(ears.flags&ABSTRACT))		? ears		: "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=\ref[src];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(wear_suit)
		dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=\ref[src];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(s_store, /obj/item/weapon/tank))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
	else
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

	if(slot_shoes in obscured)
		dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=\ref[src];item=[slot_shoes]'>[(shoes && !(shoes.flags&ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_gloves in obscured)
		dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=\ref[src];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_w_uniform in obscured)
		dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=\ref[src];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(w_uniform == null || (slot_w_uniform in obscured) || (dna && dna.species.nojumpsuit))
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
	else
		dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=\ref[src];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(belt, /obj/item/weapon/tank))
			dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=\ref[src];pockets=left'>[(l_store && !(l_store.flags&ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += "&nbsp;<A href='?src=\ref[src];pockets=right'>[(r_store && !(r_store.flags&ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A></td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=\ref[src];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A></td></tr>"
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

	spreadFire(AM)

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/safety = 0)
	if(!safety)
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			siemens_coeff = G.siemens_coefficient
	return ..(shock_damage,source,siemens_coeff)

/mob/living/carbon/human/Topic(href, href_list)
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))

		if(href_list["embedded_object"])
			var/obj/item/I = locate(href_list["embedded_object"])
			var/obj/item/organ/limb/L = locate(href_list["embedded_limb"])
			if(!I || !L || I.loc != src) //no item, no limb, or item is not in limb (the person atleast) anymore
				return
			var/time_taken = I.embedded_unsafe_removal_time*I.w_class
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from their [L.getDisplayName()].</span>","<span class='notice'>You attempt to remove [I] from your [L.getDisplayName()]... (It will take [time_taken/10] seconds.)</span>")
			if(do_after(usr, time_taken, needhand = 1))
				L.embedded_objects -= I
				L.take_damage(I.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
				I.loc = get_turf(src)
				usr.put_in_hands(I)
				usr.emote("scream")
				usr.visible_message("[usr] successfully rips [I] out of their [L.getDisplayName()]!","<span class='notice'>You successfully remove [I] from your [L.getDisplayName()].</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")
			return

		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				usr << "<span class='warning'>You can't reach that! Something is covering it.</span>"
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? src.r_store : src.l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			//visible_message("<span class='danger'>[usr] tries to empty [src]'s pockets.</span>", \
							"<span class='userdanger'>[usr] tries to empty [src]'s pockets.</span>") // Pickpocketing!
			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					usr << "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>"
				usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>"
			else if(place_item && place_item.mob_can_equip(src, pocket_id, 1) && !(place_item.flags&ABSTRACT))
				usr << "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>"
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
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


///////HUDs///////
	if(href_list["hud"])
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			var/perpname = get_face_name(get_id_name(""))
			if(istype(H.glasses, /obj/item/clothing/glasses/hud))
				var/datum/data/record/R = find_record("name", perpname, data_core.general)
				if(href_list["photo_front"] || href_list["photo_side"])
					if(R)
						if(!H.canUseHUD()) return
						else if(!istype(H.glasses, /obj/item/clothing/glasses/hud)) return
						var/obj/item/weapon/photo/P = null
						if(href_list["photo_front"])
							P = R.fields["photo_front"]
						else if(href_list["photo_side"])
							P = R.fields["photo_side"]
						if(P)
							P.show(H)

				if(href_list["hud"] == "m")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/health))
						if(href_list["p_stat"])
							var/health = input(usr, "Specify a new physical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
							if(R)
								if(!H.canUseHUD()) return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health)) return
								if(health && health != "Cancel")
									R.fields["p_stat"] = health
							return
						if(href_list["m_stat"])
							var/health = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
							if(R)
								if(!H.canUseHUD()) return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health)) return
								if(health && health != "Cancel")
									R.fields["m_stat"] = health
							return
						if(href_list["evaluation"])
							if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
								usr << "<span class='notice'>No external injuries detected.</span><br>"
								return
							var/span = "notice"
							var/status = ""
							if(getBruteLoss())
								usr << "<b>Physical trauma analysis:</b>"
								for(var/obj/item/organ/limb/org in organs)
									var/brutedamage = org.brute_dam
									if(brutedamage > 0)
										status = "received minor physical injuries."
										span = "notice"
									if(brutedamage > 20)
										status = "been seriously damaged."
										span = "danger"
									if(brutedamage > 40)
										status = "sustained major trauma!"
										span = "userdanger"
									if(brutedamage)
										usr << "<span class='[span]'>The [org.getDisplayName()] appears to have [status]</span>"
							if(getFireLoss())
								usr << "<b>Analysis of skin burns:</b>"
								for(var/obj/item/organ/limb/org in organs)
									var/burndamage = org.burn_dam
									if(burndamage > 0)
										status = "signs of minor burns."
										span = "notice"
									if(burndamage > 20)
										status = "serious burns."
										span = "danger"
									if(burndamage > 40)
										status = "major burns!"
										span = "userdanger"
									if(burndamage)
										usr << "<span class='[span]'>The [org.getDisplayName()] appears to have [status]</span>"
							if(getOxyLoss())
								usr << "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>"
							if(getToxLoss() > 20)
								usr << "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>"

				if(href_list["hud"] == "s")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/security))
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

						if(perpname)
							R = find_record("name", perpname, data_core.security)
							if(R)
								if(href_list["status"])
									var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Discharged", "Cancel")
									if(setcriminal != "Cancel")
										if(R)
											if(H.canUseHUD())
												if(istype(H.glasses, /obj/item/clothing/glasses/hud/security))
													investigate_log("[src.key] has been set from [R.fields["criminal"]] to [setcriminal] by [usr.name] ([usr.key]).", "records")
													R.fields["criminal"] = setcriminal
													sec_hud_set_security_status()
									return

								if(href_list["view"])
									if(R)
										if(!H.canUseHUD()) return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security)) return
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
												var/t1 = stripped_input("Please input minor crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input minor crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access) return
													else if(!H.canUseHUD()) return
													else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security)) return
													var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													data_core.addMinorCrime(R.fields["id"], crime)
													usr << "<span class='notice'>Successfully added a minor crime.</span>"
													return
										if("Major Crime")
											if(R)
												var/t1 = stripped_input("Please input major crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input major crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access) return
													else if (!H.canUseHUD()) return
													else if (!istype(H.glasses, /obj/item/clothing/glasses/hud/security)) return
													var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													data_core.addMajorCrime(R.fields["id"], crime)
													usr << "<span class='notice'>Successfully added a major crime.</span>"
									return

								if(href_list["view_comment"])
									if(R)
										if(!H.canUseHUD()) return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security)) return
										usr << "<b>Comments/Log:</b>"
										var/counter = 1
										while(R.fields[text("com_[]", counter)])
											usr << R.fields[text("com_[]", counter)]
											usr << "----------"
											counter++
										return

								if(href_list["add_comment"])
									if(R)
										var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
										if(R)
											if (!t1 || !allowed_access) return
											else if(!H.canUseHUD()) return
											else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security)) return
											var/counter = 1
											while(R.fields[text("com_[]", counter)])
												counter++
											R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, worldtime2text(), time2text(world.realtime, "MMM DD"), year_integer+540, t1,)
											usr << "<span class='notice'>Successfully added comment.</span>"
											return
							usr << "<span class='warning'>Unable to locate a data core entry for this person.</span>"

/mob/living/carbon/human/proc/canUseHUD()
	return !(src.stat || src.weakened || src.stunned || src.restrained())

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_sel.selecting
	if(dna && PIERCEIMMUNE in dna.species.specflags)
		. = 0
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

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/singularity_pull(S, current_size)
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && unEquip(hand))
				step_towards(hand, src)
				src << "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>"
	irradiate(current_size * 3)
	if(mob_negates_gravity())
		return
	..()


/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(health >= 0)
		if(src == M)
			visible_message( \
				"[src] examines \himself.", \
				"<span class='notice'>You check yourself for injuries.</span>")

			for(var/obj/item/organ/limb/org in organs)
				var/status = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				if(hallucination)
					if(prob(30))
						brutedamage += rand(30,40)
					if(prob(30))
						burndamage += rand(30,40)

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "battered"
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
				if(status == "")
					status = "OK"
				src << "\t [status == "OK" ? "\blue" : "\red"] Your [org.getDisplayName()] is [status]."

				for(var/obj/item/I in org.embedded_objects)
					src << "\t <a href='byond://?src=\ref[src];embedded_object=\ref[I];embedded_limb=\ref[org]'>\red There is \a [I] embedded in your [org.getDisplayName()]!</a>"

			if(blood_max)
				src << "<span class='danger'>You are bleeding!</span>"
			if(staminaloss)
				if(staminaloss > 30)
					src << "<span class='info'>You're completely exhausted.</span>"
				else
					src << "<span class='info'>You feel fatigued.</span>"
		else
			if(wear_suit)
				wear_suit.add_fingerprint(M)
			else if(w_uniform)
				w_uniform.add_fingerprint(M)

			..()


/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/C)
	if(C.stat == DEAD)
		src << "<span class='warning'>[C.name] is dead!</span>"
		return
	if(is_mouth_covered())
		src << "<span class='warning'>Remove your mask first!</span>"
		return 0
	if(C.is_mouth_covered())
		src << "<span class='warning'>Remove their mask first!</span>"
		return 0

	if(C.cpr_time < world.time + 30)
		add_logs(src, C, "CPRed")
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>You try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_mob(src, C))
			src << "<span class='warning'>You fail to perform CPR on [C]!</span>"
			return 0

		if(C.health <= config.health_threshold_crit)
			C.cpr_time = world.time
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			src.visible_message("[src] performs CPR on [C.name]!", "<span class='notice'>You perform CPR on [C.name].</span>")
			C << "<span class='unconscious'>You feel a breath of fresh air enter your lungs... It feels good...</span>"


/mob/living/carbon/human/generateStaticOverlay()
	var/image/staticOverlay = image(icon('icons/effects/effects.dmi', "static"), loc = src)
	staticOverlay.override = 1
	staticOverlays["static"] = staticOverlay

	staticOverlay = image(icon('icons/effects/effects.dmi', "blank"), loc = src)
	staticOverlay.override = 1
	staticOverlays["blank"] = staticOverlay

	staticOverlay = getLetterImage(src, "H", 1)
	staticOverlay.override = 1
	staticOverlays["letter"] = staticOverlay

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(dna && dna.check_mutation(HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		..(I, cuff_break = 1)
	else
		..()
