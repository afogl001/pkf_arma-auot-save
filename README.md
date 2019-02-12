# **pkf_arma-auto-save** v0.1.0
Install systemd service/path to auto-archive all save games (unlimited saves)

## Description
This script will provide an "Arma: Cold War Assault" player with unlimited saves and the ability to quickly load the last save without manually moving/renaming files.  It will also preserve ALL save games that can be manually loaded via moving/renaming if the player wishes (helpfully when the player saves after a game-breaking bug/glitch occurs such as a faulty event trigger)

## Usage
Ideally, this script should be run in a separate virtual console (generally accessed by pressing "*Ctl+Alt+F#*") for easy access without needing to minimize the running application but can be run in any terminal emulator (Konsole, Terminal, etc) if desired.
To run the script, simply make it executable and run as your regular user.  The presented menu is ordered in the general sequence you would follow when initially configuring or updating the use of this script.  ***NOTE: User WILL be prompted their password when running options 3, 4, 5, and 6 since these options interact with systemd***

**"Current path:"** = Shows the current path (if any) to the save games directory being used by "pkf_arma-auto-save".  This will be blank if "pkf_arma-auto-save" has not been previously configured.

**1: "Find existing paths for saved games:"** = List all directories where "Arma: Cold Ware Assault" save files are located (within the user's home directory, aka '~').  The results can be directly copy/pasted into the next option to avoid typing potentially log path names.

**2: "Set path for saved games:"** = Specify the path the the save game directory you wish to set unlimited saves for.  You may manually type in a known path or copy one of the results from the option above.  Do not include the save file name in the path.  For example, if a save file is located at "/home/user001/ARMA/1985/save.fps", you would use "/home/user001/ARMA/1985" as your path.

**3: "Setup systemd service and path for auto-save:"** = Writes a .service and a .path file for systemd, which are used to automate the "unlimited save" feature without manual intervention.  It simply writes an "arma_auto_save.service" and "arma_auto_save.path" files and reloads the systemd deamon.  It WILL NOT enable/activate the service, which is done via the next option.

**4: "Start/enable or stop/disable path service:"** = Checks the current status of the service (specifically, the .path service) and asks you if you would like to proceed with the relevant option ("Y" for yes, any other input cancels).  You MUST run this at least once to start the service, otherwise it will remain stopped and disabled.

**5: "Load last saved game:"** = Copies the last saved game and names it "continue.fps", allowing you to load the last saved game by clicking "Continue" from your campaign screen.  ***NOTE: You must exit your active game (back to the campaign screen or main menu) BEFORE running, otherwise the game will overwrite with wherever you actually left the game***

**6: "Remove systemd service:"** = Will stop/disable all installed services, remove them from your system entirely, then reloads systemd to clear out any cache of it.

**0: "Exit:"** = Closes script.  If you have installed the systemd services by using options 2 -> 3 -> 4, you will continue to enjoy unlimited saves and can either load this script again and use option 5 (to automatically load your last save) or manually copy and rename the desired save.fps.###### file as "continue.fps".

If you decide to start a new campaign, you can simply run options 2 -> 3 -> 4 again with the new campaign's save path, and resume your previous campaign by following the same steps.  

## Limitations
- ***NO CLEANUP***.  This isn't a huge concern as the save.fps files are not very large but over time you may want to manually remove older save files.  This is technically as designed as I wanted a sort of "archive" of all my saves but a feature to clean old ones up if desired may be considered in future releases.
- For "Option 2", the search parameters are a little loose, simply checking for "ARMA" (all caps) and "save.fps*".  This seems adequate for now but other installations of Arma: Cold War Assault may not adhere to these assumptions and Operation Flashpoint certainly won't!
- For "Option 5", you can only load last saved game.  This may be addressed in a future release depending on how much the author sucks at getting through the campaigns
- Only supports one campaign at a time (though mitigated by simply running 3->4->5 to switch back and forth)

### Planned Improvements
- Possibly add an option to load saved games from a limited list instead of just the last save.
- Consider adding a clean up option which would remove all but the last 10 saves

### **Code overview**

#### Variables used
- $1 = Used to capture and use an option passed to the script.  This is specifically implemented via arma_auto_save.service file, where "9" (an option not visiable to the user) is passed in order to initiate the move command on the discovered "save.fps" file.
- $2 = Used by arma_auto_save.service file, in conjunction with "*$1*", to specify the path of the save file to be moved.
- $vSavePath = Full path the the specific campaign's save directory.
- $vMainMenu = Holds value for what option is selected
- $vResponse = Holds value for user's answer to prompted Y/N questions  

#### TODO: Elaborate on code
