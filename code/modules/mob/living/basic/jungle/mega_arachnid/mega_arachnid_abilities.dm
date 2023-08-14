
/datum/action/cooldown/spell/pointed/projectile/flesh_restraints
	name = "fleshy restraints"
	desc = "Launch at your prey to immobilize them."
	button_icon = 'icons/obj/restraints.dmi'
	button_icon_state = "flesh_snare"

	cooldown_time = 6 SECONDS
	spell_requirements = NONE

	active_msg = "You prepare to throw a restraint at your target!"
	cast_range = 8
	projectile_type = /obj/projectile/mega_arachnid

/obj/projectile/mega_arachnid
	name = "flesh snare"
	icon_state = "tentacle_end"
	damage = 0

/obj/projectile/mega_arachnid/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!iscarbon(target) || blocked >= 100)
		return
	var/obj/item/restraints/legcuffs/beartrap/mega_arachnid/restraint = new /obj/item/restraints/legcuffs/beartrap/mega_arachnid(get_turf(target))
	restraint.spring_trap(null, target)

/obj/item/restraints/legcuffs/beartrap/mega_arachnid
	name = "fleshy restraints"
	desc = "Used by mega arachnids to immobilize their prey."
	flags_1 = NONE
	item_flags = DROPDEL
	icon_state = "flesh_snare"
	armed = TRUE

/obj/item/restraints/legcuffs/beartrap/mega_arachnid/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGA_ARACHNID, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)


/datum/action/cooldown/mob_cooldown/secrete_acid
	name = "Secrete Acid"
	button_icon = 'icons/effects/acid.dmi'
	button_icon_state = "default"
	desc = "Secrete a slippery acid!"
	cooldown_time = 15 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	/// the acid we will secrete
	var/obj/effect/slippery_acid/acid

/datum/action/cooldown/mob_cooldown/secrete_acid/Activate(atom/target_atom)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(release_acid))
	addtimer(CALLBACK(src, PROC_REF(deactivate_ability)), 3 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/secrete_acid/proc/release_acid()
	var/turf/current_turf = get_turf(owner)
	if(locate(acid) in current_turf.contents)
		return
	acid = new(current_turf)

/datum/action/cooldown/mob_cooldown/secrete_acid/proc/deactivate_ability()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/obj/effect/slippery_acid
	name = "slippery acid"
	icon = 'icons/effects/acid.dmi'
	icon_state = "default"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// how long does the acid exist for
	var/duration_time = 5 SECONDS

/obj/effect/slippery_acid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 60)
	QDEL_IN(src, duration_time)
