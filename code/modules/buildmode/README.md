# Buildmode

## Code layout

### Buildmode

Manager for buildmode modes. Contains logic to manage switching between each mode, and presenting a suitable user interface.

### Effects

Special graphics used by buildmode modes for user interface purposes.

### Buildmode Mode

Implementer of buildmode behaviors.

Existing varieties:

- Basic

  **Description**:

  Allows creation of simple structures consisting of floors, walls, windows, and airlocks.

  **Controls**:

  - _Left click a turf_:

    "Upgrades" the turf based on the following rules below:

    - Space -> Tiled floor
    - Simulated floor -> Regular wall
    - Wall -> Reinforced wall

  - _Right click a turf_:

    "Downgrades" the turf based on the following rules below:

    - Reinforced wall -> Regular wall
    - Wall -> Tiled floor
    - Simulated floor -> Space

  - _Right click an object_:

    Deletes the clicked object.

  - _Alt+Left click a location_:

    Places an airlock at the clicked location.

  - _Ctrl+Left click a location_:

    Places a window at the clicked location.

- Advanced

  **Description**:

  Creates an instance of a configurable atom path where you click.

  **Controls**:

  - _Right click on the mode selector_:

    Choose a path to spawn.

  - _Left click a location_ (requires chosen path):

    Place an instance of the chosen path at the location.

  - _Right click an object_:

    Delete the object.

- Fill

  **Description**:

  Creates an instance of an atom path on every tile in a chosen region.

  With a special control input, instead deletes everything within the region.

  **Controls**:

  - _Right click on the mode selector_:

    Choose a path to spawn.

  - _Left click on a region_ (requires chosen path):

    Fill the region with the chosen path.

  - _Alt+Left click on a region_:

    Deletes everything within the region.

  - _Right click during region selection_:

    Cancel region selection.

- Copy

  **Description**:

  Take an existing object in the world, and place duplicates with identical attributes where you click.

  May not always work nicely - "deep" variables such as lists or datums may malfunction.

  **Controls**:

  - _Right click an existing object_:

    Select the clicked object as a template.

  - _Left click a location_ (Requires a selected object as template):

    Place a duplicate of the template at the clicked location.

- Area Edit

  **Description**:

  Modifies and creates areas.

  The active area will be highlighted in yellow.

  **Controls**:

  - _Right click the mode selector_:

    Create a new area, and make it active.

  - _Right click an existing area_:

    Make the clicked area active.

  - _Left click a turf_:

    When an area is active, adds the turf to the active area.

- Var Edit

  **Description**:

  Allows for setting and resetting variables of objects with a click.

  If the object does not have the var, will do nothing and print a warning message.

  **Controls**:

  - _Right click the mode selector_:

    Choose which variable to set, and what to set it to.

  - _Left click an atom_:

    Change the clicked atom's variables as configured.

  - _Right click an atom_:

    Reset the targeted variable to its original value in the code.

- Map Generator

  **Description**:

  Fills rectangular regions with algorithmically generated content. Right click during region selection to cancel.

  See the `procedural_mapping` module for the generators themselves.

  **Controls**:

  - _Right-click on the mode selector_:

    Select a map generator from all the generators present in the codebase.

  - _Left click two corners of an area_:

    Use the generator to populate the region.

  - _Right click during region selection_:

    Cancel region selection.

- Throwing

  **Description**:

  Select an object with left click, and right click to throw it towards where you clicked.

  **Controls**:

  - _Left click on a movable atom_:

    Select the atom for throwing.

  - _Right click on a location_:

    Throw the selected atom towards that location.

- Boom

  **Description**:

  Make explosions where you click.

  **Controls**:

  - _Right click the mode selector_:

    Configure the explosion size.

  - _Left click a location_:

    Cause an explosion where you clicked.
