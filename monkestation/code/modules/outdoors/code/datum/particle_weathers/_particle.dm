/particles/weather
	spawning = 0
	var/wind = 0 //Left/Right maximum movement increase per tick
	var/max_spawning = 0 //Max spawner - Recommend you use this over Spawning, so severity can ease it in
	var/min_spawning = 0 //Weather should start with 0, but when easing, it will never go below this
	icon = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'


	spawning               = 0
	width                  = 800  // I think this is supposed to be in pixels, but it doesn't match bounds, so idk - 800x800 seems to prevent particle-less edges
	height                 = 800
	count                  = 4000 // 3000 particles
	//Set bounds to rough screensize + some extra on the side and top movement for "wind"
	bound1                 = list(-500, -256, -10)
	bound2                 = list(500, 500, 10)
	lifespan               = 285   // live for 30s max (fadein + lifespan + fade)
	fade                   = 10    // 1s fade out
	fadein				   = 5     // 0.5s fade in

	//Obnoxiously 3D -- INCREASE Z level to make them further away
	transform			   = list( 1, 0, 0,  0  ,
								   0, 1, 0,  0  ,
								   0, 0, 1, 1/10, //Get twice as Small every 10 Z
								   0, 0, 0,  1  )

//Animate particle effect to a severity
/particles/weather/proc/animate_severity(severity_mod)

	//If we have no severity, just stop spawning
	if(!severity_mod)
		spawning = 0
		return

	var/new_wind = wind * severity_mod * pick(-1,1) //Wind can go left OR right!
	var/new_spawning = max(min_spawning, max_spawning * severity_mod)

	//gravity might be x, xy, or xyz
	var/new_gravity = gravity
	if(length(new_gravity))
		new_gravity[1] = new_wind
	else
		new_gravity = list(new_wind)

	//The higher the severity, the faster the change - elastic easing for flappy wind
	gravity = new_gravity
	spawning = new_spawning
	//animate(src, gravity = new_gravity, spawning = new_spawning, time = 1/severity_mod * 10, easing=ELASTIC_EASING)


//Rain - goes down
/particles/weather/rain
	icon_state             = "drop"
	color                  = "#ccffff"
	position               = generator("box", list(-500, -256, 0), list(400, 500, 0))
	grow			       = list(-0.01, -0.01)
	gravity                = list(0, -12, 0.5)
	drift                  = generator("circle", 0, 1) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	transform 			   = null // Rain is directional - so don't make it "3D"
	//Weather effects, max values
	max_spawning           = 200
	min_spawning           = 50
	wind                   = 4
	spin                   = 0 // explicitly set spin to 0 - there is a bug that seems to carry generators over from old particle effects

/particles/weather/rain/storm
	color                  = "#9ad0ff"
	gravity                = list(0, -18, 1)

	max_spawning           = 400
	min_spawning           = 100
	wind                   = 6


//Snow - goes down and swirls
/particles/weather/snow
	icon_state             = list("cross" = 2, "snow_1" = 5, "snow_2" = 2, "snow_3" = 2,)
	color                  = "#ffffff"
	position               = generator("box", list(-500, -256, 5), list(500, 500, 0))
	spin                   = generator("num", -10, 10)
	gravity                = list(0, -2, 0.1)
	drift                  = generator("circle", 0, 3) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	max_spawning           = 100
	min_spawning           = 20
	wind                   = 2

/particles/weather/snowstorm
	icon_state             = list("cross"=2, "snow_1"=5, "snow_2"=2, "snow_3"=2,)
	color                  = "#ffffff"
	position               = generator("box", list(-500,-256,5), list(500,500,0))
	spin                   = generator("num",-10,10)
	gravity                = list(0, -2, 0.1)
	drift                  = generator("circle", 0, 3.5) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	max_spawning           = 150
	min_spawning           = 50
	wind                   = 4


//Dust - goes sideways and swirls
/particles/weather/dust
	icon_state             = list("dot"=5, "cross"=1)
	gradient               = list(0,"#422a1de3",10,"#853e1be3","loop")
	color                  = 0
	color_change		   = generator("num",0,3)
	spin                   = generator("num",-5,5)
	position               = generator("box", list(-500,-256,0), list(500,500,0))
	gravity                = list(-5 -1, 0.1)
	drift                  = generator("circle", 0, 3) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	max_spawning           = 80
	min_spawning           = 20
	wind                   = 10


//Rads - goes fucking everywhere
/particles/weather/rads
	icon_state              = list("dot"=5, "cross"=1)

	gradient               = list(0,"#54d832",1,"#1f2720",2,"#aad607",3,"#5f760d",4,"#484b3f","loop")
	color                  = 0
	color_change		   = generator("num",-5,5)
	position               = generator("box", list(-500,-256,0), list(500,500,0))
	gravity                = list(-5 -1, 0.1)
	drift                  = generator("circle", 0, 5) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	max_spawning           = 80
	min_spawning           = 20
	wind                   = 10
