import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';

type FishingTips = {
  spots : string,
  difficulty: string,
  favorite_bait: string,
  disliked_bait: string,
  traits: string[]
}

type FishInfo = {
  name: string,
  desc: string,
  fluid: string,
  temp_min: number,
  temp_max: number,
  feed: string,
  source: string,
  fishing_tips: FishingTips,
  weight : string,
  size: string,
  icon: string
}

type FishCatalogData = {
  fish_info : FishInfo[] | null,
  sponsored_by: string
}

export const FishCatalog = (props, context) => {
  const { act, data } = useBackend<FishCatalogData>(context);
  const {
    fish_info,
    sponsored_by,
  } = data;
  const fish_by_name = flow([
    sortBy((fish: FishInfo) => fish.name),
  ])(fish_info || []);
  const [
    currentFish,
    setCurrentFish,
  ] = useLocalState<FishInfo | null>(context, 'currentFish', null);
  return (
    <Window
      width={500}
      height={300}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="140px">
            <Section fill scrollable>
              {fish_by_name.map(f => (
                <Button
                  key={f.name}
                  fluid
                  color="transparent"
                  selected={f === currentFish}
                  onClick={() => { setCurrentFish(f); }}>
                  {f.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title={currentFish
                ? capitalize(currentFish.name)
                : sponsored_by + " Fish Index"}>
              {currentFish && (
                <LabeledList>
                  <LabeledList.Item label="Description">
                    {currentFish.desc}
                  </LabeledList.Item>
                  <LabeledList.Item label="Water type">
                    {currentFish.fluid}
                  </LabeledList.Item>
                  <LabeledList.Item label="Temperature">
                    {currentFish.temp_min} to {currentFish.temp_max}
                  </LabeledList.Item>
                  <LabeledList.Item label="Feeding">
                    {currentFish.feed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Acquisition">
                    {currentFish.source}
                  </LabeledList.Item>
                  <LabeledList.Item label="Average size">
                    {currentFish.size} cm
                  </LabeledList.Item>
                  <LabeledList.Item label="Average weight">
                    {currentFish.weight} g
                  </LabeledList.Item>
                  <LabeledList.Item label="Fishing tips">
                    <LabeledList>
                      <LabeledList.Item label="Fishing locations">
                        {currentFish.fishing_tips.spots}
                      </LabeledList.Item>
                      <LabeledList.Item label="Favourite bait">
                        {currentFish.fishing_tips.favorite_bait}
                      </LabeledList.Item>
                      <LabeledList.Item label="Disliked bait">
                        {currentFish.fishing_tips.disliked_bait}
                      </LabeledList.Item>
                      <LabeledList.Item label="Behavior">
                        {currentFish.fishing_tips.traits}
                      </LabeledList.Item>
                    </LabeledList>
                  </LabeledList.Item>
                  <LabeledList.Item label="Illustration">
                    <Box
                      className={classes([
                        'fish32x32',
                        currentFish.icon,
                      ])} />
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
