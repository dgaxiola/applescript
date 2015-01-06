Checkbook
=========

## Overview

Checkbook was an interactive art project I did in college as part of my 4.643J class at MIT.

It's essentially a randomly assembled, web version of work done by Barbara Kruger and Jenny Holzer.  Barbara Kruger is known for juxtaposing images and phrases to subvert or give new meaning to the original image. Jenny Holzer is known for using text in installations or buildings to add commentary on the physical world.  The project title itself comes from one of Kruger's works which commonly goes by "When I hear the word Culture I take out my checkbook."

My take was to present a word or phrase on a web page which would link to some destination site.  The intention is that the participant's feelings on the destination site would be altered when thinking about the words that they had just seen. The sites ranged from art collections, biology, politics and even personal web sites (such as they were in the Spring of 1995). Though I don't include the actual art assets here, I lifted some of Kruger's phrases and tried to come up with a few of my own and used a few from advertisements. 

## The Code

The project was pretty simple and not a lot of code in the end but the idea of generating pages from a database was a new idea to me.  I spent a fair amount of time researching and finding the right examples.  I did most of the actual work in just a day or two, including cobbling together art assets.  I was doing a lot with AppleScript at the time for my thesis so it seemed natural to use that to be the basis of server.

I've included three files:

* [InfoSeek Import to FMP.applescript](InfoSeek Import to FMP.applescript) - I used an at the time popular search engine called InfoSeek to gather lists of webpages on a variety of topics.  These would be the destination sites that follow the words. This script scrapes the resulting pages and creates entries in a FileMaker Pro database. If I had more time I would have tried to completely automate it.
* [Default.html](Default.html) - The landing page for project.  It basically provides a link to CGI that will generate the random word and site page.
* [remote_control.acgi.applescript](remote_control.acgi.applescript) - The script that returns the intermediate word image with a link to the final destination.  I had intended that you might be able to revisit previously generated associations but dropped it due to time constraints and not knowing about cookies.

This was developed on an PowerMac 6100 with System 7.5.x.  FileMaker Pro v2.1 was used as the database backend.  MacHTTP 2.2 was the web server.  The scripts use several OSAXen which maybe hard to find.  The ones common to web service such as Decode and Tokens are still available with some searching.  There's a string manipulation OSAX used by the remote_control.acgi whose name I can't remember so that code will need to be rewritten.

I learned the importance of load testing and the need to distribute that load when 20+ students tried to hit my PowerMac 6100 when I presented it in class. 


