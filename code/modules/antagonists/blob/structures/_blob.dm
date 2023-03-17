//I will need to recode parts of this but I am way too tired atm //I don't know who left this comment but they never did come back
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	light_range = 2
	desc = "A thick wall of writhing tendrils."
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	pass_flags_self = PASSBLOB
	can_atmos_pass = ATMOS_PASS_PROC
	obj_flags = CAN_BE_HIT|BLOCK_Z_OUT_DOWN // stops blob mobs from falling on multiz.
	/// How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/point_return = 0
	max_integrity = BLOB_REGULAR_MAX_HP
	armor_type = /datum/armor/structure_blob
	/// how much health this blob regens when pulsed
	var/health_regen = BLOB_REGULAR_HP_REGEN
	/// We got pulsed when?
	COOLDOWN_DECLARE(pulse_timestamp)
	/// we got healed when?
	COOLDOWN_DECLARE(heal_timestamp)
	/// Multiplies brute damage by this
	var/brute_resist = BLOB_BRUTE_RESIST
	/// Multiplies burn damage by this
	var/fire_resist = BLOB_FIRE_RESIST
	/// Only used by the synchronous mesh strain. If set to true, these blobs won't share or receive damage taken with others.
	var/ignore_syncmesh_share = 0
	/// If the blob blocks atmos and heat spread
	var/atmosblock = FALSE
	var/mob/camera/blob/overmind


/datum/armor/structure_blob
	fire = 80
	acid = 70

/obj/structure/blob/Initialize(mapload, owner_overmind)
	. = ..()
	register_context()
	if(owner_overmind)
		overmind = owner_overmind
		overmind.all_blobs += src
	GLOB.blobs += src //Keep track of the blob in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_appearance()
	if(atmosblock)
		air_update_turf(TRUE, TRUE)
	ConsumeTile()
	if(!QDELETED(src)) //Consuming our tile can in rare cases cause us to del
		AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOB, CELL_VIRUS_TABLE_GENERIC, 2, 2)

/obj/structure/blob/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if (!isovermind(user))
		return .

	if(istype(src, /obj/structure/blob/normal))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Create strong blob"
	if(istype(src, /obj/structure/blob/shield) && !istype(src, /obj/structure/blob/shield/reflective))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Create reflective blob"

	if(point_return >= 0)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove blob"

	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/blob/proc/creation_action() //When it's created by the overmind, do this.
	return

/obj/structure/blob/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(TRUE, FALSE)
	if(overmind)
		overmind.all_blobs -= src
		overmind.blobs_legit -= src  //if it was in the legit blobs list, it isn't now
		overmind = null
	GLOB.blobs -= src //it's no longer in the all blobs list either
	playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE) //Expand() is no longer broken, no check necessary.
	return ..()

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/Adjacent(atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/blob) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/blob/block_superconductivity()
	return atmosblock

/obj/structure/blob/can_atmos_pass(turf/T, vertical = FALSE)
	return !atmosblock

/obj/structure/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	. = ..()
	if(overmind)
		add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)
		var/area/A = get_area(src)
		if(!(A.area_flags & BLOBS_ALLOWED))
			add_atom_colour(BlendRGB(overmind.blobstrain.color, COLOR_WHITE, 0.5), FIXED_COLOUR_PRIORITY) //lighten it to indicate an off-station blob
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/blob/proc/Be_Pulsed()
	if(COOLDOWN_FINISHED(src, pulse_timestamp))
		ConsumeTile()
		if(COOLDOWN_FINISHED(src, heal_timestamp))
			atom_integrity = min(max_integrity, atom_integrity+health_regen)
			COOLDOWN_START(src, heal_timestamp, 20)
		update_appearance()
		COOLDOWN_START(src, pulse_timestamp, 10)
		return TRUE//we did it, we were pulsed!
	return FALSE //oh no we failed

/obj/structure/blob/proc/ConsumeTile()
	for(var/atom/A in loc)
		if(!A.can_blob_attack())
			continue
		if(isliving(A) && overmind && !isblobmonster(A)) // Make sure to inject strain-reagents with automatic attacks when needed.
			overmind.blobstrain.attack_living(A)
			continue // Don't smack them twice though
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/blob_attack_animation(atom/A = null, controller) //visually attacks an atom
	var/obj/effect/temp_visual/blob/O = new /obj/effect/temp_visual/blob(src.loc)
	O.setDir(dir)
	var/area/my_area = get_area(src)
	if(controller)
		var/mob/camera/blob/BO = controller
		O.color = BO.blobstrain.color
		if(!(my_area.area_flags & BLOBS_ALLOWED))
			O.color = BlendRGB(O.color, COLOR_WHITE, 0.5) //lighten it to indicate an off-station blob
		O.alpha = 200
	else if(overmind)
		O.color = overmind.blobstrain.color
		if(!(my_area.area_flags & BLOBS_ALLOWED))
			O.color = BlendRGB(O.color, COLOR_WHITE, 0.5) //lighten it to indicate an off-station blob
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/structure/blob/proc/expand(turf/T = null, controller = null, expand_reaction = 1)
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/structure/blob) in T))
				break
			else
				T = null
	if(!T)
		return
	var/make_blob = TRUE //can we make a blob?

	if(isspaceturf(T) && !(locate(/obj/structure/lattice) in T) && prob(80))
		make_blob = FALSE
		playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE) //Let's give some feedback that we DID try to spawn in space, since players are used to it

	ConsumeTile() //hit the tile we're in, making sure there are no border objects blocking us
	if(!T.CanPass(src, get_dir(T, src))) //is the target turf impassable
		make_blob = FALSE
		T.blob_act(src) //hit the turf if it is
	for(var/atom/A in T)
		if(!A.CanPass(src, get_dir(T, src))) //is anything in the turf impassable
			make_blob = FALSE
		if(!A.can_blob_attack())
			continue
		if(isliving(A) && overmind && !controller) // Make sure to inject strain-reagents with automatic attacks when needed.
			overmind.blobstrain.attack_living(A)
			continue // Don't smack them twice though
		A.blob_act(src) //also hit everything in the turf

	if(make_blob) //well, can we?
		var/obj/structure/blob/B = new /obj/structure/blob/normal(src.loc, (controller || overmind))
		B.set_density(TRUE)
		if(T.Enter(B)) //NOW we can attempt to move into the tile
			B.set_density(initial(B.density))
			B.forceMove(T)
			var/area/Ablob = get_area(B)
			if(Ablob.area_flags & BLOBS_ALLOWED) //Is this area allowed for winning as blob?
				overmind.blobs_legit += B
			else if(controller)
				B.balloon_alert(overmind, "off-station, won't count!")
			B.update_appearance()
			if(B.overmind && expand_reaction)
				B.overmind.blobstrain.expand_reaction(src, B, T, controller)
			return B
		else
			blob_attack_animation(T, controller)
			T.blob_act(src) //if we can't move in hit the turf again
			qdel(B) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return
	else
		blob_attack_animation(T, controller) //if we can't, animate that we attacked
	return

/obj/structure/blob/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity > 0)
		if(overmind)
			overmind.blobstrain.emp_reaction(src, severity)
		if(prob(100 - severity * 30))
			new /obj/effect/temp_visual/emp(get_turf(src))

/obj/structure/blob/zap_act(power, zap_flags)
	if(overmind)
		if(overmind.blobstrain.tesla_reaction(src, power))
			take_damage(power * 0.0025, BURN, ENERGY)
	else
		take_damage(power * 0.0025, BURN, ENERGY)
	power -= power * 0.0025 //You don't get to do it for free
	return ..() //You don't get to do it for free

/obj/structure/blob/extinguish()
	..()
	if(overmind)
		overmind.blobstrain.extinguish_reaction(src)

/obj/structure/blob/hulk_damage()
	return 15

/obj/structure/blob/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<b>The analyzer beeps once, then reports:</b><br>")
		SEND_SOUND(user, sound('sound/machines/ping.ogg'))
		if(overmind)
			to_chat(user, "<b>Progress to Critical Mass:</b> [span_notice("[overmind.blobs_legit.len]/[overmind.blobwincount].")]")
			to_chat(user, chemeffectreport(user).Join("\n"))
		else
			to_chat(user, "<b>Blob core neutralized. Critical mass no longer attainable.</b>")
		to_chat(user, typereport(user).Join("\n"))
	else
		return ..()

/obj/structure/blob/proc/chemeffectreport(mob/user)
	RETURN_TYPE(/list)
	. = list()
	if(overmind)
		. += list("<b>Material: <font color=\"[overmind.blobstrain.color]\">[overmind.blobstrain.name]</font>[span_notice(".")]</b>",
		"<b>Material Effects:</b> [span_notice("[overmind.blobstrain.analyzerdescdamage]")]",
		"<b>Material Properties:</b> [span_notice("[overmind.blobstrain.analyzerdesceffect || "N/A"]")]")
	else
		. += "<b>No Material Detected!</b>"

/obj/structure/blob/proc/typereport(mob/user)
	RETURN_TYPE(/list)
	return list("<b>Blob Type:</b> [span_notice("[uppertext(initial(name))]")]",
							"<b>Health:</b> [span_notice("[atom_integrity]/[max_integrity]")]",
							"<b>Effects:</b> [span_notice("[scannerreport()]")]")


/obj/structure/blob/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(ROLE_BLOB in user.faction) //sorry, but you can't kill the blob as a blobbernaut
		return
	..()

/obj/structure/blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/blob/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = get_armor_rating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(overmind && damage_flag)
		damage_amount = overmind.blobstrain.damage_reaction(src, damage_amount, damage_type, damage_flag)
	return damage_amount

/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && atom_integrity > 0)
		update_appearance()

/obj/structure/blob/atom_destruction(damage_flag)
	if(overmind)
		overmind.blobstrain.death_reaction(src, damage_flag)
	..()

/obj/structure/blob/proc/change_to(type, controller)
	if(!ispath(type))
		CRASH("change_to(): invalid type for blob")
	var/obj/structure/blob/B = new type(src.loc, controller)
	B.creation_action()
	B.update_appearance()
	B.setDir(dir)
	qdel(src)
	return B

/obj/structure/blob/examine(mob/user)
	. = ..()
	var/datum/atom_hud/hud_to_check = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	if(HAS_TRAIT(user, TRAIT_RESEARCH_SCANNER) || hud_to_check.hud_users[user])
		. += "<b>Your HUD displays an extensive report...</b><br>"
		if(overmind)
			. += overmind.blobstrain.examine(user)
		else
			. += "<b>Core neutralized. Critical mass no longer attainable.</b>"
		. += chemeffectreport(user)
		. += typereport(user)
	else
		if((user == overmind || isobserver(user)) && overmind)
			. += overmind.blobstrain.examine(user)
		. += "It seems to be made of [get_chem_name()]."

/obj/structure/blob/proc/scannerreport()
	return "A generic blob. Looks like someone forgot to override this proc, adminhelp this."

/obj/structure/blob/proc/get_chem_name()
	if(overmind)
		return overmind.blobstrain.name
	return "some kind of organic tissue"

/obj/structure/blob/normal
	name = "normal blob"
	icon_state = "blob"
	light_range = 0
	max_integrity = BLOB_REGULAR_MAX_HP
	var/initial_integrity = BLOB_REGULAR_HP_INIT
	health_regen = BLOB_REGULAR_HP_REGEN
	brute_resist = BLOB_BRUTE_RESIST * 0.5

/obj/structure/blob/normal/Initialize(mapload, owner_overmind)
	. = ..()
	update_integrity(initial_integrity)

/obj/structure/blob/normal/scannerreport()
	if(atom_integrity <= 15)
		return "Currently weak to brute damage."
	return "N/A"

/obj/structure/blob/normal/update_name()
	. = ..()
	name = "[(atom_integrity <= 15) ? "fragile " : (overmind ? null : "dead ")][initial(name)]"

/obj/structure/blob/normal/update_desc()
	. = ..()
	if(atom_integrity <= 15)
		desc = "A thin lattice of slightly twitching tendrils."
	else if(overmind)
		desc = "A thick wall of writhing tendrils."
	else
		desc = "A thick wall of lifeless tendrils."

/obj/structure/blob/normal/update_icon_state()
	icon_state = "blob[(atom_integrity <= 15) ? "_damaged" : null]"

	/// - [] TODO: Move this elsewhere
	if(atom_integrity <= 15)
		brute_resist = BLOB_BRUTE_RESIST
	else if (overmind)
		brute_resist = BLOB_BRUTE_RESIST * 0.5
	else
		brute_resist = BLOB_BRUTE_RESIST * 0.5
	return ..()

/obj/structure/blob/special // Generic type for nodes/factories/cores/resource
	// Core and node vars: claiming, pulsing and expanding
	/// The radius inside which (previously dead) blob tiles are 'claimed' again by the pulsing overmind. Very rarely used.
	var/claim_range = 0
	/// The radius inside which blobs are pulsed by this overmind. Does stuff like expanding, making blob spores from factories, make resources from nodes etc.
	var/pulse_range = 0
	/// The radius up to which this special structure naturally grows normal blobs.
	var/expand_range = 0

	// Spore production vars: for core, factories, and nodes (with strains)
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = null
	var/max_spores = 0
	var/list/spores = list()
	COOLDOWN_DECLARE(spore_delay)
	var/spore_cooldown = BLOBMOB_SPORE_SPAWN_COOLDOWN

	// Area reinforcement vars: used by cores and nodes, for strains to modify
	/// Range this blob free upgrades to strong blobs at: for the core, and for strains
	var/strong_reinforce_range = 0
	/// Range this blob free upgrades to reflector blobs at: for the core, and for strains
	var/reflector_reinforce_range = 0

/obj/structure/blob/special/proc/reinforce_area(delta_time) // Used by cores and nodes to upgrade their surroundings
	if(strong_reinforce_range)
		for(var/obj/structure/blob/normal/B in range(strong_reinforce_range, src))
			if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
				B.change_to(/obj/structure/blob/shield/core, overmind)
	if(reflector_reinforce_range)
		for(var/obj/structure/blob/shield/B in range(reflector_reinforce_range, src))
			if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
				B.change_to(/obj/structure/blob/shield/reflective/core, overmind)

/obj/structure/blob/special/proc/pulse_area(mob/camera/blob/pulsing_overmind, claim_range = 10, pulse_range = 3, expand_range = 2)
	if(QDELETED(pulsing_overmind))
		pulsing_overmind = overmind
	Be_Pulsed()
	var/expanded = FALSE
	if(prob(70*(1/BLOB_EXPAND_CHANCE_MULTIPLIER)) && expand())
		expanded = TRUE
	var/list/blobs_to_affect = list()
	for(var/obj/structure/blob/B in urange(claim_range, src, 1))
		blobs_to_affect += B
	shuffle_inplace(blobs_to_affect)
	for(var/L in blobs_to_affect)
		var/obj/structure/blob/B = L
		if(!B.overmind && prob(30))
			B.overmind = pulsing_overmind //reclaim unclaimed, non-core blobs.
			B.update_appearance()
		var/distance = get_dist(get_turf(src), get_turf(B))
		var/expand_probablity = max(20 - distance * 8, 1)
		if(B.Adjacent(src))
			expand_probablity = 20
		if(distance <= expand_range)
			var/can_expand = TRUE
			if(blobs_to_affect.len >= 120 && !(COOLDOWN_FINISHED(B, heal_timestamp)))
				can_expand = FALSE
			if(can_expand && COOLDOWN_FINISHED(B, pulse_timestamp) && prob(expand_probablity*BLOB_EXPAND_CHANCE_MULTIPLIER))
				if(!expanded)
					var/obj/structure/blob/newB = B.expand(null, null, !expanded) //expansion falls off with range but is faster near the blob causing the expansion
					if(newB)
						expanded = TRUE
		if(distance <= pulse_range)
			B.Be_Pulsed()

/obj/structure/blob/special/proc/produce_spores()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(!COOLDOWN_FINISHED(src, spore_delay))
		return
	COOLDOWN_START(src, spore_delay, spore_cooldown)
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new (loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		BS.overmind = overmind
		BS.update_icons()
		overmind.blob_mobs.Add(BS)
