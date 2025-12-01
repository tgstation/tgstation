
/datum/action/cooldown/spell/summon_mob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	button_icon_state = "summons"

	school = SCHOOL_CONJURATION
	cooldown_time = 10 SECONDS

	invocation = "JE'VES?"

	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	spell_max_level = 0 //cannot be improved

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 0

	///Weakref to the summonable mob.
	var/datum/weakref/summon_weakref
	///Are we already summoning a mob?
	var/summoning_servant = FALSE
	///Have we selected a mob to be our servant?
	var/selected_summon = FALSE
	///What do we call our servant?
	var/servant_title = "Servant"

/datum/action/cooldown/spell/summon_mob/Grant(mob/grant_to)
	. = ..()
	owner.balloon_alert(owner, "conjuring a new [servant_title]...")
	find_servant()

/datum/action/cooldown/spell/summon_mob/before_cast(mob/living/invoker, feedback)
	. = ..()
	if(!selected_summon)
		if(summoning_servant)
			owner.balloon_alert(owner, "still conjuring!")
			return SPELL_CANCEL_CAST
		owner.balloon_alert(owner, "conjuring [servant_title]...")
		find_servant()
		return SPELL_CANCEL_CAST

	var/mob/living/to_summon = summon_weakref?.resolve()

	if(QDELETED(to_summon))
		to_chat(owner, span_warning("You can't seem to summon your [servant_title] - it seems they've vanished from reality, or never existed in the first place..."))
		return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/summon_mob/cast()
	. = ..()

	var/mob/living/to_summon = summon_weakref?.resolve()

	to_summon.visible_message(span_alert("[to_summon] suddenly vanishes into thin air!"), span_alert("You have been summoned to serve!"), span_hear("You hear something teleport away from nearby, off to serve..."))

	do_teleport(
		to_summon,
		get_turf(owner),
		precision = 1,
		asoundin = 'sound/effects/magic/wand_teleport.ogg',
		asoundout = 'sound/effects/magic/wand_teleport.ogg',
		channel = TELEPORT_CHANNEL_MAGIC,
	)

/datum/action/cooldown/spell/summon_mob/proc/find_servant()
	summoning_servant = TRUE //If we find a candidate, this stays true and locks in the summoned servant.
	var/list/candidate_list = SSpolling.poll_ghost_candidates("Do you want to play as [span_danger("[owner.real_name]'s")] [span_notice("[servant_title]")]?", check_jobban = ROLE_WIZARD, role = ROLE_WIZARD, poll_time = 15 SECONDS, alert_pic = owner, role_name_text = "[servant_title]")
	if(!length(candidate_list))
		summoning_servant = FALSE
		return

	var/mob/chosen_one = pick(candidate_list)
	if(!chosen_one) //Just in case!
		summoning_servant = FALSE
		return

	message_admins("[ADMIN_LOOKUPFLW(chosen_one)] was spawned as a Magical Servant ([servant_title])")
	var/turf/spawn_location = get_turf(owner)
	spawn_location.visible_message(span_userdanger("A Magical [servant_title] appears in a cloud of smoke!"))
	var/mob/living/carbon/human/human_servant = new(spawn_location)
	human_servant.equipOutfit(/datum/outfit/butler)
	do_smoke(0, holder = src, location = spawn_location)
	human_servant.PossessByPlayer(chosen_one.key)
	summon_weakref = WEAKREF(human_servant)

	var/datum/mind/servant_mind = new /datum/mind()
	var/datum/antagonist/magic_servant/servant_antagonist = new

	servant_mind.transfer_to(human_servant)
	servant_antagonist.setup_master(owner)
	servant_mind.add_antag_datum(servant_antagonist)
	selected_summon = TRUE

/datum/action/cooldown/spell/summon_mob/dice
	name = "Summon Dice Servant"
	sound = 'sound/machines/microwave/microwave-end.ogg'
	servant_title = "Dice Servant"

/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit/black_really
	neck = /obj/item/clothing/neck/tie/red/tied
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white
