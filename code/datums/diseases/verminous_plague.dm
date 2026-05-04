GLOBAL_LIST_INIT(cursed_vermin_by_stage, list(
	"1" = list( // Mostly harmless
		/mob/living/basic/butterfly = 1,
		/mob/living/basic/cockroach = 4,
		/mob/living/basic/cockroach/bloodroach = 1,
		/mob/living/basic/frog = 2,
		/mob/living/basic/mouse = 2,
		/mob/living/basic/snail = 2,
		/mob/living/basic/spider/maintenance = 1,
	),
	"2" = list( // Deal damage but not that dangerous
		/mob/living/basic/cockroach/bloodroach = 1,
		/mob/living/basic/cockroach/sewer = 1,
		/mob/living/basic/bee = 4,
		/mob/living/basic/frog = 3,
		/mob/living/basic/frog/crazy = 2,
		/mob/living/basic/mouse/rat = 4,
		/mob/living/basic/snail/angry = 2,
	),
	"3" = list( // More annoying
		/mob/living/basic/bee/toxin = 4,
		/mob/living/basic/cockroach/hauberoach = 3,
		/mob/living/basic/frog/crazy = 3,
		/mob/living/basic/mouse/rat = 3,
		/mob/living/basic/spider/growing/spiderling/hunter = 1,
	),
))

/// Makes you cough out rats, bugs, etc
/datum/disease/verminous_plague
	name = "Verminous Plague"
	desc = "You can't stop germinating small animals."
	form = "Affliction"
	agent = "Wizard's Curse"
	cure_text = "Exorcism"
	viable_mobtypes = list(/mob/living/carbon/human)
	cures = list(/datum/reagent/consumable/salt, /datum/reagent/water/holywater)
	spread_flags = DISEASE_SPREAD_CONTACT_SKIN
	severity = DISEASE_SEVERITY_MEDIUM
	max_stages = 3
	stage_prob = 2
	needs_all_cures = FALSE
	/// Chance to spawn something
	var/spawn_chance = 5

/datum/disease/verminous_plague/stage_act(seconds_per_tick)
	. = ..()
	if (SPT_PROB(spawn_chance, seconds_per_tick))
		spawn_mob()

/// Creates a pest
/datum/disease/verminous_plague/proc/spawn_mob()
	var/creating_type = pick_weight(GLOB.cursed_vermin_by_stage["[stage]"])
	var/mob/living/created = new creating_type(affected_mob.drop_location())
	if (QDELETED(created))
		return

	var/obj/item/organ/lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if (lungs && affected_mob.emote("cough"))
		affected_mob.visible_message(span_warning("[affected_mob] coughs out [created]!"))
		lungs.apply_organ_damage(stage * 2)
	else
		affected_mob.vomit(VOMIT_CATEGORY_BLOOD_STUNLESS | MOB_VOMIT_FORCE)
		affected_mob.visible_message(span_warning("[affected_mob] vomits out [created]!"))

	if (stage == 1 || !created.ai_controller)
		return

	created.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, affected_mob)
	created.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, affected_mob)

/datum/disease/verminous_plague/update_stage(new_stage)
	var/was_stage = stage
	. = ..()
	if (new_stage > was_stage)
		spawn_mob()
