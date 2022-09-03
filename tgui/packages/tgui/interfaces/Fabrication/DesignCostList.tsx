import { Design, MaterialMap } from './Types';
import { Stack } from '../../components';
import { MaterialAmount, MATERIAL_KEYS, MaterialFormatting } from '../common/Materials';

export type DesignCostListProps = {
  /**
   * The design being printed.
   */
  design: Design;

  /**
   * The amount of times to print.
   */
  amount: number;

  /**
   * The materials available to complete the job.
   */
  available: MaterialMap;
};

/**
 * A horizontal sequence of material costs, indicating the effect of queueing
 * a print job. Orange labels indicate that the job can only be completed once,
 * and red labels indicate the job can't be completed at all.
 */
export const DesignCostList = (props: DesignCostListProps, context) => {
  const { design, amount, available } = props;

  return (
    <Stack wrap justify="space-around">
      {Object.entries(design.cost).map(([material, cost]) => (
        <Stack.Item key={material}>
          <MaterialAmount
            name={material as keyof typeof MATERIAL_KEYS}
            amount={cost * amount}
            formatting={MaterialFormatting.SIUnits}
            color={
              cost * amount > available[material]
                ? 'bad'
                : cost * amount * 2 > available[material]
                  ? 'average'
                  : 'normal'
            }
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};
