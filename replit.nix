{pkgs}: {
  deps = [
    pkgs.python311Packages.gunicorn
    pkgs.php82
    pkgs.rsync
    pkgs.imagemagick
    pkgs.openssh
  ];
}
