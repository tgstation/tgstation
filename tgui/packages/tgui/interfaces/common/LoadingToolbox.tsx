import { Dimmer, Icon, Stack } from '../../components';

/** Spinner that represents loading states.
 *
 * @usage
 * ```tsx
 * /// rest of the component
 * return (
 * ///... content to overlay
 * {!!loading && <LoadingScreen />}
 * /// ... content to overlay
 * );
 * ```
 * OR
 * ```tsx
 * return (
 * {loading ? <LoadingScreen /> : <ContentToHide />}
 * )
 * ```
 */
export const LoadingScreen = (props) => {
  return (
    <Dimmer>
      <Stack align="center" fill justify="center" vertical>
        <Stack.Item>
          <Icon color="blue" name="toolbox" spin size={4} />
        </Stack.Item>
        <Stack.Item>Please wait...</Stack.Item>
      </Stack>
    </Dimmer>
  );
};
