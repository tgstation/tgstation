import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useContext,
} from 'react';

type LibraryContextType = {
  checkoutBookState: [boolean, Dispatch<SetStateAction<boolean>>];
  uploadToDBState: [boolean, Dispatch<SetStateAction<boolean>>];
};

export const LibraryContext = createContext<LibraryContextType>({
  checkoutBookState: [false, () => {}],
  uploadToDBState: [false, () => {}],
});

export function useLibraryContext() {
  return useContext(LibraryContext);
}
