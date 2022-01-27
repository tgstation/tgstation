/obj/item/reagent_containers/spray/waterflower/lube
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist. A <i>slippery</i> twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	inhand_icon_state = "sunflower"
	amount_per_transfer_from_this = 3
	spray_range = 1
	stream_range = 1
	volume = 30
	list_reagents = list(/datum/reagent/lube = 30)

//COMBAT CLOWN SHOES
//Clown shoes with combat stats and noslip. Of course they still squeak.
/obj/item/clothing/shoes/clown_shoes/combat
	name = "combat clown shoes"
	desc = "advanced clown shoes that protect the wearer and render them nearly immune to slipping on their own peels. They also squeak at 100% capacity."
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 10, FIRE = 70, ACID = 50)
	strip_delay = 70
	resistance_flags = NONE
	permeability_coefficient = 0.05
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/// Recharging rate in PPS (peels per second)
#define BANANA_SHOES_RECHARGE_RATE 17
#define BANANA_SHOES_MAX_CHARGE 3000

//The super annoying version
/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	name = "mk-honk combat shoes"
	desc = "The culmination of years of clown combat research, these shoes leave a trail of chaos in their wake. They will slowly recharge themselves over time, or can be manually charged with bananium."
	slowdown = SHOES_SLOWDOWN
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 10, FIRE = 70, ACID = 50)
	strip_delay = 70
	resistance_flags = NONE
	permeability_coefficient = 0.05
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	always_noslip = TRUE

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/Initialize(mapload)
	. = ..()
	var/datum/component/material_container/bananium = GetComponent(/datum/component/material_container)
	bananium.insert_amount_mat(BANANA_SHOES_MAX_CHARGE, /datum/material/bananium)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/process(delta_time)
	var/datum/component/material_container/bananium = GetComponent(/datum/component/material_container)
	var/bananium_amount = bananium.get_material_amount(/datum/material/bananium)
	if(bananium_amount < BANANA_SHOES_MAX_CHARGE)
		bananium.insert_amount_mat(min(BANANA_SHOES_RECHARGE_RATE * delta_time, BANANA_SHOES_MAX_CHARGE - bananium_amount), /datum/material/bananium)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat/attack_self(mob/user)
	ui_action_click(user)

#undef BANANA_SHOES_RECHARGE_RATE
#undef BANANA_SHOES_MAX_CHARGE

//BANANIUM SWORD

/obj/item/melee/energy/sword/bananium
	name = "bananium sword"
	icon_state = "e_sword"
	attack_verb_continuous = list("hits", "taps", "pokes")
	attack_verb_simple = list("hit", "tap", "poke")
	force = 0
	throwforce = 0
	hitsound = null
	embedding = null
	light_color = COLOR_YELLOW
	sword_color_icon = "bananium"
	active_heat = 0
	/// Cooldown for making a trombone noise for failing to make a bananium desword
	COOLDOWN_DECLARE(next_trombone_allowed)

/obj/item/melee/energy/sword/bananium/make_transformable()
	AddComponent(/datum/component/transforming, \
		throw_speed_on = 4, \
		attack_verb_continuous_on = list("slips"), \
		attack_verb_simple_on = list("slip"), \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, .proc/on_transform)

/obj/item/melee/energy/sword/bananium/on_transform(obj/item/source, mob/user, active)
	. = ..()
	adjust_slipperiness()

/*
 * Adds or removes a slippery component, depending on whether the sword is active or not.
 */
/obj/item/melee/energy/sword/bananium/proc/adjust_slipperiness()
	if(blade_active)
		AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
	else
		qdel(GetComponent(/datum/component/slippery))

/obj/item/melee/energy/sword/bananium/attack(mob/living/M, mob/living/user)
	. = ..()
	if(blade_active)
		var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
		slipper.Slip(src, M)

/obj/item/melee/energy/sword/bananium/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(blade_active)
		var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
		slipper.Slip(src, hit_atom)

/obj/item/melee/energy/sword/bananium/attackby(obj/item/weapon, mob/living/user, params)
	if(COOLDOWN_FINISHED(src, next_trombone_allowed) && istype(weapon, /obj/item/melee/energy/sword/bananium))
		COOLDOWN_START(src, next_trombone_allowed, 5 SECONDS)
		to_chat(user, span_warning("You slap the two swords together. Sadly, they do not seem to fit!"))
		playsound(src, 'sound/misc/sadtrombone.ogg', 50)
		return TRUE
	return ..()

/obj/item/melee/energy/sword/bananium/suicide_act(mob/user)
	if(!blade_active)
		attack_self(user)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku, but the blade slips off of [user.p_them()] harmlessly!"))
	var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
	slipper.Slip(src, user)
	return SHAME

//BANANIUM SHIELD

/obj/item/shield/energy/bananium
	name = "bananium energy shield"
	desc = "A shield that stops most melee attacks, protects user from almost all energy projectiles, and can be thrown to slip opponents."
	icon_state = "bananaeshield"
	throw_speed = 1
	force = 0
	throwforce = 0
	throw_range = 5

	active_force = 0
	active_throwforce = 0
	active_throw_speed = 1
	can_clumsy_use = TRUE

/obj/item/shield/energy/bananium/on_transform(obj/item/source, mob/user, active)
	. = ..()
	adjust_comedy()

/*
 * Adds or removes a slippery and boomerang component, depending on whether the shield is active or not.
 */
/obj/item/shield/energy/bananium/proc/adjust_comedy()
	if(enabled)
		AddComponent(/datum/component/slippery, 60, GALOSHES_DONT_HELP)
		AddComponent(/datum/component/boomerang, throw_range+2, TRUE)
	else
		qdel(GetComponent(/datum/component/slippery))
		qdel(GetComponent(/datum/component/boomerang))

/obj/item/shield/energy/bananium/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(enabled)
		var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
		if(iscarbon(hit_atom) && !caught)//if they are a carbon and they didn't catch it
			var/datum/component/slippery/slipper = GetComponent(/datum/component/slippery)
			slipper.Slip(src, hit_atom)
	else
		return ..()


//BOMBANANA

/obj/item/seeds/banana/bombanana
	name = "pack of bombanana seeds"
	desc = "They're seeds that grow into bombanana trees. When grown, give to the clown."
	plantname = "Bombanana Tree"
	product = /obj/item/food/grown/banana/bombanana

/obj/item/food/grown/banana/bombanana
	trash_type = /obj/item/grown/bananapeel/bombanana
	seed = /obj/item/seeds/banana/bombanana
	tastes = list("explosives" = 10)
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/grown/bananapeel/bombanana
	desc = "A peel from a banana. Why is it beeping?"
	seed = /obj/item/seeds/banana/bombanana
	var/det_time = 50
	var/obj/item/grenade/syndieminibomb/bomb

/obj/item/grown/bananapeel/bombanana/Initialize(mapload)
	. = ..()
	bomb = new /obj/item/grenade/syndieminibomb(src)
	bomb.det_time = det_time
	if(iscarbon(loc))
		to_chat(loc, span_danger("[src] begins to beep."))
	bomb.arm_grenade(loc, null, FALSE)

/obj/item/grown/bananapeel/bombanana/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, det_time)

/obj/item/grown/bananapeel/bombanana/Destroy()
	. = ..()
	QDEL_NULL(bomb)

/obj/item/grown/bananapeel/bombanana/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is deliberately slipping on the [src.name]! It looks like \he's trying to commit suicide."))
	playsound(loc, 'sound/misc/slip.ogg', 50, TRUE, -1)
	bomb.arm_grenade(user, 0, FALSE)
	return (BRUTELOSS)

//TEARSTACHE GRENADE

/obj/item/grenade/chem_grenade/teargas/moustache
	name = "tear-stache grenade"
	desc = "A handsomely-attired teargas grenade."
	icon_state = "moustacheg"
	clumsy_check = GRENADE_NONCLUMSY_FUMBLE

/obj/item/grenade/chem_grenade/teargas/moustache/detonate(mob/living/lanced_by)
	var/myloc = get_turf(src)
	. = ..()
	for(var/mob/living/carbon/M in view(6, myloc))
		if(!istype(M.wear_mask, /obj/item/clothing/mask/gas/clown_hat) && !istype(M.wear_mask, /obj/item/clothing/mask/gas/mime) )
			if(!M.wear_mask || M.dropItemToGround(M.wear_mask))
				var/obj/item/clothing/mask/fakemoustache/sticky/the_stash = new /obj/item/clothing/mask/fakemoustache/sticky()
				M.equip_to_slot_or_del(the_stash, ITEM_SLOT_MASK, TRUE, TRUE, TRUE, TRUE)

/obj/item/clothing/mask/fakemoustache/sticky
	var/unstick_time = 600

/obj/item/clothing/mask/fakemoustache/sticky/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, STICKY_MOUSTACHE_TRAIT)
	addtimer(CALLBACK(src, .proc/unstick), unstick_time)

/obj/item/clothing/mask/fakemoustache/sticky/proc/unstick()
	REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_MOUSTACHE_TRAIT)
