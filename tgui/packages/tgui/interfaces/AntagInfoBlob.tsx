import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Collapsible, Divider, LabeledList, Section, Stack } from '../components';

import { Window } from '../layouts';

type Data = {
  color: string;
  description: string;
  effects: string;
  name: string;
  objectives: Objectives[];
};

type Objectives = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

const BLOB_COLOR = '#556b2f';

export const AntagInfoBlob = (props, context) => {
  return (
    <Window width={400} height={550}>
      <Window.Content>
        <Section fill scrollable>
          <Overview />
          <Divider />
          <Basics />
          <Structures />
          <Minions />
          <ObjectiveDisplay />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Overview = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { color, description, effects, name } = data;

  if (!name) {
    return (
      <Stack vertical>
        <Stack.Item bold fontSize="14px" textColor={BLOB_COLOR}>
          You haven&apos;t revealed your true form yet!
        </Stack.Item>
        <Stack.Item>
          You must be succumb to the infection. Find somewhere safe and pop!
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack vertical>
      <Stack.Item bold fontSize="24px" textColor={BLOB_COLOR}>
        You are the Blob!
      </Stack.Item>
      <Stack.Item>As the overmind, you can control the blob.</Stack.Item>
      <Stack.Item>
        Your blob reagent is:{' '}
        <span
          style={{
            color,
          }}>
          {name}
        </span>
      </Stack.Item>
      <Stack.Item>
        The{' '}
        <span
          style={{
            color,
          }}>
          {name}
        </span>{' '}
        reagent {description}
      </Stack.Item>
      {effects && (
        <Stack.Item>
          The{' '}
          <span
            style={{
              color,
            }}>
            {name}
          </span>{' '}
          reagent {effects}
        </Stack.Item>
      )}
    </Stack>
  );
};

const Basics = (props, context) => {
  return (
    <Collapsible title="The Basics">
      <LabeledList>
        <LabeledList.Item label="Attacking">
          You can expand, which will attack people, damage objects, or place a
          Normal Blob if the tile is clear.
        </LabeledList.Item>
        <LabeledList.Item label="Placement">
          You will be able to manually place your blob core by pressing the
          Place Blob Core button in the bottom right corner of the screen.
        </LabeledList.Item>
        <LabeledList.Item label="HUD">
          In addition to the buttons on your HUD, there are a few click
          shortcuts to speed up expansion and defense.
        </LabeledList.Item>
        <LabeledList.Item label="Shortcuts">
          Click = Expand Blob | Middle Mouse Click = Rally Spores | Ctrl Click =
          Create Shield Blob | Alt Click = Remove Blob
        </LabeledList.Item>
        <LabeledList.Item label="Comms">
          Attempting to talk will send a message to all other overminds,
          allowing you to coordinate with them.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Minions = (props, context) => {
  return (
    <Collapsible title="Minions">
      <LabeledList>
        <LabeledList.Item label="Blobbernauts">
          Defenders that can be produced from factories for a cost, and are hard
          to kill, powerful, and moderately smart. The factory used to create
          one will become fragile and briefly unable to produce spores.
        </LabeledList.Item>
        <LabeledList.Item label="Spores">
          Produced automatically from factories, these are weak, but can be
          rallied to attack enemies. They will also attack enemies near the
          factory and attempt to zombify corpses.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Structures = (props, context) => {
  return (
    <Collapsible title="Structures">
      <Box>
        Normal Blobs will expand your reach and can be upgraded into special
        blobs that perform certain functions.
      </Box>
      <br />
      <Box>You can upgrade normal blobs into the following types of blob:</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Shield Blobs">
          Strong and expensive blobs which take more damage. In additon, they
          are fireproof and can block air, use these to protect yourself from
          station fires. Upgrading them again will result in a reflective blob,
          capable of reflecting most projectiles at the cost of the strong
          blob&apos;s extra health.
        </LabeledList.Item>
        <LabeledList.Item label="Resource Blobs">
          Blobs which produce more resources for you, build as many of these as
          possible to consume the station. This type of blob must be placed near
          node blobs or your core to work.
        </LabeledList.Item>
        <LabeledList.Item label="Factory Blobs">
          Blobs that spawn blob spores which will attack nearby enemies. This
          type of blob must be placed near node blobs or your core to work.
        </LabeledList.Item>
        <LabeledList.Item label="Node Blobs">
          Blobs which grow, like the core. Like the core it can activate
          resource and factory blobs.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const ObjectiveDisplay = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { color, objectives } = data;

  return (
    <Collapsible title="Objectives">
      <LabeledList>
        {objectives.map(({ explanation }, index) => (
          <LabeledList.Item
            color={color ?? 'white'}
            key={index}
            label={(index + 1).toString()}>
            {explanation}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Collapsible>
  );
};
