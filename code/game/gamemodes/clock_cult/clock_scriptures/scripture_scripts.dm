/////////////
// SCRIPTS //
/////////////

//Ocular Warden: Creates an ocular warden, which defends a small area near it.
/datum/clockwork_scripture/create_object/ocular_warden
	descname = "Structure, Turret"
	name = "Ocular Warden"
	desc = "Forms an automatic short-range turret that deals low sustained damage to the unenlightened in its range."
	invocations = list("Guardians...", "...of the Engine...", "...defend us!")
	channel_time = 120
	required_components = list(BELLIGERENT_EYE = 2, REPLICANT_ALLOY = 1)
	consumed_components = list(BELLIGERENT_EYE = 1, REPLICANT_ALLOY = 1)
	object_path = /obj/structure/destructible/clockwork/ocular_warden
	creator_message = "<span class='brass'>You form an ocular warden, which will focus its searing gaze upon nearby unenlightened.</span>"
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
	for(var/obj/structure/destructible/clockwork/ocular_warden/W in range(3, invoker))
		invoker << "<span class='neovgre'>You sense another ocular warden too near this location. Placing another this close would cause them to fight.</span>" //fluff message
		return FALSE
	return ..()


//Cogscarab: Creates an empty cogscarab shell, which produces a cogscarab dedicated to maintaining and defending the cult.
/datum/clockwork_scripture/create_object/cogscarab
	descname = "Constructor Soul Vessel Shell"
	name = "Cogscarab"
	desc = "Creates a small shell fitted for soul vessels. Adding an active soul vessel to it results in a small construct with tools and an inbuilt proselytizer."
	invocations = list("Call forth...", "...the workers of Armorer.")
	channel_time = 60
	required_components = list(BELLIGERENT_EYE = 2, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(BELLIGERENT_EYE = 1, HIEROPHANT_ANSIBLE = 1)
	object_path = /obj/structure/destructible/clockwork/shell/cogscarab
	creator_message = "<span class='brass'>You form a cogscarab, a constructor soul vessel receptacle.</span>"
	observer_message = "<span class='warning'>The slab disgorges a puddle of black metal that contracts and forms into a strange shell!</span>"
	usage_tip = "Useless without a soul vessel and should not be created without one."
	tier = SCRIPTURE_SCRIPT
	primary_component = BELLIGERENT_EYE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Cogscarab Shell, which produces a Cogscarab when filled with a Soul Vessel."


//Fellowship Armory: Arms the invoker and nearby servants with Ratvarian armor.
/datum/clockwork_scripture/fellowship_armory
	descname = "Area Servant Armor"
	name = "Fellowship Armory"
	desc = "Equips the invoker and any nearby servants with Ratvarian armor. This armor provides high melee resistance but a weakness to lasers. \
	It grows faster to invoke with more nearby servants."
	invocations = list("Shield us...", "...with the...", "... fragments of Engine!")
	channel_time = 100
	required_components = list(VANGUARD_COGWHEEL = 2, REPLICANT_ALLOY = 1)
	consumed_components = list(VANGUARD_COGWHEEL = 1, REPLICANT_ALLOY = 1)
	usage_tip = "Before using, advise adjacent allies to remove their helmets, external suits, gloves, and shoes."
	tier = SCRIPTURE_SCRIPT
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Attempts to armor all nearby Servants with powerful Ratvarian armor."

/datum/clockwork_scripture/fellowship_armory/run_scripture()
	for(var/mob/living/L in orange(1, get_turf(invoker)))
		if(is_servant_of_ratvar(L) && L.can_speak_vocal())
			channel_time = max(channel_time - 10, 0)
	return ..()

/datum/clockwork_scripture/fellowship_armory/scripture_effects()
	var/affected = 0
	for(var/mob/living/L in range(1, invoker))
		if(!is_servant_of_ratvar(L))
			continue
		var/do_message = 0
		do_message += L.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/clockwork(null), slot_head)
		do_message += L.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/clockwork(null), slot_wear_suit)
		do_message += L.equip_to_slot_or_del(new/obj/item/clothing/gloves/clockwork(null), slot_gloves)
		do_message += L.equip_to_slot_or_del(new/obj/item/clothing/shoes/clockwork(null), slot_shoes)
		if(do_message)
			L.visible_message("<span class='warning'>Strange armor appears on [L]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body, equipping you with Ratvarian armor.</span>")
			playsound(L, 'sound/magic/clockwork/fellowship_armory.ogg', 15*do_message, 1) //get sound loudness based on how much we equipped
			affected++
	return affected


//Sigil of Submission: Creates a sigil of submission, which converts one heretic above it after a delay.
/datum/clockwork_scripture/create_object/sigil_of_submission
	descname = "Trap, Conversion"
	name = "Sigil of Submission"
	desc = "Places a luminous sigil that will enslave any valid beings standing on it after a time."
	invocations = list("Divinity, enlighten...", "...those who trespass here!")
	channel_time = 60
	required_components = list(BELLIGERENT_EYE = 1, GEIS_CAPACITOR = 2)
	consumed_components = list(BELLIGERENT_EYE = 1, GEIS_CAPACITOR = 1)
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
	required_components = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 2)
	consumed_components = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1)
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


//Clockwork Proselytizer: Creates a clockwork proselytizer, used to convert objects and repair clockwork structures.
/datum/clockwork_scripture/create_object/clockwork_proselytizer
	descname = "Converts Objects to Ratvarian"
	name = "Clockwork Proselytizer"
	desc = "Forms a device that, when used on certain objects, converts them into their Ratvarian equivalents. It requires power to function."
	invocations = list("With this device...", "...his presence shall be made known.")
	channel_time = 20
	required_components = list(GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 2)
	consumed_components = list(GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1)
	whispered = TRUE
	object_path = /obj/item/clockwork/clockwork_proselytizer/preloaded
	creator_message = "<span class='brass'>You form a clockwork proselytizer.</span>"
	usage_tip = "Clockwork Walls cause nearby tinkerer's caches to generate components passively, making them a vital tool. Clockwork Floors heal toxin damage in Servants standing on them."
	tier = SCRIPTURE_SCRIPT
	space_allowed = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a Clockwork Proselytizer, which can convert various objects to Ratvarian variants."


//Function Call: Grants the invoker the ability to call forth a Ratvarian spear that deals significant damage to silicons.
/datum/clockwork_scripture/function_call
	descname = "Permanent Summonable Spear"
	name = "Function Call"
	desc = "Grants the invoker the ability to call forth a powerful Ratvarian spear every three minutes. The spear will deal significant damage to Nar-Sie's dogs and silicon lifeforms, but will \
	vanish three minutes after being summoned."
	invocations = list("Grant me...", "...the might of brass!")
	channel_time = 20
	required_components = list(REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 1)
	consumed_components = list(REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)
	whispered = TRUE
	usage_tip = "You can impale human targets with the spear by pulling them, then attacking. Throwing the spear at a mob will do massive damage and stun them, but break the spear."
	tier = SCRIPTURE_SCRIPT
	primary_component = REPLICANT_ALLOY
	sort_priority = 8

/datum/clockwork_scripture/function_call/check_special_requirements()
	for(var/datum/action/innate/function_call/F in invoker.actions)
		invoker << "<span class='warning'>You have already bound a Ratvarian spear to yourself!</span>"
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
	var/base_cooldown = 1800

/datum/action/innate/function_call/IsAvailable()
	if(!is_servant_of_ratvar(owner) || cooldown > world.time)
		return FALSE
	return ..()

/datum/action/innate/function_call/Activate()
	if(!owner.get_empty_held_indexes())
		usr << "<span class='warning'>You need an empty hand to call forth your spear!</span>"
		return FALSE
	owner.visible_message("<span class='warning'>A strange spear materializes in [owner]'s hands!</span>", "<span class='brass'>You call forth your spear!</span>")
	var/obj/item/clockwork/ratvarian_spear/R = new(get_turf(usr))
	owner.put_in_hands(R)
	if(!ratvar_awakens)
		R.clockwork_desc = "A powerful spear of Ratvarian making. It's more effective against enemy cultists and silicons, though it won't last for long."
		owner << "<span class='warning'>Your spear begins to break down in this plane of existence. You can't use it for long!</span>"
		R.timerid = addtimer(CALLBACK(R, /obj/item/clockwork/ratvarian_spear.proc/break_spear), base_cooldown, TIMER_STOPPABLE)
	cooldown = base_cooldown + world.time
	owner.update_action_buttons_icon()
	addtimer(CALLBACK(src, .proc/update_actions), base_cooldown)
	return TRUE

/datum/action/innate/function_call/proc/update_actions()
	if(owner)
		owner.update_action_buttons_icon()


//Spatial Gateway: Allows the invoker to teleport themselves and any nearby allies to a conscious servant or clockwork obelisk.
/datum/clockwork_scripture/spatial_gateway
	descname = "Teleport Gate"
	name = "Spatial Gateway"
	desc = "Tears open a miniaturized gateway in spacetime to any conscious servant that can transport objects or creatures to its destination. \
	Each servant assisting in the invocation adds one additional use and four additional seconds to the gateway's uses and duration."
	invocations = list("Spatial Gateway...", "...activate!")
	channel_time = 80
	required_components = list(VANGUARD_COGWHEEL = 1, HIEROPHANT_ANSIBLE = 2)
	consumed_components = list(VANGUARD_COGWHEEL = 1, HIEROPHANT_ANSIBLE = 1)
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
		invoker << "<span class='warning'>You must not be inside an object to use this scripture!</span>"
		return FALSE
	var/other_servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L) && !L.stat && L != invoker)
			other_servants++
	for(var/obj/structure/destructible/clockwork/powered/clockwork_obelisk/O in all_clockwork_objects)
		other_servants++
	if(!other_servants)
		invoker << "<span class='warning'>There are no other servants or clockwork obelisks!</span>"
		return FALSE
	return TRUE

/datum/clockwork_scripture/spatial_gateway/scripture_effects()
	var/portal_uses = 0
	var/duration = 0
	for(var/mob/living/L in range(1, invoker))
		if(!L.stat && is_servant_of_ratvar(L))
			portal_uses++
			duration += 40 //4 seconds
	if(ratvar_awakens)
		portal_uses = max(portal_uses, 100) //Very powerful if Ratvar has been summoned
		duration = max(duration, 100)
	return slab.procure_gateway(invoker, duration, portal_uses)


//Volt Void: Channeled for up to thirty times over thirty seconds. Consumes power from most power storages and deals slight burn damage to the invoker.
/datum/clockwork_scripture/channeled/volt_void
	descname = "Channeled, Area Power Drain"
	name = "Volt Void" //Alternative name: "On all levels but physical, I am a power sink"
	desc = "Drains energy from nearby power sources, dealing burn damage if the total power consumed is above a threshhold. Channeled every second for a maximum of thirty seconds."
	chant_invocations = list("Draw charge to this shell!")
	chant_amount = 30
	chant_interval = 10
	required_components = list(GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 2)
	consumed_components = list(GEIS_CAPACITOR = 1, HIEROPHANT_ANSIBLE = 1)
	usage_tip = "If standing on a Sigil of Transmission, will transfer power to it. Augumented limbs will also be healed unless above a very high threshhold."
	tier = SCRIPTURE_SCRIPT
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 10
	quickbind = TRUE
	quickbind_desc = "Drains power from nearby objects. If standing on a Sigil of Transmission, gives it that power.<br><b>Maximum 30 chants.</b>"
	var/total_power_drained = 0
	var/power_damage_threshhold = 3000
	var/augument_damage_threshhold = 6000

/datum/clockwork_scripture/channeled/volt_void/chant_effects(chant_number)
	playsound(invoker, 'sound/effects/EMPulse.ogg', 50, 1)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/sigil/voltvoid, get_turf(invoker))
	var/power_drained = 0
	for(var/atom/movable/A in view(7, get_turf(invoker)))
		power_drained += A.power_drain(TRUE)
	var/obj/effect/clockwork/sigil/transmission/ST = locate(/obj/effect/clockwork/sigil/transmission) in get_turf(invoker)
	if(ST && power_drained >= MIN_CLOCKCULT_POWER)
		var/sigil_drain = 0
		while(power_drained >= MIN_CLOCKCULT_POWER)
			ST.modify_charge(-MIN_CLOCKCULT_POWER)
			power_drained -= MIN_CLOCKCULT_POWER
			sigil_drain += MIN_CLOCKCULT_POWER * 0.2
		power_drained += sigil_drain //readd part of the power given to the sigil to the power drained this cycle
		ST.visible_message("<span class='warning'>[ST] flares a brilliant orange!</span>")
	total_power_drained += power_drained
	if(power_drained >= MIN_CLOCKCULT_POWER)
		if(iscyborg(invoker))
			var/mob/living/silicon/robot/R = invoker
			if(R.cell)
				R.cell.give(power_drained)
				R.visible_message("<span class='warning'>[invoker] flares a brilliant orange!</span>", "<span class='brass'>You feel your cell charging.</span>")
		else if(total_power_drained >= power_damage_threshhold)
			var/power_damage = power_drained * 0.01
			invoker.visible_message("<span class='warning'>[invoker] flares a brilliant orange!</span>", "<span class='userdanger'>You feel the heat of electricity running into your body.</span>")
			if(ishuman(invoker))
				var/mob/living/carbon/human/H = invoker
				for(var/X in H.bodyparts)
					var/obj/item/bodypart/BP = X
					if(ratvar_awakens || (BP.status == BODYPART_ROBOTIC && total_power_drained < augument_damage_threshhold)) //if ratvar is alive, it won't damage and will always heal augumented limbs
						if(BP.heal_damage(power_damage, power_damage, 1, 0)) //heals one point of burn and brute for every ~100W drained on augumented limbs
							H.update_damage_overlays()
					else
						if(BP.receive_damage(0, power_damage))
							H.update_damage_overlays()
			else if(isanimal(invoker))
				var/mob/living/simple_animal/A = invoker
				A.adjustHealth(-power_damage) //if a simple animal is using volt void, just heal it
	return TRUE
