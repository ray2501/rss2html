#!/usr/bin/env tclsh

package require TclCurl
package require tdom

proc get_rss {url} {
    try {
        set curlHandle [curl::init]
        $curlHandle configure -url $url -bodyvar result
        $curlHandle setopt CURLOPT_HTTP_VERSION 2TLS

        catch { $curlHandle perform } curlErrorNumber
        if { $curlErrorNumber != 0 } {
            throw error [curl::easystrerror $curlErrorNumber]
        }
    } on error {em} {
        error "Error: $em"
    } finally {
       $curlHandle cleanup
    }

    return $result
}

proc parse {XML ofname} {
    set doc [dom parse $XML]
    set root [$doc documentElement]
    set titleList [$root selectNodes //item/title]
    set linkList [$root selectNodes //item/link]

    set out [open $ofname w 0666]
    foreach tnode $titleList lnode $linkList {
        set ntitle [$tnode text]
        set nlink [$lnode text]
        puts $out "<a href=\"$nlink\">$ntitle</a><br>"
    }
    close $out
}

if {$argc == 2} {
    set url [lindex $argv 0]
    set ofile [lindex $argv 1]
} else {
    puts "Usage:"
    puts "\ttclsh rss2html.tcl url filename"
    exit
}

if {[catch {set data [get_rss $url]} err]} {
    puts $err
} else {
    parse $data $ofile
}
