import { useBackend, useLocalState } from '../backend';
import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { Box, Button, Section, Table, Flex } from '../components';
import { Window } from '../layouts';

export const AtmosControlPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const groups = flow([
    map((group, i) => ({
      ...group,
      // Generate a unique id
      id: group.area + i,
    })),
    sortBy(group => group.id),
  ])(data.excited_groups);
  return (
    <Window
      title="SSAir Control Panel"
      width={650}
      height={500}
      resizable>
      <Flex>
        <Flex.Item grow={1}>
          <Button
            onClick={() => act('toggle-freeze')}
            content={
              data.frozen === 1 ? 'Freeze Subsystem' : 'Unfreeze Subsystem'
            }
            color={data.frozen === 1 ? 'good' : 'bad'}
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box>
            Active Turfs: {data.active_size}
          </Box>
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box>
            Hotspots: {data.hotspots_size}
          </Box>
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box>
            Excited Groups: {data.excited_size}
          </Box>
        </Flex.Item>
        <Flex.Item grow={1}>
          <Button.Checkbox
            content="Display all"
            checked={data.show_all}
            onClick={() => act('toggle_show_all')}
          />
        </Flex.Item>
      </Flex>
      <Box fillPositionedParent top="21px">
        <Window.Content scrollable>
          <Table>
            <tr>
              <td>
                Area Name
              </td>
              <td>
                Breakdown Counter
              </td>
              <td>
                Dismantle Counter
              </td>
              <td>
                Tile Count
              </td>
              <td>
                Display
              </td>
            </tr>
            {groups.map((group, i) => (
              <tr key={group.id}>
                <td>
                  <Button
                    content={group.area}
                    onClick={() => act('move-to-target', {
                      spot: group.jump_to,
                    })}
                  />
                </td>
                <td>
                  {group.breakdown}
                </td>
                <td>
                  {group.dismantle}
                </td>
                <td>
                  {group.size}
                </td>
                <td>
                  <Button.Checkbox
                    checked={group.should_show}
                    onClick={() => act('toggle_show_group', {
                      group: group.group,
                    })}
                  />
                </td>
              </tr>
            ))}
          </Table>
        </Window.Content>
      </Box>
    </Window>
  );
};
