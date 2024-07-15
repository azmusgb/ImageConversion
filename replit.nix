{ pkgs }: {
  deps = [
    pkgs.python38Full
    pkgs.python38Packages.flask
    pkgs.python38Packages.pillow
    pkgs.python38Packages.sqlalchemy
    pkgs.python38Packages.flask_sqlalchemy
    pkgs.nodejs-20_x
  ];
}