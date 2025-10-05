import { Flex } from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';

import { MaterialIcon } from './MaterialIcon';
import type { Design, MaterialMap } from './Types';

export type MaterialCostSequenceProps = {
  /**
   * A map of available materials.
   */
  available?: MaterialMap;

  /**
   * If provided, the materials to be consumed. By default, generated from
   * `design`; otherwise, an empty list.
   */
  costMap?: MaterialMap;

  /**
   * A design to generate the cost map from.
   */
  design?: Design;

  /**
   * The amount of times the provided design will be printed. By default, one.
   */
  amount?: number;

  /**
   * The `align-items` flex property provided to the generated list.
   */
  align?: string;

  /**
   * The `justify-content` flex property provided to the generated list.
   */
  justify?: string;

  /**
   * Definition of how much units 1 sheet has.
   */
  SHEET_MATERIAL_AMOUNT: number;
};

/**
 * A horizontal list of material costs, with labels.
 *
 * For a given material set that can only be printed once, the label for
 * offending materials is orange.
 *
 * For a given material set that can't be printed at all, the label for
 * offending materials is red.
 *
 * Otherwise, the labels are white.
 */
export const MaterialCostSequence = (props: MaterialCostSequenceProps) => {
  const { design, amount, available, align, justify, SHEET_MATERIAL_AMOUNT } =
    props;
  let { costMap } = props;

  if (!costMap && !design) {
    return null;
  }

  costMap ??= {};

  if (design) {
    for (const [name, value] of Object.entries(design.cost)) {
      costMap[name] = (costMap[name] || 0) + value;
    }
  }

  return (
    <Flex wrap justify={justify ?? 'space-around'} align={align ?? 'center'}>
      {Object.entries(costMap).map(([material, quantity]) => (
        <Flex.Item key={material} style={{ padding: '0.25em' }}>
          <Flex direction={'column'} align="center">
            <Flex.Item>
              <MaterialIcon
                materialName={material}
                sheets={((amount || 1) * quantity) / SHEET_MATERIAL_AMOUNT}
              />
            </Flex.Item>
            <Flex.Item
              style={
                available && {
                  color:
                    (amount || 1) * quantity * 2 <= available[material]
                      ? '#fff'
                      : (amount || 1) * quantity <= available[material]
                        ? '#f08f11'
                        : '#db2828',
                }
              }
            >
              {formatSiUnit(
                ((amount || 1) * quantity) / SHEET_MATERIAL_AMOUNT,
                0,
              )}
            </Flex.Item>
          </Flex>
        </Flex.Item>
      ))}
    </Flex>
  );
};
