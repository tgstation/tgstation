#define HEAVY_SMITE "heavy"
#define LIGHT_SMITE "light"

/datum/action/cooldown/spell/pointed/smite
	name = "Smite"
	desc = "A spell to strike down your foes from the heavens."
	button_icon_state = "gib"
	sound = 'sound/magic/disintegrate.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS
	cast_range = 2

	invocation = "EI NATH!!"

	active_msg = "You prepare to smite your foe..."
	deactive_msg = "You dispel your power."

	//what type of smites should we be forced to used, if unset then pick normally
	var/forced_smite_type
	//what smite type is selected for our currenting casting, have to put it here so we can reference between procs
	var/smite_type
	//list of smites that have a high effect on the target, if a smite is not in one of these lists then it cannot be picked(besides rod which is unique)
	var/list/heavy_smites = list(/datum/smite/berforate, /datum/smite/bloodless, /datum/smite/boneless, /datum/smite/brain_damage, /datum/smite/bread, /datum/smite/bsa, \
								 /datum/smite/fireball, /datum/smite/gib, /datum/smite/lightning, /datum/smite/nugget, /datum/smite/puzzgrid, /datum/smite/puzzle)
	//list of smites that have a low effect on the target
	var/list/light_smites = list(/datum/smite/bad_luck, /datum/smite/curse_of_babel, /datum/smite/fake_bwoink, /datum/smite/fat, /datum/smite/ghost_control, /datum/smite/immerse, \
								 /datum/smite/knot_shoes, /datum/smite/ocky_icky, /datum/smite/scarify)

/datum/action/cooldown/spell/pointed/smite/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on)) //im just gonna make this only work on carbon mobs
		cast_on.balloon_alert(owner, "Can only be cast on advanced life forms!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/smite/cast(atom/cast_on)
	. = ..()
	smite_type = forced_smite_type
	if(!smite_type)
		if(prob(70))
			smite_type = HEAVY_SMITE
		else
			smite_type = LIGHT_SMITE

	var/datum/smite/picked_smite
	if(smite_type == HEAVY_SMITE)
		if(prob(7))
			picked_smite = /datum/smite/rod //very high impact so it should be rare
		else
			picked_smite = pick(heavy_smites)
	else
		picked_smite = pick(light_smites)

	switch(picked_smite) //subtype vars moment, I really want a better way to do this
		if(/datum/smite/bad_luck)
			var/datum/smite/bad_luck/luck_smite = new picked_smite
			luck_smite.permanent = TRUE
			do_smite(luck_smite, cast_on)
		if(/datum/smite/berforate)
			var/datum/smite/berforate/shoot_smite = new picked_smite
			shoot_smite.hatred = "A lot"
			do_smite(shoot_smite, cast_on)
		if(/datum/smite/curse_of_babel)
			var/datum/smite/curse_of_babel/babel_smite = new picked_smite
			babel_smite.duration = 5 MINUTES
			do_smite(babel_smite, cast_on)
		if(/datum/smite/puzzgrid)
			var/datum/smite/puzzgrid/puzz_smite = new picked_smite
			puzz_smite.gib_on_loss = TRUE
			do_smite(puzz_smite, cast_on)
		else
			picked_smite = new picked_smite
			do_smite(picked_smite, cast_on)

/datum/action/cooldown/spell/pointed/smite/after_cast(atom/cast_on)
	. = ..()
	if(smite_type == LIGHT_SMITE) //these should give a lower cooldown as they dont do as much
		next_use_time -= cooldown_time/2
	smite_type = null

/datum/action/cooldown/spell/pointed/smite/proc/do_smite(datum/smite/real_smite, mob/living/carbon/target)
	real_smite.should_log = FALSE
	real_smite.effect(owner.client, target)

/datum/action/cooldown/spell/pointed/smite/light //used for clown casting and admemery
	name = "\"Harmless\" Smite"
	desc = "For those who just want to watch the world burn."
	cooldown_time = 20 SECONDS
	forced_smite_type = LIGHT_SMITE
	spell_max_level = 1

/datum/action/cooldown/spell/pointed/smite/light/New(Target)
	. = ..()
	light_smites += /datum/smite/puzzle

#undef HEAVY_SMITE
#undef LIGHT_SMITE
