//This isn't actually a subsystem. It exists solely to hold a game's round statistics, such as deaths.

var/client/chara = null //The client who killed the most people
var/client/frisk = null //The client who killed the least people
var/horn_honks = 0 //The amount of times a clown has honked a bike horn; non-clown honks don't count
var/total_slips = 0 //The amount of times someone has slipped
var/total_deaths = 0 //The amount of times someone has died
