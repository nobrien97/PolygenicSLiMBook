


# Working with SLiM data

## Overview

A lot of the power of SLiM (and simulations in general) is that it is relatively cheap to keep track
of a lot of data, which would be impossible in the field. SLiM's output is extremely customisable,
so anything that you keep track of during a simulation, you can output to a file. But should you?
Outputting everything you are modelling as text will result in huge files which are difficult to 
work with, and contain irrelevant data. With more frequent sampling and more data, you'll end up with
huge plaintext files that R or Python will have a hard time reading. You could upload this to a 
database, but this will incur large speed penalties when trying to analyse your results. In large
experiments, it is important that you only keep track of what you need to, and sample as little 
as you can get away with. The importance of this decreases the smaller your experiments, but it is
still something to keep in mind, not only for your hard drive's sake, but also your simulation's
speed.


## An example of saving space in custom SLiM output

The examples below are from the output in `Chp5-1_1T.slim`. Here, we take a variety of quantitative
and population genetics statistics as output, saving them every so many generations:


```slim
420 	Mfile = paste(sim.generation, asString(seed), modelindex, meanH, VA, phenomean, dist, w, deltaPheno, deltaw, sep=",");
421	    writeFile(outName, Mfile, append = T);
```

`Mfile` contains all the statistics we are measuring. We need the timepoint and model information to identify what all this data
will belong to, but we _don't_ need every predictor variable! This is the purpose of `modelindex`, as explained in Chapter 5. 
`modelindex` is unique for each _parameter combination_, and hence describes all of those parameters in a single value. This saves
a lot of space for the final output, as we are removing upwards of 3 columns (depending on how many parameters you are adjusting).
You could similarly save space by saving the seed as the index of seeds in your `seeds.csv` file, rather than the actual 32-bit seed
value, however I found this unnecessary. 
Not only does this save space, but it also saves processing power, as SLiM doesn't need to fetch information on all of these parameters
every time it stores output. While this is a tiny amount of time individually (a modern CPU can fetch a variable from a memory address
in less than 1 nanosecond, although SLiM introduces overhead to this so it won't be nearly as quick), in large experiments this can 
add up, especially if you are changing many parameters and sampling often.

As mentioned in Chapter 7, as well as measuring how long your experiments will take, it can be a good idea to measure how large your 
output files will be, particularly if you know they are likely to be large. This will allow you to better dial-in your sampling rate
according to the amount of space/RAM you have available to do analysis, and the resolution of the data you are collecting.

A much larger output is also in my example script:


```slim
306     for (mut in muts) {
            ...
317         mutsLine = paste(sim.generation, asString(seed), modelindex, mutType, 
                          mut.id, mut.position, mut.originGeneration, mutValue, 
                          mutChi, mutFreq, mutCount, "NA", sep = ",");
        }

```

Here, a line is created for each unique mutation existing in the population. This output quickly grows to large sizes. Hence, it is sampled
less often than the other output (line 420), to ensure the simulation is fast, and that the data isn't too big to handle.

## Compression

Another option is to compress your output. SLiM does have an option to compress custom output (via the `writeFile(compress = T)` argument),
however keep in mind this will raise the memory footprint of your model. As the documentation says, \"If the compress option is used in conjunction 
with append==T, Eidos will buffer data to append and flush it to the file in a delayed fashion (for performance reasons), and so appended data 
may not be visible in the file until later – potentially not until the process ends (i.e., the end of the SLiM simulation, for example).\"[^fn9]

In English, that means that SLiM holds onto the data that would be written to the file until it has time to decompress the file, add the new output line/s,
and recompress the file. This probably won't happen until the end of the simulation, however you can force this process to happen using the 
function `flushFile()`, which will stick all the 'waiting-to-be-written' lines of output onto the file and clear the queue. For example, if you are
appending output to a file every 50 generations, and you wanted to compress this output, you could use `flushFile()` to keep your RAM usage under control
by calling `flushFile()` every 500 generations or so.

## Footnotes
[^fn9]: Haller, B.C. (2021) Eidos: A Simple Scripting Language, Version 3.6, pp. 71, URL: http://benhaller.com/slim/Eidos_Manual.pdf 
