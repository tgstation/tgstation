import {
  Box,
  Collapsible,
  Divider,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Objective } from './common/Objectives';

type Data = {
  color: string;
  description: string;
  effects: string;
  name: string;
  objectives: Objective[];
};

const BLOB_COLOR = '#556b2f';

export const AntagInfoBlob = (props) => {
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

const Overview = (props) => {
  const { data } = useBackend<Data>();
  const { color, description, effects, name } = data;

  if (!name) {
    return (
      <Stack vertical>
        <Stack.Item bold fontSize="14px" textColor={BLOB_COLOR}>
          You haven&apos;t revealed your true form yet!
        </Stack.Item>
        <Stack.Item>
          You must succumb to the infection. Find somewhere safe and pop!
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
          }}
        >
          {name}
        </span>
      </Stack.Item>
      <Stack.Item>
        The{' '}
        <span
          style={{
            color,
          }}
        >
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
            }}
          >
            {name}
          </span>{' '}
          reagent {effects}
        </Stack.Item>
      )}
    </Stack>
  );
};

const Basics = (props) => {
  return (
    <Collapsible title="The Basics">
      <LabeledList>
        <LabeledList.Item label="Attacking">
          You can expand, which will attack people, damage objects, or place a
          Normal Blob if the tile is clear.
        </LabeledList.Item>
        <LabeledList.Item label="Placement">
          You will be able to manually place your blob core by pressing the
          Place Blob Core button in the bottom right corner of the screen.{' '}
          <br />
          <br />
          If you are the blob infection, you can place the core where you are
          standing by pressing the pop button on the top left corner of the
          screen.
        </LabeledList.Item>
        <LabeledList.Item label="HUD">
          In addition to the buttons on your HUD, there are a few click
          shortcuts to speed up expansion and defense.
        </LabeledList.Item>
        <LabeledList.Item label="Shortcuts">
          Click = Expand Blob <br />
          Middle Mouse Click = Rally Spores <br />
          Ctrl Click = Create Shield Blob <br />
          Alt Click = Remove Blob <br />
        </LabeledList.Item>
        <LabeledList.Item label="Comms">
          Attempting to talk will send a message to all other overminds,
          allowing you to coordinate with them.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Minions = (props) => {
  return (
    <Collapsible title="Minions">
      <LabeledList>
        <LabeledList.Item label="Blobbernauts">
          This unit can be produced from factories for a cost. They are hard to
          kill, powerful, and moderately smart. The factory used to create one
          will become fragile and briefly unable to produce spores.
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

const Structures = (props) => {
  return (
    <Collapsible title="Structures">
      <Box>
        Normal Blobs will expand your reach and can be upgraded into special
        blobs that perform certain functions. Bear in mind that expanding into
        space has an 80% chance of failing!
      </Box>
      <br />
      <Box>You can upgrade normal blobs into the following types of blob:</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Strong Blobs">
          Strong blobs are expensive but take more damage. In additon, they are
          fireproof and can block air, use these to protect yourself from
          station fires.
        </LabeledList.Item>
        <LabeledList.Item label="Reflective Blobs">
          Upgrading strong blobs creates reflective blobs, capable of reflecting
          most projectiles at the cost of the strong blob&apos;s extra health.
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

const ObjectiveDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { color, objectives } = data;

  return (
    <Collapsible title="Objectives">
      <LabeledList>
        {objectives.map(({ explanation }, index) => (
          <LabeledList.Item
            color={color ?? 'white'}
            key={index}
            label={(index + 1).toString()}
          >
            {explanation}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Collapsible>
  );
};
