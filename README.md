# HN Reader

A small Flutter app that shows the Hacker News front page, lets you save favorite stories, and adds them to the device calendar.

Built for the Transylvania Star Group application task. Target platform: **Android** (the `device_calendar` package does not support web or desktop).

## Features

- **Front page list** from `https://hn.algolia.com/api/v1/search?tags=front_page`: title, publication date, author, number of comments and points. Pull down to refresh; loading, error (with Retry) and empty states.
- **Favorites**: tap the star on a story. Favorites are stored with `shared_preferences` and survive app restarts. A separate Favorites page lists them (details refreshed from `/items/:id`), and the red ❌ removes one.
- **Calendar export**: on the Favorites page, the calendar button asks for a day, requests calendar permission, creates the event and shows a confirmation message. The event contains the story title, author, link and publication date.
- **Open in browser**: tapping a story card (on either page) opens its URL in the external browser. Stories without a link (Ask HN etc.) open their Hacker News page.

Extras beyond the brief:

- **Feed tabs**: Top (the front page above), New (latest stories) and Ask (Ask HN).
- **Search**: a box above the list filters the loaded stories by title or author as you type.
- **Offline copy**: each feed's last list is saved on the device. If a refresh fails, the saved list is shown with an "Offline" banner.
- **Story page**: tap the comment count on any card to open the story with its full comment thread (loaded from `/items/:id`, replies indented). For Ask HN posts it also shows the post text.
- **Share**: a share button on the story page sends the title and link through the system share sheet (`share_plus`).
- **Soft-cards design** with light and dark themes that follow the system setting: a featured first story, green points badges, pill tabs and a floating navigation bar. Headings use Sora and body text DM Sans (via `google_fonts`).
- **Swipe actions**: swipe a story card right to save or unsave it, left to open its comments.
- **Read tracking**: stories you have opened (in the browser or the comments page) are dimmed with a check mark. A settings menu in the header can hide read stories.
- **Theme switch**: the same menu lets you choose light, dark or match-system; the choice is saved.
- **Animations**: staggered list entrance, cross-fade when switching feeds and tabs, a sliding highlight in the navigation bar, a bouncing favorite star, an expanding search field, cards that fade and collapse when removed, and a calendar button that turns into an "added" chip.

### Event time window

The time of the event depends on the weekday of the day you pick:

| Day | Time |
|---|---|
| Monday, Wednesday, Friday | 14:00 - 20:00 |
| Tuesday, Thursday | 12:00 - 18:00 |
| Saturday, Sunday | 08:00 - 12:00 |

## Run it

Requirements: Flutter 3.50 (stable), an Android emulator or phone.

```
flutter pub get
flutter run
```

The app needs a calendar to write to. If the device has no writable calendar (for example a fresh emulator with no Google account), the app creates a local calendar called "HN Favorites".

## Structure

```
lib/
  models/      story.dart                 Story data model (JSON in/out)
               comment.dart               Comment model, comment-tree flattening, HTML-to-text
               feed.dart                  the three feeds (Top / New / Ask)
  services/    hn_api.dart                HTTP calls to the Algolia API
               calendar_service.dart      permissions, calendar lookup, event creation, time-window rule
  providers/   stories_provider.dart      feed state: loading / error / data, search, offline copy
               favorites_provider.dart    favorites, persistence, calendar-export labels
               read_provider.dart         which stories have been opened
               settings_provider.dart     theme mode and "hide read"
  theme.dart                              light and dark colour schemes
  screens/     home_screen.dart           bottom navigation
               stories_screen.dart        feed tabs, search, story list
               favorites_screen.dart      favorites, remove, calendar export
               story_detail_screen.dart   story page with comments and share
  widgets/     story_card.dart            card shared by both lists, featured card, points badge
               pill_nav.dart              floating navigation bar
               swipe_actions.dart         swipe right to save, left for comments
               settings_menu.dart         theme and "hide read" menu
               star_button.dart           animated favorite star
               fade_slide_in.dart         staggered entrance animation
               screen_header.dart         caption and title above each page
```

State management is `provider` (`ChangeNotifier`). Screens only read state and call provider/service methods; HTTP, storage and calendar code live outside the UI.

## Design notes

- **One card, two lists.** `StoryCard` is used by both pages; each page passes its own buttons through the `trailing` slot.
- **Favorites keep a saved copy and are refreshed from `/items/:id`.** The saved copy lets the Favorites page open instantly and work offline. At app start and on pull-to-refresh, each favorite's details are re-fetched from `/items/:id`; if a request fails the saved copy is kept.
- **The day is chosen by the user.** The brief does not say which date the event should use, so the export asks for one and applies the weekday rule to it.
- **Event time zone.** Events are written as absolute (UTC) instants, so the calendar shows them at the correct local time. Using the phone's own time zone name would need an extra package (`flutter_timezone`); it was left out to keep the app small.

## Limitations

- Android only; iOS would additionally need calendar permission strings in `Info.plist`.
- On the Favorites page the comment count is computed from the `/items/:id` comment tree, so it can be slightly lower than the count on the front page, which also includes deleted comments.
- Search only looks at the stories already loaded in the current feed (20 per feed), not the whole of Hacker News.
- Comments are shown as plain text: HTML formatting and clickable links in comments are stripped.
- Upvoting is not possible: Hacker News has no voting API, only logged-in voting on its own website. The green badge only shows the points.
- The fonts are downloaded the first time the app runs online and then cached; until then (or if the first run is offline) the phone's default font is used. Bundling the font files would remove that.
- Animations don't yet respect the system "remove animations" accessibility setting.
- No automated tests.
