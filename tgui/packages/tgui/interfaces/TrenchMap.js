import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Box } from '../components';

export const TrenchMap = (props, context) => {
  const { act, data } = useBackend(context);
  const { map } = data;
  const textHtml = {
    __html: map,
  };
  return (
    <Window width={560} height={610}>
      <Box dangerouslySetInnerHTML={textHtml} />
    </Window>
  );
};
