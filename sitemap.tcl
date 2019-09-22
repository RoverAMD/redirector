#!/usr/bin/env tclsh
# Generate redirecting short URLs following a map file

namespace eval smdeps {
	proc quickread {fn} {
		if {! [file exists $fn]} {
			error "File \"$fn\" does not exist."
		}
		set desc [open $fn r]
		set result [read $desc]
		close $desc
		return $result
	}
	
	proc trim {listing} {
		set listingR [list]
		foreach item $listing {
			lappend listingR [string trim $item]
		}
		return $listingR
	}
	
	proc splitnl {str} {
		set strfixed [string map [list \r\n \n] $str]
		return [split $strfixed \n]
	}
}

if {$::argc < 1} {
	puts "Usage: tclsh sitemap.tcl SITEMAP1 \[SITEMAP2, ...\]"
	exit 1
}

foreach arg $::argv {
	set contents [smdeps::quickread $arg]
	set contents [smdeps::splitnl $contents]
	foreach cl $contents {
		set splitLine [smdeps::trim [split $cl {>}]]
		if {[llength $splitLine] >= 2} { 
			set dirTarget "[pwd]/[lindex $splitLine 0]"
			if {[file isdirectory $dirTarget]} {
				file delete -force -- $dirTarget
			}
			file mkdir $dirTarget
			set desc [open $dirTarget/index.html w]
			set template "<html><head><script>window.location.href = \"[lindex $splitLine 1]\";</script>"
			set template "$template</head><body><p>If you aren't getting redirected, click <a href=\"[lindex $splitLine 1]\">here</a>.</p></body></html>"
			puts $desc $template
			close $desc
		}
	}
}
