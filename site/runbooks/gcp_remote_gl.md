Remote OpenGL on GCP with Nvidia GPUs
=====================================

In this runbook, we will see how to display a graphical application locally
with the GL rendering being computed a remote workstation.

```
  server:                                              client:
 ······································               ·················
 : ┌───────────┐ X11 commands         :               : ┌───────────┐ :
 : │application│━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━▶│X server 2)│ :
 : │           │        ┌───────────┐ :               : │           │ :
 : │           │        │X server 1)│ :               : ├┈┈┈┈┈┈┈┈┈╮ │ :
 : │ ╭┈┈┈┈┈┈┈┈┈┤ OpenGL │ ╭┈┈┈┈┈┈┈┈┈┤ : image stream  : │VirtualGL┊ │ :
 : │ ┊VirtualGL│━━━━━━━▶│ ┊VirtualGL│━━━━━━━━━━━━━━━━━━▶│client   ┊ │ :
 : └─┴─────────┘        └─┴─────────┘ :               : └─────────┴─┘ :
 ······································
                    from https://wiki.archlinux.org/index.php/VirtualGL
```


We will make use of a Virtual Machine (VM) on Google Cloud Platform (GCP) with NVIDIA GPUs.
Visit the [GCP marketplace][nvidia-vws-ubuntu] to create a NVIDIA Quatro
Virtual Workstation based on Ubuntu 18.04

```eval_rst
.. note:: NVIDIA® Quadro® Virtual Workstation is an NVIDIA Virtual Machine Image (VMI) preconfigured with Quadro Virtual Workstation software and NVIDIA GPU hardware. The NVIDIA Quadro driver is preinstalled on the VMI and NVIDIA ensures that the image is always up to date with the latest Quadro ISV certifications, patches, and upgrades. Support and technical information to help you get started are available on the NVIDIA Quadro vWS on CSP Marketplace community forum and from additional resources.
```

VM preparation
--------------

- Setup GL with NVIDIA
```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libxau6 libxau6:i386 libxdmcp6 libxdmcp6:i386 \
                        libxcb1 libxcb1:i386 libxext6 libxext6:i386 \
                        libx11-6 libx11-6:i386
echo "/usr/local/nvidia/lib"   | sudo tee -a /etc/ld.so.conf.d/nvidia.conf
echo "/usr/local/nvidia/lib64" | sudo tee -a /etc/ld.so.conf.d/nvidia.conf
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
echo 'export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"' >> $HOME/.bashrc
sudo apt-get install -y libglvnd0 libglvnd0:i386 \
                        libgl1 libgl1:i386 \
                        libglx0 libglx0:i386 \
                        libegl1 libegl1:i386 \
                        libgles2 libgles2:i386
cat > /tmp/10_nvidia.json  << 'EOF'
{
    "file_format_version" : "1.0.0",
    "ICD" : {
        "library_path" : "libEGL_nvidia.so.0"
    }
}
EOF
sudo mv /tmp/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
sudo apt-get install -y pkg-config \
                        libglvnd-dev libglvnd-dev:i386 \
                        libgl1-mesa-dev libgl1-mesa-dev:i386 \
                        libegl1-mesa-dev libegl1-mesa-dev:i386 \
                        libgles2-mesa-dev libgles2-mesa-dev:i386
```

- Setup Xorg
```
sudo apt-get install -y xserver-xorg xinit xterm
sudo nvidia-xconfig -a --use-display-device=Screen0 --virtual=1280x1024
sudo xinit &
```

- Setup VirtualGL
```
wget https://sourceforge.net/projects/virtualgl/files/2.6.3/virtualgl_2.6.3_amd64.deb/download -O virtualgl_2.6.3_amd64.deb
sudo dpkg -i virtualgl_2.6.3_amd64.deb
sudo apt-get install -f
sudo /opt/VirtualGL/bin/vglserver_config
sudo usermod -a -G vglusers $USER
```

- Setup TurboVNC (Optional)
```
wget https://sourceforge.net/projects/turbovnc/files/2.2.3/turbovnc_2.2.3_amd64.deb/download -O turbovnc_2.2.3_amd64.deb
sudo dpkg -i turbovnc_2.2.3_amd64.deb
sudo apt-get install xfce4 xfce4-goodies
/opt/TurboVNC/bin/vncserver
```

Connect from localhost
----------------------

[VirtualGL][virtualgl-intro] must be installed on the client as well.
Next we can get a shell on the VM with `vglconnect`. Depending on the
authentication method, you might need to provide the ssh key like this:
```
vglconnect -s ${USER}@X.X.X.X -i ~/.ssh/google_compute_engine
```

GL application can be started from the VM with `vglrun`. For example:
```
vglrun glxgears
```

References
----------

* [Creating a virtual GPU-accelerated Linux workstation][nvidia-vws-ubuntu]
* [IA Quadro Virtual Workstation - Ubuntu 18.04][ia-quatro-vws]
* [Quadro Virtual Workstation on Google Cloud Platform Quick Start Guide][nvidia-vws-doc]
* [A Brief Introduction to VirtualGL][virtualgl-intro]
* [VirtualGL - ArchLinux Wiki][virtualgl-archlinux]
* [User Guide for VirtualGL and TurboVNC][userguide-virtualgl-turbovnc]

[nvidia-vws-ubuntu]: https://console.cloud.google.com/marketplace/details/nvidia/nvidia-quadro-vws-ubuntu-18
[ia-quatro-vws]: https://console.cloud.google.com/marketplace/details/nvidia/nvidia-quadro-vws-ubuntu-18
[nvidia-vws-doc]: https://docs.nvidia.com/grid/qvws/latest/qvws-quick-start-guide-google-cloud-platform/index.html
[virtualgl-intro]: https://virtualgl.org/About/Introduction
[virtualgl-archlinux]: https://wiki.archlinux.org/index.php/VirtualGL
[userguide-virtualgl-turbovnc]: https://virtualgl.org/vgldoc/2_1_1/
<br>
