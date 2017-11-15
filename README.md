View the app [here.](https://cultureofinsight.shinyapps.io/dotmap/)

#### Background

We wanted to build a different kind of electorate map that could provide a better visual representation of voter density and diversity at a single glance.

The standard electorate map tends to be the choropleth style. These maps will typically fill an entire constituency with the colour of the winning party. Although this gives a definitive guide of seat winners, it fails to visualise any diversity of voting within the constituency and the number of ballots cast.

The dot density approach has the benefit of representing votes for parties that did not win in each constituency. It also does not suffer from the tendency of over-emphasising the influence of large, yet sparsely populated areas, as colour-coverage is dictated by voter count, not constituency area size.

For more information about the benefits of dot density mapping, listen to the wise words of Bill Rankin  [here.](https://www.youtube.com/watch?v=8pRcdMVkA3k)


#### Process

The app was built with R, utilising the leaflet package and Shiny. You can view the source code [here](https://github.com/PaulC91/gedotmap) - suggested improvements welcome! (any way to speed up the dot plotting in leaflet? see below)

Plotting all dots at once was causing a lot of browser meltdown, hence the region splits.

To limit the number of colours on the map, for general election results, we've only included votes for the 6 largest parties in the UK by voter count. Northern Ireland has therefore been removed as a region option.

Voter numbers for each constituency are divided by 250. The resulting number of dots are then randomly distributed within the constituency boundaries, colour-coded by party. 

For example, Labour received 30,633 votes in Hackney South & Shoreditch in 2015, so there will be 122 red dots (rounded down to nearest integer) randomly spread across that area. The exact location of each dot therefore does not have any significant meaning.

The number of **EU Ref** dots for Leave and Remain votes in each constituency were estimated (very crudely) in the follwing way:  
*((18+ Population 2015 figure &ast; 0.722) &ast; % Leave/Remain Estimate) / 250*  
With 0.722 being the average voter turnout % in the EU ref and the resulting figure representing 250 votes.

The bar chart shows the count of all visable dots on the screen for each party * 250. Due to the rounding process in dot plotting, not all votes will be represented in each constituency so this number will not be exact but should give a good representation of vote distribution amongst parties in any given area you zoom to on the map.

A note on zoom levels: it is best to view high density (urban) areas at a closer zoom level to avoid the order in which dots are plotted having an influence in the colour blend (Green dots will have more prominence from wider zooms because they are plotted last and will therefore cover dots below them).


#### Credits

Thanks to [Alasdair Rae](https://twitter.com/undertheraedar) for making his excellent constituency shapefile available with all data embedded. You can find the full breakdown of sources on his [blog post.](http://www.statsmapsnpix.com/2017/04/getting-ready-for-ge2017-big-shapefile.html)

EU Referendum % esitmates for each constituency were computed by [Chris Hanretty.](https://twitter.com/chrishanretty) Read his [blog post](https://medium.com/@chrishanretty/final-estimates-of-the-leave-vote-or-areal-interpolation-and-the-uks-referendum-on-eu-membership-5490b6cab878) that summarises the findings of his academic article "Areal Interpolation and the UK's referendum on EU Membership", *Journal Of Elections, Public Opinion And Parties,* accesible [here.](http://www.tandfonline.com/doi/abs/10.1080/17457289.2017.1287081?journalCode=fbep20)

Inspiration for the layout and dynamic bar chart was taken from the [shiny superZIP example.](http://shiny.rstudio.com/gallery/superzip-example.html)

For more information about [Culture of Insight](http://cultureofinsight.com) get in touch via [email](mailto:paul@cultureofinsight.com) or twitter [@datasetfree](https://twitter.com/datasetfree)
