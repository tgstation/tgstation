import { Box, TextArea } from '../../../../../../components';
import { Feature, FeatureShortTextData, FeatureValueProps } from '../../base';

export type FeatureMultiline = Feature<string, string, FeatureShortTextData>;
export type FeatureMultilineProps = FeatureValueProps<
  string,
  string,
  FeatureShortTextData
>;

export const MultilineText = (
  props: FeatureMultilineProps & {
    box_height: string | null;
  },
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }
  return (
    <TextArea
      width="80%"
      height={props.box_height || '36px'}
      value={props.value}
      maxLength={props.serverData.maximum_length || 1024}
      onChange={(_, new_value) => {
        props.handleSetValue(new_value);
      }}
    />
  );
};

export const flavor_text: FeatureMultiline = {
  name: 'Flavor - Flavor Text',
  description:
    'A small snippet of text shown when others examine you, \
    describing what you may look like.',
  component: (props: FeatureMultilineProps) => {
    return <MultilineText {...props} box_height="52px" />;
  },
};

export const silicon_text: FeatureMultiline = {
  name: 'Flavor - Silicon Flavor Text',
  description: 'Flavor text shown when you are placed into a cyborg or AI.',
  component: MultilineText,
};

export const exploitable_info: FeatureMultiline = {
  name: 'Flavor - Exploitable Info',
  description:
    'Information about your character made available to \
    players who are antagonists. Can be used to give antagonists \
    more interesting ways of approaching your character.',
  component: MultilineText,
};

export const general_records: FeatureMultiline = {
  name: 'Flavor - General Records',
  description:
    "Random information about your character's history. \
    Available in medical records consoles.",
  component: MultilineText,
};

export const security_records: FeatureMultiline = {
  name: 'Flavor - Security Records',
  description:
    "Information about your character's criminal past. \
    Available in security records consoles.",
  component: MultilineText,
};

export const medical_records: FeatureMultiline = {
  name: 'Flavor - Medical Records',
  description:
    "Information about your character's medical history. \
    Available in medical records consoles.",
  component: MultilineText,
};
