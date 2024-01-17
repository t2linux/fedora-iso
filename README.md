# t2linux-fedora-iso

This repo has kiwi image descriptions for t2linux Fedora ISOs.

Combine the split ISOs with `cat name_of_iso_here.iso.* > full.iso`.

## Building the ISOs

Clone this repo then run:

```bash
podman run --rm --privileged -v $PWD:/repo ghcr.io/t2linux/fedora-dev /repo/build.sh
```

## Disclaimer
This project is not officially provided or supported by the Fedora Project. The official Fedora software is available at [https://fedoraproject.org/](https://fedoraproject.org/). This project is not related to Fedora in any way.
