#!/bin/bash

current_image="output2.png" #this have to be the QR code at the beggining
background_image="" #just remember to put this somewhere lol
ADMIN_WKSP="workspace 11" # home: "workspace 11" | performance hall: ADMIN_WKSP="workspace 1"
AUDIENCE_WKSPC="workspace 2" # home: "workspace 2" | performance hall: ADMIN_WKSP="workspace 11"

fake_prompt="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed lobortis lorem in bibendum pretium. Cras elementum venenatis lacus, ac cursus orci placerat id. Vivamus sagittis orci quis ipsum dapibus, at egestas nunc lobortis. Maecenas odio quam, iaculis ac accumsan ac, molestie non lacus. Proin dui libero, semper at lacus ac, sodales ullamcorper lorem. Quisque eget metus ac ante mollis tincidunt. Nulla ultricies diam vel tempor tristique. Nullam posuere faucibus diam, in convallis dolor varius quis.

Praesent mattis odio a sem tempor, at dignissim arcu tincidunt. Nunc vitae risus sit amet turpis ullamcorper sodales. Etiam et ex leo. Donec mattis neque tortor, non elementum enim maximus eget. Etiam eu nisi mi. Donec lobortis mi quis lorem tincidunt porttitor.

Proin quis volutpat elit. Vestibulum pulvinar ullamcorper mattis. Donec malesuada luctus urna, at pharetra odio fermentum vel. Integer dapibus ex ac nibh volutpat rhoncus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas."


function display_img() {
    ### sets the walpaper at the start of the piece
    #Needs to be set when screes setup changes.
    i3-msg "$AUDIENCE_WKSPC"
    imv -f $current_image &
    sleep 0.4 # needs time or it will transfer the background to your current workspace
    i3-msg "$ADMIN_WKSP"
}

function display_prompts() {
    magick -size 1800x1000 -background none -fill yellow -font Liberation-Sans -pointsize 42 caption:"$fake_prompt" \
     miff:- | \
    magick $background_image - -gravity center -composite $current_image
}



#display_img
#sleep 2
display_prompts
sleep 2
display_img