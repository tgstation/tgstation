import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Window } from '../layouts';

type Data = {
  enabled: BooleanLike;
  min_volume: number;
  max_volume: number;
  disposal_rate: number;
};

export function ChemDisposer() {
  const { act, data } = useBackend<Data>();
  const { enabled, min_volume, max_volume, disposal_rate } = data;

  return (
    <Window width={320} height={105}>
      <Window.Content>
        <Section
          title="Control Panel"
          buttons={
            <Button
              icon="power-off"
              selected={enabled}
              onClick={() => act('toggle_power')}
            >
              {enabled ? 'On' : 'Off'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Volume">
              <NumberInput
                value={disposal_rate}
                unit="u"
                width="50px"
                minValue={min_volume}
                maxValue={max_volume}
                step={2}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_volume', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
}
