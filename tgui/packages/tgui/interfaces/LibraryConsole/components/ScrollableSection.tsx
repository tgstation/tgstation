import { Box, Section } from 'tgui-core/components';

export function ScrollableSection(props) {
  const { header, contents } = props;

  return (
    <Section fill scrollable>
      <Box fontSize="20px" textAlign="center">
        {header}
      </Box>
      <Box position="relative" top="10px">
        {contents}
      </Box>
    </Section>
  );
}
