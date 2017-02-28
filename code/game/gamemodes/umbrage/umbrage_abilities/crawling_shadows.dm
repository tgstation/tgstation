//Assumes a stealthier form for thirty seconds or until cancelled.
/datum/action/innate/umbrage/crawling_shadows
	name = "Crawling Shadows"
	id = "crawling_shadows"
	desc = "Assumes a shadowy form that can crawl through vents and squeeze through the cracks in doors. You can also knock people out by attacking them."
	button_icon_state = "umbrage_simulacrum"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	psi_cost = 75
	lucidity_cost = 3 //Very powerful!
	blacklisted = 0

/datum/action/innate/umbrage/crawling_shadows/Activate()
	owner.visible_message("<span class='warning'>[owner] falls to the ground and transforms into a shadowy creature!</span>", "<span class='velvet bold'>sa iahz sepd zwng</span>\n\
	<span class='notice'>You assume a stealthier form.</span>")
	playsound(owner, 'sound/magic/devour_will_end.ogg', 50, 1)
	var/mob/living/simple_animal/hostile/crawling_shadows/CS = new(get_turf(owner))
	CS.umbrage_mob = owner
	return TRUE
