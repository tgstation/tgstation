//The chests dropped by mob spawner tendrils. Also contains associated loot.

#define HIEROPHANT_BLINK_RANGE 5
#define HIEROPHANT_BLINK_COOLDOWN 15 SECONDS

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously. You need a skeleton key to open it."
	///prevents bust_open to fire
	integrity_failure = 0
	/// var to check if it got opened by a key
	var/spawned_loot = FALSE

/obj/structure/closet/crate/necropolis/tendril/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/try_spawn_loot)

/obj/structure/closet/crate/necropolis/tendril/proc/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/skeleton_key) || spawned_loot)
		return FALSE
	var/loot = rand(1,21)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/soulstone/anybody(src)
		if(3)
			new /obj/item/katana/cursed(src)
		if(4)
			new /obj/item/clothing/glasses/godeye(src)
		if(5)
			new /obj/item/reagent_containers/glass/bottle/potion/flight(src)
		if(6)
			new /obj/item/clothing/gloves/gauntlets(src)
		if(7)
			var/mod = rand(1,4)
			switch(mod)
				if(1)
					new /obj/item/disk/design_disk/modkit_disc/resonator_blast(src)
				if(2)
					new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(src)
				if(3)
					new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(src)
				if(4)
					new /obj/item/disk/design_disk/modkit_disc/bounty(src)
		if(8)
			new /obj/item/rod_of_asclepius(src)
		if(9)
			new /obj/item/organ/heart/cursed/wizard(src)
		if(10)
			new /obj/item/ship_in_a_bottle(src)
		if(11)
			new /obj/item/clothing/suit/space/hardsuit/berserker(src)
		if(12)
			new /obj/item/jacobs_ladder(src)
		if(13)
			new /obj/item/guardiancreator/miner(src)
		if(14)
			new /obj/item/warp_cube/red(src)
		if(15)
			new /obj/item/wisp_lantern(src)
		if(16)
			new /obj/item/immortality_talisman(src)
		if(17)
			new /obj/item/voodoo(src)
		if(18)
			new /obj/item/book/granter/spell/summonitem(src)
		if(19)
			new /obj/item/book_of_babel(src)
		if(20)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
		if(21)
			new /obj/item/clothing/neck/necklace/memento_mori(src)
	spawned_loot = TRUE
	qdel(item)
	to_chat(user, "<span class='notice'>You disable the magic lock, revealing the loot.</span>")
	return TRUE

/obj/structure/closet/crate/necropolis/tendril/can_open(mob/living/user, force = FALSE)
	if(!spawned_loot)
		return FALSE
	return ..()

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/Initialize()
	. = ..()
	blueprints[1] = new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	category = list("Mining Designs", "Cyborg Upgrade Modules") //can't be normally obtained
	build_type = PROTOLATHE | MECHFAB
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(/datum/material/iron = 7000, /datum/material/glass = 3000, /datum/material/silver = 3000, /datum/material/gold = 3000, /datum/material/diamond = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/uranium = 8000, /datum/material/bluespace = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 5000, /datum/material/uranium = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(/datum/material/iron = 4000, /datum/material/silver = 4000, /datum/material/gold = 4000, /datum/material/bluespace = 4000)
	reagents_list = list(/datum/reagent/blood = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, "<span class='warning'>The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath.</span>")
		return
	var/mob/living/carbon/itemUser = user
	usedHand = itemUser.get_held_index_of_item(src)
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, "<span class='warning'>You can't possibly handle the responsibility of more than one rod!</span>")
		return
	var/failText = "<span class='warning'>The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!</span>"
	to_chat(itemUser, "<span class='notice'>The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong...</span>")
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 20, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, "<span class='notice'>The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory...</span>")
	var/datum/status_effect/hippocratic_oath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags = DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	activated = TRUE

//Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return slot == ITEM_SLOT_NECK

/obj/item/clothing/neck/necklace/memento_mori/dropped(mob/user)
	..()
	if(active_owner)
		mori()

//Just in case
/obj/item/clothing/neck/necklace/memento_mori/Destroy()
	if(active_owner)
		mori()
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/memento(mob/living/carbon/human/user)
	to_chat(user, "<span class='warning'>You feel your life being drained by the pendant...</span>")
	if(do_after(user, 40, target = user))
		to_chat(user, "<span class='notice'>Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die.</span>")
		ADD_TRAIT(user, TRAIT_NODEATH, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOHARDCRIT, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, "memento_mori")
		icon_state = "memento_mori_active"
		active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if(!active_owner)
		return
	var/mob/living/carbon/human/H = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(H, "<span class='userdanger'>You feel your life rapidly slipping away from you!</span>")
	H.dust(TRUE, TRUE)

/datum/action/item_action/hands_free/memento_mori
	check_flags = NONE
	name = "Memento Mori"
	desc = "Bind your life to the pendant."

/datum/action/item_action/hands_free/memento_mori/Trigger()
	var/obj/item/clothing/neck/necklace/memento_mori/MM = target
	if(!MM.active_owner)
		if(ishuman(owner))
			MM.memento(owner)
			Remove(MM.active_owner) //Remove the action button, since there's no real use in having it now.

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	inhand_icon_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, "<span class='warning'>The wisp has gone missing!</span>")
		icon_state = "lantern"
		return

	if(wisp.loc == src)
		to_chat(user, "<span class='notice'>You release the wisp. It begins to bob around your head.</span>")
		icon_state = "lantern"
		wisp.orbit(user, 20)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")

	else
		to_chat(user, "<span class='notice'>You return the wisp to the lantern.</span>")
		icon_state = "lantern-blue"
		wisp.forceMove(src)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned")

/obj/item/wisp_lantern/Initialize()
	. = ..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message("<span class='notice'>[wisp] has a sad feeling for a moment, then it passes.</span>")
	return ..()

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_flags = LIGHT_ATTACHED
	layer = ABOVE_ALL_MOB_LAYER
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/effect/wisp/orbit(atom/thing, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	. = ..()
	if(ismob(thing))
		RegisterSignal(thing, COMSIG_MOB_UPDATE_SIGHT, .proc/update_user_sight)
		var/mob/being = thing
		being.update_sight()
		to_chat(thing, "<span class='notice'>The wisp enhances your vision.</span>")

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	if(ismob(orbits.parent))
		UnregisterSignal(orbits.parent, COMSIG_MOB_UPDATE_SIGHT)
		to_chat(orbits.parent, "<span class='notice'>Your vision returns to normal.</span>")

/obj/effect/wisp/proc/update_user_sight(mob/user)
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/teleport_color = "#3FBAFD"
	var/obj/item/warp_cube/linked
	var/teleporting = FALSE

/obj/item/warp_cube/attack_self(mob/user)
	var/turf/current_location = get_turf(user)
	var/area/current_area = current_location.loc
	if(!linked || (current_area.area_flags & NOTELEPORT))
		to_chat(user, "<span class='warning'>[src] fizzles uselessly.</span>")
		return
	if(teleporting)
		return
	teleporting = TRUE
	linked.teleporting = TRUE
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/warp_cube(T, user, teleport_color, TRUE)
	SSblackbox.record_feedback("tally", "warp_cube", 1, type)
	new /obj/effect/temp_visual/warp_cube(get_turf(linked), user, linked.teleport_color, FALSE)
	var/obj/effect/warp_cube/link_holder = new /obj/effect/warp_cube(T)
	user.forceMove(link_holder) //mess around with loc so the user can't wander around
	sleep(2.5)
	if(QDELETED(user))
		qdel(link_holder)
		return
	if(QDELETED(linked))
		user.forceMove(get_turf(link_holder))
		qdel(link_holder)
		return
	link_holder.forceMove(get_turf(linked))
	sleep(2.5)
	if(QDELETED(user))
		qdel(link_holder)
		return
	teleporting = FALSE
	if(!QDELETED(linked))
		linked.teleporting = FALSE
	user.forceMove(get_turf(link_holder))
	qdel(link_holder)

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"
	teleport_color = "#FD3F48"

/obj/item/warp_cube/red/Initialize()
	. = ..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

/obj/effect/warp_cube
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

//Meat Hook
/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	inhand_icon_state = "hook"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	item_flags = NEEDS_PERMIT | NOBLUDGEON
	force = 18

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/projectile/hook
	caliber = CALIBER_HOOK
	icon_state = "hook"

/obj/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 20
	stamina = 20
	armour_penetration = 60
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	var/chain
	var/knockdown_time = (0.5 SECONDS)

/obj/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain")
	..()
	//TODO: root the firer until the chain returns

/obj/projectile/hook/on_hit(atom/target)
	. = ..()
	if(ismovable(target))
		var/atom/movable/A = target
		if(A.anchored)
			return
		A.visible_message("<span class='danger'>[A] is snagged by [firer]'s hook!</span>")
		new /datum/forced_movement(A, get_turf(firer), 5, TRUE)
		if (isliving(target))
			var/mob/living/fresh_meat = target
			fresh_meat.Knockdown(knockdown_time)
			return
		//TODO: keep the chain beamed to A
		//TODO: needs a callback to delete the chain

/obj/projectile/hook/Destroy()
	qdel(chain)
	return ..()

//just a nerfed version of the real thing for the bounty hunters.
/obj/item/gun/magic/hook/bounty
	name = "hook"
	ammo_type = /obj/item/ammo_casing/magic/hook/bounty

/obj/item/gun/magic/hook/bounty/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>The [src] isn't ready to fire yet!</span>")

/obj/item/ammo_casing/magic/hook/bounty
	projectile_type = /obj/projectile/hook/bounty

/obj/projectile/hook/bounty
	damage = 0
	stamina = 40

//Immortality Talisman
/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE)

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
		cooldown = world.time + 600
		new /obj/effect/immortality_talisman(get_turf(user), user)
	else
		to_chat(user, "<span class='warning'>[src] is not ready yet!</span>")

/obj/effect/immortality_talisman
	name = "hole in reality"
	desc = "It's shaped an awful lot like a person."
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/vanish_description = "vanishes from reality"
	var/can_destroy = TRUE

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()
	if(new_user)
		vanish(new_user)

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message("<span class='danger'>[user] [vanish_description], leaving a hole in [user.p_their()] place!</span>")

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.notransform = TRUE
	user.status_flags |= GODMODE

	can_destroy = FALSE

	addtimer(CALLBACK(src, .proc/unvanish, user), 10 SECONDS)

/obj/effect/immortality_talisman/proc/unvanish(mob/user)
	user.status_flags &= ~GODMODE
	user.notransform = FALSE
	user.forceMove(get_turf(src))

	user.visible_message("<span class='danger'>[user] pops back into reality!</span>")
	can_destroy = TRUE
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"

//Shared Bag

/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = INDESTRUCTIBLE

/obj/item/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/shared_storage/red/Initialize()
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	STR.max_items = 21
	new /obj/item/shared_storage/blue(drop_location(), STR)

/obj/item/shared_storage/blue/Initialize(mapload, datum/component/storage/concrete/master)
	. = ..()
	if(!istype(master))
		return INITIALIZE_HINT_QDEL
	var/datum/component/storage/STR = AddComponent(/datum/component/storage, master)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	STR.max_items = 21

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/attack_self(mob/user)
	if(!user.can_read(src))
		return FALSE
	to_chat(user, "<span class='notice'>You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops.</span>")
	user.grant_all_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)


//Potion of Flight
/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon_state()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		var/mob/living/carbon/exposed_carbon = exposed_mob
		var/holycheck = ishumanbasic(exposed_carbon)
		if(reac_volume < 5 || !(holycheck || islizard(exposed_carbon) || (ismoth(exposed_carbon) && exposed_carbon.dna.features["moth_wings"] != "Burnt Off"))) // implying xenohumans are holy //as with all things,
			if((methods & INGEST) && show_message)
				to_chat(exposed_carbon, "<span class='notice'><i>You feel nothing but a terrible aftertaste.</i></span>")
			return
		if(exposed_carbon.dna.species.has_innate_wings)
			to_chat(exposed_carbon, "<span class='userdanger'>A terrible pain travels down your back as your wings change shape!</span>")
			if(!exposed_carbon.dna.features["original_moth_wings"]) //Stores their wings for later possible reconstruction
				exposed_carbon.dna.features["original_moth_wings"] = exposed_carbon.dna.features["moth_wings"]
			exposed_carbon.dna.features["moth_wings"] = "None"
			if(!exposed_carbon.dna.features["original_moth_antennae"]) //Stores their antennae type as well
				exposed_carbon.dna.features["original_moth_antennae"] = exposed_carbon.dna.features["moth_antennae"]
			exposed_carbon.dna.features["moth_antennae"] = "Regal"
		else
			to_chat(exposed_carbon, "<span class='userdanger'>A terrible pain travels down your back as wings burst out!</span>")
		exposed_carbon.dna.species.GiveSpeciesFlight(exposed_carbon)
		if(holycheck)
			to_chat(exposed_carbon, "<span class='notice'>You feel blessed!</span>")
			ADD_TRAIT(exposed_carbon, TRAIT_HOLY, SPECIES_TRAIT)
		playsound(exposed_carbon.loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -1)
		exposed_carbon.adjustBruteLoss(20)
		exposed_carbon.emote("scream")


/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder00"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/ladder_x = T.x
	var/ladder_y = T.y
	to_chat(user, "<span class='notice'>You unfold the ladder. It extends much farther than you were expecting.</span>")
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_centcom_level(i) || is_reserved_level(i) || is_away_level(i))
			continue
		var/turf/T2 = locate(ladder_x, ladder_y, i)
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(T2, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

//Concussive Gauntlets
/obj/item/clothing/gloves/gauntlets
	name = "concussive gauntlets"
	desc = "Pickaxes... for your hands!"
	icon_state = "concussive_gauntlets"
	inhand_icon_state = "concussive_gauntlets"
	toolspeed = 0.1
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 100, BIO = 0, RAD = 0, FIRE = 100, ACID = 30) //mostly bone bracer armor

/obj/item/clothing/gloves/gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/rocksmash)
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, .proc/rocksmash)
	else
		stopmining(user)

/obj/item/clothing/gloves/gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)

/obj/item/clothing/gloves/gauntlets/proc/rocksmash(mob/living/carbon/human/H, atom/A, proximity)
	if(!istype(A, /turf/closed/mineral))
		return
	A.attackby(src, H)
	return COMPONENT_CANCEL_ATTACK_CHAIN


///Bosses

//Miniboss Miner

/obj/item/melee/transforming/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	throwforce_on = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	worn_icon_state = "cleaving_saw"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_off = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_on = list("cleaves", "swipes", "slashes", "chops")
	hitsound = 'sound/weapons/bladeslice.ogg'
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	faction_bonus_force = 30
	nemesis_factions = list("mining", "boss")
	var/transform_cooldown
	var/swiping = FALSE
	var/bleed_stacks_per_hit = 3

/obj/item/melee/transforming/cleaving_saw/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [active ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].\n"+\
	"Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.\n"+\
	"Transforming it immediately after an attack causes the next attack to come out faster.</span>"

/obj/item/melee/transforming/cleaving_saw/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is [active ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	transform_cooldown = 0
	transform_weapon(user, TRUE)
	return BRUTELOSS

/obj/item/melee/transforming/cleaving_saw/transform_weapon(mob/living/user, supress_message_text)
	if(transform_cooldown > world.time)
		return FALSE
	. = ..()
	if(.)
		transform_cooldown = world.time + (CLICK_CD_MELEE * 0.5)
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/melee/transforming/cleaving_saw/transform_messages(mob/living/user, supress_message_text)
	if(!supress_message_text)
		if(active)
			to_chat(user, "<span class='notice'>You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna.</span>")
		else
			to_chat(user, "<span class='notice'>You close [src]. It will now attack rapidly and cause fauna to bleed.</span>")
	playsound(user, 'sound/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))

/obj/item/melee/transforming/cleaving_saw/clumsy_transform_effect(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_bodypart_damage(10)

/obj/item/melee/transforming/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!active)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/transforming/cleaving_saw/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	var/datum/status_effect/stacking/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	if(!B)
		target.apply_status_effect(STATUS_EFFECT_SAWBLEED,bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

/obj/item/melee/transforming/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	if(!active || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!active)
			faction_bonus_force = 0
		..()
		if(!active)
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/L in T)
				if(user.Adjacent(L) && L.density)
					melee_attack_chain(user, L)
		swiping = FALSE

//Dragon

/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/PopulateContents()
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
		if(3)
			new /obj/item/book/granter/spell/sacredflame(src)
			new /obj/item/gun/magic/wand/fireball(src)
		if(4)
			new /obj/item/dragons_blood(src)

/obj/structure/closet/crate/necropolis/dragon/crusher
	name = "firey dragon chest"

/obj/structure/closet/crate/necropolis/dragon/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/tail_spike(src)

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	inhand_icon_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize()
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/butchering, 150, 90)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = GLOB.observer_default_invisibility
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "<span class='warning'>You just recently called out for aid. You don't want to annoy the spirits!</span>")
		return
	to_chat(user, "<span class='notice'>You call out for aid, attempting to summon spirits to your side.</span>")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href=?src=[REF(src)];orbit=1>(Click to help)</a>",
		source = user, ignore_key = POLL_IGNORE_SPECTRAL_BLADE, header = "Spectral blade")

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	for(var/thing in contents)
		var/atom/A = thing
		A.transfer_observers_to(src)

	for(var/i in orbiters?.orbiter_list)
		if(!isobserver(i))
			continue
		var/mob/dead/observer/G = i
		ghost_counter++
		G.invisibility = 0
		current_spirits |= G

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = GLOB.observer_default_invisibility

	spirits = current_spirits

	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirits!</span>")
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message("<span class='danger'>[owner] is protected by a ring of [ghost_counter] ghosts!</span>")
	return ..()

//Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			to_chat(user, "<span class='danger'>Your appearance morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities.</span>")
			H.dna.features = list("mcolor" = "A02720", "tail_lizard" = "Dark Tiger", "tail_human" = "None", "snout" = "Sharp", "horns" = "Curled", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "Long", "body_markings" = "Dark Tiger Body", "legs" = "Digitigrade Legs")
			H.eye_color = "fee5a3"
			H.set_species(/datum/species/lizard)
		if(2)
			to_chat(user, "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>")
			H.set_species(/datum/species/skeleton)
		if(3)
			to_chat(user, "<span class='danger'>Power courses through you! You can now shift your form at will.</span>")
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(4)
			to_chat(user, "<span class='danger'>You feel like you could walk straight through lava now.</span>")
			LAZYOR(H.weather_immunities, "lava")

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1 = list("Your bones ache.")
	stage2 = list("Your skin feels scaly.")
	stage3 = list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4 = list("<span class='danger'>Your blood burns.</span>")
	stage5 = list("<span class='danger'>You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	inhand_icon_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/open/lava/smooth
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space/transit, /turf/closed))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(target in view(user.client.view, get_turf(user)))

		var/turf/open/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message("<span class='danger'>[user] points [src] at [T]!</span>")
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				var/old_name = T.name
				if(T.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message("<span class='danger'>[user] turns \the [old_name] into [transform_string]!</span>")
					message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(T)]")
					log_game("[key_name(user)] fired the lava staff at [AREACOORD(T)].")
					timer = world.time + create_cooldown
					playsound(T,'sound/magic/fireball.ogg', 200, TRUE)
			else
				timer = world.time
			qdel(L)
		else
			var/old_name = T.name
			if(T.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
				user.visible_message("<span class='danger'>[user] turns \the [old_name] into [reset_string]!</span>")
				timer = world.time + reset_cooldown
				playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

//Bubblegum
/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/PopulateContents()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)
	var/loot = rand(1,2)
	switch(loot)
		if(1)
			new /obj/item/mayhem(src)
		if(2)
			new /obj/item/gun/magic/staff/spellblade(src)

/obj/structure/closet/crate/necropolis/bubblegum/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/demon_claws(src)

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		H.apply_status_effect(STATUS_EFFECT_MAYHEM)
	to_chat(user, "<span class='notice'>You shatter the bottle!</span>")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	message_admins("<span class='adminnotice'>[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!</span>")
	user.log_message("activated a bottle of mayhem", LOG_ATTACK)
	qdel(src)

//Colossus
/obj/structure/closet/crate/necropolis/colossus
	name = "colossus chest"

/obj/structure/closet/crate/necropolis/colossus/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/colossus))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/structure/closet/crate/necropolis/colossus/PopulateContents()
	var/list/choices = subtypesof(/obj/machinery/anomalous_crystal)
	var/random_crystal = pick(choices)
	new random_crystal(src)
	new /obj/item/organ/vocal_cords/colossus(src)

/obj/structure/closet/crate/necropolis/colossus/crusher
	name = "angelic colossus chest"

/obj/structure/closet/crate/necropolis/colossus/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/blaster_tubes(src)

//Hierophant
/datum/action/innate/dash/hierophant
	current_charges = 1
	max_charges = 1
	charge_rate = HIEROPHANT_BLINK_COOLDOWN
	recharge_sound = null
	phasein = /obj/effect/temp_visual/hierophant/blast/visual
	phaseout = /obj/effect/temp_visual/hierophant/blast/visual
	// It's a simple purple beam, works well enough for the purple hiero effects.
	beam_effect = "plasmabeam"

/datum/action/innate/dash/hierophant/Teleport(mob/user, atom/target)
	var/dist = get_dist(user, target)
	if(dist > HIEROPHANT_BLINK_RANGE)
		to_chat(user, "<span class='hierophant_warning'>Blink destination out of range.</span>")
		return

	. = ..()

	if(!current_charges)
		var/obj/item/hierophant_club/club = src.target
		if(istype(club))
			club.blink_charged = FALSE
			club.update_icon()

/datum/action/innate/dash/hierophant/charge()
	var/obj/item/hierophant_club/club = target
	if(istype(club))
		club.blink_charged = TRUE
		club.update_icon()

	current_charges = clamp(current_charges + 1, 0, max_charges)
	holder.update_action_buttons_icon()

	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)
	to_chat(holder, "<span class='notice'>[src] now has [current_charges]/[max_charges] charges.</span>")

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical teleportation feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	inhand_icon_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	attack_verb_continuous = list("clubs", "beats", "pummels")
	attack_verb_simple = list("club", "beat", "pummel")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall)

	/// Linked teleport beacon for the group teleport functionality.
	var/obj/effect/hierophant/beacon
	/// TRUE if currently doing a teleport to the beacon, FALSE otherwise.
	var/teleporting = FALSE //if we ARE teleporting

	/// Action enabling the blink-dash functionality.
	var/datum/action/innate/dash/hierophant/blink
	/// Whether the blink ability is activated. IF TRUE, left clicking a location will blink to it. If FALSE, this is disabled.
	var/blink_activated = TRUE
	/// Whether the blink is charged. Set and unset by the blink action. Used as part of setting the appropriate icon states.
	var/blink_charged = TRUE

/obj/item/hierophant_club/Initialize()
	. = ..()
	blink = new(src)

/obj/item/hierophant_club/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += "<span class='hierophant_warning'>The[beacon ? " beacon is not currently":"re is a beacon"] attached.</span>"

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message("<span class='suicide'>[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlockopen.ogg', 75, TRUE)
	user.visible_message("<span class='hierophant_warning'>[user] fades out, leaving [user.p_their()] belongings behind!</span>")
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		new /obj/effect/temp_visual/hierophant/blast/visual(T, user, TRUE)
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/attack_self(mob/user)
	blink_activated = !blink_activated
	to_chat(user, "<span class='notice'>You [blink_activated ? "enable" : "disable"] the blink function on [src].</span>")

/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	// If our target is the beacon and the hierostaff is next to the beacon, we're trying to pick it up.
	if((target == beacon) && target.Adjacent(src))
		return
	if(blink_activated)
		blink.Teleport(user, target)

/obj/item/hierophant_club/update_icon_state()
	icon_state = inhand_icon_state = "hierophant_club[blink_charged ? "_ready":""][(!QDELETED(beacon)) ? "":"_beacon"]"

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		to_chat(user, "<span class='warning'>You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!</span>")
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message("<span class='hierophant_warning'>[user] starts fiddling with [src]'s pommel...</span>", \
			"<span class='notice'>You start detaching the hierophant beacon...</span>")
			if(do_after(user, 50, target = user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_action_buttons_icon()
				user.visible_message("<span class='hierophant_warning'>[user] places a strange machine beneath [user.p_their()] feet!</span>", \
				"<span class='hierophant'>You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!</span>\n\
				<span class='notice'>You can remove the beacon to place it again by striking it with the club.</span>")
		else
			to_chat(user, "<span class='warning'>You need to be on solid ground to detach the beacon!</span>")
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, "<span class='warning'>You are too close to the beacon to teleport to it!</span>")
		return
	var/turf/beacon_turf = get_turf(beacon)
	if(beacon_turf?.is_blocked_turf(TRUE))
		to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
		return
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You don't have enough space to teleport from here!</span>")
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("<span class='hierophant_warning'>[user] starts to glow faintly...</span>")
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 40, target = user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, TRUE)
		playsound(source,'sound/machines/airlockopen.ogg', 200, TRUE)
		if(!do_after(user, 3, target = user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, "<span class='warning'>The beacon is blocked by something, preventing teleportation!</span>")
			user.update_action_buttons_icon()
			beacon.icon_state = "hierophant_tele_off"
			return
		user.log_message("teleported self from [AREACOORD(source)] to [beacon]", LOG_GAME)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/t in RANGE_TURFS(1, source))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, .proc/teleport_mob, source, L, T, user)
		sleep(6) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	var/area/destination_area = turf_to_teleport_to.loc
	if(!turf_to_teleport_to || turf_to_teleport_to.is_blocked_turf(TRUE) || destination_area.area_flags & NOTELEPORT)
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades out!</span>")
	sleep(2)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message("<span class='hierophant_warning'>[M] fades in!</span>")
	if(user != M)
		log_combat(user, M, "teleported", null, "from [AREACOORD(source)]")

/obj/item/hierophant_club/pickup(mob/living/user)
	. = ..()
	blink.Grant(user, src)
	user.update_icons()

/obj/item/hierophant_club/dropped(mob/user)
	. = ..()
	blink.Remove(user)
	user.update_icons()

//Just some minor stuff
/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/PopulateContents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

/obj/item/skeleton_key
	name = "skeleton key"
	desc = "An artifact usually found in the hands of the natives of lavaland, which NT now holds a monopoly on."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "skeleton_key"
	w_class = WEIGHT_CLASS_SMALL

#undef HIEROPHANT_BLINK_RANGE
#undef HIEROPHANT_BLINK_COOLDOWN
