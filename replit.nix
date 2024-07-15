{ pkgs }: {
  deps = [
    pkgs.nodePackages.prettier
    pkgs.python38Full
    pkgs.python38Packages.flask
    pkgs.python38Packages.flask_sqlalchemy
    pkgs.python38Packages.pillow
    pkgs.python38Packages.sqlalchemy
    pkgs.nodejs-20_x
  ];
}