
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/tear_in_reality
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = FALSE //if TRUE, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = FALSE

/obj/effect/rend/New(loc, spawn_type, spawn_amt, desc, spawn_fast)
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)
	return

/obj/effect/rend/process()
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_act()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "banana_blade"
	inhand_icon_state = "banana_blade"
	worn_icon_state = "render"

/obj/item/veilrender/honkrender/honkhulkrender
	name = "superior honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus. This one gleams with a special light."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	spawn_amt = 5
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of mirthful grunting."

#define TEAR_IN_REALITY_CONSUME_RANGE 3
#define TEAR_IN_REALITY_SINGULARITY_SIZE STAGE_FOUR

/// Tear in reality, spawned by the veil render
/obj/tear_in_reality
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	layer = MASSIVE_OBJ_LAYER
	light_range = 6
	appearance_flags = LONG_GLIDE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/tear_in_reality/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/singularity, \
		consume_range = TEAR_IN_REALITY_CONSUME_RANGE, \
		notify_admins = !mapload, \
		roaming = FALSE, \
		singularity_size = TEAR_IN_REALITY_SINGULARITY_SIZE, \
	)

/obj/tear_in_reality/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	var/datum/component/mood/insaneinthemembrane = jedi.GetComponent(/datum/component/mood)
	if(insaneinthemembrane.sanity < 15)
		return //they've already seen it and are about to die, or are just too insane to care
	to_chat(jedi, "<span class='userdanger'>OH GOD! NONE OF IT IS REAL! NONE OF IT IS REEEEEEEEEEEEEEEEEEEEEEEEAL!</span>")
	insaneinthemembrane.sanity = 0
	for(var/lore in typesof(/datum/brain_trauma/severe))
		jedi.gain_trauma(lore)
	addtimer(CALLBACK(src, .proc/deranged, jedi), 10 SECONDS)

/obj/tear_in_reality/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(0, TRUE, TRUE, 3, TRUE)
	C.spew_organ(3, 2)
	C.death()

#undef TEAR_IN_REALITY_CONSUME_RANGE
#undef TEAR_IN_REALITY_SINGULARITY_SIZE

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, merely holding it gives you vision and hearing beyond mortal means, and staring into it lets you see the entire universe."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

	var/mob/current_owner

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, "<span class='notice'>Your otherworldly vision fades...</span>")

		REMOVE_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		REMOVE_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, "<span class='notice'>You can see...everything!</span>")

		ADD_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		ADD_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

/obj/item/scrying/attack_self(mob/user)
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(!istype(user) || !user.canUseTopic(M, BE_CLOSE))
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) //excludes new players
		if(ghost.mind && ghost.mind.current == M && ghost.client)  //the dead mobs list can contain clientless mobs
			ghost.reenter_corpse()
			break

	if(!M.mind || !M.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return

	M.set_species(/datum/species/skeleton, icon_update=0)
	M.revive(full_heal = TRUE, admin_revive = TRUE)
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>[user.p_theyre(TRUE)] your master now, assist [user.p_them()] even if it costs you your new life!</span>")

	equip_roman_skeleton(M)

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.dropItemToGround(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionnaire)
	H.equip_to_slot_or_del(new hat(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(H), ITEM_SLOT_ICLOTHING)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), ITEM_SLOT_FEET)
	H.put_in_hands(new /obj/item/shield/riot/roman(H), TRUE)
	H.put_in_hands(new /obj/item/claymore(H), TRUE)
	H.equip_to_slot_or_del(new /obj/item/spear(H), ITEM_SLOT_BACK)


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/voodoo_link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0
	max_integrity = 10
	resistance_flags = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && cooldown < world.time)
		if(I.get_temperature())
			to_chat(target, "<span class='userdanger'>You suddenly feel very hot!</span>")
			target.adjust_bodytemperature(50)
			GiveHint(target)
		else if(I.get_sharpness() == SHARP_POINTY)
			to_chat(target, "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_selected)]!</span>")
			target.Paralyze(40)
			GiveHint(target)
		else if(istype(I, /obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			SEND_SOUND(target, 'sound/items/airhorn.ogg')
			var/obj/item/organ/ears/ears = user.getorganslot(ORGAN_SLOT_EARS)
			if(ears)
				ears.adjustEarDamage(0, 3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!voodoo_link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			if (user.transferItemToLoc(I,src))
				voodoo_link = I
				to_chat(user, "You attach [I] to the doll.")
				update_targets()

/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user)
	if(!target && possible.len)
		target = input(user, "Select your victim!", "Voodoo") as null|anything in sortNames(possible)
		return

	if(user.zone_selected == BODY_ZONE_CHEST)
		if(voodoo_link)
			target = null
			voodoo_link.forceMove(drop_location())
			to_chat(user, "<span class='notice'>You remove the [voodoo_link] from the doll.</span>")
			voodoo_link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_MOUTH)
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw, forced = "voodoo doll")
				log_game("[key_name(user)] made [key_name(target)] say [wgw] with a voodoo doll.")
			if(BODY_ZONE_PRECISE_EYES)
				user.set_machine(src)
				user.reset_perspective(target)
				addtimer(CALLBACK(src, .proc/reset, user), 10 SECONDS)
			if(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
				to_chat(user, "<span class='notice'>You move the doll's legs around.</span>")
				var/turf/T = get_step(target,pick(GLOB.cardinals))
				target.Move(T)
			if(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
				target.click_random_mob()
				GiveHint(target)
			if(BODY_ZONE_HEAD)
				to_chat(user, "<span class='notice'>You smack the doll's head with your hand.</span>")
				target.Dizzy(10)
				to_chat(target, "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/reset(mob/user)
	if(QDELETED(user))
		return
	user.reset_perspective(null)
	user.unset_machine()

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!voodoo_link)
		return
	var/list/prints = voodoo_link.return_fingerprints()
	if(!length(prints))
		return FALSE
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(prints[md5(H.dna.uni_identity)])
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>You feel a dark presence from [way].</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>You feel a dark presence from [A.name].</span>")

/obj/item/voodoo/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] links the voodoo doll to [user.p_them()]self and sits on it, infinitely crushing [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	return(BRUTELOSS)

/obj/item/voodoo/fire_act(exposed_temperature, exposed_volume)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

//Warp Whistle: Provides uncontrolled long distance teleportation.
/obj/item/warpwhistle
	name = "warp whistle"
	desc = "One toot on this whistle will send you to a far away land!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"
	var/on_cooldown = 0 //0: usable, 1: in use, 2: on cooldown
	var/mob/living/carbon/last_user

/obj/item/warpwhistle/proc/interrupted(mob/living/carbon/user)
	if(!user || QDELETED(src) || user.notransform)
		on_cooldown = FALSE
		return TRUE
	return FALSE

/obj/item/warpwhistle/proc/end_effect(mob/living/carbon/user)
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~GODMODE
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)


/obj/item/warpwhistle/attack_self(mob/living/carbon/user)
	if(!istype(user) || on_cooldown)
		return
	on_cooldown = TRUE
	last_user = user
	var/turf/T = get_turf(user)
	playsound(T,'sound/magic/warpwhistle.ogg', 200, TRUE)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	if(interrupted(user))
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, WARPWHISTLE_TRAIT)
		return
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= GODMODE
	sleep(20)
	if(interrupted(user))
		end_effect(user)
		return
	var/breakout = 0
	while(breakout < 50)
		var/turf/potential_T = find_safe_turf()
		if(T.z != potential_T.z || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			do_teleport(user, potential_T, channel = TELEPORT_CHANNEL_MAGIC)
			T = potential_T
			break
		breakout += 1
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	end_effect(user)
	if(interrupted(user))
		return
	on_cooldown = 2
	addtimer(VARSET_CALLBACK(src, on_cooldown, 0), 4 SECONDS)

/obj/item/warpwhistle/Destroy()
	if(on_cooldown == 1 && last_user) //Flute got dunked somewhere in the teleport
		end_effect(last_user)
	return ..()

/obj/effect/temp_visual/tornado
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	name = "tornado"
	desc = "This thing sucks!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 40
	pixel_x = 500

/obj/effect/temp_visual/tornado/Initialize()
	. = ..()
	animate(src, pixel_x = -500, time = 40)
