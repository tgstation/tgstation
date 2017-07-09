/////////////
// SCRIPTS //
/////////////

//Ocular Warden: Creates an ocular warden, which defends a small area near it.
/datum/clockwork_scripture/create_object/ocular_warden
	descname = "Structure, Turret"
	name = "Ocular Warden"
	desc = "Forms an automatic short-range turret which will automatically attack nearby unrestrained non-Servants that can see it."
	invocations = list("Guardians...", "...of the Engine...", "...defend us!")
	channel_time = 120
	consumed_components = list(BELLIGERENT_EYE = 2, REPLICANT_ALLOY = 1)
	object_path = /obj/structure/destructible/clockwork/ocular_warden
	creator_message = "<span class='brass'>You form an ocular warden, which will automatically attack nearby unrestrained non-Servants that can see it.</span>"
	observer_message = "<span class='warning'>A brass eye takes shape and slowly rises into the air, its red iris glaring!</span>"
	usage_tip = "Although powerful, the warden is very fragile and should optimally be placed behind barricades."
	tier = SCRIPTURE_SCRIPT
	one_per_tile = TRUE
	space_allowed = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 1
	quickbind = TRUE
	quickbind_desc = "Creates an Ocular Warden, which will automatically attack nearby unrestrained non-Servants that can see it."

/datum/clockwork_scripture/create_object/ocular_warden/check_special_requirements()
	for(var/obj/structure/destructible/clockwork/ocular_warden/W in range(OCULAR_WARDEN_EXCLUSION_RANGE, invoker))
		to_chat(invoker, "<span class='neovgre'>You sense another ocular warden too near this location. Placing another this close would cause them to fight.</span>" )
		return FALSE
	return ..()


//Cogscarab: Creates an empty cogscarab shell, which produces a cogscarab dedicated to maintaining and defending the cult.
/datum/clockwork_scripture/create_object/cogscarab
	descname = "Constructor Soul Vessel Shell"
	name = "Cogscarab"
	desc = "Creates a small shell fitted for soul vessels. Adding an active soul vessel to it results in a small construct with tools and an inbuilt fabricator."
	invocations = list("Call forth...", "...the workers of Armorer.")
	channel_time = 60
	consumed_components = list(BELLIGERENT_EYE = 2, HIEROPHANT_ANSIBLE = 1)
	object_path = /obj/structure/destructible/clockwork/shell/cogscarab
	creator_message = "<span class='brass'>You form a cogscarab, a constructor soul vessel receptacle.</span>"
	observer_message = "<span class='warning'>The slab disgorges a puddle of black metal that contracts and forms into a strange shell!</span>"
	usage_tip = "Useless without a soul vessel and should not be created without one."
	tier = SCRIPTURE_SCRIPT
	primary_component = BELLIGERENT_EYE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Cogscarab Shell, which produces a Cogscarab when filled with a Soul Vessel."


//Vitality Matrix: Creates a sigil which will drain health from nonservants and can use that health to heal or even revive servants.
/datum/clockwork_scripture/create_object/vitality_matrix
	descname = "Trap, Damage to Healing"
	name = "Vitality Matrix"
	desc = "Places a sigil that drains life from any living non-Servants that cross it. Servants that cross it, however, will be healed based on how much Vitality all \
	Matrices have drained from non-Servants. Dead Servants can be revived by this sigil if there is vitality equal to the target Servant's non-oxygen damage."
	invocations = list("Divinity...", "...steal their life...", "...for these shells!")
	channel_time = 60
	consumed_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 2)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/vitality
	creator_message = "<span class='brass'>A vitality matrix appears below you. It will drain life from non-Servants and heal Servants that cross it.</span>"
	usage_tip = "The sigil will be consumed upon reviving a Servant."
	tier = SCRIPTURE_SCRIPT
	one_per_tile = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 3
	quickbind = TRUE
	quickbind_desc = "Creates a Vitality Matrix, which drains non-Servants on it to heal Servants that cross it."


//Mending Mantra: Channeled for up to ten times over twenty seconds to repair structures and heal allies
/datum/clockwork_scripture/channeled/mending_mantra
	descname = "Channeled, Area Healing and Repair"
	name = "Mending Mantra"
	desc = "Repairs nearby structures and constructs. Servants wearing clockwork armor will also be healed. Channeled every two seconds for a maximum of twenty seconds."
	chant_invocations = list("Mend our dents!", "Heal our scratches!", "Repair our gears!")
	chant_amount = 10
	chant_interval = 20
	consumed_components = list(VANGUARD_COGWHEEL = 2, REPLICANT_ALLOY = 1)
	usage_tip = "This is a very effective way to rapidly reinforce a base after an attack."
	tier = SCRIPTURE_SCRIPT
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Repairs nearby structures and constructs. Servants wearing clockwork armor will also be healed.<br><b>Maximum 10 chants.</b>"
	var/heal_attempts = 4
	var/heal_amount = 2.5
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)
	var/static/list/heal_finish_messages = list("There, all mended!", "Try not to get too damaged.", "No more dents and scratches for you!", "Champions never die.", "All patched up.", \
	"Ah, child, it's okay now.", "Pain is temporary.", "What you do for the Justiciar is eternal.", "Bear this for me.", "Be strong, child.", "Please, be careful!", \
	"If you die, you will be remembered.")
	var/static/list/heal_target_typecache = typecacheof(list(
	/obj/structure/destructible/clockwork,
	/obj/machinery/door/airlock/clockwork,
	/obj/machinery/door/window/clockwork,
	/obj/structure/window/reinforced/clockwork,
	/obj/structure/table/reinforced/brass))
	var/static/list/ratvarian_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/armor/clockwork,
	/obj/item/clothing/head/helmet/clockwork,
	/obj/item/clothing/gloves/clockwork,
	/obj/item/clothing/shoes/clockwork))

/datum/clockwork_scripture/channeled/mending_mantra/chant_effects(chant_number)
	var/turf/T
	for(var/atom/movable/M in range(7, invoker))
		if(isliving(M))
			if(isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
				var/mob/living/simple_animal/S = M
				if(S.health == S.maxHealth || S.stat == DEAD)
					continue
				T = get_turf(M)
				for(var/i in 1 to heal_attempts)
					if(S.health < S.maxHealth)
						S.adjustHealth(-heal_amount)
						new /obj/effect/temp_visual/heal(T, "#1E8CE1")
						if(i == heal_attempts && S.health >= S.maxHealth) //we finished healing on the last tick, give them the message
							to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
							break
					else
						to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
						break
			else if(issilicon(M))
				var/mob/living/silicon/S = M
				if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
					continue
				T = get_turf(M)
				for(var/i in 1 to heal_attempts)
					if(S.health < S.maxHealth)
						S.heal_ordered_damage(heal_amount, damage_heal_order)
						new /obj/effect/temp_visual/heal(T, "#1E8CE1")
						if(i == heal_attempts && S.health >= S.maxHealth)
							to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
							break
					else
						to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
						break
			else if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.health == H.maxHealth || H.stat == DEAD || !is_servant_of_ratvar(H))
					continue
				T = get_turf(M)
				var/heal_ticks = 0 //one heal tick for each piece of ratvarian armor worn
				var/obj/item/I = H.get_item_by_slot(slot_wear_suit)
				if(is_type_in_typecache(I, ratvarian_armor_typecache))
					heal_ticks++
				I = H.get_item_by_slot(slot_head)
				if(is_type_in_typecache(I, ratvarian_armor_typecache))
					heal_ticks++
				I = H.get_item_by_slot(slot_gloves)
				if(is_type_in_typecache(I, ratvarian_armor_typecache))
					heal_ticks++
				I = H.get_item_by_slot(slot_shoes)
				if(is_type_in_typecache(I, ratvarian_armor_typecache))
					heal_ticks++
				if(heal_ticks)
					for(var/i in 1 to heal_ticks)
						if(H.health < H.maxHealth)
							H.heal_ordered_damage(heal_amount, damage_heal_order)
							new /obj/effect/temp_visual/heal(T, "#1E8CE1")
							if(i == heal_ticks && H.health >= H.maxHealth)
								to_chat(H, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
								break
						else
							to_chat(H, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
							break
		else if(is_type_in_typecache(M, heal_target_typecache))
			var/obj/structure/destructible/clockwork/C = M
			if(C.obj_integrity == C.max_integrity || (istype(C) && !C.can_be_repaired))
				continue
			T = get_turf(M)
			for(var/i in 1 to heal_attempts)
				if(C.obj_integrity < C.max_integrity)
					C.obj_integrity = min(C.obj_integrity + 5, C.max_integrity)
					C.update_icon()
					new /obj/effect/temp_visual/heal(T, "#1E8CE1")
				else
					break
	new /obj/effect/temp_visual/ratvar/mending_mantra(get_turf(invoker))
	return TRUE


//Sigil of Submission: Creates a sigil of submission, which converts one heretic above it after a delay.
/datum/clockwork_scripture/create_object/sigil_of_submission
	descname = "Trap, Conversion"
	name = "Sigil of Submission"
	desc = "Places a luminous sigil that will enslave any valid beings standing on it after a time."
	invocations = list("Divinity, enlighten...", "...those who trespass here!")
	channel_time = 60
	consumed_components = list(BELLIGERENT_EYE = 1, GEIS_CAPACITOR = 2)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A luminous sigil appears below you. The next non-servant to cross it will be enslaved after a brief time if they do not move.</span>"
	usage_tip = "This is not a primary conversion method - use Geis for that. It is advantageous as a trap, however, as it will transmit the name of the newly-converted."
	tier = SCRIPTURE_SCRIPT
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Submission, which will convert one non-Servant that remains on it."


//Soul Vessel: Creates a soul vessel, which can seek a ghost or be used on the uncovered head of a dead or dying human to take their brain.
/datum/clockwork_scripture/create_object/soul_vessel
	descname = "Clockwork Posibrain"
	name = "Soul Vessel"
	desc = "Forms an ancient positronic brain with an overriding directive to serve Ratvar."
	invocations = list("Herd the souls of...", "...the blasphemous damned!")
	channel_time = 30
	consumed_components = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 2)
	whispered = TRUE
	object_path = /obj/item/device/mmi/posibrain/soul_vessel
	creator_message = "<span class='brass'>You form a soul vessel, which can be used in-hand to attract spirits, or used on an unconscious or dead human to extract their consciousness.</span>"
	usage_tip = "The vessel can be used as a teleport target for Spatial Gateway, though it is generally better-used by placing it in a shell or cyborg body."
	tier = SCRIPTURE_SCRIPT
	space_allowed = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 6
	quickbind = TRUE
	quickbind_desc = "Creates a Soul Vessel, which can be placed in construct shells and cyborg bodies once filled."


//Replica Fabricator: Creates a replica fabricator, used to convert objects and repair clockwork structures.
/datum/clockwork_scripture/create_object/replica_fabricator
	descname = "Replaces Objects with Ratvarian Versions"
	name = "Replica Fabricator"
	desc = "Forms a device that, when used on certain objects, replaces them with their Ratvarian equivalents. It requires power to function."
	invocations = list("With this device...", "...his presence shall be made known.")
	channel_time = 20
	consumed_components = list(GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 2)
	whispered = TRUE
	object_path = /obj/item/clockwork/replica_fabricator/preloaded
	creator_message = "<span class='brass'>You form a replica fabricator.</span>"
	usage_tip = "Clockwork Walls cause nearby Tinkerer's Caches to generate components passively, making this a vital tool. Clockwork Floors heal toxin damage in Servants standing on them."
	tier = SCRIPTURE_SCRIPT
	space_allowed = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a Replica Fabricator, which can convert various objects to Ratvarian variants."


//Function Call: Grants the invoker the ability to call forth a Ratvarian spear that deals significant damage to silicons.
/datum/clockwork_scripture/function_call
	descname = "Permanent Summonable Spear"
	name = "Function Call"
	desc = "Grants the invoker the ability to call forth a powerful Ratvarian spear every three minutes. The spear will deal significant damage to Nar-Sie's dogs and silicon lifeforms, but will \
	vanish three minutes after being summoned."
	invocations = list("Grant me...", "...the might of brass!")
	channel_time = 20
	consumed_components = list(REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 1)
	whispered = TRUE
	usage_tip = "You can impale human targets with the spear by pulling them, then attacking. Throwing the spear at a mob will do massive damage and stun them, but break the spear."
	tier = SCRIPTURE_SCRIPT
	primary_component = REPLICANT_ALLOY
	sort_priority = 8

/datum/clockwork_scripture/function_call/check_special_requirements()
	for(var/datum/action/innate/function_call/F in invoker.actions)
		to_chat(invoker, "<span class='warning'>You have already bound a Ratvarian spear to yourself!</span>")
		return FALSE
	return invoker.can_hold_items()

/datum/clockwork_scripture/function_call/scripture_effects()
	invoker.visible_message("<span class='warning'>A shimmer of yellow light infuses [invoker]!</span>", \
	"<span class='brass'>You bind a Ratvarian spear to yourself. Use the \"Function Call\" action button to call it forth.</span>")
	var/datum/action/innate/function_call/F = new()
	F.Grant(invoker)
	return TRUE

//Function Call action: Calls forth a Ratvarian spear once every 3 minutes.
/datum/action/innate/function_call
	name = "Function Call"
	desc = "Allows you to summon a Ratvarian spear to fight enemies."
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/cooldown = 0
	var/base_cooldown = RATVARIAN_SPEAR_DURATION

/datum/action/innate/function_call/IsAvailable()
	if(!is_servant_of_ratvar(owner) || cooldown > world.time)
		return FALSE
	return ..()

/datum/action/innate/function_call/Activate()
	if(!owner.get_empty_held_indexes())
		to_chat(usr, "<span class='warning'>You need an empty hand to call forth your spear!</span>")
		return FALSE
	owner.visible_message("<span class='warning'>A strange spear materializes in [owner]'s hands!</span>", "<span class='brass'>You call forth your spear!</span>")
	var/obj/item/clockwork/ratvarian_spear/R = new(get_turf(usr))
	owner.put_in_hands(R)
	if(!GLOB.ratvar_awakens)
		to_chat(owner, "<span class='warning'>Your spear begins to break down in this plane of existence. You can't use it for long!</span>")
	cooldown = base_cooldown + world.time
	owner.update_action_buttons_icon()
	addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), base_cooldown)
	return TRUE


//Spatial Gateway: Allows the invoker to teleport themselves and any nearby allies to a conscious servant or clockwork obelisk.
/datum/clockwork_scripture/spatial_gateway
	descname = "Teleport Gate"
	name = "Spatial Gateway"
	desc = "Tears open a miniaturized gateway in spacetime to any conscious servant that can transport objects or creatures to its destination. \
	Each servant assisting in the invocation adds one additional use and four additional seconds to the gateway's uses and duration."
	invocations = list("Spatial Gateway...", "...activate!")
	channel_time = 80
	consumed_components = list(VANGUARD_COGWHEEL = 1, HIEROPHANT_ANSIBLE = 2)
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	usage_tip = "This gateway is strictly one-way and will only allow things through the invoker's portal."
	tier = SCRIPTURE_SCRIPT
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 9
	quickbind = TRUE
	quickbind_desc = "Allows you to create a one-way Spatial Gateway to a living Servant or Clockwork Obelisk."

/datum/clockwork_scripture/spatial_gateway/check_special_requirements()
	if(!isturf(invoker.loc))
		to_chat(invoker, "<span class='warning'>You must not be inside an object to use this scripture!</span>")
		return FALSE
	var/other_servants = 0
	for(var/mob/living/L in GLOB.living_mob_list)
		if(is_servant_of_ratvar(L) && !L.stat && L != invoker)
			other_servants++
	for(var/obj/structure/destructible/clockwork/powered/clockwork_obelisk/O in GLOB.all_clockwork_objects)
		if(O.anchored)
			other_servants++
	if(!other_servants)
		to_chat(invoker, "<span class='warning'>There are no other conscious servants or anchored clockwork obelisks!</span>")
		return FALSE
	return TRUE

/datum/clockwork_scripture/spatial_gateway/scripture_effects()
	var/portal_uses = 0
	var/duration = 0
	for(var/mob/living/L in range(1, invoker))
		if(!L.stat && is_servant_of_ratvar(L))
			portal_uses++
			duration += 40 //4 seconds
	if(GLOB.ratvar_awakens)
		portal_uses = max(portal_uses, 100) //Very powerful if Ratvar has been summoned
		duration = max(duration, 100)
	return slab.procure_gateway(invoker, duration, portal_uses)


//Volt Void: Channeled for up to five times over ten seconds to fire up to five rays of energy at target locations.
/datum/clockwork_scripture/channeled/volt_void
	descname = "Channeled, Targeted Energy Blasts"
	name = "Volt Void" //Alternative name: "On all levels but physical, I am a power sink"
	desc = "Allows you to fire energy rays at target locations; more power consumed causes more damage. Channeled every fifth of a second for a maximum of ten seconds."
	channel_time = 30
	invocations = list("Amperage...", "...grant me your power!")
	chant_invocations = list("Use charge to kill!", "Slay with power!", "Hunt with energy!")
	chant_amount = 4
	chant_interval = 5
	consumed_components = list(GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 2)
	usage_tip = "Though it requires you to stand still, this scripture can do massive damage."
	tier = SCRIPTURE_SCRIPT
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Allows you to fire energy rays at target locations. Failing to fire causes backlash.<br><b>Maximum 4 chants.</b>"
	var/static/list/nzcrentr_insults = list("You're not very good at aiming.", "You hunt badly.", "What a waste of energy.", "Almost funny to watch.",
	"Boss says </span><span class='heavy_brass'>\"Click something, you idiot!\"</span><span class='nzcrentr'>.", "Stop wasting components if you can't aim.")

/datum/clockwork_scripture/channeled/volt_void/chant_effects(chant_number)
	slab.busy = null
	var/datum/clockwork_scripture/ranged_ability/volt_ray/ray = new
	ray.slab = slab
	ray.invoker = invoker
	var/turf/T = get_turf(invoker)
	if(!ray.run_scripture() && slab && invoker)
		if(can_recite() && T == get_turf(invoker))
			if(!GLOB.ratvar_awakens)
				var/obj/structure/destructible/clockwork/powered/volt_checker/VC = new/obj/structure/destructible/clockwork/powered/volt_checker(get_turf(invoker))
				var/multiplier = 0.5
				var/usable_power = min(Floor(VC.total_accessable_power() * 0.2, MIN_CLOCKCULT_POWER), 1000)
				if(VC.try_use_power(usable_power))
					multiplier += (usable_power * 0.0005) //at maximum power, should be 1 multiplier
				qdel(VC)
				if(iscyborg(invoker))
					var/mob/living/silicon/robot/C = invoker
					if(C.cell)
						var/prev_power = usable_power //we don't want to increase the multiplier past 1
						usable_power = min(Floor(C.cell.charge * 0.2, MIN_CLOCKCULT_POWER), 1000) - prev_power
						if(usable_power > 0 && C.cell.use(usable_power))
							multiplier += (usable_power * 0.0005)
				var/obj/effect/temp_visual/ratvar/volt_hit/VH = new /obj/effect/temp_visual/ratvar/volt_hit(get_turf(invoker), null, multiplier)
				invoker.visible_message("<span class='warning'>[invoker] is struck by [invoker.p_their()] own [VH.name]!</span>", "<span class='userdanger'>You're struck by your own [VH.name]!</span>")
				invoker.adjustFireLoss(VH.damage) //you have to fail all five blasts to die to this
				playsound(invoker, 'sound/machines/defib_zap.ogg', VH.damage, 1, -1)
			to_chat(invoker, "<span class='nzcrentr'>\"[text2ratvar(pick(nzcrentr_insults))]\"</span>")
		else
			return FALSE
	return TRUE

/obj/effect/ebeam/volt_ray
	name = "volt_ray"
	layer = LYING_MOB_LAYER

/datum/clockwork_scripture/ranged_ability/volt_ray
	name = "Volt Ray"
	slab_icon = "volt"
	allow_mobility = FALSE
	ranged_type = /obj/effect/proc_holder/slab/volt
	ranged_message = "<span class='nzcrentr_small'><i>You charge the clockwork slab with shocking might.</i>\n\
	<b>Left-click a target to fire, quickly!</b></span>"
	timeout_time = 20

/obj/structure/destructible/clockwork/powered/volt_checker
	invisibility = INVISIBILITY_ABSTRACT
