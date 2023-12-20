# fedora-kiwi-descriptions

This project is used to manage the Fedora KIWI image descriptions used in composing Fedora release images.

The `rawhide` branch is used for Fedora Rawhide images and each release branch is used by that release.

All changes should be made via the PR workflow.

## Image variants

* Cloud Edition (image type: `oem`, image profiles: `Cloud-OpenStack`/`Cloud-AmazonEC2`/`Cloud-Azure`/`Cloud-GCE`/`Cloud-Oracle`)
* KDE Spin (image type: `iso`, image profiles: `KDE-Live`)
* Vagrant Cloud Edition (image type: `oem`, image profiles: `Vagrant-libvirt`/`Vagrant-VirtualBox`)
* Workstation Edition (image type: `iso`, image profiles: `Workstation-Live`)

## Image build quickstart

Set up your development environment and run the image build (substitute `<image_type>` and `<image_profile>` for the appropriate settings):

```bash
# Install kiwi
[]$ sudo dnf --assumeyes install kiwi
# Run the image build
[]$ sudo ./kiwi-build --image-type=<image_type> --image-profile=<image_profile> --output-dir ./outdir
```

## CI information

This project is tested using the Software Factory Zuul CI instance
using the [Test Management Tool](https://tmt.readthedocs.io/).

## Licensing

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, under version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
