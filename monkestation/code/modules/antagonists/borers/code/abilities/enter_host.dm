//to either get inside, or out, of a host
/datum/action/cooldown/borer/choosing_host
	name = "Inhabit/Uninhabit Host"
	cooldown_time = 10 SECONDS
	button_icon_state = "host"
	ability_explanation = "\
	Using this ability we can eighter enter or exit a host.\n\
	Whilst leaving a host, they cannot have sugar within them and we require to be carefull in order to not immediatelly get squished.\n\
	Going inside of a host will usually take 6 seconds if we are not a hivelord, we must take causion for the host to not move.\n\
	Whilst going inside of a host we require the following:\n\
	- they must not have one of us within them\n\
	- they must be of compatible species\n\
	- and they must not have helmets designed against us\n\
	"

/datum/action/cooldown/borer/choosing_host/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	//having a host means we need to leave them
	if(cortical_owner.human_host)
		if(cortical_owner.host_sugar())
			if(cortical_owner.human_host.stat != DEAD)
				owner.balloon_alert(owner, "cannot function with sugar in host")
				return
			// we have a host with sugar and our host is dead. Amazing fuckup
			owner.balloon_alert(owner, "Struggling to leave")
			to_chat(cortical_owner, span_userdanger("We struggle to leave our host, barelly able to due to the sugar in their blood no longer moving, this will take time..."))
			StartCooldown(30 SECONDS) // stay in place now
			sleep(30 SECONDS)

		owner.balloon_alert(owner, "detached from host")
		if(!(cortical_owner.upgrade_flags & BORER_STEALTH_MODE))
			to_chat(cortical_owner.human_host, span_notice("Something carefully tickles your inner ear..."))

		//log the interaction
		var/turf/human_turfone = get_turf(cortical_owner.human_host)
		var/logging_text = "[key_name(cortical_owner)] left [key_name(cortical_owner.human_host)] at [loc_name(human_turfone)]"
		cortical_owner.log_message(logging_text, LOG_GAME)
		cortical_owner.human_host.log_message(logging_text, LOG_GAME)

		var/obj/item/organ/internal/borer_body/borer_organ = locate() in cortical_owner.human_host.organs
		if(borer_organ)
			borer_organ.Remove(cortical_owner.human_host)

		cortical_owner.forceMove(human_turfone)
		cortical_owner.human_host = null
		REMOVE_TRAIT(cortical_owner, TRAIT_WEATHER_IMMUNE, "borer_in_host")

		StartCooldown()
		return

	//we dont have a host so lets inhabit one
	var/list/usable_hosts = list()
	for(var/mob/living/carbon/human/listed_human in range(1, cortical_owner))
		// no non-human hosts
		if(!ishuman(listed_human) || ismonkey(listed_human))
			to_chat(cortical_owner, span_warning("[listed_human] is not a human!"))
			continue
		// cannot have multiple borers (for now)
		if(listed_human.has_borer())
			to_chat(cortical_owner, span_warning("[listed_human] already has our sister within them!"))
			continue
		// hosts need to be organic
		if(!(listed_human.dna.species.inherent_biotypes & MOB_ORGANIC) && cortical_owner.organic_restricted)
			to_chat(cortical_owner, span_warning("[listed_human] has incompatible biology with us!"))
			continue
		// hosts NEED to be organic
		if(!(listed_human.mob_biotypes & MOB_ORGANIC) && cortical_owner.organic_restricted)
			to_chat(cortical_owner, span_warning("[listed_human] has incompatible biology with us!"))
			continue
		// hosts cannot be changelings unless we specify otherwise
		if(listed_human.mind)
			var/datum/antagonist/changeling/changeling = listed_human.mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling && cortical_owner.changeling_restricted)
				to_chat(cortical_owner, span_warning("[listed_human] has incompatible biology with us!"))
				continue
		// hosts cannot have bio protected headgear
		if(check_for_bio_protection(listed_human) == TRUE)
			to_chat(cortical_owner, span_warning("[listed_human] has too hard of a helmet to crawl inside of their ear!"))
			continue
		usable_hosts += listed_human

	//if the list of possible hosts is one, just go straight in, no choosing
	if(length(usable_hosts) == 1)
		enter_host(usable_hosts[1])
		return

	//if the list of possible host is more than one, allow choosing a host
	var/choose_host = tgui_input_list(cortical_owner, "Choose your host!", "Host Choice", usable_hosts)
	if(!choose_host)
		owner.balloon_alert(owner, "no target selected")
		return
	enter_host(choose_host)

/datum/action/cooldown/borer/choosing_host/proc/enter_host(mob/living/carbon/human/singular_host)
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(check_for_bio_protection(singular_host))
		owner.balloon_alert(owner, "target head too protected!")
		return
	if(singular_host.has_borer())
		owner.balloon_alert(owner, "target already occupied")
		return
	if(!do_after(cortical_owner, (((cortical_owner.upgrade_flags & BORER_FAST_BORING) && !(cortical_owner.upgrade_flags & BORER_HIDING)) ? 3 SECONDS : 6 SECONDS), target = singular_host))
		owner.balloon_alert(owner, "you and target must be still")
		return
	if(get_dist(singular_host, cortical_owner) > 1)
		owner.balloon_alert(owner, "target too far away")
		return
	cortical_owner.human_host = singular_host
	cortical_owner.forceMove(cortical_owner.human_host)
	if(!(cortical_owner.upgrade_flags & BORER_STEALTH_MODE))
		to_chat(cortical_owner.human_host, span_notice("A chilling sensation goes down your spine..."))

	cortical_owner.copy_languages(cortical_owner.human_host)

	var/obj/item/organ/internal/borer_body/borer_organ = new(cortical_owner.human_host)
	borer_organ.borer = owner
	borer_organ.Insert(cortical_owner.human_host)

	var/turf/human_turftwo = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] went into [key_name(cortical_owner.human_host)] at [loc_name(human_turftwo)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)

	ADD_TRAIT(cortical_owner, TRAIT_WEATHER_IMMUNE, "borer_in_host")
	StartCooldown()

/// Checks if the target's head is bio protected, returns true if this is the case
/datum/action/cooldown/borer/choosing_host/proc/check_for_bio_protection(mob/living/carbon/human/target)
	if(isobj(target.head))
		if(target.head.get_armor_rating(BIO) >= 100)
			return TRUE
	if(isobj(target.wear_mask))
		if(target.wear_mask.get_armor_rating(BIO) >= 100)
			return TRUE
	if(isobj(target.wear_neck))
		if(target.wear_neck.get_armor_rating(BIO) >= 100)
			return TRUE
	return FALSE
