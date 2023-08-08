//Gomble is a developer - not an artist

//current particles
// + shape




//Rain - goes down
/particles/weather/rain
	icon_state             = "drop"
	color                  = "#ccffff"
	position               = generator("box", list(-500,-256,0), list(400,500,0))
	grow			       = list(-0.01,-0.01)
	gravity                = list(0, -10, 0.5)
	drift                  = generator("circle", 0, 1) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	transform 			   = null // Rain is directional - so don't make it "3D"
	//Weather effects, max values
	maxSpawning            = 100
	minSpawning            = 50
	wind                   = 2
	spin                   = 0 // explicitly set spin to 0 - there is a bug that seems to carry generators over from old particle effects


//Snow - goes down and swirls
/particles/weather/snow
	icon_state             = list("cross"=2, "snow_1"=5, "snow_2"=2, "snow_3"=2,)
	color                  = "#ffffff"
	position               = generator("box", list(-500,-256,5), list(500,500,0))
	spin                   = generator("num",-10,10)
	gravity                = list(0, -2, 0.1)
	drift                  = generator("circle", 0, 3) // Some random movement for variation
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	maxSpawning           = 50
	minSpawning           = 10
	wind                  = 2


//Dust - goes sideways and swirls
/particles/weather/dust
	icon_state             = list("dot"=5, "cross"=1)
	gradient               = list(0,"#422a1de3",10,"#853e1be3","loop")
	color                  = 0
	color_change		   = generator("num",0,3)
	spin                   = generator("num",-5,5)
	position               = generator("box", list(-500,-256,0), list(500,500,0))
	gravity                = list(-5 -1, 0.1)
	drift                  = generator("circle", 0, 3) + generator("sphere", 0, 1) // Some random movement for variation - squashed sphere
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	maxSpawning           = 50
	minSpawning           = 20
	wind                  = 10


//Rads - goes fucking everywhere
/particles/weather/rads
	icon_state              = list("dot"=5, "cross"=1)

	gradient               = list(0,"#54d832",1,"#1f2720",2,"#aad607",3,"#5f760d",4,"#484b3f","loop")
	color                  = 0
	color_change		   = generator("num",-5,5)
	position               = generator("box", list(-500,-256,0), list(500,500,0))
	gravity                = list(-5 -1, 0.1)
	drift                  = generator("circle", 0, 5) + generator("sphere", 0, 1) // Some random movement for variation - squashed sphere
	friction               = 0.3  // shed 30% of velocity and drift every 0.1s
	//Weather effects, max values
	maxSpawning           = 50
	minSpawning           = 20
	wind                  = 10
