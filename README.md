## Table of Contents

* [Scope](#scope)
* [Design](#design)
* [Code Structure](#code-structure)
* [Performance Considerations](#performance-considerations)

## Scope
I extracted this library from a Rails e-commerce project i was working for.  
I need to generate XML sitemaps according to the [Google standard](https://support.google.com/webmasters/answer/156184).  

## Design
The site i had to deal with has a large number of product pages (> 30k), and it comes with worldwide multi-language support.  
I was asked to add [HREFLANG directive](https://support.google.com/webmasters/answer/2620865) for all of the available languages of the HREF entry.  

### Files Grouping
The issue i faced was that Google has XML file limit of 10MB, while my resulting file, already split by country, was about 22MB.  
I have opted to split sitemap files by logical grouping, ending with one XML (per country) for: 
* categories of product
* sub-categories (sorts)
* products
* stores
* homepages

I keep trace of the generated files into an index XML.

## Code Structure
I structured the library by single-responsibility classes:

### Repository
Its main role is fetching data from some sources and solve impedance mismatch by returning appropriate entities for fetched data.  
The constructor accepts a sites argument identifying for which languages the data will be fetched.  
The public API returns also a paths method identifying where the sitemaps have to be saved and a host one, identifying the host to be used to generate the URLs.  
I've included a MySQL subclass i've used in my project that uses the sequel gem to interact with a legacy database (not part of the gem).

### Entities
It contains the Ruby representations of the data. I used a common template for each group.  
The class constructor accepts an arguments hash: this is particularly convenient when interacting with Sequel dataset.  
In order to compute all available HREFLANG directives i scan the same array of entities  i was cycling into to generate the main HREF entry.  
This design halt me to alter the data structure in place to reduce RAM consumption.  This leads to some garbage collector issues (see below), but also avoid to hit database on each iteration.

### Mapper
The mapper accepts a list of entities and transform them to the XML nodes representation. It also filters entities by country, allowing to split XML files properly.

### Base and Nodes
The Base and Nodes classes contains the XML representation of the entities.  
I used the excellent Builder gem, that suits my needs better than other juggernaut libraries and allows me to create a common API to render XML from data.

### Factory
The factory class glues every piece together:
* fetch the data from the repository by filtering on the selected countries
* interacts with the mapper to get XML nodes representation
* save the XML and gzip them
* create the XML index
* propagates the maps by copying them on specified folders location (read from repository)

### Rake task
A rake task is available to create sitemaps. It accepts a list of sites (regions) to split maps by, a variable identifying the environment where to fetch information from (save folders, host, etc) and a flag used to print the hreflang directives into the XML (default to false).

Create maps for sites it, fr and uk, fetching data from development environment, do not include hreflang directives:
```
rake sitemap:factory sites=it,fr,uk env=devlopment
```

Create maps for jp, kr, cn, cn-en, fetching data from production environment, do include hrflang directives:
```
rake sitemap:factory sites=jp,kr,cn,cn-en env=production hreflang=Y
```

Remove maps`created for the development enviornment:
```
rake sitemap:clean env=development
```

## Performance Considerations
I had several version of the library, getting better performance on each iteration.

### Platform
I've used a [Vagrant](https://www.vagrantup.com/) box with the following specs:
* Ubuntu Trusty 64 bit 
* 2 VCPUs (out of 4 cores 2.2Ghz)
* 4GB of RAM (out of 8GB 1333Mhz DDR3)

### Sequel VS ActiveRecord
The first version uses Rails ActiveRecord to fetch data from MySQL, but this implementation quickly shows its limits: loading several nested, eager loaded, data structures in memory was great for impedance mismatch, but a nightmare for Ruby 1.8.7 garbage collector.  
To solve the issue i triggered a new query to the database at each iteration: the performance was slightly better, but latency and DB traffic was not an option for production code (i also cannot afford locking products table longer than few seconds).  
At the end i decided to use few large SQL queries to load all of the data in memory at once, skipping ActiveRecord at all. I opted for the [Sequel](http://sequel.jeremyevans.net) gem, finding it pretty flexible: it returns plain hashes that i can throw to the entities constructors to get more idiomatic Ruby representation.  
I barely scratched the surface of Sequel, but it's a gem i will go for everyday in place of the bulky alternatives.

### Processes
Once i get some decent performance it was time to parallelize the computation. You can set how many processes are spawned by setting the MAX_PROCS environment variable (default to 3).  

### Ruby 1.8.7 VS 2.3.0
Once i extracted the gem i tested the library against ruby 2.3.0. I was expecting
better results, but was impressed by the boost i get.

The script creates a total of 136 XML files, printing about 130k href entries and relative hreflang directives.

| Ruby Version   |  Execution time     |
| :------------- | ------------------: |
| 1.8.7          |          63m16.141s |
| 2.3.0          |          13m20.731s | 

My gentle guess is that the optimizations to the garbage collector introduced by Ruby 2.0 are the real deal here.  
