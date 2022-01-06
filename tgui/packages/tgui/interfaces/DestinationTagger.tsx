import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Stack, Section, Button } from '../components';

type DestinationTaggerData = {
  locations: string[];
  currentTag: number;
};

export const DestinationTagger = (props, context) => {
  const { act, data } = useBackend<DestinationTaggerData>(context);
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
              }>
              {locations.map((location, index) => {
                return (
                  <Button.Checkbox
                    checked={locations[currentTag - 1] === location}
                    height={2}
                    key={location}
                    onClick={() => act('change', { index: index + 1 })}
                    width={15}>
                    {location.toUpperCase()}
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
