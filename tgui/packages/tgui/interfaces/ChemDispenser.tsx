import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';
import { useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';
import { Beaker, BeakerDisplay } from './common/BeakerDisplay';

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
  chemicals: DispensableReagent[];
  recipes: string[];
  recordingRecipe: string[];
  recipeReagents: string[];
  beaker: Beaker;
};

export const ChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const { recipeReagents = [], recipes = [], beaker } = data;
  const [hasCol, setHasCol] = useState(false);

  const beakerTransferAmounts = beaker ? beaker.transferAmounts : [];
  const recordedContents =
    recording &&
    Object.keys(data.recordingRecipe).map((id) => ({
      id,
      name: toTitleCase(id.replace(/_/, ' ')),
      volume: data.recordingRecipe[id],
    }));

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
                disabled={!beaker}
                content={'Reaction search'}
                tooltip={
                  beaker
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
          }
        >
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
                  disabled={!beaker}
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
          }
        >
          <Box mr={-1}>
            {Object.keys(recipes).map((recipe) => (
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
          ))}
        >
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
          ))}
        >
          <BeakerDisplay
            beaker={beaker}
            title_label={recording && 'Virtual beaker'}
            replace_contents={recordedContents}
            showpH={data.showpH}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
