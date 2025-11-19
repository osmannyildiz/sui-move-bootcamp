import { SuiObjectResponse } from "@mysten/sui/client";
import { ENV } from "../env";
import { getHero } from "../helpers/getHero";
import { getHeroSwordIds } from "../helpers/getHeroSwordIds";
import { Hero, parseHeroContent } from "../helpers/parseHeroContent";

const HERO_OBJECT_ID =
  "0x5b89d98e0b73963c23bba7e877d9ebe066bf793277242dcc887b5b9d9b6d74cd";

describe("Get Hero", () => {
  let objectResponse: SuiObjectResponse;

  beforeAll(async () => {
    objectResponse = await getHero(HERO_OBJECT_ID);
  });

  test("Hero Exists", () => {
    console.log("== Object Response: ", objectResponse);
    expect(objectResponse.data).toBeDefined();
    expect(objectResponse.data!.objectId).toBe(HERO_OBJECT_ID);
    expect(objectResponse.data!.type).toBe(`${ENV.PACKAGE_ID}::hero::Hero`);
  });

  test("Hero Content", () => {
    const hero: Hero = parseHeroContent(objectResponse);
    console.log("== Hero: ", hero);
    expect(hero.id).toBe(HERO_OBJECT_ID);
    expect(hero.stamina).toBeDefined();
    expect(hero.health).toBeDefined();
  });

  test("Hero Has Attached Swords", async () => {
    const swordIds = await getHeroSwordIds(objectResponse.data!.objectId);
    console.log("== Sword IDs: ", swordIds);
    expect(swordIds.length).toBeGreaterThan(0);
  });
});
