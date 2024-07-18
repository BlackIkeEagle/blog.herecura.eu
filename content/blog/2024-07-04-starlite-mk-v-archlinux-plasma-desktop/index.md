---
title: Starlite MK V and Arch Linux with Plasma Desktop
description: Use Arch Linux with Plasma Desktop on the Starlite MK V
date: 2024-07-04
categories:
  - linux
  - tablet
tags:
  - linux
  - tablet
---

Recently I received my Starlite MK V Linux tablet / laptop. While it took a bit more than 6 weeks to get it delivered, I'm still happy I made the order.

{{< notice note >}}
[Updates published on 18/07/2024](https://github.com/BlackIkeEagle/blog.herecura.eu/commit/09be0a9edbe8c71734a6ae11a330dea3cdea47c6)
{{< /notice >}}

<!--more-->

![Starlite boxes and extras](IMG_20240627_122724_672.jpg)

## Content

![Starlite charger usb-c](IMG_20240630_182729_588.jpg)

![Starlite tablet on its side](IMG_20240630_182857_909.jpg)

When I ordered the Starlite, I also added the keyboard and the stylus pen. I wanted to have the option to use this device like a laptop so the keyboard comes in handy. The stylus is just something extra, I really want to know how drawing on a Linux tablet will feel, and the kids will probably like it :).

![Starlite keyboard/touchpad and stylus](IMG_20240630_182944_108.jpg)

## First run

I ordered it with Ubuntu preinstalled since I thought that would be a safe bet. Well it looks like I have no idea how to use Ubuntu anymore. First the good part, everything that was installed worked fine. The on-screen keyboard showed up, automatic screen rotation went smooth. The initial configuration went well and I could log-in to Ubuntu. But when I installed krita to go and test drawing something with the stylus, things did not work so well. Krita did not even start. Since I did not really plan on using Ubuntu anyway I did not even bother trying to figure out what went wrong.

## Setting up Arch Linux with Plasma Desktop

Since this is an actual PC, installation of Arch Linux works fine. Via the boot menu I got to boot the Arch Linux ISO from a USB-stick. Using a script I installed Plasma Desktop as I would on any other computer. Since this will be about additional steps I had to take to make the tablet behave like a tablet I will not go into depth how to install Arch Linux, there are plenty of good resources for that. For the installation the keyboard came in handy, since I would probably not have been able to boot from USB and do a text based install without it.

![Plasma desktop system info](Screenshot_20240630_135725.png)

### tpmrm0 boot delay

When booting the first time I had to wait for a very long time for `/dev/tpmrm0.device`

```
jun 29 16:02:59 archlinux-MjkxYmFi systemd[1]: dev-tpmrm0.device: Job dev-tpmrm0.device/start timed out.  
jun 29 16:02:59 archlinux-MjkxYmFi systemd[1]: Timed out waiting for device /dev/tpmrm0.  
jun 29 16:02:59 archlinux-MjkxYmFi systemd[1]: dev-tpmrm0.device: Job dev-tpmrm0.device/start failed with result 'timeout'.
```

To overcome this I disabled the `tpm2.target`

```sh
systemctl mask tpm2.target
```

### On-screen keyboard

Since I'm using Plasma Desktop, `maliit-keyboard` is stated to be the best choice for the on-screen keyboard. I actually prepared my install script to install it already, but manual installation would be done with `pacman -S maliit-keyboard`. SDDM also needs to run on wayland to be able to use the on-screen keyboard. For this to work I added a extra config file `/etc/sddm.conf.d/plasma-wayland.conf` with the following content

```
[General]  
DisplayServer=wayland  
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell  
  
[Wayland]  
CompositorCommand=kwin_wayland --drm --no-global-shortcuts --no-lockscreen --locale1 --inputmethod maliit-keyboard
```

I had to add `--inputmethod maliit-keyboard` to get support for the on-screen keyboard.
With the default SDDM theme I had to touch the input language dropdown for the maliit-keyboard to show up. Once I started using the Breeze theme in SDDM it immediatly started showing up when I pressed the password field.

### Auto rotation of the display

At this point the tablet only works in landscape mode, there is no automatic rotation yet. To get this working I needed to install `iio-sensor-proxy`: `pacman -S iio-sensor-proxy`. After installing and a reboot the auto rotation started to work on both login screen and the desktop.

### Desktop in action

Below is a quick video recording of the desktop in action with on-screen keyboard and auto rotation of the display.

{{< video src="starlite-2024-07-04_18-21-05" >}}

### disable touchpad while typing

This does not seem to work when just ticked in system settings. When it gets listed via `libinput list-devices` it shows that disable while typing is enabled. So it does not seem to do anything.

```sh
libinput list-devices
...
Device:           HID 1018:1006 Touchpad  
Kernel:           /dev/input/event5  
Group:            4  
Seat:             seat0, default  
Size:             122x83mm  
Capabilities:     pointer gesture  
Tap-to-click:     disabled  
Tap-and-drag:     enabled  
Tap drag lock:    disabled  
Left-handed:      disabled  
Nat.scrolling:    disabled  
Middle emulation: disabled  
Calibration:      n/a  
Scroll methods:   *two-finger edge    
Click methods:    *button-areas clickfinger    
Disable-w-typing: enabled  
Disable-w-trackpointing: enabled  
Accel profiles:   flat *adaptive custom  
Rotation:         n/a
...
```

Trying some `libinput` quircks to see if that makes it a bit better.

`/etc/libinput/starlite-touchpad.quircks`

```
[Serial Keyboards]
MatchVendor=0x27C6
MatchProduct=0x0111
MatchUdevType=keyboard
AttrKeyboardIntegration=internal
```

### fwupdmgr is not showing "bios" updates

There was already an update for the system firmware, but fwupdmgr did not want to show it. According to [issue 24 on the StarLabs firmware github](https://github.com/StarLabsLtd/firmware/issues/24#issuecomment-1007307280), `iomem=relaxed` must be passed to the kernel commandline.

`/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="... iomem=relaxed"
```

Regenerate the grub config:

```sh
sudo grub-mkconfig -o /boot/efi/EFI/BOOT/grub/grub.cfg
```

Also note when `lockdown` is used it will not be possible to update coreboot since `flashrom` needs direct memory IO.

To manually update, get the last rom from the StarLabs [firmware repo](https://github.com/StarLabsLtd/firmware/tree/master/StarLite/MkV). I have updated to `24.06` manually with `flashrom`.

```sh
curl -OlL https://github.com/StarLabsLtd/firmware/raw/master/StarLite/MkV/coreboot/24.06/24.06.rom
sudo flashrom -p internal -w 24.06.rom -i bios --ifd -n -N
sudo systemctl poweroff
```

As stated on the firmware repo:

> 	Once that has finished, please shutdown (not a reboot), disconnect the charger and wait for 12 seconds until you see the LEDs flicker. Once that happens, you can reconnect the charger and carry on.


To get the `bios` to show up when running `fwupdmgr get-devices`, there is currently a quirck needed as found in [issue 179 of the firmware repo](https://github.com/StarLabsLtd/firmware/issues/179#issuecomment-2200038005):

`/var/lib/fwupd/quirks.d/starlite.quirk`

```
[3d9415bb-3027-541b-99b7-cf21e5383bdb]  
Plugin = flashrom
```

Then it shows up in the devices:

```
fwupdmgr get-devices

Star Labs StarLite  
│  
├─N200:  
│     Device ID:          4bde70ba4e39b28f9eab1628f9dd6e6244c03027  
│     Current version:    0x00000017  
│     Vendor:             Intel  
│     GUIDs:              90cc499c-3166-5538-b337-ac47d715d50b ← CPUID\PRO_0&FAM_06&MOD_BE  
│                         dcb3a326-6c55-59ef-a947-d5ae46f7b4ec ← CPUID\PRO_0&FAM_06&MOD_BE&STP_0  
│     Device Flags:       • Internal device  
│      
├─NVME 1TB SSD:  
│     Device ID:          71b677ca0f1bc2c5b804fa1d59e52064ce589293  
│     Summary:            NVM Express solid state drive  
│     Current version:    T1103N0L  
│     Vendor:             Silicon Motion, Inc. (NVME:0x126F)  
│     Serial Number:      2024011200227  
│     GUIDs:              eb4c6074-9dc2-57ae-bd43-1119ad6080f5 ← NVME\VEN_126F&DEV_2263  
│                         165a89d1-acc2-51c7-92b9-300207a5409c ← NVME\VEN_126F&DEV_2263&SUBSYS_126F2263  
│                         abd4111a-12e7-5c7c-9e79-35da2766ab3a ← NVME 1TB SSD  
│     Device Flags:       • Internal device  
│                         • Updatable  
│                         • System requires external power source  
│                         • Needs a reboot after installation  
│                         • Device is usable for the duration of the update  
│      
└─StarLite (bios):  
     Device ID:          dbee8bd3b1ae0316ad143336155651eedb495a0e  
     Current version:    24.06  
     Vendor:             Star Labs (DMI:coreboot)  
     GUIDs:              b2e0b708-4ced-5edb-83fe-eac07c774b3a ← FLASHROM\VENDOR_Star Labs&PRODUCT_StarLite&REGION_BIOS  
                         31626536-411f-5e0a-9c93-95b6839d6366 ← FLASHROM\GUID_3d9415bb-3027-541b-99b7-cf21e5383bdb  
                         f03fd104-123b-59da-a3a0-72fdd4eedbae ← Star Labs&I5&StarLite&I5&Star Labs&StarLite  
                         a9d3771c-03ed-506d-83f6-310ce9cbd252 ← Star Labs&I5&StarLite&I5  
                         9878fde8-dbff-5024-ae11-7580fafd445f ← Star Labs&I5&StarLite  
                         80d2617e-b380-559d-8caf-fb36afea3478 ← Star Labs&I5&Star Labs&StarLite  
                         c9d8edd8-8c89-598f-9d7a-e3ad247ee9cd ← Star Labs&I5&StarLite&I5&coreboot  
     Device Flags:       • Internal device  
                         • Updatable  
                         • System requires external power source  
                         • Supported on remote server  
                         • Needs shutdown after installation  
                         • Cryptographic hash verification is available
```

## Chromium based browsers

Since I'm normally using Vivaldi, I searched a bit how to get the on-screen keyboard popping up. By default none of the Chromium based browsers trigger the on-screen keyboard and by not doing that become pretty useless when in tablet mode.

To get the on-screen keyboard working I had to add the following flags to Vivaldi (I'm going to assume other chromium based browsers will need the same flags):

```
--ozone-platform-hint=auto
--ozone-platform=wayland
--enable-wayland-ime
```

## maliit-keyboard tweaks

Set the theme to `Breeze` to integrate properly with Plasma Desktop.

```sh
gsettings set org.maliit.keyboard.maliit theme Breeze
```

I like to see a bit of the underlying screen when the keyboard pops up. Maliit-keyboard allows opacity.

```sh
gsettings set org.maliit.keyboard.maliit opacity 0.8
```

To allow input for other languages we can set possible languages via the settings. I have not yet found how to change the keyboard layout for maliit-keyboard yet.

```sh
gsettings set org.maliit.keyboard.maliit enabled-languages "['en', 'nl']"
```

Because the auto capitalization did not really behave as I expected. I got it disabled.

```sh
gsettings set org.maliit.keyboard.maliit auto-capitalization false
```

To get a graphical interface for these settings you can install `dconf-editor`.

## General impression

### My requirements

Since the impression of the device and how the software works depends on your personal requirements, I'll list mine here.

I wanted to have a very portable device, where I can comfortably browse the web, handle some email and read a paper or a book. Additionally I want to be able to remotely login into another system with ssh or a remote desktop.

Writing a document was not really my first requirement, but taking some notes is interesting.

As and extra because it is a tablet after all and I ordered the stylus, letting the kids draw something on it would be cool.

### Pros

- It is a PC, so you can install all your favorite applications and have no learning curve
- The N200 cpu is fairly capable for many tasks
- The 12 inch form-factor makes it very portable
- I love the possibility to use it as tablet, or with the keyboard/touch-pad
- The battery life is pretty good compared to a laptop

### Cons

- The touch-pad does not properly disable while typing which leads to many accidental clicks while typing
- Selecting large portions of text is tricky, sometimes the touch-pad does lose it's click while selecting
- The keyboard with stand has more depth than a laptop, so no comfortable use of a laptop pillow in the sofa
- The keyboard is missing some keys like `home`, `end`, `ins`, ... which make some tasks annoying
- Maliit-keyboard only had qwerty layout, it conflicts a bit with my default azerty layout
- Bluetooth does not work at all, its not even detected to be present

### Annoyances

- Maliit-keyboard sometimes refuses to show, or the other way around to go away
- Applications in XWayland don't always work so great with the on-screen keyboard
- While using it as a tablet it is fairly heavy for long reading sessions

## Conclusion

I like the Starlite MK V, it suits my needs pretty good and might over time replace a lightweight laptop and an aging Android tablet. For tasks on the go it will come in handy. The keyboard with stand makes it handy to do some productivity tasks. The tablet mode makes it great for consuming media, books, papers, ...

Overall I'm also impressed by how well everything already works with a touch-only interface (once installed). But compared to for example Android there are still some rough edges. Nothing outside of my expectation, I was expecting the need for some tweaking so it is fine for my use. But it is probably not yet for the general audience.

So I like my current setup of the Starlite and looking forward to improve it further, after only one week since receiving it's looking good.
