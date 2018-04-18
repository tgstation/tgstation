//The compiler got angry when I tried capitalising the defines so I've left them uncapitalised - sorry
//Stopped all this from being run because travis freaked out
/*
#define red_colour rgb(0, 0, 255)
#define green_colour rgb(0, 255, 0)
#define blue_colour rgb(255, 0, 0)
#define colour_alpha rgb(0,0,0)
#define colour_sum list(red_colour, green_colour, blue_colour, colour_alpha)
#define colour_sum_redux list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0) //This was the attempt at making inverted colours
#define colour_vibrant list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 1,1,1,0) //This was the attempt at vibrancy, by setting the colours to their normal values and adding the constant I thought I'd be able to stack the constant on top but... that didn't work :(

var/thenewcolour = rgb2hsl(red_colour)
var/vibrant_colour_sum_multiplier = 2
#define vibrant_summed colour_sum
*/

//None of the above is needed for this code to work but I'll leave it here in case someone finds a use for it

/datum/client_colour/vibrant
	colour = rgb(255,255,255) //This just changes everything to white - leaving it here in case someone wants to experiment or figures out how to do this one properly
	priority = INFINITY - 1 //Higher priority number = will override all other colour sets more

/datum/client_colour/inverted
	colour = list(rgb(0,0,255), rgb(0,255,0), rgb(255,0,0)) //For some reason changing the green causes weird things to happen so I can't change the green... yet
	priority = INFINITY - 2

/datum/client_colour/greyscale
	colour = list(rgb(80,80,80), rgb(80,80,80), rgb(80,80,80), rgb(0,0,0))
	priority = INFINITY - 4

/datum/client_colour/faded //This one isn't used yet in a trait but I left it here cause it looks pretty cool
	colour = list(rgb(255,85,85), rgb(85,255,85), rgb(85,85,255), rgb(0,0,0))
	priority = INFINITY - 3