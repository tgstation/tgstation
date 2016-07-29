
/obj/item/clothing/under/golem/coal
	name = "coal body"
	icon_state="golem_coal"

/obj/item/clothing/suit/golem/coal
	name="coal shell"
	icon_state="golem_coal"

/obj/item/clothing/shoes/golem/coal
	name="coal feet"
	icon_state="golem_coal"

/obj/item/clothing/mask/gas/golem/coal
	name = "coal face"
	icon_state="golem_coal"

/obj/item/clothing/gloves/golem/coal
	name = "coal hands"
	item_state="golem_coal"

/obj/item/clothing/head/space/golem/coal
	name = "coal head"
	icon_state="golem_coal"

/spell/targeted/flesh_to_coal
	name = "Flesh to Coal"
	desc = "This spell turns a single person into a coal golem slaved to the caster."

	school = "transmutation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES | SELECTABLE
	range = 3
	max_targets = 1
	invocation = "NAUGHTY"
	invocation_type = SpI_SHOUT
	amt_stunned = 5//just exists to make sure the statue "catches" them
	cooldown_min = 200 //100 deciseconds reduction per rank

	hud_state = "wiz_statue"

/spell/targeted/flesh_to_coal/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/carbon/human/H in targets)
		H.drop_all()
		H.dna.mutantrace = "coalgolem"
		H.real_name = text("Coal Golem ([rand(1, 1000)])")
		H.equip_to_slot_or_del(new /obj/item/clothing/under/golem/coal(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/golem/coal(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem/coal(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem/coal(H), slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem/coal(H), slot_gloves)
		//G.equip_to_slot_or_del(new /obj/item/clothing/head/space/golem(H), slot_head)
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = H.mind
		new_objective.target = user.mind
		new_objective.explanation_text = "Protect [user.real_name], the wizard."
		H.mind.objectives += new_objective
		ticker.mode.traitors += H.mind
		H.mind.special_role = "apprentice"
		to_chat(H, "You are a coal golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. Serve [user], and assist them in completing their goals at any cost.")

		if(ticker.mode.name == "sandbox")
			H.CanBuild()
			to_chat(H, "Sandbox tab enabled.")