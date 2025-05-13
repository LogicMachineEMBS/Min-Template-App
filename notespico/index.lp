<?
-- lua

-- Connecting to Redis
local red = require("redis").connect()

-- Define the Redis key for storing notes
local redis_key = "app:notespico"


-- Functions for working with notes
local function get_notes()
  local notes = {} -- Table to store the list of notes

  -- Retrieve all notes from the Redis hash app:notespico
  local notes_data = red:hgetall(redis_key)
  
  -- Iterate through the hash data
  for id, note in pairs(notes_data) do
    -- Deserialize the JSON note using json.pdecode
    note = json.pdecode(note)
    -- Check if the note is successfully deserialized and is a table
    if type(note) == 'table' then
      notes[#notes + 1] = note -- Add the note to the list
    end
  end
  
  -- Sort notes by creation time (newest first)
  table.sort(notes, function(a, b) 
    return (tonumber(a.created) or 0) > (tonumber(b.created) or 0)
  end)
    
  return notes -- Return the sorted list of notes
end


-- Function to save a new note
local function save_note(title, content)
  -- Generate a unique ID for the note using INCR
  local id = red:incr(redis_key .. ":id")

  -- Create a note object
  local note = {}
  note.id = id
  note.title = title
  note.content = content
  note.created = ngx.time() -- Creation time (Unix timestamp)

  -- Serialize the note to JSON and store it in the app:notespico hash
  red:hset(redis_key, id, json.encode(note))
    
  return id -- Return the ID of the saved note
end


-- Function to delete a note
local function delete_note(id)
  if id then
    -- Remove the note from the app:notespico hash by ID
    red:hdel(redis_key, id)
  end
end


-- Handling POST requests
if ngx.req.get_method() == "POST" then
  -- Extract request parameters
  local args = getvars() -- getvars() retrieves POST or GET parameters
  
  -- Handle "save" action (create a note)
  if args.action == "save" and args.title and args.content then
    save_note(args.title, args.content)
    return ngx.redirect("/apps/data/notespico") -- Redirect to the notes page

  -- Handle "delete" action (delete a note)
  elseif args.action == "delete" and args.id then
    delete_note(args.id)
    return ngx.redirect("/apps/data/notespico") -- Redirect to the notes page
  end
end


-- Retrieve all notes for display
local notes = get_notes()
?>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Simple Notes Pico</title>

  <!-- Include Pico CSS for minimalistic styling -->
  <!--
  PICO CSS is a lightweight, minimal CSS framework for building clean,
  responsive web interfaces. It provides simple, semantic styling for
  common HTML elements, with a focus on typography, forms, and buttons,
  requiring no JavaScript. Ideal for quick prototyping or small projects.
  -->
  <link rel="stylesheet" href="pico/pico.min.css">

  <!-- Include custom styles -->
  <link rel="stylesheet" href="custom_css/style.css">
    
  <!-- Reference to Pico CSS documentation -->
  <!-- 
  https://picocss.com/docs/css-variables
  -->

  <style>
    /* Inline styles (empty for now, can be used for overrides) */      
  </style>
</head>
<body>
  <!-- Button to close the application -->
  <a href="/apps/" class="close-app">×</a>
    
  <div class="container">
    <header>
      <h4>Notes Pico</h4>
    </header>
        
    <main>
      <!-- Note creation form -->
      <article>
        <form method="post">
		  <!-- Hidden field to specify the action -->
          <input type="hidden" name="action" value="save">
		  
          <div>
            <!-- Input field for note title -->
            <input type="text" 
                   name="title" 
                   placeholder="Note title" 
                   required>
          </div>
          <div>
            <!-- Textarea for note content -->
            <textarea name="content" 
                      placeholder="Note content" 
                      rows="4" 
                      required></textarea>
          </div>
          <!-- Submit button to save the note -->
          <button type="submit">Save Note</button>
        </form>
      </article>
            
      <!-- List of notes -->
      <section>
        <? if #notes == 0 then ?>
            <!-- Display message when no notes exist -->
            <div style="text-align: center; color: #666; padding: 2rem 0;">
              <p>No notes yet. Create your first note!</p>
            </div>
        <? else 
            -- Iterate through notes to display each one
            for _, note in ipairs(notes) do ?>
              <article class="note">
                <!-- Button to open delete confirmation modal -->
                <button type="button" 
                  class="delete-btn" 
                  onclick="openModal('deleteModal<?= note.id ?>')">×</button>
                        
                <!-- Note title (escaped for security) -->
                <h5 class="note-title"><?= escape(note.title) ?></h5>
                <!-- Note content (escaped for security) -->
                <p class="note-content"><?= escape(note.content) ?></p>
                <!-- Note creation time -->
                <div class="note-time">
                  Created: <?= os.date("%Y-%m-%d %H:%M", tonumber(note.created)) ?>
                </div>
                        
                <!-- Modal for confirming deletion -->
                <div id="deleteModal<?= note.id ?>" class="modal">
                  <div class="modal-content">
                    <h5>Confirm Deletion</h5>
                    <!-- Confirmation message with note title -->
                    <p>Are you sure you want to delete note "<?= escape(note.title) ?>"?</p>
                    <div class="modal-actions">
                      <!-- Cancel button to close modal -->
                      <button onclick="closeModal('deleteModal<?= note.id ?>')" class="secondary">Cancel</button>
                      <!-- Form to submit delete action -->
                      <form method="post" style="display: inline; margin: 0;">
					    <!-- Hidden field to specify the action -->
                        <input type="hidden" name="action" value="delete">
						
                        <input type="hidden" name="id" value="<?= note.id ?>">
                        <button type="submit" class="contrast">Delete</button>
                      </form>
                    </div>
                  </div>
                </div>
              </article>
        <?  end
          end ?>
      </section>
    </main>
  </div>
    
  <script>
    // Simple JavaScript for modal windows
    // Open a modal by adding 'active' class
    function openModal(id) {
      document.getElementById(id).classList.add('active');
    }
        
    // Close a modal by removing 'active' class
    function closeModal(id) {
      document.getElementById(id).classList.remove('active');
    }

    // Close the modal when clicking outside the content
    document.addEventListener('click', function(e) {
      if (e.target.classList.contains('modal')) {
        e.target.classList.remove('active');
      }
    });
  </script>
</body>
</html>