**Big O:**
Single threaded CPU approach: 
For each item in N, you need to add sum[i-1] to N[i]. So that's about 1 computation per item, so big O for this is on the order of N.

Naive:
For each item in N, you need to add up all the items before N. So that's  on the order of N^2.

Multiple kernels:
In my implementation, the first kernel takes about 100 steps per thread. 
The second kernel takes about N/100 steps --> on the order of N.
The third kernel takes the same as the first. 
So the big O for this approach is on the order of N. 

My multiple kernels code isn't quite right but I am not going to work on it anymore. Its bugginness seems to be reflected in the data/graph. 
Here is my chart: https://docs.google.com/spreadsheets/d/1AZzwl93NQRtVerehv-FWmDHM1jgvLjL-6XXGBz1eVMc/edit?gid=0#gid=0
