import { sortBy } from 'common/collections';
import { ColorBox, ProgressBar, Section, Stack } from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Restock = (props) => {
  return (
    <Window width={575} height={560}>
      <Window.Content scrollable>
        <RestockTracker />
      </Window.Content>
    </Window>
  );
};

export const RestockTracker = (props) => {
  const { data } = useBackend();
  const vending_list = sortBy(
    data.vending_list ?? [],
    (vend) => vend.percentage,
  );
  return (
    <Section fill title="Vendor Stocking Status">
      <Stack vertical>
        <Stack fill horizontal>
          <Stack.Item bold width="35%">
            Vending Name
          </Stack.Item>
          <Stack.Item bold width="25%">
            Location
          </Stack.Item>
          <Stack.Item bold width="20%">
            Stock %
          </Stack.Item>
          <Stack.Item bold width="20%">
            Credits stored
          </Stack.Item>
        </Stack>
        <hr />
        {vending_list?.map((vend) => (
          <Stack key={vend.id} fill horizontal>
            <Stack.Item wrap width="35%" height="100%">
              {vend.name}
            </Stack.Item>
            <Stack.Item wrap width="25%" height="100%">
              {vend.location}
            </Stack.Item>
            <Stack.Item
              wrap
              width="20%"
              textAlign={
                vend.percentage > 75
                  ? 'left'
                  : vend.percentage > 45
                    ? 'right'
                    : 'center'
              }
            >
              <ProgressBar
                value={vend.percentage}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [75, 100],
                  average: [45, 75],
                  bad: [0, 45],
                }}
              >
                {round(vend.percentage, 0.01)}
              </ProgressBar>
            </Stack.Item>
            <Stack.Item
              wrap
              width="20%"
              color={vend.credits > 50 ? 'good' : 'bad'}
            >
              <ColorBox color={vend.credits > 50 ? 'good' : 'bad'} mr={'5%'} />
              {vend.credits}
            </Stack.Item>
          </Stack>
        ))}
        {vending_list.length === 0 && <RestockTrackerFull />}
      </Stack>
    </Section>
  );
};

export const RestockTrackerFull = (props) => {
  const { data } = useBackend();
  return (
    <Section bold textAlign="center">
      All vending machines stocked!
    </Section>
  );
};
