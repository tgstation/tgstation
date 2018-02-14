/////////////
// SCRIPTS //
/////////////


//Replica Fabricator: Creates a replica fabricator, used to convert objects and repair chumbiswork structures.
/datum/chumbiswork_scripture/create_object/replica_fabricator
	descname = "Creates Brass and Converts Objects"
	name = "Replica Fabricator"
	desc = "Forms a device that, when used on certain objects, replaces them with their Ratvarian equivalents. It requires power to function."
	invocations = list("With this device...", "...his presence shall be made known.")
	channel_time = 20
	power_cost = 250
	whispered = TRUE
	object_path = /obj/item/chumbiswork/replica_fabricator
	creator_message = "<span class='brass'>You form a replica fabricator.</span>"
	usage_tip = "chumbiswork Walls cause nearby Tinkerer's Caches to generate components passively, making this a vital tool. chumbiswork Floors heal toxin damage in Servants standing on them."
	tier = SCRIPTURE_SCRIPT
	space_allowed = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 1
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Creates a Replica Fabricator, which can convert various objects to Ratvarian variants."


//Ocular Warden: Creates an ocular warden, which defends a small area near it.
/datum/chumbiswork_scripture/create_object/ocular_warden
	descname = "Structure, Turret"
	name = "Ocular Warden"
	desc = "Forms an automatic short-range turret which will automatically attack nearby unrestrained non-Servants that can see it."
	invocations = list("Guardians of Engine...", "...judge those who would harm us!")
	channel_time = 100
	power_cost = 250
	object_path = /obj/structure/destructible/chumbiswork/ocular_warden
	creator_message = "<span class='brass'>You form an ocular warden, which will automatically attack nearby unrestrained non-Servants that can see it.</span>"
	observer_message = "<span class='warning'>A brass eye takes shape and slowly rises into the air, its red iris glaring!</span>"
	usage_tip = "Although powerful, the warden is very fragile and should optimally be placed behind barricades."
	tier = SCRIPTURE_SCRIPT
	one_per_tile = TRUE
	space_allowed = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates an Ocular Warden, which will automatically attack nearby unrestrained non-Servants that can see it."

/datum/chumbiswork_scripture/create_object/ocular_warden/check_special_requirements()
	for(var/obj/structure/destructible/chumbiswork/ocular_warden/W in range(OCULAR_WARDEN_EXCLUSION_RANGE, invoker))
		to_chat(invoker, "<span class='neovgre'>You sense another ocular warden too near this location. Placing another this close would cause them to fight.</span>" )
		return FALSE
	return ..()


//Vitality Matrix: Creates a sigil which will drain health from nonservants and can use that health to heal or even revive servants.
/datum/chumbiswork_scripture/create_object/vitality_matrix
	descname = "Trap, Damage to Healing"
	name = "Vitality Matrix"
	desc = "Places a sigil that drains life from any living non-Servants that cross it, producing Vitality. Servants that cross it, however, will be healed using existing Vitality. \
	Dead Servants can be revived by this sigil at a cost of 150 Vitality."
	invocations = list("Divinity, siphon their essence...", "...for this shell to consume.")
	channel_time = 60
	power_cost = 1000
	whispered = TRUE
	object_path = /obj/effect/chumbiswork/sigil/vitality
	creator_message = "<span class='brass'>A vitality matrix appears below you. It will drain life from non-Servants and heal Servants that cross it.</span>"
	usage_tip = "The sigil will be consumed upon reviving a Servant."
	tier = SCRIPTURE_SCRIPT
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 3
	quickbind = TRUE
	quickbind_desc = "Creates a Vitality Matrix, which drains non-Servants on it to heal Servants that cross it."

/datum/chumbiswork_scripture/create_object/vitality_matrix/check_special_requirements()
	if(locate(object_path) in range(1, invoker))
		to_chat(invoker, "<span class='danger'>Vitality matrices placed next to each other could interfere and cause a feedback loop! Move away from the other ones!</span>")
		return FALSE
	return ..()


//Judicial Visor: Creates a judicial visor, which can smite an area.
/datum/chumbiswork_scripture/create_object/judicial_visor
	descname = "Delayed Area Knockdown Glasses"
	name = "Judicial Visor"
	desc = "Creates a visor that can smite an area, applying Belligerent and briefly stunning. The smote area will explode after 3 seconds."
	invocations = list("Grant me the flames of Engine!")
	channel_time = 10
	power_cost = 400
	whispered = TRUE
	object_path = /obj/item/clothing/glasses/judicial_visor
	creator_message = "<span class='brass'>You form a judicial visor, which is capable of smiting a small area.</span>"
	usage_tip = "The visor has a thirty-second cooldown once used."
	tier = SCRIPTURE_SCRIPT
	space_allowed = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Creates a Judicial Visor, which can smite an area, applying Belligerent and briefly stunning."


//chumbiswork Armaments: Grants the invoker the ability to call forth a Ratvarian spear and chumbiswork armor.
/datum/chumbiswork_scripture/chumbiswork_armaments
	descname = "Summonable Armor and Weapons"
	name = "chumbiswork Armaments"
	desc = "Allows the invoker to summon chumbiswork armor and a Ratvarian spear at will. The spear's attacks will generate Vitality, used for healing."
	invocations = list("Grant me armaments...", "...from the forge of Armorer!")
	channel_time = 20
	power_cost = 250
	whispered = TRUE
	usage_tip = "Throwing the spear at a mob will do massive damage and knock them down, but break the spear. You will need to wait for 30 seconds before resummoning it."
	tier = SCRIPTURE_SCRIPT
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 5
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Permanently binds chumbiswork armor and a Ratvarian spear to you."

/datum/chumbiswork_scripture/chumbiswork_armaments/check_special_requirements()
	for(var/datum/action/innate/chumbiswork_armaments/F in invoker.actions)
		to_chat(invoker, "<span class='warning'>You have already bound a Ratvarian spear to yourself!</span>")
		return FALSE
	return invoker.can_hold_items()

/datum/chumbiswork_scripture/chumbiswork_armaments/scripture_effects()
	invoker.visible_message("<span class='warning'>A shimmer of yellow light infuses [invoker]!</span>", \
	"<span class='brass'>You bind chumbiswork equipment to yourself. Use chumbiswork Armaments and Call Spear to summon them.</span>")
	var/datum/action/innate/call_weapon/ratvarian_spear/S = new()
	S.Grant(invoker)
	var/datum/action/innate/chumbiswork_armaments/A = new()
	A.Grant(invoker)
	return TRUE

//chumbiswork Armaments: Equips a set of chumbiswork armor. Three-minute cooldown.
/datum/action/innate/chumbiswork_armaments
	name = "chumbiswork Armaments"
	desc = "Outfits you in a full set of Ratvarian armor."
	icon_icon = 'icons/mob/actions/actions_chumbiscult.dmi'
	button_icon_state = "chumbiswork_armor"
	background_icon_state = "bg_chumbis"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "chumbiscult"
	var/cooldown = 0
	var/static/list/ratvarian_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/armor/chumbiswork,
	/obj/item/clothing/head/helmet/chumbiswork,
	/obj/item/clothing/gloves/chumbiswork,
	/obj/item/clothing/shoes/chumbiswork)) //don't replace this ever
	var/static/list/better_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/space,
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/shoes/magboots)) //replace this only if ratvar is up

/datum/action/innate/chumbiswork_armaments/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		qdel(src)
		return
	if(cooldown > world.time)
		return
	return ..()

/datum/action/innate/chumbiswork_armaments/Activate()
	var/do_message = 0
	var/obj/item/I = owner.get_item_by_slot(slot_wear_suit)
	if(remove_item_if_better(I, owner))
		do_message += owner.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/chumbiswork(null), slot_wear_suit)
	I = owner.get_item_by_slot(slot_head)
	if(remove_item_if_better(I, owner))
		do_message += owner.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/chumbiswork(null), slot_head)
	I = owner.get_item_by_slot(slot_gloves)
	if(remove_item_if_better(I, owner))
		do_message += owner.equip_to_slot_or_del(new/obj/item/clothing/gloves/chumbiswork(null), slot_gloves)
	I = owner.get_item_by_slot(slot_shoes)
	if(remove_item_if_better(I, owner))
		do_message += owner.equip_to_slot_or_del(new/obj/item/clothing/shoes/chumbiswork(null), slot_shoes)
	if(do_message)
		owner.visible_message("<span class='warning'>Strange armor appears on [owner]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body, equipping you with Ratvarian armor.</span>")
		playsound(owner, 'sound/magic/chumbiswork/fellowship_armory.ogg', 15 * do_message, TRUE) //get sound loudness based on how much we equipped
	cooldown = chumbisWORK_ARMOR_COOLDOWN + world.time
	owner.update_action_buttons_icon()
	addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), chumbisWORK_ARMOR_COOLDOWN)
	return TRUE

/datum/action/innate/chumbiswork_armaments/proc/remove_item_if_better(obj/item/I, mob/user)
	if(!I)
		return TRUE
	if(is_type_in_typecache(I, ratvarian_armor_typecache))
		return FALSE
	if(!GLOB.ratvar_awakens && is_type_in_typecache(I, better_armor_typecache))
		return FALSE
	return user.dropItemToGround(I)

//Call Spear: Calls forth a powerful Ratvarian spear.
/datum/action/innate/call_weapon/ratvarian_spear
	name = "Call Spear"
	desc = "Calls a Ratvarian spear into your hands to fight your enemies."
	weapon_type = /obj/item/chumbiswork/weapon/ratvarian_spear


//Spatial Gateway: Allows the invoker to teleport themselves and any nearby allies to a conscious servant or chumbiswork obelisk.
/datum/chumbiswork_scripture/spatial_gateway
	descname = "Teleport Gate"
	name = "Spatial Gateway"
	desc = "Tears open a miniaturized gateway in spacetime to any conscious servant that can transport objects or creatures to its destination. \
	Each servant assisting in the invocation adds one additional use and four additional seconds to the gateway's uses and duration."
	invocations = list("Spatial Gateway...", "...activate!")
	channel_time = 80
	power_cost = 400
	multiple_invokers_used = TRUE
	multiple_invokers_optional = TRUE
	usage_tip = "This gateway is strictly one-way and will only allow things through the invoker's portal."
	tier = SCRIPTURE_SCRIPT
	primary_component = GEIS_CAPACITOR
	sort_priority = 6
	quickbind = TRUE
	quickbind_desc = "Allows you to create a one-way Spatial Gateway to a living Servant or chumbiswork Obelisk."

/datum/chumbiswork_scripture/spatial_gateway/check_special_requirements()
	if(!isturf(invoker.loc))
		to_chat(invoker, "<span class='warning'>You must not be inside an object to use this scripture!</span>")
		return FALSE
	var/other_servants = 0
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(is_servant_of_ratvar(L) && !L.stat && L != invoker)
			other_servants++
	for(var/obj/structure/destructible/chumbiswork/powered/chumbiswork_obelisk/O in GLOB.all_chumbiswork_objects)
		if(O.anchored)
			other_servants++
	if(!other_servants)
		to_chat(invoker, "<span class='warning'>There are no other conscious servants or anchored chumbiswork obelisks!</span>")
		return FALSE
	return TRUE

/datum/chumbiswork_scripture/spatial_gateway/scripture_effects()
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

