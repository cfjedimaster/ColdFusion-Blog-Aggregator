LICENSE 
Copyright 2011 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

Update: March 18, 2011
Scott Stroz did some nice cleanup here to make things more configurable. 
Lots of other changes since the last update almost 3 years ago. 

Update: August 27, 2007
Sorry for the delay in updating. Unfortunately I don't have a good list of what has been changed.

Update: August 3, 2007
Added a check for url.log to note if we should log the search. This will help 
stop popular searches from being even more popular as people continue to click
on them. We only log searches from the Search box now.

Also added a cool Powered by CF8 logo.

Update: August 1, 2007
Lola fixed up the MySQL install script.
I fixed a bug with dangling HTML in content.cfm.

Update: July 31, 2007
Added a new created column to entries. It is set to the time when
the entry is added to the database. There is a file in the install
folder named updatecreated.cfm. Run this to set the values for created
in your database.

Front end sorts by created now. RSS shows created.

Charlie Arehart wrote an install file. This is now moved into an install
folder, along with the readme file.

Update: July 29, 2007
Fix to search when coming from other pages.
Added + to open entries in new window.
Added click through tracking.
Added statd page.
Removed Prefs until I'm ready.
Small formatting changes.
tables.sql updated with new table.

Update: July 27, 2007
Added a Comment window.
Addeed max= to the RSS feed.