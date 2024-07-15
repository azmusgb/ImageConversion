{ pkgs }: {
  deps = [
    pkgs.python310Full
    pkgs.python310Packages.flask
    pkgs.python310Packages.pillow
    pkgs.python310Packages.sqlalchemy
    pkgs.python310Packages.flask_sqlalchemy
    pkgs.nodejs-20_x  # Correct Node.js version
  ];
}