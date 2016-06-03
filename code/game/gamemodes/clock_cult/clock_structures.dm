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
	var/max_health = 100 //All clockwork structures have health that can be removed via attacks
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	var/list/debris = list(/obj/item/clockwork/component/replicant_alloy) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station

/obj/structure/clockwork/New()
	..()
	clockwork_construction_value += construction_value
	all_clockwork_objects += src

/obj/structure/clockwork/Destroy()
	clockwork_construction_value -= construction_value
	all_clockwork_objects -= src
	..()

/obj/structure/clockwork/proc/destroyed()
	if(!takes_damage)
		return 0
	for(var/obj/item/I in debris)
		new I (get_turf(src))
	visible_message(break_message)
	playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1

/obj/structure/clockwork/proc/damaged(mob/living/user, obj/item/I, amount, type)
	if(!amount || !type || !type in list(BRUTE, BURN))
		return 0
	if(user.a_intent == "harm" && user.canUseTopic(I) && I.force && takes_damage)
		user.visible_message("<span class='warning'>[user] strikes [src] with [I]!</span>", "<span class='danger'>You strike [src] with [I]!</span>")
		playsound(src, I.hitsound, 50, 1)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		health = max(0, health - I.force)
		if(!health)
			destroyed()
	return 1

/obj/structure/clockwork/ex_act(severity)
	if(takes_damage)
		switch(severity)
			if(1)
				health -= max_health * 0.7 //70% max health lost
			if(2)
				health -= max_health * 0.4 //40% max health lost
			if(3)
				if(prob(50))
					health -= max_health * 0.1 //10% max health lost
		if(health <= max_health * 0.1) //If there's less than 10% max health left, destroy it
			destroyed()
			qdel(src)

/obj/structure/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/structure/clockwork/attacked_by/(obj/item/I, mob/living/user)
	if(user.a_intent == "harm" && user.Adjacent(I) && I.force && takes_damage)
		damaged(user, I, I.force, I.damtype)
	else
		return ..()

/obj/structure/clockwork/cache //Tinkerer's cache: Stores components for later use.
	name = "tinkerer's cache"
	desc = "A large brass spire with a flaming hole in its center."
	clockwork_desc = "A brass container capable of storing a large amount of components. Shares components with all other caches."
	icon_state = "tinkerers_cache"
	construction_value = 10
	break_message = "<span class='warning'>The cache's fire winks out before it falls in on itself!</span>"

/obj/structure/clockwork/cache/New()
	..()
	clockwork_caches++

/obj/structure/clockwork/cache/Destroy()
	clockwork_caches--
	return ..()

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
		"<span class='notice'>You activate the daemon and put it into [src]. It will now produce a component every thirty seconds.</span>")
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
	if(!user || !user.canUseTopic(src) || !component_to_withdraw || !)
		return 0
	var/obj/item/clockwork/component/the_component
	switch(component_to_withdraw)
		if("Belligerent Eye")
			the_component = new/obj/item/clockwork/component/belligerent_eye(get_turf(src))
			clockwork_component_cache["belligerent_eye"]--
		if("Vanguard Cogwheel")
			the_component = new/obj/item/clockwork/component/vanguard_cogwheel(get_turf(src))
			clockwork_component_cache["vanguard_cogwheel"]--
		if("Guvax Capacitor")
			the_component = new/obj/item/clockwork/component/guvax_capacitor(get_turf(src))
			clockwork_component_cache["guvax_capacitor"]--
		if("Replicant Alloy")
			the_component = new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
			clockwork_component_cache["replicant_alloy"]--
		if("Hierophant Ansible")
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
		user << "<i>Belligerent Eyes:</i> [clockwork_component_cache["belligerent_eye"]]"
		user << "<i>Vanguard Cogwheels:</i> [clockwork_component_cache["vanguard_cogwheel"]]"
		user << "<i>Guvax Capacitors:</i> [clockwork_component_cache["guvax_capacitor"]]"
		user << "<i>Replicant Alloys:</i> [clockwork_component_cache["replicant_alloy"]]"
		user << "<i>Hierophant Ansibles:</i> [clockwork_component_cache["hierophant_ansible"]]"

/obj/structure/clockwork/ocular_warden //Ocular warden: Low-damage, low-range turret. Deals constant damage to whoever it makes eye contact with.
	name = "ocular warden"
	desc = "A large brass eye with tendrils trailing below it and a wide red iris."
	clockwork_desc = "A stalwart turret that will deal sustained damage to any non-faithful it sees."
	icon_state = "ocular_warden"
	health = 25
	max_health = 25
	construction_value = 15
	break_message = "<span class='warning'>The warden's eye gives a glare of utter hate before falling dark!</span>"
	debris = list(/obj/item/clockwork/component/replicant_alloy/blind_eye)
	var/damage_per_tick = 3
	var/sight_range = 3
	var/mob/living/target

/obj/structure/clockwork/ocular_warden/New()
	..()
	SSfastprocess.processing += src

/obj/structure/clockwork/ocular_warden/Destroy()
	SSfastprocess.processing -= src
	return ..()

/obj/structure/clockwork/ocular_warden/examine(mob/user)
	..()
	user << "[target ? "It's fixated on [target]" : "Its gaze is wandering aimlessly"]."

/obj/structure/clockwork/ocular_warden/process()
	if(ratvar_awakens && (damage_per_tick == initial(damage_per_tick) || sight_range == initial(sight_range))) //Massive buff if Ratvar has returned
		damage_per_tick = 10
		sight_range = 5
	if(target)
		if(target.stat || get_dist(get_turf(src), get_turf(target)) > sight_range || is_servant_of_ratvar(target))
			lose_target()
		else
			target.adjustFireLoss(!iscultist(target) ? damage_per_tick : damage_per_tick * 2) //Nar-Sian cultists take additional damage
			if(ratvar_awakens && target)
				target.adjust_fire_stacks(damage_per_tick)
				target.IgniteMob()
			dir = get_dir(get_turf(src), get_turf(target))
	else
		if(!acquire_nearby_target() && prob(0.5)) //Extremely low chance because of how fast the subsystem it uses processes
			var/list/idle_messages = list("[src] sulkily glares around.", "[src] lazily drifts from side to side.", "[src] looks around for something to burn.", "[src] slowly turns in circles.")
			if(prob(50))
				visible_message("<span class='notice'>[pick(idle_messages)]</span>")
			else
				dir = pick(NORTH, EAST, SOUTH, WEST) //Random rotation

/obj/structure/clockwork/ocular_warden/proc/acquire_nearby_target()
	var/list/possible_targets = list()
	for(var/mob/living/L in viewers(sight_range, src)) //Doesn't attack the blind
		if(!is_servant_of_ratvar(L) && !L.stat && L.mind)
			possible_targets += L
	if(!possible_targets.len)
		return 0
	target = pick(possible_targets)
	visible_message("<span class='warning'>[src] swivels to face [target]!</span>")
	target << "<span class='heavy_brass'>\"I SEE YOU!\"</span>\n<span class='userdanger'>[src]'s gaze [ratvar_awakens ? "melts you alive" : "burns you"]!</span>"
	return 1

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
		user.visible_message("<span class='notice'>[user] clicks [S] into place on [src].</span>", "<span class='brass'>You insert [S] into [src]. It whirs and begins to rise.</span>")
		var/mob/living/simple_animal/hostile/anima_fragment/A = new(get_turf(src))
		S.brainmob.mind.transfer_to(A)
		add_servant_of_ratvar(A, TRUE)
		A << A.playstyle_string
		user.drop_item()
		qdel(S)
		qdel(src)
		return 1
	else
		return ..()

/obj/structure/clockwork/interdiction_lens //Interdiction lens: A powerful artifact that can massively disrupt electronics. Five-minute cooldown between uses.
	name = "interdiction lens"
	desc = "An ominous, double-pronged brass obelisk. There's a strange gemstone clasped between the pincers."
	clockwork_desc = "A powerful obelisk that can devastate certain electronics. It needs to recharge between uses."
	icon_state = "interdiction_lens"
	construction_value = 25
	break_message = "<span class='warning'>The lens flares a blinding violet before shattering!</span>"
	break_sound = 'sound/effects/Glassbr3.ogg'
	var/recharging = FALSE //If the lens is still recharging its energy

/obj/structure/clockwork/interdiction_lens/examine(mob/user)
	..()
	user << "Its gemstone [recharging ? "has been breached by writhing tendrils of blackness that cover the obelisk" : "vibrates in place and thrums with power"],"

/obj/structure/clockwork/interdiction_lens/attack_hand(mob/living/user)
	if(user.canUseTopic(src))
		disrupt(user)

/obj/structure/clockwork/interdiction_lens/proc/disrupt(mob/living/user)
	if(!user || !is_servant_of_ratvar(user))
		return 0
	if(recharging)
		user << "<span class='warning'>As you place your hand on the gemstone, cold tendrils of black matter crawl up your arm. You quickly pull back.</span>"
		return 0
	user.visible_message("<span class='warning'>[user] places their hand on [src]' gemstone...</span>", "<span class='brass'>You place your hand on the gemstone...</span>")
	var/target = input(user, "Power flows through you. Choose where to direct it.", "Interdiction Lens") as null|anything in list("Disrupt Telecommunications", "Disable Cameras", "Disable Cyborgs")
	if(!user.canUseTopic(src) || !target)
		user.visible_message("<span class='warning'>[user] pulls their hand back.</span>", "<span class='brass'>On second thought, maybe not right now.</span>")
		return 0
	user.visible_message("<span class='warning'>Violet tendrils engulf [user]'s arm as the gemstone glows with furious energy!</span>", \
	"<span class='heavy_brass'>A mass of violet tendrils cover your arm as [src] unleashes a blast of power!</span>")
	user.notransform = TRUE
	icon_state = "[initial(icon_state)]_active"
	recharging = TRUE
	sleep(30)
	switch(target)
		if("Disrupt Telecommunications")
			for(var/obj/machinery/telecomms/hub/H in telecomms_list)
				for(var/mob/M in range(7, H))
					M << "<span class='warning'>You sense a strange force pass through you...</span>"
				H.visible_message("<span class='warning'>The lights on [H] flare a blinding yellow before falling dark!</span>")
				H.emp_act(1)
		if("Disable Cameras")
			for(var/obj/machinery/camera/C in cameranet.cameras)
				C.emp_act(1)
			for(var/mob/living/silicon/ai/A in living_mob_list)
				A << "<span class='userdanger'>Massive energy surge detected. All cameras offline.</span>"
				A << 'sound/machines/warning-buzzer.ogg'
		if("Disable Cyborgs")
			for(var/mob/living/silicon/robot/R in living_mob_list) //Doesn't include AIs, for obvious reasons
				if(is_servant_of_ratvar(R) || R.stat) //Doesn't affect already-offline cyborgs
					continue
				R.visible_message("<span class='warning'>[R] shuts down with no warning!</span>", \
				"<span class='userdanger'>Massive emergy surge detected. All systems offline. Initiating reboot sequence..</span>")
				playsound(R, 'sound/machines/warning-buzzer.ogg', 50, 1)
				R.Weaken(30)
	user.visible_message("<span class='warning'>The tendrils around [user]'s arm turn to an onyx black and wither away!</span>", \
	"<span class='heavy_brass'>The tendrils around your arm turn a horrible black and sting your skin before they shrivel away.</span>")
	user.notransform = FALSE
	if(!src)
		return 0
	flick("[initial(icon_state)]_discharged", src)
	icon_state = "[initial(icon_state)]_recharging"
	spawn(3000) //5 minutes
		if(!src)
			return 0
		visible_message("<span class='warning'>The writhing tendrils return to the gemstone, which begins to glow with power.</span>")
		flick("[initial(icon_state)]_recharged", src)
		icon_state = initial(icon_state)
		recharging = FALSE
	return 1

/obj/structure/clockwork/mending_motor //Mending motor: A prism that consumes replicant alloy to repair nearby mechanical servants at a quick rate.
	name = "mending motor"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that rapidly repairs nearby mechanical servants and clockwork structures."
	icon_state = "mending_motor"
	construction_value = 20
	break_message = "<span class='warning'>The prism collapses with a heavy thud!</span>"
	var/stored_alloy = 0
	var/max_alloy = 150
	var/uses_alloy = TRUE
	var/active = TRUE

/obj/structure/clockwork/mending_motor/prefilled
	stored_alloy = 30

/obj/structure/clockwork/mending_motor/New()
	..()
	SSobj.processing += src
	toggle() //Toggles off as soon as it's created, but starts online for reasons

/obj/structure/clockwork/mending_motor/Destroy()
	SSobj.processing -= src
	..()

/obj/structure/clockwork/mending_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "It has [stored_alloy]/[max_alloy] units of replicant alloy."

/obj/structure/clockwork/mending_motor/process()
	if(!active)
		return 0
	if(!stored_alloy && uses_alloy)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return 0
	for(var/atom/movable/M in range(5, src))
		if(istype(M, /mob/living/simple_animal/hostile/anima_fragment))
			var/mob/living/simple_animal/hostile/anima_fragment/F = M
			if(F.health == F.maxHealth || F.stat)
				continue
			F.adjustBruteLoss(-15)
			if(uses_alloy)
				stored_alloy = max(0, stored_alloy - 2)
		else if(istype(M, /mob/living/simple_animal/hostile/clockwork_marauder))
			var/mob/living/simple_animal/hostile/clockwork_marauder/E = M
			if(E.health == E.maxHealth || E.stat || !E.fatigue)
				continue
			E.adjustBruteLoss(-E.maxHealth) //Instant because marauders don't usually take health damage
			E.fatigue = max(0, E.fatigue - 15)
			if(uses_alloy)
				stored_alloy = max(0, stored_alloy - 2)
		else if(istype(M, /mob/living/silicon))
			var/mob/living/silicon/S = M
			if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
				continue
			S.adjustBruteLoss(-25)
			S.adjustFireLoss(-25)
			if(uses_alloy)
				stored_alloy = max(0, stored_alloy - 5) //Much higher cost because silicons are much more useful
		else if(istype(M, /obj/structure/clockwork))
			var/obj/structure/clockwork/C = M
			if(C.health == C.max_health)
				continue
			C.health = min(C.health + 10, C.max_health)
			if(uses_alloy)
				stored_alloy = max(0, stored_alloy - 1)
	return 1

/obj/structure/clockwork/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src)) //Unnecessary?
		if(!stored_alloy)
			user << "<span class='warning'>[src] needs more replicant alloy to function!</span>"
			return 0
		toggle(user)

/obj/structure/clockwork/mending_motor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user))
		if(stored_alloy + 10 > max_alloy)
			user << "<span class='warning'>[src] is too full to accept any more alloy!</span>"
			return 0
		user.whisper("Genafzhgr vagb jngre.")
		user.visible_message("<span class='notice'>[user] liquifies [I] and pours it onto [src].</span>", \
		"<span class='notice'>You liquify [src] and pour it onto [src], which transfers the alloy into its reserves.</span>")
		stored_alloy = min(max(0, stored_alloy + 10), max_alloy)
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()

/obj/structure/clockwork/mending_motor/proc/toggle(mob/living/user)
	active = !active
	if(user && is_servant_of_ratvar(user))
		user.visible_message("<span class='notice'>[user] [active ? "en" : "dis"]ables [src].</span>", "<span class='brass'>You [active ? "en" : "dis"]able [src].</span>")
	if(active)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_inactive"

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

/obj/effect/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/effect/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/effect/clockwork/examine(mob/user)
	if(is_servant_of_ratvar(user) && clockwork_desc)
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
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/clockwork/judicial_marker/New()
	..()
	flick("judicial_marker", src)
	spawn(25) //Utilizes spawns due to how it works with Ratvar's flame
		flick("judicial_explosion", src)
		spawn(15)
			for(var/mob/living/L in range(1, src))
				if(is_servant_of_ratvar(L))
					continue
				if(!iscultist(L))
					L << "<span class='userdanger'>[!issilicon(L) ? "An unseen force slams you into the ground!" : "ERROR: Motor servos disabled by external source!"]</span>"
					L.Weaken(8)
				else
					L << "<span class='heavy_brass'>\"Keep an eye out, filth.\"</span>\n<span class='userdanger'>[!issilicon(L) ? "An unseen force piledrives you into the ground!" : "ERROR: Motor servos damaged by external source!"]</span>"
					L.Weaken(10)
					L.adjustBruteLoss(10)
			qdel(src)
			return 1

/obj/effect/clockwork/spatial_gateway //Spatial gateway: A one-way rift to another location.
	name = "spatial gateway"
	desc = "A gently thrumming tear in reality."
	clockwork_desc = "A gateway in reality. It can either send or receive, but not both."
	icon_state = "spatial_gateway"
	density = 1
	var/sender = TRUE //If this gateway is made for sending, not receiving
	var/lifetime = 25 //How many deciseconds this portal will last
	var/uses = 1 //How many objects or mobs can go through the portal
	var/obj/effect/clockwork/spatial_gateway/linked_gateway //The gateway linked to this one

/obj/effect/clockwork/spatial_gateway/New()
	..()
	spawn(1)
		if(!linked_gateway)
			qdel(src)
			return 0
		else
			if(linked_gateway.sender == sender)
				linked_gateway.sender = !sender
		spawn(lifetime)
			if(src)
				qdel(src)

/obj/effect/clockwork/spatial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "This gateway can only [sender ? "send" : "receive"] objects."

/obj/effect/clockwork/spatial_gateway/attack_hand(mob/living/user)
	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.buckled_mobs.len)
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
	linked_gateway.uses = max(0, uses - 1)
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
	spawn(10)
		qdel(src)

/obj/effect/clockwork/general_marker/nezbere
	name = "Nezbere, the Brass Eidolon"
	desc = "A towering colossus clad in nigh-impenetrable brass armor. Its gaze is stern yet benevolent, even upon you."
	clockwork_desc = "One of Ratvar's four generals. Nezbere is responsible for the design, testing, and creation of everything in Ratvar's domain."
	icon = 'icons/effects/340x428.dmi'
	icon_state = "nezbere"
	pixel_x = -154
	pixel_y = -192

/obj/effect/clockwork/general_marker/sevtug
	name = "Sevtug, the Formless Pariah"
	desc = "A sinister cloud of purple energy. Looking at it gives you a headache."
	clockwork_desc = "One of Ratvar's four generals. Sevtug taught him how to manipulate minds and is one of his oldest allies."
	icon = 'icons/effects/211x247.dmi'
	icon_state = "sevtug"
	pixel_x = -113
	pixel_y = -131

/obj/effect/clockwork/general_marker/nzcrentr
	name = "Nzcrentr, the Forgotten Arbiter"
	desc = "A terrifying war machine crackling with limitless energy."
	clockwork_desc = "One of Ratvar's four generals. Nzcrentr is the result of Neovgre - Nezbere's finest war machine, commandeerable only be a mortal - fusing with its pilot and driving her \
	insane. Nzcrentr seeks out any and all sentient life to slaughter it for sport."
	icon = 'icons/effects/254x361.dmi'
	icon_state = "nzcrentr"
	pixel_x = -110
	pixel_y = -163

/obj/effect/clockwork/general_marker/inathneq
	name = "Inath-Neq, the Resonant Cogwheel"
	desc = "A humanoid form blazing with blue fire. It radiates an aura of kindness and caring."
	clockwork_desc = "One of Ratvar's four generals. Before her current form, Inath-Neq was a powerful warrior priestess commanding the Resonant Cogs, a sect of Ratvarian warriors renowned for \
	their prowess. After a lost battle with Nar-Sian cultists, Inath-Neq was struck down and stated in her dying breath, \
	\"The Resonant Cogs shall not fall silent this day, but will come together to form a wheel that shall never stop turning.\" Ratvar, touched by this, granted Inath-Neq an eternal body and \
	merged her soul with those of the Cogs slain with her on the battlefield."
	icon = 'icons/effects/187x381.dmi'
	icon_state = "inath-neq"
	pixel_x = -91
	pixel_y = -199

/obj/effect/clockwork/sigil //Sigils: Rune-like markings on the ground with various effects.
	name = "sigil"
	desc = "A strange set of markings drawn on the ground."
	clockwork_desc = "A sigil of some purpose."
	icon_state = "sigil"
	alpha = 25
	var/affects_servants = FALSE

/obj/effect/clockwork/sigil/attack_hand(mob/user)
	if(iscarbon(user) && !user.stat && user.a_intent == "harm")
		user.visible_message("<span class='warning'>[user] stamps out [src]!</span>", "<span class='danger'>You stomp on [src], scattering it into thousands of particles.</span>")
		qdel(src)
		return 1
	..()

/obj/effect/clockwork/sigil/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!L.stat)
			if(!is_servant_of_ratvar(L) || (is_servant_of_ratvar(L) && affects_servants))
				sigil_effects(L)
			return 1
	..()

/obj/effect/clockwork/sigil/proc/sigil_effects(mob/living/L)

/obj/effect/clockwork/sigil/transgression //Sigil of Transgression: Stuns and flashes the first non-servant to walk on it. Nar-Sian cultists are damaged and knocked down.
	name = "dull sigil"
	desc = "A dull, barely-visible golden sigil. It's as though light was carved into the ground."
	icon = 'icons/effects/clockwork_effects.dmi'
	clockwork_desc = "A sigil that will stun the first non-servant to cross it. Nar-Sie's dogs will be knocked down."
	color = rgb(255, 255, 0)

/obj/effect/clockwork/sigil/transgression/sigil_effects(mob/living/L)
	visible_message("<span class='warning'>[src] appears in a burst of light!</span>")
	for(var/mob/living/M in viewers(5, src))
		if(!is_servant_of_ratvar(M))
			M.flash_eyes()
	if(!iscultist(L))
		L << "<span class='userdanger'>An unseen force holds you in place!</span>"
	else
		L << "<span class='heavy_brass'>\"Watch your step, wretch.\"</span>"
		L.adjustBruteLoss(10)
		L.Weaken(5)
	L.Stun(5)
	qdel(src)
	return 1

/obj/effect/clockwork/sigil/submission //Sigil of Submission: After a short time, converts any non-servant standing on it. Knocks down and silences them for five seconds afterwards.
	name = "ominous sigil"
	desc = "A brilliant golden sigil. Something about it really bothers you."
	clockwork_desc = "A sigil that will enslave the first person to cross it, provided they do not move and they stand still for a brief time."
	color = rgb(255, 255, 0)
	alpha = 75

/obj/effect/clockwork/sigil/submission/sigil_effects(mob/living/L)
	visible_message("<span class='warning'>[src] begins to glow a piercing magenta!</span>")
	animate(src, color = rgb(255, 0, 150), time = 30)
	sleep(30)
	if(get_turf(L) != get_turf(src))
		animate(src, color = initial(color), time = 30)
		return 0
	L << "<span class='heavy_brass'>\"You belong to me now.\"</span>"
	add_servant_of_ratvar(L)
	L.Weaken(5) //Completely defenseless for a few seconds - mainly to give them time to read over the information they've just been presented with
	L.Stun(5)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.silent += 5
	for(var/mob/living/M in living_mob_list - L)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='heavy_brass'>Sigil of Submission in [get_area(src)] [is_servant_of_ratvar(L) ? "" : "un"]successfully converted [L.real_name]!</span>"
	qdel(src)
	return 1

/obj/effect/clockwork/sigil/transmission
	name = "suspicious sigil"
	desc = "A barely-visible sigil. Things seem a bit quieter around it."
	clockwork_desc = "A sigil that will listen for and transmit anything it hears."
	color = rgb(75, 75, 75)
	alpha = 50
	flags = HEAR
	languages = ALL

/obj/effect/clockwork/sigil/transmission/sigil_effects(mob/living/L)
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='heavy_brass'>Sigil of Transmission in [get_area(src)] crossed by [L.name].</span>"
	return 0

/obj/effect/clockwork/sigil/transmission/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(!message || !speaker)
		return 0
	var/parsed_message = "<span class='heavy_brass'>(Sigil of Tranmission in [get_area(src)]): </span><span class='brass'>[message]</span>"
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << parsed_message
