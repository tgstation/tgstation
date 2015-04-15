
//Defines mapped to the values of:
// /datum/sound/var/environment
//They point to byond preset settings for 3D sound environments
//See below for custom sound environments

#define SOUND_ENV_DEFAULT			-1
#define SOUND_ENV_GENERIC			0
#define SOUND_ENV_PADDED_CELL		1
#define SOUND_ENV_ROOM				2
#define SOUND_ENV_BATHROOM			3
#define SOUND_ENV_LIVINGROOM		4
#define SOUND_ENV_STONEROOM			5
#define SOUND_ENV_AUDITORIUM		6
#define SOUND_ENV_CONCERT_HALL		7
#define SOUND_ENV_CAVE				8
#define SOUND_ENV_ARENA				9
#define SOUND_ENV_HANGAR			10
#define SOUND_ENV_CARPETTED_HALLWAY	11
#define SOUND_ENV_HALLWAY			12
#define SOUND_ENV_STONE_CORRIDOOR	13
#define SOUND_ENV_ALLEY				14
#define SOUND_ENV_FOREST			15
#define SOUND_ENV_CITY				16
#define SOUND_ENV_MOUNTAINS			17
#define SOUND_ENV_QUARRY			18
#define SOUND_ENV_PLAIN				19
#define SOUND_ENV_PARKING_LOT		20
#define SOUND_ENV_SEWER_PIPE		21
#define SOUND_ENV_UNDERWATER		22
#define SOUND_ENV_DRUGGED			23
#define SOUND_ENV_DIZZY				24
#define SOUND_ENV_PSYCHOTIC			25


///////////////////////////////
// CUSTOM SOUND ENVIRONMENTS //
///////////////////////////////

//For weirdos who know how to sound engineer, you can actually make custom environments:
/*

A 23-element list represents a custom environment with the following reverbration settings.
A null or non-numeric value for any setting will select its default.

1 EnvSize (1.0 to 100.0) default = 7.5
	environment size in meters
2 EnvDiffusion (0.0 to 1.0) default = 1.0
	environment diffusion
3 Room (-10000 to 0) default = -1000
	room effect level (at mid frequencies)
4 RoomHF (-10000 to 0) default = -100
	relative room effect level at high frequencies
5 RoomLF (-10000 to 0) default = 0
	relative room effect level at low frequencies
6 DecayTime (0.1 to 20.0) default = 1.49
	reverberation decay time at mid frequencies
7 DecayHFRatio (0.1 to 2.0) default = 0.83
	high-frequency to mid-frequency decay time ratio
8 DecayLFRatio (0.1 to 2.0) default = 1.0
	low-frequency to mid-frequency decay time ratio
9 Reflections (-10000 to 1000) default = -2602
	early reflections level relative to room effect
10 ReflectionsDelay (0.0 to 0.3) default = 0.007
	initial reflection delay time
11 Reverb (-10000 to 2000) default = 200
	late reverberation level relative to room effect
12 ReverbDelay (0.0 to 0.1) default = 0.011
	late reverberation delay time relative to initial reflection
13 EchoTime (0.075 to 0.250) default = 0.25
	echo time
14 EchoDepth (0.0 to 1.0) default = 0.0
	echo depth
15 ModulationTime (0.04 to 4.0) default = 0.25
	modulation time
16 ModulationDepth (0.0 to 1.0) default = 0.0
	modulation depth
17 AirAbsorptionHF (-100 to 0.0) default = -5.0
	change in level per meter at high frequencies
18 HFReference (1000.0 to 20000) default = 5000.0
	reference high frequency (hz)
19 LFReference (20.0 to 1000.0) default = 250.0
	reference low frequency (hz)
20 RoomRolloffFactor (0.0 to 10.0) default = 0.0
	like rolloffscale in System::set3DSettings but for reverb room size effect
21 Diffusion (0.0 to 100.0) default = 100.0
	Value that controls the echo density in the late reverberation decay.
22 Density (0.0 to 100.0) default = 100.0
	Value that controls the modal density in the late reverberation decay
23 Flags default = 63
	Bit flags that modify the behavior of above properties
	1 - 'EnvSize' affects reverberation decay time
	2 - 'EnvSize' affects reflection level
	4 - 'EnvSize' affects initial reflection delay time
	8 - 'EnvSize' affects reflections level
	16 - 'EnvSize' affects late reverberation delay time
	32 - AirAbsorptionHF affects DecayHFRatio
	64 - 'EnvSize' affects echo time
	128 - 'EnvSize' affects modulation time

*/