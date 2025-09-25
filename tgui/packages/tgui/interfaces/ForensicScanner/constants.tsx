import {
  Box,
  Icon,
  LabeledList,
} from 'tgui-core/components';
import type { ReactElement } from 'react';

export const logFormatters: Record<string, ({ log, iconName, iconColor }: { log: Record<string, string | string[]>; iconName: string; iconColor: string; }) => ReactElement> = {
  'Blood': ({ log, iconName, iconColor }) =>
    <>
      {Object.entries(log).map(([key, value]) => (
        <Box key={key} py={0.5} style={{ textTransform: 'uppercase' }}>
          <Icon name={iconName} mr={1} color={iconColor} />
          {`${key}, ${value}`}
        </Box>
      ))}
    </>
  ,
  'Prints': ({ log, iconName, iconColor }) =>
    <>
      {Object.entries(log).map(([key, value]) => (
        <Box key={key} py={0.5} style={{ textTransform: 'uppercase' }}>
          <Icon name={iconName} mr={1} color={iconColor} />
          {value}
        </Box>
      ))}
    </>
  ,
  'Reagents': ({ log, iconName, iconColor }) =>
   <LabeledList>{Object.keys(log).map((reagent) => (<LabeledList.Item key={reagent} label={<><Icon name={iconName} mr={1} color={iconColor} />{reagent}</>}>
        {`${log[reagent]} u.`}
      </LabeledList.Item>
    ))}
  </LabeledList>,
  'ID Access': ({ log, iconName, iconColor }) => <LabeledList>
    {Object.keys(log).map((region) => (
      <LabeledList.Item key={region} label={<><Icon name={iconName} mr={1} color={iconColor} />{region}</>}>
        {log[region]}
      </LabeledList.Item>
    ))}
  </LabeledList>,
}
