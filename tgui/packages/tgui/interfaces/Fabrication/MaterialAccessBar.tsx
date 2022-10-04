import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { useLocalState } from '../../backend';
import { Flex, Button, Stack, AnimatedNumber } from '../../components';
import { formatSiUnit } from '../../format';
import { MaterialIcon } from './MaterialIcon';
import { Material } from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MATERIAL_RARITY: Record<string, number> = {
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
            <MaterialIcon
              materialName={material.name}
              amount={material.amount}
            />
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
