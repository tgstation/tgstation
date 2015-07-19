
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
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/singularity/narsie/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = 0 //if 1, ignores checking for mobs on loc before spawning

/obj/item/weapon/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(usr), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] hums with power as [usr] deals a blow to [activate_descriptor] itself!</span>")
	else
		user << "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>"

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = 0

/obj/effect/rend/New(loc, var/spawn_type, var/spawn_amt, var/desc, var/spawn_fast)
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	SSobj.processing |= src
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
		user.visible_message("<span class='danger'>[usr] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	..()

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
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
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
	w_class = 1
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/device/necromantic_stone/unlimited
	unlimited = 1

/obj/item/device/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M, /mob/living/carbon/human))
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

	hardset_dna(M, null, null, null, null, /datum/species/skeleton)
	M.revive()
	spooky_scaries |= M
	M << "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>"
	M << "<span class='userdanger'>They are your master now, assist them even if it costs you your new life!</span>"

	equip_roman_skeleton(M)

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/device/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!istype(X, /mob/living/carbon/human))
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
		H.unEquip(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
	H.equip_to_slot_or_del(new hat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/roman(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_r_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), slot_back)



/////////////////////Multiverse Blade////////////////////
var/global/list/multiverse = list()

/obj/item/weapon/multisword
	name = "multiverse sword"
	desc = "A weapon capable of conquering the universe and beyond. Activate it to summon copies of yourself from others dimensions to fight by your side."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "energy_katana"
	item_state = "energy_katana"
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 20
	throwforce = 10
	w_class = 2
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/faction = list("unassigned")
	var/cooldown = 0
	var/assigned = "unassigned"
	var/evil = TRUE

/obj/item/weapon/multisword/New()
	..()
	multiverse |= src


/obj/item/weapon/multisword/Destroy()
	multiverse.Remove(src)
	..()

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
			if(!usr.mind.special_role)
				if(prob(30))
					user << "<span class='warning'><B>With your new found power you could easily conquer the station!</B></span>"
					var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
					hijack_objective.owner = usr.mind
					usr.mind.objectives += hijack_objective
					hijack_objective.explanation_text = "Ensure only [usr.real_name] and their copies are on the shuttle!"
					usr << "<B>Objective #[1]</B>: [hijack_objective.explanation_text]"
					ticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = TRUE
				else
					user << "<span class='warning'><B>With your new found power you could easily defend the station!</B></span>"
					var/datum/objective/survive/new_objective = new /datum/objective/survive
					new_objective.owner = usr.mind
					new_objective.explanation_text = "Survive, and help defend the innocent from the mobs of multiverse clones."
					usr << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
					usr.mind.objectives += new_objective
					ticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = FALSE
		else
			var/list/candidates = get_candidates(BE_WIZARD)
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


/obj/item/weapon/multisword/proc/spawn_copy(var/client/C, var/turf/T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	M.mind.name = usr.real_name
	M << "<B>You are an alternate version of [usr.real_name] from another universe! Help them accomplish their goals at all costs.</B>"
	M.real_name = usr.real_name
	M.name = usr.real_name
	M.faction = list("[usr.real_name]")
	equip_copy(M)

	if(evil)
		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = M.mind
		M.mind.objectives += hijack_objective
		hijack_objective.explanation_text = "Ensure only [usr.real_name] and their copies are on the shuttle!"
		M << "<B>Objective #[1]</B>: [hijack_objective.explanation_text]"
		M.mind.special_role = "multiverse traveller"
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] hijack.")
	else
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = M:mind
		new_objective:target = usr:mind
		new_objective.explanation_text = "Protect [usr.real_name], your copy, and help them defend the innocent from the mobs of multiverse clones."
		M.mind.objectives += new_objective
		M << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
		M.mind.special_role = "multiverse traveller"
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] protect the station.")

/obj/item/weapon/multisword/proc/equip_copy(var/mob/living/carbon/human/M)

	var/obj/item/weapon/multisword/sword = new /obj/item/weapon/multisword
	sword.assigned = assigned
	sword.faction = list("[assigned]")
	sword.evil = evil

	var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet")

	switch(randomize)
		if("mobster")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), slot_w_uniform)
			M.equip_to_slot_or_del(sword, slot_r_hand)

		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			M.equip_to_slot_or_del(new hat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/roman(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/roman(M), slot_l_hand)
			M.equip_to_slot_or_del(sword, slot_r_hand)

		if("wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("cyborg")
			var/obj/item/organ/limb/chest/C = locate(/obj/item/organ/limb/chest) in M.organs
			qdel(C)
			M.organs += new /obj/item/organ/limb/robot/chest
			var/obj/item/organ/limb/r_arm/R = locate(/obj/item/organ/limb/r_arm) in M.organs
			qdel(R)
			M.organs += new /obj/item/organ/limb/robot/r_arm
			var/obj/item/organ/limb/l_arm/L = locate(/obj/item/organ/limb/l_arm) in M.organs
			qdel(L)
			M.organs += new /obj/item/organ/limb/robot/l_arm
			var/obj/item/organ/limb/l_leg/LL = locate(/obj/item/organ/limb/l_leg) in M.organs
			qdel(LL)
			M.organs += new /obj/item/organ/limb/robot/l_leg
			var/obj/item/organ/limb/r_leg/RL = locate(/obj/item/organ/limb/r_leg) in M.organs
			qdel(RL)
			M.organs += new /obj/item/organ/limb/robot/r_leg
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("syndicate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),slot_wear_mask)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("assistant")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("animu")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl/red(M), slot_w_uniform)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("cultist")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("highlander")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(sword, slot_r_hand)
		if("clown")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_l_store)
			M.equip_to_slot_or_del(sword, slot_r_hand)
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
			M.equip_to_slot_or_del(sword, slot_r_hand)
			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))
					carried_item.add_blood(M)
		if("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(sword, slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
		if("soviet")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)

		else
			return

	ready_dna(M)
	if(M.dna && prob(50))
		var/list/all_species = list()
		for(var/speciestype in typesof(/datum/species) - /datum/species)
			var/datum/species/S = new speciestype()
			if(!S.dangerous_existence)
				all_species += speciestype
		hardset_dna(M, null, null, null, null, pick(all_species))
	M.update_icons()

	var/obj/item/weapon/card/id/W = new /obj/item/weapon/card/id
	W.icon_state = "centcom"
	W.access += access_maint_tunnels
	W.assignment = "Multiverse Traveller"
	W.registered_name = M.real_name
	W.update_label(M.real_name)
	M.equip_to_slot_or_del(W, slot_wear_id)
