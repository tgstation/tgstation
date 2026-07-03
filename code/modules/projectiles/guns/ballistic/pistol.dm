/obj/item/gun/ballistic/automatic/pistol
	name = "\improper Makarov pistol"
	desc = "A small, easily concealable 9mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0 SECONDS
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = 'sound/items/weapons/gun/pistol/shot.ogg'
	dry_fire_sound = 'sound/items/weapons/gun/pistol/dry_fire.ogg'
	suppressed_sound = 'sound/items/weapons/gun/pistol/shot_suppressed.ogg'
	load_sound = 'sound/items/weapons/gun/pistol/mag_insert.ogg'
	load_empty_sound = 'sound/items/weapons/gun/pistol/mag_insert.ogg'
	eject_sound = 'sound/items/weapons/gun/pistol/mag_release.ogg'
	eject_empty_sound = 'sound/items/weapons/gun/pistol/mag_release.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack_small.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/lock_small.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/drop_small.ogg'
	drop_sound = 'sound/items/handling/gun/ballistics/pistol/pistol_drop1.ogg'
	pickup_sound = 'sound/items/handling/gun/ballistics/pistol/pistol_pickup1.ogg'
	fire_sound_volume = 90
	bolt_wording = "затвора"
	suppressor_x_offset = 10
	suppressor_y_offset = -1
	recoil_backtime_multiplier = 1

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/fire_mag
	spawn_magazine_type = /obj/item/ammo_box/magazine/m9mm/fire

/obj/item/gun/ballistic/automatic/pistol/contraband

/obj/item/gun/ballistic/automatic/pistol/contraband/Initialize(mapload)
	if(prob(10))
		pin = pick(
		list(
			/obj/item/firing_pin/clown,
			/obj/item/firing_pin/clown/ultra,
			/obj/item/firing_pin/clown/ultra/selfdestruct,
		))
	. = ..()
	pin.pin_removable = FALSE


/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/clandestine
	name = "\improper Ansem pistol"
	desc = "The spiritual successor of the Makarov, or maybe someone just dropped their gun in a bucket of paint. The gun is chambered in 10mm."
	icon_state = "pistol_evil"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm
	empty_indicator = TRUE
	suppressor_x_offset = 12

/obj/item/gun/ballistic/automatic/pistol/clandestine/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Manufactured by Scarborough Arms, the Ansem is regarded as one of the best sidearms on the market. Minimal recoil combined with \
		high stopping power makes it a favourite amongst soldiers of fortune across known space.<br> \
		<br>\
		The ease of concealment due to the weapon's sleek profile has given it a well-earned reputation as the 'smuggler's gun of course'. While \
		space pirate bands tend to favour the HDS-1 created by Nanotrasen due to their low maintenance cost, the Ansem has seen plenty of use by \
		mercernaries, hitmen and espionage agents. Dozens of seized Ansem pistols line evidence lockups across the Spinward. Many with extremely \
		long and bloodied histories from years of service amongst underground criminal elements." \
	)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher
	name = "\improper Ansem/SC pistol"
	desc = "A modified variant of the Ansem, spiritual successor to the Makarov, featuring an integral suppressor and push-button trigger on the grip \
	for an underbarrel-mounted disruptor, similar in operation to the standalone SC/FISHER. Chambered in 10mm."
	desc_controls = "Right-click to use the underbarrel disruptor. Two shots maximum between self-charges."
	icon_state = "pistol_evil_fisher"
	suppressed = SUPPRESSED_QUIET
	can_suppress = FALSE
	can_unsuppress = FALSE
	var/obj/item/gun/energy/recharge/fisher/underbarrel

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/energy/recharge/fisher(src)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "The Ansem/SC is a Scarborough Arms overhaul suite for their own Ansem handgun, designed for special operators who operate operationally, \
		especially against people who like using lightbulbs.<br>\
		<br>\
		The slide is chopped down, with the front half of the handgun featuring a monolithic integral suppressor built around the barrel, \
		and a compact kinetic light disruptor mounted underneath the barrel assembly. The integral suppressor is engineered to not affect \
		ballistic performance nor affect the concealability of the handgun, leading to a surprisingly robust firearm.<br>\
		<br>\
		Scarborough Arms has never actually addressed allegations of their involvement with the modification and/or manufacture \
		of the SC/FISHER or similar disruptor weapons. Prospective operators are reminded that kinetic light disruptors do not actually physically harm targets.<br>\
		<br>\
		Caveat emptor." \
	)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/Destroy()
	QDEL_NULL(underbarrel)
	return ..()

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/try_fire_gun(atom/target, mob/living/user, params)
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		underbarrel.try_fire_gun(target, user, params)
		return
	return ..()

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(QDELETED(target))
		return
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = user
	simulated_hit.on_hit(target)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = throwingdatum?.get_thrower()
	simulated_hit.on_hit(hit_atom)

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = 'sound/items/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/m1911/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "The Colt M1911, created by John Moses Browning centuries ago, is the primordial ancestor of modern automatic firearms. \
		Somehow, to this day, there are still officers who refuse to utilize anything that isn't chambered in 'God's Caliber'.<br>\
		<br>\
		Few want to tell any of these people that .45 ACP has struggled to puncture modern ballistic plating for almost five centuries.<br>\
		<br>\
		You are VERY confident that this particular example was lathed this decade. Most M1911's seen in the wild today are recreations of the weapon \
		made with modern alloyed metals and manufactoring techniques, mass produced for the consumer market. This does not stop fraudsters from \
		claiming that their weapon is a 'family heirloom' that has saved them from various conflicts that they insist they participated in." \
	)

/**
 * Weak 1911 for syndicate chimps. It comes in a 4 TC kit.
 * 15 damage every.. second? 7 shots to kill. Not fast.
 */
/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun
	name = "\improper CH1M911"
	desc = "For the monkey mafioso on-the-go. Uses .45 rounds and has the distinct smell of bananas."
	projectile_damage_multiplier = 0.5
	projectile_wound_bonus = -12
	pin = /obj/item/firing_pin/monkey

/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun/add_deep_lore()
	return

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	accepted_magazine_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	fire_sound = 'sound/items/weapons/gun/rifle/shot.ogg'
	rack_sound = 'sound/items/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/items/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/items/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/deagle/contraband

/obj/item/gun/ballistic/automatic/pistol/deagle/contraband/Initialize(mapload)
	if(prob(10))
		pin = pick(
		list(
			/obj/item/firing_pin/clown,
			/obj/item/firing_pin/clown/ultra,
			/obj/item/firing_pin/clown/ultra/selfdestruct,
		))
	. = ..()
	pin.pin_removable = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/regal
	name = "\improper Regal Condor"
	desc = "Unlike the Desert Eagle, this weapon seems to utilize some kind of advanced internal stabilization system to significantly \
		reduce felt recoil and increase overall accuracy, at the cost of using a smaller caliber. \
		This allows it to fire a very quick 2-round burst. Chambered in .45."
	icon_state = "reagle"
	inhand_icon_state = "deagleg"
	burst_size = 2
	burst_delay = 1
	projectile_damage_multiplier = 1.25
	accepted_magazine_type = /obj/item/ammo_box/magazine/r45
	actions_types = list(/datum/action/item_action/toggle_firemode)
	obj_flags = UNIQUE_RENAME // if you did the sidequest, you get the customization
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 30, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 25, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 11.5, /datum/material/telecrystal = SHEET_MATERIAL_AMOUNT * 4)

/obj/item/gun/ballistic/automatic/pistol/deagle/regal/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "One of the Culling Arms of the Tiger Cooperative, a collection of relic weapons said to have come to Martinson in a frenzied vision from \
		God to enact holy retribution upon the enemies of the faith. Almost all examples of these guns are replicas of the original pattern. This one is no \
		different. However, it carries some of the gravitus of the original firearm. And, some say, the holy might that it wielded against the enemies of the cult.<br>\
		<br>\
		The fact that you are looking at this relic weapon means one of two things.<br>\
		<br>\
		A) A Tiger Cooperative evangelist has died during or before they could commit a bloody massacre in the name of God. Or <br>\
		<br>\
		B) You are that evangelist, and will soon be adding another chapter to this gun's dark history." \
	)

/obj/item/gun/ballistic/automatic/pistol/aps
	name = "\improper Stechkin APS machine pistol"
	desc = "An old Soviet machine pistol. It fires quickly, but kicks like a mule. Uses 9mm ammo. Has a threaded barrel for suppressors."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm_aps
	can_suppress = TRUE
	burst_size = 3
	burst_delay = 1
	spread = 10
	actions_types = list(/datum/action/item_action/toggle_firemode)
	suppressor_x_offset = 6

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"
	mag_display = FALSE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/pistol/stickman/equipped(mob/user, slot)
	..()
	to_chat(user, span_notice("As you try to manipulate [src], it slips out of your possession.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
		user.dropItemToGround(src)

#define DOORHICKEY_GUN_MIN_DAMAGE 70
#define DOORHICKEY_GUN_MAX_DAMAGE 140

/obj/item/gun/ballistic/automatic/pistol/doohickey
	name = "\improper Liberator"
	desc = "A poorly made 3D printed \"gun\", only capable of firing a single shot."
	icon_state = "doorhickey"
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = TRUE
	casing_ejector = FALSE
	force = 10
	max_integrity = 100
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/doorhickey
	can_suppress = FALSE
	semi_auto = FALSE
	show_bolt_icon = FALSE
	projectile_damage_multiplier = 0.5
	spread = 10

/obj/item/gun/ballistic/automatic/pistol/doohickey/unload_ammo(mob/living/user, forced = FALSE)
	if (forced)
		return ..()

	balloon_alert(user, "unscrewing the barrel...")
	playsound(user, 'sound/items/tools/screwdriver_operating.ogg', 75, FALSE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	if (!do_after(user, 2 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return
	. = ..()

/obj/item/gun/ballistic/automatic/pistol/doohickey/load_gun(obj/item/ammo, mob/living/user)
	. = ..()
	if (!.)
		return

	balloon_alert(user, "screwing the barrel on...")
	playsound(user, 'sound/items/tools/screwdriver_operating.ogg', 75, FALSE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	if (do_after(user, 2 SECONDS, src))
		return TRUE

	balloon_alert(user, "interrupted!")
	unload_ammo(user, forced = TRUE)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/doohickey/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/dmg_multiplier = 1

	if (get_dist(target, user) <= 1)
		dmg_multiplier *= 2

	if (isliving(target))
		var/mob/living/victim = target
		var/datum/status_effect/grouped/heldup/gunpoint = victim.has_status_effect(/datum/status_effect/grouped/heldup)
		if (gunpoint)
			for (var/datum/weakref/pointer_ref as anything in gunpoint.sources)
				if (pointer_ref.resolve() == user)
					dmg_multiplier *= 1.5 // Caps at 60 damage
					break

	projectile_damage_multiplier *= dmg_multiplier
	. = ..()
	projectile_damage_multiplier /= dmg_multiplier

/obj/item/gun/ballistic/automatic/pistol/doohickey/shoot_live_shot(mob/living/user, pointblank = FALSE, atom/pbtarget = null, message = TRUE)
	. = ..()
	if (!.)
		return

	var/damage_to_take = rand(DOORHICKEY_GUN_MIN_DAMAGE, DOORHICKEY_GUN_MAX_DAMAGE)
	if (atom_integrity > damage_to_take)
		take_damage(damage_to_take)
		return

	playsound(loc, SFX_SHATTER, 75, TRUE)
	if (loc != user)
		take_damage(damage_to_take)
		return

	var/shrapnel_bomb = FALSE
	var/obj/item/bodypart/arm/poor_sod = user.get_active_hand()
	if (prob(damage_to_take - atom_integrity) && poor_sod)
		shrapnel_bomb = TRUE

	user.visible_message(span_danger("[src] explodes into small pieces[shrapnel_bomb ? ", chunk of it embedding in [user]'s [user.parse_zone_with_bodypart(poor_sod.body_zone)]" : ""]!"),
		span_userdanger("[src] explodes into small pieces[shrapnel_bomb ? ", chunk of it embedding in your [poor_sod]!" : ""]!"),
		span_hear("You can hear sound of plastic shattering."))

	if (poor_sod)
		poor_sod.receive_damage((damage_to_take - atom_integrity) * 0.5, wound_bonus = -10, exposed_wound_bonus = 20, sharpness = SHARP_EDGED, damage_source = src)
	else
		user.take_bodypart_damage((damage_to_take - atom_integrity) * 0.5, wound_bonus = -10, exposed_wound_bonus = 20, sharpness = SHARP_EDGED)

	if (shrapnel_bomb)
		var/obj/item/shrapnel/plastic/shrapnel = new(user.loc)
		if (!shrapnel.force_embed(user, poor_sod))
			qdel(shrapnel)
		else if(!HAS_TRAIT(user, TRAIT_ANALGESIA))
			user.emote("scream")

	new /obj/effect/decal/cleanable/plastic(get_turf(src))
	take_damage(damage_to_take)

/obj/item/gun/ballistic/automatic/pistol/doohickey/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "The Liberator pattern, according to digital historians, was first posted to a fringe imageboard on the NTNet. The post included a now dead \
		link to a defuncting hosting service through which board members were encouraged to download and 'admire' the design. The thread's author began their \
		post by describing their extreme vitriolic hatred of so-called 'moon men' amongst the Nanotrasen 'elites'. And that, through 'the sauce', they had \
		been shown a means to 'end the oppression of Luna's Tormentors'. They called it the 'Liberator' as a result.<br>\
		<br>\
		Response to this thread began as skeptism amongst posters regarding the 3D pattern. Many highlighted the dubious functionality, let alone safe operation \
		of a gun created using cheap plastic and minimal machined parts firing a high pressure round through an unrifled barrel. But the thread suddenly began to \
		gain traction immediately following a particular news article published by the Spinward Dove, a respected editorial in the Spinward Sector. The author of this \
		article recounts that, during a particularly brisk day in New Moscow, they observed three off-duty Nanotrasen assistants attempting to use what the author \
		described as a 'bizarre plastic doohickey' to shoot a mouse at point blank. The horrific aftermath, and images of the rattled but otherwise unscathed mouse, lead many \
		to try and find from where these now crippled assistants had come across such an absurd device. Word spread of the post, and its author's continuously nonsensical \
		rants regarding their hated foe in other areas of the imageboard.<br>\
		<br>\
		The author of the thread returned immediately following the news, claiming that those who frequented the imageboard had 'stolen' their 'dreams of freedom', and \
		that clearly the moon men were attempting to discredit their invention through this publicity stunt. A slur-laiden rant from the thread author followed this declaration, \
		leading to the the moderators of the imageboard to step in and close the thread for good." \
	)

/obj/item/disk/design_disk/liberator
	name = "illegal 3D printer design disk"

/obj/item/disk/design_disk/liberator/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/liberator_gun

#undef DOORHICKEY_GUN_MIN_DAMAGE
#undef DOORHICKEY_GUN_MAX_DAMAGE
