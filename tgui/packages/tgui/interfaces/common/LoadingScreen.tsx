import { Icon, Stack } from 'tgui-core/components';

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
export function LoadingScreen(props) {
  return (
    <Stack align="center" fill justify="center" vertical>
      <Stack.Item>
        <Icon color="blue" name="toolbox" spin size={4} />
      </Stack.Item>
      <Stack.Item>Please wait...</Stack.Item>
    </Stack>
  );
}
