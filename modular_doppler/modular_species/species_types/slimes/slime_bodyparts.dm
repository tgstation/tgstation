// Roundstartslimes!

#define SLIME_LIMB_BLOOD_LOSS 60

/obj/item/bodypart/head/jelly
	can_dismember = TRUE //Their organs are in their chest now, all slime subspecies, so they can safely be decapitated.

/obj/item/bodypart/head/jelly/slime/roundstart
	is_dimorphic = FALSE
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)
	teeth_count = 0

/obj/item/bodypart/chest/jelly/slime/roundstart
	is_dimorphic = TRUE
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/arm/left/jelly/slime/roundstart
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/arm/right/jelly/slime/roundstart
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/left/jelly/slime/roundstart
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/leg/right/jelly/slime/roundstart
	icon_greyscale = BODYPART_ICON_ROUNDSTARTSLIME
	biological_state = (BIO_FLESH|BIO_BLOODED)

/obj/item/bodypart/head/jelly/Initialize(mapload)
    . = ..()
    AddElement(/datum/element/splattering_limb)

/obj/item/bodypart/arm/left/jelly/Initialize(mapload)
    . = ..()
    AddElement(/datum/element/splattering_limb)

/obj/item/bodypart/arm/right/jelly/Initialize(mapload)
    . = ..()
    AddElement(/datum/element/splattering_limb)

/obj/item/bodypart/leg/left/jelly/Initialize(mapload)
    . = ..()
    AddElement(/datum/element/splattering_limb)

/obj/item/bodypart/leg/right/jelly/Initialize(mapload)
    . = ..()
    AddElement(/datum/element/splattering_limb)

/**
 * Splattering limb element
 *
 * When an /obj/item/bodypart with this is dropped,
 * instead splatter and lower the owner's blood.
 */
/datum/element/splattering_limb

/datum/element/splattering_limb/Attach(datum/target)
    . = ..()
    if(!isbodypart(target))
        return ELEMENT_INCOMPATIBLE

    RegisterSignal(target, COMSIG_BODYPART_REMOVED, PROC_REF(on_bodypart_removed))

/datum/element/splattering_limb/proc/on_bodypart_removed(obj/item/bodypart/source, mob/living/carbon/human/owner, special, dismembered)
    SIGNAL_HANDLER

    if(special || isnull(owner) || QDELETED(source))
        return

    var/obj/goo_splat
    goo_splat = new /obj/effect/decal/cleanable/goo(get_turf(owner))
    if(HAS_TRAIT(owner, TRAIT_MUTANT_COLORS))
        goo_splat.color = owner.dna.features["mcolor"]

    owner.blood_volume -= SLIME_LIMB_BLOOD_LOSS

    post_bodypart_removed(source, owner)

/datum/element/splattering_limb/proc/post_bodypart_removed(obj/item/bodypart/source, mob/living/carbon/human/owner)
    to_chat(owner, span_warning("Your [source.name] splatters with an unnerving squelch!"))
    source.drop_organs(null, TRUE)
    qdel(source)

/obj/effect/decal/cleanable/goo
	name = "small puddle of goo"
	desc = "Its colorful! Who knows what else it could be..."
	icon = 'icons/effects/blood.dmi'
	icon_state = "drip1"
	random_icon_states = list("drip1", "drip2", "drip3")
	beauty = -50

/obj/effect/decal/cleanable/goo/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

#undef SLIME_LIMB_BLOOD_LOSS
