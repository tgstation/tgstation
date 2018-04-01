#define red_colour rgb(-255,127,128)
#define green_colour rgb(127,-255,128)
#define blue_colour rgb(128,127,-255)
#define colour_alpha rgb(-255,-255,-255)
#define colour_sum list(red_colour, green_colour, blue_colour, colour_alpha)
#define colour_sum_redux list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
#define colour_vibrant list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 1,1,1,0)

var/vibrant_colour_sum_multiplier = 2

#define vibrant_summed colour_sum

/datum/client_colour/vibrant
	colour = list(rgb(colour_sum,0,0), rgb(0,colour_sum,0), rgb(0,0,colour_sum))
	priority = 1 //Monochromacy will override this cause otherwise who knows what will happen

/datum/client_colour/inverted
	colour = list(colour_sum_redux)
	priority = 2

/datum/client_colour/faded
	colour = list(rgb(255,85,85), rgb(85,255,85), rgb(85,85,255), rgb(0,0,0))
	priority = 2 //This will override vibrant