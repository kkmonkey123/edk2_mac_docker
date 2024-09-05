## Introduction  
This repo is to provide a env to run edk2 on qemu on arm Mac  
With the below cmd, you should be able to build a bootable fd file on qemu on Mac.  
### Download Dockerfile

### Build Docker
```
docker build -t mac-arm-edk2-env .
```
### Enter Docker
```
docker run -p 2222:22 -v $PWD:/tmp/localdrive -it mac-arm-edk2-env /bin/bash
```
### Once enter docker
```
export GCC_AARCH64_PREFIX=/usr/sbin/aarch64-linux-gnu-
make -C BaseTools
source edksetup.sh 
build -a AARCH64 -t GCC48 -p ArmVirtPkg/ArmVirtQemu.dsc
```

The FW for Qemu is located here in docker ./Build/ArmVirtQemu-AARCH64/DEBUG_GCC48/FV/QEMU_EFI.fd
You can cp ./Build/ArmVirtQemu-AARCH64/DEBUG_GCC48/FV/QEMU_EFI.fd /tmp/localdrive. 
Then the QEMU_EFI.fd will be cp outside of docker  

### Open another term in Mac
```
brew install qemu # verify the installation
qemu-system-aarch64 --version # verify the installation
qemu-system-aarch64 -M virt -cpu cortex-a57 -nographic -smp 2 -m 1024 -bios QEMU_EFI.fd -drive file=fat:rw:$PWD,format=raw
```
Once it's booted, you should see the below screen.  
<img width="594" alt="image" src="https://github.com/user-attachments/assets/893be589-228d-428e-a574-6066dd65e724">

