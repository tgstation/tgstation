
/proc/build_hog_construction_lists()
	if(global_handofgod_traptypes.len && global_handofgod_structuretypes.len)
		return

	var/list/types = subtypesof(/obj/structure/divine) - /obj/structure/divine/trap
	for(var/T in types)
		var/obj/structure/divine/D = T
		if(initial(D.constructable))
			if(initial(D.trap))
				global_handofgod_traptypes[initial(D.name)] = T
			else
				global_handofgod_structuretypes[initial(D.name)] = T

/obj/structure/divine
	name = "divine construction site"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	desc = "An unfinished divine building"
	anchored = 1
	density = 1
	var/constructable = TRUE
	var/trap = FALSE
	var/metal_cost = 0
	var/glass_cost = 0
	var/lesser_gem_cost = 0
	var/greater_gem_cost = 0
	var/mob/camera/god/deity
	var/side = "neutral" //"blue" or "red", also used for colouring structures when construction is started by a deity
	var/health = 100
	var/maxhealth = 100
	var/deactivated = 0		//Structures being hidden can't be used. Mainly to prevent invisible defense pylons.
	var/autocolours = TRUE //do we colour to our side?

/obj/structure/divine/New()
	..()

/obj/structure/divine/proc/deactivate()
	deactivated = 1

/obj/structure/divine/proc/activate()
	deactivated = 0


/obj/structure/divine/proc/update_icons()
	if(autocolours)
		icon_state = "[initial(icon_state)]-[side]"


/obj/structure/divine/Destroy()
	if(deity)
		deity.structures -= src
	return ..()


/obj/structure/divine/proc/healthcheck()
	if(!health)
		visible_message("<span class='danger'>\The [src] was destroyed!</span>")
		qdel(src)


/obj/structure/divine/attackby(obj/item/I, mob/user)
	if(!I || (I.flags & ABSTRACT))
		return 0

	//Structure conversion/capture
	if(istype(I, /obj/item/weapon/godstaff))
		if(!is_handofgod_cultist(user))
			user << "<span class='notice'>You're not quite sure what the hell you're even doing.</span>"
			return
		var/obj/item/weapon/godstaff/G = I
		if(G.god && deity != G.god)
			assign_deity(G.god, alert_old_deity = TRUE)
			visible_message("<span class='boldnotice'>\The [src] has been captured by [user]!</span>")
		return

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(get_turf(src), I.hitsound, 50, 1)
	visible_message("<span class='danger'>\The [src] has been attacked with \the [I][(user ? " by [user]" : ".")]!</span>")
	health = max(0, health-I.force)
	healthcheck()


/obj/structure/divine/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return 0

	if(Proj.damage_type == BRUTE || Proj.damage_type == BURN)
		health = max(0, health-Proj.damage)
		healthcheck()


/obj/structure/divine/attack_animal(mob/living/simple_animal/M)
	if(!M)
		return 0

	visible_message("<span class='danger'>\The [src] has been attacked by \the [M]!</span>")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage)
		return
	health = max(0, health-damage)
	healthcheck()


/obj/structure/divine/proc/assign_deity(mob/camera/god/new_deity, alert_old_deity = TRUE)
	if(!new_deity)
		return 0
	if(deity)
		if(alert_old_deity)
			deity << "<span class='danger'><B>Your [name] was captured by [new_deity]'s cult!</B></span>"
		deity.structures -= src
	deity = new_deity
	deity.structures |= src
	side = deity.side
	update_icons()
	return 1


/obj/structure/divine/construction_holder
	alpha = 125
	constructable = FALSE
	var/obj/structure/divine/construction_result = /obj/structure/divine //a path, but typed to /obj/structure/divine for initial()



/obj/structure/divine/construction_holder/assign_deity(mob/camera/god/new_deity, alert_old_deity = TRUE)
	if(..())
		color = side


/obj/structure/divine/construction_holder/attack_god(mob/camera/god/user)
	if(user.side == side && construction_result)
		user.add_faith(75)
		visible_message("<span class='danger'>[user] has cancelled \the [initial(construction_result.name)]")
		qdel(src)


/obj/structure/divine/construction_holder/proc/setup_construction(construct_type)
	if(ispath(construct_type))
		construction_result = construct_type
		name = "[initial(construction_result.name)] construction site "
		icon_state = initial(construction_result.icon_state)
		metal_cost = initial(construction_result.metal_cost)
		glass_cost = initial(construction_result.glass_cost)
		lesser_gem_cost = initial(construction_result.lesser_gem_cost)
		greater_gem_cost = initial(construction_result.greater_gem_cost)
		desc = "An unfinished [initial(construction_result.name)]."


/obj/structure/divine/construction_holder/attackby(obj/item/I, mob/user)
	if(!I || !user)
		return 0

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(metal_cost)
			var/spend = min(metal_cost, M.amount)
			user << "<span class='notice'>You add [spend] metal to \the [src]."
			metal_cost = max(0, metal_cost - spend)
			M.use(spend)
			check_completion()
		else
			user << "<span class='notice'>\The [src] does not require any more metal!"
		return

	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(glass_cost)
			var/spend = min(glass_cost, G.amount)
			user << "<span class='notice'>You add [spend] glass to \the [src]."
			glass_cost = max(0, glass_cost - spend)
			G.use(spend)
			check_completion()
		else
			user << "<span class='notice'>\The [src] does not require any more glass!"
		return

	if(istype(I, /obj/item/stack/sheet/lessergem))
		var/obj/item/stack/sheet/lessergem/LG = I
		if(lesser_gem_cost)
			var/spend = min(lesser_gem_cost, LG.amount)
			user << "<span class='notice'>You add [spend] lesser gems to \the [src]."
			lesser_gem_cost = max(0, lesser_gem_cost - spend)
			LG.use(spend)
			check_completion()
		else
			user << "<span class='notice'>\The [src] does not require any more lesser gems!"
		return

	if(istype(I, /obj/item/stack/sheet/greatergem))
		var/obj/item/stack/sheet/greatergem/GG = I //GG!
		if(greater_gem_cost)
			var/spend = min(greater_gem_cost, GG.amount)
			user << "<span class='notice'>You add [spend] greater gems to \the [src]."
			greater_gem_cost = max(0, greater_gem_cost - spend)
			GG.use(spend)
			check_completion()
		else
			user << "<span class='notice'>\The [src] does not require any more greater gems!"
		return

	..()


/obj/structure/divine/construction_holder/proc/check_completion()
	if(!metal_cost && !glass_cost && !lesser_gem_cost && !greater_gem_cost)
		visible_message("<span class='notice'>\The [initial(construction_result.name)] is complete!</span>")
		var/obj/structure/divine/D = new construction_result (get_turf(src))
		D.assign_deity(deity)
		qdel(src)


/obj/structure/divine/construction_holder/examine(mob/user)
	..()

	if(metal_cost || glass_cost || lesser_gem_cost || greater_gem_cost)
		user << "To finish construction it requires the following materials:"
		if(metal_cost)
			user << "[metal_cost] metal <IMG CLASS=icon SRC=icons/obj/items.dmi ICONSTATE='sheet-metal'>"
		if(glass_cost)
			user << "[glass_cost] glass <IMG CLASS=icon SRC=icons/obj/items.dmi ICONSTATE='sheet-glass'>"
		if(lesser_gem_cost)
			user << "[lesser_gem_cost] lesser gems <IMG CLASS=icon SRC=icons/obj/items.dmi ICONSTATE='sheet-lessergem'>"
		if(greater_gem_cost)
			user << "[greater_gem_cost] greater gems <IMG CLASS=icon SRC=icons/obj/items.dmi ICONSTATE='sheet-greatergem'>"


/obj/structure/divine/nexus
	name = "nexus"
	desc = "It anchors a deity to this world. It radiates an unusual aura. Cultists protect this at all costs. It looks well protected from explosive shock."
	icon_state = "nexus"
	health = 500
	maxhealth = 500
	constructable = FALSE
	var/faith_regen_rate = 1
	var/list/powerpylons = list()


/obj/structure/divine/nexus/ex_act()
	return


/obj/structure/divine/nexus/healthcheck()
	if(deity)
		deity.update_health_hud()

	if(!health)
		if(!qdeleted(deity) && deity.nexus_required)
			deity << "<span class='danger'>Your nexus was destroyed. You feel yourself fading...</span>"
			qdel(deity)
		visible_message("<span class='danger'>\The [src] was destroyed!</span>")
		qdel(src)


/obj/structure/divine/nexus/New()
	SSobj.processing |= src


/obj/structure/divine/nexus/process()
	healthcheck()
	if(deity)
		deity.update_followers()
		deity.add_faith(faith_regen_rate + (powerpylons.len / 5) + (deity.alive_followers / 3))
		deity.max_faith = initial(deity.max_faith) + (deity.alive_followers*10) //10 followers = 100 max faith, so disaster() at around 20 followers
		deity.check_death()


/obj/structure/divine/nexus/Destroy()
	SSobj.processing -= src
	return ..()


/obj/structure/divine/conduit
	name = "conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"
	health = 150
	maxhealth = 150
	metal_cost = 10
	glass_cost = 5


/obj/structure/divine/conduit/assign_deity(mob/camera/god/new_deity, alert_old_deity = TRUE)
	if(deity)
		deity.conduits -= src
	..()
	if(deity)
		deity.conduits += src

/obj/structure/divine/conduit/deactivate()
	..()
	if(deity)
		deity.conduits -= src

/obj/structure/divine/conduit/activate()
	..()
	if(deity)
		deity.conduits += src

/* //No good sprites, and not enough items to make it viable yet
/obj/structure/divine/forge
	name = "forge"
	desc = "A forge fueled by divine might, it allows the creation of sacred and powerful artifacts.  It requires common materials to craft objects."
	icon_state = "forge"
	health = 250
	maxhealth = 250
	density = 0
	maxhealth = 250
	metal_cost = 40
*/

/obj/structure/divine/convertaltar
	name = "conversion altar"
	desc = "An altar dedicated to a deity.  Cultists can \"forcefully teach\" their non-aligned crewmembers to join their side and take up their deity."
	icon_state = "convertaltar"
	density = 0
	metal_cost = 10
	can_buckle = 1


/obj/structure/divine/convertaltar/attack_hand(mob/living/user)
	..()
	if(deactivated)
		return
	var/mob/living/carbon/human/H = locate() in get_turf(src)
	if(!is_handofgod_cultist(user))
		user << "<span class='notice'>You try to use it, but unfortunately you don't know any rituals.</span>"
		return
	if(!H)
		return
	if(!H.mind)
		user << "<span class='danger'>Only sentients may serve your deity.</span>"
		return
	if((side == "red" && is_handofgod_redcultist(user) && !is_handofgod_redcultist(H)) || (side == "blue" && is_handofgod_bluecultist(user) && !is_handofgod_bluecultist(H)))
		user << "<span class='notice'>You invoke the conversion ritual.</span>"
		ticker.mode.add_hog_follower(H.mind, side)
	else
		user << "<span class='notice'>You invoke the conversion ritual.</span>"
		user << "<span class='danger'>But the altar ignores your words...</span>"


/obj/structure/divine/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity.  The cultists performing the sacrifice will gain a powerful material to use in their forge.  Sacrificing a prophet will yield even better results."
	icon_state = "sacrificealtar"
	density = 0
	metal_cost = 15
	can_buckle = 1


/obj/structure/divine/sacrificealtar/attack_hand(mob/living/user)
	..()
	if(deactivated)
		return
	var/mob/living/L = locate() in get_turf(src)
	if(!is_handofgod_cultist(user))
		user << "<span class='notice'>You try to use it, but unfortunately you don't know any rituals.</span>"
		return
	if(!L)
		return
	if((side == "red" && is_handofgod_redcultist(user))	|| (side == "blue" && is_handofgod_bluecultist(user)))
		if((side == "red" && is_handofgod_redcultist(L)) || (side == "blue" && is_handofgod_bluecultist(L)))
			user << "<span class='danger'>You cannot sacrifice a fellow cultist.</span>"
			return
		user << "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>"
		sacrifice(L)
	else
		user << "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>"
		user << "<span class='danger'>But the altar ignores your words...</span>"


/obj/structure/divine/sacrificealtar/proc/sacrifice(mob/living/L)
	if(!L)
		L = locate() in get_turf(src)
	if(L)
		if(ismonkey(L))
			var/luck = rand(1,4)
			if(luck > 3)
				new /obj/item/stack/sheet/lessergem(get_turf(src))

		else if(ishuman(L))
			var/mob/living/carbon/human/H = L

			//Sacrifice altars can't teamkill
			if(side == "red" && is_handofgod_redcultist(H))
				return
			else if(side == "blue" && is_handofgod_bluecultist(H))
				return

			if(is_handofgod_prophet(H))
				new /obj/item/stack/sheet/greatergem(get_turf(src))
				if(deity)
					deity.prophets_sacrificed_in_name++
			else
				new /obj/item/stack/sheet/lessergem(get_turf(src))

		else if(isAI(L) || istype(L, /mob/living/carbon/alien/humanoid/royal/queen))
			new /obj/item/stack/sheet/greatergem(get_turf(src))
		else
			new /obj/item/stack/sheet/lessergem(get_turf(src))
		L.gib()


/obj/structure/divine/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life... or death, depending on where your allegiances lie."
	icon_state = "fountain"
	metal_cost = 10
	glass_cost = 5
	autocolours = FALSE
	var/time_between_uses = 1800
	var/last_process = 0
	var/cult_only = TRUE

/obj/structure/divine/healingfountain/anyone
	desc = "A fountain containing the waters of life."
	cult_only = FALSE

/obj/structure/divine/healingfountain/attack_hand(mob/living/user)
	if(deactivated)
		return
	if(last_process + time_between_uses > world.time)
		user << "<span class='notice'>The fountain appears to be empty.</span>"
		return
	last_process = world.time
	if(!is_handofgod_cultist(user) && cult_only)
		user << "<span class='danger'><B>The water burns!</b></spam>"
		user.reagents.add_reagent("hell_water",20)
	else
		user << "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>"
		user.reagents.add_reagent("godblood",20)
	update_icons()
	spawn(time_between_uses)
		if(src)
			update_icons()


/obj/structure/divine/healingfountain/update_icons()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-[side]"


/obj/structure/divine/powerpylon
	name = "power pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	icon_state = "powerpylon"
	density = 1
	health = 30
	maxhealth = 30
	metal_cost = 5
	glass_cost = 15


/obj/structure/divine/powerpylon/New()
	..()
	if(deity && deity.god_nexus)
		deity.god_nexus.powerpylons += src


/obj/structure/divine/powerpylon/Destroy()
	if(deity && deity.god_nexus)
		deity.god_nexus.powerpylons -= src
	return ..()


/obj/structure/divine/powerpylon/deactivate()
	..()
	if(deity)
		deity.god_nexus.powerpylons -= src

/obj/structure/divine/powerpylon/activate()
	..()
	if(deity)
		deity.god_nexus.powerpylons += src

/obj/structure/divine/defensepylon
	name = "defense pylon"
	desc = "A pylon which is blessed to withstand many blows, and fire strong bolts at nonbelievers. A god can toggle it."
	icon_state = "defensepylon"
	health = 150
	maxhealth = 150
	metal_cost = 25
	glass_cost = 30
	var/obj/machinery/porta_turret/defensepylon_internal_turret/pylon_gun


/obj/structure/divine/defensepylon/New()
	..()
	pylon_gun = new(src)
	pylon_gun.base = src
	pylon_gun.faction = list("[side] god")


/obj/structure/divine/defensepylon/Destroy()
	qdel(pylon_gun) //just in case
	return ..()


/obj/structure/divine/defensepylon/examine(mob/user)
        ..()
        user << "<span class='notice'>\The [src] looks [pylon_gun.on ? "on" : "off"].</span>"


/obj/structure/divine/defensepylon/assign_deity(mob/camera/god/new_deity, alert_old_deity = TRUE)
	if(..() && pylon_gun)
		pylon_gun.faction = list("[side] god")
		pylon_gun.side = side

/obj/structure/divine/defensepylon/attack_god(mob/camera/god/user)
	if(user.side == side)
		if(deactivated)
			user << "You need to reveal it first!"
			return
		pylon_gun.on = !pylon_gun.on
		icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"

/obj/structure/divine/defensepylon/deactivate()
	..()
	pylon_gun.on = 0
	icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"

/obj/structure/divine/defensepylon/activate()
	..()
	pylon_gun.on = 1
	icon_state = (pylon_gun.on) ? "defensepylon-[side]" : "defensepylon"

//This sits inside the defensepylon, to avoid copypasta
/obj/machinery/porta_turret/defensepylon_internal_turret
	name = "defense pylon"
	desc = "A plyon which is blessed to withstand many blows, and fire strong bolts at nonbelievers."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	installation = null
	always_up = 1
	use_power = 0
	has_cover = 0
	health = 200
	projectile =  /obj/item/projectile/beam/pylon_bolt
	eprojectile =  /obj/item/projectile/beam/pylon_bolt
	shot_sound =  'sound/weapons/emitter2.ogg'
	eshot_sound = 'sound/weapons/emitter2.ogg'
	base_icon_state = "defensepylon"
	active_state = ""
	off_state = ""
	faction = null
	emp_vunerable = 0
	var/side = "neutral"

/obj/machinery/porta_turret/defensepylon_internal_turret/setup()
	return

/obj/machinery/porta_turret/defensepylon_internal_turret/shootAt(atom/movable/target)
	var/obj/item/projectile/A = ..()
	if(A)
		A.color = side

/obj/machinery/porta_turret/defensepylon_internal_turret/assess_perp(mob/living/carbon/human/perp)
	if(perp.handcuffed) //dishonourable to kill somebody who might be converted.
		return 0
	var/badtarget = 0
	switch(side)
		if("blue")
			badtarget = is_handofgod_bluecultist(perp)
		if("red")
			badtarget = is_handofgod_redcultist(perp)
		else
			badtarget = 1
	if(badtarget)
		return 0
	return 10



/obj/item/projectile/beam/pylon_bolt
	name = "divine bolt"
	icon_state = "greyscale_bolt"
	damage = 15


/obj/structure/divine/shrine
	name = "shrine"
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"
	metal_cost = 15
	glass_cost = 15


/obj/structure/divine/shrine/assign_deity(mob/camera/god/new_deity, alert_old_deity = TRUE)
	if(..())
		name = "shrine to [new_deity.name]"
		desc = "A shrine dedicated to [new_deity.name]"




//Functional, but need sprites
/*
/obj/structure/divine/translocator
	name = "translocator"
	desc = "A powerful structure, made with a greater gem.  It allows a deity to move their nexus to where this stands"
	icon_state = "translocator"
	health = 100
	maxhealth = 100
	metal_cost = 20
	glass_cost = 20
	greater_gem_cost = 1


/obj/structure/divine/lazarusaltar
	name = "lazarus altar"
	desc = "A very powerful altar capable of bringing life back to the recently deceased, made with a greater gem.  It can revive anyone and will heal virtually all wounds, but they are but a shell of their former self."
	icon_state = "lazarusaltar"
	density = 0
	health = 100
	maxhealth = 100
	metal_cost = 20
	greater_gem_cost = 1


/obj/structure/divine/lazarusaltar/attack_hand(mob/living/user)
	var/mob/living/L = locate() in get_turf(src)
	if(!is_handofgod_culstist(user))
		user << "<span class='notice'>You try to use it, but unfortunately you don't know any rituals.</span>"
		return
	if(!L)
		return

	if((side == "red" && is_handofgod_redcultist(user))) || (side == "blue" && is_handofgod_bluecultist(user)))
		user << "<span class='notice'>You attempt to revive [L] by invoking the rebirth ritual.</span>"
		L.revive()
		L.adjustCloneLoss(50)
		L.adjustStaminaLoss(100)
	else
		user << "<span class='notice'>You attempt to revive [L] by invoking the rebirth ritual.</span>"
		user << "<span class='danger'>But the altar ignores your words...</span>"
*/


