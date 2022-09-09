import { useBackend } from '../../tgui/backend';
import { Button, ByondUi, Section, Stack } from '../../tgui/components';
import { Window } from '../../tgui/layouts';

export const HelmComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const { mapRef, thrust } = data;
  return (
    <Window width={500} height={630} theme="retro">
      <Window.Content>
        <Section>
         <Stack vertical align="left">
            <Stack.Item>
              <Button
                icon="arrow-left"
                iconRotation={45}
                onClick={() => act('northwest')}
                />
              <Button
                icon="arrow-up"
                onClick={() => act('north')}
                />
              <Button
                icon="arrow-up"
                iconRotation={45}
                onClick={() => act('northeast')}
                />
            </Stack.Item>
         </Stack>
          <Stack vertical align="left">
            <Stack.Item>
              <Button
                icon="arrow-left"
                onClick={() => act('west')}
                />
              <Button
                icon="circle"
                onClick={() => act('reset')}
                />
              <Button
                icon="arrow-right"
                onClick={() => act('east')}
                />
            </Stack.Item>
          </Stack>
          <Stack vertical align="left">
            <Stack.Item>
              <Button
                icon="arrow-down"
                iconRotation={45}
                onClick={() => act('southwest')}
                />
              <Button
                icon="arrow-down"
                onClick={() => act('south')}
                />
              <Button
                icon="arrow-right"
                iconRotation={45}
                onClick={() => act('southeast')}
                />
            </Stack.Item>
          </Stack>

        </Section>
        <Section fill>
          <ByondUi
            className="overmap__map"
            height={40}
            params={{
              id: mapRef,
              type: 'map',
            }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
