# Patch Management - kitchen_examples/azure

This directory contains an example kitchen file and local settings file for building an 
example architecture for WSUS patch management.

To use this example, simply change to this directory and create a symlink using the 
kitchen.windows.yml file to kitchen.yml OR copy the kitchen.windows.yml example to 
kitchen.yml. Then use the normal kitchen commands like so:

```bash
kitchen list
kitchen create
kitchen converge
```

Once everything is created you should then be able to login into the WSUS server using 
the public IP and the credentials contained in the hidden `.kitchen` directory using 
your favorite remote desktop client. You should then be able to login to the client 
from the WSUS server to check the patch status and/or point it to the WSUS server.

 
