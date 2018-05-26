when heap becomes full, garbage is collected

methods, thread stacks, and native handles are allocated in memory separate from the heap

heap divided into 2 generations: 
young space => for allocation of new objects, gc is collected by running a special young collection. When all objects that have lived long enough in the nersery are promoted to the old space
old space => old collection is triggered when old collection is full

small objects => thread local areas: free chunks reserved rom the heap and given to a thread for exlcusive use
large objects => directly on the heap

----
GC: mark and sweep
During sweep the heap is traversed to find the gaps between the live objects, gaps are recorded in a free list and are made availble for new object allocation

mostly concurrent mark: =>

mostly concurrent sweep phase: 
=> sweeping of one half of the heap, so that other threads can allocate objects in the part of the heap that is not being swept
=> swtich halves
=> sweeping the other half of the heap

JVM compacts a part of the heap at every old GC. size and position of the compaction area is selected by heuristics
In throughput mode, the compaction area size is static
In other modes. compaction area size changes to keep compaction times equal throughout the run.

external compaction: typically near the top of the heap. Moves the objects within the compatciotn area to free positions outside the compaction area and as far down in the heap as possible
interal compaction: near the bottom where the desity of objects is higher. move objects within the compaction area ar far down int he
ompaction as possible

The postion of the compaction area changes at each GC, using one or two sliding windows to determin the next position


-----
Patterns for fragment problem:
degradation over time, suddenly pops back to excellent, and start degrading again

JVM options: 
Compaction ratio: compact percentage of the heap at each old collection
Compact set limit: how many references there may be from objects outside the compaction area to objects within the compaction area

I just checked on a linux machine with 5gb physical memory. Default max heap shows as 1.5gb

-------
Heap - Java usable memory by devs
non-heap - JVM itself

method region, JIT memory, type and stuff are in the non-heap memory

1. JVM's own memmory, including 3rd party lib, and memories allocated by the memory

2. NIO DirectBuffer -> native memory

class JVM's GC is in per gen, hard to GC

thread stack
 
method region- perm gen -> shared thread ram region
runtime constant, part of method region

local var table needed ram space is determned during compliation, when entering a method, the size of stack frame is fixed, so it won't change local var table's size

program counter: current thread's bytecode's PC

jmap -heap [pid]

jstat -gcutil [pid]

Memory model
--------


Heap - Method Area (including runtime constant pool) - VM Stack(includeing stack frames) - native method stack - program coutner register

Sometime VM Stack and Method Stack are combined.

Method Area: 

	every type's struct info: RCP, String ,and method data, constructor,and normal method's string content
	
	type , instance,interface's special method required on init

Direct memory: native method stack applied outside the hep, ei.g., DirectByteBuffer inside NIO





