// Calls the real OpenAI API with the Worker's own request. Skipped by
// default; costs a fraction of a cent per run. Run it in your own terminal,
// where the key is typed without being shown or saved:
//
//   read -rs "OPENAI_API_KEY?OpenAI key: " && export OPENAI_API_KEY
//   LIVE_AI_TEST=1 npx vitest run test/live.test.ts; unset OPENAI_API_KEY
//
// Read the printed plans too: whether each day stays in one area near the
// accommodation can only be judged by a person.

import { describe, expect, it } from 'vitest';

import { MAX_TRIP_DAYS, planTrip, type TripRequest } from '../src/tripPlan';

const enabled = process.env.LIVE_AI_TEST === '1';
const key = process.env.OPENAI_API_KEY ?? '';

interface Activity {
  time: string;
  place: string;
  area: string;
  travel: string;
  description: string;
}
interface Day {
  area: string;
  theme: string;
  activities: Activity[];
}

function inAMonth(): string {
  const date = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  return date.toISOString().slice(0, 10);
}

async function plan(trip: Omit<TripRequest, 'startDate' | 'language'>, label: string) {
  const started = Date.now();
  const outcome = await planTrip({ ...trip, startDate: inAMonth(), language: 'en' }, key);
  console.log(`[${label}] ${Date.now() - started} ms | status ${outcome.status} | ${JSON.stringify(outcome.log)}`);
  const days = (outcome.body.days ?? []) as Day[];
  console.log(`  Accommodation: ${trip.accommodation}`);
  days.forEach((day, i) => {
    console.log(`  Day ${i + 1}: ${day.theme}  [${day.area}]`);
    for (const a of day.activities) console.log(`    - ${a.time}: ${a.place} (${a.area}) – ${a.description}\n      Getting there: ${a.travel}`);
  });
  return { outcome, days };
}

function expectPlannedByModel(days: Day[]) {
  for (const day of days) {
    expect(day.area, day.theme).not.toBe('');
    expect(day.activities.length, day.theme).toBeGreaterThanOrEqual(3);
    for (const activity of day.activities) expect(activity.travel, activity.place).not.toBe('');
  }
}

describe.skipIf(!enabled)('real OpenAI API', () => {
  it('rejects a bad key with 401', async () => {
    const outcome = await planTrip(
      { startDate: inAMonth(), lengthInDays: 1, accommodation: 'Downtown Dubai', interests: ['Attractions'], language: 'en' },
      'sk-invalid-live-check',
    );
    expect(outcome.status).toBe(502);
    expect(outcome.log).toMatchObject({ openai_status: 401, openai_code: 'invalid_api_key' });
  });

  describe.skipIf(!key.startsWith('sk-'))('with a real key', () => {
    it('3-day plan: every day planned by the model, in an area, with directions', async () => {
      const { outcome, days } = await plan(
        { lengthInDays: 3, accommodation: 'Dubai Marina', interests: ['Beaches', 'Restaurants', 'Rooftops'] },
        '3 days',
      );
      expect(outcome.status).toBe(200);
      expect(days).toHaveLength(3);
      expectPlannedByModel(days);
      expect(JSON.stringify(days)).not.toContain('â€');
    }, 240_000);

    it(`${MAX_TRIP_DAYS}-day plan, the longest allowed: all days, within the timeout`, async () => {
      const { outcome, days } = await plan(
        {
          lengthInDays: MAX_TRIP_DAYS,
          accommodation: 'Rove Downtown',
          interests: ['Attractions', 'Shopping', 'Desserts', 'Nightlife', 'Theme parks'],
        },
        `${MAX_TRIP_DAYS} days`,
      );
      expect(outcome.status).toBe(200);
      expect(days).toHaveLength(MAX_TRIP_DAYS);
      expectPlannedByModel(days);
    }, 240_000);
  });
});
