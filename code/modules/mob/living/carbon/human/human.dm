<<<<<<< HEAD
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
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	//initialize limbs first
	bodyparts = newlist(/obj/item/bodypart/chest, /obj/item/bodypart/head, /obj/item/bodypart/l_arm,
					 /obj/item/bodypart/r_arm, /obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg)
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		O.owner = src

	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

	if(dna.species)
		set_species(dna.species.type)

	//initialise organs
	if(!(NOHUNGER in dna.species.specflags))
		internal_organs += new /obj/item/organ/appendix

	if(!(NOBREATH in dna.species.specflags))
		internal_organs += new /obj/item/organ/lungs

	if(!(NOBLOOD in dna.species.specflags))
		internal_organs += new /obj/item/organ/heart

	internal_organs += new /obj/item/organ/brain

	//Note: Additional organs are generated/replaced on the dna.species level

	for(var/obj/item/organ/I in internal_organs)
		I.Insert(src)

	martial_art = default_martial_art

	handcrafting = new()

	..()

/mob/living/carbon/human/OpenCraftingMenu()
	handcrafting.ui_interact(src)

/mob/living/carbon/human/prepare_data_huds()
	//Update med hud images...
	..()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
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
	var/bomb_armor = getarmor(null, "bomb")
	if(istype(ex_target, /datum/spacevine_mutation) && isvineimmune(src))
		return

	switch (severity)
		if (1)
			b_loss += 500
			if (prob(bomb_armor))
				shred_clothing(1,150)
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			else
				gib()
				return

		if (2)
			b_loss += 60

			f_loss += 60
			if (prob(bomb_armor))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5
				shred_clothing(1,25)
			else
				shred_clothing(1,50)

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			if (prob(70))
				Paralyse(10)

		if(3)
			b_loss += 30
			if (prob(bomb_armor))
				b_loss = b_loss/2
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			if (prob(50))
				Paralyse(10)

	take_overall_damage(b_loss,f_loss)
	//attempt to dismember bodyparts
	if(severity <= 2 || !bomb_armor)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && !prob(getarmor(BP, "bomb")) && BP.body_zone != "head" && BP.body_zone != "chest")
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break
	..()

/mob/living/carbon/human/blob_act(obj/effect/blob/B)
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))
	return

/mob/living/carbon/human/bullet_act()
	if(martial_art && martial_art.deflection_chance) //Some martial arts users can deflect projectiles!
		if(!prob(martial_art.deflection_chance))
			return ..()
		if(!src.lying && dna && !dna.check_mutation(HULK)) //But only if they're not lying down, and hulks can't do it
			src.visible_message("<span class='danger'>[src] deflects the projectile; they can't be hit with ranged weapons!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
			playsound(src, pick("sound/weapons/bulletflyby.ogg","sound/weapons/bulletflyby2.ogg","sound/weapons/bulletflyby3.ogg"), 75, 1)
			return 0
	..()

/mob/living/carbon/human/attack_ui(slot)
	if(!get_bodypart(hand ? "l_arm" : "r_arm"))
		return 0
	return ..()

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

	if((w_uniform == null && !(dna && dna.species.nojumpsuit)) || (slot_w_uniform in obscured))
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
/mob/living/carbon/human/Crossed(atom/movable/AM)
	var/mob/living/simple_animal/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

	spreadFire(AM)

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0)
	if(tesla_shock)
		var/total_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			if(G.siemens_coefficient <= 0)
				total_coeff -= 0.5
		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			if(S.siemens_coefficient <= 0)
				total_coeff -= 0.95
		siemens_coeff = total_coeff
	else if(!safety)
		var/gloves_siemens_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			gloves_siemens_coeff = G.siemens_coefficient
		siemens_coeff = gloves_siemens_coeff
	if(heart_attack)
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			heart_attack = 0
			if(stat == CONSCIOUS)
				src << "<span class='notice'>You feel your heart beating again!</span>"
	. = ..(shock_damage,source,siemens_coeff,safety,override,tesla_shock)
	if(.)
		electrocution_animation(40)



/mob/living/carbon/human/Topic(href, href_list)
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))

		if(href_list["embedded_object"])
			var/obj/item/I = locate(href_list["embedded_object"])
			var/obj/item/bodypart/L = locate(href_list["embedded_limb"])
			if(!I || !L || I.loc != src || !(I in L.embedded_objects)) //no item, no limb, or item is not in limb or in the person anymore
				return
			var/time_taken = I.embedded_unsafe_removal_time*I.w_class
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from their [L.name].</span>","<span class='notice'>You attempt to remove [I] from your [L.name]... (It will take [time_taken/10] seconds.)</span>")
			if(do_after(usr, time_taken, needhand = 1, target = src))
				if(!I || !L || I.loc != src || !(I in L.embedded_objects))
					return
				L.embedded_objects -= I
				L.take_damage(I.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
				I.loc = get_turf(src)
				usr.put_in_hands(I)
				usr.emote("scream")
				usr.visible_message("[usr] successfully rips [I] out of their [L.name]!","<span class='notice'>You successfully remove [I] from your [L.name].</span>")
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
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

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
					if(pocket_item == (pocket_id == slot_r_store ? r_store : l_store)) //item still in the pocket we search
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
						if(!H.canUseHUD())
							return
						else if(!istype(H.glasses, /obj/item/clothing/glasses/hud))
							return
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
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health))
									return
								if(health && health != "Cancel")
									R.fields["p_stat"] = health
							return
						if(href_list["m_stat"])
							var/health = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
							if(R)
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health))
									return
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
								for(var/X in bodyparts)
									var/obj/item/bodypart/BP = X
									var/brutedamage = BP.brute_dam
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
										usr << "<span class='[span]'>[BP] appears to have [status]</span>"
							if(getFireLoss())
								usr << "<b>Analysis of skin burns:</b>"
								for(var/X in bodyparts)
									var/obj/item/bodypart/BP = X
									var/burndamage = BP.burn_dam
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
										usr << "<span class='[span]'>[BP] appears to have [status]</span>"
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
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security))
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
												var/t1 = stripped_input("Please input minor crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input minor crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access)
														return
													else if(!H.canUseHUD())
														return
													else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security))
														return
													var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													data_core.addMinorCrime(R.fields["id"], crime)
													usr << "<span class='notice'>Successfully added a minor crime.</span>"
													return
										if("Major Crime")
											if(R)
												var/t1 = stripped_input("Please input major crime names:", "Security HUD", "", null)
												var/t2 = stripped_multiline_input("Please input major crime details:", "Security HUD", "", null)
												if(R)
													if (!t1 || !t2 || !allowed_access)
														return
													else if (!H.canUseHUD())
														return
													else if (!istype(H.glasses, /obj/item/clothing/glasses/hud/security))
														return
													var/crime = data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													data_core.addMajorCrime(R.fields["id"], crime)
													usr << "<span class='notice'>Successfully added a major crime.</span>"
									return

								if(href_list["view_comment"])
									if(R)
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security))
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
										var/t1 = stripped_multiline_input("Add Comment:", "Secure. records", null, null)
										if(R)
											if (!t1 || !allowed_access)
												return
											else if(!H.canUseHUD())
												return
											else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security))
												return
											var/counter = 1
											while(R.fields[text("com_[]", counter)])
												counter++
											R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, worldtime2text(), time2text(world.realtime, "MMM DD"), year_integer+540, t1,)
											usr << "<span class='notice'>Successfully added comment.</span>"
											return
							usr << "<span class='warning'>Unable to locate a data core entry for this person.</span>"

/mob/living/carbon/human/proc/canUseHUD()
	return !(src.stat || src.weakened || src.stunned || src.restrained())

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, var/penetrate_thick = 0)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_selected
	if(dna && (PIERCEIMMUNE in dna.species.specflags))
		. = 0
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if(above_neck(target_zone))
		if(head && head.flags & THICKMATERIAL && !penetrate_thick)
			. = 0
	else
		if(wear_suit && wear_suit.flags & THICKMATERIAL && !penetrate_thick)
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

	if(wear_mask)
		if(wear_mask.flags_inv & HIDEEYES)
			obscured |= slot_glasses

	if(obscured.len > 0)
		return obscured
	else
		return null

/mob/living/carbon/human/assess_threat(mob/living/simple_animal/bot/secbot/judgebot, lasercolor)
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

	//mindshield implants imply trustworthyness
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
	update_body()
	update_hair()

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
	rad_act(current_size * 3)
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

			var/list/missing = list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg")
			for(var/X in bodyparts)
				var/obj/item/bodypart/LB = X
				missing -= LB.body_zone
				var/status = ""
				var/brutedamage = LB.brute_dam
				var/burndamage = LB.burn_dam
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
				src << "\t [status == "OK" ? "\blue" : "\red"] Your [LB.name] is [status]."

				for(var/obj/item/I in LB.embedded_objects)
					src << "\t <a href='byond://?src=\ref[src];embedded_object=\ref[I];embedded_limb=\ref[LB]'>\red There is \a [I] embedded in your [LB.name]!</a>"

			for(var/t in missing)
				src << "<span class='boldannounce'>Your [parse_zone(t)] is missing!</span>"

			if(bleed_rate)
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
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (C.status_flags & FAKEDEATH))
		src << "<span class='warning'>[C.name] is dead!</span>"
		return
	if(is_mouth_covered())
		src << "<span class='warning'>Remove your mask first!</span>"
		return 0
	if(C.is_mouth_covered())
		src << "<span class='warning'>Remove their mask first!</span>"
		return 0

	if(C.cpr_time < world.time + 30)
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>You try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_mob(src, C))
			src << "<span class='warning'>You fail to perform CPR on [C]!</span>"
			return 0

		var/they_breathe = (!(NOBREATH in C.dna.species.specflags))
		var/they_lung = C.getorganslot("lungs")

		if(C.health > config.health_threshold_crit)
			return

		src.visible_message("[src] performs CPR on [C.name]!", "<span class='notice'>You perform CPR on [C.name].</span>")
		C.cpr_time = world.time
		add_logs(src, C, "CPRed")

		if(they_breathe && they_lung)
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			C << "<span class='unconscious'>You feel a breath of fresh air enter your lungs... It feels good...</span>"
		else if(they_breathe && !they_lung)
			C << "<span class='unconscious'>You feel a breath of fresh air... \
				but you don't feel any better...</span>"
		else
			C << "<span class='unconscious'>You feel a breath of fresh air... \
				which is a sensation you don't recognise...</span>"

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

	staticOverlay = getRandomAnimalImage(src)
	staticOverlay.override = 1
	staticOverlays["animal"] = staticOverlay

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(dna && dna.check_mutation(HULK))
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(..(I, cuff_break = FAST_CUFFBREAK))
			unEquip(I)
	else
		if(..())
			unEquip(I)

/mob/living/carbon/human/clean_blood()
	var/mob/living/carbon/human/H = src
	if(H.gloves)
		if(H.gloves.clean_blood())
			H.update_inv_gloves()
	else
		..() // Clear the Blood_DNA list
		if(H.bloody_hands)
			H.bloody_hands = 0
			H.update_inv_gloves()
	update_icons()	//apply the now updated overlays to the mob


/mob/living/carbon/human/wash_cream()
	//clean both to prevent a rare bug
	overlays -=image('icons/effects/creampie.dmi', "creampie_lizard")
	overlays -=image('icons/effects/creampie.dmi', "creampie_human")


//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//Handle mutant parts if possible
	if(dna && dna.species)
		add_overlay("electrocuted_base")
		spawn(anim_duration)
			if(src)
				overlays -= "electrocuted_base"

	else //or just do a generic animation
		var/list/viewing = list()
		for(var/mob/M in viewers(src))
			if(M.client)
				viewing += M.client
		flick_overlay(image(icon,src,"electrocuted_generic",ABOVE_MOB_LAYER), viewing, anim_duration)

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close = 0)
	if(incapacitated() || lying )
		return
	if(!Adjacent(M) && (M.loc != src))
		if((be_close == 0) && (dna.check_mutation(TK)))
			if(tkMaxRangeCheck(src, M))
				return 1
		return
	return 1

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/replace_records_name(oldname,newname) // Only humans have records right now, move this up if changed.
	for(var/list/L in list(data_core.general,data_core.medical,data_core.security,data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

/mob/living/carbon/human/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	dna.species.update_sight(src)

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		. += glasses.tint

/mob/living/carbon/human/update_health_hud()
	if(!client || !hud_used)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(hud_used.healths)
			var/health_amount = health - staminaloss
			if(..(health_amount)) //not dead
				switch(hal_screwyhud)
					if(1)
						hud_used.healths.icon_state = "health6"
					if(2)
						hud_used.healths.icon_state = "health7"
					if(5)
						hud_used.healths.icon_state = "health0"
		if(hud_used.healthdoll)
			hud_used.healthdoll.cut_overlays()
			if(stat != DEAD)
				hud_used.healthdoll.icon_state = "healthdoll_OVERLAY"
				for(var/X in bodyparts)
					var/obj/item/bodypart/BP = X
					var/damage = BP.burn_dam + BP.brute_dam
					var/comparison = (BP.max_damage/5)
					var/icon_num = 0
					if(damage)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					if(hal_screwyhud == 5)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(image('icons/mob/screen_gen.dmi',"[BP.body_zone][icon_num]"))
				for(var/t in get_missing_limbs()) //Missing limbs
					hud_used.healthdoll.add_overlay(image('icons/mob/screen_gen.dmi',"[t]6"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"

/mob/living/carbon/human/fully_heal(admin_revive = 0)
	CHECK_DNA_AND_SPECIES(src)

	if(admin_revive)
		regenerate_limbs()

		if(!(NOBREATH in dna.species.specflags) && !getorganslot("lungs"))
			var/obj/item/organ/lungs/L = new()
			L.Insert(src)

		if(!(NOBLOOD in dna.species.specflags) && !getorganslot("heart"))
			var/obj/item/organ/heart/H = new()
			H.Insert(src)

		if(!getorganslot("tongue"))
			var/obj/item/organ/tongue/T

			for(var/tongue_type in dna.species.mutant_organs)
				if(ispath(tongue_type, /obj/item/organ/tongue))
					T = new tongue_type()
					T.Insert(src)

			// if they have no mutant tongues, give them a regular one
			if(!T)
				T = new()
				T.Insert(src)

	remove_all_embedded_objects()
	drunkenness = 0
	for(var/datum/mutation/human/HM in dna.mutations)
		if(HM.quality != POSITIVE)
			dna.remove_mutation(HM.name)
	..()

/mob/living/carbon/human/proc/influenceSin()
	var/datum/objective/sintouched/O
	switch(rand(1,7))//traditional seven deadly sins... except lust.
		if(1) // acedia
			log_game("[src] was influenced by the sin of Acedia.")
			O = new /datum/objective/sintouched/acedia
		if(2) // Gluttony
			log_game("[src] was influenced by the sin of gluttony.")
			O = new /datum/objective/sintouched/gluttony
		if(3) // Greed
			log_game("[src] was influenced by the sin of greed.")
			O = new /datum/objective/sintouched/greed
		if(4) // sloth
			log_game("[src] was influenced by the sin of sloth.")
			O = new /datum/objective/sintouched/sloth
		if(5) // Wrath
			log_game("[src] was influenced by the sin of wrath.")
			O = new /datum/objective/sintouched/wrath
		if(6) // Envy
			log_game("[src] was influenced by the sin of envy.")
			O = new /datum/objective/sintouched/envy
		if(7) // Pride
			log_game("[src] was influenced by the sin of pride.")
			O = new /datum/objective/sintouched/pride
	ticker.mode.sintouched += src.mind
	src.mind.objectives += O
	var/obj_count = 1
	src << "<span class='notice'>Your current objectives:</span>"
	for(O in src.mind.objectives)
		var/datum/objective/objective = O
		src << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	. = ..()
	if (dna && dna.species)
		. += dna.species.check_weakness(weapon, attacker)

/mob/living/carbon/human/is_literate()
	return 1

/mob/living/carbon/human/can_hold_items()
	return TRUE

/mob/living/carbon/human/update_gravity(has_gravity,override = 0)
	override = dna.species.override_float
	..()
=======

/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	can_butcher = 0
	var/list/hud_list[9]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/manifested
	real_name = "Manifested Ghost"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/manifested/New(var/new_loc, delay_ready_dna = 0)
	underwear = 0
	..(new_loc, "Manifested")

/mob/living/carbon/human/skrell/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Skrell Male Tentacles"
	..(new_loc, "Skrell")

/mob/living/carbon/human/tajaran/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")

/mob/living/carbon/human/unathi/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Unathi Horns"
	..(new_loc, "Unathi")

/mob/living/carbon/human/vox/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Short Vox Quills"
	..(new_loc, "Vox")

/mob/living/carbon/human/diona/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Diona")

/mob/living/carbon/human/skellington/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Skellington", delay_ready_dna)

/mob/living/carbon/human/skelevox/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Skeletal Vox")

/mob/living/carbon/human/plasma/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Plasmaman")

/mob/living/carbon/human/muton/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Muton")

/mob/living/carbon/human/grey/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Grey")

/mob/living/carbon/human/golem/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Golem")
	gender = NEUTER
	meat_type = /obj/item/weapon/ore/diamond

/mob/living/carbon/human/frankenstein/New(var/new_loc, delay_ready_dna = 0) //Just fuck my shit up: the mob
	f_style = pick(facial_hair_styles_list)
	h_style = pick(hair_styles_list)

	var/list/valid_species = (all_species - list("Krampus", "Horror"))

	var/datum/species/new_species = all_species[pick(valid_species)]
	..(new_loc, new_species.name)
	gender = pick(MALE, FEMALE, NEUTER, PLURAL)
	meat_type = pick(typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))

	for(var/datum/organ/external/E in organs)
		E.species = all_species[pick(valid_species)]

	update_body()

/mob/living/carbon/human/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	static_overlays.Add(list("static", "blank", "letter"))
	var/image/static_overlay = image(icon('icons/effects/effects.dmi', "static"), loc = src)
	static_overlay.override = 1
	static_overlays["static"] = static_overlay

	static_overlay = image(icon('icons/effects/effects.dmi', "blank_human"), loc = src)
	static_overlay.override = 1
	static_overlays["blank"] = static_overlay

	static_overlay = getLetterImage(src, "H", 1)
	static_overlay.override = 1
	static_overlays["letter"] = static_overlay

/mob/living/carbon/human/New(var/new_loc, var/new_species_name = null, var/delay_ready_dna=0)
	if(!hair_styles_list.len) buildHairLists()
	if(!all_species.len) buildSpeciesLists()

	if(new_species_name)
		s_tone = random_skin_tone(new_species_name)

	if(!src.species)
		if(new_species_name)	src.set_species(new_species_name)
		else					src.set_species()

	default_language = get_default_language()

	create_reagents(1000)

	if(!dna)
		dna = new /datum/dna(null)
		dna.species=species.name
		dna.b_type = random_blood_type()

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	obj_overlays[FIRE_LAYER]		= getFromPool(/obj/Overlays/fire_layer)
	obj_overlays[MUTANTRACE_LAYER]	= getFromPool(/obj/Overlays/mutantrace_layer)
	obj_overlays[MUTATIONS_LAYER]	= getFromPool(/obj/Overlays/mutations_layer)
	obj_overlays[DAMAGE_LAYER]		= getFromPool(/obj/Overlays/damage_layer)
	obj_overlays[UNIFORM_LAYER]		= getFromPool(/obj/Overlays/uniform_layer)
	obj_overlays[ID_LAYER]			= getFromPool(/obj/Overlays/id_layer)
	obj_overlays[SHOES_LAYER]		= getFromPool(/obj/Overlays/shoes_layer)
	obj_overlays[GLOVES_LAYER]		= getFromPool(/obj/Overlays/gloves_layer)
	obj_overlays[EARS_LAYER]		= getFromPool(/obj/Overlays/ears_layer)
	obj_overlays[SUIT_LAYER]		= getFromPool(/obj/Overlays/suit_layer)
	obj_overlays[GLASSES_LAYER]		= getFromPool(/obj/Overlays/glasses_layer)
	obj_overlays[BELT_LAYER]		= getFromPool(/obj/Overlays/belt_layer)
	obj_overlays[SUIT_STORE_LAYER]	= getFromPool(/obj/Overlays/suit_store_layer)
	obj_overlays[BACK_LAYER]		= getFromPool(/obj/Overlays/back_layer)
	obj_overlays[HAIR_LAYER]		= getFromPool(/obj/Overlays/hair_layer)
	obj_overlays[GLASSES_OVER_HAIR_LAYER] = getFromPool(/obj/Overlays/glasses_over_hair_layer)
	obj_overlays[FACEMASK_LAYER]	= getFromPool(/obj/Overlays/facemask_layer)
	obj_overlays[HEAD_LAYER]		= getFromPool(/obj/Overlays/head_layer)
	obj_overlays[HANDCUFF_LAYER]	= getFromPool(/obj/Overlays/handcuff_layer)
	obj_overlays[LEGCUFF_LAYER]		= getFromPool(/obj/Overlays/legcuff_layer)
	obj_overlays[HAND_LAYER]		= getFromPool(/obj/Overlays/hand_layer)
	obj_overlays[TAIL_LAYER]		= getFromPool(/obj/Overlays/tail_layer)
	obj_overlays[TARGETED_LAYER]	= getFromPool(/obj/Overlays/targeted_layer)

	..()

	if(dna)
		dna.real_name = real_name

	prev_gender = gender // Debug for plural genders
	make_blood()
	init_butchering_list() // While animals only generate list of their teeth/skins on death, humans generate it when they're born.

	// Set up DNA.
	if(!delay_ready_dna)
		dna.ready_dna(src)

	if(hardcore_mode_on)
		spawn(2 SECONDS)
			//Hardcore mode stuff
			//Warn the player that not eating will lead to his death
			if(eligible_for_hardcore_mode(src))
				to_chat(src, "<h5><span class='notice'>Hardcore mode is enabled!</span></h5>")
				to_chat(src, "<b>You must eat to survive. Starvation for extended periods of time will kill you!</b>")
				to_chat(src, "<b>Keep an eye out on the hunger indicator on the right of your screen; it will start flashing red and black when you're close to starvation.</b>")

/mob/living/carbon/human/player_panel_controls()
	var/html=""

	// TODO: Loop through contents and call parasite_panel or something.
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		html +="<h2>Borer:</h2> [B] ("
		if(B.controlling)
			html += "<a style='color:red;font-weight:bold;' href='?src=\ref[B]&act=release'>Controlling</a>"
		else if(B.host_brain.ckey)
			html += "<a style='color:red;font-weight:bold;' href='?src=\ref[B]&act=release'>!HOST BRAIN BUGGED!</a>"
		else
			html += "Not Controlling"
		html += " | <a href='?src=\ref[B]&act=detach'>Detach</a>"
		html += " | <a href='?_src_=holder;adminmoreinfo=\ref[B]'>?</a> | <a href='?_src_=vars;mob_player_panel=\ref[B]'>PP</a>"
		html += ")"

	return html

/mob/living/carbon/human/Stat()
	..()

	if(statpanel("Status"))
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

		if (internal)
			if (!internal.air_contents)
				qdel(internal)
				internal = null
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", mind.changeling.chem_charges)
				stat("Genetic Damage Time", mind.changeling.geneticdamage)

		if(istype(loc, /obj/spacepod)) // Spacdpods!
			var/obj/spacepod/S = loc
			stat("Spacepod Charge", "[istype(S.battery) ? "[(S.battery.charge / S.battery.maxcharge) * 100]" : "No cell detected"]")
			stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
		if(!iscarbon(M))
			LAssailant = null
		else
			LAssailant = M
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		add_logs(M, src, "attacked", admin=0)

		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)

		if(M.zone_sel && M.zone_sel.selecting)
			dam_zone = M.zone_sel.selecting

		if(check_shields(damage)) //Shield check
			return

		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee") //Armor check

		apply_damage(damage, M.melee_damage_type, affecting, armor)
		src.visible_message("<span class='danger'>[M] [M.attacktext] [src] in \the [affecting.display_name]!</span>")


/mob/living/carbon/human/proc/is_loyalty_implanted(mob/living/carbon/human/M)
	for(var/L in M.contents)
		if(istype(L, /obj/item/weapon/implant/loyalty))
			for(var/datum/organ/external/O in M.organs)
				if(L in O.implants)
					return 1
	return 0

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("<span class='danger'>The [M.name] glomps []!</span>", src), 1)
		add_logs(M, src, "glomped on", 0)
		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/slime/adult))
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick(LIMB_HEAD, LIMB_CHEST, LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_GROIN)

		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
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

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>The [M.name] has shocked []!</span>", src), 1)

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


/mob/living/carbon/human/restrained()
	if (timestopped)
		return 1 //under effects of time magick
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0



/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75 //but why is this here

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOverCreature(src,species.blood_color)
	else
		var/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate/WC = AM
		if(istype(WC))
			WC.crush(src,species.blood_color)
		else
			return //Don't make blood
	var/obj/effect/decal/cleanable/blood/B = getFromPool(/obj/effect/decal/cleanable/blood, get_turf(src))
	B.basecolor = species.blood_color
	B.update_icon()
	B.New(B.loc)
	B.blood_DNA = list()
	B.blood_DNA[src.dna.unique_enzymes] = src.dna.b_type

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return
//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return
//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if( wear_mask && (is_slot_hidden(wear_mask.body_parts_covered,HIDEFACE)) && !istype(wear_mask,/obj/item/clothing/mask/gas/golem))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (is_slot_hidden(head.body_parts_covered,HIDEFACE)))
		return get_id_name("Unknown")	//Likewise for hats
	if(mind && mind.vampire && (VAMP_SHADOW in mind.vampire.powers) && mind.vampire.ismenacing)
		return get_id_name("Unknown")
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name
//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/organ/external/head/head_organ = get_organ(LIMB_HEAD)
	if((wear_mask && (is_slot_hidden(wear_mask.body_parts_covered,HIDEFACE)) && !istype(wear_mask,/obj/item/clothing/mask/gas/golem)) || ( head && (is_slot_hidden(head.body_parts_covered,HIDEFACE))) || !head_organ || head_organ.disfigured || (head_organ.status & ORGAN_DESTROYED) || !real_name || (M_HUSK in mutations) )	//Wearing a mask which hides our face, use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	if(wear_id)
		. = wear_id.get_owner_name_from_ID()
	if(!.)
		return if_no_id

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE || M_NO_SHOCK in src.mutations)	return 0	//godmode

	if (!def_zone)
		def_zone = pick(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)

	var/datum/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)

/mob/living/carbon/human/hear_radio_only()
	if(!ears) return 0
	return is_on_ears(/obj/item/device/radio/headset/headset_earmuffs)

/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/pickpocket = usr.isGoodPickpocket()
	var/list/obscured = check_obscured_slots()
	var/dat

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"
	dat += "<BR>"
	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"
	if(slot_wear_mask in obscured)
		dat += "<BR><font color=grey><B>Mask:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"
	if(slot_glasses in obscured)
		dat += "<BR><font color=grey><B>Eyes:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Eyes:</B> <A href='?src=\ref[src];item=[slot_glasses]'>[makeStrippingButton(glasses)]</A>"
	if(slot_ears in obscured)
		dat += "<BR><font color=grey><B>Ears:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Ears:</B> <A href='?src=\ref[src];item=[slot_ears]'>[makeStrippingButton(ears)]</A>"
	dat += "<BR>"
	dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[slot_wear_suit]'>[makeStrippingButton(wear_suit)]</A>"
	if(wear_suit)
		dat += "<BR>[HTMLTAB]&#8627;<B>Suit Storage:</B> <A href='?src=\ref[src];item=[slot_s_store]'>[makeStrippingButton(s_store)]</A>"
	if(slot_shoes in obscured)
		dat += "<BR><font color=grey><B>Shoes:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=[slot_shoes]'>[makeStrippingButton(shoes)]</A>"
	if(slot_gloves in obscured)
		dat += "<BR><font color=grey><B>Gloves:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=[slot_gloves]'>[makeStrippingButton(gloves)]</A>"
	if(slot_w_uniform in obscured)
		dat += "<BR><font color=grey><B>Uniform:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(w_uniform)]</A>"
		if(w_uniform)
			dat += "<BR>[HTMLTAB]&#8627;<B>Suit Sensors:</B> <A href='?src=\ref[src];sensors=1'>Set</A>"
	if(w_uniform)
		dat += "<BR>[HTMLTAB]&#8627;<B>Belt:</B> <A href='?src=\ref[src];item=[slot_belt]'>[makeStrippingButton(belt)]</A>"
		if(pickpocket)
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
		else
			dat += "<BR>[HTMLTAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
		dat += "<BR>[HTMLTAB]&#8627;<B>ID:</B> <A href='?src=\ref[src];id=1'>[makeStrippingButton(wear_id)]</A>"
	dat += "<BR>"
	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"
	if(legcuffed)
		dat += "<BR><B>Legcuffed:</B> <A href='?src=\ref[src];item=[slot_legcuffed]'>Remove</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/human/Topic(href, href_list)
	..() //Slot stripping, hand stripping, and internals setting in /mob/living/carbon/Topic()
	if(href_list["id"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_id(usr)

	else if(href_list["pockets"]) //href_list "pockets" would be "left" or "right"
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_pocket(usr, href_list["pockets"])

	else if(href_list["sensors"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		toggle_sensors(usr)

	else if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	else if (href_list["criminal"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/modified

			if(wear_id)
				var/obj/item/weapon/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											hud_updateflag |= 1 << WANTED_HUD
											if(istype(usr,/mob/living/carbon/human))
												var/mob/living/carbon/human/U = usr
												U.handle_regular_hud_updates()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Sec. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
	else if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")
							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.len = 0
									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()
			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")
			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")
	else if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = copytext(sanitize(input("Add Comment:", "Med. records", null, null)  as message),1,MAX_MESSAGE_LEN)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
		//else if(!. && error_msg && user)
//			to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on their head" : "on their body"].</span>")
	else if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		usr.examination(I)
	/*else if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		usr.examination(M)*/

/**
 * Returns a number between -1 to 2.
 * TODO: What's the default return value?
 */
/mob/living/carbon/human/eyecheck()
	. = 0
	var/obj/item/clothing/head/headwear = src.head
	var/obj/item/clothing/glasses/eyewear = src.glasses
	var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]

	if (istype(headwear))
		. += headwear.eyeprot

	if (istype(eyewear))
		. += eyewear.eyeprot

	if(E)
		. += E.eyeprot

	return Clamp(., -1, 2)


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such

/mob/living/carbon/human/isGoodPickpocket()
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		return G.pickpocket

/mob/living/carbon/human/abiotic(var/full_body = 0)
	for(var/obj/item/I in held_items)
		if(I.abstract) continue

		return 1

	if(full_body)
		for(var/obj/item/I in get_all_slots())
			return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	if(dna && dna.mutantrace == "golem")
		return "Animated Construct"

	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>[src] begins playing \his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='notice'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/vomit(hairball = 0, instant = 0)
	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<spawn class='warning'>You feel nauseous...</span>")

		spawn((instant ? 0 : 150))	//15 seconds until second warning
			to_chat(src, "<spawn class='danger'>You feel like you are about to throw up!</span>")

			sleep((instant ? 0 : 100))	//And you have 10 more seconds to move it to the bathrooms

			Stun(5)

			var/turf/location = loc
			var/spawn_vomit_on_floor = 0

			if(hairball)
				src.visible_message("<span class='warning'>[src] hacks up a hairball!</span>","<span class='danger'>You hack up a hairball!</span>")

			else
				var/skip_message = 0

				var/obj/structure/toilet/T = locate(/obj/structure/toilet) in location //Look for a toilet
				if(T && T.open)
					src.visible_message("<span class='warning'>[src] throws up into \the [T]!</span>", "<span class='danger'>You throw up into \the [T]!</span>")
					skip_message = 1
				else //Look for a bucket

					for(var/obj/item/weapon/reagent_containers/glass/G in (location.contents + src.get_active_hand() + src.get_inactive_hand()))
						if(!G.reagents) continue
						if(!G.is_open_container()) continue

						src.visible_message("<span class='warning'>[src] throws up into \the [G]!</span>", "<span class='danger'>You throw up into \the [G]!</span>")

						if(G.reagents.total_volume <= G.reagents.maximum_volume-7) //Container can fit 7 more units of chemicals - vomit into it
							G.reagents.add_reagent(VOMIT, rand(3,10))
							if(src.reagents) reagents.trans_to(G, 1 + reagents.total_volume * 0.1)
						else //Container is nearly full - fill it to the brim with vomit and spawn some more on the floor
							G.reagents.add_reagent(VOMIT, 10)
							spawn_vomit_on_floor = 1
							to_chat(src, "<span class='warning'>\The [G] overflows!</span>")

						skip_message = 1

						break

				if(!skip_message)
					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='danger'>You throw up!</span>")
					spawn_vomit_on_floor = 1

			playsound(get_turf(loc), 'sound/effects/splat.ogg', 50, 1)

			if(spawn_vomit_on_floor)
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1, (hairball ? 0 : 1), 1)

			if(!hairball)
				nutrition = max(nutrition-40,0)
				adjustToxLoss(-3)

			sleep((instant ? 0 : 350))	//Wait 35 seconds before next volley

			lastpuke = 0

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Mutant Abilities"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(M_MORPH in mutations))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation",rgb(r_facial,g_facial,b_facial)) as color
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation",rgb(r_hair,g_hair,b_hair)) as color
	if(new_facial)
		r_hair = hex2num(copytext(new_hair, 2, 4))
		g_hair = hex2num(copytext(new_hair, 4, 6))
		b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation",rgb(r_eyes,g_eyes,b_eyes)) as color
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", "[35-s_tone]")  as text

	if (!new_tone)
		new_tone = 35
	s_tone = max(min(round(text2num(new_tone)), 220), 1)
	s_tone =  -s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done
		H = null

	var/new_style = input("Please select hair style", "Character Generation",h_style)  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)
		H = null

	new_style = input("Please select facial style", "Character Generation",f_style)  as null|anything in fhairs

	if(new_style)
		f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			setGender(MALE)
		else
			setGender(FEMALE)
	regenerate_icons()
	check_dna()

	visible_message("<span class='notice'>\The [src] morphs and changes [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] appearance!</span>", "<span class='notice'>You change your appearance!</span>", "<span class='warning'>Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!</span>")
/mob/living/carbon/human/proc/can_mind_interact(var/mob/M)
//	to_chat(world, "Starting can interact on [M]")
	if(!ishuman(M)) return 0 //Can't see non humans with your fancy human mind.
//	to_chat(world, "[M] is a human")
	var/turf/temp_turf = get_turf(M)
	var/turf/our_turf = get_turf(src)
	if(!temp_turf)
//		to_chat(world, "[M] is in null space")
		return 0
	if((temp_turf.z != our_turf.z) || M.stat!=CONSCIOUS) //Not on the same zlevel as us or they're dead.
//		to_chat(world, "[(temp_turf.z != our_turf.z) ? "not on the same zlevel as [M]" : "[M] is not concious"]")
		if(temp_turf.z != 2)
			to_chat(src, "The mind of [M] is too faint...")//Prevent "The mind of Admin is too faint..."


		return 0
	if(M_PSY_RESIST in M.mutations)
//		to_chat(world, "[M] has psy resist")
		to_chat(src, "The mind of [M] is resisting!")
		return 0
	var/mob/living/carbon/human/H = M
	if(H.head && istype(H.head,/obj/item/clothing/head/tinfoil))
		to_chat(src, "Interference is disrupting the connection with the mind of [M].")
		return 0
	return 1

/mob/living/carbon/human/can_wield()
	return 1

/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT) && ((is_slot_hidden(head.body_parts_covered,HIDEMASK)) || is_slot_hidden(wear_mask.body_parts_covered,HIDEMASK)))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()
	for (var/datum/organ/external/O in organs)
		O.status &= ~ORGAN_BROKEN
		O.status &= ~ORGAN_BLEEDING
		O.status &= ~ORGAN_SPLINTED
		O.status &= ~ORGAN_CUT_AWAY
		O.status &= ~ORGAN_ATTACHABLE
		if (!O.amputated)
			O.status &= ~ORGAN_DESTROYED
			O.destspawn = 0
		O.wounds.len = 0
		O.heal_damage(1000,1000,1,1)

	var/datum/organ/external/head/h = organs_by_name[LIMB_HEAD]
	h.disfigured = 0

	if(species && !(species.flags & NO_BLOOD))
		vessel.add_reagent(BLOOD,560-vessel.total_volume)
		fixblood()

	var/datum/organ/internal/brain/BBrain = internal_organs_by_name["brain"]
	if(!BBrain)
		var/obj/item/weapon/organ/head/B = decapitated
		if(B)
			var/datum/organ/internal/brain/copied
			if(B.organ_data)
				var/datum/organ/internal/I = B.organ_data
				copied = I.Copy()
			else
				copied = new
			copied.owner = src
			internal_organs_by_name["brain"] = copied
			internal_organs += copied

			var/datum/organ/external/affected = get_organ(LIMB_HEAD)
			affected.internal_organs += copied
			affected.status = 0
			affected.amputated = 0
			affected.destspawn = 0
			update_body()
			updatehealth()
			UpdateDamageIcon()

			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			if(B.borer)
				B.borer.perform_infestation(src)
				B.borer=null

			decapitated = null

			qdel(B)

	for(var/datum/organ/internal/I in internal_organs)
		I.damage = 0

	for (var/datum/disease/virus in viruses)
		virus.cure()
	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
	return L && L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]

	if(L && !L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	//set background = 1
	var/damage = input("Wound damage","Wound damage") as num
	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		diary << "VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]"
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			to_chat(world, "Reached stage 1 in [ticks] ticks")
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			to_chat(world, "Reached stage 2 in [ticks] ticks")
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			to_chat(world, "Reached stage 3 in [ticks] ticks")
	to_chat(world, "Mob took [tdamage] tox damage")
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	if(!M)
		return
	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	src.update_inv_gloves()	//handles bloody hands overlays and updating
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()
	if(clean_feet && !shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		feet_blood_DNA.len = 0
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || (usr.client && usr.client.move_delayer.blocked()))
		return
	usr.delayNextMove(20)

	if(usr.isUnconscious())
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/list/valid_objects = list()
	var/datum/organ/external/affected = null
	var/mob/living/carbon/human/S = src
	var/mob/living/carbon/human/U = usr
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(1)

	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your wounds that is large enough to remove without surgery.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove without surgery.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	for(var/datum/organ/external/organ in organs) //Grab the organ holding the implant.
		for(var/obj/item/weapon/O in organ.implants)
			if(O == selection)
				affected = organ
	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on the [selection] in your [affected.display_name] with bloody fingers.</span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s [affected.display_name] with bloody fingers.</span>")

	if(istype(U,/mob/living/carbon/human/)) U.bloody_hands(S)

	if(!do_after(U, src, 80))
		return

	if(!selection || !affected || !S || !U)
		return

	if(self)
		visible_message("<span class='danger'><b>[src] rips [selection] out of their [affected.display_name] in a welter of blood.</b></span>","<span class='warning'>You rip [selection] out of your [affected] in a welter of blood.</span>")
	else
		visible_message("<span class='danger'><b>[usr] rips [selection] out of [src]'s [affected.display_name] in a welter of blood.</b></span>","<span class='warning'>[usr] rips [selection] out of your [affected] in a welter of blood.</span>")

	selection.loc = get_turf(src)
	affected.implants -= selection
	shock_stage+=10

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0

	if(prob(10)) //I'M SO ANEMIC I COULD JUST -DIE-.
		var/datum/wound/internal_bleeding/I = new (15)
		affected.wounds += I
		custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 1)
	return 1

/mob/living/carbon/human/proc/get_visible_implants(var/class = 0)


	var/list/visible_implants = list()
	for(var/datum/organ/external/organ in src.organs)
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && (O.w_class > class) && !istype(O,/obj/item/weapon/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/generate_name()
	name = species.makeName(gender,src)
	real_name = name
	return name

/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/datum/organ/external/organ in src.organs)
		if(organ.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [organ.display_name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [organ.display_name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [organ.display_name] twists painfully as you move.</span>"
				to_chat(src, msg)

				organ.take_damage(rand(1,3), 0, 0)
				if(!(organ.status & (ORGAN_ROBOT|ORGAN_PEG))) //There is no blood in protheses.
					organ.status |= ORGAN_BLEEDING
					src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.isUnconscious() || usr.restrained() || !isliving(usr) || isanimal(usr) || isAI(usr)) return

	if(usr == src)
		self = 1

	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.</span>",\
		"<span class='info'>You begin counting [src]'s pulse.</span>")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"<span class='info'>You begin counting your pulse.</span>")

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'>[self ? "You have" : "[src] has"] no pulse!</span>")
		return

	to_chat(usr, "<span class='info'>Don't move until counting is finished.</span>")

	if (do_mob(usr, src, 60))
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")
	else
		to_chat(usr, "<span class='info'>You moved while counting. Try again.</span>")

/mob/living/carbon/human/proc/set_species(var/new_species_name, var/force_organs, var/default_colour)


	if(new_species_name)
		if(src.species && src.species.name && (src.species.name == new_species_name)) return
	else if(src.dna)	new_species_name = src.dna.species
	else	new_species_name = "Human"

	if(src.species)
		//if(src.species.language)	src.remove_language(species.language)
		if(src.species.abilities)
			src.verbs -= species.abilities
		if(species.language)
			remove_language(species.language)
		species.clear_organs(src)

	var/datum/species/S = all_species[new_species_name]

	src.species = new S.type
	src.species.myhuman = src

	if(species.language)
		add_language(species.language)
	if(species.default_language)
		add_language(species.default_language)
	if(src.species.abilities)
		//if(src.species.language)	src.add_language(species.language)
		if(src.species.abilities)	src.verbs |= species.abilities
	if(force_organs || !src.organs || !src.organs.len)
		src.species.create_organs(src)
	var/datum/organ/internal/eyes/E = src.internal_organs_by_name["eyes"]
	if(E)
		src.see_in_dark = E.see_in_dark //species.darksight
	if(src.see_in_dark > 2)	src.see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else					src.see_invisible = SEE_INVISIBLE_LIVING
	if((src.species.default_mutations.len > 0) || (src.species.default_blocks.len > 0))
		src.do_deferred_species_setup = 1
	spawn()
		src.dna.species = new_species_name
		src.species.handle_post_spawn(src)
		src.update_icons()
	return 1

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = getFromPool(/obj/effect/decal/cleanable/blood/writing, T)
		W.New(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : "#A10808"
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)
/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1
	if(!user)
		target_zone = pick(LIMB_CHEST,LIMB_CHEST,LIMB_CHEST,"left leg","right leg","left arm", "right arm", LIMB_HEAD)
	else if(!target_zone)
		target_zone = user.zone_sel.selecting
	/*switch(target_zone)
		if(LIMB_HEAD)
			if(head && head.flags & THICKMATERIAL)
				. = 0
		else
			if(wear_suit && wear_suit.flags & THICKMATERIAL)
				. = 0
	*/
	if(!. && error_msg && user)
 		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [target_zone == LIMB_HEAD ? "on their head" : "on their body"] to inject into.</span>")
/mob/living/carbon/human/canSingulothPull(var/obj/machinery/singularity/singulo)
	if(!..())
		return 0
	if(istype(shoes,/obj/item/clothing/shoes/magboots))
		var/obj/item/clothing/shoes/magboots/M = shoes
		if(M.magpulse)
			return 0
	return 1
// Get ALL accesses available.
/mob/living/carbon/human/GetAccess()
	var/list/ACL=list()
	var/obj/item/I = get_active_hand()
	if(istype(I))
		ACL |= I.GetAccess()
	if(wear_id)
		ACL |= wear_id.GetAccess()
	return ACL
/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0
	//Lasertag
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team.
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2
		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2
		return threatcount
	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_id_card()
	if(judgebot.idcheck && !idcard)
		threatcount += 4
	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			for(var/obj/item/I in held_items)
				if(judgebot.check_for_weapons(I))
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
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/rig/wizard))
		threatcount += 2
	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1
	//Secbots are racist!
	if(dna && dna.mutantrace && dna.mutantrace != "none")
		threatcount += 2
	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/weapon/card/id/syndicate))
		threatcount -= 2
/mob/living/carbon/human/has_brain()
	if(internal_organs_by_name["brain"])
		var/datum/organ/internal/brain = internal_organs_by_name["brain"]
		if(brain && istype(brain))
			return 1
	return 0
/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name["eyes"])
		var/datum/organ/internal/eyes = internal_organs_by_name["eyes"]
		if(eyes && istype(eyes) && !eyes.status & ORGAN_CUT_AWAY)
			return 1
	return 0
/mob/living/carbon/human/singularity_act()
	if(src.flags & INVULNERABLE)
		return 0
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer"))
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigation_log(I_SINGULO,"has been consumed by a singularity")
	gib()
	return gain
/mob/living/carbon/human/singularity_pull(S, current_size,var/radiations = 3)
	if(src.flags & INVULNERABLE)
		return 0
	if(current_size >= STAGE_THREE) //Pull items from hand
		for(var/obj/item/I in held_items)
			if(prob(current_size*5) && I.w_class >= ((11-current_size)/2) && u_equip(I,1))
				step_towards(I, src)
				to_chat(src, "<span class = 'warning'>\The [S] pulls \the [I] from your grip!</span>")
	if(radiations)
		apply_effect(current_size * radiations, IRRADIATE)
	if(shoes)
		if(shoes.flags & NOSLIP) return 0
	..()
/mob/living/carbon/human/get_default_language()
	. = ..()
	if(.)
		return .
	if(!species)
		return null
	return species.default_language ? all_languages[species.default_language] : null

/mob/living/carbon/human/dexterity_check()
	if (stat != CONSCIOUS)
		return 0

	if(reagents.has_reagent(METHYLIN))
		return 1

	if(getBrainLoss() >= 60)
		return 0

	if(gloves && istype(gloves, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = gloves

		return G.dexterity_check()

	return 1

/mob/living/carbon/human/spook()
	if(!client) return
	if(!hallucinating())
		to_chat(src, "<i>[pick(boo_phrases)]</i>")
	else
		to_chat(src, "<b><font color='[pick("red","orange","yellow","green","blue")]'>[pick(boo_phrases_drugs)]</font></b>")

// Makes all robotic limbs organic.
/mob/living/carbon/human/proc/make_robot_limbs_organic()
	for(var/datum/organ/external/O in src.organs)
		if(O.is_robotic())
			O &= ~ORGAN_ROBOT
	update_icons()

// Makes all robot internal organs organic.
/mob/living/carbon/human/proc/make_robot_internals_organic()
	for(var/datum/organ/internal/O in src.organs)
		if(O.robotic)
			O.robotic = 0

// Makes all robot organs, internal and external, organic.
/mob/living/carbon/human/proc/make_all_robot_parts_organic()
	make_robot_limbs_organic()
	make_robot_internals_organic()

/mob/living/carbon/human/proc/set_attack_type(new_type = NORMAL_ATTACK)
	kick_icon.icon_state = "act_kick"
	bite_icon.icon_state = "act_bite"

	if(attack_type == new_type)
		attack_type = NORMAL_ATTACK
		return

	attack_type = new_type
	switch(attack_type)
		if(NORMAL_ATTACK)

		if(ATTACK_KICK)
			kick_icon.icon_state = "act_kick_on"
		if(ATTACK_BITE)
			bite_icon.icon_state = "act_bite_on"

/mob/living/carbon/human/proc/can_kick(atom/target)
	//Need two feet to kick!

	if(legcuffed)
		return 0

	if(target && !isturf(target) && !isturf(target.loc))
		return 0

	var/datum/organ/external/left_foot = get_organ(LIMB_LEFT_FOOT)
	if(!left_foot)
		return 0
	else if(left_foot.status & ORGAN_DESTROYED)
		return 0

	var/datum/organ/external/right_foot = get_organ(LIMB_RIGHT_FOOT)
	if(!right_foot)
		return 0
	else if(right_foot.status & ORGAN_DESTROYED)
		return 0

	return 1

/mob/living/carbon/human/proc/can_bite(atom/target)
	//Need a mouth to bite

	if(!hasmouth)
		return 0

	//Need at least two teeth or a beak to bite

	if(check_body_part_coverage(MOUTH))
		if(!isvampire(src)) //Vampires can bite through masks
			return 0

	if(M_BEAK in mutations)
		return 1

	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in src.butchering_drops
	if(T && T.amount >= 2)
		return 1

	return 0

/mob/living/carbon/human/proc/get_footprint_type()
	var/obj/item/clothing/shoes/S = shoes //Why isn't shoes just typecast in the first place?
	return ((istype(S) && S.footprint_type) || (species && species.footprint_type) || /obj/effect/decal/cleanable/blood/tracks/footprints) //The shoes' footprint type overrides the mob's, for obvious reasons. Shoes with a falsy footprint_type will let the mob's footprint take over, though.

/mob/living/carbon/human/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	if(..()) // we've been flashed
		var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]
		var/damage = intensity - eyecheck()
		if(visual)
			return
		if(!eyes)
			return
		switch(damage)
			if(0)
				to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")
			if(1)
				to_chat(src, "<span class='warning'>Your eyes sting a little.</span>")
				if(prob(40))
					eyes.damage += 1

			if(2)
				src << "<span class='warning'>Your eyes burn.</span>"
				eyes.damage += rand(2, 4)

			else
				to_chat(src,"<span class='warning'>Your eyes itch and burn severely!</span>")
				eyes.damage += rand(12, 16)

		if(eyes.damage > 10)
			eye_blind += damage
			eye_blurry += damage * rand(3, 6)

			if(eyes.damage > 20)
				if (prob(eyes.damage - 20))
					to_chat(src, "<span class='warning'>Your eyes start to burn badly!</span>")
					disabilities |= NEARSIGHTED
				else if(prob(eyes.damage - 25))
					to_chat(src, "<span class='warning'>You can't see anything!</span>")
					disabilities |= BLIND
			else
				to_chat(src, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
		return 1
	else
		to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")

/mob/living/carbon/human/reset_layer()
	if(lying)
		plane = PLANE_OBJ
		layer = MOB_LAYER - 0.1 //so we move under bedsheets
	else
		layer = MOB_LAYER
		plane = PLANE_MOB

/mob/living/carbon/human/set_hand_amount(new_amount) //Humans need hand organs to use the new hands. This proc will give them some
	if(new_amount > held_items.len)
		for(var/i = (held_items.len + 1) to new_amount) //For all the new indexes, create a hand organ
			if(!find_organ_by_grasp_index(i))
				var/datum/organ/external/OE = new/datum/organ/external/r_hand(organs_by_name[LIMB_GROIN]) //Fuck it the new hand will grow out of the groin (it doesn't matter anyways)
				OE.grasp_id = i
				OE.owner = src

				organs_by_name["hand[i]"] = OE
				grasp_organs.Add(OE)
				organs.Add(OE)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
