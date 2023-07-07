import { useBackend } from '../backend';
import { LabeledList, Section, ProgressBar, Collapsible, Stack, Icon, Box, Tooltip, Button } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';
import { Design, MaterialMap } from './Fabrication/Types';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { BooleanLike, classes } from 'common/react';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Material } from './Fabrication/Types';

type AutolatheDesign = Design & {
  buildable: BooleanLike;
  mult5: BooleanLike;
  mult10: BooleanLike;
  mult25: BooleanLike;
  mult50: BooleanLike;
  sheet: BooleanLike;
};

type AutolatheData = {
  materials: Material[];
  materialtotal: number;
  materialsmax: number;
  designs: AutolatheDesign[];
  active: BooleanLike;
};

export const Autolathe = (props, context) => {
  const { act, data } = useBackend<AutolatheData>(context);
  const { materialtotal, materialsmax, materials, designs, active } = data;

  const filteredMaterials = materials.filter((material) => material.amount > 0);

  const availableMaterials: MaterialMap = {};

  for (const material of filteredMaterials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Autolathe" width={670} height={600}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Total Materials">
              <LabeledList>
                <LabeledList.Item label="Total Materials">
                  <ProgressBar
                    value={materialtotal}
                    minValue={0}
                    maxValue={materialsmax}
                    ranges={{
                      'good': [materialsmax * 0.85, materialsmax],
                      'average': [materialsmax * 0.25, materialsmax * 0.85],
                      'bad': [0, materialsmax * 0.25],
                    }}>
                    {materialtotal + '/' + materialsmax + ' cm³'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item>
                  {filteredMaterials.length > 0 && (
                    <Collapsible title="Materials">
                      <LabeledList>
                        {filteredMaterials.map((material) => (
                          <LabeledList.Item
                            key={material.name}
                            label={capitalize(material.name)}>
                            <ProgressBar
                              style={{
                                transform: 'scaleX(-1) scaleY(1)',
                              }}
                              value={materialsmax - material.amount}
                              maxValue={materialsmax}
                              backgroundColor={material.color}
                              color="black">
                              <div style={{ transform: 'scaleX(-1)' }}>
                                {material.amount + ' cm³'}
                              </div>
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Collapsible>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <DesignBrowser
              busy={!!active}
              designs={designs}
              availableMaterials={availableMaterials}
              buildRecipeElement={(
                design,
                availableMaterials,
                _onPrintDesign
              ) => (
                <AutolatheRecipe
                  design={design}
                  availableMaterials={availableMaterials}
                />
              )}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  availableMaterials: MaterialMap;
};

const PrintButton = (props: PrintButtonProps, context) => {
  const { act, data } = useBackend<AutolatheData>(context);
  const { design, quantity, availableMaterials } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !availableMaterials[material] ||
      amount * quantity > (availableMaterials[material] ?? 0)
  );

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          available={availableMaterials}
        />
      }>
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() => act('make', { id: design.id, multiplier: quantity })}>
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type AutolatheRecipeProps = {
  design: AutolatheDesign;
  availableMaterials: MaterialMap;
};

const AutolatheRecipe = (props: AutolatheRecipeProps, context) => {
  const { act, data } = useBackend<AutolatheData>(context);
  const { design, availableMaterials } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !availableMaterials[material] ||
      amount > (availableMaterials[material] ?? 0)
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
            available={availableMaterials}
          />
        }>
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => act('make', { id: design.id, multiplier: 1 })}>
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

      {!!design.mult5 && (
        <PrintButton
          design={design}
          quantity={5}
          availableMaterials={availableMaterials}
        />
      )}

      {!!design.mult10 && (
        <PrintButton
          design={design}
          quantity={10}
          availableMaterials={availableMaterials}
        />
      )}

      {!!design.mult25 && (
        <PrintButton
          design={design}
          quantity={25}
          availableMaterials={availableMaterials}
        />
      )}

      {!!design.mult50 && (
        <PrintButton
          design={design}
          quantity={50}
          availableMaterials={availableMaterials}
        />
      )}

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
            act('make', {
              id: design.id,
              multiplier: value,
            })
          }
        />
      </div>
    </div>
  );
};
