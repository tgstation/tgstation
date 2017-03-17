/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force.\n<span class='notice'>Drag your sprite to sit in the chair. Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = 1
	can_buckle = 1
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = 0
	obj_integrity = 250
	max_integrity = 250
	integrity_failure = 25
	var/item_chair = /obj/item/chair // if null it can't be picked up
	layer = OBJ_LAYER
	var/can_electrify = FALSE
	var/last_shock_time

/obj/structure/chair/e_chair/Initialize()
	SetItemToReachConstructionState(CHAIR_ELECTRIC, new /obj/item/assembly/shock_kit(src))
	..()

/obj/structure/chair/Initialize()
	..()
	if(!GetItemUsedToReachConstructionState(CHAIR_ELECTRIC))
		Construct()
		if(type == /obj/structure/chair)
			can_electrify = TRUE
	else
		can_electrify = TRUE
	update_icon()
	if(!anchored)	//why would you put these on the shuttle?
		addtimer(CALLBACK(src, .proc/RemoveFromLatejoin), 0)

/obj/structure/chair/Destroy()
	RemoveFromLatejoin()
	return ..()

/obj/structure/chair/proc/RemoveFromLatejoin()
	latejoin -= src	//These may be here due to the arrivals shuttle

CONSTRUCTION_BLUEPRINT(/obj/structure/chair, FALSE, FALSE)
	. = newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/stack/sheet/metal
			required_amount_to_construct = 1
			construction_delay = 10
			one_per_turf = 1
			on_floor = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/assembly/shock_kit
			required_amount_to_construct = 1
			stash_construction_item = 1
			required_type_to_deconstruct = /obj/item/weapon/wrench
			required_type_to_repair = /obj/item/weapon/weldingtool
			damage_reachable = 1
		},
		/datum/construction_state/last{
			required_type_to_deconstruct = /obj/item/weapon/wrench
		}
	)
	
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/metal

/obj/structure/chair/ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip)
	. = ..()
	if(!. || skip)
		return

	if(state_started_id)	//not just constructed, must try to be making an echair
		return can_electrify

/obj/structure/chair/update_icon()
	cut_overlays()
	if(current_construction_state.id >= CHAIR_ELECTRIC)
		icon_state = "echair0"
		add_overlay(image('icons/obj/chairs.dmi', src, "echair_over", MOB_LAYER + 1))
		name = "electric [initial(name)]"
		desc = "Looks absolutely SHOCKING!\n<span class='notice'>Drag your sprite to sit in the chair. Alt-click to rotate it clockwise.</span>"
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)

/obj/structure/chair/proc/shock()
	if(current_construction_state.id < CHAIR_ELECTRIC)
		return

	if(last_shock_time + 50 > world.time)
		return
	last_shock_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!A || !A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)

	flick("echair_shock", src)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(12, 1, src)
	s.start()
	if(has_buckled_mobs())
		return 
	visible_message("<span class='danger'>The [src] went off!</span>", "<span class='italics'>You hear a deep sharp shock!</span>")

/obj/structure/chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/narsie_act()
	if(prob(20))
		var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/structure/chair/attack_tk(mob/user)
	if(has_buckled_mobs())
		..()
	else
		rotate()

/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/post_buckle_mob(mob/living/M)
	..()
	handle_layer()

/obj/structure/chair/proc/spin()
	setDir(turn(dir, 90))

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/structure/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		spin()
	else
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.restrained())
			return
		spin()

/obj/structure/chair/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		rotate()

// Chair types
/obj/structure/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	resistance_flags = FLAMMABLE
	obj_integrity = 70
	max_integrity = 70
	item_chair = /obj/item/chair/wood

CONSTRUCTION_BLUEPRINT(/obj/structure/chair/wood, FALSE, FALSE)
	. = ..()
	var/datum/construction_state/first/F = .[1]
	F.required_type_to_construct = /obj/item/stack/sheet/mineral/wood
	F.required_amount_to_construct = 3

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/normal //Kept for map compatibility
	construction_blueprint = null	//Reee you have the tools, delete the damn thing!

/obj/structure/chair/wood/wings
	bp_name = "winged wooden chair"
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "comfychair"
	color = rgb(255,255,255)
	resistance_flags = FLAMMABLE
	obj_integrity = 70
	max_integrity = 70
	var/image/armrest = null
	item_chair = null

CONSTRUCTION_BLUEPRINT(/obj/structure/chair/comfy, FALSE, FALSE)
	. = ..()
	var/datum/construction_state/first/F = .[1]
	F.required_amount_to_construct = 2

/obj/structure/chair/comfy/Initialize()
	armrest = image("icons/obj/chairs.dmi", "comfychair_armrest")
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	..()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)


/obj/structure/chair/comfy/brown
	bp_name = "brown comfy chair"
	color = rgb(255,113,0)

/obj/structure/chair/comfy/beige
	bp_name = "beige comfy chair"
	color = rgb(255,253,195)

/obj/structure/chair/comfy/teal
	bp_name = "teal comfy chair"
	color = rgb(0,255,255)

/obj/structure/chair/comfy/black
	bp_name = "black comfy chair"
	color = rgb(167,164,153)

/obj/structure/chair/comfy/lime
	bp_name = "lime comfy chair"
	color = rgb(255,251,0)

/obj/structure/chair/office
	bp_name = "office chair"
	anchored = 0
	item_chair = null

CONSTRUCTION_BLUEPRINT(/obj/structure/chair/office, FALSE, FALSE)
	. = ..()
	var/datum/construction_state/first/F = .[1]
	F.required_amount_to_construct = 5

/obj/structure/chair/office/light
	bp_name = "white office chair"
	icon_state = "officechair_white"

/obj/structure/chair/office/dark
	bp_name = "black office chair"
	icon_state = "officechair_dark"

//Stool

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = 0
	item_chair = /obj/item/chair/stool

/obj/structure/chair/stool/narsie_act()
	return

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || !usr.can_hold_items() || has_buckled_mobs() || src.flags & NODECONSTRUCT)
			return
		if(usr.incapacitated())
			to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
			return
		usr.visible_message("<span class='notice'>[usr] grabs \the [src.name].</span>", "<span class='notice'>You grab \the [src.name].</span>")
		var/C = new item_chair(loc)
		usr.put_in_hands(C)
		qdel(src)

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	item_state = "chair"
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/narsie_act()
	if(prob(20))
		var/obj/item/chair/wood/W = new/obj/item/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	for(var/obj/A in get_turf(loc))
		if(istype(A,/obj/structure/chair))
			to_chat(user, "<span class='danger'>There is already a chair here.</span>")
			return
		if(A.density && !(A.flags & ON_BORDER))
			to_chat(user, "<span class='danger'>There is already something here.</span>")
			return

	user.visible_message("<span class='notice'>[user] rights \the [src.name].</span>", "<span class='notice'>You right \the [name].</span>")
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.setDir(dir)
	qdel(src)

/obj/item/chair/proc/smash(mob/living/user)
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically dissapears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	qdel(src)




/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>[owner] fends off [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/chair/afterattack(atom/target, mob/living/carbon/user, proximity)
	..()
	if(!proximity)
		return
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user] smashes \the [src] to pieces against \the [target]</span>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(C.health < C.maxHealth*0.5)
				C.Weaken(1)
		smash(user)


/obj/item/chair/stool
	name = "stool"
	icon_state = "stool_toppled"
	item_state = "stool"
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	item_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/narsie_act()
	return //sturdy enough to ignore a god

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	item_state = "woodenchair"
	resistance_flags = FLAMMABLE
	obj_integrity = 70
	max_integrity = 70
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	break_chance = 50

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/structure/chair/old
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks REALLY uncomfortable."
	icon_state = "chairold"
	item_chair = null
