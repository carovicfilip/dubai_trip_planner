# Privacy Policy

**Last updated: November 11, 2026**

## 1. Introduction

This Privacy Policy explains how the Dubai Trip Planner mobile application (the "App") handles information. The App is developed and operated by Filip Carovic, an individual developer based in Serbia ("we", "us", "our").

**In short:**

- The App has no user accounts. You never give us your name or email address in the App.
- Your favorites, trip plans and settings are stored only on your device.
- When you ask the App to create a trip plan, the trip details you entered go to our server, which asks OpenAI to write the plan. Our server does not store your trip details.
- Subscriptions are bought through Apple or Google. We never see your payment details. Superwall shows the subscription screens and keeps track of your subscription status for us.
- The App does not ask for your location, does not show ads and does not track you across other companies' apps or websites.

## 2. Information Stored on Your Device

The App stores the following information on your device, in the standard app storage of iOS or Android:

- Places you save as favorites
- Trip plans you create, including the trip details you entered (start date, number of days, hotel name or area, and selected interests), the generated itinerary, any items you add or change, and whether the plan is unlocked
- Your settings: app language and light or dark theme
- Technical flags, such as whether you have completed the introduction screens, whether the App has already asked how you like it, whether you have used your free trip plan, and whether you have already seen the one-time subscription offer
- The most recent weather forecast for Dubai, so it can be shown without downloading it again
- Data that Superwall keeps on your device, such as a random identifier, the subscription screens it has downloaded and how many times you have seen them (see section 4.4)

We cannot see or access this information. The App does not add its own encryption layer. The information is protected by your device's built-in security, such as your passcode and the operating system's storage protections.

If you use device backups, such as iCloud Backup or Google backup, this information may be included in those backups. In that case, Apple's or Google's terms apply to it.

## 3. Our Server

The App uses a small server of our own for two things: creating trip plans and getting the weather forecast. The server runs on Cloudflare, which hosts it for us. The server keeps our keys for OpenAI and OpenWeather, so they are never stored in the App.

**What the server receives.** When you create a trip plan, the server receives the trip start date, the number of days, the hotel name or area you entered, the interests you selected and the language of the App. For the weather, it receives only a request for the forecast. Every request also carries a security token from Firebase App Check (see section 4.3) and, like any internet connection, your device's IP address and standard technical information.

**What the server does with it.**

- It passes your trip details to OpenAI and sends the plan back to your device. It does not store your trip details.
- It uses your IP address to limit how many trip plans can be requested in a short time, which protects the service from abuse. We do not store your IP address for this.
- It shares one weather forecast for central Dubai with all users.

**Technical logs.** Cloudflare keeps technical logs of the requests to our server, such as the time of the request, the address requested, the result, whether the request came from iOS or Android, the number of days and the language of a trip plan, and related request information that Cloudflare records. These logs do not contain the hotel name or area or the interests you entered. Cloudflare deletes them after 3 days. We use them only to keep the service running and to find errors.

Cloudflare privacy policy: [https://www.cloudflare.com/privacypolicy/](https://www.cloudflare.com/privacypolicy/)

## 4. Information Sent to Third-Party Services

### 4.1 OpenAI: AI trip plans

When you ask the App to create a trip plan, our server sends OpenAI:

- the trip start date and number of days,
- the hotel name or area you entered,
- the interests you selected, and
- the language of the App.

OpenAI receives these details from our server, not from your device, so it does not receive your IP address. The App does not send your name, email address, contacts, location or any device identifier. Please do not enter personal information in the hotel name or area field.

OpenAI uses this information to generate the itinerary, which our server sends back to your device, where it is saved. OpenAI may keep request data for a limited time under its own policies.

Privacy policy: [https://openai.com/policies/privacy-policy](https://openai.com/policies/privacy-policy)

### 4.2 OpenWeather: weather forecast

Our server requests the weather forecast for a fixed location in central Dubai. No information about you or your device is sent to OpenWeather.

Privacy policy: [https://openweathermap.org/privacy-policy](https://openweathermap.org/privacy-policy)

### 4.3 Firebase App Check: protecting our server

To make sure that requests to our server come from the genuine App on a genuine device, the App uses Firebase App Check, a Google service. App Check uses Apple's App Attest on iOS and Google Play Integrity on Android. For this check, information about the integrity of the App and your device is sent to Apple or Google and to Firebase. If the check succeeds, the App receives a security token that is valid for a limited time, at most 7 days, and sends it with its requests to our server.

App Check does not receive your trip details, your name or your email address.

Privacy policies: [https://policies.google.com/privacy](https://policies.google.com/privacy) and [https://firebase.google.com/support/privacy](https://firebase.google.com/support/privacy)

### 4.4 Superwall: subscription screens and subscription status

The App uses Superwall, a service of Nest 22, Inc., to show the subscription screens, to test different versions of them, to measure how often they are viewed and lead to a purchase, and to keep track of whether you have an active subscription. Superwall processes this information on our behalf. Superwall receives:

- a random identifier created for the App on your device, and on iOS Apple's identifier for vendor, an identifier that is specific to our App and is not used for advertising,
- information about your device and the App, such as the device model, operating system version, App version, language, region, currency, time zone, network type, light or dark mode and low power mode,
- your approximate location, such as country, region and city, which Superwall estimates from your IP address,
- your interactions with the subscription screens, such as when a screen is shown or closed and when a purchase is started, completed or canceled, and
- information about your subscription and purchases that Apple or Google share with Superwall, such as the product, price, purchase and renewal dates, and subscription status.

Superwall does not receive your name, email address, trip details or payment card details. We do not use this information for advertising, and we do not use your device's advertising identifier.

Privacy policy: [https://superwall.com/legal/privacy-policy](https://superwall.com/legal/privacy-policy)

### 4.5 Apple App Store and Google Play

**Purchases.** Subscriptions are sold and paid for through the Apple App Store or Google Play. Apple or Google process your payment. We never receive your payment card details, name or email address. Apple or Google share information about your subscription with us through Superwall, such as the product, price, dates and subscription status, so that the App can unlock the features you have paid for.

**Ratings.** At one point, the App asks how you like it. Your answer is neither stored nor sent anywhere. The App only saves the fact that the question was asked. If you choose the happy face, the App may ask Apple or Google to show their standard rating window. Any rating or review you leave there is handled by Apple or Google under their own policies.

**Statistics.** Apple and Google may also give us aggregated statistics, such as the number of downloads, and crash reports if you have allowed your device to share this kind of data with app developers. This information does not identify you to us.

### 4.6 Google Fonts: fonts

The App downloads its fonts from Google Fonts the first time they are needed, then keeps them on your device.

Privacy policy: [https://policies.google.com/privacy](https://policies.google.com/privacy)

### 4.7 Links

The Privacy Policy and Terms of Use links in the App and on the subscription screens open our website in your browser. The website is not part of the App.

## 5. What the App Does Not Do

- It has no accounts or sign-in.
- It does not ask for location permission and does not use your device's location. Superwall's estimate of your approximate location from your IP address is described in section 4.4.
- It does not access your contacts, photos, camera or microphone.
- It does not show ads, does not use advertising identifiers and does not track you across other companies' apps or websites.
- We do not sell your personal information or share it for advertising.

## 6. How We Use Information and Our Legal Bases

We use information only to:

- create the trip plans you ask for,
- sell subscriptions, keep track of your subscription status and unlock the features you have paid for,
- protect our server and the App from abuse,
- show the weather forecast and load fonts,
- understand how the subscription screens perform and improve them,
- fix problems and improve the App, using statistics and crash reports from Apple and Google, and
- reply to emails you send us.

If the EU General Data Protection Regulation (GDPR), the UK GDPR or the Law on Personal Data Protection of the Republic of Serbia applies to you, our legal bases are:

- **Providing the service you request (performance of a contract)**, for creating trip plans and for selling and managing your subscription.
- **Our legitimate interests** in running, securing and improving the App, for protecting our server (App Check, request limits and technical logs), for the weather forecast and fonts, for measuring and testing the subscription screens, for statistics and crash reports, and for replying to your emails.

## 7. Data Retention

- **On your device:** until you delete it in the App (for example, by removing a favorite or deleting a trip plan), clear the App's data, or uninstall the App.
- **On our server:** trip details are not stored. Technical logs are deleted after 3 days.
- **Firebase App Check:** security tokens are valid for at most 7 days. Firebase does not keep the device integrity information.
- **Superwall:** for as long as we use Superwall's service, under its data processing terms.
- **Apple and Google:** purchase records are kept under their own policies.
- **Other third-party services:** as described in their own privacy policies.
- **Emails:** only as long as needed to handle your request.

## 8. International Data Transfers

Cloudflare, Google, Superwall and OpenAI may process data on servers outside your country, including in the United States. Their privacy policies and data processing terms describe how they protect such transfers, for example with the European Commission's Standard Contractual Clauses.

## 9. Security

The App uses encrypted HTTPS connections. Our keys for OpenAI and OpenWeather are stored only on our server, and Firebase App Check helps ensure that only the genuine App can use the server. Information stored on your device is protected by your device's security features. No method of storage or transmission is completely secure, but we work to keep the App safe.

## 10. Your Rights

Depending on where you live, for example in the EEA, the UK, Serbia or California, you may have the right to:

- access your personal data,
- correct or delete it,
- restrict or object to its processing,
- receive it in a portable format,
- withdraw consent, where processing is based on consent, and
- lodge a complaint with a data protection authority. In Serbia, this is the Commissioner for Information of Public Importance and Personal Data Protection.

Most of your data is stored only on your device, so you can view, change and delete it directly in the App. You can also clear the App's data or uninstall the App.

The information that reaches our service providers is not linked to your name or email address. For that reason, we usually cannot link it to you. You can still contact us, and we will help as far as we can.

To cancel a subscription, use your Apple ID or Google Play account settings, as explained in our [Terms of Use](https://dubaitripplanner.app/terms-of-use). Uninstalling the App does not cancel a subscription.

## 11. Children's Privacy

The App is not intended for children under 13, or under the minimum age required in your country. We do not knowingly collect personal information from children. If you believe a child has sent us personal information, please contact us at [carovic.filip@gmail.com](mailto:carovic.filip@gmail.com), and we will delete it.

## 12. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. When we do, we will publish the new version on this page and change the "Last updated" date. If we make significant changes, we may also let you know in the App or in its store listing.

## 13. Contact Us

If you have questions or requests about this Privacy Policy, please contact us:

- **Email:** [carovic.filip@gmail.com](mailto:carovic.filip@gmail.com)
- **Data controller:** Filip Carovic, Serbia

We aim to reply within 30 days.
