/mob/living/basic/mouse
	var/disease_chance = 50

/mob/living/basic/mouse/Initialize(mapload, tame, new_body_color)
	. = ..()
	immune_system = new(src)

	if(prob(disease_chance))
		var/virus_choice = pick(subtypesof(/datum/disease/advanced)- typesof(/datum/disease/advanced/premade))
		var/list/anti = list(
			ANTIGEN_BLOOD	= 2,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
		)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 2,
			EFFECT_DANGER_ANNOYING	= 2,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 2,
			EFFECT_DANGER_DEADLY	= 0,
		)
		var/datum/disease/advanced/disease = new virus_choice
		disease.makerandom(list(50,90),list(10,100),anti,bad,src)
		diseases = list()
		diseases += disease
		disease.after_add()
		src.med_hud_set_status()
		disease.log += "<br />[ROUND_TIME()] Infected [src]"

		log_virus("[key_name(src)] was infected by virus: [disease.admin_details()] at [loc_name(loc)]")
		disease.origin = "Rat"
		disease.AddToGoggleView(src)

/mob/living/basic/mouse/Destroy()
	. = ..()
	if(src in GLOB.infected_contact_mobs)
		GLOB.infected_contact_mobs -= src
	QDEL_NULL(immune_system)

/mob/living/basic/mouse/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/reagent_containers/syringe))
		return
	if(!do_after(user, 1.5 SECONDS, src))
		return
	var/obj/item/reagent_containers/syringe/I = attacking_item
	var/list/data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"viruses"=list(),"immunity"=list())
	if(diseases)
		data["viruses"] |= diseases
	data["immunity"] = immune_system.GetImmunity()
	I.reagents.add_reagent(/datum/reagent/blood, I.volume, data)

/mob/living/basic/mouse/Life(seconds_per_tick, times_fired)
	. = ..()
	handle_virus_updates(seconds_per_tick)
