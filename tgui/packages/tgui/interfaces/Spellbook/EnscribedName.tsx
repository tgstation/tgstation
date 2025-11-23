import { Box, Divider } from 'tgui-core/components';
import { useBackend } from '../../backend';
import type { SpellbookData } from './types';

export function EnscribedName(props) {
  const { data } = useBackend<SpellbookData>();
  const { owner } = data;

  return (
    <>
      <Box
        mt={25}
        mb={-3}
        fontSize="50px"
        color="bad"
        textAlign="center"
        fontFamily="Ink Free"
      >
        {owner}
      </Box>
      <Divider />
    </>
  );
}
