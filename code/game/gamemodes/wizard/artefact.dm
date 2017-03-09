
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/singularity/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = 0 //if 1, ignores checking for mobs on loc before spawning

/obj/item/weapon/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		user << "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>"

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	anchored = 1
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = 0

/obj/effect/rend/New(loc, var/spawn_type, var/spawn_amt, var/desc, var/spawn_fast)
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
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	else
		return ..()

/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/weapon/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"

////TEAR IN REALITY

/obj/singularity/wizard
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	grav_pull = 6
	consume_range = 3
	current_size = STAGE_FOUR
	allowed_size = STAGE_FOUR

/obj/singularity/wizard/process()
	move()
	eat()
	return
/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user)
	user << "<span class='notice'>You can see...everything!</span>"
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)
	return

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/device/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/device/necromantic_stone/unlimited
	unlimited = 1

/obj/item/device/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(!istype(user) || !user.canUseTopic(M,1))
		return

	if(M.stat != DEAD)
		user << "<span class='warning'>This artifact can only affect the dead!</span>"
		return

	if(!M.mind || !M.client)
		user << "<span class='warning'>There is no soul connected to this body...</span>"
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		user << "<span class='warning'>This artifact can only affect three undead at a time!</span>"
		return

	M.set_species(/datum/species/skeleton, icon_update=0)
	M.revive(full_heal = 1, admin_revive = 1)
	spooky_scaries |= M
	M << "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>"
	M << "<span class='userdanger'>[user.p_they(TRUE)] [user.p_are()] your master now, assist them even if it costs you your new life!</span>"

	equip_roman_skeleton(M)

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/device/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/device/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.dropItemToGround(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
	H.equip_to_slot_or_del(new hat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	H.put_in_hands_or_del(new /obj/item/weapon/shield/riot/roman(H))
	H.put_in_hands_or_del(new /obj/item/weapon/claymore(H))
	H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), slot_back)



/////////////////////Multiverse Blade////////////////////
var/global/list/multiverse = list()

/obj/item/weapon/multisword
	name = "multiverse sword"
	desc = "A weapon capable of conquering the universe and beyond. Activate it to summon copies of yourself from others dimensions to fight by your side."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "multiverse"
	item_state = "multiverse"
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	sharpness = IS_SHARP
	force = 20
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/faction = list("unassigned")
	var/cooldown = 0
	var/assigned = "unassigned"

/obj/item/weapon/multisword/New()
	..()
	multiverse |= src


/obj/item/weapon/multisword/Destroy()
	multiverse.Remove(src)
	return ..()

/obj/item/weapon/multisword/attack_self(mob/user)
	if(user.mind.special_role == "apprentice")
		user << "<span class='warning'>You know better than to touch your teacher's stuff.</span>"
		return
	if(cooldown < world.time)
		var/faction_check = 0
		for(var/F in faction)
			if(F in user.faction)
				faction_check = 1
				break
		if(faction_check == 0)
			faction = list("[user.real_name]")
			assigned = "[user.real_name]"
			user.faction = list("[user.real_name]")
			user << "You bind the sword to yourself. You can now use it to summon help."
			if(!is_gangster(user))
				var/datum/gang/multiverse/G = new(src, "[user.real_name]")
				ticker.mode.gangs += G
				G.bosses += user.mind
				G.add_gang_hud(user.mind)
				user.mind.gang_datum = G
				user << "<span class='warning'><B>With your new found power you could easily conquer the station!</B></span>"
				var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
				hijack_objective.owner = user.mind
				user.mind.objectives += hijack_objective
				hijack_objective.explanation_text = "Ensure only [user.real_name] and their copies are on the shuttle!"
				user << "<B>Objective #[1]</B>: [hijack_objective.explanation_text]"
				ticker.mode.traitors += user.mind
				user.mind.special_role = "[user.real_name] Prime"
		else
			var/list/candidates = get_candidates(ROLE_WIZARD)
			if(candidates.len)
				var/client/C = pick(candidates)
				spawn_copy(C, get_turf(user.loc), user)
				user << "<span class='warning'><B>The sword flashes, and you find yourself face to face with...you!</B></span>"
				cooldown = world.time + 400
				for(var/obj/item/weapon/multisword/M in multiverse)
					if(M.assigned == assigned)
						M.cooldown = cooldown

			else
				user << "You fail to summon any copies of yourself. Perhaps you should try again in a bit."
	else
		user << "<span class='warning'><B>[src] is recharging! Keep in mind it shares a cooldown with the swords wielded by your copies.</span>"


/obj/item/weapon/multisword/proc/spawn_copy(var/client/C, var/turf/T, mob/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M, icon_updates=0)
	M.key = C.key
	M.mind.name = user.real_name
	M << "<B>You are an alternate version of [user.real_name] from another universe! Help them accomplish their goals at all costs.</B>"
	ticker.mode.add_gangster(M.mind, user.mind.gang_datum, FALSE)
	M.real_name = user.real_name
	M.name = user.real_name
	M.faction = list("[user.real_name]")
	if(prob(50))
		var/list/all_species = list()
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = new speciestype()
			if(!S.dangerous_existence)
				all_species += speciestype
		M.set_species(pick(all_species), icon_update=0)
	M.update_body()
	M.update_hair()
	M.update_body_parts()
	M.dna.update_dna_identity()
	equip_copy(M)

/obj/item/weapon/multisword/proc/equip_copy(var/mob/living/carbon/human/M)

	var/obj/item/weapon/multisword/sword = new /obj/item/weapon/multisword
	sword.assigned = assigned
	sword.faction = list("[assigned]")

	var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet", "officer", "gladiator")

	switch(randomize)
		if("mobster")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), slot_w_uniform)
			M.put_in_hands_or_del(sword)

		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			M.equip_to_slot_or_del(new hat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/roman(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), slot_shoes)
			M.put_in_hands_or_del(new /obj/item/weapon/shield/riot/roman(M))
			M.put_in_hands_or_del(sword)

		if("wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
			M.put_in_hands_or_del(sword)
		if("cyborg")
			for(var/X in M.bodyparts)
				var/obj/item/bodypart/affecting = X
				affecting.change_bodypart_status(BODYPART_ROBOTIC)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.put_in_hands_or_del(sword)

		if("syndicate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),slot_wear_mask)
			M.put_in_hands_or_del(sword)

		if("assistant")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
			M.put_in_hands_or_del(sword)

		if("animu")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl/red(M), slot_w_uniform)
			M.put_in_hands_or_del(sword)

		if("cultist")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.put_in_hands_or_del(sword)

		if("highlander")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.put_in_hands_or_del(sword)

		if("clown")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_l_store)
			M.put_in_hands_or_del(sword)

		if("killer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/scalpel(M), slot_r_store)
			M.put_in_hands_or_del(sword)
			for(var/obj/item/carried_item in M.get_equipped_items())
				carried_item.add_mob_blood(M)
			for(var/obj/item/I in M.held_items)
				I.add_mob_blood(M)
		if("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.put_in_hands_or_del(sword)

		if("soviet")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/pirate/captain(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate/captain(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
			M.put_in_hands_or_del(sword)

		if("officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/miljacket(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.put_in_hands_or_del(sword)

		if("gladiator")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gladiator(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/gladiator(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.put_in_hands_or_del(sword)


		else
			return

	M.update_body_parts()

	var/obj/item/weapon/card/id/W = new /obj/item/weapon/card/id
	W.icon_state = "centcom"
	W.access += access_maint_tunnels
	W.assignment = "Multiverse Traveller"
	W.registered_name = M.real_name
	W.update_label(M.real_name)
	M.equip_to_slot_or_del(W, slot_wear_id)


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	item_state = "electronic"
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0
	obj_integrity = 10
	max_integrity = 10
	resistance_flags = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && cooldown < world.time)
		if(I.is_hot())
			target << "<span class='userdanger'>You suddenly feel very hot</span>"
			target.bodytemperature += 50
			GiveHint(target)
		else if(is_pointed(I))
			target << "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_selected)]!</span>"
			target.Weaken(2)
			GiveHint(target)
		else if(istype(I,/obj/item/weapon/bikehorn))
			target << "<span class='userdanger'>HONK</span>"
			target << 'sound/items/AirHorn.ogg'
			target.adjustEarDamage(0,3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			user.drop_item()
			I.loc = src
			link = I
			user << "You attach [I] to the doll."
			update_targets()

/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user)
	if(!target && possible.len)
		target = input(user, "Select your victim!", "Voodoo") as null|anything in possible
		return

	if(user.zone_selected == "chest")
		if(link)
			target = null
			link.loc = get_turf(src)
			user << "<span class='notice'>You remove the [link] from the doll.</span>"
			link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if("mouth")
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw)
				log_game("[user][user.key] made [target][target.key] say [wgw] with a voodoo doll.")
			if("eyes")
				user.set_machine(src)
				user.reset_perspective(target)
				spawn(100)
					user.reset_perspective(null)
					user.unset_machine()
			if("r_leg","l_leg")
				user << "<span class='notice'>You move the doll's legs around.</span>"
				var/turf/T = get_step(target,pick(cardinal))
				target.Move(T)
			if("r_arm","l_arm")
				target.click_random_mob()
				GiveHint(target)
			if("head")
				user << "<span class='notice'>You smack the doll's head with your hand.</span>"
				target.Dizzy(10)
				target << "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>"
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!link)
		return
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(md5(H.dna.uni_identity) in link.fingerprints)
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		victim << "<span class='notice'>You feel a dark presence from [way]</span>"
	if(prob(20) || force)
		var/area/A = get_area(src)
		victim << "<span class='notice'>You feel a dark presence from [A.name]</span>"

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
	if(!user || QDELETED(src))
		on_cooldown = FALSE
		return TRUE
	return FALSE

/obj/item/warpwhistle/attack_self(mob/living/carbon/user)
	if(!istype(user) || on_cooldown)
		return
	on_cooldown = TRUE
	last_user = user
	var/turf/T = get_turf(user)
	playsound(T,'sound/magic/WarpWhistle.ogg', 200, 1)
	user.canmove = 0
	new /obj/effect/overlay/temp/tornado(T)
	sleep(20)
	if(interrupted(user))
		return
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= GODMODE
	sleep(20)
	if(interrupted(user))
		return
	var/breakout = 0
	while(breakout < 50)
		var/turf/potential_T = find_safe_turf()
		if(T.z != potential_T.z || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			user.forceMove(potential_T)
			user.canmove = 0
			T = potential_T
			break
		breakout += 1
	new /obj/effect/overlay/temp/tornado(T)
	sleep(20)
	if(interrupted(user))
		return
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~GODMODE
	user.canmove = 1
	on_cooldown = 2
	sleep(40)
	on_cooldown = 0

/obj/item/warpwhistle/Destroy()
	if(on_cooldown == 1 && last_user) //Flute got dunked somewhere in the teleport
		last_user.invisibility = initial(last_user.invisibility)
		last_user.status_flags &= ~GODMODE
		last_user.canmove = 1
	return ..()

/obj/effect/overlay/temp/tornado
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	name = "tornado"
	desc = "This thing sucks!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 40
	pixel_x = 500

/obj/effect/overlay/temp/tornado/New(loc)
	..()
	animate(src, pixel_x = -500, time = 40)
