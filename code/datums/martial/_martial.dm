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

/datum/martial_art/proc/reset_streak(mob/living/new_target)
	current_target = new_target
	streak = ""

/datum/martial_art/proc/teach(mob/living/owner, make_temporary=FALSE)
	if(!istype(owner) || !owner.mind)
		return FALSE
	if(owner.mind.martial_art)
		if(make_temporary)
			if(!owner.mind.martial_art.allow_temp_override)
				return FALSE
			store(owner.mind.martial_art, owner)
		else
			owner.mind.martial_art.on_remove(owner)
	else if(make_temporary)
		base = owner.mind.default_martial_art
	if(help_verb)
		add_verb(owner, help_verb)
	owner.mind.martial_art = src
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/old, mob/living/owner)
	old.on_remove(owner)
	if (old.base) //Checks if old is temporary, if so it will not be stored.
		base = old.base
	else //Otherwise, old is stored.
		base = old

/datum/martial_art/proc/remove(mob/living/owner)
	if(!istype(owner) || !owner.mind || owner.mind.martial_art != src)
		return
	on_remove(owner)
	if(base)
		base.teach(owner)
	else
		var/datum/martial_art/default = owner.mind.default_martial_art
		default.teach(owner)

/datum/martial_art/proc/on_remove(mob/living/owner)
	if(help_verb)
		remove_verb(owner, help_verb)
	return

///Gets called when a projectile hits the owner. Returning anything other than BULLET_ACT_HIT will stop the projectile from hitting the mob.
/datum/martial_art/proc/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
	return BULLET_ACT_HIT
