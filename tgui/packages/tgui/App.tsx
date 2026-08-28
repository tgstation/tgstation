import { Provider } from 'jotai';
import { store } from './events/store';
import { RoutedComponent } from './routes';

export function App() {
  return (
    <Provider store={store}>
      <RoutedComponent />
    </Provider>
  );
}
