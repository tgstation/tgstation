/datum/techweb/specialized/autounlocking/biogenerator/proc/update_biogen(var/tier)
	design_autounlock_categories = tier
	switch(tier)
		if(1)
			design_autounlock_categories = list("initial")
		if(2)
			design_autounlock_categories = list("initial", "tier_two")
		if(3)
			design_autounlock_categories = list("initial", "tier_two", "tier_three")
		if(4)
			design_autounlock_categories = list("initial", "tier_two", "tier_three", "tier_four")
	autounlock()

/datum/techweb/specialized/autounlocking/biogenerator/New()
	return //Prevents a double update.
