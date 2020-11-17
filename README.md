# Todo
This script allows you to manage a to do list.
## Features
* It auto-updates the file set to be the to do list by removing past events when you run it.(you can always change it, just remember to move the list to the new directory and/or file)
* It tells you if the first elements are due for the actual date or if they're due for later.
* You can add and remove event, I haven't added an option that allows you to edit an event.(maybe one day I'll do it...)
* The removing option is really bad but it works if you do it the correct way.
* If you want to use this script for real I would advise you to do a keybind to exec it. Since I use i3 and kitty for me it'll be something like:
```bash
bindsym $mod+Shift+t exec kitty $Path_To_Script
```

This script isn't perfect and I know it but it works just fine for me. Maybe one day I'll do it in a better way...
