# Dubai Trip Planner API

A Cloudflare Worker (free plan) between the app and the paid APIs. It is the
only place that holds the OpenAI and OpenWeather keys.

| Route | Does |
|---|---|
| `POST /trip-plan` | Checks the trip form, builds the prompt and the schema, asks OpenAI (`gpt-6-luna`) and answers `{"days": [...]}` |
| `GET /weather` | Answers the Dubai forecast in OpenWeather's shape, `{"list": [...]}`, from a 30-minute cache |

Every request needs a Firebase App Check token in the `X-Firebase-AppCheck`
header (project `dubaitripplanner-ae015`, Android or iOS app); without one the
Worker answers 401. Trip plans are limited to 5 a minute per IP address.
Errors are JSON: `{"error": "<code>"}`.

## Commands

```sh
npm install
npm test             # unit tests, no network
npm run typecheck
npx wrangler login   # once, opens the browser
npm run deploy       # wrangler deploy
npx wrangler tail    # live logs
```

## Secrets

Set them in your own terminal; wrangler asks for the value without showing it,
and it is never written to a file:

```sh
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put OPENWEATHER_API_KEY
npx wrangler secret list   # names only, never the values
```

To change a key, create the new one, `secret put` it (it takes effect at
once, without an app update), then delete the old one at OpenAI or
OpenWeather.

## Live OpenAI test

Skipped by default; costs a fraction of a cent. Type the key without it being
shown or saved:

```sh
read -rs "OPENAI_API_KEY?OpenAI key: " && export OPENAI_API_KEY
LIVE_AI_TEST=1 npx vitest run test/live.test.ts; unset OPENAI_API_KEY
```

## Limits of the free plan

100,000 requests a day for the whole Worker; above that Workers Paid costs
$5 a month. App Check tokens last about an hour and can be used more than
once until then: one-time tokens need the Firebase Admin SDK, which does not
run on Workers. OpenAI's prepaid credit is the upper bound of what misuse can
cost.
