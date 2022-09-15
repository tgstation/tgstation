/obj/item/organ/internal/heart/gland/electric
	abductor_hint = "electron accumulator/discharger. The abductee becomes fully immune to electric shocks. Additionally, they will randomly discharge electric bolts."
	cooldown_low = 800
	cooldown_high = 1200
	icon_state = "species"
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/internal/heart/gland/electric/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "abductor_gland")

/obj/item/organ/internal/heart/gland/electric/Remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "abductor_gland")
	..()

/obj/item/organ/internal/heart/gland/electric/activate()
	owner.visible_message(span_danger("[owner]'s skin starts emitting electric arcs!"),\
	span_warning("You feel electric energy building up inside you!"))
	playsound(get_turf(owner), SFX_SPARKS, 100, TRUE, -1, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, .proc/zap), rand(30, 100))

/obj/item/organ/internal/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN)
	playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, TRUE)
