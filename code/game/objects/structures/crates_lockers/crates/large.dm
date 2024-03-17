/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate. You'll need a crowbar to get it open."
	icon_state = "largecrate"
	base_icon_state = "largecrate"
	density = TRUE
	pass_flags_self = PASSSTRUCTURE
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_install_electronics = FALSE
	elevation = 22

	// Stops people from "diving into" a crate you can't open normally
	divable = FALSE

/obj/structure/closet/crate/large/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_MISSING_ITEM_ERROR, TRAIT_GENERIC)

/obj/structure/closet/crate/large/attack_hand(mob/user, list/modifiers)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, span_warning("You need a crowbar to pry this open!"))

/obj/structure/closet/crate/large/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(manifest)
			tear_manifest(user)
		if(!open(user))
			return FALSE
		user.visible_message(span_notice("[user] pries \the [src] open."), \
			span_notice("You pry open \the [src]."), \
			span_hear("You hear splitting wood."))
		playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, TRUE)

		var/turf/T = get_turf(src)
		for(var/i in 1 to material_drop_amount)
			new material_drop(src)
		for(var/atom/movable/AM in contents)
			AM.forceMove(T)
		qdel(src)

	else
		if(user.combat_mode) //Only return  ..() if intent is harm, otherwise return 0 or just end it.
			return ..() //Stops it from opening and turning invisible when items are used on it.

		else
			to_chat(user, span_warning("You need a crowbar to pry this open!"))
			return FALSE //Just stop. Do nothing. Don't turn into an invisible sprite. Don't open like a locker.
					//The large crate has no non-attack interactions other than the crowbar, anyway.

/obj/structure/closet/crate/large/hats/PopulateContents()
	..()
	for (var/i in 1 to 5)
		new /obj/effect/spawner/random/clothing/funny_hats(src)
	if(prob(1))
		var/our_contents = list()
		for(var/obj/item/clothing/head/any_hat in contents)
			our_contents[any_hat]++
		if(our_contents)
			var/obj/item/clothing/head/lucky_hat = pick(our_contents)
			lucky_hat.AddComponent(/datum/component/unusual_effect, color = "#FFEA0030", include_particles = TRUE)
			lucky_hat.name = "unusual [name]"
