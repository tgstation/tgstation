/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "sticky"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/cellulose = 5)
	splint_factor = 0.65
	merge_type = /obj/item/stack/sticky_tape
	/// The embed stats offered by this type of tape
	var/list/conferred_embed = EMBED_HARMLESS
	/// If set, this trait will be applied to the target item on application
	var/applied_trait

/obj/item/stack/sticky_tape/afterattack(obj/item/target, mob/living/user, proximity)
	if(!proximity)
		return

	if(!istype(target))
		return

	if(target.embedding && target.embedding == conferred_embed)
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return

	user.visible_message(span_notice("[user] begins wrapping [target] with [src]."), span_notice("You begin wrapping [target] with [src]."))

	if(!do_after(user, 3 SECONDS, target=target))
		return

	if(target.embedding && target.embedding == conferred_embed) // in case we somehow already wrapped it in that time
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return

	use(1)
	if(istype(target, /obj/item/clothing/gloves/fingerless))
		var/obj/item/clothing/gloves/tackler/offbrand/slapcraft_gloves = new /obj/item/clothing/gloves/tackler/offbrand
		to_chat(user, span_notice("You turn [target] into [slapcraft_gloves] with [src]."))
		QDEL_NULL(target)
		user.put_in_hands(slapcraft_gloves)
		return

	if(applied_trait)
		ADD_TRAIT(target, applied_trait, STICKY_TAPE_TRAIT)

	target.embedding = conferred_embed
	target.updateEmbedding()
	to_chat(user, span_notice("You finish wrapping [target] with [src]."))
	target.name = "[prefix] [target.name]"

	if(istype(target, /obj/item/grenade))
		var/obj/item/grenade/sticky_bomb = target
		sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	icon_state = "tape_y"
	prefix = "super sticky"
	conferred_embed = EMBED_HARMLESS_SUPERIOR
	splint_factor = 0.4
	merge_type = /obj/item/stack/sticky_tape/super

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	conferred_embed = EMBED_POINTY
	merge_type = /obj/item/stack/sticky_tape/pointy

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	icon_state = "tape_spikes"
	prefix = "super pointy"
	conferred_embed = EMBED_POINTY_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape/pointy/super
	applied_trait = TRAIT_CLEANBOT_COMPATIBLE

/obj/item/stack/sticky_tape/surgical
	name = "surgical tape"
	singular_name = "surgical tape"
	desc = "Made for patching broken bones back together alongside bone gel, not for playing pranks."
	//icon_state = "tape_spikes"
	prefix = "surgical"
	conferred_embed = list("embed_chance" = 30, "pain_mult" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)
	splint_factor = 0.5
	custom_price = PAYCHECK_MEDIUM
	merge_type = /obj/item/stack/sticky_tape/surgical
