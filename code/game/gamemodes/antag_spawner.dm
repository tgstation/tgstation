/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(var/client/C, var/turf/T, var/type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target as mob)
	return

/obj/item/weapon/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/weapon/antag_spawner/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/antag_spawner/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["school"])
			if (used)
				H << "You already used this contract!"
				return
			var/list/candidates = get_candidates(BE_WIZARD)
			if(candidates.len)
				src.used = 1
				var/client/C = pick(candidates)
				spawn_antag(C, get_turf(H.loc), href_list["school"])
				if(H.mind)
					ticker.mode.update_wiz_icons_added(H.mind)
			else
				H << "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."

/obj/item/weapon/antag_spawner/contract/spawn_antag(var/client/C, var/turf/T, var/type = "")
	PoolOrNew(/obj/effect/effect/smoke, T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	M << "<B>You are the [usr.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
	switch(type)
		if("destruction")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball."
		if("bluespace")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt."
		if("healing")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(null))
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/magic/staff/healing(M), slot_r_hand)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall."
		if("robeless")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap."

	equip_antag(M)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/newname = copytext(sanitize(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	M.mind.name = newname
	M.real_name = newname
	M.name = newname
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = M:mind
	new_objective:target = usr:mind
	new_objective.explanation_text = "Protect [usr.real_name], the wizard."
	M.mind.objectives += new_objective
	ticker.mode.traitors += M.mind
	M.mind.special_role = "apprentice"
	ticker.mode.update_wiz_icons_added(M.mind)
	M << sound('sound/effects/magic.ogg')

/obj/item/weapon/antag_spawner/contract/equip_antag(mob/target as mob)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_ears)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(target), slot_r_store)

/obj/item/weapon/antag_spawner/borg_tele
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/TC_cost = 0

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user as mob)
	if(used)
		user << "The teleporter is out of power."
		return
	var/list/borg_candicates = get_candidates(BE_OPERATIVE)
	if(borg_candicates.len > 0)
		used = 1
		var/client/C = pick(borg_candicates)
		spawn_antag(C, get_turf(src.loc), "syndieborg")
	else
		user << "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>"

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(var/client/C, var/turf/T, var/type = "")
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = list("syndicate")


/obj/item/weapon/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"


/obj/item/weapon/antag_spawner/slaughter_demon/attack_self(mob/user as mob)
	var/list/demon_candidates = get_candidates(BE_ALIEN)
	if(user.z != 1)
		user << "<span class='notice'>You should probably wait until you reach the station.</span>"
		return
	if(demon_candidates.len > 0)
		used = 1
		var/client/C = pick(demon_candidates)
		spawn_antag(C, get_turf(src.loc), "Slaughter Demon")
		user << "<span class='notice'>You shatter the bottle, no turning back now!</span>"
		user << "<span class='notice'>You sense a dark presence lurking just beyond the veil...</span>"
		playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
		qdel(src)
	else
		user << "<span class='notice'>You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later.</span>"


/obj/item/weapon/antag_spawner/slaughter_demon/spawn_antag(var/client/C, var/turf/T, var/type = "")

	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	S.phased = TRUE
	S.key = C.key
	S.mind.assigned_role = "Slaughter Demon"
	S.mind.special_role = "Slaughter Demon"
	ticker.mode.traitors += S.mind
	var/datum/objective/assassinate/new_objective = new /datum/objective/assassinate
	new_objective.owner = S:mind
	new_objective:target = usr:mind
	new_objective.explanation_text = "Kill [usr.real_name], the one who summoned you."
	S.mind.objectives += new_objective
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = S:mind
	new_objective2.explanation_text = "Kill everyone else while you're at it."
	S.mind.objectives += new_objective2
	S << S.playstyle_string
	S << "<B>You are currently not currently in the same plane of existence as the station. Ctrl+Click a blood pool to manifest.</B>"
	S << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
	S << "<B>Objective #[2]</B>: [new_objective2.explanation_text]"

/obj/item/weapon/antag_spawner/elemental
	name = "elemental figurine"
	desc = "You have a feeling you shouldn't be seeing this in its current state..."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	var/summonType = "earth"
	var/flavorText = "You activate the figurine!"
	var/usedFlavorText = "The figure's powers are spent."

/obj/item/weapon/antag_spawner/elemental/attack_self(mob/user as mob)
	var/list/candidates = get_candidates(BE_WIZARD)
	if(user.z != 1)
		user << "<span class='notice'>[src] seems dormant here. Perhaps the aura here isn't strong enough.</span>"
		return
	if(used)
		user << "<span class='notice'>[usedFlavorText]</span>"
		return
	if(candidates.len > 0)
		used = 1
		var/client/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), summonType, user)
		user << "<span class='notice'>[flavorText]</span>"
	else
		user << "<span class='notice'>[src] seems dormant at the moment. Perhaps it may work later.</span>"

/obj/item/weapon/antag_spawner/elemental/spawn_antag(var/client/C, var/turf/T, var/type = "", var/mob/user)
	if(!user)
		return
	switch(type)
		if(null)
			return
		if("earth")
			visible_message("<span class='warning'>[src] begins to expand!</span>")
			var/mob/living/simple_animal/elemental/earth/E = new(get_turf(src))
			E.key = C.key
			E.master = user
		if("air")
			visible_message("<span class='warning'>The swirling clouds expand and pulse, crackling with lightning, into a living storm.</span>")
			var/mob/living/simple_animal/elemental/air/A = new(get_turf(src))
			A.key = C.key
			A.master = user
		if("fire")
			visible_message("<span class='warning'>The flame rapidly grows to a living inferno.</span>")
			var/mob/living/simple_animal/elemental/fire/F = new(get_turf(src))
			F.key = C.key
			F.master = user
		if("water")
			visible_message("<span class='warning'>A form rises from the water pool.</span>")
			var/mob/living/simple_animal/elemental/water/W = new(get_turf(src))
			W.key = C.key
			W.master = user
		if("life")
			visible_message("<span class='warning'>With the creaking of wood and crunching of leaves, the sap grows into a tree.</span>")
			var/mob/living/simple_animal/elemental/life/L = new(get_turf(src))
			L.key = C.key
			L.master = user
			if(prob(1))
				L.say("I am Groot!")
		if("death")
			visible_message("<span class='warning'>Red mist swirls rapidly around the skull and darkens to black.</span>")
			var/mob/living/simple_animal/elemental/necrotic/D = new(get_turf(src))
			D.key = C.key
			D.master = user
		if("arcane")
			visible_message("<span class='warning'>The markings pulse and throb. The air shimmers and something emerges.</span>")
			var/mob/living/simple_animal/elemental/arcane/AC = new(get_turf(src))
			AC.key = C.key
			AC.master = user
		if("unbound")
			visible_message("<span class='warning'>The twisted matter on the ground begins to expand and groan outward.</span>")
			var/mob/living/simple_animal/elemental/unbound/U = new(get_turf(src))
			U.key = C.key
			U.master = user
	qdel(src)

/obj/item/weapon/antag_spawner/elemental/earth
	name = "obsidian heart"
	desc = "A small likeness of a human heart carved of black obsidian. It feels hot to the touch."
	summonType = "earth"
	flavorText = "You drop the heart to the ground, and it begins to break apart, lava seeping from its cracks."
	usedFlavorText = "The heart is cold and dead."

/obj/item/weapon/antag_spawner/elemental/air
	name = "phial of cloud essence"
	desc = "A sturdy glass phial filled with white, swirling mist. It strains to get out."
	summonType = "air"
	flavorText = "You uncap the vial. Its contents whirl into the air and begin to twist into a shape."
	usedFlavorText = "This vial is empty."

/obj/item/weapon/antag_spawner/elemental/fire
	name = "everburning flame"
	desc = "A flickering flame about the size of a lantern. It doesn't seem to produce much heat."
	summonType = "fire"
	flavorText = "You grip the flame in your hands. It immediately heats up and floats into the air, expanding rapidly."
	usedFlavorText = "There's nothing but a pile of ashes."

/obj/item/weapon/antag_spawner/elemental/water
	name = "tidal globe"
	desc = "A small enclosure of some gelatinous substance. Encapsuled within is a tiny, raging sea."
	summonType = "water"
	flavorText = "You gently apply pressure to the orb. Immediately it pops open and the water within floods out."
	usedFlavorText = "The sac is deflated and empty."

/obj/item/weapon/antag_spawner/elemental/life
	name = "ever-blooming frond"
	desc = "A gorgeous green plant that seems to have a mind of its own."
	summonType = "life"
	flavorText = "You crush the plant's leaves in your hand. Green sap seeps through your fingers and begins to shift."
	usedFlavorText = "There is nothing but a pile of crushed detritus."

/obj/item/weapon/antag_spawner/elemental/death
	name = "charred skull"
	desc = "An eerie skull that seems blackened from fire. Two tiny red dots glimmer in its eye sockets."
	summonType = "death"
	flavorText = "You pry the jawbone off of the skull. Immediately red mist flows out of the skull's mouth and begins forming."
	usedFlavorText = "The relic seems dead - it is just a skull, after all. Duh."

/obj/item/weapon/antag_spawner/elemental/arcane
	name = "invocationist's rune"
	desc = "Some strange chalk markings engraved on a limestone tablet."
	summonType = "arcane"
	flavorText = "After some fumbles, you manage to speak the words of the engravings. The markings begin to shift and turn."
	usedFlavorText = "It's just a blank tablet."

/obj/item/weapon/antag_spawner/elemental/unbound //The !!FUN!! elemental
	name = "elemental amalgation"
	desc = "This is an aberration of random debris encapsuled in a gently-vibrating glass container. Are you sure about this?"
	summonType = "unbound"
	flavorText = "You hold your breath and drop the bottle. The glass vanishes and its contents begin to coalesce into... something."
