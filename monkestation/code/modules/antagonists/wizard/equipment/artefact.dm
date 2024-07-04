//magical chem sprayer
/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent! Warning: User not immune to effects."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 1200
	possible_transfer_amounts = list() //we dont want this to change transfer amounts

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	cycle_chems() //does this even need to be a proc
	. = ..()
	balloon_alert(user, "You change the reagent to [english_list(reagents.reagent_list)].")
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/examine()
	. = ..()
	. += "It currently holds [english_list(reagents.reagent_list)]."
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/proc/cycle_chems()
	reagents.clear_reagents()
	list_reagents = list(get_random_reagent_id_unrestricted() = volume)
	reagents.add_reagent_list(list_reagents)
	return

//reactive talisman
#define REACTION_COOLDOWN_DURATION 10 SECONDS
/obj/item/clothing/neck/neckless/wizard_reactive //reactive armor for wizards that casts a spell when it reacts
	name = "reactive talisman"
	desc = "A reactive talisman for the reactive mage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	hit_reaction_chance = 50
	//weakref to whomever the talisman is bound to
	var/datum/weakref/binding_owner
	//list of spells that can be cast by the talisman
	var/static/list/spell_list = list(/datum/action/cooldown/spell/rod_form, /datum/action/cooldown/spell/aoe/magic_missile,
									  /datum/action/cooldown/spell/emp/disable_tech, /datum/action/cooldown/spell/aoe/repulse/wizard,
								      /datum/action/cooldown/spell/timestop, /datum/action/cooldown/spell/forcewall, /datum/action/cooldown/spell/conjure/the_traps,
								      /datum/action/cooldown/spell/conjure/bee, /datum/action/cooldown/spell/conjure/simian,
								      /datum/action/cooldown/spell/teleport/radius_turf/blink)

	COOLDOWN_DECLARE(armor_cooldown) //unsure if I should use a world.time instead of this

/obj/item/clothing/neck/neckless/wizard_reactive/examine(mob/user)
	. = ..()
	if(binding_owner)
		var/mob/owner = binding_owner?.resolve()
		. += "It is currently bound to [owner.name]."
	else
		. += "It is currently unbound."

/obj/item/clothing/neck/neckless/wizard_reactive/attack_self(mob/user)
	. = ..()
	if(binding_owner)
		if(binding_owner?.resolve() == user)
			to_chat(user, "You start to unbind the talisman from yourself.")
			if(!do_after(user, 10 SECONDS))
				to_chat(user, "You fail to unbind the talisman from yourself.")
				return
			to_chat(user, "You unbind the talisman from yourself!")
			binding_owner = null
			return
		to_chat(user, "This talisman is already bound to someone else!.")
		return

	to_chat(user, "You start to bind the talisman to yourself.")
	if(!do_after(user, 10 SECONDS))
		to_chat(user, "You fail to bind the talisman to yourself.")
		return
	to_chat(user, "You bind the talisman to yourself!")
	binding_owner = WEAKREF(user)

/obj/item/clothing/neck/neckless/wizard_reactive/hit_reaction(mob/owner)
	if(!(prob(hit_reaction_chance)) || !(binding_owner))
		return FALSE
	if(!COOLDOWN_FINISHED(src, armor_cooldown))
		owner.visible_message("The [src] glows faintly for a second and then fades.")
		return FALSE
	return talisman_activation()

//do the casting of the spell
/obj/item/clothing/neck/neckless/wizard_reactive/proc/talisman_activation()
	var/mob/living/binding_ref = binding_owner?.resolve()
	var/datum/action/cooldown/spell/new_spell = pick(spell_list)

	COOLDOWN_START(src, armor_cooldown, REACTION_COOLDOWN_DURATION)
	new_spell = new new_spell(binding_ref.mind || binding_ref)
	new_spell.owner_has_control = FALSE
	new_spell.spell_requirements = ~SPELL_REQUIRES_WIZARD_GARB
	new_spell.Grant(binding_ref)

	if(!new_spell.cast(binding_ref))
		binding_ref.visible_message("The [src] glows brightly and then fades, looks like something went wrong!")
		qdel(new_spell)
		return

	binding_ref.visible_message("The [src] glows brightly and casts [new_spell.name]!")
	qdel(new_spell)

#undef REACTION_COOLDOWN_DURATION

//spellbook charges
//technically not used now, still useful for badminning though
/obj/item/spellbook_charge
	name = "power charge"
	desc = "An artifact that when inserted into a spellbook increases its power."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "flux"
	var/value = 1

/obj/item/spellbook_charge/ten
	name = "greater power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by a massive amount."
	value = 10

/obj/item/spellbook_charge/debug
	name = "debug power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by 100."
	value = 100

/obj/item/spellbook_charge/afterattack(obj/item/spellbook/book, mob/user)
	. = ..()
	if(!istype(book))
		to_chat(user, "<span class='warning'>The charge can only increase the power of spellbooks!</span>")
		return
	book.uses += value
	to_chat(user, "<span class='notice'>You increase the power of the spellbook by [value] points.</span>")
	qdel(src)
