
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

/mob/living/carbon/human/plasma/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Plasmaman")

/mob/living/carbon/human/muton/New(var/new_loc, delay_ready_dna = 0)
	h_style = "Bald"
	..(new_loc, "Muton")

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
	if(!src.species)
		if(new_species_name)	src.set_species(new_species_name)
		else					src.set_species()
	default_language = get_default_language()

	create_reagents(1000)

	if(!dna)
		dna = new /datum/dna(null)
		dna.species=species.name

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")

	obj_overlays[FIRE_LAYER] = new /obj/Overlays/fire_layer
	obj_overlays[MUTANTRACE_LAYER] = new /obj/Overlays/mutantrace_layer
	obj_overlays[MUTATIONS_LAYER] = new /obj/Overlays/mutations_layer
	obj_overlays[DAMAGE_LAYER] = new /obj/Overlays/damage_layer
	obj_overlays[UNIFORM_LAYER] = new /obj/Overlays/uniform_layer
	obj_overlays[ID_LAYER] = new /obj/Overlays/id_layer
	obj_overlays[SHOES_LAYER] = new /obj/Overlays/shoes_layer
	obj_overlays[GLOVES_LAYER] = new /obj/Overlays/gloves_layer
	obj_overlays[EARS_LAYER] = new /obj/Overlays/ears_layer
	obj_overlays[SUIT_LAYER] = new /obj/Overlays/suit_layer
	obj_overlays[GLASSES_LAYER] = new /obj/Overlays/glasses_layer
	obj_overlays[BELT_LAYER] = new /obj/Overlays/belt_layer
	obj_overlays[SUIT_STORE_LAYER] = new /obj/Overlays/suit_store_layer
	obj_overlays[BACK_LAYER] = new /obj/Overlays/back_layer
	obj_overlays[HAIR_LAYER] = new /obj/Overlays/hair_layer
	obj_overlays[GLASSES_OVER_HAIR_LAYER] = new /obj/Overlays/glasses_over_hair_layer
	obj_overlays[FACEMASK_LAYER] = new /obj/Overlays/facemask_layer
	obj_overlays[HEAD_LAYER] = new /obj/Overlays/head_layer
	obj_overlays[HANDCUFF_LAYER] = new /obj/Overlays/handcuff_layer
	obj_overlays[LEGCUFF_LAYER] = new /obj/Overlays/legcuff_layer
	obj_overlays[L_HAND_LAYER] = new /obj/Overlays/l_hand_layer
	obj_overlays[R_HAND_LAYER] = new /obj/Overlays/r_hand_layer
	obj_overlays[TAIL_LAYER] = new /obj/Overlays/tail_layer
	obj_overlays[TARGETED_LAYER] = new /obj/Overlays/targeted_layer

	..()

	if(dna)
		dna.real_name = real_name

	prev_gender = gender // Debug for plural genders
	make_blood()
	init_butchering_list() // While animals only generate list of their teeth/skins on death, humans generate it when they're born.

	// Set up DNA.
	if(!delay_ready_dna)
		dna.ready_dna(src)

/mob/living/carbon/human/player_panel_controls()
	var/html=""

	// TODO: Loop through contents and call parasite_panel or something.
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		html +="<h2>Cortical Borer:</h2> [B] ("
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
				del(internal)
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

/mob/living/carbon/human/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat == DEAD)
		return

	show_message("<span class='warning'>The blob attacks you!</span>")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(rand(30,40), BRUTE, affecting, run_armor_check(affecting, "melee"))
	return

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
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		if(M.zone_sel && M.zone_sel.selecting)
			dam_zone = M.zone_sel.selecting
		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")
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

		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/slime/adult))
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin")

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
/mob/living/carbon/human/var/temperature_resistance = T0C+75

/*
/mob/living/carbon/human/show_inv(mob/user as mob)
	var/obj/item/clothing/gloves/G
	var/pickpocket = 0
	var/list/obscured = check_obscured_slots()
	if(ishuman(user) && user:gloves)
		G = user:gloves
		pickpocket = G.pickpocket
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(ears ? ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform ? w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR><B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store ? s_store : "Nothing")]</A>
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(legcuffed ? text("<A href='?src=\ref[src];item=legcuff'>Legcuffed</A>") : text(""))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=splints'>Remove Splints</A>
	<BR><BR><A href='?src=\ref[src];pockets=left'>Left Pocket ([l_store ? (pickpocket ? l_store.name : "Full") : "Empty"])</A>
	<BR><A href='?src=\ref[src];pockets=right'>Right Pocket ([r_store ? (pickpocket ? r_store.name : "Full") : "Empty"])</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob\ref[src];size=340x480"))
	onclose(user, "mob\ref[src]")
	return
*/


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()
	var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"
	var/dat = {"
	<B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>		[(l_hand && !( src.l_hand.abstract ))		? l_hand	: "<font color=grey>Empty</font>"]</A><BR>
	<B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>		[(r_hand && !( src.r_hand.abstract ))		? r_hand	: "<font color=grey>Empty</font>"]</A><BR>
	"}
	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=back'> [(back && !(src.back.abstract)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/weapon/tank))
		dat += "<BR>[TAB]&#8627;<A href='?src=\ref[src];item=internal'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	dat += "<BR>"
	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>				[(head && !(src.head.abstract))		? head		: "<font color=grey>Empty</font>"]</A>"
	if(slot_wear_mask in obscured)
		dat += "<BR><font color=grey><B>Mask:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=mask'>		[(wear_mask && !(src.wear_mask.abstract))	? wear_mask	: "<font color=grey>Empty</font>"]</A>"
	if(slot_glasses in obscured)
		dat += "<BR><font color=grey><B>Eyes:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>			[(glasses && !(src.glasses.abstract))	? glasses	: "<font color=grey>Empty</font>"]</A>"
	if(slot_ears in obscured)
		dat += "<BR><font color=grey><B>Ears:</B> Obscured by [head]</font>"
	else
		dat += "<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>				[(ears && !(src.ears.abstract))		? ears		: "<font color=grey>Empty</font>"]</A>"
	dat += "<BR>"
	dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=suit'> [(wear_suit && !(src.wear_suit.abstract)) ? wear_suit : "<font color=grey>Empty</font>"]</A>"
	if(wear_suit)
		dat += "<BR>[TAB]&#8627;<B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store && !(src.s_store.abstract)) ? s_store : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(s_store, /obj/item/weapon/tank))
			dat += "<BR>[TAB][TAB]&#8627;<A href='?src=\ref[src];item=internal2'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	if(slot_shoes in obscured)
		dat += "<BR><font color=grey><B>Shoes:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>			[(shoes && !(src.shoes.abstract))		? shoes		: "<font color=grey>Empty</font>"]</A>"
	if(slot_gloves in obscured)
		dat += "<BR><font color=grey><B>Gloves:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>			[(gloves && !(src.gloves.abstract))		? gloves	: "<font color=grey>Empty</font>"]</A>"
	if(slot_w_uniform in obscured)
		dat += "<BR><font color=grey><B>Uniform:</B> Obscured by [wear_suit]</font>"
	else
		dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>	 [(w_uniform && !(src.w_uniform.abstract)) ? w_uniform : "<font color=grey>Empty</font>"]</A>"
	if(w_uniform)
		dat += "<BR>[TAB]&#8627;<B>Belt:</B> <A href='?src=\ref[src];item=belt'> [(belt && !(src.belt.abstract)) ? belt : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(belt, /obj/item/weapon/tank))
			dat += "<BR>[TAB][TAB]&#8627;<A href='?src=\ref[src];item=internal1'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		if(ishuman(user) && istype(user:gloves, /obj/item/clothing/gloves/black/thief))
			dat += "<BR>[TAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
		else
			dat += "<BR>[TAB]&#8627;<B>Pockets:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
		dat += "<BR>[TAB]&#8627;<B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id && !(src.wear_id.abstract)) ? wear_id : "<font color=grey>Empty</font>"]</A>"
	dat += "<BR>"
	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=handcuff'>Remove</A>"
	if(legcuffed)
		dat += "<BR><B>Legcuffed:</B> <A href='?src=\ref[src];item=legcuff'>Remove</A>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()
// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(istype(AM,/obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/MB = AM
		MB.RunOverCreature(src,species.blood_color)
	else if(istype(AM,/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate))
		var/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate/WC = AM
		WC.crush(src,species.blood_color)
	else
		return //Don't make blood
	var/obj/effect/decal/cleanable/blood/B = getFromPool(/obj/effect/decal/cleanable/blood, get_turf(src))
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
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) && !istype(wear_mask,/obj/item/clothing/mask/gas/golem))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv&HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	if(mind && mind.vampire && (VAMP_SHADOW in mind.vampire.powers) && mind.vampire.ismenacing)
		return get_id_name("Unknown")
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name
//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/datum/organ/external/head/head = get_organ("head")
	if( !head || head.disfigured || (head.status & ORGAN_DESTROYED) || !real_name || (M_HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(pda))		. = pda.owner
	else if(istype(id))	. = id.registered_name
	if(!.) 				. = if_no_id	//to prevent null-names making the mob unclickable
	return

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE || M_NO_SHOCK in src.mutations)	return 0	//godmode

	if (!def_zone)
		def_zone = pick("l_hand", "r_hand")

	var/datum/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)

/mob/living/carbon/human/proc/num2slotname(slot_id)
	switch (slot_id)
		if (slot_back)
			return "back"
		if (slot_wear_mask)
			return "mask"
		if (slot_handcuffed)
			return "handcuffed"
		if (slot_l_hand)
			return "l_hand"
		if (slot_r_hand)
			return "r_hand"
		if (slot_belt)
			return "belt"
		if (slot_wear_id)
			return "id"
		if (slot_ears)
			return "ears"
		if (slot_glasses)
			return "eyes"
		if (slot_gloves)
			return "gloves"
		if (slot_head)
			return "head"
		if (slot_shoes)
			return "shoes"
		if (slot_wear_suit)
			return "suit"
		if (slot_w_uniform)
			return "uniform"
		if (slot_l_store)
			return "l_store"
		if (slot_r_store)
			return "r_store"
		if (slot_s_store)
			return "s_store"
		if (slot_in_backpack)
			return "in_backpack"
		if (slot_legcuffed)
			return "h_store"
		else
			return ""

/mob/living/carbon/human/hear_radio_only()
	if(!ears) return 0
	return is_on_ears(/obj/item/device/radio/headset/headset_earmuffs)

/mob/living/carbon/human/Topic(href, href_list)
	var/pickpocket = 0
	var/able = (!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr) && Adjacent(usr))

	if(href_list["item"])
		if (!able) return
		var/slot = href_list["item"]
		var/obj/item/place_item = usr.get_active_hand()
		var/obj/item/id_item = src.wear_id

		var/list/obscured_slots = new/list()

		for (var/obscured_slot_num in check_obscured_slots())
			var/slot_name = num2slotname(obscured_slot_num)

			if (slot_name != "")
				obscured_slots += slot_name

		if (slot in obscured_slots)
			to_chat(usr, "<span class='warning'>You can't reach that. Something is covering it.</span>")
			return
		else
			if(isanimal(usr)) return //Animals can't do that
			var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
			if(ishuman(usr) && usr:gloves)
				var/obj/item/clothing/gloves/G = usr:gloves
				pickpocket = G.pickpocket
			O.source = usr
			O.target = src
			O.item = usr.get_active_hand()
			O.s_loc = usr.loc
			O.t_loc = loc
			O.place = href_list["item"]
			O.pickpocket = pickpocket //Stealthy
			requests += O
//			to_chat(world, O.place)
			if(O.place == "id")
				if(id_item)
					to_chat(usr, "<span class='notice'>You try to take [src]'s ID.</span>")
				else if(place_item && place_item.mob_can_equip(src, slot_wear_id, 1))
					to_chat(usr, "<span class='notice'>You try to place [place_item] on [src].</span>")

				if(do_mob(usr, src, HUMAN_STRIP_DELAY))
					if(id_item)
						u_equip(id_item,0)
						if(pickpocket) usr.put_in_hands(id_item)
					else
						if(place_item)
							usr.u_equip(place_item,1)
							equip_to_slot_if_possible(place_item, slot_wear_id, 0, 1)
					// Update strip window
					if(in_range(src, usr))
						show_inv(usr)

				else if(!pickpocket)
					// Display a warning if the user mocks up
					to_chat(src, "<span class='warning'>You feel your ID being fumbled with!</span>")
			else
				spawn( 0 )
					O.process()
					spawn(HUMAN_STRIP_DELAY)	if(in_range(src, usr)) show_inv(usr)
					return
	else if(href_list["pockets"])
		if (!able) return
		var/pocket_side = href_list["pockets"]
		var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
		var/obj/item/pocket_item = (pocket_id == slot_r_store ? src.r_store : src.l_store)
		var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty
		if(isanimal(usr)) return //Animals can't do that
		if(ishuman(usr) && (usr:gloves))
			var/obj/item/clothing/gloves/G = usr:gloves
			pickpocket = G.pickpocket

		if(pocket_item)
			to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
		else if(place_item && place_item.mob_can_equip(src, pocket_id, 1))
			to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
		else
			return

		if(do_mob(usr, src, HUMAN_STRIP_DELAY))
			if(pocket_item)
				u_equip(pocket_item,1)
				pocket_item.stripped(src,usr)
				if(pickpocket) usr.put_in_hands(pocket_item)
			else
				if(place_item)
					usr.u_equip(place_item,1)
					equip_to_slot_if_possible(place_item, pocket_id, 0, 1)
			// Update strip window
			if(in_range(src, usr))
				show_inv(usr)

		else if(!pickpocket)
				// Display a warning if the user mocks up
			to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")
	else if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)
	else if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
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
	else if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		usr.examination(M)
	else
		..()
	return
/**
 * Returns a number between -1 to 2.
 * TODO: What's the default return value?
 */
/mob/living/carbon/human/eyecheck()
	. = 0
	var/obj/item/clothing/head/headwear = src.head
	var/obj/item/clothing/glasses/eyewear = src.glasses

	if (istype(headwear))
		. += headwear.eyeprot

	if (istype(eyewear))
		. += eyewear.eyeprot

	return Clamp(., -1, 2)


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.ears || src.gloves)))
		return 1

	if( (src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) )
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
		visible_message("<span class='warning'>[src] begins playing his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='notice'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/vomit(hairball = 0)
	if(!lastpuke)
		lastpuke = 1
		to_chat(src, "<spawn class='warning'>You feel nauseous...</span>")
		spawn(150)	//15 seconds until second warning
			to_chat(src, "<spawn class='danger'>You feel like you are about to throw up!</span>")
			spawn(100)	//And you have 10 more seconds to move it to the bathrooms
				Stun(5)

				if(hairball)
					src.visible_message("<span class='warning'>[src] hacks up a hairball!</span>","<span class='danger'>You hack up a hairball!</span>")
				else
					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='danger'>You throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				if(!hairball)
					nutrition -= 40
					adjustToxLoss(-3)

				spawn(350)	//Wait 35 seconds before next volley
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
		del(H) // delete the hair after it's all done

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
		del(H)

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

/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
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

	var/datum/organ/external/head/h = organs_by_name["head"]
	h.disfigured = 0

	if(species && !(species.flags & NO_BLOOD))
		vessel.add_reagent("blood",560-vessel.total_volume)
		fixblood()

	for (var/obj/item/weapon/organ/head/H in world)
		if(H.brainmob)
			if(H.brainmob.real_name == src.real_name)
				if(H.brainmob.mind)
					H.brainmob.mind.transfer_to(src)
					del(H)
				if(H.borer)
					H.borer.perform_infestation(src)
					H.borer=null

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

	if(usr.stat == 1 || (usr.status_flags & FAKEDEATH))
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

	if(usr.stat == 1 || usr.restrained() || !isliving(usr) || (usr.status_flags & FAKEDEATH)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.</span>",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"You begin counting your pulse.")

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "Don't move until counting is finished.")

	if (do_mob(usr, src, 60))
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")
	else
		to_chat(usr, "You moved while counting. Try again.")

/mob/living/carbon/human/proc/set_species(var/new_species_name, var/force_organs, var/default_colour)


	if(new_species_name)
		if(src.species && src.species.name && (src.species.name == new_species_name)) return
	else if(src.dna)	new_species_name = src.dna.species
	else	new_species_name = "Human"

	if(src.species)
		//if(src.species.language)	src.remove_language(species.language)
		if(src.species.abilities)	src.verbs -= species.abilities
		if(species.language)
			remove_language(species.language)

	src.species = all_species[new_species_name]

	if(species.language)
		add_language(species.language)
	if(species.default_language)
		add_language(species.default_language)
	if(src.species.abilities)
		//if(src.species.language)	src.add_language(species.language)
		if(src.species.abilities)	src.verbs |= species.abilities
	if(force_organs || !src.organs || !src.organs.len)	src.species.create_organs(src)
	src.see_in_dark = species.darksight
	if(src.see_in_dark > 2)	src.see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else					src.see_invisible = SEE_INVISIBLE_LIVING
	if((src.species.default_mutations.len > 0) || (src.species.default_blocks.len > 0))
		src.do_deferred_species_setup = 1
	spawn()
		src.dna.species = new_species_name
		src.update_icons()
	src.species.handle_post_spawn(src)
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
		target_zone = pick("chest","chest","chest","left leg","right leg","left arm", "right arm", "head")
	else if(!target_zone)
		target_zone = user.zone_sel.selecting
	/*switch(target_zone)
		if("head")
			if(head && head.flags & THICKMATERIAL)
				. = 0
		else
			if(wear_suit && wear_suit.flags & THICKMATERIAL)
				. = 0
	*/
	if(!. && error_msg && user)
 		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"] to inject into.</span>")
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
	var/obj/item/weapon/card/id/idcard = get_id_card()
	if(judgebot.idcheck && !idcard)
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
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size*5) && hand.w_class >= ((11-current_size)/2) && u_equip(hand,1))
				step_towards(hand, src)
				to_chat(src, "<span class = 'warning'>\The [S] pulls \the [hand] from your grip!</span>")
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
	if(reagents.has_reagent("methylin"))
		return 1
	if (getBrainLoss() >= 60)
		return 0
	return 1
/mob/living/carbon/human/spook()
	if(!client) return
	if(!hallucinating())
		to_chat(src, "<i>[pick(boo_phrases)]</i>")
	else
		to_chat(src, "<b><font color='[pick("red","orange","yellow","green","blue")]'>[pick(boo_phrases_drugs)]</font></b>")
