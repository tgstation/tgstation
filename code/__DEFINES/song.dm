#define MUSICIAN_HEARCHECK_MINDELAY 4
#define MUSIC_MAXLINES 1000
#define MUSIC_MAXLINECHARS 300

#define BPM_TO_TEMPO_SETTING(value) (600 / round(value, 1))

//Return values of song/should_stop_playing()

///When the song should stop being played
#define STOP_PLAYING 1
///Will ignore the instrument checks and play the song anyway.
#define IGNORE_INSTRUMENT_CHECKS 2

///it's what monkeys play!
#define MONKEY_SONG "BPM: 200\nC4/0,14,C,A4-F2,F3,A3,F-F2,A-F,F4,G4,F,D4-Bb2-G2\nD3,G3,D-G2,G3-G2,D,D4-G3,D,B4-B2,G,B3,G-B2,B3-B2\nG4,A4,G,E4-C3,E3,G3,E-C,G-C,E,E4-G,E,C5-E-A3,C4\nA-E3,C,E4-C3,A4-C4,B4-A3-A2,C5-C4,D5-F-B3,D4,B-F3\nD,F4-D3,D4,F-B-B2,G4-D,A4-C-F3,F,C/2,B3/2,A3-C3/2\nB/2,C4,E-C3,F4,G-C,F-F3,F-C,C4/2,B/2,A-A2/2,G3/2\nF/I"
///VENOM VENOM VENOM
#define VENOM_SONG "BPM: 400\nF#5-F#-F#-D-B2-F#-B-F#-D,D5-D-D-D-D-D-D-D\nD3-D/0.6,D-D/0.6,D-D/0.6\nE4-B-A#2-E3-G#-D-B-D#2-An-E4-E3-A#-G#-Dn3-B-B-An-D#2/0.6\nDn3-D/0.6,D-D,D5-D-D-D-D-D-D-D\nD-D-D-D3-D5-D3-D5-D-D-D/0.6\nD-D3-D5-D-D-D3-D5-D-D-D,D-D-D-D-D-D-D-D\nD3-Gn5-G-G-G-B-D-G-G-G-G-B/0.6\nG-G-G-G-D-D-G-G-G-G/0.6,G-G-G-G-D-D-G-G-G-G\nF#-F#-F#-F#-F#-F#-F#-F#,D-D/0.6\nE4-B-A-E3-A#-G#3-D-An-B-D#2-A#-An-E-E4-Dn3-G#-B-B-D#2-A/0.6\nDn3-D/0.6,D-D/0.6,D-D/0.6,D-B-D-B/0.6,D-D/0.6\nD-D/0.6,D-D/0.6,D-B-D-B/0.6,D-D/0.6,D-D/0.6\nD5-D-D3-D5-D-D3-D5-D-D-D/1.5\nD-D-D-D-D-D-D-D/1.5\nGn5-G-G-G-D3-B-D-G-G-G-G-B/0.6\nG-G-G-G-D-D-G-G-G-G/1.5,F#-F#-F#-F#-F#-F#/1.5\nE5-E-E-D-E-D-E-E-E-E/1.5\nF#-F#-F#-F#-F#-F#-F#-F#/1.5,D-D/0.6\nA#-E3-B-E4-D-G#3-D#2-D#-B-An-E-E3-A#-G#-Dn3-B-B-An-D#2-D#/0.6\nDn3-D/0.6,D-D/0.6,D-D/0.6,D-B-D-B/0.6,D-D/0.6\nD-D/0.6,D-D/0.6\nB-E-E4-A#-G#-D-D#2-D#-B-An-E3-A#-E4-Dn3-G#/3\nB-B-D#2-D#-An/0.6,Dn3-D/0.6,D-D/0.6\nD5-D-D-D3-D5-D3-D5-D-D-D/1.5\nD-D-D-D-D-D-D-D/1.5\nGn5-G-G-D3-G-B-D-G-G-G-G-B/0.6\nG-G-G-G-D-D-G-G-G-G/0.6,G-G-G-D-G-D-G-G-G-G/1.5\nF#-F#-F#-F#-F#-F#-F#-F#/1.5,D-D/0.6,D-B-D/3\nB/0.6,D-D/0.6,D-D/0.6,D-D/0.6,D-B-D/3,B/0.6\nD-D/0.6,D-D/0.6,D-D/0.6\nE-A#-E3-B-G#3-D-D#2-An-D#-B-A#-E-E4-G#-Dn3/3\nB-B-D#2-D#-An/0.6,Dn3-D/0.6,D-D/0.6\nD5-D3-D5-D-D-D3/3,D5-D-D-D/1.5,D-D-D-D/3\nD-D-D-D/1.5,D3-Gn5-G-G-G-B-D/3,G-G-G-G-B/0.6\nG-G-D-G-G-D/3,G-G-G-G/1.5,F#-F#-F#/3\nF#-F#-F#/1.5,E5-E-D-E-E-D/3,E-E-E-E/1.5\nF#-F#-F#-F#/3,F#-F#-F#-F#/1.5,D-D/0.6,D-B-D/3\nB/0.6,D-D/0.6,D-D/0.15"
