/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet"
	density = FALSE
	anchored = TRUE
	var/cistern_open = FALSE //if the cistern bit is open
	var/w_items = 0 //the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null //the mob being given a swirlie

/obj/structure/toilet/Initialize()
	. = ..()
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(..())
		return TRUE

	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams [swirlie]'s head against the toilet!</span>", "<span class='userdanger'>[user] slams your head against the toilet!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(10)
		return TRUE

	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/GM = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a tighter grip!</span>")
			return TRUE
		if(GM.loc != get_turf(src))
			to_chat(user, "<span class='warning'>[GM] needs to be on [src]!</span>")
			return TRUE
		if(swirlie)
			return TRUE
		GM.visible_message("<span class='danger'>[user] starts to give [GM] a swirlie!</span>", "<span class='userdanger'>[user] starts to give you a swirlie...</span>")
		swirlie = GM
		if(do_after(user, 30, 0, target = src))
			GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] gives you a swirlie!</span>", "<span class='italics'>You hear a toilet flushing.</span>")
			if(iscarbon(GM))
				var/mob/living/carbon/C = GM
				if(!C.internal)
					C.adjustOxyLoss(5)
			else
				GM.adjustOxyLoss(5)
		swirlie = null
		return TRUE

	if(cistern_open && user.CanReach(src))
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return TRUE
		var/obj/item/I = pick(contents)
		if(ishuman(user))
			user.put_in_hands(I)
		else
			I.forceMove(drop_location())
		to_chat(user, "<span class='notice'>You find [I] in the cistern.</span>")
		w_items -= I.w_class
		return TRUE

/obj/structure/toilet/update_icon()
	cut_overlays()
	if(dir == NORTH)
		icon_state = cistern_open ? "toilet-cistern-open" : "toilet-cistern"
		add_overlay("toilet")
	else
		icon_state = "toilet"
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', cistern_open ? "toilet-cistern-open" : "toilet-cistern", ABOVE_MOB_LAYER))

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, "<span class='notice'>You start to [cistern_open ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 30))
			user.visible_message("[user] [cistern_open ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
			cistern_open = !cistern_open
			update_icon()
		return TRUE

	if(cistern_open)
		if(user.a_intent != INTENT_HARM)
			if(I.w_class > WEIGHT_CLASS_NORMAL)
				to_chat(user, "<span class='warning'>[I] does not fit!</span>")
				return TRUE
			if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
				to_chat(user, "<span class='warning'>The cistern is full!</span>")
				return TRUE
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the cistern!</span>")
				return TRUE
			w_items += I.w_class
			to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")
			return TRUE

	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = I
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, "<span class='notice'>You fill [RG] from [src]. Gross.</span>")
		return TRUE

	return ..()

/obj/structure/toilet/secret
	var/obj/item/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if (secret_type)
		secret = new secret_type(src)
		secret.desc += " It's a secret!"
		w_items += secret.w_class
		contents += secret


/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal. Comes complete with experimental urinal cake."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE
	var/exposed = FALSE // can you currently put an item inside
	var/obj/item/hiddenitem = null // what's in the urinal

/obj/structure/urinal/Initialize()
	. = ..()
	hiddenitem = new /obj/item/reagent_containers/food/snacks/urinalcake

/obj/structure/urinal/attack_hand(mob/user)
	if(..())
		return TRUE

	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/GM = user.pulling
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a tighter grip!</span>")
			return TRUE
		if(GM.loc != get_turf(src))
			to_chat(user, "<span class='notice'>[GM.name] needs to be on [src].</span>")
			return TRUE
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='danger'>[user] slams [GM] into [src]!</span>", "<span class='danger'>You slam [GM] into [src]!</span>")
		GM.adjustBruteLoss(8)
		return TRUE

	if(exposed)
		if(!hiddenitem)
			to_chat(user, "<span class='notice'>There is nothing in the drain holder.</span>")
			return TRUE
		if(ishuman(user))
			user.put_in_hands(hiddenitem)
		else
			hiddenitem.forceMove(get_turf(src))
		to_chat(user, "<span class='notice'>You fish [hiddenitem] out of the drain enclosure.</span>")
		hiddenitem = null
		return TRUE

/obj/structure/urinal/attackby(obj/item/I, mob/living/user, params)
	if(exposed)
		if(hiddenitem)
			to_chat(user, "<span class='warning'>There is already something in the drain enclosure.</span>")
			return TRUE
		if(I.w_class > 1)
			to_chat(user, "<span class='warning'>[I] is too large for the drain enclosure.</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in the drain enclosure!</span>")
			return TRUE
		hiddenitem = I
		to_chat(user, "<span class='notice'>You place [I] into the drain enclosure.</span>")
		return TRUE
	return ..()

/obj/structure/urinal/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(exposed)
		to_chat(user, "<span class='notice'>You start to screw the cap back into place...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 20))
			user.visible_message("[user] screws the cap back into place!", "<span class='notice'>You screw the cap back into place!</span>", "<span class='italics'>You hear metal and squishing noises.</span>")
			exposed = FALSE
	else
		to_chat(user, "<span class='notice'>You start to unscrew the cap to the drain protector...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 20))
			user.visible_message("[user] unscrews the cap to the drain protector!", "<span class='notice'>You unscrew the cap on the drain!</span>", "<span class='italics'>You hear metal and squishing noises.</span>")
			exposed = TRUE
	return TRUE

/obj/structure/urinal/update_icon()
	cut_overlays()
	if(!exposed)
		add_overlay("urinal_cap")


/obj/item/reagent_containers/food/snacks/urinalcake
	name = "urinal cake"
	desc = "The noble urinal cake, protecting the station's pipes from the station's pee. Do not eat."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "urinalcake"
	w_class = WEIGHT_CLASS_TINY
	list_reagents = list("chlorine" = 3, "ammonia" = 1)
	foodtype = TOXIC | GROSS

/obj/item/reagent_containers/food/snacks/urinalcake/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] squishes [src]!</span>", "<span class='notice'>You squish [src].</span>", "<i>You hear a squish.</i>")
	icon_state = "urinalcake_squish"
	addtimer(VARSET_CALLBACK(src, icon_state, "urinalcake"), 8)


/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	use_power = NO_POWER_USE
	var/on = FALSE
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/datum/looping_sound/showering/soundloop

/obj/machinery/shower/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/interact(mob/M)
	on = !on
	update_icon()
	add_fingerprint(M)
	if(on)
		START_PROCESSING(SSmachines, src)
		soundloop.start()
		wash_turf()
		for(var/atom/movable/G in loc)
			SEND_SIGNAL(G, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
			if(isliving(G))
				var/mob/living/L = G
				wash_mob(L)
			else if(isobj(G)) // Skip the light objects
				wash_obj(G)
	else
		soundloop.stop()
		if(isopenturf(loc))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")
	else
		return ..()

/obj/machinery/shower/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I]...</span>")
	if(I.use_tool(src, user, 50))
		switch(watertemp)
			if("normal")
				watertemp = "freezing"
			if("freezing")
				watertemp = "boiling"
			if("boiling")
				watertemp = "normal"
		user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I] to [watertemp] temperature.</span>")
		log_game("[key_name(user)] has wrenched a shower to [watertemp] at ([x],[y],[z])")
		add_hiddenprint(user)
	return TRUE


/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	cut_overlays()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER))
		if(watertemp == "freezing")
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new /obj/effect/mist(loc)
		else
			ismist = 1
			mymist = new /obj/effect/mist(loc)
	else if(ismist)
		ismist = 1
		mymist = new /obj/effect/mist(loc)
		spawn(250)
			if(!on && mymist)
				qdel(mymist)
				ismist = 0


/obj/machinery/shower/Crossed(atom/movable/AM)
	..()
	if(on)
		if(isliving(AM))
			var/mob/living/L = AM
			if(wash_mob(L)) //it's a carbon mob.
				var/mob/living/carbon/C = L
				C.slip(80,null,NO_SLIP_WHEN_WALKING)
		else if(isobj(AM))
			wash_obj(AM)


/obj/machinery/shower/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	if(isitem(O))
		var/obj/item/I = O
		I.acid_level = 0
		I.extinguish()


/obj/machinery/shower/proc/wash_turf()
	if(isturf(loc))
		var/turf/tile = loc
		SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
		tile.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		for(var/obj/effect/E in tile)
			if(is_cleanable(E))
				qdel(E)


/obj/machinery/shower/proc/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.wash_cream()
	L.ExtinguishMob()
	L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
	L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = TRUE
		check_heat(M)
		for(var/obj/item/I in M.held_items)
			wash_obj(I)

		if(M.back && wash_obj(M.back))
			M.update_inv_back(0)

		var/list/obscured = M.check_obscured_slots()

		if(M.head && wash_obj(M.head))
			M.update_inv_head()

		if(M.glasses && !(SLOT_GLASSES in obscured) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(SLOT_WEAR_MASK in obscured) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(SLOT_NECK in obscured) && wash_obj(M.wear_neck))
			M.update_inv_neck()

		if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
			M.update_inv_shoes()

		var/washgloves = FALSE
		if(M.gloves && !(HIDEGLOVES in obscured))
			washgloves = TRUE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_suit && wash_obj(H.wear_suit))
				H.update_inv_wear_suit()
			else if(H.w_uniform && wash_obj(H.w_uniform))
				H.update_inv_w_uniform()

			if(washgloves)
				SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

			if(!H.is_mouth_covered())
				H.lip_style = null
				H.update_body()

			if(H.belt && wash_obj(H.belt))
				H.update_inv_belt()
		else
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else
		SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

/obj/machinery/shower/proc/contamination_cleanse(atom/movable/thing)
	var/datum/component/radioactive/healthy_green_glow = thing.GetComponent(/datum/component/radioactive)
	if(!healthy_green_glow || QDELETED(healthy_green_glow))
		return
	var/strength = healthy_green_glow.strength
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(healthy_green_glow)
		return
	healthy_green_glow.strength -= max(0, (healthy_green_glow.strength - (RAD_BACKGROUND_RADIATION * 2)) * 0.2)

/obj/machinery/shower/process()
	if(on)
		wash_turf()
		for(var/atom/movable/AM in loc)
			if(isliving(AM))
				wash_mob(AM)
			else if(isobj(AM))
				wash_obj(AM)
			contamination_cleanse(AM)
	else
		return PROCESS_KILL

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)

/obj/machinery/shower/proc/check_heat(mob/living/carbon/C)
	if(watertemp == "freezing")
		C.adjust_bodytemperature(-80, 80)
		to_chat(C, "<span class='warning'>The water is freezing!</span>")
	else if(watertemp == "boiling")
		C.adjust_bodytemperature(35, 0, 500)
		C.adjustFireLoss(5)
		to_chat(C, "<span class='danger'>The water is searing!</span>")

/obj/machinery/shower/proc/check_clothes(mob/living/carbon/human/H)
	var/result
	if(H.wear_suit && (H.wear_suit.clothing_flags & SHOWEROKAY))
		return FALSE
	result &= (H.wear_suit && !(H.wear_suit.clothing_flags & SHOWEROKAY))
	result &= (H.w_uniform && !(H.w_uniform.clothing_flags & SHOWEROKAY))
	result &= (H.shoes && !(H.shoes.clothing_flags & SHOWEROKAY))
	result &= (H.ears && !(H.ears.clothing_flags & SHOWEROKAY))
	result &= (H.gloves && !(H.gloves.clothing_flags & SHOWEROKAY))
	result &= (H.wear_mask && !(H.wear_mask.clothing_flags & SHOWEROKAY))
	result &= (H.head && !(H.head.clothing_flags & SHOWEROKAY))
	return result


/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"


/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment
	var/busy_overlay = "sink-water"
	var/dispensedreagent = "water" // for whenever plumbing happens

/obj/structure/sink/attack_hand(mob/living/carbon/user)
	if(..())
		return TRUE
	if(!istype(user))
		return FALSE
	if(busy)
		to_chat(user, "<span class='notice'>Someone's already washing here.</span>")
		return TRUE

	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	user.visible_message("<span class='notice'>[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = TRUE
	update_icon()

	var/success = do_after(user, 40, target = src)
	busy = FALSE
	update_icon()

	if(!success)
		return TRUE

	user.visible_message("<span class='notice'>[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.wash_cream()
			H.regenerate_icons()
		user.drowsyness = max(user.drowsyness - rand(2,3), 0) //Washing your face wakes you up if you're falling asleep
	else
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

		if(ishuman(user))
			var/mob/living/carbon/human/dirtyboy
			dirtyboy.adjust_hygiene(10)
	return TRUE

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(!istype(O))
		return FALSE

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here!</span>")
		return TRUE

	if(istype(O, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = O
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				RG.reagents.add_reagent(dispensedreagent, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, "<span class='notice'>You fill [RG] from [src].</span>")
				return TRUE
			to_chat(user, "<span class='notice'>\The [RG] is full.</span>")
			return TRUE

	if(istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.cell)
			if(B.cell.charge > 0 && B.status == 1)
				flick("baton_active", src)
				var/stunforce = B.stunforce
				user.Paralyze(stunforce)
				user.stuttering = stunforce/20
				B.deductcharge(B.hitcost)
				user.visible_message("<span class='warning'>[user] shocks [user.p_them()]self while attempting to wash the active [B.name]!</span>", \
									"<span class='userdanger'>You unwisely attempt to wash [B] while it's still on.</span>")
				playsound(src, "sparks", 50, 1)
				return TRUE

	if(istype(O, /obj/item/mop))
		O.reagents.add_reagent("[dispensedreagent]", 5)
		to_chat(user, "<span class='notice'>You wet [O] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return TRUE

	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		new /obj/item/reagent_containers/glass/rag(src.loc)
		to_chat(user, "<span class='notice'>You tear off a strip of gauze and make a rag.</span>")
		G.use(1)
		return TRUE

	if(O.item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return TRUE

	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='notice'>You start washing [O]...</span>")
		busy = TRUE
		update_icon()

		var/success = do_after(user, 40, target = src)
		busy = FALSE
		update_icon()

		if(!success())
			return TRUE

		SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		O.acid_level = 0
		create_reagents(5)
		reagents.add_reagent(dispensedreagent, 5)
		reagents.reaction(O, TOUCH)
		user.visible_message("<span class='notice'>[user] washes [O] using [src].</span>", \
							"<span class='notice'>You wash [O] using [src].</span>")
		return TRUE

	return ..()

/obj/structure/sink/update_icon()
	if(!busy_overlay)
		return
	cut_overlays()
	if(busy)
		add_overlay(busy_overlay)

/obj/structure/sink/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"
	busy_overlay = "sink_alt-water"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	desc = "A puddle used for washing one's hands and face."
	icon_state = "puddle"
	resistance_flags = UNACIDABLE
	busy_overlay = null

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/deconstruct(disassembled = TRUE)
	qdel(src)


/obj/structure/curtain
	name = "curtain"
	desc = "Contains less than 1% mercury."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "open"
	color = "#ACD1E9" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = 0
	density = FALSE
	var/open = TRUE

/obj/structure/curtain/proc/toggle()
	open = !open
	update_icon()

/obj/structure/curtain/update_icon()
	if(!open)
		icon_state = "closed"
		layer = WALL_OBJ_LAYER
		density = TRUE
		open = FALSE

	else
		icon_state = "open"
		layer = SIGN_LAYER
		density = FALSE
		open = TRUE

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		color = input(user,"","Choose Color",color) as color
	else
		return ..()

/obj/structure/curtain/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 50)
	return TRUE

/obj/structure/curtain/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return TRUE

	user.visible_message("<span class='warning'>[user] cuts apart [src].</span>",
		"<span class='notice'>You start to cut apart [src].</span>", "You hear cutting.")
	if(I.use_tool(src, user, 50, volume=100) && !anchored)
		to_chat(user, "<span class='notice'>You cut apart [src].</span>")
		deconstruct()

	return TRUE


/obj/structure/curtain/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/curtain.ogg', 50, 1)
	toggle()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth (loc, 2)
	new /obj/item/stack/sheet/plastic (loc, 2)
	new /obj/item/stack/rods (loc, 1)
	qdel(src)

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, 1)
