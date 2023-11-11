/datum/action/cooldown/slasher/stalk_target
	name = "Stalk Target"
	desc = "Get a target to stalk, standing near them for 3 minutes will rip their soul from their body. YOU MUST PROTECT THEM FROM HARM."

	button_icon_state = "slasher_possession"

	cooldown_time = 5 MINUTES

/datum/action/cooldown/slasher/stalk_target/Activate(atom/target)
	. = ..()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == owner.mind)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue
		possible_targets += possible_target.current

	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	if(slasherdatum && slasherdatum.stalked_human)
		qdel(slasherdatum.stalked_human.tracking_beacon)

	var/mob/living/living_target = pick(possible_targets)
	var/mob/living/carbon/human/owner_human = owner
	if(!owner_human.team_monitor)
		owner_human.tracking_beacon = owner_human.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#00660e")
		owner_human.team_monitor = owner_human.AddComponent(/datum/component/team_monitor, "slasher", null, owner_human.tracking_beacon)

	living_target.tracking_beacon = living_target.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#660000")
	if(slasherdatum)
		slasherdatum.stalked_human = living_target
	owner_human.team_monitor.add_to_tracking_network(living_target.tracking_beacon)
	owner_human.team_monitor.show_hud(owner_human)
