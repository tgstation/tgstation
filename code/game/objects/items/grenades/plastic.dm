/obj/item/grenade/plastic
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "plastic-explosive0"
	item_state = "plastic-explosive"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	item_flags = NOBLUDGEON
	flags_1 = NONE
	det_time = 10
	display_timer = 0
	w_class = WEIGHT_CLASS_SMALL
	var/atom/target = null
	var/mutable_appearance/plastic_overlay
	var/obj/item/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/directional = FALSE
	var/aim_dir = NORTH
	var/boom_sizes = list(0, 0, 3)
	var/can_attach_mob = FALSE
	var/full_damage_on_mobs = FALSE

/obj/item/grenade/plastic/Initialize()
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[item_state]2", HIGH_OBJ_LAYER)

/obj/item/grenade/plastic/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)

/obj/item/grenade/plastic/Destroy()
	qdel(nadeassembly)
	nadeassembly = null
	target = null
	..()

/obj/item/grenade/plastic/attackby(obj/item/I, mob/user, params)
	if(!nadeassembly && istype(I, /obj/item/assembly_holder))
		var/obj/item/assembly_holder/A = I
		if(!user.transferItemToLoc(I, src))
			return ..()
		nadeassembly = A
		A.master = src
		assemblyattacher = user.ckey
		to_chat(user, "<span class='notice'>You add [A] to the [name].</span>")
		playsound(src, 'sound/weapons/tap.ogg', 20, 1)
		update_icon()
		return
	if(nadeassembly && istype(I, /obj/item/wirecutters))
		I.play_tool_sound(src, 20)
		nadeassembly.forceMove(get_turf(src))
		nadeassembly.master = null
		nadeassembly = null
		update_icon()
		return
	..()

/obj/item/grenade/plastic/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.cut_overlay(plastic_overlay, TRUE)
			if(!ismob(target) || full_damage_on_mobs)
				target.ex_act(2, target)
	else
		location = get_turf(src)
	if(location)
		if(directional && target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir), boom_sizes[1], boom_sizes[2], boom_sizes[3])
		else
			explosion(location, boom_sizes[1], boom_sizes[2], boom_sizes[3])
	if(ismob(target))
		var/mob/M = target
		M.gib()
	qdel(src)

//assembly stuff
/obj/item/grenade/plastic/receive_signal()
	prime()

/obj/item/grenade/plastic/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/grenade/plastic/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/grenade/plastic/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_held_item() == src)
		newtime = CLAMP(newtime, 10, 60000)
		det_time = newtime
		to_chat(user, "Timer set for [det_time] seconds.")

/obj/item/grenade/plastic/afterattack(atom/movable/AM, mob/user, flag)
	. = ..()
	aim_dir = get_dir(user,AM)
	if(!flag)
		return
	if(ismob(AM) && !can_attach_mob)
		return

	to_chat(user, "<span class='notice'>You start planting [src]. The timer is set to [det_time]...</span>")

	if(do_after(user, 30, target = AM))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		target = AM

		message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_VERBOSEJMP(target)] with [det_time] second fuse")
		log_game("[key_name(user)] planted [name] on [target.name] at [AREACOORD(user)] with [det_time] second fuse")

		moveToNullspace()	//Yep

		if(istype(AM, /obj/item)) //your crappy throwing star can't fly so good with a giant brick of c4 on it.
			var/obj/item/I = AM
			I.throw_speed = max(1, (I.throw_speed - 3))
			I.throw_range = max(1, (I.throw_range - 3))
			I.embedding = I.embedding.setRating(embed_chance = 0)

		target.add_overlay(plastic_overlay, TRUE)
		if(!nadeassembly)
			to_chat(user, "<span class='notice'>You plant the bomb. Timer counting down from [det_time].</span>")
			addtimer(CALLBACK(src, .proc/prime), det_time*10)
		else
			qdel(src)	//How?

/obj/item/grenade/plastic/proc/shout_syndicate_crap(mob/M)
	if(!M)
		return
	var/message_say = "FOR NO RAISIN!"
	if(M.mind)
		var/datum/mind/UM = M
		if(UM.has_antag_datum(/datum/antagonist/nukeop) || UM.has_antag_datum(/datum/antagonist/traitor))
			message_say = "FOR THE SYNDICATE!"
		else if(UM.has_antag_datum(/datum/antagonist/changeling))
			message_say = "FOR THE HIVE!"
		else if(UM.has_antag_datum(/datum/antagonist/cult))
			message_say = "FOR NAR-SIE!"
		else if(UM.has_antag_datum(/datum/antagonist/clockcult))
			message_say = "FOR RATVAR!"
		else if(UM.has_antag_datum(/datum/antagonist/rev))
			message_say = "VIVA LA REVOLUTION!"
	M.say(message_say, forced="C4 suicide")

/obj/item/grenade/plastic/suicide_act(mob/user)
	message_admins("[ADMIN_LOOKUPFLW(user)] suicided with [src] at [ADMIN_VERBOSEJMP(user)]")
	log_game("[key_name(user)] suicided with [src] at [AREACOORD(user)]")
	user.visible_message("<span class='suicide'>[user] activates [src] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
	shout_syndicate_crap(user)
	explosion(user,0,2,0) //Cheap explosion imitation because putting prime() here causes runtimes
	user.gib(1, 1)
	qdel(src)

/obj/item/grenade/plastic/update_icon()
	if(nadeassembly)
		icon_state = "[item_state]1"
	else
		icon_state = "[item_state]0"

//////////////////////////
///// The Explosives /////
//////////////////////////

/obj/item/grenade/plastic/c4
	name = "C4"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteur's favorite."
	gender = PLURAL
	var/open_panel = 0
	can_attach_mob = TRUE

/obj/item/grenade/plastic/c4/New()
	wires = new /datum/wires/explosive/c4(src)
	..()

/obj/item/grenade/plastic/c4/Destroy()
	qdel(wires)
	wires = null
	target = null
	return ..()

/obj/item/grenade/plastic/c4/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] activates the [src.name] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
	shout_syndicate_crap(user)
	target = user
	message_admins("[ADMIN_LOOKUPFLW(user)] suicided with [name] at [ADMIN_VERBOSEJMP(src)]")
	log_game("[key_name(user)] suicided with [name] at [AREACOORD(user)]")
	sleep(10)
	prime()
	user.gib(1, 1)

/obj/item/grenade/plastic/c4/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		open_panel = !open_panel
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")
	else if(is_wire_tool(I))
		wires.interact(user)
	else
		return ..()

/obj/item/grenade/plastic/c4/prime()
	if(QDELETED(src))
		return
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.cut_overlay(plastic_overlay, TRUE)
			if(!ismob(target) || full_damage_on_mobs)
				target.ex_act(2, target)
	else
		location = get_turf(src)
	if(location)
		explosion(location,0,0,3)
	qdel(src)

/obj/item/grenade/plastic/c4/attack(mob/M, mob/user, def_zone)
	return

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/grenade/plastic/x4
	name = "X4"
	desc = "A shaped high-explosive breaching charge. Designed to ensure user safety and wall nonsafety."
	icon_state = "plasticx40"
	item_state = "plasticx4"
	gender = PLURAL
	directional = TRUE
	boom_sizes = list(0, 2, 5)
