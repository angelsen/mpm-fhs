# MATLAB Nix Module

This Nix module provides a convenient way to install and manage MATLAB using the MATLAB Package Manager (MPM) within a Nix environment. It creates an FHS (Filesystem Hierarchy Standard) environment to ensure compatibility with MATLAB's requirements.

## Features

- Installs MATLAB and specified products using MPM
- Creates an FHS environment for running MATLAB and MPM
- Provides command-line tools for running MATLAB and MPM in the FHS environment
- Generates a desktop entry for easy MATLAB launch

## Prerequisites

- Nix package manager
- Home Manager

## Installation

1. Clone this repository or copy the `mpm-fhs` module into your Nix configuration directory.

2. Import the module in your `home.nix` file:

```nix
{
  imports = [
    /path/to/mpm-fhs
  ];
}
```

3. Enable and configure the module in your `home.nix`:

```nix
programs.mpm-fhs = {
  enable = true;
  release = "R2024a"; # Specify the desired MATLAB release
  products = ["MATLAB" "Simulink" "Control_System_Toolbox"]; # List desired products
};
```

4. Run `home-manager switch` to apply the changes.

## Usage

After installation, you can use the following commands:

- `mpm-env`: Run MPM commands in the FHS environment
- `matlab-env`: Run MATLAB in the FHS environment
- `install-matlab`: Install MATLAB with the specified configuration

MATLAB can also be launched from your desktop environment's application menu.

## Customization

You can customize the MATLAB installation by modifying the `release` and `products` options in your `home.nix` file.

## Notes

- The module uses the `nix-matlab` repository for MATLAB dependencies. Ensure you have the necessary licenses for the MATLAB products you install.
- The first run of `home-manager switch` after enabling the module will download and install MATLAB, which may take some time depending on your internet connection and the products selected.

## Contributing

Contributions to improve this module are welcome. Please submit issues or pull requests on the project's repository.

## License

This module is provided under the [MIT License](LICENSE). Note that MATLAB itself is proprietary software and subject to its own licensing terms.