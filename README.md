# UW-Madison ECE552 Introduction to Computer Architecture Course Project
This is an implementation of WISC-F15, a pipelined micro computer with a cache-memory hierarchy. 

The WISC-F15 description is documented in "F15_552_Project_description_Stage1.pdf", "F15_552_Project_description_Stage2.pdf". 

The program is compiled by [icarus](http://iverilog.icarus.com/) on Ubuntu 14.04 LTS.
[gtkwave](http://gtkwave.sourceforge.net/) is a tool to visualize and watch the signal waves.

## How to compile the program?
<pre><code>
    cd verilog
    ./compile.sh
</code></pre>

## How to run the program?
<pre><code>
    cd bin
    ./run.sh $number
</code></pre>

$number can be 0 ~ 5, corresponding to the test cases in ProjectStage2Tests
