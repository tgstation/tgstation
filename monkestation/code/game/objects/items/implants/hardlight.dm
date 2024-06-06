/obj/item/implant/hard_spear
	name = "hardlight spear implant"
	actions_types = null
	implant_color = "b"
	allow_multiple = TRUE
	var/timerid
	var/deltime = 3 SECONDS
	/// The typepath of the spell we give to people. (yes this is copy pasted from spell implants, yes this has different functionality)
	var/datum/action/cooldown/spell/spell_type = /datum/action/cooldown/spell/conjure_item/hardlight_spear
	/// The actual spell we give to the person on implant
	var/datum/action/cooldown/spell/spell_to_give
	/// Does this implant contain a spell
	var/spell_inside = FALSE
	/// What is the level of the spell inside
	var/spell_inside_level = 1

/obj/item/implant/hard_spear/Initialize(mapload)
	. = ..()
	if(!spell_type)
		return

	spell_to_give = new spell_type(src)

/obj/item/implant/hard_spear/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if (!.)
		return

	if (!spell_to_give)
		return FALSE

	var/datum/action/cooldown/spell/existing = locate(spell_to_give) in user.actions
	if(existing)
		if(!existing.level_spell())
			to_chat(target, span_boldnotice("The implant is unable to upgrade your hardlight spear further"))
			return FALSE
		timerid = QDEL_IN_STOPPABLE(src, deltime)
		return TRUE
	spell_inside = TRUE
	spell_to_give.Grant(target)
	return TRUE

/obj/item/implant/hard_spear/removed(mob/living/source, silent, special)
	. = ..()
	if (!.)
		return FALSE

	if(spell_inside)
		if(spell_to_give)
			spell_inside_level = spell_to_give.spell_level
			spell_to_give.Remove(source)
			if(source.stat != DEAD && !silent)
				to_chat(source, span_boldnotice(""))

	if(timerid)
		deltimer(timerid)
		timerid = null


/obj/item/implant/hard_spear/Destroy()
	QDEL_NULL(spell_to_give)
	return ..()

/obj/item/implant/hard_spear/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Aetherofusion Hardlight Weapons Platform<BR>
				<b>Life:</b> 67 years in a dead host.<BR>
				<b>Important Notes:</b> The insertion of additional copies of this implant will upgrade the orignal one. Efficacy not shown after 5 upgrades.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Preforms and maintains a series of classified modifications to the body.<BR>
				<b>Special Features:</b> Allows the implantee to control a single hardlight spear, further implants will allow for up to 4 additional spears.<BR>
				<b>System Resonance:</b> Internal resonance level suggests a [spell_to_give] is contained within.<BR>
				<b>Integrity:</b> Implant acquires waste material in the blood for self-repair, giving it an unlimited lifespan in a living host."}
	return dat

/obj/item/implanter/hard_spear
	name = "implanter (hardlight spear)"
	imp_type = /obj/item/implant/hard_spear

/obj/item/implantcase/hard_spear
	name = "implant case - 'Hardlight Spear'"
	desc = "A glass case containing a hardlight spear implant."
	imp_type = /obj/item/implant/hard_spear


/obj/item/implant/hard_spear/max
	name = "hardlight spear implant"
	spell_type = /datum/action/cooldown/spell/conjure_item/hardlight_spear/max
	allow_multiple = FALSE

/obj/item/implant/hard_spear/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Aetherofusion Experimental Resonance System<BR>
				<b>Life:</b>  8 millennia in a dead host.<BR>
				<b>Important Notes:</b> The insertion of additional copies of this implant will do nothing, you cannot improve on perfection.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> CLASSIFIED.<BR>
				<b>Special Features:</b> Allows the implantee to control seven hardlight spears.<BR>
				<b>System Resonance:</b> Internal resonance level is above readable levels.<BR>
				<b>Integrity:</b> Implant acquires waste material in the blood for self-repair, giving it an unlimited lifespan in a living host."}
	return dat

/obj/item/implanter/hard_spear/max
	name = "implanter (hardlight spear)"
	imp_type = /obj/item/implant/hard_spear/max

/obj/item/implantcase/hard_spear/max
	name = "implant case - 'Hardlight Spear'"
	desc = "A glass case containing a hardlight spear implant."
	imp_type = /obj/item/implant/hard_spear/max

/datum/action/cooldown/spell/conjure_item/hardlight_spear
	name = "Hardlight Spear"
	desc = "Summon a spear of light to strike down your foes."
	button_icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	button_icon_state = "lightspear"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	sound = 'sound/weapons/saberon.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 20 SECONDS
	invocation_type = INVOCATION_NONE

	spell_requirements = NONE
	antimagic_flags = NONE
	spell_max_level = 5 //max is actually 7(the point where the sprites stop working), but the implant can only reach 5

	delete_old = FALSE
	item_type = /obj/item/gun/magic/hardlight_spear

/datum/action/cooldown/spell/conjure_item/hardlight_spear/before_cast(mob/living/cast_on)
	. = ..()
	for(var/I in cast_on.get_contents())
		if(istype(I, /obj/item/gun/magic/hardlight_spear))
			return . | SPELL_CANCEL_CAST


/datum/action/cooldown/spell/conjure_item/hardlight_spear/make_item()
	. = ..()
	var/obj/item/gun/magic/hardlight_spear/made_spear = .
	made_spear.spears_left = spell_level-1

/datum/action/cooldown/spell/conjure_item/hardlight_spear/get_spell_title()
	switch(spell_level)
		if(2)
			return "Upgraded "
		if(3)
			return "Recursive "
		if(4)
			return "Resonant "
		if(5)
			return "Ascended "
		if(6)
			return "Overwhelming "
		if(7)
			return "Commmanding "

	return ""

/datum/action/cooldown/spell/conjure_item/hardlight_spear/max
	name = "Commmanding Hardlight Spear"
	cooldown_time = 10 SECONDS
	spell_level = 7

/datum/action/cooldown/spell/conjure_item/hardlight_spear/max/get_spell_title()
	return "" //commanding commanding

/obj/item/gun/magic/hardlight_spear //listen man
	name = "hardlight spear"
	desc = "A spear made out of hardened light."
	fire_sound = 'sound/weapons/fwoosh.ogg'
	pinless = TRUE
	force = 25
	wound_bonus = -5
	bare_wound_bonus = 20
	armour_penetration = 18
	block_chance = 0
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_HUGE
	antimagic_flags = NONE
	hitsound = 'sound/weapons/blade1.ogg'
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "lightspear"
	inhand_icon_state = "lightspear"
	worn_icon_state = "none"
	lefthand_file = 'monkestation/icons/mob/inhands/polearms_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/polearms_righthand.dmi'
	slot_flags = null
	can_charge = FALSE //ITS A SPEAR
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NO_MAT_REDEMPTION
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_system = OVERLAY_LIGHT
	light_outer_range = 3
	light_power = 1
	max_charges = 1
	var/spears_left = 5
	ammo_type = /obj/item/ammo_casing/magic/hardlight_spear

/obj/item/gun/magic/hardlight_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 70, \
	)

	block_chance = 5+spears_left*5

/obj/item/gun/magic/hardlight_spear/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands) //HOW ARE YOU DOING THIS
		return
	if(!spears_left)
		return
	var/mutable_appearance/back_spear_overlay
	switch(spears_left)
		if(0)
			return
		if(1)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear1", MOB_SHIELD_LAYER)
		if(2)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear2", MOB_SHIELD_LAYER)
		if(3)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear3", MOB_SHIELD_LAYER)
		if(4)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear4", MOB_SHIELD_LAYER)
		if(5)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear5", MOB_SHIELD_LAYER)
		if(6)
			back_spear_overlay = mutable_appearance('monkestation/icons/effects/hardlightspear.dmi', "spear6", MOB_SHIELD_LAYER)
	back_spear_overlay.pixel_x = -32
	. += back_spear_overlay

/obj/item/gun/magic/hardlight_spear/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(spears_left)
		var/obj/item/gun/magic/hardlight_spear/spear = new type
		spear.spears_left = spears_left - 1
		spear.apply_cooldown()
		qdel(src)
		user.put_in_hands(spear)
	else
		user.dropItemToGround(src, TRUE)

/obj/item/gun/magic/hardlight_spear/proc/apply_cooldown()
	semicd = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_semicd)), 1.5 SECONDS)

/obj/item/ammo_casing/magic/hardlight_spear
	name = "please god report this"
	desc = "Why god why"
	slot_flags = null
	projectile_type = /obj/projectile/bullet/hardlight_spear
	heavy_metal = FALSE

/obj/projectile/bullet/hardlight_spear
	name = "hardlight spear"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "lightspear"
	damage = 40
	armour_penetration = 5
	wound_bonus = -5
	bare_wound_bonus = 50
	wound_falloff_tile = -1
	embed_falloff_tile = -1
	speed = 0.7 //lower = faster
	shrapnel_type = /obj/item/shrapnel/bullet/spear
	light_outer_range = 1
	light_power = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	hitsound_wall = 'sound/weapons/parry.ogg'
	embedding = list(embed_chance=70, fall_chance=6, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=2, jostle_pain_mult=3, rip_time=10)

/obj/item/shrapnel/bullet/spear
	name = "hardlight spear"
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "lightspear"

/obj/item/shrapnel/bullet/spear/unembedded()
	. = ..()
	QDEL_NULL(src) //Deletes itself when unembedded
	return TRUE
