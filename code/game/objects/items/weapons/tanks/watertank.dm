//Hydroponics tank and base code
/obj/item/weapon/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 30)
	resistance_flags = FIRE_PROOF

	var/obj/item/weapon/noz
	var/on = 0
	var/volume = 500

/obj/item/weapon/watertank/New()
	..()
	create_reagents(volume)
	noz = make_noz()

/obj/item/weapon/watertank/ui_action_click()
	toggle_mister()

/obj/item/weapon/watertank/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return 1

/obj/item/weapon/watertank/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"
	if (usr.get_item_by_slot(usr.getBackSlot()) != src)
		to_chat(usr, "<span class='warning'>The watertank must be worn properly to use!</span>")
		return
	if(usr.incapacitated())
		return
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		if(noz == null)
			noz = make_noz()

		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			on = 0
			to_chat(user, "<span class='warning'>You need a free hand to hold the mister!</span>")
			return
		noz.loc = user
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/weapon/watertank/proc/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister(src)

/obj/item/weapon/watertank/equipped(mob/user, slot)
	..()
	if(slot != slot_back)
		remove_noz()

/obj/item/weapon/watertank/proc/remove_noz()
	if(ismob(noz.loc))
		var/mob/M = noz.loc
		M.temporarilyRemoveItemFromInventory(noz, TRUE)
	return

/obj/item/weapon/watertank/Destroy()
	if (on)
		qdel(noz)
	return ..()

/obj/item/weapon/watertank/attack_hand(mob/user)
	if(src.loc == user)
		ui_action_click()
		return
	..()

/obj/item/weapon/watertank/MouseDrop(obj/over_object)
	var/mob/M = src.loc
	if(istype(M) && istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/weapon/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return 1
	else
		return ..()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/weapon/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	item_state = "mister"
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	flags = NODROP | NOBLUDGEON
	container_type = OPENCONTAINER
	slot_flags = 0

	var/obj/item/weapon/watertank/tank

/obj/item/weapon/reagent_containers/spray/mister/New(parent_tank)
	..()
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
		loc = tank
	return

/obj/item/weapon/reagent_containers/spray/mister/dropped(mob/user)
	..()
	to_chat(user, "<span class='notice'>The mister snaps back onto the watertank.</span>")
	tank.on = 0
	loc = tank

/obj/item/weapon/reagent_containers/spray/mister/attack_self()
	return

/proc/check_tank_exists(parent_tank, mob/living/carbon/human/M, obj/O)
	if (!parent_tank || !istype(parent_tank, /obj/item/weapon/watertank))	//To avoid weird issues from admin spawns
		qdel(O)
		return 0
	else
		return 1

/obj/item/weapon/reagent_containers/spray/mister/Move()
	..()
	if(loc != tank.loc)
		loc = tank.loc

/obj/item/weapon/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it
		return
	..()

//Janitor tank
/obj/item/weapon/watertank/janitor
	name = "backpack water tank"
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"

/obj/item/weapon/watertank/janitor/New()
	..()
	reagents.add_reagent("cleaner", 500)

/obj/item/weapon/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()

/obj/item/weapon/watertank/janitor/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister/janitor(src)

/obj/item/weapon/reagent_containers/spray/mister/janitor/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define RESIN_LAUNCHER 1
#define RESIN_FOAM 2

/obj/item/weapon/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refridgerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, resin launcher and a smaller scale resin foamer."
	item_state = "waterbackpackatmos"
	icon_state = "waterbackpackatmos"
	volume = 200
	slowdown = 0

/obj/item/weapon/watertank/atmos/New()
	..()
	reagents.add_reagent("water", 200)

/obj/item/weapon/watertank/atmos/make_noz()
	return new /obj/item/weapon/extinguisher/mini/nozzle(src)

/obj/item/weapon/watertank/atmos/dropped(mob/user)
	..()
	icon_state = "waterbackpackatmos"
	if(istype(noz, /obj/item/weapon/extinguisher/mini/nozzle))
		var/obj/item/weapon/extinguisher/mini/nozzle/N = noz
		N.nozzle_mode = 0

/obj/item/weapon/extinguisher/mini/nozzle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	safety = 0
	max_water = 200
	power = 8
	force = 10
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	var/obj/item/weapon/watertank/tank
	var/nozzle_mode = 0
	var/metal_synthesis_cooldown = 0
	var/resin_cooldown = 0

/obj/item/weapon/extinguisher/mini/nozzle/New(parent_tank)
	..()
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents
		max_water = tank.volume
		loc = tank


/obj/item/weapon/extinguisher/mini/nozzle/Move()
	..()
	if(loc != tank.loc)
		loc = tank
	return

/obj/item/weapon/extinguisher/mini/nozzle/attack_self(mob/user)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = RESIN_LAUNCHER
			tank.icon_state = "waterbackpackatmos_1"
			to_chat(user, "Swapped to resin launcher")
			return
		if(RESIN_LAUNCHER)
			nozzle_mode = RESIN_FOAM
			tank.icon_state = "waterbackpackatmos_2"
			to_chat(user, "Swapped to resin foamer")
			return
		if(RESIN_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.icon_state = "waterbackpackatmos_0"
			to_chat(user, "Swapped to water extinguisher")
			return
	return

/obj/item/weapon/extinguisher/mini/nozzle/dropped(mob/user)
	..()
	to_chat(user, "<span class='notice'>The nozzle snaps back onto the tank!</span>")
	tank.on = 0
	loc = tank

/obj/item/weapon/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)
	if(nozzle_mode == RESIN_LAUNCHER)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < 100)
			to_chat(user, "<span class='warning'>You need at least 100 units of water to use the resin launcher!</span>")
			return
		if(resin_cooldown)
			to_chat(user, "<span class='warning'>Resin launcher is still recharging...</span>")
			return
		resin_cooldown = TRUE
		R.remove_any(100)
		var/obj/effect/resin_container/A = new (get_turf(src))
		log_game("[key_name_admin(user)] used Resin Launcher at [get_area(user)] [COORD(user)].")
		playsound(src,'sound/items/syringeproj.ogg',40,1)
		for(var/a=0, a<5, a++)
			step_towards(A, target)
			sleep(2)
		A.Smoke()
		spawn(100)
			if(src)
				resin_cooldown = FALSE
		return
	if(nozzle_mode == RESIN_FOAM)
		if(!Adj|| !isturf(target))
			return
		for(var/S in target)
			if(istype(S, /obj/effect/particle_effect/foam/metal/resin) || istype(S, /obj/structure/foamedmetal/resin))
				to_chat(user, "<span class='warning'>There's already resin here!</span>")
				return
		if(metal_synthesis_cooldown < 5)
			var/obj/effect/particle_effect/foam/metal/resin/F = new (get_turf(target))
			F.amount = 0
			metal_synthesis_cooldown++
			spawn(100)
				metal_synthesis_cooldown--
		else
			to_chat(user, "<span class='warning'>Resin foam mix is still being synthesized...</span>")
			return

/obj/effect/resin_container
	name = "resin container"
	desc = "A compacted ball of expansive resin, used to repair the atmosphere in a room, or seal off breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = 0
	pass_flags = PASSTABLE

/obj/effect/resin_container/proc/Smoke()
	var/obj/effect/particle_effect/foam/metal/resin/S = new /obj/effect/particle_effect/foam/metal/resin(get_turf(loc))
	S.amount = 3
	playsound(src,'sound/effects/bamf.ogg',100,1)
	qdel(src)

#undef EXTINGUISHER
#undef RESIN_LAUNCHER
#undef RESIN_FOAM

/obj/item/weapon/reagent_containers/chemtank
	name = "backpack chemical injector"
	desc = "A chemical autoinjector that can be carried on your back."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpackatmos"
	item_state = "waterbackpackatmos"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/activate_injector)

	var/on = 0
	volume = 300
	var/usage_ratio = 5 //5 unit added per 1 removed
	var/injection_amount = 1
	amount_per_transfer_from_this = 5
	container_type = OPENCONTAINER
	spillable = 0
	possible_transfer_amounts = list(5,10,15)

/obj/item/weapon/reagent_containers/chemtank/ui_action_click()
	toggle_injection()

/obj/item/weapon/reagent_containers/chemtank/item_action_slot_check(slot, mob/user)
	if(slot == slot_back)
		return 1

/obj/item/weapon/reagent_containers/chemtank/proc/toggle_injection()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if (user.get_item_by_slot(slot_back) != src)
		to_chat(user, "<span class='warning'>The chemtank needs to be on your back before you can activate it!</span>")
		return
	if(on)
		turn_off()
	else
		turn_on()

//Todo : cache these.
/obj/item/weapon/reagent_containers/chemtank/proc/update_filling()
	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "backpack-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 15)
				filling.icon_state = "backpack-10"
			if(16 to 60)
				filling.icon_state = "backpack50"
			if(61 to INFINITY)
				filling.icon_state = "backpack100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/weapon/reagent_containers/chemtank/worn_overlays(var/isinhands = FALSE) //apply chemcolor and level
	. = list()
	//inhands + reagent_filling
	if(!isinhands && reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "backpackmob-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 15)
				filling.icon_state = "backpackmob-10"
			if(16 to 60)
				filling.icon_state = "backpackmob50"
			if(61 to INFINITY)
				filling.icon_state = "backpackmob100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/weapon/reagent_containers/chemtank/proc/turn_on()
	on = 1
	START_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] turns on.</span>")

/obj/item/weapon/reagent_containers/chemtank/proc/turn_off()
	on = 0
	STOP_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] turns off.</span>")

/obj/item/weapon/reagent_containers/chemtank/process()
	if(!ishuman(loc))
		turn_off()
		return
	if(!reagents.total_volume)
		turn_off()
		return
	var/mob/living/carbon/human/user = loc
	if(user.back != src)
		turn_off()
		return

	var/used_amount = injection_amount/usage_ratio
	reagents.reaction(user, INJECT,injection_amount,0)
	reagents.trans_to(user,used_amount,multiplier=usage_ratio)
	update_filling()
	user.update_inv_back() //for overlays update

//Operator backpack spray
/obj/item/weapon/watertank/operator
	name = "backpack water tank"
	desc = "A New Russian backpack spray for systematic cleansing of carbon lifeforms."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 2000
	slowdown = 0

/obj/item/weapon/watertank/operator/New()
	..()
	reagents.add_reagent("mutagen",350)
	reagents.add_reagent("napalm",125)
	reagents.add_reagent("welding_fuel",125)
	reagents.add_reagent("clf3",300)
	reagents.add_reagent("cryptobiolin",350)
	reagents.add_reagent("plasma",250)
	reagents.add_reagent("condensedcapsaicin",500)

/obj/item/weapon/reagent_containers/spray/mister/operator
	name = "janitor spray nozzle"
	desc = "A mister nozzle attached to several extended water tanks. It suspiciously has a compressor in the system and is labelled entirely in New Cyrillic."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 100
	possible_transfer_amounts = list(75,100,150)

/obj/item/weapon/watertank/operator/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister/operator(src)
