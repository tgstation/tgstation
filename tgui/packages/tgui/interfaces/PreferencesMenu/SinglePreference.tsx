import { LabeledList, Stack } from 'tgui-core/components';

import { sendAct } from '../../backend';
import features from './preferences/features';
import { FeatureValueInput } from './preferences/features/base';

export const PreferenceSingle = (props: {
  act: typeof sendAct;
  pref_key: string;
  preferences: Record<string, unknown>;
}) => {
  const feature = features[props.pref_key];
  const value = props.preferences[props.pref_key];

  if (feature === undefined) {
    return (
      <Stack.Item key={props.pref_key}>
        <b>Feature {props.pref_key} is not recognized.</b>
      </Stack.Item>
    );
  }

  return (
    <LabeledList.Item
      key={props.pref_key}
      label={feature.name}
      tooltip={feature.description}
      verticalAlign="middle"
    >
      <Stack.Item grow>
        <FeatureValueInput
          act={props.act}
          feature={feature}
          featureId={props.pref_key}
          value={value}
        />
      </Stack.Item>
    </LabeledList.Item>
  );
};
