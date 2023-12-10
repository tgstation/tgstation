/// A spell which gives you a clown item
/datum/action/cooldown/spell/conjure_item/clown_pockets
	name = "Acquire Clowning Implement"
	desc = "Pull an item out of your mysteriously expansive pants."
	button_icon = 'icons/obj/clothing/masks.dmi'
	button_icon_state = "clown"
	school = SCHOOL_CONJURATION
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS
	delete_old = FALSE
	delete_on_failure = FALSE
	/// Amount of time it takes you to rummage around in there
	var/cast_time = 3 SECONDS
	/// True while currently casting the spell
	var/casting = FALSE
	/// List of prank implements you can find in your pockets
	var/static/list/clown_items = list(
		/obj/item/bikehorn = 5,
		/obj/item/food/pie/cream = 5,
		/obj/item/grown/bananapeel = 5,
		/obj/item/toy/balloon = 3,
		/obj/item/toy/snappop = 5,
		/obj/item/toy/waterballoon = 5,
		/obj/item/assembly/mousetrap = 3,
		/obj/item/bikehorn/airhorn = 2,
		/obj/item/reagent_containers/cup/soda_cans/canned_laughter = 2,
		/obj/item/soap = 2,
		/obj/item/stack/tile/fakeice/loaded = 2,
		/obj/item/stack/tile/fakepit/loaded = 2,
		/obj/item/stack/tile/fakespace/loaded = 2,
		/obj/item/storage/box/heretic_box = 2,
		/obj/item/toy/balloon/corgi = 2,
		/obj/item/toy/foamblade = 2,
		/obj/item/toy/gun = 2,
		/obj/item/toy/spinningtoy = 2,
		/obj/item/toy/spinningtoy/dark_matter = 1,
		/obj/item/bikehorn/golden = 1,
		/obj/item/dualsaber/toy = 1,
		/obj/item/restraints/legcuffs/beartrap = 1,
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/toy/balloon/arrest = 1,
		/obj/item/toy/crayon/spraycan/lubecan = 1,
		/obj/item/toy/dummy = 1,
	)

/datum/action/cooldown/spell/conjure_item/clown_pockets/before_cast(atom/cast_on)
	. = ..()
	if (. & SPELL_CANCEL_CAST)
		return
	casting = TRUE
	cast_message(cast_on)
	if (!do_after(cast_on, cast_time, cast_on))
		casting = FALSE
		cast_on.balloon_alert(cast_on, "interrupted!")
		StartCooldown(2 SECONDS) // Prevents chat spam
		return . | SPELL_CANCEL_CAST
	casting = FALSE

/datum/action/cooldown/spell/conjure_item/clown_pockets/make_item(atom/caster)
	item_type = pick_weight(clown_items)
	return ..()

/datum/action/cooldown/spell/conjure_item/clown_pockets/post_created(atom/cast_on, atom/created)
	cast_on.visible_message(span_notice("[cast_on] pulls out [created]!"))

/datum/action/cooldown/spell/conjure_item/clown_pockets/can_cast_spell(feedback = TRUE)
	. = ..()
	if (!.)
		return
	if (casting)
		if (feedback)
			owner.balloon_alert(owner, "can't rummage harder!")
		return FALSE

/// Prints a funny message, exists so I can override it to print a different message
/datum/action/cooldown/spell/conjure_item/clown_pockets/proc/cast_message(mob/cast_on)
	cast_on.visible_message(span_notice("[cast_on] reaches far deeper into [cast_on.p_their()] pockets than you think \
		should be possible and starts rummaging around for something."))

/// Longer cooldown variant which is attached to the enchanted clown suit
/datum/action/cooldown/spell/conjure_item/clown_pockets/enchantment
	name = "Enchanted Clown Pockets"
	cooldown_time = 60 SECONDS

/datum/action/cooldown/spell/conjure_item/clown_pockets/enchantment/cast_message(mob/cast_on)
	cast_on.visible_message(span_notice("[cast_on] starts rummaging around in [cast_on.p_their()] comically large pants."))

/// Enchanted clown suit
/obj/item/clothing/under/rank/civilian/clown/magic
	name = "enchanted clown suit"

/obj/item/clothing/under/rank/civilian/clown/magic/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/conjure_item/clown_pockets/enchantment/big_pocket = new(src)
	add_item_action(big_pocket)

/// Enchanted plasmaman clown suit
/obj/item/clothing/under/plasmaman/clown/magic
	name = "enchanted clown envirosuit"

/obj/item/clothing/under/plasmaman/clown/magic/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/conjure_item/clown_pockets/enchantment/big_pocket = new(src)
	add_item_action(big_pocket)
