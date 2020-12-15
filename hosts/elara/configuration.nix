# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.kernelModules     = [ "i915" ];
    kernelParams             = [ "pci=nommconf" ];
    supportedFilesystems     = [ "zfs" ];
    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages           = pkgs.linuxPackages_latest;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP                   = false;
    interfaces.wlp2s0.useDHCP = true;
    hostId                    = "dcb6ee42";
    networkmanager.enable     = true;
    hostName                  = "elara";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
  ];

  # Set your time zone.
  time.timeZone = "America/Costa_Rica";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    slock.enable = true;
    zsh.enable   = true;
    dconf.enable = true;
  };

  xdg.portal = {
    enable       = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    gtkUsePortal = true;
  };

  # List services that you want to enable:
  services = {
    flatpak.enable  = true;
    resolved.enable = true;
    tlp.enable      = true;
    thermald.enable = true;
    upower.enable   = true;
    pcscd.enable    = true;
    udev.packages   = with pkgs; [ yubikey-personalization ];
    dbus.packages   = with pkgs; [ gnome3.dconf ];
    printing.enable = true;
    fwupd.enable    = true;

    restic = {
      backups = {
        homes = {
          repository        = "s3:http://paco.menari:9000/backups/restic/elara";
          passwordFile      = "/etc/nixos/secrets/restic-password";
          s3CredentialsFile = "/etc/nixos/secrets/restic-s3-credentials";
          paths = [
            "/home/jarias"
          ];
          timerConfig = {
            OnCalendar = "hourly";
          };
        };
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable                      = true;
    layout                      = "us";
    xkbVariant                  = "altgr-intl";
    autorun                     = true;
    videoDrivers                = [ "intel" ];
    # Enable touchpad support.
    libinput = {
      enable  = true;
      tapping = false;
    };

    displayManager.lightdm = {
      enable               = true;
      background           = /home/jarias/Pictures/ponyo002.jpg;
      greeters.enso.enable = true;
    };

    desktopManager = {
      xterm.enable = false;
      session = [
        {
          name  = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };
  };

  # Enable sound.
  sound.enable = true;

  hardware = {
    pulseaudio.enable             = true;
    cpu.intel.updateMicrocode     = true;
    enableRedistributableFirmware = true;
    opengl.extraPackages          = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver ];
  };

  virtualisation = {
    docker = {
      enable        = true;
      storageDriver = "zfs";
      listenOptions = ["0.0.0.0:2375" "/run/docker.sock"];
    };
    #virtualbox.host = {
    #  enable              = true;
    #  enableExtensionPack = true;
    #};
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jarias = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "audio" "docker" "vboxusers" ];
    shell        = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

