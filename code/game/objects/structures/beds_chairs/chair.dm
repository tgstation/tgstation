/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 0.1
	custom_materials = list(/datum/material/iron = 2000)
	layer = OBJ_LAYER
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up


/obj/structure/chair/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")
	if(!has_buckled_mobs() && can_buckle)
		. += span_notice("While standing on [src], drag and drop your sprite onto [src] to buckle to it.")

/obj/structure/chair/Initialize(mapload)
	. = ..()
	if(!anchored) //why would you put these on the shuttle?
		addtimer(CALLBACK(src, .proc/RemoveFromLatejoin), 0)
	if(prob(0.2))
		name = "tactical [name]"

/obj/structure/chair/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/structure/chair/proc/can_be_rotated(mob/user)
	return TRUE

/obj/structure/chair/proc/can_user_rotate(mob/user)
	var/mob/living/L = user

	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
			return FALSE
		else
			return TRUE
	else if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/obj/structure/chair/Destroy()
	RemoveFromLatejoin()
	return ..()

/obj/structure/chair/proc/RemoveFromLatejoin()
	SSjob.latejoin_trackers -= src //These may be here due to the arrivals shuttle

/obj/structure/chair/deconstruct(disassembled)
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
		else
			for(var/i in custom_materials)
				var/datum/material/M = i
				new M.sheet_type(loc, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
	..()

/obj/structure/chair/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/chair/narsie_act()
	var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/structure/chair/attackby(obj/item/W, mob/user, params)
	if(flags_1 & NODECONSTRUCT_1)
		return . = ..()
	if(istype(W, /obj/item/assembly/shock_kit) && !HAS_TRAIT(src, TRAIT_ELECTRIFIED_BUCKLE))
		electrify_self(W, user)
		return
	. = ..()

///allows each chair to request the electrified_buckle component with overlays that dont look ridiculous
/obj/structure/chair/proc/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	SHOULD_CALL_PARENT(TRUE)
	if(!user.temporarilyRemoveItemFromInventory(input_shock_kit))
		return
	if(!overlays_from_child_procs || overlays_from_child_procs.len == 0)
		var/image/echair_over_overlay = image('icons/obj/chairs.dmi', loc, "echair_over")
		AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE | SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE), input_shock_kit, list(echair_over_overlay), FALSE)
	else
		AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE | SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE), input_shock_kit, overlays_from_child_procs, FALSE)

	if(HAS_TRAIT(src, TRAIT_ELECTRIFIED_BUCKLE))
		to_chat(user, span_notice("You connect the shock kit to the [name], electrifying it "))
	else
		user.put_in_active_hand(input_shock_kit)
		to_chat(user, "<span class='notice'> You cannot fit the shock kit onto the [name]!")


/obj/structure/chair/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1&NODECONSTRUCT_1)
		return TRUE
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/chair/attack_tk(mob/user)
	if(!anchored || has_buckled_mobs() || !isturf(user.loc))
		return ..()
	setDir(turn(dir,-90))
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
		plane = GAME_PLANE_UPPER
	else
		layer = OBJ_LAYER
		plane = GAME_PLANE

/obj/structure/chair/post_buckle_mob(mob/living/M)
	. = ..()
	handle_layer()

/obj/structure/chair/post_unbuckle_mob()
	. = ..()
	handle_layer()

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

// Chair types

///Material chair
/obj/structure/chair/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	item_chair = /obj/item/chair/greyscale
	buildstacktype = null //Custom mats handle this


/obj/structure/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = /obj/item/chair/wood

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	// The mutable appearance used for the overlay over buckled mobs.
	var/mutable_appearance/armrest

/obj/structure/chair/comfy/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	armrest.plane = GAME_PLANE_UPPER
	return ..()

/obj/structure/chair/comfy/proc/GetArmrest()
	return mutable_appearance(icon, "[icon_state]_armrest")

/obj/structure/chair/comfy/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/comfy/post_unbuckle_mob()
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a more sturdy looking buckling system, for smoother flights."
	icon_state = "shuttle_chair"
	buildstacktype = /obj/item/stack/sheet/mineral/titanium

/obj/structure/chair/comfy/shuttle/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	if(!overlays_from_child_procs)
		overlays_from_child_procs = list(image('icons/obj/chairs.dmi', loc, "echair_over", pixel_x = -1))
	. = ..()

/obj/structure/chair/comfy/carp
	name = "carpskin chair"
	desc = "A luxurious chair, the many purple scales reflect the light in a most pleasing manner."
	icon_state = "carp_chair"
	buildstacktype = /obj/item/stack/sheet/animalhide/carp

/obj/structure/chair/office
	anchored = FALSE
	buildstackamount = 5
	item_chair = null
	icon_state = "officechair_dark"


/obj/structure/chair/office/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/structure/chair/office/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	if(!overlays_from_child_procs)
		overlays_from_child_procs = list(image('icons/obj/chairs.dmi', loc, "echair_over", pixel_x = -1))
	. = ..()

/obj/structure/chair/office/light
	icon_state = "officechair_white"

//Stool

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = FALSE
	buildstackamount = 1
	item_chair = /obj/item/chair/stool

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool, 0)

/obj/structure/chair/stool/narsie_act()
	return

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || has_buckled_mobs() || src.flags_1 & NODECONSTRUCT_1)
			return
		if(!usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
			return
		usr.visible_message(span_notice("[usr] grabs \the [src.name]."), span_notice("You grab \the [src.name]."))
		var/obj/item/C = new item_chair(loc)
		C.set_custom_materials(custom_materials)
		TransferComponents(C)
		usr.put_in_hands(C)
		qdel(src)

/obj/structure/chair/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return ..()

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/chair/stool/bar, 0)

/obj/structure/chair/stool/bamboo
	name = "bamboo stool"
	desc = "A makeshift bamboo stool with a rustic look."
	icon_state = "bamboo_stool"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 2
	item_chair = /obj/item/chair/stool/bamboo

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	inhand_icon_state = "chair"
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50
	custom_materials = list(/datum/material/iron = 2000)
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src,hitsound,50,TRUE)
	return BRUTELOSS

/obj/item/chair/narsie_act()
	var/obj/item/chair/wood/W = new/obj/item/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	var/turf/T = get_turf(loc)
	if(!isfloorturf(T))
		to_chat(user, span_warning("You need ground to plant this on!"))
		return
	for(var/obj/A in T)
		if(istype(A, /obj/structure/chair))
			to_chat(user, span_warning("There is already a chair here!"))
			return
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			to_chat(user, span_warning("There is already something here!"))
			return

	user.visible_message(span_notice("[user] rights \the [src.name]."), span_notice("You right \the [name]."))
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.set_custom_materials(custom_materials)
	TransferComponents(C)
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
	else if(custom_materials[GET_MATERIAL_REF(/datum/material/iron)])
		new /obj/item/stack/rods(get_turf(loc), 2)
	qdel(src)




/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message(span_danger("[owner] fends off [attack_text] with [src]!"))
		return TRUE
	return FALSE

/obj/item/chair/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(prob(break_chance))
		user.visible_message(span_danger("[user] smashes \the [src] to pieces against \the [target]"))
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(C.health < C.maxHealth*0.5)
				C.Paralyze(20)
		smash(user)

/obj/item/chair/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	origin_type = /obj/structure/chair/greyscale

/obj/item/chair/stool
	name = "stool"
	icon_state = "stool_toppled"
	inhand_icon_state = "stool"
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	inhand_icon_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/bamboo
	name = "bamboo stool"
	icon_state = "bamboo_stool"
	inhand_icon_state = "stool_bamboo"
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/stool/bamboo
	break_chance = 50	//Submissive and breakable unlike the chad iron stool

/obj/item/chair/stool/narsie_act()
	return //sturdy enough to ignore a god

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	inhand_icon_state = "woodenchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	custom_materials = null
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

/obj/structure/chair/bronze
	name = "brass chair"
	desc = "A spinny chair made of bronze. It has little cogs for wheels!"
	anchored = FALSE
	icon_state = "brass_chair"
	buildstacktype = /obj/item/stack/sheet/bronze
	buildstackamount = 1
	item_chair = null
	var/turns = 0

/obj/structure/chair/bronze/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/chair/bronze/process()
	setDir(turn(dir,-90))
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	turns++
	if(turns >= 8)
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/bronze/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)

/obj/structure/chair/bronze/AltClick(mob/user)
	turns = 0
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	if(!(datum_flags & DF_ISPROCESSING))
		user.visible_message(span_notice("[user] spins [src] around, and the last vestiges of Ratvarian technology keeps it spinning FOREVER."), \
		span_notice("Automated spinny chairs. The pinnacle of ancient Ratvarian technology."))
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message(span_notice("[user] stops [src]'s uncontrollable spinning."), \
		span_notice("You grab [src] and stop its wild spinning."))
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/mime
	name = "invisible chair"
	desc = "The mime needs to sit down and shut up."
	anchored = FALSE
	icon_state = null
	buildstacktype = null
	item_chair = null
	flags_1 = NODECONSTRUCT_1
	alpha = 0

/obj/structure/chair/mime/post_buckle_mob(mob/living/M)
	M.pixel_y += 5

/obj/structure/chair/mime/post_unbuckle_mob(mob/living/M)
	M.pixel_y -= 5


/obj/structure/chair/plastic
	icon_state = "plastic_chair"
	name = "folding plastic chair"
	desc = "No matter how much you squirm, it'll still be uncomfortable."
	resistance_flags = FLAMMABLE
	max_integrity = 50
	custom_materials = list(/datum/material/plastic = 2000)
	buildstacktype = /obj/item/stack/sheet/plastic
	buildstackamount = 2
	item_chair = /obj/item/chair/plastic

/obj/structure/chair/plastic/post_buckle_mob(mob/living/Mob)
	Mob.pixel_y += 2
	.=..()
	if(iscarbon(Mob))
		INVOKE_ASYNC(src, .proc/snap_check, Mob)

/obj/structure/chair/plastic/post_unbuckle_mob(mob/living/Mob)
	Mob.pixel_y -= 2

/obj/structure/chair/plastic/proc/snap_check(mob/living/carbon/Mob)
	if (Mob.nutrition >= NUTRITION_LEVEL_FAT)
		to_chat(Mob, span_warning("The chair begins to pop and crack, you're too heavy!"))
		if(do_after(Mob, 6 SECONDS, progress = FALSE))
			Mob.visible_message(span_notice("The plastic chair snaps under [Mob]'s weight!"))
			new /obj/effect/decal/cleanable/plastic(loc)
			qdel(src)

/obj/item/chair/plastic
	name = "folding plastic chair"
	desc = "Somehow, you can always find one under the wrestling ring."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "folded_chair"
	inhand_icon_state = "folded_chair"
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 7
	throw_range = 5 //Lighter Weight --> Flies Farther.
	custom_materials = list(/datum/material/plastic = 2000)
	break_chance = 25
	origin_type = /obj/structure/chair/plastic
