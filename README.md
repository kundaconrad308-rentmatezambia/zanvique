# Zanvique — Website + Android starter application

This is a shared-codebase Progressive Web App (PWA) that can be published as a website and wrapped as an Android app using Capacitor.

## Included in this build
- Responsive marketplace website and installable PWA shell
- Supabase email sign-up/sign-in
- Public marketplace listings stored online
- Create, edit and delete your own listings
- Province, town, category and keyword search for Zambia
- Listing image upload to Supabase Storage
- Seller WhatsApp contact
- User dashboard, profile, favourites and notifications screen
- Business profiles/directory
- Listing reviews and ratings
- Featured listing requests and admin approval screen
- SQL schema and row-level security policies

## Important: connect your existing Supabase project
1. Open `index.html`.
2. Find `const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";`
3. Replace only the placeholder with your Supabase **publishable/anon public key**. Never put a `service_role` key in a browser or Android app.
4. In Supabase, open SQL Editor, create a new query, paste all of `supabase-setup.sql`, and run it.
5. In Authentication > Providers, enable Email. For testing, configure email confirmation as you prefer.
6. Create your first account in Zanvique.

The project URL is already set to the user's existing project:
`https://uqfzuspzmwbttgiulkof.supabase.co`

The app uses the canonical table name `public.listings` in lowercase. Do not create a second table named `Listing` or `listing`.

## Website deployment to GitHub Pages
1. Extract this ZIP.
2. Upload/replace the files in your existing GitHub repository `kundaconrad308-rentmatezambia/zanvique`.
3. Keep `index.html`, `manifest.webmanifest`, `sw.js` and `icon.svg` in the repository root.
4. In repository Settings > Pages, select Deploy from a branch, branch `main`, folder `/root` (or the branch/folder already used by your live site).
5. Open `https://kundaconrad308-rentmatezambia.github.io/zanvique/`.

## Android application
This package includes a Capacitor configuration. To create an Android Studio project on a computer with Node.js installed:
```bash
npm install
npx cap add android
npx cap sync android
npx cap open android
```
Build an APK from Android Studio: Build > Build Bundle(s) / APK(s) > Build APK(s).

A computer is needed for the Android Studio build. The same app can be installed on Android as a PWA from Chrome before producing a Play Store APK.

## Test checklist
- Sign up and sign in
- Publish a listing with province, town, phone and description
- Upload an image
- Open the listing from another browser/account
- Test filters and WhatsApp contact
- Edit and delete your own listing
- Create a business profile
- Test reviews and favourites
- Grant admin access to your account using the SQL comment at the bottom of `supabase-setup.sql`

## Features that need external services or further production work
- Real push notifications need a push provider and service worker push subscription.
- Maps currently require adding coordinates/geocoding and a map provider; the listing data model can be extended.
- Payment collection, mobile money checkout, paid promotion billing and delivery dispatch require contracts/API credentials from providers.
- Admin account moderation and report handling need additional moderation workflows.
- Email/password auth is included; password reset and social login can be added next.
- The town directory is an initial list of major towns, and can be expanded.

## Security notes
- Only the public anon/publishable key belongs in frontend code.
- Never expose a Supabase service role key.
- Review RLS policies before accepting payments or storing sensitive user information.
- This is a functional first release foundation, not yet a fully audited production marketplace.
