import { classes } from 'common/react';
import { Icon } from '../../components';

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
  'diamond': [
    [0, 'sheet-diamond'],
    [17, 'sheet-diamond_2'],
    [34, 'sheet-diamond_3'],
  ],
  'plasma': [
    [0, 'sheet-plasma'],
    [17, 'sheet-plasma_2'],
    [34, 'sheet-plasma_3'],
  ],
  'uranium': [
    [0, 'sheet-uranium'],
    [17, 'sheet-uranium_2'],
    [34, 'sheet-uranium_3'],
  ],
  'bananium': [
    [0, 'sheet-bananium'],
    [17, 'sheet-bananium_2'],
    [34, 'sheet-bananium_3'],
  ],
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

export type MaterialIconProps = {
  /**
   * The name of the material.
   */
  materialName: string;

  /**
   * The amount of material. One sheet is 2,000 units. By default, the icon
   * attempts to render a full stack (200,000 units).
   */
  amount?: number;
};

/**
 * A 32x32 material icon. Animates between different stack sizes of the given
 * material.
 */
export const MaterialIcon = (props: MaterialIconProps) => {
  const { materialName, amount } = props;
  const icons = MATERIAL_ICONS[materialName];

  if (!icons) {
    return <Icon name="question-circle" />;
  }

  let activeIdx = 0;

  while (
    icons[activeIdx + 1] &&
    icons[activeIdx + 1][0] <= (amount ?? 200_000) / 2_000
  ) {
    activeIdx += 1;
  }

  return (
    <div className={'FabricatorMaterialIcon'}>
      {icons.map(([_, iconState], idx) => (
        <div
          key={idx}
          className={classes([
            'FabricatorMaterialIcon__Icon',
            idx === activeIdx && 'FabricatorMaterialIcon__Icon--active',
            'sheetmaterials32x32',
            iconState,
          ])}
        />
      ))}
    </div>
  );
};
