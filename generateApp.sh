#!/bin/sh

echo "What should the Application be called (no spaces allowed e.g. Google)?"
read inputline
name=$inputline

echo "What is the url (e.g. https://www.google.com)?"
read inputline
url=$inputline

echo "What is the full path to the icon (e.g. /Users/username/Desktop/icon.png)?"
read inputline
icon=$inputline



appRoot="/Applications"


# various paths used when creating the app
resourcePath="$appRoot/$name.app/Contents/Resources"
execPath="$appRoot/$name.app/Contents/MacOS" 
profilePath="$appRoot/$name.app/Contents/Profile"
plistPath="$appRoot/$name.app/Contents/Info.plist"

# make the directories
mkdir -p  $resourcePath $execPath $profilePath

# convert the icon and copy into Resources
if [ -f $icon ] ; then
    sips -s format tiff $icon --out $resourcePath/icon.tiff --resampleWidth 128 >& /dev/null
    tiff2icns -noLarge $resourcePath/icon.tiff >& /dev/null
fi

# create the executable
cat >$execPath/$name <<EOF
#!/bin/bash

#recuperation du patrh d'install de google chrome
path=\$(osascript -e 'set a to path to application "Google Chrome"
set p to POSIX path of a')

#navigation dans le app de chrome
path="\$path/Contents/MacOS/Google Chrome"

#path courant du script
current=\$(dirname \$0)

#fallback
if [ ! -f "\$path" ] ; then
	osascript -e 'tell app "System Events" to display dialog "You can not use this app without Google Chrome"' 
	open -a safari $url
fi

#lancement de chrome
if [ -f "\$path" ] ; then
	exec "\$path" --start-maximized --forced-maximize-mode  --app="$url"   --user-data-dir="\$current/../Profile" "\$@"
fi
EOF
chmod +x $execPath/$name

# create the Info.plist 
cat > $plistPath <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=”1.0″>
<dict>
<key>CFBundleExecutable</key>
<string>$name</string>
<key>CFBundleIconFile</key>
<string>icon</string>
</dict>
</plist>
EOF

