import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Powers } from './PowersMenu';
import { PreferencesMenuData } from './types';

type MortalPagePowers = {
  handleCloseMortal: () => void;
};

export const MortalPage = (props: MortalPagePowers) => {
  const { data } = useBackend<PreferencesMenuData>();
  return (
    <Stack vertical>
      <Stack.Item>
        <Button icon="arrow-left" onClick={props.handleCloseMortal}>
          Go Back
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Section
          align="center"
          title={'Points: ' + data.power_points + '/' + data.total_power_points}
        >
          <Button
            icon="crown"
            tooltip="Powers with this icon are root powers. They unlock access to powers in a specific path."
            color="transparent"
          />
          <Button
            icon="diamond"
            tooltip="Powers with this icon are advanced powers. They cannot be picked with other paths."
            color="transparent"
          />
          <br />
          Hover over the learn button to view the required root power, if
          applicable.
        </Section>
      </Stack.Item>
      <Stack.Item />
      <Stack>
        <Stack.Item minWidth="33%">
          <Section title="Warfighter">
            <Stack vertical>
              {data.warfighter.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="33%">
          <Section title="Expert">
            <Stack vertical>
              {data.expert.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="33%">
          <Section title="Augmented">
            <Stack vertical>
              {data.augmented.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
