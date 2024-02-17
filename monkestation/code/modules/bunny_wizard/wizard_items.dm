/obj/item/gun/magic/staff/bunny
	name = "staff of bunnies"
	desc = "An artefact that spits bolts of lagomorphic energy which cause the target's appearence and clothing to change."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	icon_state = "bunnystaff"
	inhand_icon_state = "bunnystaff"
	worn_icon_state = "bunnystaff"
	ammo_type = /obj/item/ammo_casing/magic/bunny
	school = SCHOOL_TRANSMUTATION

/obj/item/ammo_casing/magic/bunny
	projectile_type = /obj/projectile/magic/bunny

/obj/projectile/magic/bunny
	name = "bolt of bunny"
	icon_state = "bun_bolt"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'

/obj/projectile/magic/bunny/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()

	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		victim.bunnify()
		return


/obj/item/gun/magic/wand/bunny //*sigh
	name = "wand of bunnies"
	desc = "This wand attuned to bunnies and alters a victim's form to a specific one. It seems to regain power over time."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/belt.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "bunnywand"
	base_icon_state = "bunnywand"
	worn_icon_state = "bunnywand"
	inhand_icon_state = "bunnywand"
	ammo_type = /obj/item/ammo_casing/magic/bunny
	max_charges = 8
	variable_charges = FALSE
	can_charge = TRUE

/obj/item/gun/magic/wand/bunny/zap_self(mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		user.bunnify()
		charges--
		return

/datum/spellbook_entry/item/wandbunny
	name = "Wand of Bunnies"
	desc = "An artefact that spits bolts of lagomorphic energy which cause the target's appearence and clothing to change. Unlike most wands, it is able to recharge its own power. This magic doesn't effect machines or animals."
	item_path = /obj/item/gun/magic/wand/bunny
	category = "Offensive"

/mob/living/carbon/human/proc/bunnify(mob/target)
	var/obj/effect/particle_effect/fluid/smoke/exit_poof = new(get_turf(src))
	exit_poof.lifetime = 2 SECONDS
	for(var/obj/item/clothing/maybe_cursed as anything in get_equipped_items())
		if(HAS_TRAIT_FROM(maybe_cursed, TRAIT_NODROP, CURSED_ITEM_TRAIT(maybe_cursed.type)))
			REMOVE_TRAIT(maybe_cursed, TRAIT_NODROP, CURSED_ITEM_TRAIT(maybe_cursed.type)) //Get rid fo their cursed gear for different cursed gear

	unequip_everything()
	to_chat(src, span_notice("Your clothing falls to the floor and you seem to be wearing something different!"))
	src.physique = FEMALE
	update_body(is_creating = TRUE) //actually update your body sprite
	if(IS_WIZARD(src))
		equipOutfit(/datum/outfit/cursed_bunny/magician)
		return
	if(isplasmaman(src))
		equipOutfit(/datum/outfit/plasmaman/cursed_bunny)
		return
	var/bunny_theme = pick_weight(list(
	"Color" = 43,
	 pick(list(
		"British",
		"Communist",
		"USA",
	)) = 30,
	"Black" = 16,
	"Centcomm" = 2,
	"Syndicate" = 2,
	))

	switch(bunny_theme)
		if("Color")
			equipOutfit(/datum/outfit/cursed_bunny/color)
			return
		if("British")
			equipOutfit(/datum/outfit/cursed_bunny/british)
			return
		if("Communist")
			equipOutfit(/datum/outfit/cursed_bunny/communist)
			return
		if("USA")
			equipOutfit(/datum/outfit/cursed_bunny/usa)
			return
		if("Black")
			equipOutfit(/datum/outfit/cursed_bunny)
			return
		if("Syndicate")
			equipOutfit(/datum/outfit/cursed_bunny/syndicate)
			return
		if("Centcomm")
			equipOutfit(/datum/outfit/cursed_bunny/centcom)
			return
