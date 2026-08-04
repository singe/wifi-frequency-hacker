# wifi-frequency-hacker
A modified frequency regulatory domain configuration that doesn't limit you.

## Overview

Different countries enforce different frequency restrictions on the various wifi channels. This can be a pain if your card/OS is forcing you into a different configuration than the one you need. There are numerous reasons why this may be happening. From drivers favouring EEPROM configurations over your settings to weird decision making based on observed network activity. Either way, the discerning wifi hacker doesn't want to have to bother with such t
hings.

This repository provides a source `db.txt` for Linux wireless regulatory data and a legacy `regulatory.bin` snapshot. The modern kernel path is to build and load `regulatory.db` through cfg80211's firmware loader, not through CRDA.

## Contents
- `db.txt` - source regulatory database used to generate the modern `regulatory.db`
- `regulatory.bin` - legacy CRDA-era binary snapshot kept for reference
- `singe.key.pub.pem` - legacy public key used by the old CRDA flow

## Benefits
This includes:
* Being able to access all sorts of channels, such as 14 (JP only usually) in 2.4Ghz, an assortment in 5Ghz, 6Ghz and even some of the 60Ghz or special 4Ghz bands.
* Being able to transmit at full power (30dBm), no power limits.
* Being able to use large band configurations (40/80/160/320) where the continuous spectrum allows is.
* Being able to ignore DFS.

The caveat is that your hardware still has to support the band or width you want to use.

## Warnings
Many of these settings are illegal in many jurisdictions. Passive monitoring is one thing; transmitting is another. Be careful.

Note:
- Some combinations are impossible in practice even if the rules allow them
- Hardware and firmware can still refuse to operate outside what they were designed for
- You are responsible for complying with local law

This let's you do dangerous things too, and you need to be very careful how you use this. In particular:
* Many of these configurations are completely illegal in many different countries. Passive monitoring of those frequencies isn't likely to get you caught, but transmitting at full power in some of them could not only get you in trouble, but also interfere with critical services such as emergency services. Here's a list of actions taken against those caught violating FCC rules in this way in the US https://www.fcc.gov/general/u-nii-and-tdwr-interference-enforcement
* Many of these configurations are impossible, for example, channel 14 (2474-2494) should only be available in Japan, at 20Mhz width and 802.11b only (no OFDM). However, with this configuration, you may be able to violate all of that and create a network no device would be able to connect to.
* You could break your device. Transmitting at too high power on frequencies or configurations the firmware/hardware never thought anyone could/would may lead to undesirable consequences to your hardware.

When in doubt, don't transmit! This wiki page usually has the latest details on which wifi channels are available in which country:
https://en.wikipedia.org/wiki/List_of_WLAN_channels

## Modern kernel path
Modern Linux kernels load the regulatory database as a firmware file named `regulatory.db` from `/lib/firmware`.

If you want the kernel to accept an unsigned `regulatory.db`, rebuild either the kernel, or if you can, the cfg80211.ko module, with:

```text
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=n
```

With that configuration, cfg80211 will accept an unsigned `regulatory.db` without requiring a matching `regulatory.db.p7s`.

How to rebuild kernels or modules is beyond the scope of this readme.

## Building `regulatory.db`
The current workflow is:

1. Update `db.txt` in this repository.
2. Build `regulatory.db` with the upstream wireless-regdb tree.
3. Install the resulting `regulatory.db` into `/lib/firmware/`.

Example:

```bash
git clone git://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git
cd /path/to/wifi-frequency-hacker
make WIRELESS_REGDB_DIR=/path/to/wireless-regdb build
sudo make install
```

This repo's build path generates an unsigned `regulatory.db`. If your kernel still requires signed regdb files, you will need a separate signed upstream build and its matching `regulatory.db.p7s` as well as to have modified the kernel to include your key. That's beyond the scope of this.

Verify the result with:

```bash
iw reg get
```

You should see the permissive rules from this database, including the 6 GHz band.

## Updating the database
To refresh the database here:

1. Edit `db.txt`.
2. Rebuild `regulatory.db` from the updated `db.txt`.
3. Install or ship the new `regulatory.db` in `/lib/firmware/`.

## Old behavior
The following CRDA-based flow is retained only for older systems.

### Installing CRDA-era files
If you are on an older setup that still uses CRDA and external key support, the legacy install path was:

```bash
apt-get install wireless-regdb crda
git clone https://github.com/singe/wifi-frequency-hacker
cd wifi-frequency-hacker
cp /lib/crda/regulatory.bin /lib/crda/regulatory.bin.orig
cp regulatory.bin /lib/crda/
cp singe.key.pub.pem /lib/crda/pubkeys/
iw reg set ZA
iw reg get
```

That flow depends on CRDA trusting the bundled public key and is not the preferred path on modern kernels.

### Legacy verification
On older CRDA systems, `regdbdump /lib/crda/regulatory.bin` was used to check the installed binary. If signature verification failed, the CRDA build was usually using static signatures.

## Further reading
Linux wireless regulatory documentation:
https://wireless.docs.kernel.org/en/latest/en/developers/regulatory.html
