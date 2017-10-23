#!/bin/bash
#释放buffers/cache内存：sysctl vm.drop_caches=3
#由于linux系统采用的是虚拟内存，进程的代码，库，堆和栈使用的内存都会消耗内存，但是申请出来的内存，只要没真正touch过，是不算的，因为没有真正为之分配物理页面。
#resident set size 也就是每个进程用了具体的多少页的内存。
#我们实际进程使用的物理页面应该用resident set size来算的，遍历所有的进程，就可以知道所有的所有的进程使用的内存
for PROC in `ls /proc/|grep "^[0-9]"`
do
if [ -f /proc/$PROC/statm ]; then
TEP=`cat /proc/$PROC/statm | awk '{print ($2)}'`
RSS=`expr $RSS + $TEP`
fi
done
RSS=`expr $RSS \* 4`
PageTable=`grep PageTables /proc/meminfo | awk '{print $2}'`
SlabInfo=`cat /proc/slabinfo |awk 'BEGIN{sum=0;}{sum=sum+$3*$4;}END{print sum/1024/1024}'`
echo "进程实际占用总内存(RSS):$RSS KB, 内核占用硬开销(PageTables):$PageTable KB,内核对象池占用内存(Slab):$SlabInfo MB"
printf "RSS+PageTable+SlabInfo=%sMB\n" `echo $RSS/1024 + $PageTable/1024 + $SlabInfo|bc`
#小结：内存的去向主要有3个：1. 进程消耗  2. slab消耗  3.pagetable消耗。
#注：脚本计算结果会比free显示大。
#原因：resident resident set size 包括我们使用的各种库和so等共享的模块，在前面的计算中我们重复计算了。多出的部分正是共享库重复计算的部分。但是由于每个进程共享的东西都不一样，我们也没法知道每个进程是如何共享的，没法做到准确的区分。