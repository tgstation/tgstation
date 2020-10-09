#define ALTAR_INACTIVE 0
#define ALTAR_STAGEONE 1
#define ALTAR_STAGETWO 2
#define ALTAR_STAGETHREE 3
#define ALTAR_TIME 9.5 SECONDS

/** This structure acts as a source of moisture loving cell lines,
as well as a location where a hidden item can somtimes be retrieved
at the cost of risking a vicious bite.**/
/obj/structure/moisture_trap
	name = "moisture trap"
	desc = "A device installed in order to control moisture in poorly ventilated areas.\nThe stagnant water inside basin seems to produce serious biofouling issues when improperly maintained.\nThis unit in particular seems to be teeming with life!\nWho thought mother Gaia could assert herself so vigoriously in this sterile and desolate place?"
	icon_state = "moisture_trap"
	anchored = TRUE
	density = FALSE
	///This var stores the hidden item that might be able to be retrieved from the trap
	var/obj/item/hidden_item
	///This var determines if there is a chance to recieve a bite when sticking your hand into the water.
	var/critter_infested = TRUE
	var/list/loot = list(
					/obj/item/food/meat/slab/human/mutant/skeleton = 35,
					/obj/item/food/meat/slab/human/mutant/zombie = 15,
					/obj/item/trash/can = 15,
					/obj/item/clothing/head/helmet/skull = 10,
					/obj/item/restraints/handcuffs = 4,
					/obj/item/restraints/handcuffs/cable/red = 1,
					/obj/item/restraints/handcuffs/cable/blue = 1,
					/obj/item/restraints/handcuffs/cable/green = 1,
					/obj/item/restraints/handcuffs/cable/pink = 1,
					/obj/item/restraints/handcuffs/alien = 2,
					/obj/item/coin/bananium = 9,
					/obj/item/kitchen/knife/butcher = 5,
					/obj/item/coin/mythril = 1) //the loot table isn't that great and should probably be improved and expanded later.


/obj/structure/moisture_trap/Initialize()
	. = ..()
	if(prob(40))
		critter_infested = FALSE
	if(prob(75))
		var/picked_item = pickweight(loot)
		hidden_item = new picked_item(src)
	loot = null
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOIST, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 20)

/obj/structure/moisture_trap/Destroy()
	if(hidden_item)
		QDEL_NULL(hidden_item)
	return ..()

///This proc checks if we are able to reach inside the trap to interact with it.
/obj/structure/moisture_trap/proc/CanReachInside(mob/user)
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	if((living_user.mobility_flags & MOBILITY_STAND) && ishuman(living_user)) //I dont think monkeys can crawl on command.
		return FALSE
	return TRUE

/obj/structure/moisture_trap/attack_hand(mob/user)
	. = ..()
	if(iscyborg(user) || isalien(user))
		return
	if(!CanReachInside(user))
		to_chat(user, "<span class='warning'>You need to lie down to reach into [src].</span>")
		return
	to_chat(user, "<span class='notice'>You reach down into the cold water of the basin.</span>")
	if(!do_after(user, 2 SECONDS, target = src))
		return
	if(hidden_item)
		user.put_in_hands(hidden_item)
		to_chat(user, "<span class='notice'>As you poke around inside [src] you feel the contours of something hidden below the murky waters.</span>\n<span class='nicegreen'>You retrieve [hidden_item] from [src].</span>")
		hidden_item = null
		return
	if(critter_infested && prob(50) && iscarbon(user))
		var/mob/living/carbon/bite_victim = user
		var/obj/item/bodypart/affecting = bite_victim.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		if(affecting?.receive_damage(30))

			to_chat(user, "<span class='danger'>You feel a sharp as an unseen creature sinks it's [pick("fangs", "beak", "proboscis")] into your arm!</span>")
			bite_victim.update_damage_overlays()
			playsound(src,'sound/weapons/bite.ogg', 70, TRUE)
			return
	to_chat(user, "<span class='warning'>You find nothing of value...</span>")

/obj/structure/moisture_trap/attackby(obj/item/I, mob/user, params)
	if(iscyborg(user) || isalien(user) || !CanReachInside(user))
		return ..()
	add_fingerprint(user)
	if(istype(I, /obj/item/reagent_containers))
		if(istype(I, /obj/item/food/monkeycube))
			var/obj/item/food/monkeycube/cube = I
			cube.Expand()
			return
		var/obj/item/reagent_containers/reagent_container = I
		if(reagent_container.is_open_container())
			reagent_container.reagents.add_reagent(/datum/reagent/water, min(reagent_container.volume - reagent_container.reagents.total_volume, reagent_container.amount_per_transfer_from_this))
			to_chat(user, "<span class='notice'>You fill [reagent_container] from [src].</span>")
			return
	if(hidden_item)
		to_chat(user, "<span class='warning'>There is already something inside [src].</span>")
		return
	if(!user.transferItemToLoc(I, src))
		to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in [src]!</span>")
		return
	hidden_item = I
	to_chat(user, "<span class='notice'>You hide [I] inside the basin.</span>")

/obj/structure/destructible/cult/beret_altar
	name = "strange structure"
	desc = "What is this? Who put it on this station? And why does it eminate <span class='hypnophrase'>beret energy?</span>"
	icon_state = "altar"
	cultist_examine_message = "Even you don't understand the eldritch magic behind this."
	break_message = "<span class='warning'>The structure shatters, leaving only a demonic screech!</span>"
	break_sound = 'sound/magic/demon_dies.ogg'
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 2
	var/beret_color = "#ffffff"
	var/status = ALTAR_INACTIVE

/obj/structure/destructible/cult/beret_altar/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user) && status)
		to_chat(user, "<span class='notice'>[src] is creating something, you can't move it!.</span>")
	else
		return ..()

/obj/structure/destructible/cult/beret_altar/update_overlays()
	. = ..()
	var/overlayicon
	switch(status)
		if(ALTAR_INACTIVE)
			return
		if(ALTAR_STAGEONE)
			overlayicon = "altar_beret1"
		if(ALTAR_STAGETWO)
			overlayicon = "altar_beret2"
		if(ALTAR_STAGETHREE)
			overlayicon = "altar_beret3"
	var/mutable_appearance/beret_overlay = mutable_appearance(icon, overlayicon)
	beret_overlay.appearance_flags = RESET_COLOR
	beret_overlay.color = beret_color
	. += beret_overlay

/obj/structure/destructible/cult/beret_altar/proc/beret_stageone()
	status = ALTAR_STAGEONE
	update_icon()
	visible_message("<span class='warning'>[src] starts creating something...</span>")
	playsound(src, 'sound/magic/beretaltar.ogg', 100)
	addtimer(CALLBACK(src, .proc/beret_stagetwo), ALTAR_TIME)

/obj/structure/destructible/cult/beret_altar/proc/beret_stagetwo()
	status = ALTAR_STAGETWO
	update_icon()
	visible_message("<span class='warning'>You start feeling nauseous...</span>")
	for(var/mob/living/mob in viewers(7, src))
		mob.blur_eyes(10)
		mob.add_confusion(10)
	addtimer(CALLBACK(src, .proc/beret_stagethree), ALTAR_TIME)

/obj/structure/destructible/cult/beret_altar/proc/beret_stagethree()
	status = ALTAR_STAGETHREE
	update_icon()
	visible_message("<span class='warning'>You start feeling horrible...</span>")
	for(var/mob/living/mob in viewers(7, src))
		mob.Dizzy(10)
	addtimer(CALLBACK(src, .proc/beret_create), ALTAR_TIME)

/obj/structure/destructible/cult/beret_altar/proc/beret_create()
	status = ALTAR_INACTIVE
	update_icon()
	visible_message("<span class='warning'>[src] eminates a flash of light and creates... a beret?</span>")
	for(var/mob/living/mob in viewers(7, src))
		mob.flash_act()
	var/obj/item/clothing/head/beret/greyscale/beret = new /obj/item/clothing/head/beret/greyscale(get_turf(src))
	beret.add_atom_colour(beret_color, ADMIN_COLOUR_PRIORITY)
	cooldowntime = world.time + 1 MINUTES

/obj/structure/destructible/cult/beret_altar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Beret", name)
		ui.open()

/obj/structure/destructible/cult/beret_altar/ui_data()
	var/list/data = list()
	data["beret_color"] = beret_color

	return data

/obj/structure/destructible/cult/beret_altar/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!Adjacent(usr))
		return
	if(!anchored)
		to_chat(usr, "<span class='notice'>[src] is unanchored!</span>")
		return
	if(status)
		return
	usr.set_machine(src)
	switch(action)
		if("color")
			var/chosen_color = input(usr, "", "Choose Color", beret_color) as color|null
			if (!isnull(chosen_color) && usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
				beret_color = chosen_color
		if("create")
			if(cooldowntime > world.time)
				to_chat(usr, "<span class='warning'>[src] is not ready to create something new yet...</span>")
			beret_stageone()
	return TRUE

/obj/item/clothing/head/beret/greyscale
	name = "strange beret"
	desc = "A beret. It does not look natural. It smells like fresh blood."
	icon_state = "beret_greyscale"
