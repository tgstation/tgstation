//////////////////////////
// CLOCKWORK STRUCTURES //
//////////////////////////

/obj/structure/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc //Shown to servants when they examine
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	anchored = 1
	density = 1
	opacity = 0
	layer = BELOW_OBJ_LAYER
	var/max_health = 100 //All clockwork structures have health that can be removed via attacks
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	var/list/debris = list(/obj/item/clockwork/alloy_shards) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station

/obj/structure/clockwork/New()
	..()
	clockwork_construction_value += construction_value
	all_clockwork_objects += src

/obj/structure/clockwork/Destroy()
	clockwork_construction_value -= construction_value
	all_clockwork_objects -= src
	return ..()

/obj/structure/clockwork/proc/destroyed()
	if(!takes_damage)
		return 0
	for(var/I in debris)
		new I (get_turf(src))
	visible_message(break_message)
	playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1

/obj/structure/clockwork/burn()
	SSobj.burning -= src
	if(takes_damage)
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		visible_message("<span class='warning'>[src] is warped by the heat!</span>")
		take_damage(rand(50, 100), BURN)

/obj/structure/clockwork/proc/take_damage(amount, damage_type)
	if(!amount || !damage_type || !damage_type in list(BRUTE, BURN))
		return 0
	if(takes_damage)
		health = max(0, health - amount)
		if(!health)
			destroyed()
		return 1
	return 0

/obj/structure/clockwork/narsie_act()
	if(take_damage(rand(25, 50), BRUTE) && src) //if we still exist
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/clockwork/ex_act(severity)
	var/damage = 0
	switch(severity)
		if(1)
			damage = max_health //100% max health lost
		if(2)
			damage = max_health * rand(0.5, 0.7) //50-70% max health lost
		if(3)
			damage = max_health * rand(0.1, 0.3) //10-30% max health lost
	if(damage)
		take_damage(damage, BRUTE)

/obj/structure/clockwork/examine(mob/user)
	var/can_see_clockwork = is_servant_of_ratvar(user) || isobserver(user)
	if(can_see_clockwork && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)
	if(takes_damage)
		var/servant_message = "It is at <b>[health]/[max_health]</b> integrity"
		var/other_message = "It seems pristine and undamaged"
		var/heavily_damaged = FALSE
		var/healthpercent = (health/max_health) * 100
		if(healthpercent >= 100)
			other_message = "It seems pristine and undamaged"
		else if(healthpercent >= 50)
			other_message = "It looks slightly dented"
		else if(healthpercent >= 25)
			other_message = "It appears heavily damaged"
			heavily_damaged = TRUE
		else if(healthpercent >= 0)
			other_message = "It's falling apart"
			heavily_damaged = TRUE
		user << "<span class='[heavily_damaged ? "alloy":"brass"]'>[can_see_clockwork ? "[servant_message]":"[other_message]"][heavily_damaged ? "!":"."]</span>"

/obj/structure/clockwork/bullet_act(obj/item/projectile/P)
	. = ..()
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
	take_damage(P.damage, P.damage_type)

/obj/structure/clockwork/proc/attack_generic(mob/user, damage = 0, damage_type = BRUTE) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes into [src]!</span>")
	take_damage(damage, damage_type)

/obj/structure/clockwork/attack_alien(mob/living/user)
	attack_generic(user, 15)

/obj/structure/clockwork/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper)
		return
	attack_generic(M, M.melee_damage_upper, M.melee_damage_type)

/obj/structure/clockwork/attack_slime(mob/living/simple_animal/slime/user)
	if(!user.is_adult)
		return
	attack_generic(user, rand(10, 15))

/obj/structure/clockwork/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.force && takes_damage)
		take_damage(I.force, I.damtype)
		playsound(src, I.hitsound, 50, 1)

/obj/structure/clockwork/mech_melee_attack(obj/mecha/M)
	if(..())
		take_damage(M.force, M.damtype)

/obj/structure/clockwork/cache //Tinkerer's cache: Stores components for later use.
	name = "tinkerer's cache"
	desc = "A large brass spire with a flaming hole in its center."
	clockwork_desc = "A brass container capable of storing a large amount of components.\n\
	Shares components with all other caches and will gradually generate components if near a Clockwork Wall."
	icon_state = "tinkerers_cache"
	construction_value = 10
	break_message = "<span class='warning'>The cache's fire winks out before it falls in on itself!</span>"
	var/wall_generation_cooldown
	var/wall_found = FALSE //if we've found a wall and finished our windup delay

/obj/structure/clockwork/cache/New()
	..()
	SSobj.processing += src
	clockwork_caches++

/obj/structure/clockwork/cache/Destroy()
	clockwork_caches--
	SSobj.processing -= src
	return ..()

/obj/structure/clockwork/cache/destroyed()
	if(takes_damage)
		for(var/I in src)
			var/atom/movable/A = I
			A.forceMove(get_turf(src)) //drop any daemons we have
	return ..()

/obj/structure/clockwork/cache/process()
	for(var/turf/closed/wall/clockwork/C in orange(1, src))
		if(!wall_found)
			wall_found = TRUE
			wall_generation_cooldown = world.time + CACHE_PRODUCTION_TIME
			visible_message("<span class='warning'>[src] starts to whirr in the presence of [C]...</span>")
			break
		if(wall_generation_cooldown <= world.time)
			wall_generation_cooldown = world.time + CACHE_PRODUCTION_TIME
			generate_cache_component()
			playsound(C, 'sound/magic/clockwork/fellowship_armory.ogg', rand(15, 20), 1, -3, 1, 1)
			visible_message("<span class='warning'>Something clunks around inside of [src]...</span>")
			break

/obj/structure/clockwork/cache/attackby(obj/item/I, mob/living/user, params)
	if(!is_servant_of_ratvar(user))
		return ..()
	if(istype(I, /obj/item/clockwork/component))
		var/obj/item/clockwork/component/C = I
		clockwork_component_cache[C.component_id]++
		user << "<span class='notice'>You add [C] to [src].</span>"
		user.drop_item()
		qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/clockwork_proselytizer))
		var/obj/item/clockwork/clockwork_proselytizer/P = I
		if(P.uses_alloy && P.stored_alloy + REPLICANT_ALLOY_UNIT <= P.max_alloy)
			if(clockwork_component_cache["replicant_alloy"])
				user.visible_message("<span class='notice'>[user] places the end of [P] in the hole in [src]...</span>", \
				"<span class='notice'>You start filling [P] with liquified alloy...</span>")
				while(P && P.uses_alloy && P.stored_alloy + REPLICANT_ALLOY_UNIT <= P.max_alloy && clockwork_component_cache["replicant_alloy"] && do_after(user, 10, target = src) \
				&& P && P.uses_alloy &&  P.stored_alloy + REPLICANT_ALLOY_UNIT <= P.max_alloy && clockwork_component_cache["replicant_alloy"]) //hugeass check because we need to re-check after the do_after
					P.modify_stored_alloy(REPLICANT_ALLOY_UNIT)
					clockwork_component_cache["replicant_alloy"]--
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(P && user)
					user.visible_message("<span class='notice'>[user] removes [P] from the hole in [src], apparently satisfied.</span>", \
					"<span class='brass'>You finish filling [P] with liquified alloy. It now contains [P.stored_alloy]/[P.max_alloy] units of liquified alloy.</span>")
			else
				user << "<span class='warning'>There is no Replicant Alloy in the global component cache!</span>"
		else
			user << "<span class='warning'>[P]'s containers of liquified alloy are full!</span>"
		return 1
	else if(istype(I, /obj/item/clockwork/slab))
		var/obj/item/clockwork/slab/S = I
		clockwork_component_cache["belligerent_eye"] += S.stored_components["belligerent_eye"]
		clockwork_component_cache["vanguard_cogwheel"] += S.stored_components["vanguard_cogwheel"]
		clockwork_component_cache["guvax_capacitor"] += S.stored_components["guvax_capacitor"]
		clockwork_component_cache["replicant_alloy"] += S.stored_components["replicant_alloy"]
		clockwork_component_cache["hierophant_ansible"] += S.stored_components["hierophant_ansible"]
		S.stored_components["belligerent_eye"] = 0
		S.stored_components["vanguard_cogwheel"] = 0
		S.stored_components["guvax_capacitor"] = 0
		S.stored_components["replicant_alloy"] = 0
		S.stored_components["hierophant_ansible"] = 0
		user.visible_message("<span class='notice'>[user] empties [S] into [src].</span>", "<span class='notice'>You offload your slab's components into [src].</span>")
		return 1
	else if(istype(I, /obj/item/clockwork/daemon_shell))
		var/component_type
		switch(alert(user, "Will this daemon produce a specific type of component or produce randomly?.", , "Specific Type", "Random Component"))
			if("Specific Type")
				switch(input(user, "Choose a component type.", name) as null|anything in list("Belligerent Eyes", "Vanguard Cogwheels", "Guvax Capacitors", "Replicant Alloys", "Hierophant Ansibles"))
					if("Belligerent Eyes")
						component_type = "belligerent_eye"
					if("Vanguard Cogwheels")
						component_type = "vanguard_cogwheel"
					if("Guvax Capacitors")
						component_type = "guvax_capacitor"
					if("Replicant Alloys")
						component_type = "replicant_alloy"
					if("Hierophant Ansibles")
						component_type = "hierophant_ansibles"
		if(!user || !user.canUseTopic(src) || !user.canUseTopic(I))
			return 0
		var/obj/item/clockwork/tinkerers_daemon/D = new(src)
		D.cache = src
		D.specific_component = component_type
		user.visible_message("<span class='notice'>[user] spins the cogwheel on [I] and puts it into [src].</span>", \
		"<span class='notice'>You activate the daemon and put it into [src]. It will now produce a component every twenty seconds.</span>")
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()

/obj/structure/clockwork/cache/attack_hand(mob/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/list/possible_components = list()
	if(clockwork_component_cache["belligerent_eye"])
		possible_components += "Belligerent Eye"
	if(clockwork_component_cache["vanguard_cogwheel"])
		possible_components += "Vanguard Cogwheel"
	if(clockwork_component_cache["guvax_capacitor"])
		possible_components += "Guvax Capacitor"
	if(clockwork_component_cache["replicant_alloy"])
		possible_components += "Replicant Alloy"
	if(clockwork_component_cache["hierophant_ansible"])
		possible_components += "Hierophant Ansible"
	if(!possible_components.len)
		user << "<span class='warning'>[src] is empty!</span>"
		return 0
	var/component_to_withdraw = input(user, "Choose a component to withdraw.", name) as null|anything in possible_components
	if(!user || !user.canUseTopic(src) || !component_to_withdraw)
		return 0
	var/obj/item/clockwork/component/the_component
	switch(component_to_withdraw)
		if("Belligerent Eye")
			if(clockwork_component_cache["belligerent_eye"])
				the_component = new/obj/item/clockwork/component/belligerent_eye(get_turf(src))
				clockwork_component_cache["belligerent_eye"]--
		if("Vanguard Cogwheel")
			if(clockwork_component_cache["vanguard_cogwheel"])
				the_component = new/obj/item/clockwork/component/vanguard_cogwheel(get_turf(src))
				clockwork_component_cache["vanguard_cogwheel"]--
		if("Guvax Capacitor")
			if(clockwork_component_cache["guvax_capacitor"])
				the_component = new/obj/item/clockwork/component/guvax_capacitor(get_turf(src))
				clockwork_component_cache["guvax_capacitor"]--
		if("Replicant Alloy")
			if(clockwork_component_cache["replicant_alloy"])
				the_component = new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
				clockwork_component_cache["replicant_alloy"]--
		if("Hierophant Ansible")
			if(clockwork_component_cache["hierophant_ansible"])
				the_component = new/obj/item/clockwork/component/hierophant_ansible(get_turf(src))
				clockwork_component_cache["hierophant_ansible"]--
	if(the_component)
		user.visible_message("<span class='notice'>[user] withdraws [the_component] from [src].</span>", "<span class='notice'>You withdraw [the_component] from [src].</span>")
		user.put_in_hands(the_component)
	return 1

/obj/structure/clockwork/cache/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<b>Stored components:</b>"
		user << "<span class='neovgre_small'><i>Belligerent Eyes:</i> [clockwork_component_cache["belligerent_eye"]]</span>"
		user << "<span class='inathneq_small'><i>Vanguard Cogwheels:</i> [clockwork_component_cache["vanguard_cogwheel"]]</span>"
		user << "<span class='sevtug_small'><i>Guvax Capacitors:</i> [clockwork_component_cache["guvax_capacitor"]]</span>"
		user << "<span class='nezbere_small'><i>Replicant Alloys:</i> [clockwork_component_cache["replicant_alloy"]]</span>"
		user << "<span class='nzcrentr_small'><i>Hierophant Ansibles:</i> [clockwork_component_cache["hierophant_ansible"]]</span>"


/obj/structure/clockwork/ocular_warden //Ocular warden: Low-damage, low-range turret. Deals constant damage to whoever it makes eye contact with.
	name = "ocular warden"
	desc = "A large brass eye with tendrils trailing below it and a wide red iris."
	clockwork_desc = "A stalwart turret that will deal sustained damage to any non-faithful it sees."
	icon_state = "ocular_warden"
	health = 25
	max_health = 25
	construction_value = 15
	layer = HIGH_OBJ_LAYER
	break_message = "<span class='warning'>The warden's eye gives a glare of utter hate before falling dark!</span>"
	debris = list(/obj/item/clockwork/component/belligerent_eye/blind_eye)
	burn_state = LAVA_PROOF
	var/damage_per_tick = 3
	var/sight_range = 3
	var/mob/living/target
	var/list/idle_messages = list(" sulkily glares around.", " lazily drifts from side to side.", " looks around for something to burn.", " slowly turns in circles.")

/obj/structure/clockwork/ocular_warden/New()
	..()
	SSfastprocess.processing += src

/obj/structure/clockwork/ocular_warden/Destroy()
	SSfastprocess.processing -= src
	return ..()

/obj/structure/clockwork/ocular_warden/examine(mob/user)
	..()
	user << "<span class='brass'>[target ? "<b>It's fixated on [target]!</b>" : "Its gaze is wandering aimlessly."]</span>"

/obj/structure/clockwork/ocular_warden/process()
	var/list/validtargets = acquire_nearby_targets()
	if(ratvar_awakens && (damage_per_tick == initial(damage_per_tick) || sight_range == initial(sight_range))) //Massive buff if Ratvar has returned
		damage_per_tick = 10
		sight_range = 5
	if(target)
		if(!(target in validtargets))
			lose_target()
		else
			target.adjustFireLoss(!iscultist(target) ? damage_per_tick : damage_per_tick * 2) //Nar-Sian cultists take additional damage
			if(ratvar_awakens && target)
				target.adjust_fire_stacks(damage_per_tick)
				target.IgniteMob()
			setDir(get_dir(get_turf(src), get_turf(target)))
	if(!target)
		if(validtargets.len)
			target = pick(validtargets)
			visible_message("<span class='warning'>[src] swivels to face [target]!</span>")
			target << "<span class='heavy_brass'>\"I SEE YOU!\"</span>\n<span class='userdanger'>[src]'s gaze [ratvar_awakens ? "melts you alive" : "burns you"]!</span>"
		else if(prob(0.5)) //Extremely low chance because of how fast the subsystem it uses processes
			if(prob(50))
				visible_message("<span class='notice'>[src] [pick(idle_messages)]</span>")
			else
				setDir(pick(cardinal))//Random rotation

/obj/structure/clockwork/ocular_warden/proc/acquire_nearby_targets()
	. = list()
	for(var/mob/living/L in viewers(sight_range, src)) //Doesn't attack the blind
		if(!is_servant_of_ratvar(L) && !L.stat && L.mind && !(L.disabilities & BLIND))
			. += L

/obj/structure/clockwork/ocular_warden/proc/lose_target()
	if(!target)
		return 0
	target = null
	visible_message("<span class='warning'>[src] settles and seems almost disappointed.</span>")
	return 1

/obj/structure/clockwork/anima_fragment //Anima fragment: Useless on its own, but can accept an active soul vessel to create a powerful construct.
	name = "anima fragment"
	desc = "A massive brass shell with a small cube-shaped receptable in its center. It gives off an aura of contained power."
	clockwork_desc = "A dormant receptable that, when powered with a soul vessel, will become a powerful construct."
	icon_state = "anime_fragment"
	construction_value = 0
	anchored = 0
	density = 0
	takes_damage = FALSE
	burn_state = LAVA_PROOF

/obj/structure/clockwork/anima_fragment/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/device/mmi/posibrain/soul_vessel))
		if(!is_servant_of_ratvar(user))
			..()
			return 0
		var/obj/item/device/mmi/posibrain/soul_vessel/S = I
		if(!S.brainmob)
			user << "<span class='warning'>[S] hasn't trapped a spirit! Turn it on first.</span>"
			return 0
		if(S.brainmob && (!S.brainmob.client || !S.brainmob.mind))
			user << "<span class='warning'>[S]'s trapped spirit appears inactive!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] places [S] in [src], where it fuses to the shell.</span>", "<span class='brass'>You place [S] in [src], fusing it to the shell.</span>")
		var/mob/living/simple_animal/hostile/clockwork/fragment/A = new(get_turf(src))
		A.visible_message("[src] whirs and rises from the ground on a flickering jet of reddish fire.")
		S.brainmob.mind.transfer_to(A)
		add_servant_of_ratvar(A, TRUE)
		A << A.playstyle_string
		user.drop_item()
		qdel(S)
		qdel(src)
		return 1
	else
		return ..()



/obj/structure/clockwork/wall_gear
	name = "massive gear"
	icon_state = "wall_gear"
	climbable = TRUE
	desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, or just climb over it."
	clockwork_desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, just climb over it, or proselytize it into replicant alloy."
	break_message = "<span class='warning'>The gear breaks apart into shards of alloy!</span>"
	debris = list(/obj/item/clockwork/alloy_shards)

/obj/structure/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, I, 10)
		return 1
	return ..()

/obj/structure/clockwork/wall_gear/examine(mob/user)
	..()
	user << "<span class='notice'>[src] is [anchored ? "":"un"]secured to the floor.</span>"

///////////////////////
// CLOCKWORK EFFECTS //
///////////////////////

/obj/effect/clockwork
	name = "meme machine"
	desc = "Still don't know what it is."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	anchored = 1
	density = 0
	opacity = 0
	burn_state = LAVA_PROOF

/obj/effect/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/effect/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/effect/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/effect/clockwork/judicial_marker //Judicial marker: Created by the judicial visor. After four seconds, stuns any non-servants nearby and damages Nar-Sian cultists.
	name = "judicial marker"
	desc = "You get the feeling that you shouldn't be standing here."
	clockwork_desc = "A sigil that will soon erupt and smite any unenlightened nearby."
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_MOB_LAYER

/obj/effect/clockwork/judicial_marker/New()
	..()
	flick("judicial_marker", src)
	spawn(16) //Utilizes spawns due to how it works with Ratvar's flame
		layer = ABOVE_ALL_MOB_LAYER
		flick("judicial_explosion", src)
		spawn(14)
			for(var/mob/living/L in range(1, src))
				if(is_servant_of_ratvar(L))
					continue
				if(!iscultist(L))
					L.visible_message("<span class='warning'>[L] is struck by a judicial explosion!</span>", \
					"<span class='userdanger'>[!issilicon(L) ? "An unseen force slams you into the ground!" : "ERROR: Motor servos disabled by external source!"]</span>")
					L.Weaken(8)
				else
					L.visible_message("<span class='warning'>[L] is struck by a judicial explosion!</span>", \
					"<span class='heavy_brass'>\"Keep an eye out, filth.\"</span>\n<span class='userdanger'>A burst of heat crushes you against the ground!</span>")
					L.Weaken(4) //half the stun, but sets cultists on fire
					L.adjust_fire_stacks(2)
					L.IgniteMob()
				L.adjustBruteLoss(10)
			qdel(src)
			return 1

/obj/effect/clockwork/spatial_gateway //Spatial gateway: A usually one-way rift to another location.
	name = "spatial gateway"
	desc = "A gently thrumming tear in reality."
	clockwork_desc = "A gateway in reality."
	icon_state = "spatial_gateway"
	density = 1
	var/sender = TRUE //If this gateway is made for sending, not receiving
	var/both_ways = FALSE
	var/lifetime = 25 //How many deciseconds this portal will last
	var/uses = 1 //How many objects or mobs can go through the portal
	var/obj/effect/clockwork/spatial_gateway/linked_gateway //The gateway linked to this one

/obj/effect/clockwork/spatial_gateway/New()
	..()
	spawn(1)
		if(!linked_gateway)
			qdel(src)
			return 0
		if(both_ways)
			clockwork_desc = "A gateway in reality. It can both send and receive objects."
		else
			clockwork_desc = "A gateway in reality. It can only [sender ? "send" : "receive"] objects."
		addtimer(src, "selfdel", lifetime)

/obj/effect/clockwork/spatial_gateway/proc/selfdel()
	if(src)
		qdel(src)

//set up a gateway with another gateway
/obj/effect/clockwork/spatial_gateway/proc/setup_gateway(obj/effect/clockwork/spatial_gateway/gatewayB, set_duration, set_uses, two_way)
	if(!gatewayB || !set_duration || !uses)
		return 0
	linked_gateway = gatewayB
	gatewayB.linked_gateway = src
	if(two_way)
		both_ways = TRUE
		gatewayB.both_ways = TRUE
	else
		sender = TRUE
		gatewayB.sender = FALSE
		gatewayB.density = FALSE
	lifetime = set_duration
	gatewayB.lifetime = set_duration
	uses = set_uses
	gatewayB.uses = set_uses
	return 1

/obj/effect/clockwork/spatial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='brass'>It has [uses] uses remaining.</span>"

/obj/effect/clockwork/spatial_gateway/attack_hand(mob/living/user)
	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.has_buckled_mobs())
			return 0
		user.visible_message("<span class='warning'>[user] shoves [L] into [src]!</span>", "<span class='danger'>You shove [L] into [src]!</span>")
		user.stop_pulling()
		pass_through_gateway(L)
		return 1
	if(!user.canUseTopic(src))
		return 0
	user.visible_message("<span class='warning'>[user] climbs through [src]!</span>", "<span class='danger'>You brace yourself and step through [src]...</span>")
	pass_through_gateway(user)
	return 1

/obj/effect/clockwork/spatial_gateway/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='warning'>[user] dispels [src] with [I]!</span>", "<span class='danger'>You close [src] with [I]!</span>")
		qdel(linked_gateway)
		qdel(src)
		return 1
	if(user.drop_item())
		user.visible_message("<span class='warning'>[user] drops [I] into [src]!</span>", "<span class='danger'>You drop [I] into [src]!</span>")
		pass_through_gateway(I)
	..()

/obj/effect/clockwork/spatial_gateway/Bumped(atom/A)
	..()
	if(isliving(A) || istype(A, /obj/item))
		pass_through_gateway(A)

/obj/effect/clockwork/spatial_gateway/proc/pass_through_gateway(atom/movable/A)
	if(!linked_gateway)
		qdel(src)
		return 0
	if(!sender)
		visible_message("<span class='warning'>[A] bounces off of [src]!</span>")
		return 0
	if(!uses)
		return 0
	if(isliving(A))
		var/mob/living/user = A
		user << "<span class='warning'><b>You pass through [src] and appear elsewhere!</b></span>"
	linked_gateway.visible_message("<span class='warning'>A shape appears in [linked_gateway] before emerging!</span>")
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	playsound(linked_gateway, 'sound/effects/EMPulse.ogg', 50, 1)
	transform = matrix() * 1.5
	animate(src, transform = matrix() / 1.5, time = 10)
	linked_gateway.transform = matrix() * 1.5
	animate(linked_gateway, transform = matrix() / 1.5, time = 10)
	A.forceMove(get_turf(linked_gateway))
	uses = max(0, uses - 1)
	linked_gateway.uses = max(0, linked_gateway.uses - 1)
	spawn(10)
		if(!uses)
			qdel(src)
			qdel(linked_gateway)
	return 1

/obj/effect/clockwork/general_marker
	name = "general marker"
	desc = "Some big guy."
	clockwork_desc = "One of Ratvar's generals."
	alpha = 200
	layer = MASSIVE_OBJ_LAYER

/obj/effect/clockwork/general_marker/New()
	..()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 50, 0)
	animate(src, alpha = 0, time = 10)
	addtimer(src, "selfdel", 10)

/obj/effect/clockwork/general_marker/proc/selfdel()
	qdel(src)

/obj/effect/clockwork/general_marker/nezbere
	name = "Nezbere, the Brass Eidolon"
	desc = "A towering colossus clad in nigh-impenetrable brass armor. Its gaze is stern yet benevolent, even upon you."
	clockwork_desc = "One of Ratvar's four generals. Nezbere is responsible for the design, testing, and creation of everything in Ratvar's domain."
	icon = 'icons/effects/340x428.dmi'
	icon_state = "nezbere"
	pixel_x = -154
	pixel_y = -198

/obj/effect/clockwork/general_marker/sevtug
	name = "Sevtug, the Formless Pariah"
	desc = "A sinister cloud of purple energy. Looking at it gives you a headache."
	clockwork_desc = "One of Ratvar's four generals. Sevtug taught him how to manipulate minds and is one of his oldest allies."
	icon = 'icons/effects/211x247.dmi'
	icon_state = "sevtug"
	pixel_x = -89
	pixel_y = -107

/obj/effect/clockwork/general_marker/nzcrentr
	name = "Nzcrentr, the Forgotten Arbiter"
	desc = "A terrifying war machine crackling with limitless energy."
	clockwork_desc = "One of Ratvar's four generals. Nzcrentr is the result of Neovgre - Nezbere's finest war machine, commandeerable only be a mortal - fusing with its pilot and driving her \
	insane. Nzcrentr seeks out any and all sentient life to slaughter it for sport."
	icon = 'icons/effects/254x361.dmi'
	icon_state = "nzcrentr"
	pixel_x = -111
	pixel_y = -164

/obj/effect/clockwork/general_marker/inathneq
	name = "Inath-Neq, the Resonant Cogwheel"
	desc = "A humanoid form blazing with blue fire. It radiates an aura of kindness and caring."
	clockwork_desc = "One of Ratvar's four generals. Before her current form, Inath-Neq was a powerful warrior priestess commanding the Resonant Cogs, a sect of Ratvarian warriors renowned for \
	their prowess. After a lost battle with Nar-Sian cultists, Inath-Neq was struck down and stated in her dying breath, \
	\"The Resonant Cogs shall not fall silent this day, but will come together to form a wheel that shall never stop turning.\" Ratvar, touched by this, granted Inath-Neq an eternal body and \
	merged her soul with those of the Cogs slain with her on the battlefield."
	icon = 'icons/effects/187x381.dmi'
	icon_state = "inath-neq"
	pixel_x = -77
	pixel_y = -174


/obj/effect/clockwork/sigil //Sigils: Rune-like markings on the ground with various effects.
	name = "sigil"
	desc = "A strange set of markings drawn on the ground."
	clockwork_desc = "A sigil of some purpose."
	icon_state = "sigil"
	layer = LOW_OBJ_LAYER
	alpha = 50
	burn_state = FIRE_PROOF
	burntime = 1
	var/affects_servants = FALSE
	var/affects_stat = FALSE

/obj/effect/clockwork/sigil/attack_hand(mob/user)
	if(iscarbon(user) && !user.stat && (!is_servant_of_ratvar(user) || (is_servant_of_ratvar(user) && user.a_intent == "harm")))
		user.visible_message("<span class='warning'>[user] stamps out [src]!</span>", "<span class='danger'>You stomp on [src], scattering it into thousands of particles.</span>")
		qdel(src)
		return 1
	..()

/obj/effect/clockwork/sigil/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(!L.stat || affects_stat)
			if((!is_servant_of_ratvar(L) || (is_servant_of_ratvar(L) && affects_servants)) && L.mind)
				sigil_effects(L)
			return 1

/obj/effect/clockwork/sigil/proc/sigil_effects(mob/living/L)

/obj/effect/clockwork/sigil/transgression //Sigil of Transgression: Stuns and flashes the first non-servant to walk on it. Nar-Sian cultists are damaged and knocked down for about twice the stun
	name = "dull sigil"
	desc = "A dull, barely-visible golden sigil. It's as though light was carved into the ground."
	icon = 'icons/effects/clockwork_effects.dmi'
	clockwork_desc = "A sigil that will stun the first non-servant to cross it. Nar-Sie's dogs will be knocked down."
	icon_state = "sigildull"
	color = "#FAE48C"

/obj/effect/clockwork/sigil/transgression/sigil_effects(mob/living/L)
	var/target_flashed = L.flash_eyes()
	for(var/mob/living/M in viewers(5, src))
		if(!is_servant_of_ratvar(M) && M != L)
			M.flash_eyes()
	if(iscultist(L))
		L << "<span class='heavy_brass'>\"Watch your step, wretch.\"</span>"
		L.adjustBruteLoss(10)
		L.Weaken(4)
	L.visible_message("<span class='warning'>[src] appears around [L] in a burst of light!</span>", \
	"<span class='userdanger'>[target_flashed ? "An unseen force":"The glowing sigil around you"] holds you in place!</span>")
	L.Stun(3)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/sigil/transgression, get_turf(src))
	qdel(src)
	return 1

/obj/effect/clockwork/sigil/submission //Sigil of Submission: After a short time, converts any non-servant standing on it. Knocks down and silences them for five seconds afterwards.
	name = "ominous sigil"
	desc = "A luminous golden sigil. Something about it really bothers you."
	clockwork_desc = "A sigil that will enslave the first person to cross it, provided they remain on it for five seconds."
	icon_state = "sigilsubmission"
	color = "#FAE48C"
	alpha = 125
	var/convert_time = 50
	var/glow_light = 2 //soft light
	var/glow_falloff = 1
	var/delete_on_finish = TRUE
	var/sigil_name = "Sigil of Submission"
	var/glow_type

/obj/effect/clockwork/sigil/submission/New()
	..()
	SetLuminosity(glow_light,glow_falloff)

/obj/effect/clockwork/sigil/submission/proc/post_channel(mob/living/L)

/obj/effect/clockwork/sigil/submission/sigil_effects(mob/living/L)
	visible_message("<span class='warning'>[src] begins to glow a piercing magenta!</span>")
	animate(src, color = "#AF0AAF", time = convert_time)
	var/obj/effect/overlay/temp/ratvar/sigil/glow
	if(glow_type)
		glow = PoolOrNew(glow_type, get_turf(src))
		animate(glow, alpha = 255, time = convert_time)
	var/I = 0
	while(I < convert_time && get_turf(L) == get_turf(src))
		I++
		sleep(1)
	if(get_turf(L) != get_turf(src))
		if(glow)
			qdel(glow)
		animate(src, color = initial(color), time = 20)
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
		return 0
	post_channel(L)
	if(is_eligible_servant(L))
		L << "<span class='heavy_brass'>\"You belong to me now.\"</span>"
	add_servant_of_ratvar(L)
	L.Weaken(3) //Completely defenseless for about five seconds - mainly to give them time to read over the information they've just been presented with
	L.Stun(3)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.silent += 5
	var/message = "[sigil_name] in [get_area(src)] <span class='sevtug'>[is_servant_of_ratvar(L) ? "successfully converted" : "failed to convert"]</span>"
	for(var/M in mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, L)
			M <<  "<span class='heavy_brass'>[link] [message] [L.real_name]!</span>"
		else if(is_servant_of_ratvar(M))
			if(M == L)
				M << "<span class='heavy_brass'>[message] you!</span>"
			else
				M << "<span class='heavy_brass'>[message] [L.real_name]!</span>"
	if(delete_on_finish)
		qdel(src)
	else
		animate(src, color = initial(color), time = 20)
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
	return 1

/obj/effect/clockwork/sigil/submission/accession //Sigil of Accession: After a short time, converts any non-servant standing on it though implants. Knocks down and silences them for five seconds afterwards.
	name = "terrifying sigil"
	desc = "A luminous brassy sigil. Something about it makes you want to flee."
	clockwork_desc = "A sigil that will enslave any person who crosses it, provided they remain on it for five seconds. \n\
	It can convert a mindshielded target once before disppearing, but can convert any number of non-implanted targets."
	icon_state = "sigiltransgression"
	color = "#A97F1B"
	alpha = 200
	glow_light = 4 //bright light
	glow_falloff = 3
	delete_on_finish = FALSE
	sigil_name = "Sigil of Accession"
	glow_type = /obj/effect/overlay/temp/ratvar/sigil/accession

/obj/effect/clockwork/sigil/submission/accession/post_channel(mob/living/L)
	if(isloyal(L))
		delete_on_finish = TRUE
		L.visible_message("<span class='warning'>[L] visibly trembles!</span>", \
		"<span class='sevtug'>Lbh jvyy or zvar-naq-uvf. Guvf chal gevaxrg jvyy abg fgbc zr.</span>")
		for(var/obj/item/weapon/implant/mindshield/M in L)
			if(M.implanted)
				qdel(M)

/obj/effect/clockwork/sigil/transmission
	name = "suspicious sigil"
	desc = "A glowing orange sigil. The air around it feels staticky."
	clockwork_desc = "A sigil that will serve as a battery for clockwork structures. Use Volt Void while standing on it to charge it."
	icon_state = "sigiltransmission"
	color = "#EC8A2D"
	alpha = 50
	var/power_charge = 4000 //starts with 4000W by default

/obj/effect/clockwork/sigil/transmission/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='[power_charge ? "brass":"alloy"]'>It is storing [power_charge]W of power.</span>"

/obj/effect/clockwork/sigil/transmission/sigil_effects(mob/living/L)
	if(power_charge)
		L << "<span class='brass'>You feel a slight, static shock.</span>"
	return 1

/obj/effect/clockwork/sigil/transmission/New()
	..()
	alpha = min(initial(alpha) + power_charge*0.02, 255)

/obj/effect/clockwork/sigil/transmission/proc/modify_charge(amount)
	if(power_charge - amount < 0)
		return 0
	power_charge -= amount
	alpha = min(initial(alpha) + power_charge*0.02, 255)
	return 1

/obj/effect/clockwork/sigil/vitality
	name = "comforting sigil"
	desc = "A faint blue sigil. Looking at it makes you feel protected."
	clockwork_desc = "A sigil that will drain non-servants that remain on it. Servants that remain on it will be healed if it has any vitality drained."
	icon_state = "sigilvitality"
	color = "#123456"
	alpha = 75
	affects_servants = TRUE
	affects_stat = TRUE
	var/vitality = 0
	var/base_revive_cost = 25
	var/sigil_active = FALSE

/obj/effect/clockwork/sigil/vitality/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='[vitality ? "inathneq_small":"alloy"]'>It is storing [vitality] units of vitality.</span>"
		user << "<span class='inathneq_small'>It requires at least [base_revive_cost] units of vitality to revive dead servants, in addition to any damage the servant has.</span>"

/obj/effect/clockwork/sigil/vitality/sigil_effects(mob/living/L)
	if(L.suiciding || sigil_active || !is_servant_of_ratvar(L) && L.stat == DEAD)
		return 0
	visible_message("<span class='warning'>[src] begins to glow bright blue!</span>")
	animate(src, alpha = 255, time = 10)
	sleep(10)
	sigil_active = TRUE
//as long as they're still on the sigil and are either not a servant or they're a servant AND it has remaining vitality
	while(L && (!is_servant_of_ratvar(L) && L.stat != DEAD || (is_servant_of_ratvar(L) && vitality)) && get_turf(L) == get_turf(src))
		PoolOrNew(/obj/effect/overlay/temp/ratvar/sigil/vitality, get_turf(src))
		if(!is_servant_of_ratvar(L))
			var/vitality_drained = L.adjustToxLoss(4)
			if(vitality_drained)
				vitality += vitality_drained
			else
				break
		else
			var/clone_to_heal = L.getCloneLoss()
			var/tox_to_heal = L.getToxLoss()
			var/burn_to_heal = L.getFireLoss()
			var/brute_to_heal = L.getBruteLoss()
			var/oxy_to_heal = L.getOxyLoss()
			var/total_damage = clone_to_heal + tox_to_heal + burn_to_heal + brute_to_heal + oxy_to_heal
			if(L.stat == DEAD)
				var/revival_cost = base_revive_cost + total_damage - oxy_to_heal //ignores oxygen damage
				if(vitality >= revival_cost)
					L.revive(1, 1)
					L.visible_message("<span class='warning'>[L] suddenly gets back up, their mouth dripping blue ichor!</span>", "<span class='inathneq'>\"Lbh jvyy or bxnl, puvyq.\"</span>")
					vitality -= revival_cost
					break
			if(!total_damage)
				break
			var/vitality_for_cycle = min(vitality, 8)

			if(clone_to_heal && vitality_for_cycle)
				var/healing = min(vitality_for_cycle, clone_to_heal)
				vitality_for_cycle -= healing
				L.adjustCloneLoss(-healing)
				vitality -= healing

			if(tox_to_heal && vitality_for_cycle)
				var/healing = min(vitality_for_cycle, tox_to_heal)
				vitality_for_cycle -= healing
				L.adjustToxLoss(-healing)
				vitality -= healing

			if(burn_to_heal && vitality_for_cycle)
				var/healing = min(vitality_for_cycle, burn_to_heal)
				vitality_for_cycle -= healing
				L.adjustFireLoss(-healing)
				vitality -= healing

			if(brute_to_heal && vitality_for_cycle)
				var/healing = min(vitality_for_cycle, brute_to_heal)
				vitality_for_cycle -= healing
				L.adjustBruteLoss(-healing)
				vitality -= healing

			if(oxy_to_heal && vitality_for_cycle)
				var/healing = min(vitality_for_cycle, oxy_to_heal)
				vitality_for_cycle -= healing
				L.adjustOxyLoss(-healing)
				vitality -= healing
		sleep(8)

	sigil_active = FALSE
	animate(src, alpha = initial(alpha), time = 20)
	visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
