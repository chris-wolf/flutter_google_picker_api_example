# Flutter Google Picker API Example

This example demonstrates how to integrate the Google Picker API into a Flutter application.

## Setup Instructions

To use this example, you need to configure your Google Cloud Console project and update the Flutter application with your credentials.

**1. Upload `google_picker.html`:**

*   Upload the `google_picker.html` file (located in the root of this project) to your web server. This file handles the Google Picker interaction.

**2. Configure Flutter Application:**

*   Open the `lib/main.dart` file in your Flutter project.
*   Locate the following placeholder variables:
    *   `_webUrl`: Set this to the public URL where you uploaded `google_picker.html`. For example, `https://your-domain.com/google_picker.html`.
        *   **Note on Web Server Configuration:** Ensure your web server is configured to correctly serve the `google_picker.html` file at this URL. If you are not directly linking to the `.html` file (e.g., if you are using clean URLs or a routing system), you might need to configure your server (e.g., using an `.htaccess` file on Apache, or similar configurations for Nginx or other servers) to ensure that requests to this path load the `google_picker.html` file.
    *   `_webClientId`: You will get this from the Google Cloud Console (see step 3).
    *   `_apiKey`: You will get this from the Google Cloud Console (see step 4).
    *   `_appId`: This is the numeric part of your `_webClientId`.

**3. Create OAuth 2.0 Client ID in Google Cloud Console:**

*   Go to the [Google Cloud Console](https://console.cloud.google.com/).
*   Navigate to "APIs & Services" -> "Credentials".
*   Click on "+ CREATE CREDENTIALS" and select "OAuth client ID".
*   Choose "Web application" as the application type.
*   Give it a name (e.g., "Flutter Google Picker Web Client").
*   Under "Authorised JavaScript origins", add the URL of your website where `google_picker.html` is hosted (e.g., `https://your-domain.com`). This must match the domain of your `_webUrl`.
*   Click "Create".
*   Copy the displayed "Client ID". This is your `_webClientId`.
*   The numeric part of this Client ID is your `_appId`. For example, if your Client ID is `1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`, then your `_appId` is `1234567890`.

**4. Create API Key in Google Cloud Console:**

*   In the Google Cloud Console, navigate to "APIs & Services" -> "Credentials".
*   Click on "+ CREATE CREDENTIALS" and select "API key".
*   Copy the generated API key. This is your `_apiKey`.
*   **Important:** Restrict your API key to prevent unauthorized use.
    *   Click on the newly created API key.
    *   Under "API restrictions", select "Restrict key".
    *   Add the "Google Picker API" to the list of allowed APIs.
    *   You might also want to set "Application restrictions" if applicable (e.g., "HTTP referrers" to restrict usage to your domain).

**5. Enable APIs:**

*   Make sure you have the "Google Picker API" and "Google Drive API" (if you intend to pick files from Drive) enabled in your Google Cloud Console project.
*   Navigate to "APIs & Services" -> "Library".
*   Search for "Google Picker API" and enable it.
*   Search for "Google Drive API" and enable it.

After completing these steps, you should be able to run the Flutter application, sign in with a Google account, and use the Google Picker to select files.
