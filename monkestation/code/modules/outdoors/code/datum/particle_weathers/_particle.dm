/particles/weather
	spawning = 0
	var/wind = 0 //Left/Right maximum movement increase per tick
	var/maxSpawning = 0 //Max spawner - Recommend you use this over Spawning, so severity can ease it in
	var/minSpawning = 0 //Weather should start with 0, but when easing, it will never go below this
	icon = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'


	spawning = 0
	width                  = 800  // I think this is supposed to be in pixels, but it doesn't match bounds, so idk - 800x800 seems to prevent particle-less edges
	height                 = 800
	count                  = 3000 // 3000 particles
	//Set bounds to rough screensize + some extra on the side and top movement for "wind"
	bound1                 = list(-500,-256,-10)
	bound2                 = list(500,500,10)
	lifespan               = 285   // live for 30s max (fadein + lifespan + fade)
	fade                   = 10    // 1s fade out
	fadein				   = 5     // 0.5s fade in

	//Obnoxiously 3D -- INCREASE Z level to make them further away
	transform			   = list( 1, 0, 0,  0  ,
								   0, 1, 0,  0  ,
								   0, 0, 1, 1/10, //Get twice as Small every 10 Z
								   0, 0, 0,  1  )

//Animate particle effect to a severity
/particles/weather/proc/animateSeverity(severityMod)

	//If we have no severity, just stop spawning
	if(!severityMod)
		spawning = 0
		return

	var newWind = wind * severityMod * pick(-1,1) //Wind can go left OR right!
	var newSpawning = max(minSpawning, maxSpawning * severityMod)

	//gravity might be x, xy, or xyz
	var/newGravity = gravity
	if(length(newGravity))
		newGravity[1] = newWind
	else
		newGravity = list(newWind)

	//The higher the severity, the faster the change - elastic easing for flappy wind
	gravity = newGravity
	spawning = newSpawning
	// animate(src, gravity=newGravity, spawning=newSpawning, time=1/severity * 10, easing=ELASTIC_EASING)
