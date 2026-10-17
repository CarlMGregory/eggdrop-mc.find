##
# Find v2.0 by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#
# If you have any questions/comments/idea's, please email me!
# ( Include the script name and version in the title, if you do email me. )
#
# My SVS Website - http://mc.purehype.net/
##
# Thanks to:
#  BASS - Helped me a bunch. This being the very first script I have ever made, he was
#         my... TCL Mentor if you will.  Thanks BASS.
#  Myst|c & CyclopZ - Beta Testers.
##

##
# The purpose of this script is basically a searchable database.  Here is an
# example:
#
# ADDING it:
#-> *b@t* addfind area code 214 is Dallas Texas
#-b@t- Adding {area code 214 is Dallas Texas}...
#-b@t- Done...
#
# FINDING it:
#<MC_8> @find Area Code 214
#-b@t- I found 1 match to your search for '*area*code*214*'...
#-b@t- 1) area code 214 is Dallas Texas
##

##
# History:
#  v2.0 (06.27.01)
#   MC_8 - StU - Fixed problem when trying to read from the database and it's
#                not there.
#   MC_8 - Added `set mc_find(autostar)`.
#   MC_8 - BiLL - Added `set mc_find(search_method)`.
#   MC_8 - Per Mathias Engevold - Fixed `expected integer but got ""'
#   MC_8 - Added SVS
#   MC_8 - Relocated beta history to the bottom of the script.
#   MC_8 - Removed !<botnick> and !list and made it user defined.
#   MC_8 - Merged mc:find:msg:delfind, mc:find:msg:addfind into mc:find:msg:find
#          making just 1 msg command of `find <command> [option]'.
#   MC_8 - Merged mc:find:pubm:sendfindlist into mc:find:pubm:find making just 1
#          internal proc controling the public commands.
#   MC_8 - Merged mc:find:dcc:findstats, mc:find:dcc:addfind, mc:find:dcc:delfind,
#          and mc:find:dcc:sendfindlist into mc:find:dcc:find making just 1 inital
#          dcc command `.find <command> [option]'. 
#   MC_8 - Added veriable on how to reply to searches (NOTICE to user,
#          PRIVMSG to user, NOTICE to channel, or PRIVMSG to channel).
#   MC_8 - Re`coded mc:find:dcc:findstats.
#   MC_8 - Mystic - Added find import command.
#   MC_8 - Added option to send results in datafile once reached it's limit.
#   MC_8 - Made the notfound note personalizable.
#   MC_8 - Removed the notfound feature and replaced it with one that .notes it
#          directly to you as opposed to a file.  This way anyone who you give access
#          to will be able to see the not found list without having access to your
#          shell.
#   MC_8 - Due to a difference in the way it saves and utalizes the database, Coded an
#          auto DataBase Converter.  (it auto converts 1.x to 2.0, so don't worry
#          about having to do anything to convert the it)
#   MC_8 - Updated the way it saves the database.
#   MC_8 - Re`coded mc:find:inter:flood.
#   MC_8 - Removed the OnJoin feature (get greetd.tcl for an onjoin).
#   MC_8 - Re`coded mc:find:dcc:find.
#   MC_8 - Re`coded mc:find:pubm:find.
#   MC_8 - Re`coded mc:find:dcc:addfind.
#   MC_8 - Re`coded mc:find:msg:addfind.
#   MC_8 - Re`wrote the commands list.
#   MC_8 - Re`coded mc:find:dcc:delfind.
#   MC_8 - Re`coded mc:find:msg:delfind.
#   MC_8 - Re`coded mc:find:inter:notfoundlist.
#   MC_8 - Re`coded mc:find:pubm:sendfindlist.
#   MC_8 - !<botnick> wasn't working, fixed.
#   MC_8 - Re`coded mc:find:dcc:sendfindlist.
#   MC_8 - Changed dcc command from dllist to sendfindlist.
#
#  v1.1.2 (11.22.99)
#   MC_8 - misfit - Fixed error code e1.
#
#  v1.1.1 (06/03/99)
#   MC_8 - added a pub command of !<botnick> to dcc send the list.
#          (also included !list, does same thing)
#   MC_8 - fixed some wordings...
#   MC_8 - removed the dllist MSG command that was only for ops, now it's pub.
#   MC_8 - PRiMoGeN - added "not found, request was recorded.."
#
#  v1.1.0 (06/03/99)
#   MC_8 - added the wildcards on search (should of done that first of all du!)
#   MC_8 - added dcc command 'findstat'
#   MC_8 - added flood protection, thanks to bseen1.4.0.tcl
#   MC_8 - fixed the msg FINDADD...
#   MC_8 - fixed it's dcc putloglev
#   MC_8 - fixed bugs on the 'match_limit'
#   MC_8 - added a not found list (to let ya know what your search`r is lacking)
#   MC_8 - added database limit, over write older files on exceed limit
#          (suggested by Bass)
#   MC_8 - added a command so +o users can down load the search file, making it
#          easier to see everything
#
#  v1.0.0 (0?.??.99)
#   MC_8 - first release
##

##
# Commands:
#  DCC - Usage:  find <command>
#   Valid commands of find are:
#    add <information>   - +o|+o users - adds an entrie to the database
#    del <number>        - +o|+o users - deletes the specified record number
#    sendfindlist <nick> - +o|+o users - dcc sends the entire database
#    import <file>       - +n|   users - imports finds, for every line in <file>, it
#                                        adds that line as a new record in the searchable
#                                        database
#    stats               - +o|+o users - current stats (resets on rehash/restart/start-up)
#    <*search*pattern*>  -   anyone    - preforms a search of the database
#
#  PUB
#    @find <*search*string*> -  anyone   - preforms a search of the database (command can
#                                          very, it is user defined)
#    !list                   -  anyone   - sends the entire database via DCC SEND
#                                          (command can very, it is user defined)
#
#  MSG - Usage:  find <command>
#   Valid commands of find are:
#    add <information>   - +o|+o users - adds an entrie to the database
#    del <number>        - +o|+o users - deletes the specified record number
##

##
# Settings
##

# What do you want to call the public trigger(s) that do the searches?
# You can have more than 1, but put a space inbetween them.
# If you set this to "" then the trigger will default to "@find"
# Valid replacment veriables are %botnick.
set mc_find(trigger) "!find !search !%botnick-search @find"

# What do you want to call the public trigger(s) that send the entire
# database?  You can have mroe than 1, but put a space inbetween them.
# To turn this off, set it to ""
# Valid replacment veriables are %botnick.
set mc_find(sdf_trig) "!list !%botnick @%botnick"

# What search method do you want to use?
#  1= Keywords  -- This will search based on keywords, no *search*string* format.
#  2= String  -- This will search via *search*string*.
set mc_find(search_method) 1

# If you are using the String search method (above setting, set to 2), do
# you want the script to automatically fill in the spaces with *'s and put
# starts around the outside of the search string?
# Why do this, some people don't know how to search, they do `@find Lame search`.
# If your method is String, the correct way to do this would be `@find *Lame*search*`,
# the script will auto put the *'s in.
# If `set mc_find(search_method)` is set to 1, this setting isn't used... just skip
# over it.
set mc_find(autostar) 1

# What channels do you want the above public triggers to be active on?
# Seperate each channel with a space.  Set to "" for all channels.
set mc_find(act_chan) "#abc123"

# What channels do you NOT want the script to be active on?
# This command good if you want it active on every channel except for
# a certin channel.
# Seperate each channel with a space.  Set to "" for none.
set mc_find(inact_chan) ""

# How do you want to reply to searches?
# 1 = Private NOTICE
# 2 = Private PRIVMSG
# 3 = Public NOTICE
# 4 = Public PRIVMSG
set mc_find(reply_meth) 1

# What it says before showing the results of a search.
# Avilable replacment veriables are %nick %chan %results and %search
set mc_find(reply_premsg) {
I found %results match(es) to your search for '%search'...
}

# What it says when showing the results of a search.
# Avilable replacment veriables are %line %record and %info
set mc_find(reply_msg) "(%record) %info"

# What it says after showing the results of a search.
# Avilable replacment veriables are %nick %chan %results and %search
set mc_find(reply_postmsg) {
}

# How many finds to a search done in a channel do you want to post?
set mc_find(match_limit) 6

# [0=no/1=yes] If the results go over the limit (the setting above), do you want
# to dcc send the results in a .txt file?  If using Windows, The file will be
# best viewed in wordpad.
set mc_find(limit_dccsend) 1

# If mc_find(limit_dccsend) is set to 0 then this doesn't apply to you.  Set this to
# what you want to say in the begening section of the .txt file.
# Replacment veriables avilable would be %nick %botnick %chan %time %date
# %results and %search.
set mc_find(limit_send_premsg) {
 This file created by %botnick at %time on %date for %nick@%chan.
 
Found %results result(s) for the search of %search:
______________________________________________________
}

# If mc_find(limit_dccsend) is set to 0 then this doesn't apply to you.  Set this to
# what you want to say in the ending section of the .txt file.
# Replacment veriables avilable would be %nick %botnick %chan %time %date
# %results and %search.
set mc_find(limit_send_postmsg) {

            If you have any problems with this please let the ops of %chan know.
}

# Set this to the maximum number of entries that will be able to exist in the
# database, Newer entries overwright older ones.
set mc_find(databaselimit) 4000

# Set this to what you want the data file to be named.  This script will hold it's
# information in that file.
set mc_find(datafile) ".find.dat"

# Users that have the flag of +F will recieve a note upon a search finding 0 results.
# If you don't want this feature then don't add no one as +F.  Below is a setting 
# pertaning to this feature.  How many notes maximum do you want this script to
# generate?  If you have a note limit of 50, you don't want 50 notes hogging
# the room.  No one else would be able to send you a note.  This works as a roling
# index, upon reacing the limit it removes IT'S oldest note and adds the newer one.
# This does NOT mess with other notes, just notes it has made.
set mc_find(note_limit) 30

# This is pertaning to the above setting, What would you like this script to tell
# you when it sends users the note?
# Replacment veriables avilable would be %nick %chan and %search.
set mc_find(note_message) "%nick@%chan got no results for %search."

# This is the flood protection setting, in the form x:y.  Any queries
# beyond x in y seconds is considered a flood and ignored.  To turn this
# feature off, set to 0:0
set mc_find(flood) 5:10

# How long (in min.s) do you want to ignore the flooder?
set mc_find(ignore_time) 1

## MC SVS (Script Version Service) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_find(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_find(svs:check) 0  ;#This is at Midnight
#  set mc_find(svs:check) 5  ;#This is at 5am
#  set mc_find(svs:check) 13  ;#This is at 1pm
#  set mc_find(svs:check) 23  ;#This is at 11pm
set mc_find(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_find(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_find(svs:stableonly) 0



### Do Not Edit Past This Part ###
set mc_find(version) v2.0
set mc_find(svs:script) "spamcheck 002000000000"
set mc_find(svs:server) "mc.purehype.net 8085"

bind dcc - find mc:find:dcc:find
proc mc:find:dcc:find {hand idx args} {
 if {[catch {
  global lastbind mc_find botnick xfer-timeout
  set dargs $args
  set command [lindex [join $args] 0]
  set args [join [lrange [join $args] 1 e]]
  switch -- $command {
   add {
    if {![matchattr $hand o|o [lindex [console $idx] 0]]} {
     putdcc $idx "You do not have access to this command."
     putcmdlog "#$hand# ([lindex [console $idx] 0]) find add  (no access)"
     return 0
    }
    if {$args == ""} {
     putdcc $idx "Usage: find add <information>"
     return 0
    }
    if {[set temp [mc:find:inter:record $args]]} {
     putdcc $idx "$args already exists as record $temp."
     return 0
    }
    while {[mc:find:inter:record $mc_find(next_record)] != "0"} {
     incr mc_find(next_record) 1
    }
    if {[llength $mc_find(list)] >= $mc_find(databaselimit)} {
     mc:find:inter:stats expired [expr [llength $mc_find(list)]-($mc_find(databaselimit)-1)]
    }
    set mc_find(list) "{record $mc_find(next_record) : [mc:find:inter:filt $args]} [lrange [join [split $mc_find(list)]] 0 [expr $mc_find(databaselimit)-1]]"
     putdcc $idx "Created record $mc_find(next_record) to hold `$args`."
    incr mc_find(next_record) 1
    mc:find:inter:stats add 1 ; mc:find:inter:dbsave
    putcmdlog "#$hand# ([lindex [console $idx] 0]) find add $args"
    return 0
   }
   del {
    if {![matchattr $hand o|o [lindex [console $idx] 0]]} {
     putdcc $idx "You do not have access to this command."
     putcmdlog "#$hand# ([lindex [console $idx] 0]) find del  (no access)"
     return 0
    }
    if {$args == ""} {
     putdcc $idx "Usage: find del <number>"
     return 0
    } ; set record [lindex [split $args] 0]
    if {![string match "*record $record : *" $mc_find(list)]} {
     putdcc $idx "Record: $record not found."
     return 0
    } ; set data "" ; set temp 0
    foreach entrie $mc_find(list) {
     if {![string match "record $record : *" $entrie]} {
      set data "$data {$entrie}"
     } {putdcc $idx "Removed: [join $entrie]" ; mc:find:inter:stats del 1 ; incr temp 1}
    } ; set mc_find(list) $data
    if {$temp == "1"} {putdcc $idx "Removed $temp record."} {
     putdcc $idx "Removed $temp records."
    } ; mc:find:inter:dbsave
    putcmdlog "#$hand# ([lindex [console $idx] 0]) find del $args"
    return 0
   }
   sendfindlist {
    if {![matchattr $hand o|o [lindex [console $idx] 0]]} {
     putdcc $idx "You do not have access to this command."
     putcmdlog "#$hand# ([lindex [console $idx] 0]) find sendfindlist  (no access)"
     return 0
    }
    if {($args == "") || ([llength [split $arg]] > "1")} {
     putdcc $idx "Usage: find sendfindlist <nick>" ; return 0
    }
    if {![file exists .find.inter]} {set num 1} {
     set fileid [open .find.inter r]
     set num [lindex [gets $fileid] 0] ; close $fileid
    }
    while {[file exists find_db.$num]} {incr num 1}
    set args [lindex [split $args] 0]
    set fileid [open find_db.$num w]
    puts $fileid "Find $mc_find(version) by MC_8"
    puts $fileid " - $botnick's search database, written at [realtime] on [mc:find:inter:date] for your eyes."
    puts $fileid " " ; set i 1
    foreach entrie $mc_find(list) {
     puts $fileid "$i) $entrie" ; incr i 1
    } ; close $fileid
    switch -- [dccsend find_db.$num $arg] {
     0 {
      putdcc $idx "Sending find_db.$num to $arg."
      utimer ${xfer-timeout} "file delete find_db.$num" ; incr num 1
      if {[file exists .find.inter]} {
       set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
      } {set line ""}
      set line "$num [join [lrange [split $line] 1 e]]"
      set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
     }
     1 {putdcc $idx "Dcc table is full (too many connections)."}
     2 {putdcc $idx "Can't open a socket for the transfer."}
     4 {
      putdcc $idx "find_db.$num was queued for later transfer to $arg."
      utimer ${xfer-timeout} "file delete find_db.$num" ; incr num 1
      if {[file exists .find.inter]} {
       set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
      } {set line ""}
      set line "$num [join [lrange [split $line] 1 e]]"
      set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
     }
    } ; mc:find:inter:stats dbsend 1
    putcmdlog "#$hand# ([lindex [console $idx] 0]) find sendfindlist $args"
    return 0
   }
   import {
    if {![matchattr $hand n|]} {
     putdcc $idx "You do not have access to this command."
     putcmdlog "#$hand# ([lindex [console $idx] 0]) find import  (no access)"
     return 0
    }
    if {$args == ""} {
     putdcc $idx "Usage: find import <file>"
     return 0
    }
    if {![file exists $args]} {
     putdcc $idx "$args does not exists."
     return 0
    }
    if {![file exists $args]} {close [open $args w]}
    set fileid [open $args r] ; set i 0
    while {![eof $fileid]} {
     set line [gets $fileid]
     if {[string trim $line " "] == ""} {continue}
     if {[set temp [mc:find:inter:record $line]]} {
      putdcc $idx "$line already exists as record $temp."
      continue
     }
     while {[mc:find:inter:record $mc_find(next_record)] != "0"} {
      incr mc_find(next_record) 1
     }
     if {[llength $mc_find(list)] >= $mc_find(databaselimit)} {
      mc:find:inter:stats expired [expr [llength $mc_find(list)]-($mc_find(databaselimit)-1)]
     }
     set mc_find(list) "{record $mc_find(next_record) : [mc:find:inter:filt $line]} [lrange [join [split $mc_find(list)]] 0 [expr $mc_find(databaselimit)-1]]"
     putdcc $idx "Created record $mc_find(next_record) to hold `$line`." ; incr i 1
     mc:find:inter:stats add 1 ; incr mc_find(next_record) 1
    } ; close $fileid ; mc:find:inter:dbsave
    if {$i == "1"} {
     putdcc $idx "Imported 1 new record."
    } {putdcc $idx "Imported $i new records."}
    putdcc $idx " "
    putdcc $idx "Done with $args, do you want me to delete it?"
    set mc_find(temp) $args ; control $idx mc:find:control:importfind
    putcmdlog "#$hand# ([lindex [console $idx] 0]) find import $args"
    return 0
   }
   stats {
    putdcc $idx "Currently I am holding [llength $mc_find(list)]/$mc_find(databaselimit) searchable records."
    putdcc $idx "I have had $mc_find(stat_searches) searches, $mc_find(stat_notfound) I could not find and $mc_find(stat_found) that I could."
    putdcc $idx "Ive had to DCC SEND the result in a txt file $mc_find(stat_founddccd) times due to it being so many results."
    putdcc $idx "There have been $mc_find(stat_add) added, $mc_find(stat_del) deleted and $mc_find(stat_expired) expired records."
    putdcc $idx "I've sent out $mc_find(stat_dbsend) copies of my entire database."
    putdcc $idx " "
    putdcc $idx "All except for the total search are reset every day at midnight."
    return 1
   }
   default {
    set args *[join [join [split [string trim [string tolower "$command $args"] *] *]] *]*
    set matches_n 0 ; set matches_l ""
    if {[string match $args [string tolower [join $mc_find(list)]]]} {
     foreach entrie $mc_find(list) {
      if {[string match $args [string tolower [join $entrie]]]} {
       incr matches_n 1 ; set matches_l "$matches_l {$entrie}"
      }
     }
    } ; mc:find:inter:stats searches 1
    if {!$matches_n} {
     if {[string length $args] >= "10"} {
      if {[string length $args] >= "20"} {set ending ", shorten your search!"} {
       set ending ", make your search shorter maby?"
      }
     } {set ending "."}
     putdcc $idx "I'm sorry, I did not find any matches for '$args'$ending"
     mc:find:inter:stats notfound 1 
     mc:find:inter:notfound DCC $hand $args
     return 1
    }
    set each [split [mc:find:inter:replace $mc_find(reply_premsg) "%nick $hand %chan DCC %results $matches_n %search {$args}"] \n]
    foreach line [lrange $each 1 [expr [llength $each]-2]] {putdcc $idx $line}
    set i 1
    foreach entrie $matches_l {
     set record [lindex [split $entrie] 1]
     set info [join [lrange [split $entrie] 3 e]]
     putdcc $idx [join [mc:find:inter:replace $mc_find(reply_msg) "%line $i %record $record %info {$info}"]]
     incr i
    }
    set each [split [mc:find:inter:replace $mc_find(reply_postmsg) "%nick $hand %chan DCC %results $matches_n %search {$args}"] \n]
    foreach line [lrange $each 1 [expr [llength $each]-2]] {putdcc $idx $line}
    mc:find:inter:stats found 1 ; return 1
   }
  }
 } a]} {
  if {$a != "1" && $a != "0"} {
   putlog $a;putlog "Debug: mc:find:dcc:find->$lastbind"
   putlog "Debug: $hand - $idx - $dargs"
   putlog "Please report this error to gregory@worldinter.net."
  }
 }
}

bind pubm - * mc:find:pubm:find
proc mc:find:pubm:find {nick uhost hand chan args} {
 global lastbind mc_find botnick xfer-timeout
 if {[catch {
  set dargs $args
  set args [join $args]
  if {[string match "* [string tolower $args] *" " [string tolower [mc:find:inter:replace $mc_find(sdf_trig) "%botnick $botnick"]] "]} {
   if {$mc_find(act_chan) == ""} {set act_chan [string tolower [channels]]} {
    set act_chan [string tolower $mc_find(act_chan)]
   }
   if {![string match "* [string tolower $chan] *" " $act_chan "]} {return 0}
   if {[string match "* [string tolower $chan] *" " [string tolower $mc_find(inact_chan)] "]} {return 0}
   set args [lindex $args 0]
   if {![file exists .find.inter]} {set num 1} {
    set fileid [open .find.inter r]
    set num [lindex [gets $fileid] 0] ; close $fileid
   }
   while {[file exists find_db.$num]} {incr num 1}
   set fileid [open find_db.$num w]
   puts $fileid "Find $mc_find(version) by MC_8"
   puts $fileid " - $botnick's search database, written at [realtime] on [mc:find:inter:date] for your eyes."
   puts $fileid " " ; set i 1
   foreach entrie $mc_find(list) {
    puts $fileid "$i) $entrie" ; incr i 1
   } ; close $fileid
   switch -- [dccsend find_db.$num $nick] {
    0 {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Sending find_db.$num to you."
     utimer ${xfer-timeout} "file delete find_db.$num" ; incr num 1
     if {[file exists .find.inter]} {
      set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
     } {set line ""}
     set line "$num [join [lrange [split $line] 1 e]]"
     set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
    }
    1 {puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Dcc table is full (too many connections)\; try again later."}
    2 {puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Can't open a socket for the transfer."}
    4 {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :find_db.$num was queued for later transfer."
     utimer ${xfer-timeout} "file delete find_db.$num" ; incr num 1
     if {[file exists .find.inter]} {
      set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
     } {set line ""}
     set line "$num [join [lrange [split $line] 1 e]]"
     set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
    }
   } ; mc:find:inter:stats dbsend 1 ; return 1
  }
  set i 0 
  foreach temp [string tolower [mc:find:inter:replace $mc_find(trigger) "%botnick $botnick"]] {
   if {[string tolower [lindex [split $args] 0]] == $temp} {set i 1 ; break}
  }
  if {!$i} {return 0}
  if {$mc_find(act_chan) == ""} {set act_chan [string tolower [channels]]} {
   set act_chan [string tolower $mc_find(act_chan)]
  }
  if {![string match "* [string tolower $chan] *" " $act_chan "]} {return 0}
  if {[string match "* [string tolower $chan] *" " [string tolower $mc_find(inact_chan)] "]} {return 0}
  set args [join [lrange [split [join $args]] 1 e]]
  if {[mc:find:inter:flood [string range $uhost [expr [string last @ $uhost]+1] e]]} {return 0}
  if {($mc_find(search_method) == 2) && ($mc_find(autostar))} {
   set args *[join [join [split [string trim [string tolower $args] *] *]] *]*
  }
  if {[join [join [split [string tolower $args] *]]] == ""} {
   if {$mc_find(search_method) == 2} {set to_method "*search*pattern*"} {set to_method "Key Words"} 
   puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Usage: [lindex [mc:find:inter:replace $mc_find(trigger) "%botnick $botnick"] 0] $to_method"
   return 0
  }
  set matches_n 0 ; set matches_l ""
  if {$mc_find(search_method) == 2} {
   if {[string match $args [string tolower [join $mc_find(list)]]]} {
    foreach entrie $mc_find(list) {
     if {[string match $args [string tolower [join $entrie]]]} {
      incr matches_n 1 ; set matches_l "$matches_l {$entrie}"
     }
    }
   }
  } {
   foreach entrie $mc_find(list) {
    set i 1
    foreach keyword $args {
     if {[string match *$keyword* [string tolower [join $entrie]]]} {
      set i [expr $i && 1]
     } {set i 0;break}
     if {!$i} {continue}
     incr matches_n 1 ; set matches_l "$matches_l {$entrie}"
    }
   }
  };mc:find:inter:stats searches 1
  if {!$matches_n} {
   if {[string length $args] >= "10"} {
    if {[string length $args] >= "20"} {set ending ", shorten your search!"} {
     set ending ", make your search shorter maby?"
    }
   } {set ending "."}
   puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $chan"] :I'm sorry, I did not find any matches for '$args'$ending"
   mc:find:inter:stats notfound 1
   mc:find:inter:notfound $chan $nick $args
   return 1
  }
  if {($matches_n > $mc_find(match_limit)) && ($mc_find(limit_dccsend))} {
   if {![file exists .find.inter]} {set num 1} {
    set fileid [open .find.inter r]
    set num [lindex [gets $fileid] 0] ; close $fileid
   }
   while {[file exists search_results$num.txt]} {incr num 1}
   set fileid [open search_results$num.txt w]
   set each [split [mc:find:inter:replace $mc_find(limit_send_premsg) "%nick $nick %chan $chan %botnick $botnick %time {[realtime]} %date {[mc:find:inter:date]} %results $matches_n %search {$args}"] \n]
   foreach line [lrange $each 1 [expr [llength $each]-2]] {puts $fileid $line}
   set i 0
   foreach line $matches_l {
    set record [lindex [split $line] 1]
    set info [join [lrange [split $line] 3 e]]
    puts $fileid [join [mc:find:inter:replace $mc_find(reply_msg) "%line $i %record $record %info {$info}"]]
   }
   set each [split [mc:find:inter:replace $mc_find(limit_send_postmsg) "%nick $nick %chan $chan %botnick $botnick %time {[realtime]} %date {[mc:find:inter:date]} %results $matches_n %search {$args}"] \n]
   foreach line [lrange $each 1 [expr [llength $each]-2]] {puts $fileid $line}
   close $fileid
   switch -- [dccsend search_results$num.txt $nick] {
    0 {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :I found more than $mc_find(match_limit) results to your search.  I'm sending them in a text file (best viewed in wordpad)."
     utimer ${xfer-timeout} "file delete search_results$num.txt" ; incr num 1
     if {[file exists .find.inter]} {
      set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
     } {set line ""}
     set line "$num [join [lrange [split $line] 1 e]]"
     set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
    }
    1 {puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :I found more than $mc_find(match_limit) results to your search.  I was going to DCC Send you the results in a text file, but there are too many dcc connections open on my end\; try again later."}
    2 {putlog "Error: Couldn't open a socket to send $nick $file."}
    4 {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :I found more than $mc_find(match_limit) results to your search.  I was going to DCC Send you the results in a text file, but you have too many open dcc connections as it is now\; I qued the text file for later transfer."
     utimer ${xfer-timeout} "file delete search_results$num.txt" ; incr num 1
     if {[file exists .find.inter]} {
      set fileid [open .find.inter r] ; set line [gets $fileid] ; close $fileid
     } {set line ""}
     set line "$num [join [lrange [split $line] 1 e]]"
     set fileid [open .find.inter w] ; puts $fileid $line ; close $fileid
    }
   } ; mc:find:inter:stats founddccd 1 ; return 1
  }
  set each [split [mc:find:inter:replace $mc_find(reply_premsg) "%nick $nick %chan $chan %results $matches_n %search {$args}"] \n]
  foreach line [lrange $each 1 [expr [llength $each]-2]] {
   puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $chan"] :$line"
  }
  set i 1
  foreach entrie $matches_l {
   set record [lindex [split $entrie] 1]
   set info [join [lrange [split $entrie] 3 e]]
   puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $chan"] :[join [mc:find:inter:replace $mc_find(reply_msg) "%line $i %record $record %info {$info}"]]"
   if {($i == $mc_find(match_limit)) && ($i != $matches_n)} {
    puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $chan"] :More than $mc_find(match_limit) matches, please make your search a little more complex."
    return 1
   } ; incr i
  }
  set each [split [mc:find:inter:replace $mc_find(reply_postmsg) "%nick $nick %chan $chan %results $matches_n %search {$args}"] \n]
  foreach line [lrange $each 1 [expr [llength $each]-2]] {
   puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $chan"] :$line"
  } ; mc:find:inter:stats found 1 ; return 1
 } a]} {
  if {$a != "1" && $a != "0"} {
   putlog $a;putlog "Debug: mc:find:pubm:find->$lastbind"
   putlog "Debug: $nick - $uhost - $hand - $chan - $dargs"
   putlog "Please report this error to gregory@worldinter.net."
  }
 } 
}

bind msg - find mc:find:msg:find
proc mc:find:msg:find {nick uhost hand args} {
 global lastbind botnick mc_find
 if {[catch {
  set dargs $args
  set command [lindex [join $args] 0]
  set args [join [lrange [join $args] 1 e]]
  switch -- $command {
   add {
    if {$mc_find(act_chan) == ""} {set act_chan [string tolower [channels]]} {
     set act_chan [string tolower $mc_find(act_chan)]
    } ; set temp 0
    foreach chan $act_chan {
     if {[matchattr $hand o|o $chan]} {set temp 1;break}
    }
    if !$temp {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :You do not have access to this command."
     return 0
    }
#    set args [lindex $args 0]
    if {$args == ""} {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Usage: /msg $botnick addfind <information>"
     return 0
    }
    if {[set temp [mc:find:inter:record $args]]} {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :$args already exists as record $temp."
     return 0
    }
    while {[mc:find:inter:record $mc_find(next_record)] != "0"} {
     incr mc_find(next_record) 1
    }
    if {[llength $mc_find(list)] >= $mc_find(databaselimit)} {
     mc:find:inter:stats expired [expr [llength $mc_find(list)]-($mc_find(databaselimit)-1)]
    }
    set mc_find(list) "{record $mc_find(next_record) : [mc:find:inter:filt $args]} [lrange [join [split $mc_find(list)]] 0 [expr $mc_find(databaselimit)-1]]"
    puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Created record $mc_find(next_record) to hold `$args`."
    incr mc_find(next_record) 1
    mc:find:inter:stats add 1
    mc:find:inter:dbsave
   }
   del {
    if {$mc_find(act_chan) == ""} {set act_chan [string tolower [channels]]} {
     set act_chan [string tolower $mc_find(act_chan)]
    } ; set temp 0
    foreach chan $act_chan {
     if {[matchattr $hand o|o $chan]} {set temp 1;break}
    }
    if !$temp {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :You do not have access to this command."
     return 0
    }
    if {$args == ""} {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Usage: /msg $botnick delfind <number>"
     return 0
    } ; set record [lindex [split $args] 0]
    if {![string match "*record $record : *" $mc_find(list)]} {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Record: $record not found."
     return 0
    } ; set data "" ; set temp 0
    foreach entrie $mc_find(list) {
     if {![string match "record $record : *" $entrie]} {
      set data "$data {$entrie}"
     } {
      puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Removed: [join $entrie]"
      mc:find:inter:stats del 1
      incr temp 1
     }
    } ; set mc_find(list) $data
    if {$temp == "1"} {puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Removed $temp record."} {
     puthelp "[mc:find:inter:replace $mc_find(reply_meth) "%nick $nick %chan $nick"] :Removed $temp records."
    } ; mc:find:inter:dbsave
   }
  }
 } a]} {
  if {$a != "1" && $a != "0"} {
   putlog $a;putlog "Debug: mc:find:msg:find->$lastbind"
   putlog "Debug: $nick - $uhost - $hand - $dargs"
   putlog "Please report this error to gregory@worldinter.net."
  }
 }
} ; set mc_find(next_record) 1

proc mc:find:control:importfind {idx args} {
 global lastbind mc_find
 switch -- [string tolower [string index $args 0]] {
  y {file delete $mc_find(temp) ; return 1}
  n {return 1}
  default {putdcc $idx "Yes or No, do you want me to delete $mc_find(temp)?" ; return 0}
 }
}

bind time - "01 00*" mc:find:time:statreset
proc mc:find:time:statreset {a b c d e} {
 global lastbind mc:find
 foreach item "notfound found founddccd add expired del dbsend" {
  set mc_find(stat_${item}) 0
 }
 set fileid [open .find.stats w]
 puts $fileid [mc:find:inter:date]
 puts $fileid "$mc_find(stat_searches) 0 0 0 0 0 0 0"
 close $fileid
}

#.. Internal use procs ..#

# Flood proc, tell me there host, and this will tell yes/no (1/0) if there in violation
# of flooding.
proc mc:find:inter:flood {uhost} {
 global lastbind mc_find mc_findf
 set a [lindex [split $mc_find(flood) :] 0] ; set b [lindex [split $mc_find(flood) :] 1]
 if {[info exists mc_findf($uhost)]} {
  incr mc_findf($uhost) 1
  if {$mc_findf($uhost) > $a} {
   newignore *!*@$uhost mc.find Flood $mc_find(ignore_time)
   return 1
  }
 } {set mc_findf($uhost) 1}
 if {![string match "*unset mc_findf($uhost)*" [utimers]]} {
  utimer $b "catch {unset mc_findf($uhost)}"
 } ; return 0
}

# Date proc.
proc mc:find:inter:date {} {return [strftime "%b %d, %Y"]}

# Status updater proc. Tell this proc witch status to update, and how far up to update
# it to and it will up it and save it.
proc mc:find:inter:stats {item num} {
 global lastbind mc_find
 incr mc_find(stat_${item}) $num
 set fileid [open .find.stats w]
 puts $fileid [mc:find:inter:date]
 puts $fileid "$mc_find(stat_searches) $mc_find(stat_notfound) $mc_find(stat_found) $mc_find(stat_founddccd) $mc_find(stat_add) $mc_find(stat_expired) $mc_find(stat_del) $mc_find(stat_dbsend)"
 close $fileid
}

# Filter proc.
proc mc:find:inter:filt {data} {
 regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
 regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

# Replace proc.
proc mc:find:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

# Give this text, it will find the record number, give it a number.. it will find
# the text.
proc mc:find:inter:record {args} {
 global lastbind mc_find ; set args [join $args]
 if {[catch {expr $args+1}]} {
  foreach entrie $mc_find(list) {
   if {[string tolower $args] == [string tolower [lrange [split $entrie] 3 e]]} {
    return [lindex [split $entrie] 1]
   }
  }
 } {
  foreach entrie $mc_find(list) {
   if {$args == [lindex $entrie 1]} {return [lrange [split $entrie] 3 e]}
  }
 } ; return 0
}

# Database Saver.
proc mc:find:inter:dbsave {} {
 global lastbind mc_find botnick
 set fileid3 [open $mc_find(datafile) w]
 puts $fileid3 "#! mc.find [string range $mc_find(version) 1 e] | Writen by $botnick at [realtime] on [mc:find:inter:date]."
 foreach entrie $mc_find(list) {
  puts $fileid3 $entrie
 } ; close $fileid3 ; return 1
}

# Not found, send out e`mails.
proc mc:find:inter:notfound {chan nick args} {
 global lastbind mc_find
 if {[string index $chan 0] == "#"} {set temp [userlist F|F $chan]} {
  set temp [userlist F|]
 }
 foreach sendto $temp {
  set notes 0
  foreach note [notes $sendto 1-0] {
   if {[lindex $note 0] == "mc.find"} {incr notes 1}
  }
  while {$notes >= $mc_find(note_limit)} {
   set i 1
   foreach note [notes $sendto 1-0] {
    if {[lindex $note 0] == "mc.find"} {
     erasenotes $sendto $i ; incr notes -1 ; break
    } ; incr i 1
   }
  }
  storenote mc.find $sendto [mc:find:inter:replace $mc_find(note_message) "%chan $chan %nick $nick %search {$args}"] -1
 }
}

# Database Updater.
proc mc:find:inter:dbupdate {} {
# Database update, v1.x to v2.0
# Old:
#  {acdsee32 v1.0+2 : name: letis s/n: *****}
#  {acdsee32 v1.30+7 : name: kermu s/n: *****}
#  {acdsee32 v1.30 : name: kermu s/n: *****}
# New:
#  record 1 : acdsee32 v1.0+2 : name: letis s/n: *****
#  record 2 : acdsee32 v1.30+7 : name: kermu s/n: *****
#  record 3 : acdsee32 v1.30 : name: kermu s/n: *****
 global lastbind mc_find
 if {![file exists $mc_find(datafile)]} {close [open $mc_find(datafile) w]}
 set fileid2 [open $mc_find(datafile) r] ; set mc_find(list) "" ; set record 0
 while {![eof $fileid2]} {
  set line [gets $fileid2]
  if {([string trim $line " "] == "") || ([string range $line 0 1] == "#!")} {continue}
  incr record 1
  set mc_find(list) "$mc_find(list) {record $record : [mc:find:inter:filt [lindex $line 0]]}"
 } ; close $fileid2 ; mc:find:inter:dbsave
}

#.. Fail Safes ..#

# Older bot's don't have realtime, fail safe.
if {[catch {realtime}]} {
 proc realtime {args} {
  switch -exact [lindex $args 0] {
   time {return [strftime "%H:%M"]}
   date {return [strftime "%d %b %Y"]}
   default {return [strftime "%l:%M %P"]}
  }
 }
}

# Make sure the transfer module is loaded up (if the script needs it, user defined).
if {$mc_find(limit_dccsend)} {
 set temp 1
 foreach item [modules] {if {[lindex $item 0] == "transfer"} {set temp 0 ; break}}
 if {$temp} {loadmodule transfer}
 if {![info exists xfer-timeout]} {set xfer-timeout 300}
 if {![info exists max-dloads]} {set max-dloads 3} 
 if {![info exists copy-to-tmp]} {set copy-to-tmp 1}
 if {![info exists dcc-block]} {set dcc-block 0}
}

# Make sure the notes module is loaded up.
set temp 1
foreach item [modules] {if {[lindex $item 0] == "notes"} {set temp 0 ; break}}
if {$temp} {loadmodule notes}
if {![info exists notefile]} {set notefile "notesfile"}
if {![info exists max-notes]} {set max-notes 50}
if {![info exists note-life]} {set note-life 60}
if {![info exists allow-fwd]} {set allow-fwd 1}
if {![info exists notify-users]} {set notify-users 1}
if {![info exists notify-onjoin]} {set notify-onjoin 1}

#.. Start Up Runs ..#

switch -- $mc_find(reply_meth) {
 1 {set mc_find(reply_meth) "NOTICE %nick"}
 2 {set mc_find(reply_meth) "PRIVMSG %nick"}
 3 {set mc_find(reply_meth) "NOTICE %chan"}
 4 {set mc_find(reply_meth) "PRIVMSG %chan"}
 default {set mc_find(reply_meth) PRIVMSG}
}

if {$mc_find(trigger) == ""} {set mc_find(trigger) @find}

# Load .status file to memory.
if {![file exists .find.stats]} {
 foreach item "searches notfound found founddccd add expired del dbsend" {
  set mc_find(stat_${item}) 0
 }
} {
 set fileid [open .find.stats r]
 if {[gets $fileid] == [mc:find:inter:date]} {
  set stats [gets $fileid]
  set mc_find(stat_searches) [lindex $stats 0]
  set mc_find(stat_notfound) [lindex $stats 1]
  set mc_find(stat_found) [lindex $stats 2]
  set mc_find(stat_founddccd) [lindex $stats 3]
  set mc_find(stat_add) [lindex $stats 4]
  set mc_find(stat_expired) [lindex $stats 5]
  set mc_find(stat_del) [lindex $stats 6]
  set mc_find(stat_dbsend) [lindex $stats 7] 
 } {
  set mc_find(stat_searches) [lindex [gets $fileid] 0]
 } ; close $fileid
 foreach item "searches notfound found founddccd add expired del dbsend" {
  if {(![info exists mc_find(stat_${item})]) || ($mc_find(stat_${item}) == "")} {
   set mc_find(stat_${item}) 0
  }
 }
}

# Load database file to memory.
if {[file exists $mc_find(datafile)]} {
 set fileid [open $mc_find(datafile) r]
 if {([string range [set line [gets $fileid]] 0 1] != "#!") ||
     ([lindex [split $line] 2] < [string range $mc_find(version) 1 e])} {mc:find:inter:dbupdate}
 close $fileid ; set mc_find(list) ""
 set fileid [open $mc_find(datafile) r]
 while {![eof $fileid]} {
  set line [gets $fileid]
  if {([string trim $line " "] == "") || ([string range $line 0 1] == "#!")} {continue}
  set mc_find(list) "$mc_find(list) {$line}"
 } ; close $fileid
} {set mc_find(list) "" ; mc:find:inter:dbsave}

if {$mc_find(svs:enabled)} {
 if {($mc_find(svs:check) > "23") || ($mc_find(svs:check) < "0")} {set mc_find(svs:check) 00}
 if {[string length $mc_find(svs:check)] == "1"} {set mc_find(svs:check) 0$mc_find(svs:check)}
 if {$mc_find(svs:stableonly)} {
  set mc_find(svs:script) [string range $mc_find(svs:script) 0 [expr [string length $mc_find(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_find(svs:oldcheck) * * *" mc:find:svs:time}
 set mc_find(svs:oldcheck) $mc_find(svs:check)
 bind time - "00 $mc_find(svs:check) * * *" mc:find:svs:time
 proc mc:find:svs:time {min hour day month year} {
  global mc_find
  catch {control [connect [lindex $mc_find(svs:server) 0] [lindex $mc_find(svs:server) 1]] mc:find:svs:interface}
 }
}
proc mc:find:svs:interface {idx args} {
 global mc_find;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_find(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_find(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_find(svs:script) 1]} {
    set note [mc:find:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:find:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:find:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_find(version)}"]
    set note [mc:find:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:find:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:find:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:find:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_find(svs:notify) ",;"]] {
     set outnote [mc:find:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_find(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_find(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:find:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Find $mc_find(version) by MC_8 loaded."