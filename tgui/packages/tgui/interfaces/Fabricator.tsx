import { useBackend } from '../backend';
import { Stack, Section, Icon, Dimmer, Box, Tooltip, Button } from '../components';
import { Window } from '../layouts';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { FabricatorData, Design, MaterialMap } from './Fabrication/Types';
import { classes } from 'common/react';
import { DesignBrowser } from './Fabrication/DesignBrowser';

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { fabName, onHold, designs, busy } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title={fabName} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <DesignBrowser
              busy={!!busy}
              designs={Object.values(designs)}
              availableMaterials={availableMaterials}
              buildRecipeElement={(
                design,
                availableMaterials,
                onPrintDesign
              ) => <Recipe design={design} available={availableMaterials} />}
            />
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials ?? []}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
        {!!onHold && (
          <Dimmer style={{ 'font-size': '2em', 'text-align': 'center' }}>
            Mineral access is on hold, please contact the quartermaster.
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  available: MaterialMap;
};

const PrintButton = (props: PrintButtonProps, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, quantity, available } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount * quantity > (available[material] ?? 0)
  );

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          available={available}
        />
      }>
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() => act('build', { ref: design.id, amount: quantity })}>
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type CustomPrintProps = {
  design: Design;
  available: MaterialMap;
};

const CustomPrint = (props: CustomPrintProps, context) => {
  const { act } = useBackend(context);
  const { design, available } = props;
  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0)
  );

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        !canPrint && 'FabricatorRecipe__Button--disabled',
      ])}>
      <Button.Input
        content={'[Max: ' + design.maxmult + ']'}
        color={'transparent'}
        maxValue={design.maxmult}
        onCommit={(_e, value: string) =>
          act('build', {
            ref: design.id,
            amount: value,
          })
        }
      />
    </div>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, available } = props;

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
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            available={available}
          />
        }>
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => act('build', { ref: design.id, amount: 1 })}>
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
      <PrintButton design={design} quantity={5} available={available} />
      <PrintButton design={design} quantity={10} available={available} />
      <CustomPrint design={design} available={available} />
    </div>
  );
};
