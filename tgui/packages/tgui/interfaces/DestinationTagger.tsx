import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Stack, Section, Button, Divider } from '../components';

/**
 * The sorting mode for the destination list. See sortDestinations()
 */
enum SortMode {
  SM_DEFAULT = "STANDARD", // By code
  SM_ALPHABETICAL = "ALPHABETICAL", // By name
}

type DestinationTaggerData = {
  locations: string[];
  currentTag: number;
  sortListMode: SortMode;
};

/**
 * Info about destinations that survives being re-ordered.
 */
type DestinationInfo = {
  name: string;
  sorting_id: number;
};

const sortDestinations
  = (locations: string[], mode: SortMode): DestinationInfo[] => {
    const clean_destinations = locations.map((name, index) => ({
      name: name.toUpperCase(),
      sorting_id: index + 1,
    }));

    switch (mode) {
      case SortMode.SM_ALPHABETICAL:
        return clean_destinations.sort((a, b) => a.name.localeCompare(b.name));
      default:
        return clean_destinations;
    }
  };

export const DestinationTagger = (props, context) => {
  const { act, data } = useBackend<DestinationTaggerData>(context);
  const { locations, currentTag, sortListMode } = data;

  return (
    <Window theme="retro" title="TagMaster 2.4" width={420} height={530}>
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
              }>
              {Object.values(SortMode).map((modeName) => {
                return (
                  <Button.Checkbox
                    checked={sortListMode === modeName}
                    height={2}
                    key={modeName}
                    onClick={() => act('sort_list', { mode: modeName })}
                    width={15} >
                    {modeName}
                  </Button.Checkbox>
                );
              })}

              <Divider />

              {sortDestinations(locations, sortListMode)
                .map((location) => {
                  return (
                    <Button.Checkbox
                      checked={currentTag === location.sorting_id}
                      height={2}
                      key={location.sorting_id}
                      onClick={() => act('change', { index: location.sorting_id })}
                      width={15}>
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
