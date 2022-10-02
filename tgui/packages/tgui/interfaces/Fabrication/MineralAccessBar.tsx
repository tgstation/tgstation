import { sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import { Flex, Button, Stack, AnimatedNumber } from '../../components';
import { formatSiUnit } from '../../format';
import { Material, MaterialIcon } from '../common/Materials';
import { MaterialName } from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MINERAL_RARITY: Record<MaterialName, number> = {
  'iron': 1,
  'glass': 0,
  'silver': 5,
  'gold': 6,
  'diamond': 8,
  'plasma': 4,
  'uranium': 7,
  'bananium': 10,
  'titanium': 3,
  'bluespace crystal': 9,
  'plastic': 2,
};

export type MineralAccessBarProps = {
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
export const MineralAccessBar = (props: MineralAccessBarProps, context) => {
  const { availableMaterials, onEjectRequested } = props;

  return (
    <Flex wrap>
      {sortBy((m: Material) => MINERAL_RARITY[m.name])(availableMaterials).map(
        (material) => (
          <Flex.Item key={material.name} grow={1} shrink={1}>
            <MineralCounter
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

type MineralCounterProps = {
  material: Material;
  onEjectRequested: (quantity: number) => void;
};

const MineralCounter = (props: MineralCounterProps, context) => {
  const { material, onEjectRequested } = props;

  const [hovering, setHovering] = useLocalState(
    context,
    `MaterialCounter__${material.name}`,
    false
  );

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={`MaterialDock ${hovering ? 'MaterialDock--active' : ''}`}>
      <Stack vertial direction={'column-reverse'}>
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => onEjectRequested(1)}>
          <Flex.Item>
            <MaterialIcon material={material.name} />
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
      className={`Fabricator__PrintAmount ${
        amount * 2_000 > available ? 'Fabricator__PrintAmount--disabled' : ''
      }`}
      onClick={() => onEject(amount)}>
      &times;{amount}
    </Button>
  );
};
