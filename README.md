# wifi-frequency-hacker
A modified frequency regulatory domain configuration that doesn't limit you.

Overview
---------
Different countries enforce different frequency restrictions on the various wifi channels. This can be a pain if your card/OS is forcing you into a different configuration than the one you need. There are numerous reasons why this may be happening. From drivers favouring EEPROM configurations over your settings to weird decision making based on observed network activity. Either way, the discerning wifi hacker doesn't want to have to bother with such things.

Contents
--------

This contains a modified binary regulations configuration (regulatory.bin), based on the plain-text input file (db.txt). This configuration sets all countries to the same setting, and that setting is the least restrictive possible. That way, no matter what domain you're being forced into, you get the same functionality.

Benefits
--------

This includes:
* Being able to access all sorts of channels, such as 14 (JP only usually) in 2.4Ghz, an assortment in 5Ghz and even some of the new 60Ghz or special 4Ghz bands.
* Being able to transmit at full power (30dBm), no power limits.
* Being able to use large band configurations (40/80/160) where the continuous spectrum allows is.
* Being able to ignore DFS.

The caveat is that your hardware needs to support what you're trying to do (e.g. this won't give a 2.4Ghz only card 5Ghz capabilities).

Warnings
--------

Of course, this let's you do dangerous things too, and you need to be very careful how you use this. In particular:
* Many of these configurations are completely illegal in many different countries. Passive monitoring of those frequencies isn't likely to get you caught, but transmitting at full power in some of them could not only get you in trouble, but also interfere with critical services such as emergency services. Here's a list of actions taken against those caught violating FCC rules in this way in the US https://www.fcc.gov/general/u-nii-and-tdwr-interference-enforcement
* Many of these configurations are impossible, for example, channel 14 (2474-2494) should only be available in Japan, at 20Mhz width and 802.11b only (no OFDM). However, with this configuration, you may be able to violate all of that and create a network no device would be able to connect to.
* You could break your device. Transmitting at too high power on frequencies or configurations the firmware/hardware never thought anyone could/would may lead to undesirable consequences to your hardware.

When in doubt, don't transmit! This wiki page usually has the latest details on which wifi channels are available in which country:
https://en.wikipedia.org/wiki/List_of_WLAN_channels

Installing
----------

If you have a crda compiled with external key support, you need to do two things to install this. The first is to overwrite your existing regulatory.bin with the new one. The second is to copy my public key to the right directory.

When overwriting the .bin, make sure to make a backup of the original so you can go back to normal wifi function if you need to/want to.

My public key is needed because the binary is signed by my private key, and crda needs the public key to validate that signature.

On Kali Rolling 2016.1 I ran the following commands:

```
apt-get install wireless-regdb crda
```
This will make sure you get the pre-requisites.

```
git clone https://github.com/singe/wifi-frequency-hacker
cd wifi-frequency-hacker
```
Get a copy of this repo.
```
cp /lib/crda/regulatory.bin /lib/crda/regulatory.bin.orig
cp regulatory.bin /lib/crda/
cp singe.key.pub.pem /lib/crda/pubkeys/
```
Make a backup of the original file, and replace it with the new one, and add my public key to crda's list of accepted keys.
```
iw reg set ZA 
```
If you change to a new locale that isn't your current, the new setting will take effect. 
```
iw reg get 
```
You should see something like:
```
country XX: DFS-UNSET
	(2400 - 2494 @ 80), (N/A, 30), (N/A)
	(4910 - 4990 @ 80), (N/A, 30), (N/A)
	(5030 - 5090 @ 40), (N/A, 30), (N/A)
	(5150 - 5350 @ 160), (N/A, 30), (N/A)
	(5470 - 5730 @ 160), (N/A, 30), (N/A)
	(5725 - 5875 @ 80), (N/A, 30), (N/A)
	(17100 - 17300 @ 160), (N/A, 30), (N/A)
	(57000 - 66000 @ 2160), (N/A, 40), (N/A)
```
The country doesn't matter (all countries are set to the same). But you should see that list of frequencies, anything less or with DFS options, and your changes to regulatory.bin haven't been applied, either because you need to compile your own version that trust your key (see the link at the end) or because you overwrote the wrong regulatory.bin.

```
iw list|grep dBm
```
These will give you a view of the resulting configuration. The first a list of the regulatory restrictions, and the second the net result of the channels available to you. You shouldn't see any "disabled" notes here, if you do, and you applied the crda changes correctly, then it means your firmware is preventing use of these channels.

If it doesn't seem to be working, try running:
```
regdbdump /lib/crda/regulatory.bin
```
If the output includes `Database signature verification failed`, your version of crda is probably compiled with static signatures, and you will need to compile and install your own crda binary using the instructions linked below. Fedora is known to use static signatures.

Making your own
---------------

Information on building your own is available from the kernel.org team at:
https://wireless.wiki.kernel.org/en/developers/regulatory
