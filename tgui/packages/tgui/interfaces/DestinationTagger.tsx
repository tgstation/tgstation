import { sortBy } from 'es-toolkit';
import { map } from 'es-toolkit/compat';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DestinationTaggerData = {
  locations: string[];
  currentTag: number;
};

/**
 * Info about destinations that survives being re-ordered.
 */
type DestinationInfo = {
  name: string;
  sorting_id: number;
};

/**
 * Sort destinations in alphabetical order,
 * and wrap them in a way that preserves what ID to return.
 * @param locations The raw, official list of destination tags.
 * @returns The alphetically sorted list of destinations.
 */
const sortDestinations = (locations: string[]): DestinationInfo[] => {
  return sortBy(
    map(
      locations,
      (name, index) =>
        ({
          name: name.toUpperCase(),
          sorting_id: index + 1,
        }) as DestinationInfo,
    ),
    [(dest) => dest.name],
  );
};

export const DestinationTagger = (props) => {
  const { act, data } = useBackend<DestinationTaggerData>();
  const { locations, currentTag } = data;

  return (
    <Window theme="retro" title="TagMaster 2.4" width={420} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={
                !currentTag
                  ? 'Please Select A Location'
                  : `Current Destination: ${locations[currentTag - 1]}`
              }
            >
              {sortDestinations(locations).map((location) => {
                return (
                  <Button.Checkbox
                    checked={currentTag === location.sorting_id}
                    height={2}
                    key={location.sorting_id}
                    onClick={() =>
                      act('change', { index: location.sorting_id })
                    }
                    width={15}
                  >
                    {location.name}
                  </Button.Checkbox>
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
