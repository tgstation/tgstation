import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type BeakerReagent = {
  name: string;
  volume: number;
  pH: number;
  purity: number;
};

type DispensableReagent = {
  title: string;
  id: string;
  pH: number;
  pHCol: string;
};

type Data = {
  showpH: BooleanLike;
  amount: number;
  energy: number;
  maxEnergy: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: BeakerReagent[];
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerTransferAmounts: number[];
  beakerCurrentpH: number;
  chemicals: DispensableReagent[];
  recipes: string[];
  recordingRecipe: string[];
  recipeReagents: string[];
};

export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const recording = !!data.recordingRecipe;
  const { recipeReagents = [], recipes = [] } = data;
  const [hasCol, setHasCol] = useLocalState(context, 'has_col', false);

  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents =
    (recording &&
      Object.keys(data.recordingRecipe).map((id) => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))) ||
    data.beakerContents ||
    [];
  return (
    <Window width={565} height={620}>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={
            <>
              {recording && (
                <Box inline mx={1} color="red">
                  <Icon name="circle" mr={1} />
                  Recording
                </Box>
              )}
              <Button
                icon="book"
                disabled={!data.isBeakerLoaded}
                content={'Reaction search'}
                tooltip={
                  data.isBeakerLoaded
                    ? 'Look up recipes and reagents!'
                    : 'Please insert a beaker!'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('reaction_lookup')}
              />
              <Button
                icon="cog"
                tooltip="Color code the reagents by pH"
                tooltipPosition="bottom-start"
                selected={hasCol}
                onClick={() => setHasCol(!hasCol)}
              />
            </>
          }>
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar value={data.energy / data.maxEnergy}>
                {toFixed(data.energy) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Recipes"
          buttons={
            <>
              {!recording && (
                <Box inline mx={1}>
                  <Button
                    color="transparent"
                    content="Clear recipes"
                    onClick={() => act('clear_recipes')}
                  />
                </Box>
              )}
              {!recording && (
                <Button
                  icon="circle"
                  disabled={!data.isBeakerLoaded}
                  content="Record"
                  onClick={() => act('record_recipe')}
                />
              )}
              {recording && (
                <Button
                  icon="ban"
                  color="transparent"
                  content="Discard"
                  onClick={() => act('cancel_recording')}
                />
              )}
              {recording && (
                <Button
                  icon="save"
                  color="green"
                  content="Save"
                  onClick={() => act('save_recording')}
                />
              )}
            </>
          }>
          <Box mr={-1}>
            {Object.keys(recipes).map((recipe, index) => (
              <Button
                key={recipe}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={recipe}
                onClick={() =>
                  act('dispense_recipe', {
                    recipe: recipe,
                  })
                }
              />
            ))}
            {recipes.length === 0 && <Box color="light-gray">No recipes.</Box>}
          </Box>
        </Section>
        <Section
          title="Dispense"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}>
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={chemical.title}
                tooltip={'pH: ' + chemical.pH}
                backgroundColor={
                  recipeReagents.includes(chemical.id)
                    ? hasCol
                      ? 'black'
                      : 'green'
                    : hasCol
                      ? chemical.pHCol
                      : 'default'
                }
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Beaker"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="minus"
              disabled={recording}
              content={amount}
              onClick={() => act('remove', { amount })}
            />
          ))}>
          <LabeledList>
            <LabeledList.Item
              label="Beaker"
              buttons={
                !!data.isBeakerLoaded && (
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject')}
                  />
                )
              }>
              {(recording && 'Virtual beaker') ||
                (data.isBeakerLoaded && (
                  <>
                    <AnimatedNumber
                      initial={0}
                      value={data.beakerCurrentVolume}
                    />
                    /{data.beakerMaxVolume} units
                  </>
                )) ||
                'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item label="Contents">
              <Box color="label">
                {(!data.isBeakerLoaded && !recording && 'N/A') ||
                  (beakerContents.length === 0 && 'Nothing')}
              </Box>
              {beakerContents.map((chemical) => (
                <Box key={chemical.name} color="label">
                  <AnimatedNumber initial={0} value={chemical.volume} /> units
                  of {chemical.name}
                </Box>
              ))}
              {beakerContents.length > 0 && !!data.showpH && (
                <Box>
                  pH:
                  <AnimatedNumber value={data.beakerCurrentpH} />
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
