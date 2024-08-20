/obj/item/borer_egg/empowered
	name = "empowered borer egg"
	icon_state = "empowered_brainegg"

/obj/effect/mob_spawn/ghost_role/borer_egg/empowered
	name = "empowered borer egg"
	desc = "An egg of a creature that came crawling out of someone instead of into them."
	mob_type = /mob/living/basic/cortical_borer/empowered
	host_egg = /obj/item/borer_egg/empowered

/obj/item/organ/internal/empowered_borer_egg
	name = "strange egg"
	desc = "All slimy and yuck."
	icon_state = "innards" // not like you'll be seeing this anyway
	visual = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG
	/// How long it takes to burst from a corpse
	var/burst_time = 3 MINUTES
	/// What generation the egg will be
	var/generation = 0

/obj/item/organ/internal/empowered_borer_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown egg in [owner]'s [zone]!"))

/obj/item/organ/internal/empowered_borer_egg/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)

/obj/item/organ/internal/empowered_borer_egg/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	..()
	addtimer(CALLBACK(src, PROC_REF(try_burst)), burst_time)

/obj/item/organ/internal/empowered_borer_egg/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	visible_message(span_warning("<span class='italics'>As [src] is cut out of [M], it quickly vibrates and shatters, leaving nothing but some goop!</span>"))
	new /obj/effect/decal/cleanable/food/egg_smudge(drop_location())
	qdel(src)

/obj/item/organ/internal/empowered_borer_egg/proc/try_burst()
	if(QDELETED(owner) || owner.stat != DEAD)
		qdel(src)
		return
	var/list/candidates = SSpolling.poll_ghost_candidates(
		role = ROLE_CORTICAL_BORER,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_CORTICAL_BORER,
		alert_pic = /mob/living/basic/cortical_borer/empowered,
	)
	if(!length(candidates))
		var/obj/effect/mob_spawn/ghost_role/borer_egg/empowered/borer_egg = new(owner.drop_location())
		borer_egg.generation = generation
		var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
		chest.dismember()
		owner.visible_message(span_danger("An egg explodes out of [owner]'s chest, sending gore flying everywhere!"), span_danger("An egg explodes out of your chest, giblets flying everywhere!"))
		return
	var/mob/dead/observer/new_borer = pick(candidates)
	var/mob/living/basic/cortical_borer/empowered/spawned_cb = new(owner.drop_location())
	var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	chest.dismember()
	owner.visible_message(span_danger("[spawned_cb] explodes out of [owner]'s chest, sending gore flying everywhere!"), span_danger("[spawned_cb] explodes out of your chest, giblets flying everywhere!"))
	spawned_cb.generation = generation
	spawned_cb.ckey = new_borer.ckey
	spawned_cb.mind.add_antag_datum(/datum/antagonist/cortical_borer/hivemind)
