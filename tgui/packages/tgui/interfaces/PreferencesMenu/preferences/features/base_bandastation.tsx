import { Box, TextArea } from '../../../../components';
import { FeatureShortTextData, FeatureValueProps } from './base';

export const FeatureTextInput = (
  props: FeatureValueProps<string, string, FeatureShortTextData>,
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <TextArea
      height="100px"
      value={props.value}
      maxLength={props.serverData.maximum_length}
      onChange={(_, value) => props.handleSetValue(value)}
    />
  );
};
