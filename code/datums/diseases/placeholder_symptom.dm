/datum/disease/do_not_spawn_fournier/
	name = "Fournier's gangrenous necrosis"
	max_stages = 1
	spread_text = "Varies"
	spread_flags = SPECIAL
	cure_text = "Varies"
	agent = "Fournier gangrenous blood serums"
	viable_mobtypes = list(/mob/living/carbon/human)
	spread_flags = NON_CONTAGIOUS
	desc = "A rare, deadlier variety of Necrotizing Fasciitis. This variety rots away and deforms the victim. It's origin is unknown, and it's use is banned by Nanotrasen research."
	severity = DANGEROUS

/datum/disease/do_not_spawn_fournier/stage_act()
	..()
	affected_mob << "<span class='danger'>If you read this message, please contact an admin or a coder.</span>"
	cure()

/datum/disease/do_not_spawn_traitorheal/
	name = "Nuclei Apoptosis"
	max_stages = 1
	spread_text = "Varies"
	spread_flags = SPECIAL
	cure_text = "Varies"
	agent = "Nuclei Apoptosis infected blood"
	viable_mobtypes = list(/mob/living/carbon/human)
	spread_flags = NON_CONTAGIOUS
	desc = "An extremely unstable virus symptom which causes spontaneous Apoptosis - healing injuries, and purging toxins from the system. It's origin is unknown, and it's use is banned by Nanotrasen research."
	severity = DANGEROUS

/datum/disease/do_not_spawn_traitorheal/stage_act()
	..()
	affected_mob << "<span class='danger'>If you read this message, please contact an admin or a coder.</span>"
	cure()