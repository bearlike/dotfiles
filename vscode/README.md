The VS Code docs mention the location for the settings files:

Depending on your platform, the user settings file is located here:

Platform    | Location
------------|--------------------
Windows     | `%APPDATA%\Code\`
macOS       | `$HOME/Library/Application Support/Code/`
Linux       | `$HOME/.config/Code/`

Those contain all the settings/configurations that VS Code maintains (apart from the `.vscode` folder in your workspace). If you delete the Code folder, your VS Code would then behave like it was freshly installed.