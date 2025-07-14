import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Beaker, BeakerDisplay } from './common/BeakerDisplay';

type DispensableReagent = {
  title: string;
  id: string;
  pH: number;
  color: string;
  pHCol: string;
};

type TransferableBeaker = Beaker & {
  transferAmounts: number[];
};

type Data = {
  showpH: BooleanLike;
  amount: number;
  energy: number;
  maxEnergy: number;
  displayedUnits: string;
  displayedMaxUnits: string;
  chemicals: DispensableReagent[];
  recipes: string[];
  recordingRecipe: string[];
  recipeReagents: string[];
  beaker: TransferableBeaker;
};

export const ChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const { recipeReagents = [], recipes = [], beaker } = data;
  const [showPhCol, setShowPhCol] = useState(false);

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
                tooltip={
                  beaker
                    ? 'Look up recipes and reagents!'
                    : 'Please insert a beaker!'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('reaction_lookup')}
              >
                Reaction search
              </Button>
              <Button
                icon="cog"
                tooltip="Color code the reagents by pH"
                tooltipPosition="bottom-start"
                selected={showPhCol}
                onClick={() => setShowPhCol(!showPhCol)}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar value={data.energy / data.maxEnergy}>
                {data.displayedUnits +
                  ' / ' +
                  data.displayedMaxUnits +
                  ' units'}
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
                    onClick={() => act('clear_recipes')}
                  >
                    Clear recipes
                  </Button>
                </Box>
              )}
              {!recording && (
                <Button
                  icon="circle"
                  disabled={!beaker}
                  onClick={() => act('record_recipe')}
                >
                  Record
                </Button>
              )}
              {recording && (
                <Button
                  icon="ban"
                  color="transparent"
                  onClick={() => act('cancel_recording')}
                >
                  Discard
                </Button>
              )}
              {recording && (
                <Button
                  icon="save"
                  color="green"
                  onClick={() => act('save_recording')}
                >
                  Save
                </Button>
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
                onClick={() =>
                  act('dispense_recipe', {
                    recipe: recipe,
                  })
                }
              >
                {recipe}
              </Button>
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
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            >
              {amount}
            </Button>
          ))}
        >
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                textColor={showPhCol ? chemical.pHCol : chemical.color}
                width="129.5px"
                lineHeight={1.75}
                tooltip={`pH: ${chemical.pH}`}
                style={{
                  textShadow: '1px 1px 0 black',
                }}
                backgroundColor={
                  recipeReagents.includes(chemical.id) ? 'green' : 'default'
                }
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              >
                <span
                  style={{
                    color: 'white',
                    textShadow: 'none',
                  }}
                >
                  {chemical.title}
                </span>
              </Button>
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
              onClick={() => act('remove', { amount })}
            >
              {amount}
            </Button>
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
