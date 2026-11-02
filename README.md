# Homework Note

A simple homework planner with a calendar home screen, styled after Apple's Human Interface Guidelines.

**Live app:** https://mr-lobster-dev.github.io/Homework-Note/

## Features

- Month calendar showing every event and task by title and color
- **Add event:** title, color, description, assigned date, due date, and attachments (photos, videos, PDFs, links)
- **Add task:** everything an event has, plus an instructions section and a "Mark as done" button
- **To do list:** everything not yet marked done, grouped as Overdue, High, Medium and Low urgency, and Coming up
- **To-dos:** like a task, but with no due date. They have an urgency level (Low, Medium or High) that rises one level every 3 days until it reaches High, unless you turn that off
- Events and tasks can both be marked as done
- Tap a day to see everything due or assigned that day; tap an item to expand its details
- Touch and hold (or right-click) an item to edit or delete it
- Light and dark mode

## Where your data is saved

By default everything is saved in your browser (localStorage for items, IndexedDB for attached files), so it survives reloads and restarts, but stays on that browser and device.

**Sign in with Google to sync.** Once you've followed [SETUP.md](SETUP.md) (about 10 minutes, free), the person icon at the top right signs you in with Google, and your events, tasks and to-dos follow you to every device. Photos, videos and PDFs stay on the device where you added them; links sync.

## Running locally

It's a single file with no build step. Open `index.html` in a browser, or serve the folder:

```sh
python3 -m http.server 8000
```
