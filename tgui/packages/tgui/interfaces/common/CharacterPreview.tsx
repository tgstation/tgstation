import { ByondUi } from '../../components';

export const CharacterPreview = (props: { height: string; id: string }) => {
  return (
    <ByondUi
      width="228px"
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
