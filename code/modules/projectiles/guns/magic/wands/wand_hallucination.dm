#define WIZARD_WAND_HALLUCINATIONS list(\
	/datum/hallucination/death,\
	/datum/hallucination/death/dust,\
	/datum/hallucination/delusion/preset/carp,\
	/datum/hallucination/delusion/preset/corgi,\
	/datum/hallucination/delusion/preset/cyborg,\
	/datum/hallucination/delusion/preset/ghost,\
	/datum/hallucination/delusion/preset/monkey,\
	/datum/hallucination/delusion/preset/skeleton,\
	/datum/hallucination/delusion/preset/syndies,\
	/datum/hallucination/delusion/preset/zombie,\
	/datum/hallucination/fire,\
	/datum/hallucination/hazard/lava,\
	/datum/hallucination/hazard/chasm,\
	/datum/hallucination/hazard/anomaly,\
	/datum/hallucination/ice,\
	/datum/hallucination/oh_yeah,\
	/datum/hallucination/shock,\
	/datum/hallucination/xeno_attack,\
)

/**
 * Hallucination wand looks exactly like a bolt of chaos except whatever happens isn't real
 * One of the few times people might actually fall for hallucinations of being set on fire or turned into a xenomorph
 * Even if they don't, several of these are minor stuns anyway
 */
/obj/item/gun/magic/wand/hallucination
	name = "wand of chaos"
	desc = "A wand which spits bolts of hallucinogenic magic which can do almost anything, or at least make the victim think so."
	school = SCHOOL_FORBIDDEN
	ammo_type = /obj/item/ammo_casing/magic/hallucination
	icon_state = "chaoswand"
	base_icon_state = "chaoswand"
	fire_sound = 'sound/effects/magic/staff_chaos.ogg'
	max_charges = 20

/obj/item/gun/magic/wand/hallucination/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	var/datum/hallucination/picked_hallucination = pick(WIZARD_WAND_HALLUCINATIONS)
	user.cause_hallucination(picked_hallucination, "wand")
	charges--

/obj/item/gun/magic/wand/hallucination/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	var/mob/living/basic/illusion/mirage/mirage = new(get_turf(src))
	mirage.mock_as(user, 15 SECONDS)
	mirage.AddElement(/datum/element/content_barfer)

	qdel(mirage.ai_controller)
	mirage.ai_controller = new /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles(mirage)

	var/list/our_stuff = user.unequip_everything()
	for (var/atom/movable/thing in our_stuff)
		thing.forceMove(mirage)
	user.ghostize()
	qdel(user)
	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/hallucination
	projectile_type = /obj/projectile/magic/hallucination
	harmful = FALSE

/obj/projectile/magic/hallucination
	// Eagle eyed players may be aware that there's no such thing as a real bolt of chaos projectile
	name = "bolt of chaos"
	icon_state = "ice_1"

/obj/projectile/magic/hallucination/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/carbon/victim = target
	if (!istype(victim))
		return
	var/datum/hallucination/picked_hallucination = pick(WIZARD_WAND_HALLUCINATIONS)
	victim.cause_hallucination(picked_hallucination, "wand")

#undef WIZARD_WAND_HALLUCINATIONS
