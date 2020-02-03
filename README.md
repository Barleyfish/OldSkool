# OldSkool
Old Skool XQuery Framework for MarkLogic Server

Simple MarkLogic XQuery app framework using the Old Skool query parameter logic to execute application functions. 

Includes a simple UI using basic HTML and .css

Like all Old Skool projects, this is largely undocumented, but its pretty simple:
- Designed to run on MarkLogic Server where defaul.xqy will execute when a directly or based app server URL is called
- default.xqy - basic layout and query paramter parsing. Simple if then to execute different functions that are all stored in display
  - parameters are all put into a <params> node and this is passed into all the functions
- display.xqy - functions for the app. From simple layout - header(), footer() - to advanced functionality like menus
  - This app is a search app that takes the value of the search parameter and returns results. There is also a facets function
  - To extend the search with wider concepts, the app also has a simple semantic loopup for concepts related to teh results and to create dynamic facets
- ml.css, .gif, .png - layout and design bits

NOTE: data set for this app has gone missing. But if I find it, i'll also post it
  
