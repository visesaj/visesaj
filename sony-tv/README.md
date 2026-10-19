# Sony XR-65X90L: remove ads and get a cleaner home screen

The X90L runs Google TV. You can't root it, but these steps take out almost
all of the ads and swap in a simpler home screen. Each step can be undone.

## 1. Built-in settings (5 minutes, no tools needed)

1. **Apps-only mode:** Settings → Accounts & Sign-In → your Google account → turn on **Apps only mode**.
   This removes the "For You" recommendations and the sponsored banner. You lose Google Assistant
   recommendations, but your apps and casting still work.
2. **Sony ad and tracking settings:** Settings → System → About → Legal Information:
   - turn off **Samba Interactive TV** (if it's listed)
   - Privacy settings → turn off **Advertising / Personalised ads**
3. **Google ads ID:** Settings → Privacy → Ads → **Delete advertising ID**.

## 2. A cleaner home screen (Projectivy Launcher)

Google TV has no Apple TV home screen to install, but **Projectivy Launcher** comes close. It shows
a grid of your app icons with large artwork and no ads.

1. Install **Projectivy Launcher** from the Play Store on the TV.
2. Open it → Settings → General → turn on **Override current launcher** and allow the
   accessibility permission when it asks. The Home button now opens Projectivy.
3. Pick a wallpaper and an icon style, and hide the apps you don't use.

## 3. Turn off ad services with `declutter.sh` (optional, from a laptop)

1. On the TV, go to Settings → System → About and press OK on **Build** 7 times. That turns on
   Developer options.
2. Developer options → turn on **USB debugging** and **ADB over network**. Note the TV's IP from
   Settings → Network.
3. On a Mac or PC on the **same Wi-Fi**, install
   [Android platform-tools](https://developer.android.com/tools/releases/platform-tools)
   (`brew install android-platform-tools` on a Mac).
4. Run:
   ```bash
   ./declutter.sh 192.168.1.50 list      # see what's on your firmware
   ./declutter.sh 192.168.1.50           # disable the ad/promo packages (asks first)
   ./declutter.sh 192.168.1.50 restore   # undo
   ```

The script only *disables* packages. It never uninstalls anything, and a factory reset also
undoes it. Don't disable the Google TV home app (`com.google.android.apps.tv.launcherx`).
Some firmware versions need it, and Projectivy works around it.

## 4. Block ads for the whole network (optional)

Point your router's DNS at **NextDNS** (easy) or a **Pi-hole** (self-hosted). This blocks ad and
telemetry domains on every device, including the TV. You can use the same setup for guest Wi-Fi
in hospitality properties.

Ads inside apps like YouTube can't be blocked this way. Removing those takes YouTube Premium or a
similar subscription.
