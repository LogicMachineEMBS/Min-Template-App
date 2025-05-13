# Notes

The Notes app is simple and more feature-rich, using Bootstrap CSS and
JavaScript for a polished, responsive UI with interactive modals.

A lightweight, web-based note-taking application built with **Bootstrap CSS**,
**Lua**, **Redis**, and **NGINX**. This project allows users to create, view,
and delete notes with a responsive, polished interface, leveraging Bootstrap
for styling and Redis for persistent storage.

## Features
- **Create Notes**: Add notes with a title and content via a simple form.
- **View Notes**: Display all notes sorted by creation date (newest first).
- **Delete Notes**: Remove notes with a confirmation modal.
- **Responsive Design**: Uses Bootstrap CSS for a consistent, mobile-first UI.
- **Persistent Storage**: Stores notes in Redis as JSON-serialized objects.
- **Minimal JavaScript**: Relies on Bootstrap's JavaScript for modal functionality.

## Tech Stack
- **Frontend**: Bootstrap CSS for responsive styling, Bootstrap Icons for iconography,
  and Bootstrap JavaScript for modals.
- **Backend**: Lua with NGINX for server-side logic.
- **Database**: Redis for storing notes as JSON-serialized objects.
- **Server**: NGINX for handling HTTP requests and routing.


## Project Structure

<pre style="font-family: 'Courier New', monospace; line-height: 1.2;">
notes/
├── index.lp           # Main Lua Page file (backend logic and HTML template)
├── bootstrap/
│   ├── bootstrap.min.css        # Bootstrap CSS
│   ├── bootstrap.bundle.min.js  # Bootstrap JavaScript
│   └── bootstrap-icons.css      # Bootstrap Icons
├── custom_css/
│   └── style.css      # Custom styles
├── icon.svg           # icon for the app
├── title              # title of the app (text written on icon)
└── README.md          # This file
</pre>

## Structure of index.lp

The index.lp file is divided into two main sections:

1. Lua Backend Logic (enclosed in &lt;? ... ?&gt;): Handles server-side operations, including
   Redis interactions, request processing, and note management.

2. HTML Frontend: Renders a responsive note-taking interface using Bootstrap CSS, with a
   form for creating notes, a list of notes in cards, and modals for delete confirmation.