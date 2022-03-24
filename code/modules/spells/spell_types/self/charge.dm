/datum/action/cooldown/spell/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	button_icon_state = "charge"

	sound = 'sound/magic/charge.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	invocation = "DIRI CEL"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

/datum/action/cooldown/spell/charge/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/charge/cast(mob/living/cast_on)
	. = ..()
	var/atom/charged_item
	var/burnt_out = TRUE
	if(isliving(cast_on.pulling))
		var/mob/living/pulled_living = cast_on.pulling
		var/pulled_has_spells = FALSE

		for(var/datum/action/cooldown/spell/spell in pulled_living.actions)
			spell.next_use_time = world.time
			spell.UpdateButtonIcon()
			pulled_has_spells = TRUE

		if(pulled_has_spells)
			to_chat(pulled_living, span_notice("You feel raw magic flowing through you. It feels good!"))
		else
			to_chat(pulled_living, span_notice("You feel very strange for a moment, but then it passes."))
			burnt_out = TRUE
		charged_item = pulled_living

	if(!charged_item)
		for(var/obj/item in cast_on.held_items)
			if(istype(item, /obj/item/spellbook))
				to_chat(cast_on, span_danger("Glowing red letters appear on the front cover..."))
				to_chat(cast_on, span_warning("[pick(
					"NICE TRY BUT NO!",
					"CLEVER BUT NOT CLEVER ENOUGH!",
					"SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!",
					"CUTE! VERY CUTE!",
					"YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?"
				)]"))
				burnt_out = TRUE
				break

			else if(istype(item, /obj/item/book/granter/action/spell))
				var/obj/item/book/granter/action/spell/spell_granter = item
				if(spell_granter.uses >= INFINITY - 2000) // What're the odds someone uses 2000 uses of an infinite use book?
					to_chat(cast_on, span_notice("This book is infinite use and can't be recharged, \
						yet the magic has improved the book somehow..."))
					burnt_out = TRUE
					spell_granter.pages_to_mastery--
					break

				if(prob(80))
					cast_on.dropItemToGround(spell_granter, TRUE)
					spell_granter.visible_message(span_warning("[spell_granter] catches fire and burns to ash!"))
					new /obj/effect/decal/cleanable/ash(spell_granter.drop_location())
					qdel(spell_granter)

				else
					spell_granter.uses++
					charged_item = spell_granter

				break

			else if(istype(item, /obj/item/gun/magic))
				var/obj/item/gun/magic/staff = item
				if(prob(80) && !staff.can_charge)
					staff.max_charges--
				if(staff.max_charges <= 0)
					staff.max_charges = 0
					burnt_out = TRUE
				staff.charges = staff.max_charges

				if(istype(item, /obj/item/gun/magic/wand) && staff.max_charges != 0)
					var/obj/item/gun/magic/wand = item
					wand.icon_state = initial(wand.icon_state)

				staff.recharge_newshot()
				charged_item = staff
				break

			else if(istype(item, /obj/item/stock_parts/cell))
				burnt_out = charge_cell(item)
				charged_item = item
				break

			else if(item.contents)
				for(var/obj/thing in item.contents)
					if(istype(thing, /obj/item/stock_parts/cell))
						burnt_out = charge_cell(thing)
						if(istype(thing.loc, /obj/item/gun))
							var/obj/item/gun/gun_loc = thing.loc
							gun_loc.process_chamber()
						thing.update_appearance()
						charged_item = item
						break

	if(QDELETED(charged_item))
		to_chat(cast_on, span_notice("You feel magical power surging through your hands, but the feeling rapidly fades..."))
	else if(burnt_out)
		to_chat(cast_on, span_warning("[charged_item] doesn't seem to be reacting to the spell!"))
	else
		to_chat(cast_on, span_notice("[charged_item] suddenly feels very warm!"))

/// Returns TRUE if the charge burnt the cell out, FALSE otherwise
/datum/action/cooldown/spell/charge/proc/charge_cell(obj/item/stock_parts/cell/to_charge)
	if(prob(80))
		to_charge.maxcharge -= 200
	if(to_charge.maxcharge <= 1) //Div by 0 protection
		to_charge.maxcharge = 1
		return TRUE

	to_charge.charge = to_charge.maxcharge
	return FALSE
