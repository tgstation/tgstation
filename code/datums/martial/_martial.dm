/datum/martial_art
	var/name = "Martial Art"
	var/id = "" //ID, used by mind/has_martialart
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/help_verb
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
	var/smashes_tables = FALSE //If the martial art smashes tables when performing table slams and head smashes
	var/datum/weakref/holder //owner of the martial art
	var/display_combos = FALSE //shows combo meter if true

/datum/martial_art/proc/help_act(mob/living/A, mob/living/D)
	return FALSE

/datum/martial_art/proc/disarm_act(mob/living/A, mob/living/D)
	return FALSE

/datum/martial_art/proc/harm_act(mob/living/A, mob/living/D)
	return FALSE

/datum/martial_art/proc/grab_act(mob/living/A, mob/living/D)
	return FALSE

/datum/martial_art/proc/can_use(mob/living/L)
	return TRUE

/datum/martial_art/proc/add_to_streak(element, mob/living/D)
	if(D != current_target)
		reset_streak(D)
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	if (display_combos)
		var/mob/living/holder_living = holder.resolve()
		holder_living?.hud_used?.combo_display.update_icon_state(streak)

/datum/martial_art/proc/reset_streak(mob/living/new_target)
	current_target = new_target
	streak = ""
	var/mob/living/holder_living = holder.resolve()
	holder_living?.hud_used?.combo_display.update_icon_state(streak)

/datum/martial_art/proc/teach(mob/living/holder_living, make_temporary=FALSE)
	if(!istype(holder_living) || !holder_living.mind)
		return FALSE
	if(holder_living.mind.martial_art)
		if(make_temporary)
			if(!holder_living.mind.martial_art.allow_temp_override)
				return FALSE
			store(holder_living.mind.martial_art, holder_living)
		else
			holder_living.mind.martial_art.on_remove(holder_living)
	else if(make_temporary)
		base = holder_living.mind.default_martial_art
	if(help_verb)
		add_verb(holder_living, help_verb)
	holder_living.mind.martial_art = src
	holder = WEAKREF(holder_living)
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/old, mob/living/holder_living)
	old.on_remove(holder_living)
	if (old.base) //Checks if old is temporary, if so it will not be stored.
		base = old.base
	else //Otherwise, old is stored.
		base = old

/datum/martial_art/proc/remove(mob/living/holder_living)
	if(!istype(holder_living) || !holder_living.mind || holder_living.mind.martial_art != src)
		return
	on_remove(holder_living)
	if(base)
		base.teach(holder_living)
	else
		var/datum/martial_art/default = holder_living.mind.default_martial_art
		default.teach(holder_living)
	holder = null

/datum/martial_art/proc/on_remove(mob/living/holder_living)
	if(help_verb)
		remove_verb(holder_living, help_verb)
	return

///Gets called when a projectile hits the owner. Returning anything other than BULLET_ACT_HIT will stop the projectile from hitting the mob.
/datum/martial_art/proc/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
	return BULLET_ACT_HIT
