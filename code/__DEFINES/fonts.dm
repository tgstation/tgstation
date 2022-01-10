//FONTS: Used by Paper, PhotoCopier, PDA's Notekeeper, NewsCaster, NewsPaper, ModularComputers (and PaperBin once a year).
/// Font used by regular pens
#define PEN_FONT "Verdana"
/// Font used by fancy pens
#define FOUNTAIN_PEN_FONT "Segoe Script"
/// Font used by crayons
#define CRAYON_FONT "Comic Sans MS"
/// Font used by printers
#define PRINTER_FONT "Times New Roman"
/// Font used when a player signs their name
#define SIGNFONT "Times New Roman"
/// Font used by charcoal pens
#define CHARCOAL_FONT "Candara"

//pda fonts
#define MONO "Monospaced"
#define VT "VT323"
#define ORBITRON "Orbitron"
#define SHARE "Share Tech Mono"

GLOBAL_LIST_INIT(pda_styles, sort_list(list(MONO, VT, ORBITRON, SHARE)))
