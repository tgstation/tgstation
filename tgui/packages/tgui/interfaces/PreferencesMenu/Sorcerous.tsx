import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Powers } from './PowersMenu';
import { PreferencesMenuData } from './types';

type SorcerousPageProps = {
  handleCloseSorcerous: () => void;
};

export const SorcerousPage = (props: SorcerousPageProps) => {
  const { data } = useBackend<PreferencesMenuData>();
  return (
    <Stack vertical>
      <Stack.Item>
        <Button icon="arrow-left" onClick={props.handleCloseSorcerous}>
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
          <Section title="Thamaturge">
            <Stack vertical>
              {data.thaumaturge.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="33%">
          <Section title="Enigmatist">
            <Stack vertical>
              {data.enigmatist.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="33%">
          <Section title="Theologist">
            <Stack vertical>
              {data.theologist.map((val) => (
                <Powers key={val.icon} power={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
