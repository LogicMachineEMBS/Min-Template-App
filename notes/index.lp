<?
-- lua

-- Connecting to Redis
local red = require("redis").connect()

-- Define the Redis key for storing notes
local redis_key = "app:notes"


-- Functions for working with notes
local function get_notes()
  local notes = {} -- Table to store the list of notes

  -- Retrieve all notes from the Redis hash app:notes
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
    return ngx.redirect("/apps/data/notes/") -- Redirect to the notes page

  -- Handle "delete" action (delete a note)
  elseif args.action == "delete" and args.id then
    delete_note(args.id)
    return ngx.redirect("/apps/data/notes/") -- Redirect to the notes page
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
  <title>Simple Notes</title>

  <!--
  Bootstrap is a popular, open-source CSS framework for building responsive, mobile-first
  web interfaces. It provides pre-styled components (e.g., buttons, forms, modals), a
  flexible grid system, and JavaScript plugins for interactivity, simplifying and speeding
  up front-end development. Ideal for consistent, cross-device designs.
  -->
  
  <!-- Include Bootstrap CSS for styling -->
  <link href="bootstrap/bootstrap.min.css" rel="stylesheet">
  <!-- Include Bootstrap JavaScript for modal functionality -->
  <script src="bootstrap/bootstrap.bundle.min.js"></script>
  <!-- Include Bootstrap Icons for iconography -->
  <link rel="stylesheet" href="bootstrap/bootstrap-icons.css">

  <!-- Include custom styles -->
  <link href="custom_css/style.css" rel="stylesheet">

  <style>
    /* Inline styles (empty for now, can be used for overrides) */
  </style>
</head>
<body class="bg-light">
  <!-- Button to close the application -->
  <a href="/apps/" class="close-app btn btn-light border">
    <i class="bi bi-x-lg"></i>
  </a>
    
  <div class="container py-4">
    <div class="row justify-content-center">
      <div class="col-12 col-md-8">
        <h4 class="mb-4">Notes</h4>
                
        <!-- Note creation form -->
        <div class="card mb-4">
          <div class="card-body">
            <form method="post">
              <!-- Hidden field to specify the action -->
              <input type="hidden" name="action" value="save">

              <div class="mb-3">
                <!-- Input field for note title -->
                <input type="text" 
                       class="form-control"
                       name="title" 
                       placeholder="Note title" 
                       required>
              </div>
              <div class="mb-3">
                <!-- Textarea for note content -->
                <textarea name="content" 
                          class="form-control"
                          placeholder="Note content" 
                          rows="4" 
                          required></textarea>
              </div>
              <!-- Submit button to save the note -->
              <button type="submit" class="btn btn-primary">Save Note</button>
            </form>
          </div>
        </div>
                
        <!-- List of notes -->
        <div class="notes-list">
          <? if #notes == 0 then ?>
            <!-- Display message when no notes exist -->
            <div class="text-center text-muted py-5">
              <p>No notes yet. Create your first note!</p>
            </div>
          <? else 
                -- Iterate through notes to display each one
                for _, note in ipairs(notes) do ?>
                  <!-- Card for each note -->
                  <div class="card mb-3">
                    <div class="card-body">
                      <!-- Button to open delete confirmation modal -->
                      <button type="button" 
                              class="btn btn-close float-end" 
                              data-bs-toggle="modal" 
                              data-bs-target="#deleteModal<?= note.id ?>">
                      </button>
                                
                      <!-- Modal for confirming deletion -->
                      <div class="modal fade" id="deleteModal<?= note.id ?>" tabindex="-1">
                        <div class="modal-dialog">
                          <div class="modal-content">
                            <div class="modal-header">
                              <h5 class="modal-title">Confirm Deletion</h5>
                              <!-- Close button for the modal -->
                              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                              <!-- Note title (escaped for security) -->
                              Are you sure you want to delete note "<?= escape(note.title) ?>"?
                            </div>
                            <div class="modal-footer">
                              <!-- Cancel button to dismiss the modal -->
                              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                              <!-- Form to submit delete action -->
                              <form method="post" class="d-inline">
                                <!-- Hidden field to specify the action -->
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<?= note.id ?>">
                                <button type="submit" class="btn btn-danger">Delete</button>
                              </form>
                            </div>
                          </div>
                        </div>
                      </div>
                                
                      <!-- Note title (escaped for security) -->
                      <h5 class="card-title"><?= escape(note.title) ?></h5>
                      <!-- Note content (escaped for security) -->
                      <p class="card-text"><?= escape(note.content) ?></p>
                      <!-- Note creation timestamp -->
                      <div class="text-muted small">
                        Created: <?= os.date("%Y-%m-%d %H:%M", tonumber(note.created)) ?>
                      </div>
                    </div>
                  </div>
          <?    end
             end ?>
        </div>
      </div>
    </div>
  </div>
    
    
</body>
</html>