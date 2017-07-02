#  oelminsec    
Build Oracle Linux from Centos and minsec (olelminsec)   
   oelminsec.json - main packer file  
   vars.json    - defined variables to be referenced in the main packer file.   
   userdata-minsec.sh - userdata script   
Command to run packer   
   packer build -var-file= vars.json oelminsec.json   
   
NOTE:  
source ami is the one created by the oelbase
we use shell script userdata-minsec.sh instead of in-line shell  
