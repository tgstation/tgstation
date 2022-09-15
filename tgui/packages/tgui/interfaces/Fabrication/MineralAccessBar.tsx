import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { useLocalState } from '../../backend';
import { Flex, Button, Stack, AnimatedNumber, Box } from '../../components';
import { formatSiUnit } from '../../format';
import { Material } from '../common/Materials';
import { MaterialName } from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MATERIAL_RARITY: Record<MaterialName, number> = {
  'glass': 0,
  'iron': 1,
  'plastic': 2,
  'titanium': 3,
  'plasma': 4,
  'silver': 5,
  'gold': 6,
  'uranium': 7,
  'diamond': 8,
  'bluespace crystal': 9,
  'bananium': 10,
};

const MATERIAL_ICONS: Record<string, [number, string][]> = {
  'iron': [
    [0, 'sheet-metal'],
    [17, 'sheet-metal_2'],
    [34, 'sheet-metal_3'],
  ],
  'glass': [
    [0, 'sheet-glass'],
    [17, 'sheet-glass_2'],
    [34, 'sheet-glass_3'],
  ],
  'silver': [
    [0, 'sheet-silver'],
    [17, 'sheet-silver_2'],
    [34, 'sheet-silver_3'],
  ],
  'gold': [
    [0, 'sheet-gold'],
    [17, 'sheet-gold_2'],
    [34, 'sheet-gold_3'],
  ],
  'diamond': [[0, 'sheet-diamond']],
  'plasma': [
    [0, 'sheet-plasma'],
    [17, 'sheet-plasma_2'],
    [34, 'sheet-plasma_3'],
  ],
  'uranium': [[0, 'sheet-uranium']],
  'bananium': [[0, 'sheet-bananium']],
  'titanium': [
    [0, 'sheet-titanium'],
    [17, 'sheet-titanium_2'],
    [34, 'sheet-titanium_3'],
  ],
  'bluespace crystal': [[0, 'bluespace_crystal']],
  'plastic': [
    [0, 'sheet-plastic'],
    [17, 'sheet-plastic_2'],
    [34, 'sheet-plastic_3'],
  ],
};

type MaterialIconProps = {
  material: Material;
};

const MaterialIcon = (props: MaterialIconProps) => {
  const { material } = props;
  const icons = MATERIAL_ICONS[material.name];
  let className = '';

  if (icons) {
    let idx = 0;

    while (icons[idx + 1] && icons[idx + 1][0] <= material.amount / 2_000) {
      idx += 1;
    }

    className = `sheetmaterials32x32 ${icons[idx][1]}`;
  }

  return <Box width={'32px'} height={'32px'} className={className} />;
};

export type MaterialAccessBarProps = {
  /**
   * All materials currently available to the user.
   */
  availableMaterials: Material[];

  /**
   * Invoked when the user requests that a material be ejected.
   */
  onEjectRequested?: (material: Material, quantity: number) => void;
};

/**
 * The formatting function applied to the quantity labels in the bar.
 */
const LABEL_FORMAT = (value: number) => formatSiUnit(value, 0);

/**
 * A bottom-docked bar for viewing and ejecting materials from local storage or
 * the ore silo. Has pop-out docks for each material type for ejecting up to
 * fifty sheets.
 */
export const MaterialAccessBar = (props: MaterialAccessBarProps, context) => {
  const { availableMaterials, onEjectRequested } = props;

  return (
    <Flex wrap>
      {sortBy((m: Material) => MATERIAL_RARITY[m.name])(availableMaterials).map(
        (material) => (
          <Flex.Item key={material.name} grow={1}>
            <MaterialCounter
              material={material}
              onEjectRequested={(quantity) =>
                onEjectRequested && onEjectRequested(material, quantity)
              }
            />
          </Flex.Item>
        )
      )}
    </Flex>
  );
};

type MaterialCounterProps = {
  material: Material;
  onEjectRequested: (quantity: number) => void;
};

const MaterialCounter = (props: MaterialCounterProps, context) => {
  const { material, onEjectRequested } = props;

  const [hovering, setHovering] = useLocalState(
    context,
    `MaterialCounter__${material.name}`,
    false
  );

  const canEject = material.amount > 2_000;

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={classes([
        'MaterialDock',
        hovering && 'MaterialDock--active',
        !canEject && 'MaterialDock--disabled',
      ])}>
      <Stack vertial direction={'column-reverse'}>
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => onEjectRequested(1)}
          className="MaterialDock__Label">
          <Flex.Item>
            <MaterialIcon material={material} />
          </Flex.Item>
          <Flex.Item>
            <AnimatedNumber value={material.amount} format={LABEL_FORMAT} />
          </Flex.Item>
        </Flex>
        {hovering && (
          <div className={'MaterialDock__Dock'}>
            <Flex vertical direction={'column-reverse'}>
              <EjectButton
                material={material}
                available={material.amount}
                amount={5}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={10}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={25}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={50}
                onEject={onEjectRequested}
              />
            </Flex>
          </div>
        )}
      </Stack>
    </div>
  );
};

type EjectButtonProps = {
  material: Material;
  available: number;
  amount: number;
  onEject: (quantity: number) => void;
};

const EjectButton = (props: EjectButtonProps, context) => {
  const { amount, available, material, onEject } = props;

  return (
    <Button
      fluid
      color={'transparent'}
      className={classes([
        'Fabricator__PrintAmount',
        amount * 2_000 > available && 'Fabricator__PrintAmount--disabled',
      ])}
      onClick={() => onEject(amount)}>
      &times;{amount}
    </Button>
  );
};
