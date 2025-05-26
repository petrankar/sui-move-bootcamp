import { SuiObjectChange, SuiObjectChangeCreated } from '@mysten/sui/client';
import { ENV } from '../env';

interface Args {
  objectChanges: SuiObjectChange[];
}

interface Response {
  heroesIds: string[];
}

/**
 * Parses the provided SuiObjectChange[].
 * Extracts the IDs of the created Heroes and Weapons NFTs, filtering by objectType.
 */
export const parseCreatedObjectsIds = ({ objectChanges }: Args): Response => {
  const createdHeroes = objectChanges.filter((change) => {
    return change.type === 'created' && change.objectType === `${ENV.PACKAGE_ID}::hero::Hero`;
  }) as SuiObjectChangeCreated[];

  return {
    heroesIds: createdHeroes.map(({ objectId }) => objectId),
  };
};
