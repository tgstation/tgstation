import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import { LoadoutItem } from '../interfaces/PreferencesMenu/loadout/base';
import { ImageButton } from './ImageButton';

export const ItemDisplay220 = (props: {
  active: boolean;
  item: LoadoutItem;
}) => {
  const { act } = useBackend();
  const { active, item } = props;
  const icon = item.icon;
  const iconState = item.icon_state;
  const costText =
    item.cost === 1
      ? `${item.cost} Очко`
      : item.cost < 4
        ? `${item.cost} Очка`
        : `${item.cost} Очков`;

  const textInfo = (
    <Box
      style={{
        display: 'flex',
        lineHeight: '1.2rem',
        textShadow: '0 1px 0 2px rgba(0, 0, 0, 0.66)',
        textAlign: 'left',
      }}
    >
      <Box style={{ flexGrow: 1 }} fontSize={1} color="gold" opacity={0.75}>
        {/* gear.gear_tier > 0 && `Tier ${gear.gear_tier}` */}
      </Box>
      <Box fontSize={0.75} opacity={0.66}>
        {costText}
      </Box>
    </Box>
  );

  const getIcon = (info: string) => {
    switch (info) {
      case 'Recolorable':
        return 'palette';
      case 'Renamable':
        return 'font';
      case 'Reskinnable':
        return 'paint-brush';
      case 'Prescription':
        return 'prescription';
      default:
        return 'question';
    }
  };

  return (
    <ImageButton
      key={item.name}
      imageSize={89}
      selected={active}
      dmIcon={icon}
      dmIconState={iconState}
      tooltip={item.name}
      tooltipPosition={'bottom'}
      buttons={item.information.map((info) => (
        <Button
          key={info}
          bold
          icon={getIcon(info)}
          width={'20px'}
          color={'transparent'}
          tooltip={info}
          tooltipPosition={'top'}
        />
      ))}
      buttonsAlt={textInfo}
      onClick={() =>
        act('select_item', {
          path: item.path,
          deselect: active,
        })
      }
    >
      {item.name}
    </ImageButton>
  );
};
