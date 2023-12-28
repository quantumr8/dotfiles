# The name of the ISO
iso_name="archflash"

# The label of the ISO
iso_label="ARCHFLASH_$(date +%Y%m)"

# The ISO application ID
iso_application="Custom Arch Linux Live/Rescue CD"

# The ISO publisher
iso_publisher="quantumr8 <https://github.com/quanturm8/dotfiles>"

# The ISO copyright
iso_copyright="Copyright © 2023 ArchFlash Linux"

# The Arch Linux logo
iso_logo="archlinux-logo-dark-scalable.svg"

# The boot mode: 'dual' means both BIOS and UEFI, 'bios' means BIOS only, 'uefi' means UEFI only
bootmode='uefi'

# Enable x86_64-v2 microarchitecture requirements (1 to enable; leave blank or set to 0 to disable)
x86_64_v2=1