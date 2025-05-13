# Notes Pico

The Notes Pico app is the simplest, leveraging Pico CSS for a minimal interface,
ideal for quick prototyping.

A lightweight, web-based note-taking application built with **Pico CSS**, **Lua**,
**Redis**, and **NGINX**. This project allows users to create, view, and delete
notes with a clean, minimal interface, leveraging Pico CSS for styling and Redis
for persistent storage.

## Features
- **Create Notes**: Add notes with a title and content via a simple form.
- **View Notes**: Display all notes sorted by creation date (newest first).
- **Delete Notes**: Remove notes with a confirmation modal.
- **Responsive Design**: Uses Pico CSS for a clean, mobile-friendly UI.
- **No JavaScript Dependencies**: Minimal JavaScript for modal functionality; no external libraries.
- **Persistent Storage**: Notes are stored in Redis for durability.

## Tech Stack
- **Frontend**: Pico CSS for minimalistic, semantic styling; custom CSS for enhancements.
- **Backend**: Lua with NGINX for server-side logic.
- **Database**: Redis for storing notes as JSON-serialized objects.
- **Server**: NGINX for handling HTTP requests and routing.


## Project Structure

<pre style="font-family: 'Courier New', monospace; line-height: 1.2;">
notespico/
├── index.lua          # Main Lua script (backend logic and HTML template)
├── pico/
│   └── pico.min.css   # Pico CSS framework
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

2. HTML Frontend with Embedded Lua (outside Lua blocks): Defines the web interface using
   HTML, styled with Pico CSS, and includes Lua templating for dynamic content.

