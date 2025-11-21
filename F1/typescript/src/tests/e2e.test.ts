import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { getHeroesRegistry } from "../helpers/getHeroesRegistry";
import { getWeaponIdOfHero } from "../helpers/getWeaponIdOfHero";
import { mintHeroWithWeapon } from "../helpers/mintHeroWithWeapon";
import { parseCreatedObjectsIds } from "../helpers/parseCreatedObjectIds";
import { suiClient } from "../suiClient";

describe("Mint a Hero NFT, a Weapon NFT and equip it", () => {
  let txResponse: SuiTransactionBlockResponse;
  let heroId: string | undefined;
  let heroesIds: string[] = [];

  beforeAll(async () => {
    txResponse = await mintHeroWithWeapon();
    await suiClient.waitForTransaction({
      digest: txResponse.digest,
      timeout: 5_000,
    });
    console.log("Executed transaction with txDigest:", txResponse.digest);
  });

  test("Transaction Status", () => {
    expect(txResponse.effects).toBeDefined();
    expect(txResponse.effects!.status.status).toBe("success");
  });

  test("Created Hero", async () => {
    expect(txResponse.objectChanges).toBeDefined();
    console.log("== Object Changes: ", txResponse.objectChanges);
    const { heroesIds } = parseCreatedObjectsIds({
      objectChanges: txResponse.objectChanges!,
    });
    expect(heroesIds.length).toBe(1);
    heroId = heroesIds[0];
  });

  test("Hero is equiped with a Weapon", async () => {
    const weaponId = await getWeaponIdOfHero(heroId!);
    expect(weaponId).toBeDefined();
  });

  test("Heroes registry", async () => {
    const { ids, counter } = await getHeroesRegistry();
    heroesIds = ids;
    expect(ids.length).toBeGreaterThan(0);
    expect(ids).toContain(heroId);
    expect(counter).toBeGreaterThan(0);
  });
});
