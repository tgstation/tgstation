#define CHRONO_BEAM_RANGE 3
#define CHRONO_FRAME_COUNT 22
/obj/item/gun/energy/chrono_gun
	name = "Timeline Amendment Device"
	desc = "The result of outlawed time-bluespace research, this device is capable of wiping a being from the timestream."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/chrono_beam)
	can_charge = 0
	fire_delay = 50
	var/obj/item/clothing/suit/space/chronos/attached_chronosuit = null
	var/obj/structure/chrono_field/field = null
	var/turf/startpos = null
	var/list/chronosuit_typecache = /obj/item/clothing/suit/space/chronos
	var/list/erased_minds

/obj/item/gun/energy/chrono_gun/Initialize()
	if(chronosuit_typecache)
		chronosuit_typecache = typecacheof(chronosuit_typecache)
	return ..()

/obj/item/gun/energy/chrono_gun/update_icon()
	return

/obj/item/gun/energy/chrono_gun/can_shoot()
	var/mob/living/carbon/human/user = loc
	if(istype(user))
		var/obj/item/suit = user.wear_suit
		if(suit && is_type_in_typecache(suit, chronosuit_typecache))
			return ..()

/obj/item/gun/energy/chrono_gun/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='danger'>*beep*</span>")
	playsound(src, 'sound/machines/beep.ogg', 30, TRUE, -2, frequency = 41895)

/obj/item/gun/energy/chrono_gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(field)
		field_disconnect(field)
	..()

/obj/item/gun/energy/chrono_gun/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(..() && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.wear_suit && is_type_in_typecache(H.wear_suit, chronosuit_typecache))
			return TRUE
	return FALSE

/obj/item/gun/energy/chrono_gun/mob_can_unequip(mob/living/M, mob/living/unequipper)
	if(attached_chronosuit && unequipper && (unequipper != M))
		return FALSE
	return ..()

/obj/item/gun/energy/chrono_gun/proc/attach_chronosuit(obj/item/clothing/suit/space/chronos/suit)
	attached_chronosuit = suit
	RegisterSignal(suit, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/chronosuit_moved)
	RegisterSignal(suit, COMSIG_PARENT_EXAMINE, .proc/chronosuit_examined)

/obj/item/gun/energy/chrono_gun/proc/detach_chronosuit()
	UnregisterSignal(attached_chronosuit, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_EXAMINE))
	attached_chronosuit = null

/obj/item/gun/energy/chrono_gun/equipped(mob/user, slot)
	if((slot_flags & slotdefine2slotbit(slot)) && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/suit = H.wear_suit
		if(is_type_in_typecache(suit, chronosuit_typecache))
			attach_chronosuit(suit)
	else if(attached_chronosuit)
		detach_chronosuit()
	return ..()

/obj/item/gun/energy/chrono_gun/examine(mob/user)
	..()
	if(attached_chronosuit)
		to_chat(user, "<span class='notice'>It's attached to the back of [attached_chronosuit].</span>")

/obj/item/gun/energy/chrono_gun/proc/chronosuit_examined(datum/source, mob/user)
	to_chat(user, "<span class='notice'>[src] is attached to the back of it.</span>")

/obj/item/gun/energy/chrono_gun/proc/chronosuit_moved(datum/source, mob/user, slot)
	if(slot && (attached_chronosuit.slot_flags & slotdefine2slotbit(slot)))
		return
	detach_chronosuit()
	var/mob/old_owner = loc
	old_owner.dropItemToGround(src)

/obj/item/gun/energy/chrono_gun/Destroy()
	if(field)
		field_disconnect(field)
	return ..()

/obj/item/gun/energy/chrono_gun/proc/field_connect(obj/structure/chrono_field/F)
	var/mob/living/user = loc
	if(F.gun)
		if(isliving(user) && F.captured)
			to_chat(user, "<span class='alert'><b>FAIL: <i>[F.captured]</i> already has an existing connection.</b></span>")
		field_disconnect(F)
	else
		startpos = get_turf(src)
		field = F
		F.gun = src
		if(isliving(user) && F.captured)
			to_chat(user, "<span class='notice'>Connection established with target: <b>[F.captured]</b></span>")


/obj/item/gun/energy/chrono_gun/proc/field_disconnect(obj/structure/chrono_field/F)
	if(F && field == F)
		var/mob/living/user = loc
		if(F.gun == src)
			F.gun = null
		if(isliving(user) && F.captured)
			to_chat(user, "<span class='alert'>Disconnected from target: <b>[F.captured]</b></span>")
	field = null
	startpos = null

/obj/item/gun/energy/chrono_gun/proc/field_check(obj/structure/chrono_field/F)
	if(F)
		if(field == F)
			var/turf/currentpos = get_turf(src)
			var/mob/living/user = loc
			if((currentpos == startpos) && (field in view(CHRONO_BEAM_RANGE, currentpos)) && (user.mobility_flags & MOBILITY_STAND) && (user.stat == CONSCIOUS))
				return 1
		field_disconnect(F)
		return 0

/obj/item/gun/energy/chrono_gun/proc/store_mind(datum/mind/M)
	if(istype(M))
		LAZYADD(erased_minds, M)


/obj/item/projectile/energy/chrono_beam
	name = "amendment beam"
	icon_state = "chronobolt"
	range = CHRONO_BEAM_RANGE
	nodamage = 1
	var/obj/item/gun/energy/chrono_gun/gun = null

/obj/item/projectile/energy/chrono_beam/Initialize()
	. = ..()
	var/obj/item/ammo_casing/energy/chrono_beam/C = loc
	if(istype(C))
		gun = C.gun

/obj/item/projectile/energy/chrono_beam/on_hit(atom/target)
	if(target && gun && isliving(target))
		var/obj/structure/chrono_field/F = new(target.loc, target, gun)
		gun.field_connect(F)


/obj/item/ammo_casing/energy/chrono_beam
	name = "amendment beam"
	projectile_type = /obj/item/projectile/energy/chrono_beam
	icon_state = "chronobolt"
	e_cost = 0
	var/obj/item/gun/energy/chrono_gun/gun

/obj/item/ammo_casing/energy/chrono_beam/Initialize()
	if(istype(loc))
		gun = loc
	. = ..()





/obj/structure/chrono_field
	name = "amendment field"
	desc = "An aura of time-bluespace energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	interaction_flags_atom = 0
	var/mob/living/captured = null
	var/obj/item/gun/energy/chrono_gun/gun = null
	var/tickstokill = 15
	var/mutable_appearance/mob_underlay
	var/preloaded = 0
	var/RPpos = null

/obj/structure/chrono_field/Initialize(mapload, var/mob/living/target, var/obj/item/gun/energy/chrono_gun/G)
	if(target && isliving(target) && G)
		target.forceMove(src)
		captured = target
		var/icon/mob_snapshot = getFlatIcon(target)
		var/icon/cached_icon = new()

		for(var/i=1, i<=CHRONO_FRAME_COUNT, i++)
			var/icon/removing_frame = icon('icons/obj/chronos.dmi', "erasing", SOUTH, i)
			var/icon/mob_icon = icon(mob_snapshot)
			mob_icon.Blend(removing_frame, ICON_MULTIPLY)
			cached_icon.Insert(mob_icon, "frame[i]")

		mob_underlay = mutable_appearance(cached_icon, "frame1")
		update_icon()

		desc = initial(desc) + "<br><span class='info'>It appears to contain [target.name].</span>"
	START_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chrono_field/Destroy()
	if(gun && gun.field_check(src))
		gun.field_disconnect(src)
	return ..()

/obj/structure/chrono_field/update_icon()
	var/ttk_frame = 1 - (tickstokill / initial(tickstokill))
	ttk_frame = CLAMP(CEILING(ttk_frame * CHRONO_FRAME_COUNT, 1), 1, CHRONO_FRAME_COUNT)
	if(ttk_frame != RPpos)
		RPpos = ttk_frame
		mob_underlay.icon_state = "frame[RPpos]"
		underlays = list() //hack: BYOND refuses to update the underlay to match the icon_state otherwise
		underlays += mob_underlay

/obj/structure/chrono_field/process()
	if(captured)
		if(tickstokill > initial(tickstokill))
			for(var/atom/movable/AM in contents)
				AM.forceMove(drop_location())
			qdel(src)
		else if(tickstokill <= 0)
			to_chat(captured, "<span class='boldnotice'>As the last essence of your being is erased from time, you are taken back to your most enjoyable memory. You feel happy...</span>")
			var/mob/dead/observer/ghost = captured.ghostize(1)
			if(captured.mind)
				if(ghost)
					ghost.mind = null
				if(gun)
					gun.store_mind(captured.mind)
			qdel(captured)
			qdel(src)
		else
			captured.Unconscious(80)
			if(captured.loc != src)
				captured.forceMove(src)
			update_icon()
			if(gun)
				if(gun.field_check(src))
					tickstokill--
				else
					gun = null
					return .()
			else
				tickstokill++
	else
		qdel(src)

/obj/structure/chrono_field/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy/chrono_beam))
		var/obj/item/projectile/energy/chrono_beam/beam = P
		var/obj/item/gun/energy/chrono_gun/Pgun = beam.gun
		if(Pgun && istype(Pgun))
			Pgun.field_connect(src)
	else
		return 0

/obj/structure/chrono_field/assume_air()
	return 0

/obj/structure/chrono_field/return_air() //we always have nominal air and temperature
	var/datum/gas_mixture/GM = new
	GM.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	GM.gases[/datum/gas/oxygen][MOLES] = MOLES_O2STANDARD
	GM.gases[/datum/gas/nitrogen][MOLES] = MOLES_N2STANDARD
	GM.temperature = T20C
	return GM

/obj/structure/chrono_field/Move()
	return

/obj/structure/chrono_field/singularity_act()
	return

/obj/structure/chrono_field/singularity_pull()
	return

/obj/structure/chrono_field/ex_act()
	return

/obj/structure/chrono_field/blob_act(obj/structure/blob/B)
	return


#undef CHRONO_BEAM_RANGE
#undef CHRONO_FRAME_COUNT
