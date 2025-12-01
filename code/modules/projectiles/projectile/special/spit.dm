/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 65
	damage_type = STAMINA
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin
	armour_penetration = 50

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isalien(target))
		damage = 0
	return ..()

/obj/projectile/neurotoxin/damaging //for ai controlled aliums
	damage = 30
	paralyze = 0 SECONDS

/obj/projectile/ink_spit
	name = "ink spit"
	icon_state = "ink_spit"
	damage = 5
	damage_type = STAMINA
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ink_spit
	armour_penetration = 50
	hitsound = SFX_DESECRATION
	hitsound_wall = SFX_DESECRATION

/obj/projectile/ink_spit/Initialize(mapload)
	. = ..()
	if(isliving(firer))
		var/mob/living/living = firer
		var/datum/status_effect/organ_set_bonus/fish/bonus = living?.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
		if(bonus?.bonus_active)
			damage = 12
			armour_penetration = 65

	AddComponent(/datum/component/splat, \
		memory_type = /datum/memory/witnessed_inking, \
		smudge_type = /obj/effect/decal/cleanable/food/squid_ink, \
		moodlet_type = /datum/mood_event/inked, \
		splat_color = COLOR_NEARLY_ALL_BLACK, \
		hit_callback = CALLBACK(src, PROC_REF(blind_em)), \
	)

/obj/projectile/ink_spit/proc/blind_em(mob/living/victim, can_splat_on)
	if(!can_splat_on)
		return
	var/powered_up = FALSE
	if(isliving(firer))
		var/mob/living/living = firer
		var/datum/status_effect/organ_set_bonus/fish/bonus = living?.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
		powered_up = bonus?.bonus_active
	victim.adjust_temp_blindness_up_to((powered_up ? 6.5 : 4.5) SECONDS, 10 SECONDS)
	victim.adjust_confusion_up_to((powered_up ? 3 : 1.5) SECONDS, 6 SECONDS)
	if(powered_up)
		victim.Knockdown(2 SECONDS) //splat!
