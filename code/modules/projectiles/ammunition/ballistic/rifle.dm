// .310 Strilka (Sakhno Rifle)

/obj/item/ammo_casing/strilka310
	name = ".310 Strilka bullet casing"
	desc = "A .310 Strilka bullet casing. Casing is a bit of a fib; there is no case, it's just a block of red powder."
	icon_state = "310-casing"
	caliber = CALIBER_STRILKA310
	projectile_type = /obj/projectile/bullet/strilka310

/obj/item/ammo_casing/strilka310/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/strilka310/surplus
	name = ".310 Strilka surplus bullet casing"
	desc = parent_type::desc + " Damp red powder at that."
	projectile_type = /obj/projectile/bullet/strilka310/surplus

/obj/item/ammo_casing/strilka310/enchanted
	projectile_type = /obj/projectile/bullet/strilka310/enchanted

/obj/item/ammo_casing/strilka310/phasic
	name = ".310 Strilka phasic bullet casing"
	desc = "A phasic .310 Strilka bullet casing."
	projectile_type = /obj/projectile/bullet/strilka310/phasic
// .223 (M-90gl Carbine)

/obj/item/ammo_casing/a223
	name = ".223 bullet casing"
	desc = "A .223 bullet casing."
	icon_state = "223-casing"
	caliber = CALIBER_A223
	projectile_type = /obj/projectile/bullet/a223

/obj/item/ammo_casing/a223/phasic
	name = ".223 phasic bullet casing"
	desc = "A .223 phasic bullet casing."
	projectile_type = /obj/projectile/bullet/a223/phasic

/obj/item/ammo_casing/a223/weak
	projectile_type = /obj/projectile/bullet/a223/weak

// 40mm (Grenade Launcher)

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
	newtonian_force = 1.25

/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber shell"
	desc = "A cased rubber slug. The big brother of the beanbag slug, this thing will knock someone out in one. Doesn't do so great against anyone in armor."
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

/obj/item/ammo_casing/rebar
	name = "Sharpened Iron Rod"
	desc = "A Sharpened Iron rod. It's Pointy!"
	caliber = CALIBER_REBAR
	icon_state = "rod_sharp"
	base_icon_state = "rod_sharp"
	projectile_type = /obj/projectile/bullet/rebar
	newtonian_force = 1.5

/obj/item/ammo_casing/rebar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless, TRUE)

/obj/item/ammo_casing/rebar/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"

/obj/item/ammo_casing/rebar/syndie
	name = "Jagged Iron Rod"
	desc = "An Iron rod, with notches cut into it. You really don't want this stuck in you."
	caliber = CALIBER_REBAR
	icon_state = "rod_jagged"
	base_icon_state = "rod_jagged"
	projectile_type = /obj/projectile/bullet/rebar/syndie

/obj/item/ammo_casing/rebar/zaukerite
	name = "zaukerite sliver"
	desc = "A sliver of a zaukerite crystal. Due to its irregular, jagged edges, removal of an embedded zaukerite sliver should only be done by trained surgeons."
	caliber = CALIBER_REBAR
	icon_state = "rod_zaukerite"
	base_icon_state = "rod_zaukerite"
	projectile_type = /obj/projectile/bullet/rebar/zaukerite

/obj/item/ammo_casing/rebar/hydrogen
	name = "metallic hydrogen bolt"
	desc = "An ultra-sharp rod made from pure metallic hydrogen. Armor may as well not exist."
	caliber = CALIBER_REBAR
	icon_state = "rod_hydrogen"
	base_icon_state = "rod_hydrogen"
	projectile_type = /obj/projectile/bullet/rebar/hydrogen

/obj/item/ammo_casing/rebar/healium
	name = "healium crystal bolt"
	desc = "Who needs a syringe gun, anyway?"
	caliber = CALIBER_REBAR
	icon_state = "rod_healium"
	base_icon_state =  "rod_healium"
	projectile_type = /obj/projectile/bullet/rebar/healium
	/// How many seconds of healing/sleeping action we have left, once all are spent the bolt dissolves
	var/heals_left = 6 SECONDS

/obj/item/ammo_casing/rebar/healium/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if (loaded_projectile)
		var/obj/projectile/bullet/rebar/healium/bolt = loaded_projectile
		bolt.heals_left = heals_left
	return ..()

/datum/embedding/rebar_healium
	embed_chance = 100
	fall_chance = 0
	pain_stam_pct = 0.9
	ignore_throwspeed_threshold = TRUE
	rip_time = 1.5 SECONDS
	/// Amount of each type of damage healed per second
	var/healing_per_second = 5
	/// Amount of drowsiness added per second
	var/drowsy_per_second = 2 SECONDS
	/// At what point of drowsiness do we knock out the owner
	var/drowsy_knockout = 5 SECONDS // Actually more like 8 seconds, because you need 4 ticks to reach this
	/// Can this bolt cause sleeping? Used to prevent sleep stacking by shooting multiple bolts
	var/can_sleep = TRUE

/datum/embedding/rebar_healium/on_successful_embed(mob/living/carbon/victim, obj/item/bodypart/target_limb)
	. = ..()
	for(var/obj/item/bodypart/limb as anything in victim.bodyparts)
		for(var/obj/item/ammo_casing/rebar/healium/other_rebar in limb.embedded_objects)
			if (other_rebar == parent)
				continue
			var/datum/embedding/rebar_healium/embed_data = other_rebar.get_embed()
			if (istype(embed_data) && embed_data.can_sleep)
				can_sleep = FALSE
				return

/datum/embedding/rebar_healium/process(seconds_per_tick)
	. = ..()
	var/obj/item/ammo_casing/rebar/healium/casing = parent
	casing.heals_left -= seconds_per_tick * 1 SECONDS
	var/update_health = FALSE
	var/healing = -healing_per_second * seconds_per_tick
	update_health += owner.adjustBruteLoss(healing, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	update_health += owner.adjustFireLoss(healing, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	update_health += owner.adjustToxLoss(healing, updating_health = FALSE, required_biotype = BODYTYPE_ORGANIC)
	update_health += owner.adjustOxyLoss(healing, updating_health = FALSE, required_biotype = BODYTYPE_ORGANIC)
	if (update_health)
		owner.updatehealth()
	if (can_sleep && (owner.mob_biotypes & MOB_ORGANIC))
		owner.adjust_drowsiness(drowsy_per_second * seconds_per_tick)
		var/datum/status_effect/drowsiness/drowsiness = owner.has_status_effect(/datum/status_effect/drowsiness)
		if (drowsiness?.duration - world.time >= drowsy_knockout)
			owner.Sleeping(3 SECONDS)
	if (casing.heals_left <= 0)
		fall_out()

/datum/embedding/rebar_healium/remove_embedding(mob/living/to_hands)
	. = ..()
	var/obj/item/ammo_casing/rebar/healium/casing = parent
	casing.heals_left = initial(casing.heals_left)
	can_sleep = TRUE

/obj/item/ammo_casing/rebar/supermatter
	name = "supermatter bolt"
	desc = "Wait, how is the bow capable of firing this without dusting?"
	caliber = CALIBER_REBAR
	icon_state = "rod_supermatter"
	base_icon_state = "rod_supermatter"
	projectile_type = /obj/projectile/bullet/rebar/supermatter

/obj/item/ammo_casing/rebar/paperball
	name = "paper ball"
	desc = "Doink!"
	caliber = CALIBER_REBAR
	icon_state = "paperball"
	base_icon_state = "paperball"
	projectile_type = /obj/projectile/bullet/paperball
	newtonian_force = 0.5
