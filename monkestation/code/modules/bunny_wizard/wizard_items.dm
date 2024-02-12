/obj/item/gun/magic/staff/bunny
	name = "staff of bunnies"
	desc = "An artefact that spits bolts of lagomorphic energy which cause the target's appearence and clothing to change."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	ammo_type = /obj/item/ammo_casing/magic/bunny
	icon_state = "bunnystaff"
	inhand_icon_state = "bunnystaff"
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
		to_chat(victim, span_notice("Your clothing falls to the floor! And now you feel like serving drinks..."))
	return


/obj/item/gun/magic/wand/bunny //*sigh
	name = "wand of bunnies"
	desc = "Never doubt what a wizard will make on a bet."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/belt.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "bunnywand"
	base_icon_state = "bunnywand"
	inhand_icon_state = "bunnywand"
	ammo_type = /obj/item/ammo_casing/magic/bunny

/obj/item/gun/magic/wand/bunny/zap_self(mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		user.bunnify()
		to_chat(user, span_notice("Your clothing falls to the floor! And now you feel like serving drinks..."))

/datum/spellbook_entry/item/staffbunny
	name = "Staff of Bunnies"
	desc = "An artefact that spits bolts of lagomorphic energy which cause the target's appearence and clothing to change. This magic doesn't effect machines or animals."
	item_path = /obj/item/gun/magic/staff/bunny
	category = "Offensive"

/mob/living/carbon/human/proc/bunnify(mob/target)
	var/obj/effect/particle_effect/fluid/smoke/exit_poof = new(get_turf(src))
	exit_poof.lifetime = 2 SECONDS
	var/list/curse_check = list()
	curse_check += src.get_item_by_slot(ITEM_SLOT_FEET)
	curse_check += src.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	curse_check += src.get_item_by_slot(ITEM_SLOT_HEAD)
	for(var/obj/item/trait_needed as anything in curse_check)
		REMOVE_TRAIT(trait_needed, TRAIT_NODROP, CURSED_ITEM_TRAIT(trait_needed.type))
	unequip_everything() //Get rid fo their cursed gear for different cursed gear
	src.physique = FEMALE
	update_body(is_creating = TRUE) //actually update your body
//	if(IS_WIZARD(src))
//		equipOutfit(/datum/outfit/wizard/cursed_magician)
	if(isplasmaman(src))
		equipOutfit(/datum/outfit/plasmaman/cursed_bunny)
		return
	var/bunny_theme = pick_weight(list(
	"Color" = 40,
	/* pick(list(
		"British",
		"Communist",
		"USA",
	)) = 20,
	"Centcomm" = 6, */
	"Syndicate" = 3,
	))

	switch(bunny_theme)
		if("Color")
			equipOutfit(/datum/outfit/cursed_bunny/color, FALSE)
			return
		if("Syndicate")
			equipOutfit(/datum/outfit/cursed_bunny/syndicate)
			return
			/*
		if("Centcomm")
			return /datum/outfit/cursed_bunny/centcomm
		if("British")
			return /datum/outfit/cursed_bunny/british
		if("Communist")
			return /datum/outfit/cursed_bunny/communist
		if("USA")
			return /datum/outfit/cursed_bunny/usa
*/
