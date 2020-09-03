import { useBackend } from '../backend';
import { Box, Button, Section, NumberInput } from '../components';
import { Window } from '../layouts';

export const PocketDimensionCustomizer = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Pocket Dimension Customizer"
      width={300}
      height={500}
      resizable>
      <Window.Content>
        <Box align="center" my={1}>
          <Box >
            Dimension Controls
          </Box>

          <Box>
            <Button
              content="Create Dimension"
              onClick={() => act('create_dimension')}
              tooltip={`DO THIS FIRST, causes some lag, may \
              crash the server in rare very laggy circumstances.`}
            />
          </Box>
          <Box>
            <Button
              content="Input Base turf"
              onClick={() => act('input_baseturf')}
              tooltip={`Select the default baseturf type used \
              by the dimension. Reminder that you have to collapse \
              the dimension after you do so to reset the turfs.`}
            />
          </Box>
          <Box>
            <Button
              content="Collapse/Scrap (Causes lag)"
              onClick={() => act('collapse_room')}
              tooltip={`Collapses and wipes the dimension \
              clean, can runtime in rare circumstances.`}
            />
          </Box>
          <Box>
            <Button
              content="Add Event"
              onClick={() => act('add_event')}
              tooltip={`Adds a new event`}
            />
          </Box>
          <Box>
            <Button
              content="Remove Event"
              onClick={() => act('remove_event')}
              tooltip={`Removes an Event`}
            />
          </Box>
          <Box>
            <Button
              content="Relink events (Causes Lag)"
              onClick={() => act('relink_event')}
              tooltip={`If you add new internal walls / new floors \
              use this to make sure all events are applied properly \
              with them. Causes some lag.`}
            />
          </Box>
        </Box>
        <Box align="center" my={1}>
          <Box>
            Room Controls
          </Box>

          <Box>
            <NumberInput
              value={data.size}
              tooltip={`Size of the room you want to create.`}
              unit="tiles"
              width="75px"
              minValue={2}
              maxValue={254}
              step={1}
              onChange={(e, value) => act('change_size', {
                size: value,
              })} />
          </Box>
          <Box>
            <Button
              content="Input Wall"
              onClick={() => act('input_wall')}
              tooltip={`Select the default wall type used by the dimension`}
            />
          </Box>
          <Box>
            <Button
              content="Input Floor"
              onClick={() => act('input_floor')}
              tooltip={`Select the default floor type used by the dimension`}
            />
          </Box>
          <Box>
            <Button
              content="Create Room"
              onClick={() => act('create_room')}
              tooltip={`Creates the room, make sure you have \
              selected the walls and floors and shit.`}
            />
          </Box>
          <Box>
            <Button
              content="Create Portals"
              onClick={() => act('create_portals')}
              tooltip={`Creats 2 portals in the pocket dimension\
              Use the buttons below to move them around.`}
            />
          </Box>
          <Box>
            <Button
              content="Move Portal 1 to here"
              onClick={() => act('move_portal1')}
              tooltip={`Moves Portal 1 to your location.`}
            />
          </Box>
          <Box>
            <Button
              content="Move Portal 2 to here"
              onClick={() => act('move_portal2')}
              tooltip={`Moves Portal 2 to your location.`}
            />
          </Box>
          <Box>
            <Button
              content="Move Yourself to Pocket Dimension"
              onClick={() => act('move_here')}
              tooltip={`Forcemoves your mob to the dimension.`}
            />
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
