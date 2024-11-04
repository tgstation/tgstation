/obj/item/organ/heart/gland/electric
	abductor_hint = "electron accumulator/discharger. The abductee becomes fully immune to electric shocks. Additionally, they will randomly discharge electric bolts."
	cooldown_low = 800
	cooldown_high = 1200
	icon_state = "species"
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/heart/gland/electric/on_mob_insert(mob/living/carbon/gland_owner)
	. = ..()
	ADD_TRAIT(gland_owner, TRAIT_SHOCKIMMUNE, ABDUCTOR_GLAND_TRAIT)

/obj/item/organ/heart/gland/electric/on_mob_remove(mob/living/carbon/gland_owner)
	. = ..()
	REMOVE_TRAIT(gland_owner, TRAIT_SHOCKIMMUNE, ABDUCTOR_GLAND_TRAIT)

/obj/item/organ/heart/gland/electric/activate()
	owner.visible_message(span_danger("[owner]'s skin starts emitting electric arcs!"),\
	span_warning("You feel electric energy building up inside you!"))
	create_sound(owner, SFX_SPARKS).volume(100).vary(TRUE).extra_range(SHORT_RANGE_SOUND_EXTRARANGE).play()
	addtimer(CALLBACK(src, PROC_REF(zap)), rand(3 SECONDS, 10 SECONDS))

/obj/item/organ/heart/gland/electric/proc/zap()
	tesla_zap(source = owner, zap_range = 4, power = 8e3, cutoff = 1e3, zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN)
	create_sound(get_turf(owner), 'sound/effects/magic/lightningshock.ogg').vary(TRUE).play()
