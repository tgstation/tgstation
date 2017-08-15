/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	voice_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "caucasian_m"

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Destroy()
	..()
	return QDEL_HINT_QUEUE

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/Initialize()
	verbs += /mob/living/proc/mob_sleep
	verbs += /mob/living/proc/lay_down

	//initialize limbs first
	create_bodyparts()

	//initialize dna. for spawned humans; overwritten by other code
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna()

	if(dna.species)
		set_species(dna.species.type)

	//initialise organs
	create_internal_organs()

	handcrafting = new()

	..()

/mob/living/carbon/human/create_internal_organs()
	if(!(NOHUNGER in dna.species.species_traits))
		internal_organs += new /obj/item/organ/appendix
	if(!(NOBREATH in dna.species.species_traits))
		if(dna.species.mutantlungs)
			internal_organs += new dna.species.mutantlungs()
		else
			internal_organs += new /obj/item/organ/lungs()
	if(!(NOBLOOD in dna.species.species_traits))
		internal_organs += new /obj/item/organ/heart

	if(!(NOLIVER in dna.species.species_traits))
		if(dna.species.mutantliver)
			internal_organs += new dna.species.mutantliver()
		else
			internal_organs += new /obj/item/organ/liver()

	if(!(NOSTOMACH in dna.species.species_traits))
		if(dna.species.mutantstomach)
			internal_organs += new dna.species.mutantstomach()
		else
			internal_organs += new /obj/item/organ/stomach()

	internal_organs += new dna.species.mutanteyes
	internal_organs += new dna.species.mutantears
	internal_organs += new dna.species.mutanttongue
	internal_organs += new /obj/item/organ/brain
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
					for(var/thing in viruses)
						var/datum/disease/D = thing
						stat("*", "[D.name], Type: [D.spread_text], Stage: [D.stage]/[D.max_stages], Possible Cure: [D.cure_text]")


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()
	var/list/dat = list()

	dat += "<table>"
	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<tr><td><B>[get_held_index_name(i)]:</B></td><td><A href='?src=\ref[src];item=[slot_hands];hand_index=[i]'>[(I && !(I.flags & ABSTRACT)) ? I : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/weapon/tank))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=\ref[src];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_neck in obscured)
		dat += "<tr><td><font color=grey><B>Neck:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Neck:</B></td><td><A href='?src=\ref[src];item=[slot_neck]'>[(wear_neck && !(wear_neck.flags&ABSTRACT)) ? wear_neck : "<font color=grey>Empty</font>"]</A></td></tr>"

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
	popup.set_content(dat.Join())
	popup.open()

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(atom/movable/AM)
	var/mob/living/simple_animal/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

	spreadFire(AM)


/mob/living/carbon/human/Topic(href, href_list)
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["embedded_object"])
			var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
			if(!L)
				return
			var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
			if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
				return
			var/time_taken = I.embedded_unsafe_removal_time*I.w_class
			usr.visible_message("<span class='warning'>[usr] attempts to remove [I] from their [L.name].</span>","<span class='notice'>You attempt to remove [I] from your [L.name]... (It will take [time_taken/10] seconds.)</span>")
			if(do_after(usr, time_taken, needhand = 1, target = src))
				if(!I || !L || I.loc != src || !(I in L.embedded_objects))
					return
				L.embedded_objects -= I
				L.receive_damage(I.embedded_unsafe_removal_pain_multiplier*I.w_class)//It hurts to rip it out, get surgery you dingus.
				I.forceMove(get_turf(src))
				usr.put_in_hands(I)
				usr.emote("scream")
				usr.visible_message("[usr] successfully rips [I] out of their [L.name]!","<span class='notice'>You successfully remove [I] from your [L.name].</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")
			return

		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_held_item() // Item to place in the pocket, if it's empty

			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					to_chat(usr, "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
				to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
			else if(place_item && place_item.mob_can_equip(src, usr, pocket_id, 1) && !(place_item.flags&ABSTRACT))
				to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
				if(pocket_item)
					if(pocket_item == (pocket_id == slot_r_store ? r_store : l_store)) //item still in the pocket we search
						dropItemToGround(pocket_item)
				else
					if(place_item)
						if(place_item.mob_can_equip(src, usr, pocket_id, FALSE, TRUE))
							usr.temporarilyRemoveItemFromInventory(place_item, TRUE)
							equip_to_slot(place_item, pocket_id, TRUE)
						//do nothing otherwise

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up
				to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

		..()


///////HUDs///////
	if(href_list["hud"])
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/perpname = get_face_name(get_id_name(""))
			if(istype(H.glasses, /obj/item/clothing/glasses/hud) || istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud))
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(href_list["photo_front"] || href_list["photo_side"])
					if(R)
						if(!H.canUseHUD())
							return
						else if(!istype(H.glasses, /obj/item/clothing/glasses/hud) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/medical))
							return
						var/obj/item/weapon/photo/P = null
						if(href_list["photo_front"])
							P = R.fields["photo_front"]
						else if(href_list["photo_side"])
							P = R.fields["photo_side"]
						if(P)
							P.show(H)

				if(href_list["hud"] == "m")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/medical))
						if(href_list["p_stat"])
							var/health_status = input(usr, "Specify a new physical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("Active", "Physically Unfit", "*Unconscious*", "*Deceased*", "Cancel")
							if(R)
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/medical))
									return
								if(health_status && health_status != "Cancel")
									R.fields["p_stat"] = health_status
							return
						if(href_list["m_stat"])
							var/health_status = input(usr, "Specify a new mental status for this person.", "Medical HUD", R.fields["m_stat"]) in list("Stable", "*Watch*", "*Unstable*", "*Insane*", "Cancel")
							if(R)
								if(!H.canUseHUD())
									return
								else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/health) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/medical))
									return
								if(health_status && health_status != "Cancel")
									R.fields["m_stat"] = health_status
							return
						if(href_list["evaluation"])
							if(!getBruteLoss() && !getFireLoss() && !getOxyLoss() && getToxLoss() < 20)
								to_chat(usr, "<span class='notice'>No external injuries detected.</span><br>")
								return
							var/span = "notice"
							var/status = ""
							if(getBruteLoss())
								to_chat(usr, "<b>Physical trauma analysis:</b>")
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
										to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
							if(getFireLoss())
								to_chat(usr, "<b>Analysis of skin burns:</b>")
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
										to_chat(usr, "<span class='[span]'>[BP] appears to have [status]</span>")
							if(getOxyLoss())
								to_chat(usr, "<span class='danger'>Patient has signs of suffocation, emergency treatment may be required!</span>")
							if(getToxLoss() > 20)
								to_chat(usr, "<span class='danger'>Gathered data is inconsistent with the analysis, possible cause: poisoning.</span>")

				if(href_list["hud"] == "s")
					if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
						if(usr.stat || usr == src) //|| !usr.canmove || usr.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
							return													  //Non-fluff: This allows sec to set people to arrest as they get disarmed or beaten
						// Checks the user has security clearence before allowing them to change arrest status via hud, comment out to enable all access
						var/allowed_access = null
						var/obj/item/clothing/glasses/G = H.glasses
						if (!G.emagged)
							if(H.wear_id)
								var/list/access = H.wear_id.GetAccess()
								if(ACCESS_SEC_DOORS in access)
									allowed_access = H.get_authentification_name()
						else
							allowed_access = "@%&ERROR_%$*"


						if(!allowed_access)
							to_chat(H, "<span class='warning'>ERROR: Invalid Access</span>")
							return

						if(perpname)
							R = find_record("name", perpname, GLOB.data_core.security)
							if(R)
								if(href_list["status"])
									var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Discharged", "Cancel")
									if(setcriminal != "Cancel")
										if(R)
											if(H.canUseHUD())
												if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
													investigate_log("[src.key] has been set from [R.fields["criminal"]] to [setcriminal] by [usr.name] ([usr.key]).", INVESTIGATE_RECORDS)
													R.fields["criminal"] = setcriminal
													sec_hud_set_security_status()
									return

								if(href_list["view"])
									if(R)
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
											return
										to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
										to_chat(usr, "<b>Minor Crimes:</b>")
										for(var/datum/data/crime/c in R.fields["mi_crim"])
											to_chat(usr, "<b>Crime:</b> [c.crimeName]")
											to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
											to_chat(usr, "Added by [c.author] at [c.time]")
											to_chat(usr, "----------")
										to_chat(usr, "<b>Major Crimes:</b>")
										for(var/datum/data/crime/c in R.fields["ma_crim"])
											to_chat(usr, "<b>Crime:</b> [c.crimeName]")
											to_chat(usr, "<b>Details:</b> [c.crimeDetails]")
											to_chat(usr, "Added by [c.author] at [c.time]")
											to_chat(usr, "----------")
										to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
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
													else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
														return
													var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													GLOB.data_core.addMinorCrime(R.fields["id"], crime)
													to_chat(usr, "<span class='notice'>Successfully added a minor crime.</span>")
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
													else if (!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
														return
													var/crime = GLOB.data_core.createCrimeEntry(t1, t2, allowed_access, worldtime2text())
													GLOB.data_core.addMajorCrime(R.fields["id"], crime)
													to_chat(usr, "<span class='notice'>Successfully added a major crime.</span>")
									return

								if(href_list["view_comment"])
									if(R)
										if(!H.canUseHUD())
											return
										else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
											return
										to_chat(usr, "<b>Comments/Log:</b>")
										var/counter = 1
										while(R.fields[text("com_[]", counter)])
											to_chat(usr, R.fields[text("com_[]", counter)])
											to_chat(usr, "----------")
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
											else if(!istype(H.glasses, /obj/item/clothing/glasses/hud/security) && !istype(H.getorganslot("eye_hud"), /obj/item/organ/cyberimp/eyes/hud/security))
												return
											var/counter = 1
											while(R.fields[text("com_[]", counter)])
												counter++
											R.fields[text("com_[]", counter)] = text("Made by [] on [] [], []<BR>[]", allowed_access, worldtime2text(), time2text(world.realtime, "MMM DD"), GLOB.year_integer+540, t1)
											to_chat(usr, "<span class='notice'>Successfully added comment.</span>")
											return
							to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

/mob/living/carbon/human/proc/canUseHUD()
	return !(src.stat || IsKnockdown() || IsStun() || src.restrained())

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, var/penetrate_thick = 0)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_selected
	if(dna && (PIERCEIMMUNE in dna.species.species_traits))
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
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [above_neck(target_zone) ? "on [p_their()] head" : "on [p_their()] body"].</span>")

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

	if(obscured.len)
		return obscured
	else
		return null

/mob/living/carbon/human/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgement_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_idcard()
	if( (judgement_criteria & JUDGE_IDCHECK) && !idcard && name=="Unknown")
		threatcount += 4

	//Check for weapons
	if( (judgement_criteria & JUDGE_WEAPONCHECK) && weaponcheck)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			for(var/obj/item/I in held_items)
				if(weaponcheck.Invoke(I))
					threatcount += 4
			if(weaponcheck.Invoke(belt))
				threatcount += 2

	//Check for arrest warrant
	if(judgement_criteria & JUDGE_RECORDCHECK)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
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
	if(isloyal())
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

/mob/living/carbon/human/singularity_pull(S, current_size)
	if(current_size >= STAGE_THREE)
		for(var/obj/item/hand in held_items)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && dropItemToGround(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	rad_act(current_size * 3)
	if(mob_negates_gravity())
		return
	..()

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/C)
	CHECK_DNA_AND_SPECIES(C)

	if(C.stat == DEAD || (C.status_flags & FAKEDEATH))
		to_chat(src, "<span class='warning'>[C.name] is dead!</span>")
		return
	if(is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return 0
	if(C.is_mouth_covered())
		to_chat(src, "<span class='warning'>Remove [p_their()] mask first!</span>")
		return 0

	if(C.cpr_time < world.time + 30)
		visible_message("<span class='notice'>[src] is trying to perform CPR on [C.name]!</span>", \
						"<span class='notice'>You try to perform CPR on [C.name]... Hold still!</span>")
		if(!do_mob(src, C))
			to_chat(src, "<span class='warning'>You fail to perform CPR on [C]!</span>")
			return 0

		var/they_breathe = (!(NOBREATH in C.dna.species.species_traits))
		var/they_lung = C.getorganslot("lungs")

		if(C.health > HEALTH_THRESHOLD_CRIT)
			return

		src.visible_message("[src] performs CPR on [C.name]!", "<span class='notice'>You perform CPR on [C.name].</span>")
		C.cpr_time = world.time
		add_logs(src, C, "CPRed")

		if(they_breathe && they_lung)
			var/suff = min(C.getOxyLoss(), 7)
			C.adjustOxyLoss(-suff)
			C.updatehealth()
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air enter your lungs... It feels good...</span>")
		else if(they_breathe && !they_lung)
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air... but you don't feel any better...</span>")
		else
			to_chat(C, "<span class='unconscious'>You feel a breath of fresh air... which is a sensation you don't recognise...</span>")

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
			dropItemToGround(I)
	else
		if(..())
			dropItemToGround(I)

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
	cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_lizard"))
	cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_human"))


//Turns a mob black, flashes a skeleton overlay
//Just like a cartoon!
/mob/living/carbon/human/proc/electrocution_animation(anim_duration)
	//Handle mutant parts if possible
	if(dna && dna.species)
		add_atom_colour("#000000", TEMPORARY_COLOUR_PRIORITY)
		var/static/mutable_appearance/electrocution_skeleton_anim
		if(!electrocution_skeleton_anim)
			electrocution_skeleton_anim = mutable_appearance(icon, "electrocuted_base")
			electrocution_skeleton_anim.appearance_flags |= RESET_COLOR
		add_overlay(electrocution_skeleton_anim)
		addtimer(CALLBACK(src, .proc/end_electrocution_animation, electrocution_skeleton_anim), anim_duration)

	else //or just do a generic animation
		flick_overlay_view(image(icon,src,"electrocuted_generic",ABOVE_MOB_LAYER), src, anim_duration)

/mob/living/carbon/human/proc/end_electrocution_animation(mutable_appearance/MA)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#000000")
	cut_overlay(MA)

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
	for(var/list/L in list(GLOB.data_core.general,GLOB.data_core.medical,GLOB.data_core.security,GLOB.data_core.locked))
		var/datum/data/record/R = find_record("name", oldname, L)
		if(R)
			R.fields["name"] = newname

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
					if(SCREWYHUD_CRIT)
						hud_used.healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						hud_used.healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
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
					if(hal_screwyhud == SCREWYHUD_HEALTHY)
						icon_num = 0
					if(icon_num)
						hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[BP.body_zone][icon_num]"))
				for(var/t in get_missing_limbs()) //Missing limbs
					hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[t]6"))
			else
				hud_used.healthdoll.icon_state = "healthdoll_DEAD"

/mob/living/carbon/human/fully_heal(admin_revive = 0)
	if(admin_revive)
		regenerate_limbs()
		regenerate_organs()
	remove_all_embedded_objects()
	set_heartattack(FALSE)
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
	SSticker.mode.sintouched += src.mind
	src.mind.objectives += O
	src.mind.announce_objectives()

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

/mob/living/carbon/human/vomit(lost_nutrition = 10, blood = 0, stun = 1, distance = 0, message = 1, toxic = 0)
	if(blood && (NOBLOOD in dna.species.species_traits))
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing in your stomach!</span>")
		if(stun)
			Knockdown(200)
		return 1
	..()

/mob/living/carbon/human/Collide(atom/A)
	..()
	var/crashdir = get_dir(src, A)
	var/obj/item/device/flightpack/FP = get_flightpack()
	if(FP)
		FP.flight_impact(A, crashdir)

/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Make monkey"] = "?_src_=vars;makemonkey=\ref[src]"
	.["Set Species"] = "?_src_=vars;setspecies=\ref[src]"
	.["Make cyborg"] = "?_src_=vars;makerobot=\ref[src]"
	.["Make alien"] = "?_src_=vars;makealien=\ref[src]"
	.["Make slime"] = "?_src_=vars;makeslime=\ref[src]"
	.["Toggle Purrbation"] = "?_src_=vars;purrbation=\ref[src]"

/mob/living/carbon/human/MouseDrop_T(mob/living/target, mob/living/user)
	if((target != pulling) || (grab_state < GRAB_AGGRESSIVE) || (user != target) || !isliving(user) || stat || user.stat)//Get consent first :^)
		. = ..()
		return
	buckle_mob(target, TRUE, TRUE)
	. = ..()

/mob/living/carbon/human/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force)//humans are only meant to be ridden through piggybacking and special cases
		return
	if(!is_type_in_typecache(M, can_ride_typecache))
		M.visible_message("<span class='warning'>[M] really can't seem to mount [src]...</span>")
		return
	if(!riding_datum)
		riding_datum = new /datum/riding/human(src)
	if(buckled_mobs && ((M in buckled_mobs) || (buckled_mobs.len >= max_buckled_mobs)) || buckled || (M.stat != CONSCIOUS))
		return
	visible_message("<span class='notice'>[M] starts to climb onto [src]...</span>")
	if(do_after(M, 15, target = src))
		if(iscarbon(M))
			if(M.incapacitated(FALSE, TRUE) || incapacitated(FALSE, TRUE))
				M.visible_message("<span class='warning'>[M] can't hang onto [src]!</span>")
				return
			if(!riding_datum.equip_buckle_inhands(M, 2))	//MAKE SURE THIS IS LAST!!
				M.visible_message("<span class='warning'>[M] can't climb onto [src]!</span>")
				return
		. = ..(M, force, check_loc)
		stop_pulling()
	else
		visible_message("<span class='warning'>[M] fails to climb onto [src]!</span>")

/mob/living/carbon/human/unbuckle_mob(mob/living/M, force=FALSE)
	if(iscarbon(M))
		if(riding_datum)
			riding_datum.unequip_buckle_inhands(M)
			riding_datum.restore_position(M)
	. = ..(M, force)
