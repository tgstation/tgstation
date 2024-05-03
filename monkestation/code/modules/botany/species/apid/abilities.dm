/datum/action/cooldown/spell/pointed/pollinate
	name = "Pollinate Crop"
	desc = "You try to pollinate a crop."
	button_icon = 'monkestation/icons/mob/simple/bees.dmi'
	button_icon_state = "pollen_sac"

	cooldown_time = 1 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/pollinate/before_cast(atom/cast_on)
	. = ..()
	if(!cast_on.GetComponent(/datum/component/plant_growing))
		on_deactivation(owner, refund_cooldown = TRUE)
		return

/datum/action/cooldown/spell/pointed/pollinate/cast(atom/cast_on)
	. = ..()
	var/datum/component/plant_growing/growing = cast_on.GetComponent(/datum/component/plant_growing)
	if(!growing)
		return
	SEND_SIGNAL(cast_on, COMSIG_TRY_POLLINATE)

	var/mob/living/carbon/human/human = owner
	var/datum/species/apid/apid = human.dna.species
	apid.adjust_honeycount(10)
	to_chat(owner, span_notice("You pollinate the [cast_on]."))

	for(var/item as anything in growing.managed_seeds)
		var/obj/item/seeds/seed = growing.managed_seeds[item]
		if(!seed)
			continue
		switch(apid.current_stat)
			if("potency")
				seed.adjust_potency(rand(10, 20))
			if("yield")
				seed.adjust_yield(rand(5, 10))
			if("lifespan")
				seed.adjust_lifespan(rand(10, 20))
			if("lifespan")
				seed.adjust_lifespan(rand(10, 20))
			if("endurance")
				seed.adjust_endurance(rand(10, 20))
			if("maturation")
				seed.adjust_maturation(rand(10, 20))
			if("production")
				seed.adjust_production(rand(10, 20))


/particles/pollen
	icon = 'monkestation/code/modules/botany/icons/pollen.dmi'
	icon_state = "pollen"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)

/datum/action/cooldown/spell/change_pollination_stat
	name = "Change Stat"
	desc = "Changes the stat you and your bees increase on plants."
	button_icon = 'monkestation/icons/mob/simple/bees.dmi'
	button_icon_state = "pollen_sac"


	cooldown_time = 1 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/change_pollination_stat/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/human = owner
	var/datum/species/apid/apid = human.dna.species

	var/choice = tgui_input_list(human, "Choose the new stat.", "Stat Change", list("potency", "yield", "lifespan", "endurance", "maturation", "production"))
	if(!choice)
		return
	apid.current_stat = choice
	apid.owned_hive?.current_stat = choice
