

/mob/living/carbon/alien/adult/nova/praetorian
	name = "alien praetorian"
	desc = "An alien that looks like the awkward half-way point between a queen and a drone, in fact that's likely what it is."
	caste = "praetorian"
	maxHealth = 400
	health = 400
	icon_state = "alienpraetorian"
	melee_damage_lower = 25
	melee_damage_upper = 30
	next_evolution = /mob/living/carbon/alien/adult/nova/queen

/mob/living/carbon/alien/adult/nova/praetorian/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/alien/nova/heal_aura/juiced,
		/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/hard_throwing,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/nova/praetorian/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel/large
	organs += new /obj/item/organ/internal/alien/neurotoxin/spitter
	organs += new /obj/item/organ/internal/alien/resinspinner
	..()

/datum/action/cooldown/alien/nova/heal_aura/juiced
	name = "Strong Healing Aura"
	desc = "Friendly xenomorphs in a longer range around yourself will receive passive healing."
	button_icon_state = "healaura_juiced"
	plasma_cost = 100
	cooldown_time = 90 SECONDS
	aura_range = 7
	aura_healing_amount = 10
	aura_healing_color = COLOR_RED_LIGHT

/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep/hard_throwing
	name = "Flinging Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail that is much stronger than other aliens."

	aoe_radius = 2
	repulse_force = MOVE_FORCE_OVERPOWERING //Fuck everyone who gets hit by this tail in particular

	button_icon_state = "throw_tail"

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep/praetorian

	impact_sound = 'sound/weapons/slap.ogg'
	impact_damage = 20
	impact_wound_bonus = 10

/obj/effect/temp_visual/dir_setting/tailsweep/praetorian
	icon = 'monkestation/code/modules/blueshift/icons/xeno_actions.dmi'
	icon_state = "throw_tail_anim"

/datum/action/cooldown/alien/acid/nova/spread
	name = "Spit Neurotoxin Spread"
	desc = "Spits a spread neurotoxin at someone, exhausting them."
	plasma_cost = 50
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit
	spit_sound = 'monkestation/code/modules/blueshift/sounds/alien_spitacid2.ogg'
	cooldown_time = 10 SECONDS

/obj/item/ammo_casing/xenospit //This is probably really bad, however I couldn't find any other nice way to do this
	name = "big glob of neurotoxin"
	projectile_type = /obj/projectile/neurotoxin/nova/spitter_spread
	pellets = 3
	variance = 20

/obj/item/ammo_casing/xenospit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/xenospit/tk_firing(mob/living/user, atom/fired_from)
	return FALSE

/obj/projectile/neurotoxin/nova/spitter_spread //Slightly nerfed because its a shotgun spread of these
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 25

/datum/action/cooldown/alien/acid/nova/spread/lethal
	name = "Spit Acid Spread"
	desc = "Spits a spread of acid at someone, burning them."
	acid_projectile = null
	acid_casing = /obj/item/ammo_casing/xenospit/spread/lethal
	button_icon_state = "acidspit_0"
	projectile_name = "acid"
	button_base_icon = "acidspit"

/obj/item/ammo_casing/xenospit/spread/lethal
	name = "big glob of acid"
	projectile_type = /obj/projectile/neurotoxin/nova/acid/spitter_spread
	pellets = 4
	variance = 30

/obj/projectile/neurotoxin/nova/acid/spitter_spread
	name = "acid spit"
	icon_state = "toxin"
	damage = 15
	damage_type = BURN

/obj/item/organ/internal/alien/neurotoxin/spitter
	name = "large neurotoxin gland"
	icon_state = "neurotox"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_XENO_NEUROTOXINGLAND
	actions_types = list(
		/datum/action/cooldown/alien/acid/nova/spread,
		/datum/action/cooldown/alien/acid/nova/spread/lethal,
		/datum/action/cooldown/alien/acid/corrosion,
	)
