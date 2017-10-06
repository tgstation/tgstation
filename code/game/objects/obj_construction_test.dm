//this is a test item for obj construction

/obj/item/shitcode_test_phase_1
	name = "The shitcode item phase"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "box"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/construction_phase = 1
	var/is_being_constructed
	var/obj/item/melee/baton/baton
	var/obj/item/gun/energy/taser/taser

/obj/item/shitcode_test_phase_1/Destroy()
	QDEL_NULL(baton)
	QDEL_NULL(taser)
	return ..()

/obj/item/shitcode_test_phase_1/handle_atom_del(atom/A)
	if(A == baton)
		baton = null
	else if (A == taser)
		taser = null

/obj/item/shitcode_test_phase_1/update_icon()
	switch(construction_phase)
		if(1)
			icon_state = "syringe_kit"
		if(2)
			icon_state = "secbox"
		if(3)
			icon_state = "monkeycubebox"
	cut_overlays()
	if(obj_integrity < integrity_failure)
		add_overlay("beaker")
	if(baton)
		add_overlay(baton)
	if(taser)
		add_overlay(taser)

/obj/item/shitcode_test_phase_1/attack_self(mob/living/user)
	if(user.a_intent != INTENT_HELP)
		return ..()
	if(is_being_constructed)
		return
	switch(construction_phase)
		if(1)
			user.visible_message("[user] begins taking apart [src]", "<span class='notice'>You begin taking apart [src]</span>", "<span class='notice'>You hear someone tinkering with something</span>")
			if(do_after(user, 20, TRUE, src))   
				to_chat(user, "<span class='notice'>You take apart [src]</span>")
				new /obj/item/stack/sheet/mineral/wood(user.drop_location(), 2)
				qdel(src)
			return
		if(2)
			var/obj/item/thing_to_remove
			if(baton && taser)
				var/res = alert(user, "Remove which item?", null, "Baton", "Taser", "Nevermind")    //this should be a tgui menu but im lazy so imagine it is for the sake of demonstration
				if(!res || res == "Nevermind" || loc != user || (!baton && !taser) || user.incapacitated())
					return
				if(res == "Baton" && baton)
					thing_to_remove = baton
					baton = null
				else if(res == "Taser")
					thing_to_remove = taser
					taser = null
				else
					return
			else
				thing_to_remove = baton || taser
				baton = null
				taser = null
			if(thing_to_remove)
				user.visible_message("[user] removes [thing_to_remove] from [src]", "<span class='notice'>You remove [thing_to_remove] from [src]</span>", "You hear a click.")
				user.put_in_hands(thing_to_remove)
				update_icon()
			else
				user.visible_message("[user] begins taking apart [src]</span>", "<span class='notice'>You begin taking apart [src]</span>", "You hear someone tinkering with something.")
				is_being_constructed = TRUE
				if(do_after(user, 20, TRUE, src))   
					to_chat(user, "<span class='notice'>You remove some wood from [src]</span>")
					new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
					--construction_phase
					UpdateHealths()
					update_icon()
				is_being_constructed = FALSE
			return
	return ..()

/obj/item/shitcode_test_phase_1/attackby(mob/living/user, obj/item/I, params)
	if(user.a_intent != INTENT_HELP)
		return ..()
	if(is_being_constructed)
		return
	if(HandleRepair(user, I))
		return
	switch(construction_phase)
		if(1)
			var/obj/item/stack/sheet/mineral/wood/W = I
			if(istype(W))
				if(W.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least 2 of [W] to continue building [src]</span>")
					return
				user.visible_message("[user] begins adding more wood to [src]", "<span class='notice'>You begin adding more wood to [src]</span>", "You hear wooden planks being moved.")
				is_being_constructed = TRUE
				if(do_after(user, 20, TRUE, src, extra_checks = CALLBACK(GLOBAL_PROC, /proc/check_has_at_least_n_in_stack, W, 2)))
					ASSERT(W.use(2))
					++construction_phase
					UpdateHealths()
					update_icon()
				else
					to_chat(user, "<span class='warning'>You were interrupted!</span>")   
				is_being_constructed = FALSE
		if(2)
			var/attached = FALSE
			if(!baton)
				baton = I
				attached = istype(baton)
				if(!attached)
					baton = null
			if(!taser && !attached)
				taser = I
				attached = istype(taser)
				if(!attached)
					taser = null
			if(attached)
				user.visible_message("[user] attaches [I] to [src]", "<span class='notice'>You attach [I] to [src]</span>", "You hear a click.")
				user.transferItemToLoc(I, src)
				return
			if(istype(I, /obj/item/coin/diamond))
				user.visible_message("[user] inserts [I] into [src]", "<span class='notice'>You insert [I] into [src]</span>", "You hear a coin enter a slot")
				qdel(I)
				new /obj/structure/shitcode_test_phase_2(user.drop_location(), src)
				return

	return ..()

/obj/item/shitcode_test_phase_1/proc/UpdateHealths()
	var/new_max_integ
	var/new_integ_failure
	switch(construction_phase)
		if(1)
			new_max_integ = 100
			new_integ_failure = 0
		if(2)
			new_max_integ = 200
			new_integ_failure = 100
	modify_max_integrity(new_max_integ, FALSE, new_failure_integrity = new_integ_failure)

/obj/item/shitcode_test_phase_1/obj_break(damage_flag)
	if(construction_phase == 1)
		return
	--construction_phase
	UpdateHealths()
	update_icon()

/proc/check_has_at_least_n_in_stack(obj/item/stack/S, n)
	return S.get_amount() >= n

/obj/item/shitcode_test_phase_1/proc/HandleRepair(mob/living/user, obj/item/I)
	if(istype(I, /obj/item/screwdriver))
		is_being_constructed = TRUE
		. = do_after(user, 20 * I.toolspeed, TRUE, src)
		if(.)
			obj_integrity = max_integrity
			update_icon()

/obj/structure/shitcode_test_phase_2
	name = "The shitcode structure phase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "monkeycubebox"
	resistance_flags = FLAMMABLE
	var/construction_phase = 1
	var/is_being_constructed
	var/obj/item/melee/baton/baton	//typepaths if anything initially
	var/obj/item/gun/energy/taser/taser

/obj/structure/shitcode_test_phase_2/Initialize(mapload, obj/item/shitcode_test_phase_2/S)
	. = ..()
	if(!S)
		if(baton)
			baton = new baton
		if(taser)
			taser = new taser
		return

	baton = S.baton
	S.baton = null
	taser = S.taser
	S.taser = null

	var/current_mi = max_integrity
	max_integrity = S.max_integrity
	obj_integrity = S.obj_integrity
	modify_max_integrity(current_mi)

	qdel(S)
