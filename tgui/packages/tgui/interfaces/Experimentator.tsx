import {
  Button,
  Icon,
  Image,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  hasItem: BooleanLike;
  isOnCooldown: BooleanLike;
  isServerConnected: BooleanLike;
  loadedItem: Item;
};

type Item = {
  name: string;
  icon: string;
  isRelic: BooleanLike;
  associatedNodes: Node[];
};

type Node = {
  name: string;
  isUnlocked: BooleanLike;
};

export const Experimentator = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { hasItem, isOnCooldown, isServerConnected, loadedItem } = data;

  return (
    <Window width={450} height={325} title="E.X.P.E.R.I-MENTOR">
      <Window.Content>
        {isServerConnected ? (
          hasItem && loadedItem ? (
            <ExperimentScreen
              item={loadedItem}
              isOnCooldown={isOnCooldown}
              onEject={() => act('eject')}
              onExperiment={(id) => act('experiment', { id: id })}
            />
          ) : (
            <NoticeBox danger textAlign="center">
              No item present in experimentation chamber. Please insert one.
            </NoticeBox>
          )
        ) : (
          <NoticeBox danger textAlign="center">
            Not connected to a server. Please sync one using a multitool.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

enum Experiment {
  Poke = 'Poke',
  Irradiate = 'Irradiate',
  Gas = 'Gas',
  Heat = 'Heat',
  Cold = 'Freeze',
  Obliterate = 'Obliterate',
}

const EXPERIMENT2ICON = {
  Poke: 'hand',
  Irradiate: 'radiation',
  Gas: 'cloud',
  Heat: 'fire',
  Cold: 'snowflake',
  Obliterate: 'trash',
};

type ExperimentScreenProps = {
  item: Item;
  isOnCooldown: BooleanLike;
  onEject: () => void;
  onExperiment: (id: number) => void;
};

const ExperimentScreen = (props: ExperimentScreenProps) => {
  const { item, isOnCooldown, onEject, onExperiment } = props;
  const { name, icon, isRelic, associatedNodes } = item;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <ItemPreview name={name} icon={icon} onEject={onEject} />
          </Stack.Item>
          <Stack.Item grow>
            <NodePreview nodes={associatedNodes} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <ExperimentButtons
          isRelic={isRelic}
          disabled={isOnCooldown}
          onExperiment={onExperiment}
        />
      </Stack.Item>
    </Stack>
  );
};

type ItemPreviewProps = {
  name: string;
  icon: string;
  onEject: () => void;
};

const ItemPreview = (props: ItemPreviewProps) => {
  const { name, icon, onEject } = props;

  return (
    <Stack fill vertical align="center">
      <Stack.Item align="stretch">
        <Stack fill>
          <Stack.Item>
            <Button
              fluid
              color="bad"
              icon="eject"
              height="100%"
              fontSize={1.5}
              tooltip="Eject"
              textAlign="center"
              onClick={() => onEject()}
              verticalAlignContent="middle"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill bold textAlign="center">
              {toTitleCase(name)}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical align="center" justify="center">
          <Stack.Item>
            <Image
              width="128px"
              height="128px"
              src={`data:image/jpeg;base64,${icon}`}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

type NodePreviewProps = {
  nodes: Node[];
};

const NodePreview = (props: NodePreviewProps) => {
  const { nodes } = props;

  return (
    <Section fill title="Affected Nodes">
      {nodes.length > 0 ? (
        <LabeledList>
          {nodes.map((node, index) => (
            <LabeledList.Item
              key={index}
              label={node.name}
              color={node.isUnlocked ? 'good' : 'bad'}
            >
              {node.isUnlocked ? 'Unlocked' : 'Locked'}
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Stack fill vertical align="center" justify="center">
          <Stack.Item className="hypertorus__unselectable">
            <Icon
              fontSize={4}
              name="circle-question"
              className={'FabricatorRecipe__Title--disabled'}
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

type ExperimentButtonsProps = {
  isRelic: BooleanLike;
  disabled: BooleanLike;
  onExperiment: (id: number) => void;
};

const ExperimentButtons = (props: ExperimentButtonsProps) => {
  const { isRelic, disabled, onExperiment } = props;

  return (
    <Section fill>
      <Stack fill>
        {Object.keys(Experiment).map((value, index) => (
          <Stack.Item key={index}>
            <Button
              width={3}
              height={3}
              fontSize={1.6}
              textAlign="center"
              disabled={disabled}
              tooltip={Experiment[value]}
              verticalAlignContent="middle"
              icon={EXPERIMENT2ICON[value]}
              onClick={() => onExperiment(index + 1)}
            />
          </Stack.Item>
        ))}
        <Stack.Item grow>
          <Button
            bold
            fluid
            height={3}
            fontSize={1.6}
            textAlign="center"
            icon="magnifying-glass"
            verticalAlignContent="middle"
            disabled={!isRelic || disabled}
            onClick={() => onExperiment(7)}
          >
            Discover!
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
