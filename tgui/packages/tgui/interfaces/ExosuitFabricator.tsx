import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { Design, FabricatorData, MaterialMap } from './Fabrication/Types';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Tooltip } from '../components';
import { BooleanLike, classes } from 'common/react';

type ExosuitFabricatorData = FabricatorData & {
  processing: BooleanLike;
};

export const ExosuitFabricator = (props, context) => {
  const { act, data } = useBackend<ExosuitFabricatorData>(context);
  const { materials, SHEET_MATERIAL_AMOUNT } = data;

  const availableMaterials: MaterialMap = {};

  for (const material of materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Exosuit Fabricator" width={1100} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <DesignBrowser
                  designs={Object.values(data.designs)}
                  availableMaterials={availableMaterials}
                  buildRecipeElement={(design, availableMaterials) => (
                    <Recipe
                      available={availableMaterials}
                      design={design}
                      SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                    />
                  )}
                  categoryButtons={(category) => (
                    <Button
                      color={'transparent'}
                      onClick={() => {
                        act('build', {
                          designs: category.children.map((design) => design.id),
                        });
                      }}>
                      Queue All
                    </Button>
                  )}
                />
              </Stack.Item>
              <Stack.Item>
                <Section>
                  <MaterialAccessBar
                    availableMaterials={materials}
                    SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                    onEjectRequested={(material, amount) => {
                      act('remove_mat', { ref: material.ref, amount });
                    }}
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item width="420px">
            <Queue
              availableMaterials={availableMaterials}
              SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const Recipe = (props: RecipeProps, context) => {
  const { act } = useBackend<ExosuitFabricatorData>(context);
  const { design, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0)
  );

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}>
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        position="bottom"
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            available={available}
          />
        }>
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('build', { designs: [design.id], now: true })
          }>
          <div className="FabricatorRecipe__Icon">
            <Box
              width={'32px'}
              height={'32px'}
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>

      <Tooltip content={'Add to Queue'} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
          color={'transparent'}
          onClick={() => act('build', { designs: [design.id] })}>
          <Icon name="plus-circle" />
        </div>
      </Tooltip>

      <Tooltip content={'Build Now'} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
          color={'transparent'}
          onClick={() => act('build', { designs: [design.id], now: true })}>
          <Icon name="play" />
        </div>
      </Tooltip>
    </div>
  );
};

type QueueProps = {
  availableMaterials: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const Queue = (props: QueueProps, context) => {
  const { act, data } = useBackend<ExosuitFabricatorData>(context);
  const { availableMaterials, SHEET_MATERIAL_AMOUNT } = props;
  const { designs, processing } = data;

  const queue = data.queue || [];

  const materialCosts: MaterialMap = {};

  for (const entry of queue) {
    const design = designs[entry.designId];

    if (!design) {
      continue;
    }

    for (const [materialName, materialCost] of Object.entries(design.cost)) {
      materialCosts[materialName] =
        (materialCosts[materialName] || 0) + materialCost;
    }
  }

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Section
            fill
            title="Queue"
            buttons={
              <>
                <Button.Confirm
                  disabled={!queue.length}
                  color="bad"
                  icon="minus-circle"
                  content="Clear Queue"
                  onClick={() => act('clear_queue')}
                />
                {(!!processing && (
                  <Button
                    disabled={!queue.length}
                    content="Stop"
                    icon="stop"
                    onClick={() => act('stop_queue')}
                  />
                )) || (
                  <Button
                    disabled={!queue.length}
                    content="Build Queue"
                    icon="play"
                    onClick={() => act('build_queue')}
                  />
                )}
              </>
            }>
            <MaterialCostSequence
              SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
              available={availableMaterials}
              costMap={materialCosts}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill style={{ 'overflow': 'auto' }}>
            <QueueList
              availableMaterials={availableMaterials}
              SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            />
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type QueueListProps = {
  availableMaterials: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const QueueList = (props: QueueListProps, context) => {
  const { act, data } = useBackend<ExosuitFabricatorData>(context);
  const { availableMaterials, SHEET_MATERIAL_AMOUNT } = props;

  const queue = data.queue || [];
  const designs = data.designs;

  if (!queue.length) {
    return null;
  }

  const accumulatedCosts: MaterialMap = {};

  return (
    <>
      {queue
        .map((job, index) => ({ job, index, design: designs[job.designId] }))
        .map((entry) => {
          // TODO: Side effects in map are gross but at the same time I gotta
          // accumulate these *costs*
          let canPrint = true;

          for (const [material, amount] of entry.design
            ? Object.entries(entry.design.cost)
            : []) {
            accumulatedCosts[material] =
              (accumulatedCosts[material] || 0) + amount;

            if (accumulatedCosts[material] > availableMaterials[material]) {
              canPrint = false;
            }
          }

          return { canPrint, ...entry };
        })
        .map((entry) => (
          <div key={entry.job.jobId} className="FabricatorRecipe">
            {!!entry.job.processing && (
              <div
                className={'FabricatorRecipe__Progress'}
                style={{
                  width:
                    (entry.job.timeLeft /
                      (entry.design ? entry.design.constructionTime : 0)) *
                      100 +
                    '%',
                }}
              />
            )}
            <Tooltip
              position={'bottom'}
              content={
                <MaterialCostSequence
                  design={entry.design}
                  amount={1}
                  SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                  available={availableMaterials}
                />
              }>
              <div
                className={classes([
                  'FabricatorRecipe__Title',
                  !entry.canPrint && 'FabricatorRecipe__Title--disabled',
                ])}>
                <div className="FabricatorRecipe__Icon">
                  <Box
                    width={'32px'}
                    height={'32px'}
                    className={classes([
                      'design32x32',
                      entry.design && entry.design.icon,
                    ])}
                  />
                </div>
                <div className="FabricatorRecipe__Label">
                  {entry.design && entry.design.name}
                </div>
              </div>
            </Tooltip>

            {!entry.job.processing && (
              <div
                className={classes([
                  'FabricatorRecipe__Button',
                  'FabricatorRecipe__Button--icon',
                ])}
                onClick={() => {
                  act('del_queue_part', {
                    index: entry.index + (queue[0]!.processing ? 0 : 1),
                  });
                }}>
                <Tooltip content={'Remove from Queue'}>
                  <Icon name="minus-circle" />
                </Tooltip>
              </div>
            )}
          </div>
        ))}
    </>
  );
};
