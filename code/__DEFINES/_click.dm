//Defines file for byond click related parameters
//this is mostly for ease of use and for finding all the things that use say RIGHT_CLICK rather then just searching "right"

//Mouse buttons held
#define RIGHT_CLICK "right"
#define MIDDLE_CLICK "middle"
#define LEFT_CLICK "left"
#define BUTTON4 "xbutton1"
#define BUTTON5 "xbutton2"

///Mouse button that was just clicked/released
///if(modifiers[BUTTON] == LEFT_CLICK)
#define BUTTON "button"

//Keys held down during the mouse action
#define CTRL_CLICK "ctrl"
#define ALT_CLICK "alt"
#define SHIFT_CLICK "shift"

//Cells involved if using a Grid control
#define DRAG_CELL "drag-cell"
#define DROP_CELL "drop-cell"

//The button used for dragging (only sent for unrelated mouse up/down messages during a drag)
#define DRAG "drag"

//If the mouse is over a link in maptext, or this event is related to clicking such a link
#define LINK "link"

//Pixel coordinates relative to the icon's position on screen
#define VIS_X "vis-x"
#define VIS_Y "vis-y"

//Pixel coordinates within the icon, in the icon's coordinate space
#define ICON_X "icon-x"
#define ICON_Y "icon-y"

//Pixel coordinates in screen_loc format ("[tile_x]:[pixel_x],[tile_y]:[pixel_y]")
#define SCREEN_LOC "screen-loc"

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
/// Objects will ignore being clicked on regardless of their transparency (used in parallax, lighting effects, holograms, lasers, etc.)
#define MOUSE_OPACITY_TRANSPARENT 0
/// Objects will be clicked on if it is the topmost object and the pixel isn't transparent at the position of the mouse (default behavior for 99.99% of game objects)
#define MOUSE_OPACITY_ICON 1
/// Objects will be always be clicked on regardless of pixel transparency or other objects at that location (used in space vines, megafauna, storage containers)
#define MOUSE_OPACITY_OPAQUE 2
