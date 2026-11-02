# Homework Note

A simple homework planner with a calendar home screen, styled after Apple's Human Interface Guidelines.

**Live app:** https://mr-lobster-dev.github.io/homework-note/

## Features

- Month calendar showing every event and task by title and color
- **Add event:** title, color, description, assigned date, due date, and attachments (photos, videos, PDFs, links)
- **Add task:** everything an event has, plus an instructions section and a "Mark as done" button
- Tap a day to see everything due or assigned that day; tap an item to expand its details
- Touch and hold (or right-click) an item to edit or delete it
- Light and dark mode

## Where your data is saved

Everything is saved in your browser (localStorage for items, IndexedDB for attached files), so it survives reloads and restarts. It stays on that browser and device only: clearing site data, or opening the app in a different browser, starts empty.

## Running locally

It's a single file with no build step. Open `index.html` in a browser, or serve the folder:

```sh
python3 -m http.server 8000
```
