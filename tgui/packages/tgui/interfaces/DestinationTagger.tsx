import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Stack, Section, Button, NoticeBox } from '../components';

type DestinationTaggerData = {
  locations: string[];
  currentTag: number;
};

export const DestinationTagger = (props, context) => {
  const { act, data } = useBackend<DestinationTaggerData>(context);
  const { locations, currentTag } = data;

  return (
    <Window title="TagMaster 2.4" width={450} height={520}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <NoticeBox>
              {!currentTag
                ? 'PLEASE SELECT A LOCATION'
                : `CURRENT DESTINATION: ${locations[
                  currentTag - 1
                ].toUpperCase()}`}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item>
            <Section scrollable title="Locations">
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
