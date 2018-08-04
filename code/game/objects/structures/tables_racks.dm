/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.")
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/metal
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = 1
	max_integrity = 100
	integrity_failure = 30
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/table, /obj/structure/table/reinforced)

/obj/structure/table/examine(mob/user)
	..()
	deconstruction_hints(user)

/obj/structure/table/proc/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.</span>")

/obj/structure/table/update_icon()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)

/obj/structure/table/narsie_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/wood(A)

/obj/structure/table/ratvar_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/reinforced/brass(A)

/obj/structure/table/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/table/attack_hand(mob/living/user)
	if(Adjacent(user) && user.pulling)
		if(isliving(user.pulling))
			var/mob/living/pushed_mob = user.pulling
			if(pushed_mob.buckled)
				to_chat(user, "<span class='warning'>[pushed_mob] is buckled to [pushed_mob.buckled]!</span>")
				return
			if(user.a_intent == INTENT_GRAB)
				if(user.grab_state < GRAB_AGGRESSIVE)
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
				tablepush(user, pushed_mob)
			if(user.a_intent == INTENT_HELP)
				pushed_mob.visible_message("<span class='notice'>[user] begins to place [pushed_mob] onto [src]...</span>", \
									"<span class='userdanger'>[user] begins to place [pushed_mob] onto [src]...</span>")
				if(do_after(user, 35, target = pushed_mob))
					tableplace(user, pushed_mob)
				else
					return
			user.stop_pulling()
		else if(user.pulling.pass_flags & PASSTABLE)
			user.Move_Pulled(src)
			if (user.pulling.loc == loc)
				user.visible_message("<span class='notice'>[user] places [user.pulling] onto [src].</span>",
					"<span class='notice'>You place [user.pulling] onto [src].</span>")
				user.stop_pulling()
	return ..()

/obj/structure/table/attack_tk()
	return FALSE

/obj/structure/table/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return 1
	if(mover.throwing)
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return !density

/obj/structure/table/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/table/proc/tableplace(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(src.loc)
	pushed_mob.resting = TRUE
	pushed_mob.update_canmove()
	pushed_mob.visible_message("<span class='notice'>[user] places [pushed_mob] onto [src].</span>", \
								"<span class='notice'>[user] places [pushed_mob] onto [src].</span>")
	add_logs(user, pushed_mob, "placed")

/obj/structure/table/proc/tablepush(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(src.loc)
	pushed_mob.Knockdown(40)
	pushed_mob.visible_message("<span class='danger'>[user] pushes [pushed_mob] onto [src].</span>", \
								"<span class='userdanger'>[user] pushes [pushed_mob] onto [src].</span>")
	add_logs(user, pushed_mob, "pushed")
	if(!ishuman(pushed_mob))
		return
	var/mob/living/carbon/human/H = pushed_mob
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)

/obj/structure/table/attackby(obj/item/I, mob/user, params)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(istype(I, /obj/item/screwdriver) && deconstruction_ready)
			to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
			if(I.use_tool(src, user, 20, volume=50))
				deconstruct(TRUE)
			return

		if(istype(I, /obj/item/wrench) && deconstruction_ready)
			to_chat(user, "<span class='notice'>You start deconstructing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				deconstruct(TRUE, 1)
			return

	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY, drop_location())
			user.visible_message("[user] empties [I] on [src].")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(user.a_intent != INTENT_HARM && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, drop_location()))
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return 1
	else
		return ..()


/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)


/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"
	buildstack = /obj/item/stack/sheet/glass
	canSmoothWith = null
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	var/list/debris = list()

/obj/structure/table/glass/New()
	. = ..()
	debris += new frame
	debris += new /obj/item/shard

/obj/structure/table/glass/Destroy()
	QDEL_LIST(debris)
	. = ..()

/obj/structure/table/glass/Crossed(atom/movable/AM)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!isliving(AM))
		return
	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, .proc/throw_check, AM), 5)
	else
		check_break(AM)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL && !(M.movement_type & FLYING))
		table_shatter(M)

/obj/structure/table/glass/proc/table_shatter(mob/living/L)
	visible_message("<span class='warning'>[src] breaks!</span>",
		"<span class='danger'>You hear breaking glass.</span>")
	var/turf/T = get_turf(src)
	playsound(T, "shatter", 50, 1)
	for(var/I in debris)
		var/atom/movable/AM = I
		AM.forceMove(T)
		debris -= AM
		if(istype(AM, /obj/item/shard))
			AM.throw_impact(L)
	L.Knockdown(100)
	qdel(src)

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, 1)
			for(var/X in debris)
				var/atom/movable/AM = X
				AM.forceMove(T)
				debris -= AM
	qdel(src)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/shard/S in debris)
		S.color = NARSIE_WINDOW_COLOUR

/*
 * Wooden tables
 */

/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/mineral/wood
	buildstack = /obj/item/stack/sheet/mineral/wood
	resistance_flags = FLAMMABLE
	max_integrity = 70
	canSmoothWith = list(/obj/structure/table/wood,
		/obj/structure/table/wood/poker,
		/obj/structure/table/wood/bar)

/obj/structure/table/wood/narsie_act(total_override = TRUE)
	if(!total_override)
		..()

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	canSmoothWith = list(/obj/structure/table/wood/fancy, /obj/structure/table/wood/fancy/black)

/obj/structure/table/wood/fancy/New()
	// New() is used so that the /black subtype can override `icon` easily and
	// the correct value will be used by the smoothing subsystem.
	. = ..()
	// Needs to be set dynamically because table smooth sprites are 32x34,
	// which the editor treats as a two-tile-tall object. The sprites are that
	// size so that the north/south corners look nice - examine the detail on
	// the sprites in the editor to see why.
	icon = 'icons/obj/smooth_structures/fancy_table.dmi'

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black

/obj/structure/table/wood/fancy/black/New()
	. = ..()
	// Ditto above.
	icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "r_table"
	deconstruction_ready = 0
	buildstack = /obj/item/stack/sheet/plasteel
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table)
	max_integrity = 200
	integrity_failure = 50
	armor = list("melee" = 10, "bullet" = 30, "laser" = 30, "energy" = 100, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		to_chat(user, "<span class='notice'>The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.</span>")
	else
		to_chat(user, "<span class='notice'>The top cover is firmly <b>welded</b> on.</span>")

/obj/structure/table/reinforced/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weldingtool))
		if(!W.tool_start_check(user, amount=0))
			return

		if(deconstruction_ready)
			to_chat(user, "<span class='notice'>You start strengthening the reinforced table...</span>")
			if (W.use_tool(src, user, 50, volume=50))
				to_chat(user, "<span class='notice'>You strengthen the table.</span>")
				deconstruction_ready = 0
		else
			to_chat(user, "<span class='notice'>You start weakening the reinforced table...</span>")
			if (W.use_tool(src, user, 50, volume=50))
				to_chat(user, "<span class='notice'>You weaken the table.</span>")
				deconstruction_ready = 1
	else
		. = ..()

/obj/structure/table/reinforced/brass
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/brass
	framestack = /obj/item/stack/tile/brass
	buildstack = /obj/item/stack/tile/brass
	framestackamount = 1
	buildstackamount = 1
	canSmoothWith = list(/obj/structure/table/reinforced/brass, /obj/structure/table/bronze)

/obj/structure/table/reinforced/brass/New()
	change_construction_value(2)
	..()

/obj/structure/table/reinforced/brass/Destroy()
	change_construction_value(-2)
	return ..()

/obj/structure/table/reinforced/brass/tablepush(mob/living/user, mob/living/pushed_mob)
	.= ..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/obj/structure/table/reinforced/brass/narsie_act()
	take_damage(rand(15, 45), BRUTE)
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/table/reinforced/brass/ratvar_act()
	obj_integrity = max_integrity

/obj/structure/table/bronze
	name = "bronze table"
	desc = "A solid table made out of bronze."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstack = /obj/item/stack/tile/bronze
	canSmoothWith = list(/obj/structure/table/reinforced/brass, /obj/structure/table/bronze)

/obj/structure/table/bronze/tablepush(mob/living/user, mob/living/pushed_mob)
	..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smooth = SMOOTH_FALSE
	can_buckle = 1
	buckle_lying = 1
	buckle_requires_restraints = 1
	var/mob/living/carbon/human/patient = null
	var/obj/machinery/computer/operating/computer = null

/obj/structure/table/optable/New()
	..()
	for(var/direction in GLOB.cardinals)
		computer = locate(/obj/machinery/computer/operating, get_step(src, direction))
		if(computer)
			computer.table = src
			break

/obj/structure/table/optable/tablepush(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(src.loc)
	pushed_mob.resting = 1
	pushed_mob.update_canmove()
	visible_message("<span class='notice'>[user] has laid [pushed_mob] on [src].</span>")
	check_patient()

/obj/structure/table/optable/proc/check_patient()
	var/mob/M = locate(/mob/living/carbon/human, loc)
	if(M)
		if(M.resting)
			patient = M
			return 1
	else
		patient = null
		return 0



/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.
	max_integrity = 20

/obj/structure/rack/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>")

/obj/structure/rack/CanPass(atom/movable/mover, turf/target)
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	. = ..()
	if ((!( istype(O, /obj/item) ) || user.get_active_held_item() != O))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/rack/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/wrench) && !(flags_1&NODECONSTRUCT_1))
		W.play_tool_sound(src)
		deconstruct(TRUE)
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(user.transferItemToLoc(W, drop_location()))
		return 1

/obj/structure/rack/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/rack/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.IsKnockdown() || user.resting || user.lying || user.get_num_legs() < 2)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='danger'>[user] kicks [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	take_damage(rand(4,8), BRUTE, "melee", 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, 1)

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags_1&NODECONSTRUCT_1))
		density = FALSE
		var/obj/item/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)


/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rack_parts"
	flags_1 = CONDUCT_1
	materials = list(MAT_METAL=2000)
	var/building = FALSE

/obj/item/rack_parts/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/wrench))
		new /obj/item/stack/sheet/metal(user.loc)
		qdel(src)
	else
		. = ..()

/obj/item/rack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, "<span class='notice'>You start constructing a rack...</span>")
	if(do_after(user, 50, target = user, progress=TRUE))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", "<span class='notice'>You assemble \a [R].</span>")
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
