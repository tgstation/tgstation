<<<<<<< HEAD
/obj/item/weapon/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	flags = OPENCONTAINER
	spillable = 1


/obj/item/weapon/reagent_containers/glass/attack(mob/M, mob/user, obj/target)
	if(!canconsume(M, user))
		return

	if(!spillable)
		return

	if(!reagents || !reagents.total_volume)
		user << "<span class='warning'>[src] is empty!</span>"
		return

	if(istype(M))
		if(user.a_intent == "harm")
			var/R
			M.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [M]!</span>", \
							"<span class='userdanger'>[user] splashes the contents of [src] onto [M]!</span>")
			if(reagents)
				for(var/datum/reagent/A in reagents.reagent_list)
					R += A.id + " ("
					R += num2text(A.volume) + "),"
			reagents.reaction(M, TOUCH)
			add_logs(user, M, "splashed", R)
			reagents.clear_reagents()
		else
			if(M != user)
				M.visible_message("<span class='danger'>[user] attempts to feed something to [M].</span>", \
							"<span class='userdanger'>[user] attempts to feed something to you.</span>")
				if(!do_mob(user, M))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				M.visible_message("<span class='danger'>[user] feeds something to [M].</span>", "<span class='userdanger'>[user] feeds something to you.</span>")
				add_logs(user, M, "fed", reagentlist(src))
			else
				user << "<span class='notice'>You swallow a gulp of [src].</span>"
			var/fraction = min(5/reagents.total_volume, 1)
			reagents.reaction(M, INGEST, fraction)
			spawn(5)
				reagents.trans_to(M, 5)
			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/weapon/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || !check_allowed_items(target,target_self=1)) return

	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(target.reagents && !target.reagents.total_volume)
			user << "<span class='warning'>[target] is empty and can't be refilled!</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='notice'>[src] is full.</span>"
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		user << "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>"

	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			user << "<span class='warning'>[src] is empty!</span>"
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='notice'>[target] is full.</span>"
			return


		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		user << "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>"

	else if(reagents.total_volume)
		if(user.a_intent == "harm")
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
								"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, TOUCH)
			reagents.clear_reagents()

/obj/item/weapon/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness)
		var/added_heat = (hotness / 100) //ishot returns a temperature
		if(reagents)
			if(reagents.chem_temp < hotness) //can't be heated to be hotter than the source
				reagents.chem_temp += added_heat
				user << "<span class='notice'>You heat [src] with [I].</span>"
				reagents.handle_reactions()
			else
				user << "<span class='warning'>[src] is already hotter than [I]!</span>"

	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				user << "<span class='notice'>[src] is full.</span>"
			else
				user << "<span class='notice'>You break [E] in [src].</span>"
				reagents.add_reagent("eggyolk", 5)
				qdel(E)
			return
	..()


/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	materials = list(MAT_GLASS=500)

/obj/item/weapon/reagent_containers/glass/beaker/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	cut_overlays()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 79)
				filling.icon_state = "[icon_state]75"
			if(80 to 90)
				filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	materials = list(MAT_GLASS=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	materials = list(MAT_METAL=3000)
	volume = 50
	amount_per_transfer_from_this = 10
	origin_tech = "materials=2;engineering=3;plasmatech=3"
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact/New()
	..()
	reagents.set_reacting(FALSE)

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=3000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)
	flags = OPENCONTAINER
	origin_tech = "bluespace=5;materials=4;plasmatech=4"

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric
	list_reagents = list("sacid" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/slime
	list_reagents = list("slimejelly" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/styptic
	name = "styptic reserve tank"
	list_reagents = list("styptic_powder" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/silver_sulfadiazine
	name = "silver sulfadiazine reserve tank"
	list_reagents = list("silver_sulfadiazine" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/charcoal
	name = "antitoxin reserve tank"
	list_reagents = list("charcoal" = 50)

/obj/item/weapon/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list("epinephrine" = 50)

/obj/item/weapon/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	materials = list(MAT_METAL=200)
	w_class = 3
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,15,20,25,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	flags_inv = HIDEHAIR
	slot_flags = SLOT_HEAD
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0) //Weak melee protection, because you can wear it on your head
	slot_equipment_priority = list( \
		slot_back, slot_wear_id,\
		slot_w_uniform, slot_wear_suit,\
		slot_wear_mask, slot_head,\
		slot_shoes, slot_gloves,\
		slot_ears, slot_glasses,\
		slot_belt, slot_s_store,\
		slot_l_store, slot_r_store,\
		slot_generic_dextrous_storage
	)

/obj/item/weapon/reagent_containers/glass/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/weapon/mop))
		if(reagents.total_volume < 1)
			user << "<span class='warning'>[src] is out of water!</span>"
		else
			reagents.trans_to(O, 5)
			user << "<span class='notice'>You wet [O] in [src].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	else if(isprox(O))
		user << "<span class='notice'>You add [O] to [src].</span>"
		qdel(O)
		user.unEquip(src)
		qdel(src)
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
	else
		..()

/obj/item/weapon/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if(slot == slot_head && reagents.total_volume)
		user << "<span class='userdanger'>[src]'s contents spill all over you!</span>"
		reagents.reaction(user, TOUCH)
		reagents.clear_reagents()

/obj/item/weapon/reagent_containers/glass/bucket/equip_to_best_slot(var/mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(slot_head)
		slot_equipment_priority.Remove(slot_head)
		. = ..()
		slot_equipment_priority.Insert(index, slot_head)
		return
	return ..()
=======

////////////////////////////////////////////////////////////////////////////////
/// (Mixing) Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	item_state = "null"
	w_type = RECYK_GLASS
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	flags = FPRINT  | OPENCONTAINER

	var/label_text = ""

	//This is absolutely terrible
	// TODO To remove this, return 1 on every attackby() that handles reagent_containers.
	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/structure/centrifuge/,
		/obj/item/weapon/storage,
		/obj/item/weapon/solder,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/item/weapon/electrolyzer,
		/obj/machinery/bot/medbot,
		/obj/machinery/computer/pandemic,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/centrifuge,
		/obj/machinery/cooking/icemachine,
		/obj/machinery/sleeper,
		/obj/machinery/anomaly,
		/obj/machinery/bunsen_burner,
		/obj/item/weapon/sword/venom,
		/obj/item/weapon/cylinder
		)

/obj/item/weapon/reagent_containers/glass/get_rating()
	return volume / 50

/obj/item/weapon/reagent_containers/glass/New()
	..()
	base_name = name
	update_icon() //Used by all subtypes for reagent filling, and allows roundstart lids

/obj/item/weapon/reagent_containers/glass/mop_act(obj/item/weapon/mop/M, mob/user)
	return is_open_container()

/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	..()
	if(!is_open_container())
		to_chat(user, "<span class='info'>An airtight lid seals it completely.</span>")

/obj/item/weapon/reagent_containers/glass/attack_self()
	..()
	if(is_open_container())
		to_chat(usr, "<span class = 'notice'>You put the lid on \the [src].")
		flags ^= OPENCONTAINER
	else
		to_chat(usr, "<span class = 'notice'>You take the lid off \the [src].")
		flags |= OPENCONTAINER
	update_icon()

/obj/item/weapon/reagent_containers/glass/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	if (is_type_in_list(target, can_be_placed_into))
		return

	var/transfer_result = transfer(target, user, splashable_units = -1) // Potentially splash with everything inside

	if((transfer_result > 10) && (isturf(target) || istype(target, /obj/machinery/portable_atmospherics/hydroponics)))	//if we're splashing a decent amount of reagent on the floor
		playsound(get_turf(target), 'sound/effects/slosh.ogg', 25, 1)													//or in an hydro tray, then we make some noise.

/obj/item/weapon/reagent_containers/glass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [src.name]","Label",src.label_text))
		if (!Adjacent(user) || user.stat) return
		if(length(tmp_label) > 10)
			to_chat(user, "<span class='warning'>The label can be at most 10 characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			src.label_text = tmp_label
			src.update_name_label()

/obj/item/weapon/reagent_containers/glass/proc/update_name_label()
	if(src.label_text == "")
		src.name = src.base_name
	else
		src.name = "[src.base_name] ([src.label_text])"

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	starting_materials = list(MAT_GLASS = 500)
	origin_tech = "materials=1"

/obj/item/weapon/reagent_containers/glass/beaker/attackby(obj/item/weapon/W, mob/user)
	if(src.type == /obj/item/weapon/reagent_containers/glass/beaker && istype(W, /obj/item/weapon/surgicaldrill)) //regular beakers only
		to_chat(user, "You begin drilling holes into the bottom of \the [src].")
		playsound(user, 'sound/machines/juicer.ogg', 50, 1)
		if(do_after(user, src, 60))
			to_chat(user, "You drill six holes through the bottom of \the [src].")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/cylinder/I = new (get_turf(user))
				user.put_in_hands(I)
			else
				new /obj/item/weapon/cylinder(get_turf(src.loc))
			qdel(src)
		return
	return ..()

/obj/item/weapon/reagent_containers/glass/beaker/mop_act(obj/item/weapon/mop/M, mob/user)
	if(..())
		if (src.reagents.total_volume >= 1)
			switch(src.reagents.total_volume)
				if(1 to 30)
					if(M.reagents.total_volume >= 3)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 1)
					to_chat(user, "<span class='notice'>You barely manage to wet [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				if(30 to 100)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 2)
					to_chat(user, "<span class='notice'>You manage to wet [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				if(100 to INFINITY)
					if(M.reagents.total_volume >= 10)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 5)
					to_chat(user, "<span class='notice'>You manage to soak [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				else
					to_chat(user, "What")
					return 1
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
		return 1

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[icon_state]-10"
			if(10 to 24) 	filling.icon_state = "[icon_state]10"
			if(25 to 49)	filling.icon_state = "[icon_state]25"
			if(50 to 74)	filling.icon_state = "[icon_state]50"
			if(75 to 79)	filling.icon_state = "[icon_state]75"
			if(80 to 90)	filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		overlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	starting_materials = list(MAT_GLASS = 1500)
	volume = 100
	possible_transfer_amounts = list(5,10,15,25,30,50,100)

/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg
	var/obj/item/weapon/robot_module/holder

/obj/item/weapon/reagent_containers/glass/beaker/large/cyborg/New(loc,_holder)
	..()
	holder = _holder

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "stasis beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 50 units."
	icon_state = "beakernoreact"
	starting_materials = list(MAT_GLASS = 500)
	volume = 50
	flags = FPRINT  | OPENCONTAINER | NOREACT
	origin_tech = "bluespace=3;materials=4"

/obj/item/weapon/reagent_containers/glass/beaker/noreact/large
	name = "large stasis beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 100 units."
	icon_state = "beakernoreactlarge"
	starting_materials = list(MAT_GLASS = 1500)
	volume = 100
	origin_tech = "bluespace=4;materials=6"

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A newly-developed high-capacity beaker, courtesy of bluespace research. Can hold up to 200 units."
	icon_state = "beakerbluespace"
	starting_materials = list(MAT_GLASS = 2000)
	volume = 200
	w_type = RECYK_GLASS
	possible_transfer_amounts = list(5,10,15,25,30,50,100,200)
	flags = FPRINT  | OPENCONTAINER
	origin_tech = "bluespace=2;materials=3"

/obj/item/weapon/reagent_containers/glass/beaker/bluespace/large
	name = "large bluespace beaker"
	desc = "A prototype ultra-capacity beaker, courtesy of bluespace research. Can hold up to 300 units."
	icon_state = "beakerbluespacelarge"
	starting_materials = list(MAT_GLASS = 5000)
	volume = 300
	possible_transfer_amounts = list(5,10,15,25,30,50,100,150,200,300)
	origin_tech = "bluespace=3;materials=5"

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	starting_materials = list(MAT_GLASS = 250)
	volume = 25
	possible_transfer_amounts = list(5,10,15,25)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone

	New()
		..()
		reagents.add_reagent(CRYOXADONE, 30)

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric

	New()
		..()
		reagents.add_reagent(SACID, 50)

/obj/item/weapon/reagent_containers/glass/beaker/slime

	New()
		..()
		reagents.add_reagent(SLIMEJELLY, 50)

/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = FPRINT | OPENCONTAINER
	slot_flags = SLOT_HEAD

/obj/item/weapon/reagent_containers/glass/bucket/mop_act(obj/item/weapon/mop/M, mob/user)
	if(..())
		if (src.reagents.total_volume >= 1)
			switch(src.reagents.total_volume)
				if(1 to 30)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 1)
					to_chat(user, "<span class='notice'>You barely manage to wet [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				if(30 to 100)
					if(M.reagents.total_volume >= 5)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 2)
					to_chat(user, "<span class='notice'>You manage to wet [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				if(100 to INFINITY)
					if(M.reagents.total_volume >= 10)
						to_chat(user, "<span class='notice'>You dip \the [M]'s head into \the [src] but don't soak anything up.</span>")
						return 1
					src.reagents.trans_to(M, 5)
					to_chat(user, "<span class='notice'>You manage to soak [M]</span>")
					playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
				else
					to_chat(user, "What")
					return 1
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
		return 1

/obj/item/weapon/reagent_containers/glass/bucket/attackby(var/obj/D, mob/user as mob)
	if(isprox(D))
		to_chat(user, "You add \the [D] to \the [src].")
		qdel(D)
		D = null
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		user.drop_from_inventory(src)
		qdel(src)

/*
/obj/item/weapon/reagent_containers/glass/blender_jug
	name = "Blender Jug"
	desc = "A blender jug, part of a blender."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender_jug_e"
	volume = 100

	on_reagent_change()
		switch(src.reagents.total_volume)
			if(0)
				icon_state = "blender_jug_e"
			if(1 to 75)
				icon_state = "blender_jug_h"
			if(76 to 100)
				icon_state = "blender_jug_f"

/obj/item/weapon/reagent_containers/glass/canister		//not used apparantly
	desc = "It's a canister. Mainly used for transporting fuel."
	name = "canister"
	icon = 'icons/obj/tank.dmi'
	icon_state = "canister"
	item_state = "canister"
	m_amt = 300
	g_amt = 0
	w_class = W_CLASS_LARGE

	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60)
	volume = 120
	flags = FPRINT

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker0"
	amount_per_transfer_from_this = 10
	flags = FPRINT  | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent(FLUOROSURFACTANT, 20)

*/

//No idea if this actually works anymore. Please handle carefully
/obj/item/weapon/reagent_containers/glass/kettle
	name = "Kettle"
	desc = "A pot made for holding hot drinks. Can hold up to 75 units."
	icon_state = "kettle"
	starting_materials = list(MAT_IRON = 200)
	volume = 75
	w_type = RECYK_GLASS
	amount_per_transfer_from_this = 10
	flags = FPRINT  | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/kettle/red
	icon_state = "kettle_red"

/obj/item/weapon/reagent_containers/glass/kettle/blue
	icon_state = "kettle_blue"

/obj/item/weapon/reagent_containers/glass/kettle/purple
	icon_state = "kettle_purple"

/obj/item/weapon/reagent_containers/glass/kettle/green
	icon_state = "kettle_green"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
