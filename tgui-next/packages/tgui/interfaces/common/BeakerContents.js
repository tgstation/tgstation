import { Box } from '../../components';

export const BeakerContents = props => {
  const { beakerLoaded, beakerContents } = props;
  return (
    <Box>
      {!beakerLoaded && (
        <Box color="label" content="No beaker loaded." />
      ) || beakerContents.length === 0 && (
        <Box color="label" content="Beaker is empty." />
      )}
      {beakerContents.map(chemical => (
        <Box key={chemical.name} color="label">
          {chemical.volume} units of {chemical.name}
        </Box>
      ))}
    </Box>
  );
};
