/mob/living
	var/adapt_size_to_health = 0 //activating this causes a mob to shrink as it loses health.
	var/lastadaptedhealth = null
	var/adapt_original_size_to_health = 0  //this causes a mob to start off bigger based on starting maxHealth, if var editing this in game you must call update_original_size_to_health() to update.

//This controls adapt_size_to_health
/mob/living/proc/resize_on_health()
	adapt_original_size_to_health = 0 //these 2 bits of code might break eachother
	if(stat != DEAD)
		if(!lastadaptedhealth && !isnum(lastadaptedhealth))
			lastadaptedhealth = health
		if(health != lastadaptedhealth)
			var/matrix/newtransform = new()
			newtransform = newtransform * max(health/maxHealth,0.3)
			transform = newtransform
			lastadaptedhealth = health
	else
		if(lastadaptedhealth != null)
			transform = initial(transform)
			lastadaptedhealth = null

//This controls adapt_original_size_to_health
/mob/living/proc/update_original_size_to_health()
	var/basehealth = initial(maxHealth)
	var/modifier = max(maxHealth/basehealth,0.33)
	var/matrix/newtransform = new()
	newtransform = newtransform * modifier
	transform = newtransform

//degenerals request to make mega arachnid use this.
/mob/living/simple_animal/hostile/jungle/mega_arachnid/random
	adapt_original_size_to_health = 1

/mob/living/simple_animal/hostile/jungle/mega_arachnid/random/Initialize()
	var/multiplier = round(rand(10,400)/100,0.01)
	maxHealth = round(maxHealth*multiplier,1)
	health = maxHealth
	. = ..()

/mob/living/simple_animal/hostile/jungle/mega_arachnid/Life()
	. = ..()
	if(maxHealth >= initial(maxHealth))
		ranged = initial(ranged)
		projectiletype = initial(projectiletype)
	else
		ranged = 0
		projectiletype = null
